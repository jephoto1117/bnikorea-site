# ============================================================
# add-consult-form.ps1 — 전 서비스 n.html 에 Supabase 상담폼 주입
# <!-- 서비스 키워드 --> 앞에 consult-form 플레이스홀더 + </body> 앞에 스크립트
# idempotent: 이미 있으면 건너뜀
# 사용: -File add-consult-form.ps1 -Apply
# ============================================================
param([switch]$Apply)
$siteRoot="C:\Users\gkxos\Desktop\bnikorea-site"

$all=Get-ChildItem $siteRoot -Recurse -Filter "*.html" -File | Where-Object { $_.Name -match '^\d+\.html$' }
$done=0; $skip=0; $prev=$null
foreach($h in $all){
  $c=[IO.File]::ReadAllText($h.FullName,[Text.Encoding]::UTF8)
  if($c -match 'class="consult-form"'){ $skip++; continue }
  $area=""
  if($c -match '(?s)class="hero-title">[^<]+<br>\s*([^\r\n<]+?)\s*<em>'){ $area=$matches[1].Trim() }
  if(-not $area -and $c -match '<title>([^|<]+)'){ $area=($matches[1].Trim() -replace '\s+\S+$','') }
  $rel=$h.FullName.Substring($siteRoot.Length+1)
  $cat=($rel -split '\\')[0]
  if(-not $area){ $skip++; continue }

  $div="  <!-- 상담폼 -->`r`n  <div class=""consult-form"" data-cat=""$cat"" data-region=""$area""></div>`r`n`r`n  <!-- 서비스 키워드 -->"
  if($c -notmatch '<!-- 서비스 키워드 -->'){ $skip++; continue }
  $c2=$c -replace '<!-- 서비스 키워드 -->', $div
  # 스크립트 1회 추가
  if($c2 -notmatch 'consult\.js'){
    $c2=$c2 -replace '</body>', "<script src=""/consult.js"" defer></script>`r`n</body>"
  }

  if($null -eq $prev){
    $prev=$h.FullName
    Write-Host "===== 미리보기: $cat / $area ====="
    $i=$c2.IndexOf('<!-- 상담폼 -->')
    Write-Host $c2.Substring($i,[Math]::Min(260,$c2.Length-$i))
    Write-Host "..."
    Write-Host ($(if($c2 -match '<script src="/consult.js"[^>]*></script>'){'스크립트 태그: OK'}else{'스크립트 태그: 없음'}))
    Write-Host "===== /미리보기 ====="
  }
  if($Apply){ [IO.File]::WriteAllText($h.FullName,$c2,(New-Object Text.UTF8Encoding $false)) }
  $done++
}
$mode=if($Apply){"적용완료"}else{"미리보기(미적용)"}
Write-Host ""
Write-Host "[$mode] 주입:$done | 건너뜀:$skip"
