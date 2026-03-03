#!/usr/bin/env bash
# Claude Code テンプレート ブートストラップ
# Usage: bash <(curl -fsSL https://raw.githubusercontent.com/shotaseike/claude-template/main/bootstrap.sh)
# Run this from the root of your new project.

set -euo pipefail

REPO="https://github.com/shotaseike/claude-template.git"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

echo "テンプレートを取得中..."
git clone --depth 1 --quiet "$REPO" "$TMP/template"

bash "$TMP/template/setup.sh"
