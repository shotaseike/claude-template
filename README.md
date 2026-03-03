# claude-template

Claude Code プロジェクト設定のテンプレート集。新規プロジェクトに `.claude/` をコピーして使う。

## ディレクトリ構造

```
.claude/
├── settings.json               # フック設定（相対パス使用、そのままコピー可）
├── commands/
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

## セットアップ手順

### 1. ファイルをコピー

```bash
TARGET=/path/to/your/project

# .claude/ 全体をコピー
cp -r ~/.claude-template/.claude "$TARGET/"

# MCP設定（必要な場合）
cp ~/.claude-template/.mcp.json.example "$TARGET/.mcp.json"
```

### 2. planning/github.md を作成

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
