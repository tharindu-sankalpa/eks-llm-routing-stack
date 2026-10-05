# Diagram prompts

Image prompts for the five diagrams used in the README, setup guide and article. Each is generated with an image model and saved in this folder under the file name given. The prompts ask for no title inside the image: the caption in the document does that job. The prompts describe the final state of the build: two agents, two models, two virtual keys.

Colours and shapes are the same across all five:

| Component | Shape | Colour |
|---|---|---|
| LiteLLM gateway | Rounded rectangle | Teal #00695c |
| kagent and kmcp components, cluster boundary | Rounded rectangle / large boundary box | Sky blue #0288d1 |
| kagent agents | Rectangle with thin left accent bar | Sky blue #0288d1 |
| MCP tool servers | Rounded rectangle | Amber #f57f17 |
| LLM provider | Cloud with spark icon | Deep purple #6a1b9a |
| PostgreSQL | Tall cylinder | Forest green #2d7d32 |
| Virtual key | Small key icon | Teal #00695c |
| Client | Person silhouette | Dark grey |

After generating, check each image against the numbers in its prompt. Every number below comes from the live system: 124, 26, 10, 13, 14 models, 2 nodes, the budgets and the versions.

---

## 01-system-overview.jpg

Where it is used: README, setup guide opening, article opening.

```
A clean, flat-design software architecture diagram on a pure white background, landscape orientation.
No title or heading text anywhere in the image; the diagram starts at the top edge.
Overall visual style: flat minimalist corporate vector art, crisp sans-serif font (Inter), no shadows, no gradients, no textures.

SPATIAL LAYOUT: Three vertical zones. Left zone, 13% of the width: the client. Center zone, 67% of the width: one large rounded-corner boundary box with a thin sky blue (#0288d1) outline and a medium header label at its top-left reading "Amazon EKS 1.34 cluster: llm-routing-lab (2 x t3.xlarge, ap-south-1)". Right zone, 20% of the width: the external provider.

Inside the cluster boundary box there are two side-by-side inner boxes with thin light grey outlines. The left inner box takes 38% of the cluster width and has a small header label "namespace: litellm". The right inner box takes 62% of the cluster width and has a small header label "namespace: kagent".

ELEMENTS:
Left zone: a dark grey person silhouette icon, vertically centered, with a label directly beneath reading "Postman / curl" and a small 8pt caption beneath that reading "kubectl port-forward :4000".

Inside "namespace: litellm": at the top, a large teal (#00695c) rounded rectangle labeled in white bold text "LiteLLM proxy v1.104.0". Inside that rectangle, three small white-outlined pills stacked vertically, labeled "/v1/chat/completions", "/mcp/", "/a2a/". To the right of the pills, still inside the teal rectangle, three short lines of small white text: "14 models", "4 MCP servers", "2 agents". Below the teal rectangle, a forest green (#2d7d32) tall flat-top cylinder with the label beneath it "PostgreSQL 16" and a small 8pt caption "models, encrypted provider keys, MCP servers, agents, keys, spend".

Inside "namespace: kagent", arranged in three rows.
Top row, left to right: two sky blue (#0288d1) rounded rectangles of equal size labeled "kagent controller 0.9.10" and "kmcp controller 0.3.0", and at the far right a small forest green cylinder labeled "PostgreSQL 18" with an 8pt caption "kagent state".
Middle row, left to right: two sky blue rectangles of equal size, each with a thin darker left accent bar. The first is labeled "cluster-agent" with an 8pt caption "model: deepseek-v4.1-flash". The second is labeled "everything-agent" with an 8pt caption "model: grok-4.7".
Bottom row, left to right: three amber (#f57f17) rounded rectangles of equal size labeled "kagent-tools" with caption "124 tools", "querydoc" with caption "1 tool", and "everything" with caption "MCPServer, run by kmcp".

Right zone: a deep purple (#6a1b9a) cloud shape with a spark icon inside, labeled beneath "LLM providers" with a small 8pt caption "OpenRouter, OpenAI, Anthropic".

CONNECTIONS:
A thick solid red-orange (#e64a19) arrow pointing right from the person icon to the teal LiteLLM rectangle, labeled "one URL, one key".
A medium solid red-orange arrow pointing right from the "/a2a/" pill to the "kagent controller 0.9.10" box, labeled "A2A message/send".
A thin solid red-orange arrow pointing down from "kagent controller 0.9.10" to the two agent rectangles, labeled "routes to agent".
A medium solid red-orange arrow pointing left from the two agent rectangles to the "/v1/chat/completions" pill, labeled "model calls".
A medium solid red-orange arrow pointing left from the two agent rectangles to the "/mcp/" pill, labeled "tool calls".
A medium dashed steel blue (#1976d2) arrow pointing right from the "/mcp/" pill to the "kagent-tools" box, labeled "10 allowed tools".
A thin dashed steel blue arrow pointing right from the "/mcp/" pill to the "everything" box, labeled "13 tools".
A thin solid red-orange arrow pointing down from "kmcp controller 0.3.0" to the "everything" box, labeled "creates pod".
A thick solid red-orange arrow pointing right from the "/v1/chat/completions" pill, leaving the cluster boundary, to the purple cloud, labeled "provider API".
A thin dashed steel blue arrow pointing down from the teal rectangle to the green cylinder below it, labeled "config and spend".

CALLOUT BOXES: A yellow (#fff9c4) box with a thin border and dark text at the bottom-left of the image reading "Provider API keys are sent once in POST /model/new and stored encrypted in PostgreSQL. No provider key is in a Kubernetes Secret."

LEGEND: a small box in the bottom-right corner listing: teal square "LiteLLM gateway", sky blue square "kagent / kmcp", amber square "MCP tool server", purple square "LLM provider", green square "PostgreSQL", solid red-orange line "request", dashed steel blue line "forwarded by gateway".

Overall aesthetic: professional whitepaper.
```

