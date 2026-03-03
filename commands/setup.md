Bootstrap Claude Code configuration for a new project.

Copies .claude/ from the local template clone into the current project.
Runs entirely within Claude Code — no curl, no shell installer needed.

**This command is intended as a global command: `~/.claude/commands/setup.md`**

Prerequisite: `git clone https://github.com/shotaseike/claude-template ~/.claude`

## Steps

### Step 1: Copy .claude/ from local template

Check that `~/.claude/commands/init-project.md` exists. If not, tell the user to run:
```
git clone https://github.com/shotaseike/claude-template ~/.claude
```
and stop.

Otherwise, run:

```bash
SRC="${HOME}/.claude"
mkdir -p .claude/commands .claude/hooks .claude/skills/cursor-migration

cp "$SRC/settings.json"                        .claude/settings.json
cp "$SRC/commands/setup.md"                    .claude/commands/setup.md
cp "$SRC/commands/assign.md"                   .claude/commands/assign.md
cp "$SRC/commands/create-task.md"              .claude/commands/create-task.md
cp "$SRC/commands/init-project.md"             .claude/commands/init-project.md
cp "$SRC/commands/push.md"                     .claude/commands/push.md
cp "$SRC/commands/task-status.md"              .claude/commands/task-status.md
cp "$SRC/hooks/auto-register-issues.py"        .claude/hooks/auto-register-issues.py
cp "$SRC/hooks/doc-impact.sh"                  .claude/hooks/doc-impact.sh
cp "$SRC/skills/cursor-migration/SKILL.md"     .claude/skills/cursor-migration/SKILL.md
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
cp "${HOME}/.claude/.mcp.json.example" .mcp.json
```
Inform the user to replace `YOUR_GCP_PROJECT_ID` and `YOUR_SERVICE_NAME` in `.mcp.json`.

### Step 4: Continue with /init-project

Proceed immediately with the `/init-project` steps (detect language/framework, download from everything-claude-code, generate CLAUDE.md).

### Step 5: Report

Show a summary in Japanese of all installed files and next steps.
