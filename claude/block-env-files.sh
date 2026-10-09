#!/bin/bash
# Claude Code PreToolUse hook: block file tools on .env / .env.* in any directory,
# except .env.example. Works without jq (e.g. Git Bash on Windows).
# Exit code 2 blocks the tool call and shows stderr to Claude.
set -uo pipefail

input=$(cat)

extract_with_sed() {
  printf '%s' "$input" | sed -n -E 's/.*"(file_path|notebook_path|path)"[[:space:]]*:[[:space:]]*"([^"]*)".*/\2/p' | head -n 1
}

path=""
if command -v jq >/dev/null 2>&1; then
  path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.notebook_path // .tool_input.path // empty' 2>/dev/null) \
    || path=$(extract_with_sed)
else
  path=$(extract_with_sed)
fi
[[ -z "$path" ]] && exit 0

# Normalize Windows separators (JSON-escaped "\\" or plain "\") before taking the basename.
path=${path//\\\\//}
path=${path//\\//}
name=${path##*/}

[[ "$name" == ".env.example" ]] && exit 0

if [[ "$name" == ".env" || "$name" == .env.* ]]; then
  echo "Blocked by policy: $name may contain secrets (.env.example is allowed)." >&2
  exit 2
fi
exit 0
