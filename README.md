# claude-template

Claude Code プロジェクト設定のテンプレート集。新規プロジェクトに `.claude/` をコピーして使う。

`/init-project` コマンドにより、プロジェクトの言語・フレームワークを自動検出し、[everything-claude-code](https://github.com/affaan-m/everything-claude-code) から適切な rules / skills / agents を選んでダウンロードする。

## ディレクトリ構造

```
.claude/
├── settings.json               # フック設定（相対パス使用、そのままコピー可）
├── commands/
│   ├── init-project.md         # /init-project: プロジェクト分析 → ecc から rules/skills/agents 取得
│   ├── push.md                 # /push: レビュー→コミット→プッシュ→PR作成
│   ├── create-task.md          # /create-task <ITEM-ID>: open_items.md → GitHub Issue
│   ├── assign.md               # /assign <ITEM-ID> <person>: Issue割当＋タスクブランチ作成
│   └── task-status.md          # /task-status <ITEM-ID> <status>: Issue ステータス更新
├── skills/
│   └── cursor-migration/
│       └── SKILL.md            # /cursor-migration: Cursor → Claude Code 移行手順
└── hooks/
    ├── doc-impact.sh           # PostToolUse: Python編集時にdoc-tracerで影響ドキュメントを表示
    └── auto-register-issues.py # PostToolUse: open_items.md 保存時にGitHub Issueを自動登録

.mcp.json.example               # MCPサーバー設定テンプレート（コピーして .mcp.json に）
```

`/init-project` 実行後に追加される（プロジェクトごとに異なる）:
```
.claude/
├── rules/
│   ├── common/   # 共通ルール（常にダウンロード）
│   └── python/   # 言語別ルール（例）
├── agents/       # サブエージェント定義
│   ├── architect.md
│   ├── code-reviewer.md
│   └── ...
└── skills/
    ├── python-patterns/
    ├── api-design/
    └── ...
```

## セットアップ手順

### 0. テンプレートを取得（初回のみ）

```bash
git clone --depth 1 https://github.com/shotaseike/claude-template ~/claude-template
```

更新時:
```bash
git -C ~/claude-template pull
```

### 1. 新規プロジェクトにコピー

プロジェクトのルートで実行:

```bash
bash ~/claude-template/setup.sh
```

対話式で以下を設定:
- GitHub ユーザー名 / Projects 番号 → `planning/github.md` を生成
- GCP MCP を使う場合 → `.mcp.json` を生成

### 2. Claude Code を起動して /init-project を実行

```
/init-project
```

Claude がプロジェクトを分析して言語・フレームワークを検出し、必要なコンポーネントを [everything-claude-code](https://github.com/affaan-m/everything-claude-code) からダウンロードする。

ダウンロードされる例（Python + FastAPI の場合）:
- `rules/common/`, `rules/python/`
- `skills/python-patterns/`, `skills/python-testing/`, `skills/api-design/`, `skills/backend-patterns/`, `skills/tdd-workflow/`, `skills/deployment-patterns/`, `skills/security-review/`
- `agents/architect.md`, `agents/planner.md`, `agents/code-reviewer.md`, `agents/security-reviewer.md`, `agents/python-reviewer.md`

### 3. planning/github.md を作成（setup.sh で自動生成）

`auto-register-issues.py` と各コマンドがプロジェクト番号・オーナーを自動検出するために必要。

```markdown
# GitHub Projects Configuration

Project number: 2
Owner: your-github-username
```

### 3. .mcp.json をカスタマイズ（GCPプロジェクトを使う場合）

`.mcp.json` の `YOUR_GCP_PROJECT_ID` と `YOUR_SERVICE_NAME` を実際の値に変更。

### 4. GitHub Labels を作成

`auto-register-issues.py` と `create-task.md` が使う Labels:

```bash
gh label create "code-fix"   --color "d73a4a" --repo OWNER/REPO
gh label create "doc-update" --color "e4e669" --repo OWNER/REPO
gh label create "monitor"    --color "0075ca" --repo OWNER/REPO
```

## コンポーネント詳細

### /init-project コマンド

プロジェクトの言語・フレームワーク・DBを自動検出し、[everything-claude-code](https://github.com/affaan-m/everything-claude-code) から最適なコンポーネントをダウンロードする。

| 検出対象 | 参照ファイル |
|----------|-------------|
| TypeScript/JS | `package.json` |
| Python | `requirements.txt` / `pyproject.toml` |
| Go | `go.mod` |
| Rust | `Cargo.toml` |
| Java/Kotlin | `pom.xml` / `build.gradle` |

言語別マッピング（一部）:

| 言語/FW | Rules | Skills | Agents |
|---------|-------|--------|--------|
| Python + Django | `python/` | `django-patterns/`, `django-security/`, `django-tdd/` | `python-reviewer` |
| Python + FastAPI | `python/` | `api-design/`, `backend-patterns/`, `python-patterns/` | `python-reviewer` |
| TypeScript + React | `typescript/` | `frontend-patterns/`, `e2e-testing/` | — |
| Go | `golang/` | `golang-patterns/`, `golang-testing/` | `go-reviewer`, `go-build-resolver` |
| Spring Boot | — | `springboot-patterns/`, `springboot-security/`, `springboot-tdd/` | — |

常にインストール: `rules/common/`, `tdd-workflow/`, `deployment-patterns/`, `security-review/`, `architect`, `planner`, `code-reviewer`, `security-reviewer`, `doc-updater`

### コマンド (`/push`, `/create-task`, `/assign`, `/task-status`)

GitHub Issues + Projects を使ったタスク管理ワークフロー。
**リポジトリは `gh repo view` で自動検出**、プロジェクト番号は `planning/github.md` から読み込む。
プロジェクト固有の設定を一切ハードコードしていないので、そのまま使える。

タスクブランチ命名規則: `task/<ITEM-ID>-<person>`（例: `task/DOC-1-seike`）

### フック

#### doc-impact.sh
Python ファイル編集時に `doc-tracer impact` を実行し、影響するドキュメントを表示。
`doc-tracer` がインストールされ `tracer.db` が存在する場合のみ動作（未インストールなら無害にスキップ）。

```bash
pip install doc-tracer
doc-tracer scan .   # プロジェクトルートで実行してtracer.dbを生成
```

#### auto-register-issues.py
`planning/open_items.md` を Write するたびに実行。未登録の `[ITEM-ID]` エントリを GitHub Issue として自動作成し、Project に追加。
- リポジトリ: `gh repo view` で自動検出
- プロジェクト番号: `planning/github.md` から読み込み

### cursor-migration スキル
Cursor AI IDE から Claude Code への移行手順を自動実行するスキル。
`.cursor/mcp.json` → `.mcp.json`、`.cursorrules` → `CLAUDE.md` などの変換を行う。

## open_items.md フォーマット

`auto-register-issues.py` と `/create-task` が期待するフォーマット:

```markdown
## 🔴 要対処（コード・設定変更が必要）

### [CODE-1] タイトル

説明と対処方法...

---

## 🟡 要更新（ドキュメント整備が必要）

### [DOC-1] タイトル

...

---

## ✅ 解決済み

### [OLD-1] ...
```

セクション絵文字 → GitHub Label のマッピング:
- 🔴 → `code-fix`
- 🟡 → `doc-update`
- 🔵 → `monitor`
- ✅ → 登録対象外（解決済み）
