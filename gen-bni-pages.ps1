# ============================================================
# gen-bni-pages.ps1 — 부산 BNI 키워드 랜딩페이지 생성
# 조찬/비즈니스/사업가/창업/모임/커피챗 등 부산 키워드 → /bni/*.html
# 모든 CTA가 https://bnikorea.us/ (오션챕터 방문신청)로 연결
# 사용: -File gen-bni-pages.ps1 -Apply
# ============================================================
param([switch]$Apply)
$siteRoot="C:\Users\gkxos\Desktop\bnikorea-site"
$bniDir=Join-Path $siteRoot "bni"
$MAIN="https://bnikorea.us/"
$TEL="010-5640-5759"

# 키워드: slug(파일명/URL), kw(핵심문구), title, desc
$KW=@(
 @{slug="부산조찬모임"; kw="부산 조찬모임"; intent="아침 조찬 비즈니스 네트워킹"},
 @{slug="부산비즈니스모임"; kw="부산 비즈니스 모임"; intent="업종별 전문가 비즈니스 모임"},
 @{slug="부산사업가모임"; kw="부산 사업가 모임"; intent="대표·사업가 네트워킹"},
 @{slug="부산사업자모임"; kw="부산 사업자 모임"; intent="사업자 리퍼럴 커뮤니티"},
 @{slug="부산자영업자모임"; kw="부산 자영업자 모임"; intent="자영업자 상생 네트워크"},
 @{slug="부산창업모임"; kw="부산 창업 모임"; intent="창업가·예비창업자 네트워킹"},
 @{slug="부산기업인모임"; kw="부산 기업인 모임"; intent="기업 대표 비즈니스 커뮤니티"},
 @{slug="부산비즈니스미팅"; kw="부산 비즈니스 미팅"; intent="정기 비즈니스 미팅"},
 @{slug="부산비즈니스커뮤니티"; kw="부산 비즈니스 커뮤니티"; intent="전문가 비즈니스 커뮤니티"},
 @{slug="부산커피챗"; kw="부산 커피챗"; intent="비즈니스 커피챗·네트워킹"},
 @{slug="부산네트워킹모임"; kw="부산 네트워킹 모임"; intent="부산 비즈니스 네트워킹"},
 @{slug="부산BNI"; kw="부산 BNI"; intent="부산 BNI 오션챕터"},
 @{slug="부산CEO모임"; kw="부산 CEO 모임"; intent="대표·CEO 비즈니스 네트워킹"},
 @{slug="부산대표모임"; kw="부산 대표 모임"; intent="회사 대표 비즈니스 모임"},
 @{slug="부산경영인모임"; kw="부산 경영인 모임"; intent="경영인 리퍼럴 네트워크"},
 @{slug="부산오너모임"; kw="부산 오너 모임"; intent="사업주·오너 네트워킹"},
 @{slug="부산소상공인모임"; kw="부산 소상공인 모임"; intent="소상공인 상생 커뮤니티"},
 @{slug="부산프리랜서모임"; kw="부산 프리랜서 모임"; intent="프리랜서 비즈니스 모임"},
 @{slug="부산전문직모임"; kw="부산 전문직 모임"; intent="전문직 네트워킹"},
 @{slug="부산스타트업모임"; kw="부산 스타트업 모임"; intent="스타트업 네트워킹"},
 @{slug="부산예비창업자모임"; kw="부산 예비창업자 모임"; intent="예비창업자 네트워킹"},
 @{slug="부산청년창업모임"; kw="부산 청년창업 모임"; intent="청년 창업가 네트워크"},
 @{slug="부산인맥모임"; kw="부산 인맥 모임"; intent="비즈니스 인맥 네트워킹"},
 @{slug="부산리퍼럴"; kw="부산 리퍼럴"; intent="리퍼럴 마케팅 네트워크"},
 @{slug="부산소개모임"; kw="부산 소개 모임"; intent="고객 소개 네트워킹"},
 @{slug="부산추천마케팅"; kw="부산 추천 마케팅"; intent="입소문·추천 마케팅 모임"},
 @{slug="부산경제인모임"; kw="부산 경제인 모임"; intent="지역 경제인 커뮤니티"},
 @{slug="부산비즈니스런치"; kw="부산 비즈니스 런치"; intent="점심 비즈니스 네트워킹"},
 @{slug="부산조찬세미나"; kw="부산 조찬 세미나"; intent="조찬 비즈니스 세미나"},
 @{slug="부산아침모임"; kw="부산 아침 모임"; intent="아침 비즈니스 네트워킹"},
 @{slug="부산조찬회"; kw="부산 조찬회"; intent="조찬 네트워킹 모임"},
 @{slug="부산영업모임"; kw="부산 영업 모임"; intent="영업·세일즈 네트워킹"},
 @{slug="부산세일즈모임"; kw="부산 세일즈 모임"; intent="세일즈 리드 네트워크"},
 @{slug="부산마케팅모임"; kw="부산 마케팅 모임"; intent="마케팅 전문가 네트워킹"},
 @{slug="부산비즈니스세미나"; kw="부산 비즈니스 세미나"; intent="비즈니스 세미나·네트워킹"},
 @{slug="부산비즈니스조찬"; kw="부산 비즈니스 조찬"; intent="비즈니스 조찬 미팅"},
 @{slug="부산비즈니스파트너"; kw="부산 비즈니스 파트너"; intent="사업 파트너 매칭"},
 @{slug="부산사업파트너"; kw="부산 사업 파트너"; intent="사업 파트너 네트워크"},
 @{slug="부산협업모임"; kw="부산 협업 모임"; intent="비즈니스 협업 네트워킹"},
 @{slug="부산상공인모임"; kw="부산 상공인 모임"; intent="상공인 비즈니스 커뮤니티"},
 @{slug="부산비즈니스인맥"; kw="부산 비즈니스 인맥"; intent="비즈니스 인맥 형성"},
 @{slug="부산전문가모임"; kw="부산 전문가 모임"; intent="분야별 전문가 네트워킹"},
 @{slug="부산서면비즈니스모임"; kw="부산 서면 비즈니스 모임"; intent="서면 일대 비즈니스 네트워킹"},
 @{slug="부산해운대사업가모임"; kw="부산 해운대 사업가 모임"; intent="해운대 사업가 네트워킹"},
 @{slug="부산비즈니스그룹"; kw="부산 비즈니스 그룹"; intent="비즈니스 그룹 네트워킹"},
 @{slug="부산사업모임"; kw="부산 사업 모임"; intent="사업가 네트워킹"},
 @{slug="부산비즈니스네트워크"; kw="부산 비즈니스 네트워크"; intent="비즈니스 네트워크"},
 @{slug="부산리더스클럽"; kw="부산 리더스 클럽"; intent="비즈니스 리더 커뮤니티"},
 @{slug="부산비즈니스클럽"; kw="부산 비즈니스 클럽"; intent="비즈니스 클럽 네트워킹"},
 @{slug="부산CEO조찬"; kw="부산 CEO 조찬"; intent="CEO 조찬 모임"},
 @{slug="부산창업네트워킹"; kw="부산 창업 네트워킹"; intent="창업가 네트워킹"},
 @{slug="부산사업가커뮤니티"; kw="부산 사업가 커뮤니티"; intent="사업가 커뮤니티"},
 @{slug="부산비즈니스만남"; kw="부산 비즈니스 만남"; intent="비즈니스 만남·교류"},
 @{slug="부산교류모임"; kw="부산 교류 모임"; intent="비즈니스 교류 네트워킹"},
 @{slug="부산BNI가입"; kw="부산 BNI 가입"; intent="부산 BNI 가입 안내"},
 @{slug="부산BNI오션"; kw="부산 BNI 오션"; intent="BNI 오션챕터 부산"},
 @{slug="BNI오션챕터"; kw="BNI 오션챕터"; intent="BNI 오션챕터 부산"},
 @{slug="부산BNI후기"; kw="부산 BNI 후기"; intent="BNI 오션챕터 참관 후기"},
 @{slug="부산BNI비용"; kw="부산 BNI 비용"; intent="BNI 가입·회비 안내"},
 @{slug="부산BNI참관"; kw="부산 BNI 참관"; intent="BNI 미팅 무료 참관"},
 @{slug="부산BNI챕터"; kw="부산 BNI 챕터"; intent="부산 BNI 챕터 안내"},
 @{slug="부산비즈니스리퍼럴"; kw="부산 비즈니스 리퍼럴"; intent="비즈니스 리퍼럴 네트워크"}
)

