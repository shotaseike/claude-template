#!/usr/bin/env bash
# PostToolUse hook: run doc-tracer impact when a Python file is edited.
# Receives tool invocation JSON on stdin.

set -euo pipefail

INPUT=$(cat)

# Extract file_path from tool input (Edit or Write tool)
FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
tool_input = data.get('tool_input', {})
print(tool_input.get('file_path', ''))
" 2>/dev/null || echo "")

# Only proceed for Python files that exist
if [[ -z "$FILE_PATH" || "$FILE_PATH" != *.py || ! -f "$FILE_PATH" ]]; then
  exit 0
fi

# Requires tracer.db to exist (built by `doc-tracer scan .`)
if ! command -v doc-tracer &>/dev/null || [[ ! -f "tracer.db" ]]; then
  exit 0
fi

RESULT=$(doc-tracer impact "$FILE_PATH" 2>/dev/null || true)

if [[ -n "$RESULT" ]]; then
  echo "doc-tracer: $(basename "$FILE_PATH") を変更しました。影響するドキュメント:"
  echo "$RESULT"
fi