---

## 02-agent-request-path.jpg

Where it is used: article, "The key concept" section.

```
A clean, flat-design sequence-style diagram on a pure white background, landscape orientation.
No title or heading text anywhere in the image; the diagram starts at the top edge.
Overall visual style: flat minimalist corporate vector art, crisp sans-serif font (Inter), no shadows, no gradients, no textures.

SPATIAL LAYOUT: Five equal-width columns left to right, each with a shape at the top and a thin light grey vertical line running down from it to the bottom of the frame.

ELEMENTS, column headers left to right:
Column 1: a dark grey person silhouette, label beneath "Client".
Column 2: a teal (#00695c) rounded rectangle, label in white "LiteLLM gateway".
Column 3: a sky blue (#0288d1) rounded rectangle, label in white "kagent: cluster-agent", with an 8pt caption beneath "via kagent controller :8083".
Column 4: an amber (#f57f17) rounded rectangle, label in white "kagent-tools (MCP)".
Column 5: a deep purple (#6a1b9a) cloud with a spark icon, label beneath "OpenRouter", with an 8pt caption "deepseek-v4.1-flash".

CONNECTIONS, as horizontal arrows between the vertical lines, ordered top to bottom, each with a numbered dark circle at its start:
1. A thick solid red-orange (#e64a19) arrow from column 1 to column 2, labeled "POST /a2a/cluster_agent".
2. A medium solid red-orange arrow from column 2 to column 3, labeled "A2A message/send".
3. A medium solid red-orange arrow from column 3 back to column 2, labeled "POST /v1/chat/completions".
4. A medium solid red-orange arrow from column 2 to column 5, labeled "provider API call".
5. A medium solid red-orange arrow from column 3 back to column 2, labeled "MCP tools/call".
6. A medium dashed steel blue (#1976d2) arrow from column 2 to column 4, labeled "k8s_get_resources".
7. A thick dashed steel blue arrow from column 2 to column 1, labeled "TASK_STATE_COMPLETED".

To the left of arrows 1, 3 and 5, on the column 2 line, a small teal shield icon of identical size, each with an 8pt caption: beside arrow 1 "caller's key", beside arrow 3 "key: kagent, budget 10 USD", beside arrow 5 "key: kagent, kagent_tools only".

Between arrows 5 and 7, a small light grey bracket on the right side spanning arrows 3 to 6, with an 8pt caption "repeats until the model has an answer".

CALLOUT BOXES: A yellow (#fff9c4) box with a thin border at the bottom-center reading "Arrows 1, 3 and 5 all arrive at the same gateway. Each is authenticated, logged and attributed to a key."

LEGEND: a small box in the bottom-right corner listing: solid red-orange line "request", dashed steel blue line "forwarded or returned", teal shield "gateway key check".

Overall aesthetic: clean technical reference map.
```

