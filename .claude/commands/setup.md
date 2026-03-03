Bootstrap Claude Code configuration for a new project from shotaseike/claude-template.

Downloads .claude/ structure from GitHub and sets up planning files.
Runs entirely within Claude Code — no shell installer needed.

**This command is intended as a global command: `~/.claude/commands/setup.md`**

## Steps

### Step 1: Download .claude/ template files

Run the following Bash commands to download the template:

```bash
BASE="https://raw.githubusercontent.com/shotaseike/claude-template/main"
mkdir -p .claude/commands .claude/hooks .claude/skills/cursor-migration

curl -fsSL "$BASE/.claude/settings.json"                         -o .claude/settings.json
curl -fsSL "$BASE/.claude/commands/setup.md"                     -o .claude/commands/setup.md
curl -fsSL "$BASE/.claude/commands/assign.md"                    -o .claude/commands/assign.md
curl -fsSL "$BASE/.claude/commands/create-task.md"               -o .claude/commands/create-task.md
curl -fsSL "$BASE/.claude/commands/init-project.md"              -o .claude/commands/init-project.md
curl -fsSL "$BASE/.claude/commands/push.md"                      -o .claude/commands/push.md
curl -fsSL "$BASE/.claude/commands/task-status.md"               -o .claude/commands/task-status.md
curl -fsSL "$BASE/.claude/hooks/auto-register-issues.py"         -o .claude/hooks/auto-register-issues.py
curl -fsSL "$BASE/.claude/hooks/doc-impact.sh"                   -o .claude/hooks/doc-impact.sh
curl -fsSL "$BASE/.claude/skills/cursor-migration/SKILL.md"      -o .claude/skills/cursor-migration/SKILL.md
chmod +x .claude/hooks/doc-impact.sh .claude/hooks/auto-register-issues.py
```

### Step 2: Create planning/github.md

Ask the user in Japanese:
- GitHub ユーザー名（Project Owner）
- GitHub Projects 番号（不明なら Enter でスキップ）

Create `planning/github.md`:

```markdown
# GitHub Projects Configuration

Owner: <入力値 or YOUR_GITHUB_USERNAME>
Project number: <入力値 or 1>

## Labels

Required labels for task management:
- `code-fix`   (red)    -- code/config changes needed
- `doc-update` (yellow) -- documentation updates needed
- `monitor`    (blue)   -- external API changes to watch

Create labels:
```bash
gh label create "code-fix"   --color "d73a4a" --description "Code or config change required"
gh label create "doc-update" --color "e4e669" --description "Documentation update needed"
gh label create "monitor"    --color "0075ca" --description "Monitor for external changes"
```
```

### Step 3: Optionally create .mcp.json

Ask the user in Japanese: GCP（BigQuery / Cloud Run）MCP を設定しますか？

If yes:
```bash
curl -fsSL "$BASE/.mcp.json.example" -o .mcp.json
```
Inform the user to replace `YOUR_GCP_PROJECT_ID` and `YOUR_SERVICE_NAME` in `.mcp.json`.

### Step 4: Continue with /init-project

Proceed immediately with the `/init-project` steps (detect language/framework, download from everything-claude-code, generate CLAUDE.md).

### Step 5: Report

Show a summary in Japanese of all installed files and next steps.
