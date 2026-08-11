# 一键发布到 GitHub Pages，生成固定链接：https://<你的用户名>.github.io/bushuang-jilu/
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

Write-Host "检查 GitHub 登录状态..." -ForegroundColor Cyan
gh auth status 2>$null
if ($LASTEXITCODE -ne 0) {
  Write-Host "请先在浏览器中完成 GitHub 登录..." -ForegroundColor Yellow
  gh auth login --hostname github.com --git-protocol https --web
}

Copy-Item -Path ".\不爽即录.html" -Destination ".\index.html" -Force

if (-not (Test-Path ".git")) {
  git init
  git branch -M main
}

git add index.html README.md PRD-不爽即录.md .gitignore deploy-pages.ps1
git commit -m "Publish 不爽即录 prototype for GitHub Pages" 2>$null
if ($LASTEXITCODE -ne 0) {
  git add index.html README.md PRD-不爽即录.md .gitignore deploy-pages.ps1
  git commit -m "Update 不爽即录 prototype"
}

$repo = "bushuang-jilu"
$owner = (gh api user -q .login)
$remoteUrl = "https://github.com/$owner/$repo.git"

if (-not (git remote get-url origin 2>$null)) {
  gh repo create $repo --public --source=. --remote=origin --push --description "不爽即录交互原型"
} else {
  git push -u origin main
}

gh api -X POST "repos/$owner/$repo/pages" `
  -f build_type=legacy `
  -f "source[branch]=main" `
  -f "source[path]=/" 2>$null

$pagesUrl = "https://$owner.github.io/$repo/"
Write-Host ""
Write-Host "发布完成！固定链接：" -ForegroundColor Green
Write-Host $pagesUrl -ForegroundColor White
Write-Host ""
Write-Host "若首次启用 Pages，可能需等待 1-2 分钟生效。" -ForegroundColor Yellow
