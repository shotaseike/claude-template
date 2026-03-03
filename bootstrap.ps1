# Claude Code テンプレート ブートストラップ（Windows PowerShell 用）
# Usage: iex (iwr 'https://raw.githubusercontent.com/shotaseike/claude-template/main/bootstrap.ps1').Content
# Run this from the root of your new project.

$t = "$env:TEMP\ct-bootstrap.sh"
(iwr 'https://raw.githubusercontent.com/shotaseike/claude-template/main/bootstrap.sh').Content |
    Set-Content $t -Encoding UTF8 -NoNewline
bash $t
Remove-Item $t
