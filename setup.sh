#!/usr/bin/env bash
# Claude Code project template setup script
# Usage: bash ~/claude-template/setup.sh
# Run this from the root of your new project.

TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$(pwd)"
BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

echo -e "${BOLD}Claude Code テンプレートセットアップ${RESET}"
echo "対象プロジェクト: ${TARGET_DIR}"
echo ""

# ── 1. .claude/ コピー ──────────────────────────────────────────────────────
if [[ -d "$TARGET_DIR/.claude" ]]; then
  printf '%b' "${YELLOW}⚠ .claude/ が既に存在します。上書きしますか？ [y/N] ${RESET}"
  read -r ans || ans=""
  if [[ "$ans" =~ ^[Yy]$ ]]; then
    cp -r "$TEMPLATE_DIR/.claude" "$TARGET_DIR/"
    echo -e "${GREEN}✓ .claude/ をコピーしました${RESET}"
  else
    echo "スキップしました。"
  fi
else
  cp -r "$TEMPLATE_DIR/.claude" "$TARGET_DIR/"
  echo -e "${GREEN}✓ .claude/ をコピーしました${RESET}"
fi

# ── 2. .mcp.json ────────────────────────────────────────────────────────────
if [[ -f "$TARGET_DIR/.mcp.json" ]]; then
  echo -e "${YELLOW}⚠ .mcp.json が既に存在します。スキップします。${RESET}"
else
  printf '\nGCP の BigQuery / Cloud Run MCP を設定しますか？ [y/N] '
  read -r ans || ans=""
  if [[ "$ans" =~ ^[Yy]$ ]]; then
    cp "$TEMPLATE_DIR/.mcp.json.example" "$TARGET_DIR/.mcp.json"
    echo -e "${GREEN}✓ .mcp.json を作成しました${RESET}"
    echo -e "${CYAN}  → .mcp.json の YOUR_GCP_PROJECT_ID / YOUR_SERVICE_NAME を書き換えてください${RESET}"
  fi
fi

# ── 3. planning/github.md ───────────────────────────────────────────────────
if [[ -f "$TARGET_DIR/planning/github.md" ]]; then
  echo -e "${YELLOW}⚠ planning/github.md が既に存在します。スキップします。${RESET}"
else
  echo ""
  echo "GitHub Projects 設定（/create-task, /assign, /push で使用）"
  printf '  GitHub ユーザー名（Project Owner）: '
  read -r gh_owner || gh_owner=""
  printf '  GitHub Projects 番号（数字のみ、不明なら Enter でスキップ）: '
  read -r gh_project_number || gh_project_number=""

  mkdir -p "$TARGET_DIR/planning"

  OWNER="${gh_owner:-YOUR_GITHUB_USERNAME}"
  PROJNUM="${gh_project_number:-1}"

  printf '%s\n' \
    "# GitHub Projects Configuration" \
    "" \
    "Owner: ${OWNER}" \
    "Project number: ${PROJNUM}" \
    "" \
    "## Labels" \
    "" \
    "Required labels for task management:" \
    "- \`code-fix\`   (red)    -- code/config changes needed" \
    "- \`doc-update\` (yellow) -- documentation updates needed" \
    "- \`monitor\`    (blue)   -- external API changes to watch" \
    "" \
    "Create labels:" \
    '```bash' \
    'gh label create "code-fix"   --color "d73a4a" --description "Code or config change required"' \
    'gh label create "doc-update" --color "e4e669" --description "Documentation update needed"' \
    'gh label create "monitor"    --color "0075ca" --description "Monitor for external changes"' \
    '```' \
    > "$TARGET_DIR/planning/github.md"

  echo -e "${GREEN}✓ planning/github.md を作成しました${RESET}"
fi

# ── 4. 完了メッセージ ────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}セットアップ完了${RESET}"
echo ""
echo "次のステップ:"
echo "  1. GitHub Labels を作成（planning/github.md 内のコマンド参照）"
if [[ -f "$TARGET_DIR/.mcp.json" ]]; then
  echo "  2. .mcp.json の YOUR_GCP_PROJECT_ID / YOUR_SERVICE_NAME を編集"
fi
echo "  3. Claude Code を起動して /init-project を実行（言語/フレームワーク自動検出 → 追加コンポーネント取得）"
echo "  4. CLAUDE.md を完成させる（/init-project が雛形を生成）"
echo ""
echo "使えるコマンド:"
echo "  /init-project     -- プロジェクト分析 → everything-claude-code から rules/skills/agents を取得"
echo "  /push             -- レビュー -> コミット -> プッシュ -> PR 作成"
echo "  /create-task      -- planning/open_items.md -> GitHub Issue 作成"
echo "  /assign           -- Issue 割当 + タスクブランチ作成"
echo "  /task-status      -- Issue ステータス更新"
echo "  /cursor-migration -- Cursor -> Claude Code 移行"
