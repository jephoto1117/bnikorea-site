# ============================================================
# fix-faq.ps1 — 깨진 FAQ(고아 </summary>) 복구 스크립트
# 대상: 누수 / 하수구 / 보일러 3개 카테고리 (총 306개 의심)
# 동작: 지도 섹션은 보존, 그 뒤 깨진 FAQ 영역만 카테고리별 올바른 FAQ로 교체
# 사용: powershell -File fix-faq.ps1            (미리보기, 파일 수정 안 함)
#       powershell -File fix-faq.ps1 -Apply     (실제 적용)
# ============================================================
param([switch]$Apply)

$siteRoot = "C:\Users\gkxos\Desktop\bnikorea-site"

# 카테고리별 FAQ 데이터 (rebuild-pages.ps1 의 q2~a4 와 동일)
$faq = @{}
$faq["보일러"] = @{
  q2="가스보일러와 심야전기보일러 중 어떤 게 더 경제적인가요?";a2="가스보일러는 즉각적인 온수 공급과 빠른 난방이 장점이지만 도시가스 공급 지역에 한정됩니다. 심야전기보일러는 야간 저렴한 전기를 이용해 경제적 난방이 가능합니다. 주택 환경과 에너지 요금을 비교해 선택하세요.";
  q3="보일러에서 이상한 소리가 나요. 어떻게 해야 하나요?";a3="배관 내 공기가 차거나 스케일이 쌓이면 소음이 발생합니다. 에어 빼기 작업이나 배관 세척으로 해결되는 경우가 많습니다. 소음을 방치하면 보일러 수명이 단축되니 빠른 점검이 필요합니다.";
  q4="보일러 에러코드가 떴어요. 어떻게 해야 하나요?";a4="보일러 에러코드는 제조사별로 다르며 점화불량, 과열, 배기불량 등을 나타냅니다. 임의로 초기화만 반복하면 근본 원인이 남아 재발합니다. 전문 수리 기사에게 에러코드와 증상을 함께 설명해 정확한 진단을 받으세요."
}
$faq["누수"] = @{
  q2="누수가 의심될 때 가장 먼저 확인해야 할 것은?";a2="수도 계량기를 확인하세요. 모든 수전을 잠근 상태에서 계량기 바늘이 움직이면 배관 어딘가에서 누수가 발생 중입니다. 즉시 전문 누수 탐지 업체에 연락하세요.";
  q3="천장에서 물이 새는데 위층이 문제인가요?";a3="위층 바닥 방수 하자나 배관 누수 둘 다 원인이 될 수 있습니다. 열화상 카메라나 청음 탐지 장비로 정확한 위치를 찾아야 위층 책임 여부를 판단할 수 있습니다.";
  q4="수도요금이 갑자기 많이 나왔어요. 누수 때문인가요?";a4="갑작스러운 수도요금 급증의 가장 흔한 원인이 누수입니다. 지하 매립 배관이나 벽 속 배관의 미세 누수는 눈에 보이지 않아 탐지 장비 없이는 발견이 어렵습니다. 즉시 전문 탐지 의뢰를 권장합니다."
}
$faq["하수구"] = @{
  q2="싱크대, 욕실, 화장실 막힘은 원인이 다른가요?";a2="싱크대는 음식물 기름때, 욕실은 머리카락과 비누 찌꺼기, 화장실 변기는 이물질 투입이 주원인입니다. 막힘 위치에 따라 적합한 뚫음 방법이 달라지므로 전문 장비가 필요합니다.";
  q3="하수구에서 냄새가 올라와요. 어떻게 해결하나요?";a3="트랩 내 물이 마르거나 배관 내 오물이 부패하면 냄새가 올라옵니다. 뜨거운 물 세척이나 배관 청소제로 개선을 시도하고, 지속된다면 전문 고압세척이 필요합니다.";
  q4="배수가 느려졌어요. 미리 청소해야 하나요?";a4="배수 속도가 느려지는 것은 이미 배관 내에 이물질이 쌓이기 시작했다는 신호입니다. 완전히 막히기 전에 고압 세척으로 관리하면 비용과 불편함을 줄일 수 있습니다."
}

