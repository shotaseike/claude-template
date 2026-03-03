# Claude Code テンプレート ブートストラップ（Windows PowerShell 用）
# Usage: iex (iwr 'https://raw.githubusercontent.com/shotaseike/claude-template/main/bootstrap.ps1').Content
# Run this from the root of your new project.

$bash = Get-Command bash -ErrorAction SilentlyContinue
if (-not $bash) {
    Write-Error "bash が見つかりません。Git for Windows または WSL2 をインストールしてください。"
    exit 1
}

# Windows パス問題を回避するため、クローンも含めすべて bash 側で処理する
# @'...'@ は PowerShell のリテラル here-string（変数展開なし）→ bash がそのまま受け取る
bash -c @'
set -euo pipefail
TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT
echo "テンプレートを取得中..."
git clone --depth 1 --quiet https://github.com/shotaseike/claude-template.git "$TMP/template"
bash "$TMP/template/setup.sh"
'@
