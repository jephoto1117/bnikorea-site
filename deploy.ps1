# 배포 스크립트 — sitemap 자동 생성 + git push + Cloudflare 배포
# 실행: .\deploy.ps1
# 실행: .\deploy.ps1 -msg "커밋 메시지"

param(
  [string]$msg = "auto: 사이트 업데이트"
)

$siteRoot = $PSScriptRoot
Set-Location $siteRoot

Write-Host "`n[1/4] sitemap.xml 자동 생성..." -ForegroundColor Cyan
& "$siteRoot\generate-sitemap.ps1"

Write-Host "`n[2/4] git add & commit..." -ForegroundColor Cyan
git add -A
$status = git status --porcelain
if (-not $status) {
  Write-Host "변경사항 없음 — 배포만 진행" -ForegroundColor Yellow
} else {
  git commit -m $msg
}

Write-Host "`n[3/4] git push..." -ForegroundColor Cyan
git push origin master

Write-Host "`n[4/4] Cloudflare Pages 배포..." -ForegroundColor Cyan
npx wrangler pages deploy . --project-name bnikorea-site --branch master --commit-dirty=true

Write-Host "`n✅ 배포 완료!" -ForegroundColor Green