function Build-Faq($area, $cat, $d) {
  $q1 = "$area $cat 업체를 빠르게 찾으려면?"
  $a1 = "$area 인근에서 검색되는 $cat 관련 업체들을 모아 안내해 드리는 페이지입니다. 본문에 정리된 각 업체 정보와 연락처, 상단의 지도 링크를 통해 직접 확인하실 수 있습니다."
  $nl = "`r`n"
  $h  = "$nl$nl  <!-- FAQ -->$nl  <h2 class=""section-title"">자주 묻는 질문</h2>$nl  <div class=""faq-list"">$nl"
  $h += "    <details class=""faq""><summary class=""faq-q"">$q1</summary><div class=""faq-a"">$a1</div></details>$nl"
  $h += "    <details class=""faq""><summary class=""faq-q"">$($d.q2)</summary><div class=""faq-a"">$($d.a2)</div></details>$nl"
  $h += "    <details class=""faq""><summary class=""faq-q"">$($d.q3)</summary><div class=""faq-a"">$($d.a3)</div></details>$nl"
  $h += "    <details class=""faq""><summary class=""faq-q"">$($d.q4)</summary><div class=""faq-a"">$($d.a4)</div></details>$nl"
  $h += "  </div>$nl$nl  "
  return $h
}

$fixed = 0; $skipped = 0; $preview = $null
foreach ($cat in $faq.Keys) {
  $catDir = Join-Path $siteRoot $cat
  if (-not (Test-Path $catDir)) { continue }
  $d = $faq[$cat]
  foreach ($file in (Get-ChildItem $catDir -Recurse -Filter "*.html")) {
    if ($file.Name -notmatch '^\d+\.html$') { continue }
    $c = [IO.File]::ReadAllText($file.FullName, [Text.Encoding]::UTF8)

    # 깨짐 판정: 첫 </summary> 가 첫 <summary 보다 먼저 등장
    $fc = $c.IndexOf('</summary>'); $fo = $c.IndexOf('<summary')
    $orphan = ($fc -ge 0 -and ($fo -lt 0 -or $fc -lt $fo))
    if (-not $orphan) { $skipped++; continue }

    # area 추출 (rebuild-pages.ps1 과 동일 로직)
    $area = ""
    if ($c -match '(?s)class="hero-title">[^<]+<br>\s*([^\r\n<]+?)\s*<em>') { $area = $matches[1].Trim() }
    if (-not $area -and $c -match '<title>([^|<]+)') { $area = $matches[1].Trim() -replace '\s+\S+$', '' }
    if (-not $area) { $skipped++; continue }

    $newFaq = Build-Faq $area $cat $d

    # 깨진 영역 교체: 고아 </summary> + faq-a ~ 페이지네이션 직전까지
    $pattern = '(?s)\s*</summary>\s*<div class="faq-a">.*?(?=\s*<!-- 페이지네이션|\s*<nav class="pagination")'
    if ($c -notmatch $pattern) { $skipped++; continue }
    $c2 = [regex]::Replace($c, $pattern, $newFaq)

    # 푸터 토픽 불일치 보정 (보일러 페이지의 "배관 청소" 잔재 등)
    $c2 = $c2 -replace '배관 청소 관련 업체 위치 안내', "$cat 관련 업체 위치 안내"

    if ($null -eq $preview) {
      $preview = $file.FullName
      Write-Host "===== 미리보기: $($file.FullName) ====="
      $idx = $c2.IndexOf('<!-- FAQ -->')
      Write-Host $c2.Substring([Math]::Max(0,$idx-40), [Math]::Min(900, $c2.Length-[Math]::Max(0,$idx-40)))
      Write-Host "===== /미리보기 ====="
    }

    if ($Apply) {
      [IO.File]::WriteAllText($file.FullName, $c2, (New-Object Text.UTF8Encoding $false))
    }
    $fixed++
  }
}
$mode = if ($Apply) { "적용완료" } else { "미리보기(미적용)" }
Write-Host ""
Write-Host "[$mode] 복구 대상: $fixed 개 | 건너뜀(정상/추출실패): $skipped 개"
