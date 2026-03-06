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
   - `skills/` (template skills like docs/) → overwrite with latest
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

## Step 3: Determine Components to Download

Based on the detected profile, build a component plan. Use the following mapping:

### Always included

**Rules (`rules/common/`)** — download only these specific files (do NOT download all files in the directory):
`coding-style.md`, `git-workflow.md`, `testing.md`, `security.md`, `performance.md`, `patterns.md`, `hooks.md`, `agents.md`

> NOTE: Skip any file not in the above list (e.g. `test.md` is a known duplicate of `coding-style.md` and must be excluded).

**Agents** — always:
`planner.md`, `architect.md`, `code-reviewer.md`, `security-reviewer.md`, `doc-updater.md`

**Skills** — always:
`tdd-workflow/`, `deployment-patterns/`, `security-review/`

### By language

| Language | Rules dir | Skills | Agents |
|----------|-----------|--------|--------|
| python | `rules/python/` | `python-patterns/`, `python-testing/` | `python-reviewer.md` |
| typescript | `rules/typescript/` | `coding-standards/` | — |
| golang | `rules/golang/` | `golang-patterns/`, `golang-testing/` | `go-reviewer.md`, `go-build-resolver.md` |
| swift | `rules/swift/` | `swiftui-patterns/`, `swift-concurrency-6-2/` | — |
| java | — | `java-coding-standards/` | — |

### By framework

| Framework | Additional skills |
|-----------|-------------------|
| django | `django-patterns/`, `django-security/`, `django-tdd/`, `django-verification/` |
| fastapi / flask | `api-design/`, `backend-patterns/` |
| react / nextjs / vue | `frontend-patterns/`, `e2e-testing/` |
| express / nestjs | `backend-patterns/`, `api-design/` |
| springboot | `springboot-patterns/`, `springboot-security/`, `springboot-tdd/` |

### By database

| Database | Additional skills |
|----------|-------------------|
| postgres | `postgres-patterns/`, `database-migrations/` |
| mysql / sqlite | `database-migrations/` |

Add `database-reviewer.md` to agents if any database is detected.

> IMPORTANT: Download ONLY the components listed above for the detected profile.
> Do NOT download all available agents or skills.

---

## Step 4: Show Plan and Confirm

List all components that will be downloaded:
```
Rules:   rules/common/ (8 files), rules/python/ (N files)
Skills:  python-patterns/, python-testing/, tdd-workflow/, deployment-patterns/, security-review/
Agents:  planner, architect, code-reviewer, security-reviewer, doc-updater, python-reviewer
```

Ask the user:
> 上記のコンポーネントをダウンロードしてよいですか？スキップまたは追加があれば教えてください。

---

## Step 5: Download Components

Use the same download patterns as `init-project.md` Step 4.

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
  スキル: python-patterns/, python-testing/, tdd-workflow/, deployment-patterns/, security-review/
  エージェント: planner, architect, code-reviewer, security-reviewer, doc-updater, python-reviewer

CLAUDE.md は保持されます。プロジェクト固有の設定が必要な場合は手動で編集してください。
```