---

## 03-kmcp-stdio-to-http.jpg

Where it is used: article, kmcp building block; setup guide step 9.

```
A clean, flat-design software architecture diagram on a pure white background, landscape orientation.
No title or heading text anywhere in the image; the diagram starts at the top edge.
Overall visual style: flat minimalist corporate vector art, crisp sans-serif font (Inter), no shadows, no gradients, no textures.

SPATIAL LAYOUT: A left-to-right chain in three zones. Left zone, 25% width: the resource you write. Center zone, 50% width: what the controller creates. Right zone, 25% width: the callers.

ELEMENTS:
Left zone: a white document-shaped card with a thin sky blue (#0288d1) outline, header label "MCPServer: everything", and beneath it four lines of small monospaced text: "transportType: stdio", "cmd: npx", "args: -y @modelcontextprotocol/server-everything", "port: 3000".

Center zone, top: a sky blue (#0288d1) rounded rectangle labeled in white "kmcp controller 0.3.0".
Center zone, below it: a large rounded rectangle with a thin sky blue outline and a header label "Pod: everything". Inside the pod, left: a small light grey rounded rectangle labeled "init container: copy-binary" with an 8pt caption "agentgateway:0.9.0-musl". Inside the pod, right: a larger light grey rounded rectangle labeled "container: mcp-server" with an 8pt caption "node:24-alpine3.21". Inside the mcp-server container, two stacked boxes: on top a teal (#00695c) rounded rectangle labeled "agentgateway" with caption "listens on :3000/mcp", below it an amber (#f57f17) rounded rectangle labeled "npx server-everything" with caption "stdin / stdout".
Center zone, to the right of the pod: a sky blue rounded rectangle labeled "Service: everything" with caption "port 3000".

Right zone, top: a teal (#00695c) rounded rectangle labeled in white "LiteLLM gateway" with an 8pt caption beneath "registered as kmcp_everything".
Right zone, bottom: a sky blue rectangle with a thin darker left accent bar labeled "everything-agent" with an 8pt caption beneath "4 tools: echo, get-sum, ...".

CONNECTIONS:
A medium solid red-orange (#e64a19) arrow pointing right from the document card to "kmcp controller 0.3.0", labeled "kubectl apply".
A medium solid red-orange arrow pointing down from "kmcp controller 0.3.0" to the pod, labeled "creates Deployment".
A thin solid red-orange arrow pointing right from "init container: copy-binary" to the "agentgateway" box, labeled "copies binary".
A thin dashed steel blue (#1976d2) double-headed arrow between "agentgateway" and "npx server-everything", labeled "stdio".
A medium dashed steel blue arrow pointing left from "Service: everything" to the "agentgateway" box, labeled "HTTP :3000".
A medium dashed steel blue arrow pointing left from "LiteLLM gateway" to "Service: everything", labeled "streamable HTTP /mcp".
A medium solid red-orange arrow pointing up from "everything-agent" to "LiteLLM gateway", labeled "tool calls".

CALLOUT BOXES: A yellow (#fff9c4) box with a thin border at the bottom-left reading "No image was built. The controller also created a ConfigMap and a ServiceAccount named everything."

LEGEND: a small box in the bottom-right corner listing: sky blue square "kmcp / Kubernetes object", teal square "gateway", amber square "MCP server process", solid red-orange line "create or request", dashed steel blue line "MCP traffic".

Overall aesthetic: professional whitepaper.
```

