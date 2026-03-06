Update the current project's Claude Code configuration by:
1. Re-detecting the project language and framework
2. Downloading the latest template components (commands, hooks, skills, settings) from the claude-template repository
3. Downloading the latest project-specific components (rules, skills, agents) from [everything-claude-code](https://github.com/affaan-m/everything-claude-code)

**Note:** This command re-analyzes the project and refreshes all components. Unlike `/init-project`, it does NOT regenerate `CLAUDE.md`. User-defined CLAUDE.md and project-specific customizations are preserved.

## Step 1: Analyze Project (same as `/init-project`)

Read these files if they exist (do not error if missing):
- `package.json` → TypeScript/JavaScript
- `requirements.txt`, `pyproject.toml`, `setup.py` → Python
- `go.mod` → Go
- `Cargo.toml` → Rust
- `pom.xml`, `build.gradle` → Java/Kotlin
- `README.md` → general project description

Detect and report:
- **Primary language** (typescript / python / golang / swift / java / rust / unknown)
- **Framework** (django / fastapi / flask / react / nextjs / vue / express / nestjs / springboot / unknown)
- **Project type** (frontend / backend-api / fullstack / cli / library / unknown)
- **Database** (postgres / mysql / sqlite / none / unknown)

Show the detected profile and ask for confirmation before proceeding.

---

## Step 2: Update Template Components

Download the latest template files from `shotaseike/claude-template`:
1. Clone/fetch the latest version of the template repository
2. Copy new/updated files to `.claude/`:
   - `commands/` → overwrite with latest
   - `hooks/` → overwrite with latest
   - `skills/` (template skills like docs/, cursor-migration/) → overwrite with latest
   - `settings.json` → merge with existing (preserve user hooks if added)

Show a summary of updated/new files:
```
テンプレート更新:
  新規コマンド: /new-command
  更新コマンド: /init-project, /update-claude-config
  新規スキル: new-skill/
  更新フック: doc-impact.sh
```

---

## Step 3-5: Determine & Download Project-Specific Components

Use the exact same logic as `/init-project` for:
1. Determining which components to download (rules/common, language rules, framework skills, database skills, agents)
2. Building the component plan
3. Downloading all rules, skills, and agents (overwriting existing files)

Use the same GitHub API queries and download patterns as documented in `/init-project` Steps 2-4.

---

## Step 6: Report

Show a comprehensive summary in Japanese:

```
✓ 設定の更新完了

テンプレート更新 (shotaseike/claude-template):
  コマンド: 6 個更新
  スキル: 2 個 (新規/更新)
  フック: 2 個更新
  設定: settings.json 更新

プロジェクト固有コンポーネント (everything-claude-code):
  ルール: rules/common/ (N ファイル), rules/python/ (M ファイル)
  スキル: python-patterns/, python-testing/, api-design/, tdd-workflow/, deployment-patterns/, security-review/
  エージェント: planner, architect, code-reviewer, security-reviewer, doc-updater, python-reviewer

CLAUDE.md は保持されます。プロジェクト固有の設定が必要な場合は手動で編集してください。
```