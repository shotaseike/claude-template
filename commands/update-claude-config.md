Update the current project's Claude Code configuration by re-detecting the project language and framework, then downloading the latest components from [everything-claude-code](https://github.com/affaan-m/everything-claude-code) to overwrite the existing rules, skills, and agents.

**Note:** This command re-analyzes the project and refreshes all components. Unlike `/init-project`, it does NOT regenerate `CLAUDE.md`.

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

## Step 2-4: Determine & Download Components

Use the exact same logic as `/init-project` for:
1. Determining which components to download (rules/common, language rules, framework skills, database skills, agents)
2. Building the component plan
3. Downloading all rules, skills, and agents (overwriting existing files)

Use the same GitHub API queries and download patterns as documented in `/init-project` Steps 2-4.

---

## Step 5: Report

Show a summary in Japanese:

```
✓ 設定の更新完了

再ダウンロードされたコンポーネント:
  ルール: rules/common/ (N ファイル), rules/python/ (M ファイル)
  スキル: python-patterns/, python-testing/, api-design/, tdd-workflow/, deployment-patterns/, security-review/
  エージェント: planner, architect, code-reviewer, security-reviewer, doc-updater, python-reviewer

CLAUDE.md は保持されます。プロジェクト固有の設定が必要な場合は手動で編集してください。
```