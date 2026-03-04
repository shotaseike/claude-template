# Claude Code コンポーネント解説

`/init-project` で `everything-claude-code` からダウンロードされるコンポーネント（Rules / Skills / Agents）の説明と使い方です。

---

## Rules（ルール）

### `rules/common/` — 共通ルール（全プロジェクト）

| ファイル | 説明 |
|---------|------|
| `coding-style.md` | コーディング規約（インデント、命名規則、コメントスタイル）|
| `git-workflow.md` | Git ワークフロー（ブランチ戦略、コミットメッセージ形式）|
| `testing.md` | テスト戦略（単体テスト、統合テスト、テストカバレッジ）|
| `security.md` | セキュリティガイドライン（認証、暗号化、サニタイゼーション）|
| `performance.md` | パフォーマンス最適化（キャッシング、クエリ最適化、リソース管理）|
| `patterns.md` | デザインパターン（MVC、SOLID原則、リファクタリング）|
| `hooks.md` | Git フックの設定（pre-commit, pre-push）|
| `agents.md` | Claude Code エージェントの活用方法 |

### 言語別ルール

| 言語 | ディレクトリ | 説明 |
|------|----------|------|
| Python | `rules/python/` | Python 固有のスタイル、環境構築、パッケージ管理 |
| TypeScript | `rules/typescript/` | TypeScript/JavaScript の型安全性、モジュール管理 |
| Go | `rules/golang/` | Go の慣例、エラーハンドリング、並行処理 |
| Swift | `rules/swift/` | Swift の言語機能、Memory Safety、Concurrency |
| Java | 言語別なし | Java/Kotlin は Skills で対応 |

---

## Skills（スキル）

スキルは `.claude/skills/` に配置され、特定の用途・タスク・フレームワークに特化した知識・テンプレートを提供します。

### 常にインストール

| スキル | 説明 |
|--------|------|
| `tdd-workflow/` | TDD（テスト駆動開発）のワークフロー・テンプレート |
| `deployment-patterns/` | デプロイメント戦略（CI/CD、本番環境管理） |
| `security-review/` | セキュリティレビューチェックリスト |

### 言語別スキル

| 言語 | スキル | 説明 |
|------|--------|------|
| Python | `python-patterns/` | Python デザインパターン（Strategy, Factory など）|
|        | `python-testing/` | pytest, unittest, mocking のベストプラクティス |
| TypeScript | `coding-standards/` | TypeScript の型規約、ESLint 設定 |
| Go | `golang-patterns/` | Go デザインパターン（Interface-based design）|
|    | `golang-testing/` | Go testing ライブラリ、table-driven tests |
| Swift | `swiftui-patterns/` | SwiftUI コンポーネント・パターン |
|      | `swift-concurrency-6-2/` | Swift 6.2 Concurrency（async/await）|
| Java | `java-coding-standards/` | Java 命名規則、アーキテクチャパターン |

### フレームワーク別スキル

| フレームワーク | スキル | 説明 |
|--------------|--------|------|
| Django | `django-patterns/` | MVT パターン、ORM ベストプラクティス |
|        | `django-security/` | CSRF 対策、SQL インジェクション防止 |
|        | `django-tdd/` | Django テストシナリオ |
|        | `django-verification/` | モデル検証、フォーム検証 |
| FastAPI | `api-design/` | RESTful API 設計、OpenAPI スキーマ |
|         | `backend-patterns/` | バックエンド・アーキテクチャ |
| React / Next.js / Vue | `frontend-patterns/` | コンポーネント設計、状態管理 |
|                      | `e2e-testing/` | Playwright, Cypress による E2E テスト |
| Express / NestJS | `backend-patterns/` | ミドルウェア、ルーティング |
|                  | `api-design/` | API レスポンス設計 |
| Spring Boot | `springboot-patterns/` | Spring のデザインパターン（@Autowired など）|
|             | `springboot-security/` | Spring Security（認証・認可）|
|             | `springboot-tdd/` | JUnit、Mockito を使うテスト戦略 |

### データベース関連スキル

| DB | スキル | 説明 |
|----|--------|------|
| PostgreSQL | `postgres-patterns/` | JSON、範囲型、ウィンドウ関数 |
|            | `database-migrations/` | マイグレーション管理 |
| MySQL / SQLite | `database-migrations/` | マイグレーションツール、バージョニング |

---

## Agents（エージェント）

`.claude/agents/` に配置され、専門領域のタスクを支援する Claude Code サブエージェントです。

### 常にインストール

| エージェント | 用途 |
|------------|------|
| `planner.md` | プロジェクト計画、タスク分解、マイルストーン設定 |
| `architect.md` | システム設計、アーキテクチャ決定、トレードオフ分析 |
| `code-reviewer.md` | コードレビュー、品質チェック、改善提案 |
| `security-reviewer.md` | セキュリティ脆弱性スキャン、ベストプラクティス適用 |
| `doc-updater.md` | ドキュメント更新、CLAUDE.md 保守、変更ログ管理 |

### 言語別エージェント

| 言語 | エージェント | 用途 |
|------|------------|------|
| Python | `python-reviewer.md` | Python コード品質、型チェック（mypy）、PEP 8 準拠 |
| Go | `go-reviewer.md` | Go コード品質、エラーハンドリング、並行処理チェック |
|    | `go-build-resolver.md` | Go ビルド問題のトラブルシューティング |
| Java | — | 言語別エージェント未提供（code-reviewer で対応） |

### データベース関連エージェント

| エージェント | 用途 |
|------------|------|
| `database-reviewer.md` | DB スキーマ設計、クエリ最適化、インデックス戦略 |

---

## 使い方

### 1. Rules を参照

各ファイルは `.claude/rules/` に Markdown 形式で保存されます。
Claude Code はこれらを自動で読み込みながら、コードレビュー・設計判断をサポートします。

**例：** `rules/python/` がある場合、Python ファイル編集時に自動で Python ルールが適用されます。

### 2. Skills を活用

スキルはコマンドやドキュメントとして機能します。
例えば、TDD ワークフローを始める際：
- `.claude/skills/tdd-workflow/` 内のテンプレートを参照
- テストファイルの骨組みを Claude にリクエスト

### 3. Agents を指定

特定のタスクで専門エージェントを呼び出します：

```
@architect プロジェクトの全体設計を確認してください
@python-reviewer このコードをレビューしてください
@database-reviewer スキーマ設計をチェックしてください
```

---

## 詳細・最新情報

- **everything-claude-code リポジトリ**: https://github.com/affaan-m/everything-claude-code
  - Rules / Skills / Agents の最新ファイル
  - 各スキルの詳細なテンプレートとドキュメント

- **更新**: `/update-claude-config` コマンドで最新のコンポーネントをダウンロードできます

