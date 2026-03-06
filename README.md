# claude-template

Claude Code プロジェクト設定のテンプレート集。
このテンプレートを利用することで、プロジェクトに最適化されたClaude Codeの環境を簡単に構築できます。

`/init-project` コマンドにより、プロジェクトの言語・フレームワークを自動検出し、[everything-claude-code](https://github.com/affaan-m/everything-claude-code) から適切な rules / skills / agents を選んでダウンロードします。

## セットアップ手順

### 1. 初期セットアップ

以下のコマンドをプロジェクトのルートディレクトリで実行してください。
ワンライナーで `.claude` 環境の構築、`.gitignore` の設定が完了します。

**前提条件:**
- `git`, `gh`, `python3`, `curl` がインストール済み
- `gh auth login` で GitHub にログイン済み
- プロジェクトが Git リポジトリの状態（`git init` 済み）

**新規プロジェクトの場合の初期化:**
```bash
git init
git remote add origin https://github.com/YOUR_USER/YOUR_REPO.git
```

#### Linux / macOS / WSL
```bash
curl -sSL https://raw.githubusercontent.com/shotaseike/claude-template/main/install.sh | bash
```

#### Windows PowerShell
Windows PowerShell では `curl` が `Invoke-WebRequest` にエイリアスされるため、WSL または git bash で実行してください。

**WSL で実行:**
```bash
wsl bash -c "curl -sSL https://raw.githubusercontent.com/shotaseike/claude-template/main/install.sh | bash"
```

**git bash で実行:**
```bash
bash -c "curl -sSL https://raw.githubusercontent.com/shotaseike/claude-template/main/install.sh | bash"
```

### 2. プロジェクトの初期化

セットアップが完了したら、Claude Code を起動し、以下のコマンドを実行してください。
プロジェクトの言語・フレームワークを自動検出し、最適な rules / skills / agents をダウンロードします。

```
/init-project
```

このコマンドは以下を自動で実行します：
- **プロジェクト分析** - 言語・フレームワークを検出
- **コンポーネントダウンロード** - `everything-claude-code` から最適な rules/skills/agents をダウンロード
- **planning/ ディレクトリ作成** - タスク管理用の planning ディレクトリを作成
- **CLAUDE.md 生成** - プロジェクト設定テンプレートを作成

これで、あなたのプロジェクト用の Claude Code 環境の準備は完了です。

## 設定のアップデート

以下の2つのソースは随時更新されます：

1. **このテンプレートリポジトリ** (`shotaseike/claude-template`)
   - コマンド定義、スキル、フック、設定テンプレート

2. **everything-claude-code** (`affaan-m/everything-claude-code`)
   - プロジェクト言語・フレームワーク固有のルール、スキル、エージェント

以下のコマンドを実行することで、両方のソースから最新の設定を取得できます。

```
/update-claude-config
```

### 実行内容

このコマンドは以下の順序で更新を行います：

1. **プロジェクト分析** - 言語・フレームワークを再検出
2. **テンプレート更新** - このリポジトリの最新コマンド、スキル、フック、設定をダウンロード
3. **プロジェクト固有コンポーネント更新** - `everything-claude-code` から最新の rules / skills / agents をダウンロード

> **重要:** `CLAUDE.md` とプロジェクト固有の設定は保持されます。

## リポジトリ構造

### テンプレートリポジトリの構成

このリポジトリは以下のファイルで構成されています：

```
.
├── install.sh                      # インストールスクリプト
├── settings.json                   # デフォルト設定テンプレート
├── .mcp.json.example               # MCP設定の例
├── README.md                       # このファイル
├── COMPONENTS.md                   # コンポーネント詳細
├── commands/                       # コマンド定義テンプレート
│   ├── init-project.md
│   ├── update-claude-config.md
│   ├── push.md
│   ├── create-task.md
│   ├── assign.md
│   └── task-status.md
├── hooks/                          # フックスクリプト
│   ├── doc-impact.sh
│   └── auto-register-issues.py
└── skills/                         # スキルテンプレート
    ├── docs/
    │   └── SKILL.md
    └── cursor-migration/
        └── SKILL.md
```

### インストール後のプロジェクト構造

`install.sh` によって、新規プロジェクトのカレントディレクトリに以下の構造で `.claude` ディレクトリが作成されます：

```
.claude/
├── settings.json               # フック設定
├── commands/
│   ├── init-project.md         # /init-project: プロジェクトの初期化
│   ├── update-claude-config.md # /update-claude-config: 設定の更新
│   ├── push.md                 # /push: GitHubへのプッシュとPR作成
│   ├── create-task.md          # /create-task: GitHub Issueの作成
│   ├── assign.md               # /assign: Issueの担当者割り当て
│   └── task-status.md          # /task-status: Issueのステータス更新
├── skills/
│   ├── docs/
│   │   └── SKILL.md            # /docs: ドキュメントの保守・更新（doc-tracer統合）
│   └── cursor-migration/
│       └── SKILL.md            # /cursor-migration: Cursorからの移行支援
└── hooks/
    ├── doc-impact.sh           # Python編集時の影響ドキュメント表示
    └── auto-register-issues.py # open_items.md からのGitHub Issue自動登録
```

`/init-project` または `/update-claude-config` を実行すると、`.claude/` ディレクトリの下の `rules/`, `agents/`, `skills/` にプロジェクトに合わせたコンポーネントが追加されます。

## コンポーネント詳細

> ダウンロードされる **Rules / Skills / Agents** の詳細な説明と使い方は [COMPONENTS.md](COMPONENTS.md) をご覧ください。

### コマンド

| コマンド | 説明 |
|---------|------|
| `/init-project` | プロジェクトの言語・フレームワークを自動検出し、最適な rules/skills/agents をダウンロード |
| `/update-claude-config` | 既存の設定を最新版に更新（CLAUDE.md は保持） |
| `/docs` | ドキュメントをチェック・更新。frontmatter による影響範囲分析、孤立ドキュメントへの自動frontmatter付与 |
| `/push` | 変更をレビュー・コミット・プッシュ。タスクブランチの場合は PR 作成・Issue 自動クローズ |
| `/create-task` | `planning/open_items.md` から GitHub Issue を作成 |
| `/assign` | Issue を割り当てし、タスクブランチを作成 |
| `/task-status` | Issue のステータスを GitHub Projects で更新 |

### フック (`hooks/`)
- `doc-impact.sh`: Pythonファイル編集時に、関連するドキュメントを自動で検索・表示します。
- `auto-register-issues.py`: `planning/open_items.md` にタスクを記述すると、自動で GitHub Issue を作成します（ラベル付き）。
