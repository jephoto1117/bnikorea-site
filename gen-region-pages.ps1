# ============================================================
# gen-region-pages.ps1 — Task3: 서울/경기 핵심 8지역 신규 페이지 생성
# 각 카테고리의 기존 1.html을 템플릿으로 클론 → 지역 치환
# 신규 날짜폴더(자동탐색)에 1~8.html + 페이지네이션
# 사용: -File gen-region-pages.ps1         (미리보기, 첫 카테고리 1지역만)
#       -File gen-region-pages.ps1 -Apply  (전체 생성)
# ============================================================
param([switch]$Apply)
$siteRoot="C:\Users\gkxos\Desktop\bnikorea-site"

# 8개 지역: full, locality, region, lat, lng
$regions=@(
  @{full="서울 강남구"; loc="강남구"; reg="서울"; lat="37.5172"; lng="127.0473"},
  @{full="서울 서초구"; loc="서초구"; reg="서울"; lat="37.4837"; lng="127.0324"},
  @{full="서울 송파구"; loc="송파구"; reg="서울"; lat="37.5145"; lng="127.1066"},
  @{full="서울 마포구"; loc="마포구"; reg="서울"; lat="37.5638"; lng="126.9084"},
  @{full="경기 성남시"; loc="성남시"; reg="경기"; lat="37.4200"; lng="127.1267"},
  @{full="경기 수원시"; loc="수원시"; reg="경기"; lat="37.2636"; lng="127.0286"},
  @{full="경기 고양시"; loc="고양시"; reg="경기"; lat="37.6584"; lng="126.8320"},
  @{full="경기 부천시"; loc="부천시"; reg="경기"; lat="37.5034"; lng="126.7660"}
)

# 신규 지역 배치 전용 고정 날짜폴더 (재실행 시 기존 것 정리 후 재생성 → idempotent)
$newDate="20271225"
if($Apply){
  $existing = Get-ChildItem $siteRoot -Recurse -Directory | Where-Object { $_.Name -eq $newDate }
  foreach($e in $existing){ Remove-Item $e.FullName -Recurse -Force }
  if($existing.Count -gt 0){ Write-Host "기존 $newDate 폴더 $($existing.Count)개 정리" }
}
Write-Host "신규 날짜폴더: $newDate"

function New-Page($srcText, $srcArea, $srcLat, $srcLng, $cat, $rg, $num){
  $c=$srcText
  $newFull=$rg.full
  # 1) 전체 지역 문자열 치환 (title/desc/hero/intro/섹션제목/카드주소/FAQ/footer/serviceArea)
  $c=$c.Replace($srcArea, $newFull)
  # 1b) 카드 업체명 등에 하드코딩된 도(부산/경남) → 새 도
  $c=$c.Replace("부산",$rg.reg); $c=$c.Replace("경남",$rg.reg)
  # 2) JSON-LD 지역/도시
  $c=[regex]::Replace($c,'("addressRegion":\s*")[^"]+(")', "`${1}$($rg.reg)`${2}")
  $c=[regex]::Replace($c,'("addressLocality":\s*")[^"]+(")', "`${1}$($rg.loc)`${2}")
  # 3) 좌표
  $c=$c.Replace($srcLat,$rg.lat); $c=$c.Replace($srcLng,$rg.lng)
  # 4) 지도 검색 URL (인코딩된 지역 접두 치환)
  $encSrc=[Uri]::EscapeDataString($srcArea); $encNew=[Uri]::EscapeDataString($newFull)
  $c=$c.Replace($encSrc,$encNew)
  # 5) canonical / og:url / JSON-LD url
  $newUrl="https://bnikorea.us/"+[Uri]::EscapeDataString($cat)+"/$newDate/$num.html"
  $c=[regex]::Replace($c,'(rel="canonical" href=")[^"]+(")', "`${1}$newUrl`${2}")
  $c=[regex]::Replace($c,'(property="og:url" content=")[^"]+(")', "`${1}$newUrl`${2}")
  $c=[regex]::Replace($c,'("url":\s*")https://bnikorea\.us/[^"]+(")', "`${1}$newUrl`${2}")
  # 6) keywords 메타 재작성 (바닥에 남는 옛 지명 제거)
  $kw="$newFull $cat,$($rg.loc) ${cat}수리,$($rg.loc) ${cat}전문,$newFull 당일출동"
  $c=[regex]::Replace($c,'(<meta name="keywords" content=")[^"]+(")', "`${1}$kw`${2}")
  # 7) 페이지네이션 active 이동
  $c=$c.Replace('class="pager active" href="1.html"','class="pager" href="1.html"')
  $c=$c.Replace("class=""pager"" href=""$num.html""","class=""pager active"" href=""$num.html""")
  return $c
}

$made=0; $catCnt=0; $prevShown=$false
$catDirs=Get-ChildItem $siteRoot -Directory | Where-Object { $_.Name -notmatch '^\.|^og$' }
foreach($cd in $catDirs){
  $cat=$cd.Name
  $src=Get-ChildItem $cd.FullName -Recurse -Filter "1.html" | Select-Object -First 1
  if(-not $src){ continue }
  $srcText=[IO.File]::ReadAllText($src.FullName,[Text.Encoding]::UTF8)
  $srcArea=""
  if($srcText -match '(?s)class="hero-title">[^<]+<br>\s*([^\r\n<]+?)\s*<em>'){ $srcArea=$matches[1].Trim() }
  if(-not $srcArea){ continue }
  $srcLat=""; $srcLng=""
  if($srcText -match '"latitude":\s*([\d.]+)'){ $srcLat=$matches[1] }
  if($srcText -match '"longitude":\s*([\d.]+)'){ $srcLng=$matches[1] }
  if(-not $srcLat -or -not $srcLng){ continue }

  $destDir=Join-Path $cd.FullName $newDate
  if($Apply -and -not (Test-Path $destDir)){ New-Item -ItemType Directory -Path $destDir -Force | Out-Null }

  for($i=0;$i -lt $regions.Count;$i++){
    $num=$i+1
    $page=New-Page $srcText $srcArea $srcLat $srcLng $cat $regions[$i] $num
    if(-not $prevShown){
      $prevShown=$true
      Write-Host "===== 미리보기: $cat / $newDate / $num.html ($($regions[$i].full)) ====="
      if($page -match '<title>([^<]+)</title>'){Write-Host "title: $($matches[1])"}
      if($page -match '<meta name="keywords" content="([^"]+)"'){Write-Host "keywords: $($matches[1])"}
      if($page -match '"addressLocality":\s*"([^"]+)".*?"addressRegion":\s*"([^"]+)"'){Write-Host "JSONLD: $($matches[1]) / $($matches[2])"}
      if($page -match '"latitude":\s*([\d.]+)'){Write-Host "lat: $($matches[1])"}
      if($page -match 'rel="canonical" href="([^"]+)"'){Write-Host "canonical: $($matches[1])"}
      if($page -match 'map-btn naver" href="([^"]+)"'){Write-Host "naverMap: $($matches[1])"}
      if($page -match 'pager active" href="(\d+\.html)"'){Write-Host "active pager: $($matches[1])"}
      Write-Host "===== /미리보기 ====="
    }
    if($Apply){ [IO.File]::WriteAllText((Join-Path $destDir "$num.html"),$page,(New-Object Text.UTF8Encoding $false)) }
    $made++
  }
  $catCnt++
}
$mode=if($Apply){"생성완료"}else{"미리보기(미생성)"}
Write-Host ""
Write-Host "[$mode] 카테고리:$catCnt | 신규페이지:$made (= 카테고리 x 8)"
