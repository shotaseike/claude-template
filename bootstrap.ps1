# Claude Code テンプレート ブートストラップ（Windows PowerShell 用）
# Usage: iex (iwr 'https://raw.githubusercontent.com/shotaseike/claude-template/main/bootstrap.ps1').Content
# Run this from the root of your new project.

$ErrorActionPreference = 'Stop'

$repo = "https://github.com/shotaseike/claude-template.git"
$tmp = Join-Path $env:TEMP "claude-template-$(Get-Random)"

try {
    Write-Host "テンプレートを取得中..."
    # core.autocrlf=false でクローンして CRLF 問題を回避
    git clone --depth 1 --quiet --config core.autocrlf=false $repo $tmp

    $bash = Get-Command bash -ErrorAction SilentlyContinue
    if (-not $bash) {
        Write-Error "bash が見つかりません。Git for Windows をインストールするか、WSL2 を有効にしてください。"
        exit 1
    }

    # バックスラッシュをスラッシュに変換（Git Bash 対応）
    $setupSh = "$tmp\setup.sh" -replace '\\', '/'
    bash "$setupSh"
} finally {
    Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
}
