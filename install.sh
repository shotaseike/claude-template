#!/bin/bash

# Exit on any error
set -e

# --- Prerequisite Checks ---
echo "Checking prerequisites..."

# Check for required commands
for cmd in gh python3 curl git; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "Error: Required command '$cmd' is not installed." >&2
    exit 1
  fi
done

# Check gh auth status
if ! gh auth status &> /dev/null; then
  echo "Error: Not logged into GitHub. Please run 'gh auth login' and try again." >&2
  exit 1
fi

# Check if inside a git repository and at the root
if ! git rev-parse --is-inside-work-tree &> /dev/null || [ "$(git rev-parse --show-toplevel)" != "$(pwd)" ]; then
    echo "Error: This script must be run from the root of a Git repository." >&2
    exit 1
fi

echo "All prerequisites met."

# --- Directory and File Setup ---
CLAUDE_DIR=".claude"
BASE_URL="https://raw.githubusercontent.com/shotaseike/claude-template/main"

echo "Setting up .claude directory structure..."
mkdir -p "$CLAUDE_DIR/commands"
mkdir -p "$CLAUDE_DIR/hooks"
mkdir -p "$CLAUDE_DIR/skills/cursor-migration"
mkdir -p "$CLAUDE_DIR/skills/docs"

# --- File Downloads ---
echo "Downloading files from claude-template repository..."

# settings.json
curl -sSL "$BASE_URL/settings.json" -o "$CLAUDE_DIR/settings.json"

# commands
curl -sSL "$BASE_URL/commands/assign.md" -o "$CLAUDE_DIR/commands/assign.md"
curl -sSL "$BASE_URL/commands/create-task.md" -o "$CLAUDE_DIR/commands/create-task.md"
curl -sSL "$BASE_URL/commands/init-project.md" -o "$CLAUDE_DIR/commands/init-project.md"
curl -sSL "$BASE_URL/commands/push.md" -o "$CLAUDE_DIR/commands/push.md"
curl -sSL "$BASE_URL/commands/task-status.md" -o "$CLAUDE_DIR/commands/task-status.md"
curl -sSL "$BASE_URL/commands/update-claude-config.md" -o "$CLAUDE_DIR/commands/update-claude-config.md"

# hooks (and give execute permission)
curl -sSL "$BASE_URL/hooks/auto-register-issues.py" -o "$CLAUDE_DIR/hooks/auto-register-issues.py"
chmod +x "$CLAUDE_DIR/hooks/auto-register-issues.py"
curl -sSL "$BASE_URL/hooks/doc-impact.sh" -o "$CLAUDE_DIR/hooks/doc-impact.sh"
chmod +x "$CLAUDE_DIR/hooks/doc-impact.sh"

# skills
curl -sSL "$BASE_URL/skills/cursor-migration/SKILL.md" -o "$CLAUDE_DIR/skills/cursor-migration/SKILL.md"
curl -sSL "$BASE_URL/skills/docs/SKILL.md" -o "$CLAUDE_DIR/skills/docs/SKILL.md"

echo "Files downloaded successfully."

# --- .gitignore Update ---
GITIGNORE_FILE=".gitignore"
echo "Updating .gitignore..."

if [ ! -f "$GITIGNORE_FILE" ]; then
    touch "$GITIGNORE_FILE"
fi

{
    echo ""
    echo "# Claude Code settings"
    grep -qxF ".mcp.json.backup" "$GITIGNORE_FILE" || echo ".mcp.json.backup"
    grep -qxF "!.mcp.json" "$GITIGNORE_FILE" || echo "!.mcp.json"
} >> "$GITIGNORE_FILE"

echo ".gitignore updated."

# --- Completion Message ---
echo ""
echo "✅ Claude Code のセットアップが完了しました。"
echo "次に、Claude Code を起動し、 '/init-project' を実行してプロジェクトを初期化してください。"
