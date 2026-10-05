I put one gateway in front of models, MCP tool servers and agents on Amazon EKS, using LiteLLM, kagent and kmcp, and made two agents use that gateway for both their model and their tools.

The setup is one EKS 1.34 cluster with two t3.xlarge nodes. LiteLLM is the gateway. kagent runs each agent as a Kubernetes resource. kmcp runs an MCP server from a single YAML resource. Everything in the gateway was registered with REST calls.

The headline number: kagent's built-in tool server offers 124 tools, including shell and delete operations. Through the gateway, the cluster agent sees 10. I registered the server with an allowed_tools list and scoped the agent's virtual key to it. The agent's definition did not change, and calling k8s_delete_resource by name is refused even with the admin key.

The surprise was version choice. The newest kagent code, v1.0.0-alpha4, has no Agent resource at all and needs a separate runtime before any agent starts. I built on v0.9.10. The README did not show the difference. The CRD directory did.

Then I gave each agent its own key. A second agent on a different model (grok-4.7) with the kmcp-run tool server took one key, one ModelConfig and one tool-source resource. The same gateway URL returned 10 tools to one key and 13 to the other.

Then I checked the answers. The cluster agent completed 7 of 7 questions. 5 were fully correct, 1 was incomplete, and 1 reported 15 pods where there were 14. A completed task is not a correct answer, and a gateway does not fix that.

Total model spend was 0.022 USD, logged per key next to every tool call.

Everything is reproducible. The repo has every command in order, the Helm values, the raw API responses, the agents' answers, a Postman collection and the errors I hit.

Repo: https://github.com/tharindu-sankalpa/eks-llm-routing-stack
Article: <ARTICLE_URL>

#LiteLLM #kagent #kmcp #MCP #A2A #Kubernetes #EKS #AIAgents #PlatformEngineering