---

## 04-tool-filtering.jpg

Where it is used: article, "The key concept" section; README findings.

Note for checking the image: the `everything` server shows 14 tools upstream and 13 at the gateway. That is what was observed (kagent found 14 directly, 13 through LiteLLM); the difference was not investigated. It is not a typo.

```
A clean, flat-design funnel-style diagram on a pure white background, landscape orientation.
No title or heading text anywhere in the image; the diagram starts at the top edge.
Overall visual style: flat minimalist corporate vector art, crisp sans-serif font (Inter), no shadows, no gradients, no textures.

SPATIAL LAYOUT: Three columns left to right. Left column 30% width: the four upstream MCP servers. Center column 30% width: the gateway. Right column 40% width: three callers stacked vertically.

ELEMENTS:
Left column, four amber (#f57f17) rounded rectangles stacked vertically. The top one is three times taller than the others and has a header label in white "kagent-tools: 124 tools", with nine small rows of dark text inside: "cilium_* 58", "k8s_* 22", "istio_* 13", "kubescape_* 10", "argo_* 8", "helm_* 6", "prometheus_* 5", "datetime_* 1", "shell 1". The other three are small and of equal size, labeled in white "querydoc: 1 tool", "kagent controller: 2 tools", "everything (kmcp): 14 tools".

Center column: one tall teal (#00695c) rounded rectangle with a header label in white "LiteLLM /mcp/". Inside it, four white inner panels stacked vertically, aligned with the four amber boxes. The top panel is labeled "kagent_tools" with a bold line "allowed_tools: 10 of 124" and ten small lines of monospaced text: "k8s_get_resources", "k8s_describe_resource", "k8s_get_events", "k8s_get_pod_logs", "k8s_get_resource_yaml", "k8s_get_available_api_resources", "k8s_get_cluster_configuration", "helm_list_releases", "helm_get_release", "datetime_get_current_time". The other three panels are labeled "kagent_querydoc: 1", "kagent_agents: 2", "kmcp_everything: 13".

Right column, three rows of equal height.
Row 1: a dark grey person silhouette labeled "admin (master key)" with a large bold number "26 tools" and an 8pt caption "10 + 1 + 2 + 13".
Row 2: a sky blue (#0288d1) rectangle with a thin darker left accent bar labeled in white "cluster-agent", a small teal key icon beside it with the caption "key: kagent, mcp_servers = [kagent_tools]", and a large bold number "10 tools".
Row 3: a sky blue rectangle with a thin darker left accent bar labeled in white "everything-agent", a small teal key icon beside it with the caption "key: kagent-everything-agent, mcp_servers = [kmcp_everything]", and a large bold number "13 tools".

CONNECTIONS:
Four thick solid red-orange (#e64a19) arrows pointing right, one from each amber rectangle to its matching white panel in the teal rectangle. The top arrow is labeled "registered with allowed_tools". The other three share one label "registered, no filter".
A medium dashed steel blue (#1976d2) arrow pointing right from the teal rectangle to the admin silhouette, labeled "all four servers".
A medium dashed steel blue arrow pointing right from the "kagent_tools" panel to "cluster-agent", labeled "key scope".
A medium dashed steel blue arrow pointing right from the "kmcp_everything: 13" panel to "everything-agent", labeled "key scope".

CALLOUT BOXES: A light red (#ffebee) box with dark text at the bottom-center reading "Calling k8s_delete_resource by name, even with the master key, returns: Tool k8s_delete_resource is not allowed for server kagent_tools."

LEGEND: a small box in the bottom-right corner listing: amber square "upstream MCP server", teal square "gateway filter", sky blue square "agent", teal key "virtual key", solid red-orange line "registration", dashed steel blue line "tools offered".

Overall aesthetic: clean technical reference map.
```