# 오션챕터 멤버 분야 (setup.sql 기준 14)
$fields="마케팅 AI 자동화,인테리어(주거),기업보험,인테리어(뷰티샵),혈관·염증관리,정책자금,법인세무,글로벌 유통,형사변호사,개인세무,한의사,개인보험,바른자세 습관지도,인테리어(상가)" -split ","

function Esc($s){ return $s }

function Build-BniPage($item){
  $kw=$item.kw; $slug=$item.slug; $intent=$item.intent
  $url=$MAIN+"bni/"+[Uri]::EscapeDataString($slug)+".html"
  $fieldChips = ($fields | ForEach-Object { "<span class=""kwchip"">$_</span>" }) -join ''
  $relKw = @("$kw","부산 조찬모임","부산 비즈니스 네트워킹","부산 사업가 커뮤니티","부산 리퍼럴 모임","BNI 오션챕터","부산BNI","부산 창업 모임","부산 기업인 모임","부산 커피챗") | Select-Object -Unique
  $relChips = ($relKw | ForEach-Object { "<span class=""kwchip"">$_</span>" }) -join ''
@"
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>$kw — 부산BNI 오션챕터 비즈니스 네트워킹</title>
<meta name="description" content="$kw 찾으신다면 부산에서 떠오르는 BNI 오션챕터. 매주 목요일 아바니호텔 조찬 리퍼럴 미팅, 업종당 1명 독점 비즈니스 네트워킹. 무료 방문 신청 $TEL">
<meta name="keywords" content="$kw,부산 조찬모임,부산 비즈니스 모임,부산 사업가 모임,부산 창업 모임,BNI 오션챕터,부산BNI,부산 네트워킹,부산 커피챗,부산 기업인 모임">
<meta name="robots" content="index, follow, max-snippet:-1, max-image-preview:large">
<link rel="canonical" href="$url">
<meta property="og:type" content="website">
<meta property="og:title" content="$kw — 부산BNI 오션챕터">
<meta property="og:description" content="$kw — 부산에서 떠오르는 BNI 오션챕터. 매주 목요일 아바니호텔 리퍼럴 네트워킹, 업종당 1명 독점. 무료 방문 신청.">
<meta property="og:url" content="$url">
<script type="application/ld+json">
{"@context":"https://schema.org","@type":"Organization","name":"부산BNI OCEAN 챕터","alternateName":["BNI 오션챕터","부산BNI","BNI OCEAN"],"url":"https://bnikorea.us","description":"$kw - 부산 지역 전문가 비즈니스 네트워킹 그룹. 매주 목요일 아바니호텔 리퍼럴 미팅.","telephone":"$TEL","email":"gkxos@naver.com","address":{"@type":"PostalAddress","addressLocality":"부산","addressCountry":"KR"},"event":{"@type":"Event","name":"부산BNI OCEAN 정기 미팅","description":"매주 목요일 오전 6:30 아바니호텔 BNI 오션챕터 정기 네트워킹 미팅","location":{"@type":"Place","name":"아바니호텔 부산"}}}
</script>
<style>
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
:root{--primary:#0d2e8a;--primary2:#1a4fc4;--accent:#ff6b35;--text:#1a1a1a;--muted:#555;--bg:#f4f6fb;--border:#dde3ef;--radius:14px}
body{font-family:'Pretendard','Apple SD Gothic Neo','Malgun Gothic',sans-serif;color:var(--text);background:var(--bg);line-height:1.75;font-size:15px}
a{color:inherit;text-decoration:none}
header{background:#fff;border-bottom:2px solid var(--primary);padding:12px 20px;position:sticky;top:0;z-index:200;display:flex;align-items:center;justify-content:space-between;box-shadow:0 2px 10px rgba(0,0,0,.08)}
.logo{font-size:17px;font-weight:900;color:var(--primary)}.logo span{color:var(--accent)}
.header-cta{display:inline-flex;flex-direction:column;align-items:center;background:var(--accent);color:#fff;padding:8px 16px;border-radius:999px;font-weight:800;line-height:1.3}
.header-cta .l{font-size:10px;opacity:.9}.header-cta .n{font-size:14px;font-weight:900}
.hero{background:linear-gradient(150deg,#0d2e8a,#1a4fc4);color:#fff;padding:46px 22px 40px;text-align:center}
.hero .badge{display:inline-block;background:var(--accent);color:#fff;font-size:12px;font-weight:800;padding:5px 14px;border-radius:999px;margin-bottom:14px}
.hero h1{font-size:clamp(23px,5vw,38px);font-weight:900;line-height:1.3;letter-spacing:-1px;margin-bottom:14px}
.hero h1 em{color:#7eb5ff;font-style:normal}
.hero p{font-size:15px;color:rgba(255,255,255,.9);max-width:680px;margin:0 auto 22px}
.hero-btns{display:flex;gap:10px;justify-content:center;flex-wrap:wrap}
.btn{padding:13px 26px;border-radius:999px;font-weight:800;font-size:15px}
.btn-acc{background:var(--accent);color:#fff;box-shadow:0 4px 14px rgba(255,107,53,.45)}
.btn-out{background:transparent;color:#fff;border:2px solid rgba(255,255,255,.5)}
.stats{display:grid;grid-template-columns:repeat(4,1fr);background:#fff;border-bottom:1px solid var(--border)}
.stat{padding:20px 10px;text-align:center;border-right:1px solid var(--border)}
.stat:last-child{border-right:none}
.stat .v{font-size:clamp(18px,3.5vw,26px);font-weight:900;color:var(--primary)}
.stat .v span{color:var(--accent)}
.stat .l{font-size:11px;color:var(--muted);margin-top:3px}
.container{max-width:860px;margin:0 auto;padding:0 16px}
.sec-title{font-size:20px;font-weight:900;margin:36px 0 14px;padding-left:14px;border-left:5px solid var(--primary);letter-spacing:-.5px}
.box{background:#fff;border:1px solid var(--border);border-radius:var(--radius);padding:18px 20px;font-size:15px;color:var(--muted);line-height:1.95}
.box strong{color:var(--primary)}
.grid3{display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:13px;margin-top:6px}
.card{background:#fff;border:1px solid var(--border);border-radius:var(--radius);padding:18px}
.card .ic{font-size:30px;margin-bottom:8px}
.card h3{font-size:16px;font-weight:900;color:var(--primary);margin-bottom:6px}
.card p{font-size:13px;color:var(--muted);line-height:1.7}
.keyword-list{display:flex;flex-wrap:wrap;gap:7px;margin-top:6px}
.kwchip{background:#fff;border:1px solid var(--border);border-radius:999px;padding:6px 15px;font-size:13px;font-weight:600}
.kwchip:hover{background:var(--primary);color:#fff;border-color:var(--primary)}
.faq-list{display:flex;flex-direction:column;gap:10px}
details.faq{background:#fff;border:1px solid var(--border);border-radius:var(--radius);overflow:hidden}
details.faq[open]{border-color:var(--primary)}
summary.faq-q{display:flex;gap:10px;padding:15px 18px;cursor:pointer;font-weight:800;font-size:15px;list-style:none}
summary.faq-q::-webkit-details-marker{display:none}
summary.faq-q::before{content:"Q";background:var(--primary);color:#fff;border-radius:6px;min-width:24px;height:24px;display:flex;align-items:center;justify-content:center;font-size:12px;font-weight:900;flex-shrink:0}
details[open] summary.faq-q::before{background:var(--accent)}
.faq-a{padding:13px 18px 16px 52px;font-size:14px;color:var(--muted);line-height:1.85;border-top:1px solid var(--border)}
.cta-big{background:linear-gradient(135deg,#0d2e8a,#1a4fc4);color:#fff;border-radius:var(--radius);padding:34px 22px;text-align:center;margin:34px 0}
.cta-big h2{font-size:23px;font-weight:900;margin-bottom:10px}
.cta-big p{color:rgba(255,255,255,.9);margin-bottom:18px}
footer{background:#111827;color:#9ca3af;text-align:center;padding:28px 20px;font-size:13px;line-height:2}
footer strong{color:#e5e7eb}
@media(max-width:600px){.stats{grid-template-columns:1fr 1fr}.stat:nth-child(2){border-right:none}}
</style>
</head>
<body>
<header>
  <div class="logo">부산BNI <span>OCEAN</span> 오션챕터</div>
  <a class="header-cta" href="tel:$($TEL.Replace('-',''))"><span class="l">무료 방문 신청</span><span class="n">$TEL</span></a>
</header>

<section class="hero">
  <span class="badge">부산에서 떠오르는 BNI 챕터</span>
  <h1>$kw,<br><em>BNI 오션챕터</em>에서 시작하세요</h1>
  <p>$intent — 부산 BNI 오션챕터는 매주 목요일 아침 아바니호텔에서 각 분야 전문가들이 모이는 리퍼럴 네트워킹 그룹입니다. 업종당 단 1명만 참여하는 독점 구조로, 서로의 사업을 추천으로 키웁니다.</p>
  <div class="hero-btns">
    <a class="btn btn-acc" href="$MAIN">오션챕터 방문 신청 →</a>
    <a class="btn btn-out" href="tel:$($TEL.Replace('-',''))">전화 상담 $TEL</a>
  </div>
</section>

<div class="container">
  <h2 class="sec-title">$kw 찾는다면, 오션챕터</h2>
  <p class="box"><strong>$kw</strong>을(를) 찾고 계신가요? 부산BNI 오션챕터는 단순한 친목 모임이 아니라, <strong>검증된 추천(리퍼럴)으로 실제 매출을 만드는</strong> 비즈니스 네트워킹 그룹입니다. 매주 목요일 오전 6:30, 부산 아바니호텔에서 각 분야 전문가들이 모여 서로의 사업을 소개하고 고객을 추천합니다. 업종당 1명 독점 원칙으로 같은 업종 경쟁 없이 안정적으로 비즈니스를 확장할 수 있습니다.</p>

  <h2 class="sec-title">오션챕터가 다른 이유</h2>
  <div class="grid3">
    <div class="card"><div class="ic">🤝</div><h3>업종당 1명 독점</h3><p>같은 업종은 한 명만 참여합니다. 경쟁 없이 해당 분야 고객 추천을 독점적으로 받습니다.</p></div>
    <div class="card"><div class="ic">📈</div><h3>실질 매출 리퍼럴</h3><p>검증된 추천(리퍼럴)이 꾸준히 오가며, 멤버 간 실제 거래와 매출로 이어집니다.</p></div>
    <div class="card"><div class="ic">🌏</div><h3>글로벌 네트워크</h3><p>전 세계에 퍼진 BNI 글로벌 비즈니스 네트워크와 연결된 부산 거점 챕터입니다.</p></div>
  </div>

  <h2 class="sec-title">오션챕터 전문가 분야</h2>
  <div class="keyword-list">$fieldChips</div>

  <h2 class="sec-title">이런 분께 추천합니다</h2>
  <p class="box">$intent을(를) 원하는 <strong>사업가·대표·자영업자·창업가</strong>, 안정적인 고객 추천 채널이 필요한 전문직, 부산 지역에서 신뢰 기반 인맥을 넓히고 싶은 분이라면 오션챕터 방문을 추천합니다. 첫 방문은 <strong>무료</strong>이며, 실제 미팅을 참관하고 분위기를 직접 확인하실 수 있습니다.</p>

  <div class="cta-big">
    <h2>$kw, 직접 경험해 보세요</h2>
    <p>매주 목요일 아침, 부산 아바니호텔. 무료 방문 신청 후 오션챕터 미팅을 참관하세요.</p>
    <a class="btn btn-acc" href="$MAIN">지금 방문 신청하기 →</a>
  </div>

  <h2 class="sec-title">자주 묻는 질문</h2>
  <div class="faq-list">
    <details class="faq"><summary class="faq-q">$kw에 처음인데 그냥 방문해도 되나요?</summary><div class="faq-a">네, 첫 방문은 무료이며 누구나 신청 가능합니다. 사전 신청 후 매주 목요일 오전 미팅에 참관하여 분위기와 멤버들을 직접 확인하실 수 있습니다. <a href="$MAIN" style="color:#1a4fc4;font-weight:700">방문 신청 페이지</a>에서 신청하세요.</div></details>
    <details class="faq"><summary class="faq-q">BNI 오션챕터는 어떤 모임인가요?</summary><div class="faq-a">BNI(Business Network International)는 전 세계 11,000개 챕터를 둔 세계 최대 비즈니스 리퍼럴 네트워크입니다. 오션챕터는 부산에서 빠르게 성장 중인 챕터로, 업종당 1명 독점 원칙 아래 각 분야 전문가들이 매주 추천을 주고받습니다.</div></details>
    <details class="faq"><summary class="faq-q">조찬 모임은 몇 시에 어디서 진행되나요?</summary><div class="faq-a">매주 목요일 오전 6:30, 부산 아바니호텔에서 진행됩니다. 아침 시간을 활용해 하루를 비즈니스 네트워킹으로 시작할 수 있습니다.</div></details>
    <details class="faq"><summary class="faq-q">같은 업종이 이미 있으면 참여할 수 없나요?</summary><div class="faq-a">오션챕터는 업종당 1명 독점 원칙을 따릅니다. 해당 업종 자리가 비어 있다면 참여 가능하며, 자리가 찼다면 대기 또는 인근 챕터를 안내해 드립니다. 자세한 사항은 방문 신청 시 상담받으실 수 있습니다.</div></details>
  </div>
</div>

<footer>
  <strong>부산BNI OCEAN 오션챕터</strong> — 부산 비즈니스 네트워킹 · 리퍼럴 미팅<br>
  매주 목요일 오전 6:30 · 부산 아바니호텔 | 무료 방문 신청 📞 $TEL<br>
  <a href="$MAIN" style="color:#7eb5ff">▶ bnikorea.us 오션챕터 공식 사이트 바로가기</a>
</footer>
</body>
</html>
"@
}

if($Apply -and -not (Test-Path $bniDir)){ New-Item -ItemType Directory -Path $bniDir -Force | Out-Null }
$made=0
foreach($item in $KW){
  $html=Build-BniPage $item
  $dest=Join-Path $bniDir ($item.slug+".html")
  if($made -eq 0){
    Write-Host "===== 미리보기: bni/$($item.slug).html ====="
    if($html -match '<title>([^<]+)</title>'){Write-Host "title: $($matches[1])"}
    if($html -match 'canonical" href="([^"]+)"'){Write-Host "canonical: $($matches[1])"}
    $ctaCnt=([regex]::Matches($html,[regex]::Escape($MAIN))).Count
    Write-Host "bnikorea.us 링크 수: $ctaCnt"
    Write-Host "===== /미리보기 ====="
  }
  if($Apply){ [IO.File]::WriteAllText($dest,$html,(New-Object Text.UTF8Encoding $false)) }
  $made++
}
# 허브 index
$links=($KW | ForEach-Object { "<a class=""kwchip"" href=""$([Uri]::EscapeDataString($_.slug)).html"">$($_.kw)</a>" }) -join ''
$hub=@"
<!DOCTYPE html><html lang="ko"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>부산 비즈니스 네트워킹 키워드 — 부산BNI 오션챕터</title>
<meta name="description" content="부산 조찬모임·비즈니스 모임·사업가 모임·창업 네트워킹 등 부산 비즈니스 네트워킹 정보. BNI 오션챕터 무료 방문 신청.">
<link rel="canonical" href="${MAIN}bni/index.html">
<style>body{font-family:'Pretendard','Malgun Gothic',sans-serif;background:#f4f6fb;color:#1a1a1a;max-width:760px;margin:0 auto;padding:40px 18px;line-height:1.8}
h1{font-size:24px;color:#0d2e8a;font-weight:900;margin-bottom:8px}p{color:#555;margin-bottom:20px}
.keyword-list{display:flex;flex-wrap:wrap;gap:8px}
.kwchip{background:#fff;border:1px solid #dde3ef;border-radius:999px;padding:8px 16px;font-size:14px;font-weight:600;color:#0d2e8a}
.kwchip:hover{background:#0d2e8a;color:#fff}
.cta{display:inline-block;margin-top:24px;background:#ff6b35;color:#fff;padding:13px 26px;border-radius:999px;font-weight:800}</style>
</head><body>
<h1>부산 비즈니스 네트워킹 — BNI 오션챕터</h1>
<p>부산에서 떠오르는 BNI 오션챕터. 아래 키워드별 안내를 확인하고, 매주 목요일 아바니호텔 조찬 미팅에 무료로 방문 신청하세요.</p>
<div class="keyword-list">$links</div>
<a class="cta" href="$MAIN">오션챕터 방문 신청 →</a>
</body></html>
"@
if($Apply){ [IO.File]::WriteAllText((Join-Path $bniDir "index.html"),$hub,(New-Object Text.UTF8Encoding $false)) }
$mode=if($Apply){"생성완료"}else{"미리보기(미생성)"}
Write-Host ""
Write-Host "[$mode] BNI 페이지: ${made}개 + 허브 index 1개"
