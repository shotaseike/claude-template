Analyze the current project and bootstrap Claude Code configuration by downloading relevant components from [everything-claude-code](https://github.com/affaan-m/everything-claude-code).

## Step 1: Analyze Project

Read these files if they exist (do not error if missing):
- `package.json` → TypeScript/JavaScript; read `dependencies` and `devDependencies`
- `requirements.txt`, `pyproject.toml`, `setup.py` → Python; read contents for framework names
- `go.mod` → Go
- `Cargo.toml` → Rust
- `pom.xml`, `build.gradle` → Java/Kotlin
- `README.md` → general project description

Detect and report:
- **Primary language** (typescript / python / golang / swift / java / rust / unknown)
- **Framework** (django / fastapi / flask / react / nextjs / vue / express / nestjs / springboot / unknown)
- **Project type** (frontend / backend-api / fullstack / cli / library / unknown)
- **Database** (postgres / mysql / sqlite / none / unknown) — check dependency names

Show the detected profile to the user and ask for confirmation before proceeding.

---

## Step 2: Determine Components to Download

Based on the detected profile, build a component plan. Use the following mapping:

### Always included

**Rules (`rules/common/`)** — all files:
`coding-style.md`, `git-workflow.md`, `testing.md`, `security.md`, `performance.md`, `patterns.md`, `hooks.md`, `agents.md`

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

---

## Step 3: Show Plan and Confirm

List all components that will be downloaded:
```
Rules:   rules/common/ (8 files), rules/python/ (N files)
Skills:  python-patterns/, python-testing/, api-design/, tdd-workflow/, deployment-patterns/, security-review/
Agents:  planner.md, architect.md, code-reviewer.md, security-reviewer.md, doc-updater.md, python-reviewer.md
```

Ask the user:
> 上記のコンポーネントをダウンロードしてよいですか？スキップまたは追加があれば教えてください。

---

## Step 4: Download Components

Set variables:
```
ECCI_API=https://api.github.com/repos/affaan-m/everything-claude-code/contents
ECCI_RAW=https://raw.githubusercontent.com/affaan-m/everything-claude-code/main
```

### Downloading a rules directory

For each rules directory (e.g., `rules/common`, `rules/python`):

```bash
dir="common"   # or "python", "golang", etc.
mkdir -p ".claude/rules/$dir"
curl -fsSL "$ECCI_API/rules/$dir" \
  | python3 -c "
import json, sys
for f in json.load(sys.stdin):
    if f['type'] == 'file':
        print(f['name'], f['download_url'])
" | while read -r name url; do
    curl -fsSL "$url" -o ".claude/rules/$dir/$name"
    echo "  downloaded: rules/$dir/$name"
  done
```

### Downloading a skill directory

For each skill (e.g., `python-patterns`):

```bash
skill="python-patterns"
mkdir -p ".claude/skills/$skill"
curl -fsSL "$ECCI_API/skills/$skill" \
  | python3 -c "
import json, sys
for f in json.load(sys.stdin):
    if f['type'] == 'file':
        print(f['name'], f['download_url'])
" | while read -r name url; do
    curl -fsSL "$url" -o ".claude/skills/$skill/$name"
    echo "  downloaded: skills/$skill/$name"
  done
```

### Downloading agent files

For each agent file (e.g., `architect.md`):

```bash
mkdir -p ".claude/agents"
curl -fsSL "$ECCI_RAW/agents/architect.md" -o ".claude/agents/architect.md"
echo "  downloaded: agents/architect.md"
```

Execute all downloads in sequence. Report each file as it is downloaded.

---

## Step 5: Generate CLAUDE.md (if not present)

If `CLAUDE.md` does not exist, create it with this template (fill in detected values):

```markdown
# CLAUDE.md

## Project Overview

[Detected language]: [Detected framework] project.

<!-- TODO: Add project description, purpose, and key features -->

## Environment Setup

<!-- TODO: Add required environment variables and setup steps -->

## Common Commands

<!-- TODO: Add build, test, run commands for this project -->

## Architecture

<!-- TODO: Describe key modules and data flow -->

## Claude Code Configuration

Installed from [everything-claude-code](https://github.com/affaan-m/everything-claude-code):

### Rules
- `.claude/rules/common/` — Universal coding standards
[list installed language rules]

### Skills
[list installed skills with one-line descriptions]

### Agents
[list installed agents]

## Communication Style

Always respond to the user in **Japanese**.
```

---

## Step 6: Report

Show a summary in Japanese:

```
✓ セットアップ完了

インストールされたコンポーネント:
  ルール: rules/common/ (N ファイル), rules/python/ (M ファイル)
  スキル: python-patterns/, python-testing/, api-design/, tdd-workflow/, deployment-patterns/, security-review/
  エージェント: planner, architect, code-reviewer, security-reviewer, doc-updater, python-reviewer

次のステップ:
  1. CLAUDE.md を編集してプロジェクト概要を追記
  2. /docs を実行して詳細を補完
```
