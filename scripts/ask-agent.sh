#!/usr/bin/env bash
# Sends each question in scripts/questions.txt to the kagent agent through the
# LiteLLM A2A gateway and writes the raw JSON-RPC response and the answer text
# to results/answers/.
#
# Needs: LITELLM (gateway URL), LITELLM_MASTER_KEY, and a model registered in
# LiteLLM under the name kagent's ModelConfig uses.
set -euo pipefail

LITELLM="${LITELLM:-http://127.0.0.1:4000}"
AGENT="${AGENT:-cluster_agent}"   # LiteLLM accepts the agent name or its id
OUT=results/answers
mkdir -p "$OUT"

n=0
while IFS= read -r question; do
  [ -z "$question" ] && continue
  n=$((n + 1))
  id=$(printf 'q%02d' "$n")
  body=$(jq -n --arg t "$question" --arg m "$id-$(date +%s)" \
    '{jsonrpc:"2.0", id:"1", method:"message/send",
      params:{message:{role:"user", kind:"message", messageId:$m,
                       parts:[{kind:"text", text:$t}]}}}')
  start=$(date +%s)
  curl -s -m 300 -X POST "$LITELLM/a2a/$AGENT" \
    -H "Authorization: Bearer $LITELLM_MASTER_KEY" \
    -H 'Content-Type: application/json' -d "$body" > "$OUT/$id.json"
  secs=$(( $(date +%s) - start ))
  state=$(jq -r '.result.task.status.state // .error.message // "no-task"' "$OUT/$id.json")
  {
    echo "Q: $question"
    echo "State: $state (${secs}s)"
    echo
    jq -r '[.result.task.artifacts[]?.parts[]?.text] | last // "(no text artifact)"' "$OUT/$id.json"
  } > "$OUT/$id.txt"
  echo "$id  $state  ${secs}s  $question"
done < scripts/questions.txt
