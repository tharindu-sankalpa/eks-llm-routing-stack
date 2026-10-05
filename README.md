# A central AI control plane on Amazon EKS with LiteLLM, kagent and kmcp

This repository builds one gateway in front of three things an AI platform has to govern: LLM models, MCP tool servers and agents. LiteLLM is the gateway. kagent runs an agent as a Kubernetes resource. kmcp runs MCP servers as Kubernetes resources. Everything runs on one Amazon EKS cluster in `ap-south-1`, and every registration in the gateway is made with a REST call.

The point of the repo is not only the result. It contains every command in the order it was run, the exact chart values, the raw API responses, and the problems hit on the way, including one caused by picking the newest kagent code.

> **Tools:** the gateway aggregates 26 tools from 4 in-cluster MCP servers. One agent's key sees 10 of the 124 tools its tool server offers; a call to a hidden tool is refused.
>
> **Agents:** two kagent agents, on two models and two tool servers, each with its own LiteLLM key. The cluster agent completed 7 of 7 questions through the gateway; 5 answers were fully correct, 1 was incomplete and 1 had a wrong pod count. Total model spend was 0.022 USD. See [Results](#results).

![Architecture diagram: Postman or curl calls the LiteLLM proxy in the litellm namespace, which reaches kagent agents and MCP tool servers in the kagent namespace and LLM providers outside the EKS cluster](docs/diagrams/01-system-overview.jpg)

*The whole system: one LiteLLM gateway in front of the providers, the MCP tool servers and the two kagent agents.*

## Contents

- [What this builds](#what-this-builds)
- [Architecture](#architecture)
- [Method](#method)
- [Results](#results)
- [Findings](#findings)
- [Limitations](#limitations)
- [Versions](#versions)
- [Repository layout](#repository-layout)
- [Reproducing](#reproducing)

## What this builds

- **LiteLLM** is an open-source proxy that exposes many LLM providers through one OpenAI-compatible API. It also acts as an MCP gateway (`/mcp/`) and an A2A agent gateway (`/a2a/`), with virtual keys, budgets and spend logs across all three.
- **kagent** is a Kubernetes-native agent framework. An agent is an `Agent` custom resource: a system prompt, a model reference and a list of tools. The controller turns it into a Deployment and exposes it over the A2A protocol.
- **kmcp** is a controller and CLI for running MCP servers on Kubernetes. An `MCPServer` resource becomes a Deployment and a Service. A server that only speaks stdio is served over HTTP by an agentgateway process placed in the same container.

Longer introductions to each are in the [article](docs/article.md).

## Architecture

- **Cluster:** Amazon EKS 1.34 in `ap-south-1`, two availability zones, one NAT gateway, 2 × `t3.xlarge` managed nodes (4 vCPU, 16 GiB each) in private subnets, Amazon Linux 2023.
- **Add-ons:** VPC CNI, CoreDNS, kube-proxy, metrics-server, EKS Pod Identity agent, EBS CSI driver. A `gp3` StorageClass is the default.
- **Namespace `litellm`:** the LiteLLM proxy (1 replica) and its bundled PostgreSQL 16.2 on an 8 GiB volume.
- **Namespace `kagent`:** the kagent controller and UI, kagent's PostgreSQL 18.3, the kmcp controller, the `kagent-tools` and `querydoc` MCP servers, one kmcp-managed MCP server (`everything`), and two agent pods (`cluster-agent`, `everything-agent`).
- **Exposure:** every Service is `ClusterIP`. The gateway is reached with `kubectl port-forward`. Nothing is exposed to the internet.
- **Secrets:** the LiteLLM master key, salt key and Postgres passwords are Kubernetes Secrets. Each agent's LiteLLM virtual key is in a Secret. Provider API keys are not in any Secret: they are sent in `POST /model/new` and stored in Postgres, encrypted with the salt key.

## Method

**How the three are wired.** kagent is not given a provider or a direct route to its own tools. Both go through the gateway.

| Hop | Configured in | Value |
|---|---|---|
| Agent → model | kagent `ModelConfig` (`provider: OpenAI`, `openAI.baseUrl`) | `http://litellm.litellm.svc.cluster.local:4000/v1` |
| Agent → tools | kagent `RemoteMCPServer` with an `x-litellm-api-key` header | `http://litellm.litellm.svc.cluster.local:4000/mcp/` |
| Client → agent | LiteLLM `POST /v1/agents` | upstream `http://kagent-controller.kagent.svc.cluster.local:8083/api/a2a/kagent/<agent>/` |

**The two agents.**

![Comparison of the two agents by virtual key, ModelConfig, RemoteMCPServer and tools, all pointing at the LiteLLM gateway](docs/diagrams/05-two-agents-side-by-side.jpg)

*Each agent is a virtual key, a ModelConfig, a RemoteMCPServer and a tool list. The gateway URL is the same for both.*

| | `cluster-agent` | `everything-agent` |
|---|---|---|
| Purpose | Answers questions about the cluster, read-only | Demo of a kmcp-run MCP server |
| kagent `ModelConfig` | `deepseek-v4-1-flash` | `grok-4-7` |
| LiteLLM model | `openrouter/deepseek/deepseek-v4.1-flash` | `openrouter/x-ai/grok-4.7` |
| Tools | 10 `kagent_tools-*` (Kubernetes, Helm) | 4 `kmcp_everything-*` (echo, sum, ...) |
| LiteLLM key alias | `kagent` | `kagent-everything-agent` |
| Key limits | 10 USD, any model, MCP server `kagent_tools` | 5 USD, model `grok-4.7`, MCP server `kmcp_everything` |

**What was registered in the gateway, all by REST.**

| Kind | Call | Entries |
|---|---|---|
| MCP servers | `POST /v1/mcp/server` | `kagent_tools`, `kagent_querydoc`, `kagent_agents`, `kmcp_everything` |
| Agents | `POST /v1/agents` | `cluster_agent`, `everything_agent` |
| Virtual keys | `POST /key/generate`, `POST /key/update` | `kagent`, `kagent-everything-agent` |
| Models | `POST /model/new` | 14 deployments (OpenAI, Anthropic, OpenRouter, Voyage); two are used by the agents |

**Tool filtering.** `kagent_tools` is registered with `allowed_tools` set to 10 read-only tools. The other three servers are registered without a filter.

**Workload.** Seven questions to `cluster-agent` ([scripts/questions.txt](scripts/questions.txt)) and three to `everything-agent`, each sent once as an A2A `message/send` to the gateway. Each answer from `cluster-agent` was compared with `kubectl` and `helm` output taken right after the run.

**What was recorded.** Each REST response is saved under [results/raw/](results/raw/), each agent answer under [results/answers/](results/answers/), and spend per key under [results/summary/](results/summary/). Kubernetes state is quoted in the [setup guide](docs/setup-guide.md) at the step where it was observed.

## Results

Measured on 2026-10-05 against the cluster described above.

| Measurement | Value | Source |
|---|---|---|
| Tools offered by `kagent-tools` upstream | 124 | `RemoteMCPServer/kagent-tool-server` `status.discoveredTools` |
| Tools offered by the gateway for `kagent_tools` | 10 | [mcp-jsonrpc-tools-list.json](results/raw/mcp-jsonrpc-tools-list.json) |
| Tools at the aggregated endpoint, master key | 26 (10 + 1 + 2 + 13) | [mcp-jsonrpc-tools-list.json](results/raw/mcp-jsonrpc-tools-list.json) |
| Tools at the aggregated endpoint, kagent key | 10 | setup guide, step 10.4 |
| Tools kagent discovered through the gateway | 10 | `RemoteMCPServer/litellm-mcp-gateway` `status.discoveredTools` |
| `tools/call k8s_get_resources` (nodes) through the gateway | returned both nodes | [mcp-call-get-nodes.json](results/raw/mcp-call-get-nodes.json) |
| `tools/call k8s_delete_resource` through the gateway | refused, `isError: true` | [mcp-call-hidden-tool.json](results/raw/mcp-call-hidden-tool.json) |
| `tools/call echo` on the kmcp server | `Echo: hello from kmcp via LiteLLM` | [mcp-call-kmcp-echo.json](results/raw/mcp-call-kmcp-echo.json) |
| MCP server health | 4 of 4 `healthy` | [mcp-health.json](results/raw/mcp-health.json) |
| A2A `message/send` to the agent, before a model was registered | `TASK_STATE_FAILED`, HTTP 400 from `/chat/completions` | [agent-send-no-model.json](results/raw/agent-send-no-model.json) |

**Agents, through the gateway**

| Measurement | Value | Source |
|---|---|---|
| `cluster-agent`: tasks completed | 7 of 7, 3 s to 8 s each (whole seconds, one run) | [results/answers/](results/answers/) |
| `cluster-agent`: answers fully correct | 5 of 7 | setup guide, step 19 |
| `cluster-agent`: incomplete answer | 1 (instance type confirmed for one node of two) | `q01.txt` |
| `cluster-agent`: wrong answer | 1 (15 pods reported in `kube-system`, 14 existed) | `q02.txt` |
| `cluster-agent`: delete request | refused, "my tools are read-only" | `q07.txt` |
| `everything-agent`: tasks completed | 3 of 3; sum and echo by tool call, the cluster question declined | setup guide, step 18.4 |
| `everything-agent` key asking for `deepseek-v4.1-flash` | HTTP 403 | [key-model-refused.json](results/raw/key-model-refused.json) |

![Diagram of four MCP servers registered in LiteLLM and three callers: the admin sees 26 tools, cluster-agent 10 and everything-agent 13](docs/diagrams/04-tool-filtering.jpg)

*The tool counts from the table above, by caller.*

**Spend per key** ([spend-by-key.txt](results/summary/spend-by-key.txt))

| Key | Model calls | Model spend (USD) | Tokens | MCP tool calls | MCP `list_tools` calls |
|---|---|---|---|---|---|
| `kagent` | 24 (`deepseek-v4.1-flash`) | 0.01139 | 69,758 | 18 | 234 |
| `kagent-everything-agent` | 5 (`grok-4.7`) | 0.01078 | 10,198 | 2 | 5 |

## Findings

**The gateway filter is enforced on the call, not only on the listing.** `k8s_delete_resource` is absent from `tools/list`, and calling it by its full name with the master key returns `Tool k8s_delete_resource is not allowed for server kagent_tools`. A client that already knows a tool's name cannot bypass the filter.

**An agent can be restricted without changing the agent.** `cluster-agent` reaches tools only through `litellm-mcp-gateway`. kagent discovered 10 tools there, while its own tool server offers 124, including `shell` and `k8s_execute_command`. The restriction is one field on the gateway registration and one on the key.

**kagent needs nothing LiteLLM-specific.** A `ModelConfig` with `provider: OpenAI` and a `baseUrl` is enough for the model path, and a `RemoteMCPServer` with one header is enough for the tool path. The failed first invocation shows the model path is live: LiteLLM, not a provider, returned the 400.

**A second agent is three small resources and one key.** `everything-agent` needed a virtual key, a `ModelConfig` (same shape as the first, different `model`), and a `RemoteMCPServer` with the same gateway URL and a different key. The same URL returned 10 tools to one key and 13 to the other.

**The agent's answers were mostly right, and one was wrong.** Of seven answers, five matched the cluster. One reported 15 pods in `kube-system` where 14 existed, and contradicted the agent's own later answer. The tool returned the right data; the model miscounted it. The gateway governs what an agent may call, not whether the model reads the result correctly.

**Per-agent spend did not appear on the agent records.** `GET /v1/agents` showed `spend: 0.0` for both agents after the runs. Cost landed on the virtual keys (0.01139 USD and 0.01078 USD). One key per agent is what made per-agent cost visible here.

**Tool discovery is chatty.** The `kagent` key logged 234 `list_tools` calls in about four hours, against 18 real tool calls. In LiteLLM's log, consecutive `list_tools` rows for one key are 63 to 64 seconds apart.

**kmcp ships no MCP servers.** Its Helm chart installs a controller, RBAC and a metrics Service. The MCP servers that arrive with a kagent install come from kagent's chart: `kagent-tools` (124 tools), `querydoc` (1) and the controller's own endpoint (`list_agents`, `invoke_agent`). kmcp's contribution is running a server you describe: one `MCPServer` resource with `cmd: npx` produced a Deployment, Service, ConfigMap and ServiceAccount with no image build.

**"Latest" was the wrong version of kagent to build on.** The first checkout, `v1.0.0-alpha4`, has no `Agent` CRD and requires a separate runtime (Substrate) before any agent runs. `v1.0.0-alpha5`, two days newer, renames the CRD group. This build uses v0.9.10.

**Three chart defaults would have gone wrong silently.**

- The LiteLLM chart's default image tag is `v1.85.1`; the source is at 1.104.0.
- The LiteLLM chart never sets `LITELLM_SALT_KEY`; without it the master key encrypts stored provider keys.
- EKS's `gp2` StorageClass is not the default, so both Postgres volume claims would have stayed `Pending`.

## Limitations

- **One cluster, one run.** Every result is from a single install on one day. Each question was asked once, so the 5-of-7 figure says nothing about how often the agent is right in general.
- **Seven hand-written questions are not an evaluation.** They show the path works and where it failed once. Durations are whole seconds from one request each.
- **One answer detail was not checked.** The agent mentioned an earlier liveness-probe warning on the LiteLLM pod; that was not verified.
- **Model registration is not reproduced as commands.** The 14 models were registered by hand through the Postman collection. The guide shows the request shape and the resulting state.
- **Not a production setup.** One LiteLLM replica, single-node Postgres instances with no backup, no ingress, no TLS inside the cluster, and kagent's controller in its default `unsecure` auth mode.
- **The kagent A2A endpoint is not locked down.** Any pod in the cluster can call the kagent controller directly and skip the gateway. A NetworkPolicy would be needed to make the gateway the only path. None is applied.
- **The agent pod's own permissions were not reviewed.** The gateway limits which tools the agent can call. What the `kagent-tools` service account may do in the Kubernetes API is set by kagent's chart and was left at its default.
- **`cluster.yaml` was not run as a single command.** The control plane existed before this record started; the node group and add-ons were added to it.
- **The Postman collection was not run in Postman.** Its requests mirror the `curl` calls that were run.
- **Pre-1.0 software.** kagent 0.9.10 and kmcp 0.3.0 are pre-1.0, and kagent's 1.0 alphas replace the resource model used here.
- **Not compared.** No other gateway (for example agentgateway on its own) and no other agent runtime was tried.

## Versions

| Component | Version |
|---|---|
| Amazon EKS | 1.34 (platform `eks.34`), nodes `v1.34.11-eks-3b4a6ca` |
| Node OS | Amazon Linux 2023.12.20260928, containerd 2.2.7 |
| `aws-ebs-csi-driver` add-on | v1.66.0-eksbuild.1 |
| `eks-pod-identity-agent` add-on | v1.3.10-eksbuild.3 |
| LiteLLM | image `ghcr.io/berriai/litellm:v1.104.0`, chart `litellm-helm` 1.1.3 (source commit `74cad08997`) |
| LiteLLM PostgreSQL | `bitnamilegacy/postgresql:16.2.0-debian-12-r6` (subchart 14.3.1) |
| kagent | 0.9.10 (charts `kagent-crds` and `kagent`, source tag `v0.9.10`) |
| kagent-tools | 0.2.1 |
| querydoc | `ghcr.io/kagent-dev/doc2vec/mcp:1.1.14` |
| kagent PostgreSQL | `postgres:18.3-alpine` |
| kmcp | 0.3.0 (bundled by the kagent chart) |
| agentgateway (kmcp transport adapter) | 0.9.0-musl |
| eksctl / kubectl / helm / aws-cli | 0.230.0-dev / v1.35.0 / v4.2.4 / 2.37.4 |

## Repository layout

```
README.md
.env.example                      shape of the four internal secrets
docs/setup-guide.md               every command, in order, with output, errors and teardown
docs/article.md                   Medium article draft
docs/linkedin-post.md             short post
docs/diagrams/prompts.md          image prompts for the five diagrams
docs/screenshots/                 captures from the live system
infra/eks/cluster.yaml            eksctl ClusterConfig
infra/eks/storageclass-gp3.yaml   default StorageClass on the EBS CSI driver
infra/litellm/values.yaml         LiteLLM Helm values
infra/kagent/values.yaml          kagent Helm values (model through LiteLLM)
infra/kagent/litellm-mcp-gateway.yaml   RemoteMCPServer pointing at the LiteLLM MCP endpoint
infra/kagent/cluster-agent.yaml   the first Agent (Kubernetes questions, deepseek-v4.1-flash)
infra/kagent/modelconfig-deepseek.yaml  ModelConfig for deepseek-v4.1-flash through LiteLLM
infra/kagent/modelconfig-grok.yaml      ModelConfig for grok-4.7 through LiteLLM
infra/kagent/everything-agent.yaml      the second Agent and its RemoteMCPServer
infra/kmcp/everything-mcpserver.yaml    an MCPServer run by kmcp
postman/                          Postman collection for the gateway
scripts/ask-agent.sh              sends scripts/questions.txt to the agent through the gateway
results/raw/                      raw REST responses quoted in the documents
results/answers/                  the cluster agent's answers, raw JSON and text
results/summary/                  spend per virtual key
```

`repos/` (the three upstream checkouts used as the source of truth), `.env` and `.kube/` are gitignored.

## Reproducing

Start at [docs/setup-guide.md](docs/setup-guide.md). You need an AWS account with 8 spare on-demand vCPUs in the region, and one LLM provider API key for the last steps.

Billed while it exists: the EKS control plane, 2 × `t3.xlarge`, one NAT gateway, 9 GiB of gp3 volumes. The hourly total was not calculated; price it for your region with the AWS Pricing Calculator. Teardown is the last section of the setup guide.

## License

`TODO`: no LICENSE file has been added yet.
