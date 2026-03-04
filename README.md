# claude-template

Claude Code プロジェクト設定のテンプレート集。
このテンプレートを利用することで、プロジェクトに最適化されたClaude Codeの環境を簡単に構築できます。

`/init-project` コマンドにより、プロジェクトの言語・フレームワークを自動検出し、[everything-claude-code](https://github.com/affaan-m/everything-claude-code) から適切な rules / skills / agents を選んでダウンロードします。

## セットアップ手順

### 1. 初期セットアップ

以下のコマンドをプロジェクトのルートディレクトリで実行してください。
ワンライナーで `.claude` 環境の構築、`.gitignore` の設定が完了します。

**前提条件:** `git`, `gh`, `python3`, `curl` がインストール済みであり、`gh auth login` でGitHubにログインしている必要があります。

```bash
curl -sSL https://raw.githubusercontent.com/shotaseike/claude-template/main/install.sh | bash
```

### 2. プロジェクトの初期化

セットアップが完了したら、Claude Code を起動し、以下のコマンドを実行してください。
プロジェクトの言語・フレームワークを自動検出し、最適な rules / skills / agents をダウンロードします。

```
/init-project
```

これで、あなたのプロジェクト用の Claude Code 環境の準備は完了です。

## 設定のアップデート

テンプレートや `everything-claude-code` の内容は随時更新されます。
以下のコマンドを実行することで、設定を最新の状態に保つことができます。

```
/update-claude-config
```

このコマンドは、プロジェクトの言語・フレームワークを再検出し、最新の rules / skills / agents を再ダウンロードして上書きします。

## リポジトリ構造

`install.sh` によって、カレントプロジェクトに以下の構造で `.claude` ディレクトリが作成されます。

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
│   └── cursor-migration/
│       └── SKILL.md            # /cursor-migration: Cursorからの移行支援
└── hooks/
    ├── doc-impact.sh           # Python編集時の影響ドキュメント表示
    └── auto-register-issues.py # open_items.md からのGitHub Issue自動登録
```

`/init-project` または `/update-claude-config` を実行すると、`rules/`, `agents/`, `skills/` の下にプロジェクトに合わせたコンポーネントが追加されます。

## コンポーネント詳細

### コマンド (`/init-project`, `/push`, etc.)
- `/init-project`: プロジェクトの言語を検出し、最適な設定をダウンロードします。
- `/update-claude-config`: 設定を最新版に更新します。
- GitHub連携コマンド (`/push`, `/create-task`など): GitHub Issues と Projects を利用したタスク管理ワークフローを支援します。リポジトリは自動で検出されるため、設定不要ですぐに利用できます。

### フック (`hooks/`)
- `doc-impact.sh`: Pythonファイル編集時に、関連するドキュメントを自動で検索・表示します。
- `auto-register-issues.py`: `planning/open_items.md` ファイルにタスクを記述するだけで、自動でGitHub Issueを作成します。