---

## 05-two-agents-side-by-side.jpg

Where it is used: article, "Models in kagent" section; setup guide step 18; README method.

```
A clean, flat-design comparison diagram on a pure white background, landscape orientation.
No title or heading text anywhere in the image; the diagram starts at the top edge.
Overall visual style: flat minimalist corporate vector art, crisp sans-serif font (Inter), no shadows, no gradients, no textures.

SPATIAL LAYOUT: Three vertical columns. A narrow left column, 16% width, holds four row labels. Two wide columns of equal width, 34% each, hold the two agents. A right column, 16% width, holds the gateway. Four horizontal rows of equal height run across the three left columns, separated by thin light grey lines.

ELEMENTS:
Column headers: above the second column, a sky blue (#0288d1) rectangle with a thin darker left accent bar labeled in white "cluster-agent" with an 8pt caption "read-only Kubernetes questions". Above the third column, an identical sky blue rectangle labeled in white "everything-agent" with an 8pt caption "demo of a kmcp-run MCP server".

Left column, four row labels in medium bold dark text, top to bottom: "1. Virtual key (LiteLLM)", "2. ModelConfig (kagent)", "3. RemoteMCPServer (kagent)", "4. Agent tools".

Row 1, second column: a small teal (#00695c) key icon with the text "kagent" and three small lines "budget 10 USD", "models: any", "MCP: kagent_tools". Row 1, third column: an identical teal key icon with the text "kagent-everything-agent" and three small lines "budget 5 USD", "models: grok-4.7", "MCP: kmcp_everything".

Row 2, second column: a white card with a thin sky blue outline, header "deepseek-v4-1-flash", and three lines of small monospaced text "provider: OpenAI", "model: deepseek-v4.1-flash", "baseUrl: litellm:4000/v1". Row 2, third column: an identical card with header "grok-4-7" and three lines "provider: OpenAI", "model: grok-4.7", "baseUrl: litellm:4000/v1".

Row 3, second column: a white card with a thin sky blue outline, header "litellm-mcp-gateway", and two lines of small monospaced text "url: litellm:4000/mcp/", "discovered: 10 tools". Row 3, third column: an identical card with header "litellm-mcp-everything" and two lines "url: litellm:4000/mcp/", "discovered: 13 tools".

Row 4, second column: an amber (#f57f17) rounded rectangle labeled in white "10 tools" with an 8pt caption beneath "kagent_tools-k8s_get_resources, ...". Row 4, third column: an identical amber rounded rectangle labeled in white "4 tools" with an 8pt caption beneath "kmcp_everything-echo, -get-sum, ...".

Right column: one tall teal (#00695c) rounded rectangle spanning all four rows, labeled vertically in white bold text "LiteLLM gateway", with three small white-outlined pills inside stacked top to bottom: "/key/generate", "/v1/chat/completions", "/mcp/".

CONNECTIONS:
A thin dashed steel blue (#1976d2) arrow pointing left from the "/key/generate" pill across row 1, labeled "issues both keys".
A medium solid red-orange (#e64a19) arrow pointing right from row 2 to the "/v1/chat/completions" pill, labeled "model calls".
A medium solid red-orange arrow pointing right from row 3 to the "/mcp/" pill, labeled "tool calls".
A thin solid red-orange arrow pointing down from each row 3 card to the amber rectangle below it in row 4, each labeled "toolNames".

CALLOUT BOXES: A yellow (#fff9c4) box with a thin border at the bottom-center reading "Same gateway URL in both ModelConfigs and both RemoteMCPServers. Only the key and the model name differ. provider is always OpenAI because kagent only talks to LiteLLM."

LEGEND: a small box in the bottom-right corner listing: sky blue square "kagent resource", teal square "LiteLLM gateway", teal key "virtual key", amber square "tools from an MCP server", solid red-orange line "request", dashed steel blue line "issued by gateway".

Overall aesthetic: clean technical reference map.
```
