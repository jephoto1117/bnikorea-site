/* consult.js — 서비스 페이지 공용 상담 신청 폼 (Supabase bni_contacts INSERT)
   페이지에 <div class="consult-form" data-cat="보일러" data-region="부산 해운대구"></div> 만 두면 됨.
   anon key는 공개키이며 RLS(public_insert_contacts)로 INSERT만 허용됨. */
(function () {
  var SB_URL = 'https://vfjbnbmunzhlarrbuapf.supabase.co';
  var SB_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZmamJuYm11bnpobGFycmJ1YXBmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU1ODM4ODcsImV4cCI6MjA5MTE1OTg4N30.9euk6s8jBLp8eP9awy1LdwEQA4scaHKH3zkTy1mBF1g';

  var CSS = '' +
    '.consult-box{background:#fff;border:1px solid #dde3ef;border-radius:12px;padding:20px 18px;margin:6px 0}' +
    '.consult-box h3{font-size:16px;font-weight:900;color:#0d2e8a;margin-bottom:4px}' +
    '.consult-box .sub{font-size:13px;color:#777;margin-bottom:14px}' +
    '.consult-box .row{display:flex;gap:8px;flex-wrap:wrap;margin-bottom:8px}' +
    '.consult-box input,.consult-box textarea{flex:1;min-width:130px;padding:11px 13px;border:1px solid #dde3ef;border-radius:8px;font-size:14px;font-family:inherit}' +
    '.consult-box textarea{width:100%;min-height:64px;resize:vertical}' +
    '.consult-box button{width:100%;padding:13px;background:#ff6b35;color:#fff;border:none;border-radius:999px;font-size:15px;font-weight:800;cursor:pointer;margin-top:4px}' +
    '.consult-box button:disabled{opacity:.6}' +
    '.consult-box .msg{font-size:13px;margin-top:10px;text-align:center;font-weight:700}' +
    '.consult-box .ok{color:#03893f}.consult-box .err{color:#e23}' +
    '.consult-box .priv{font-size:11px;color:#aaa;margin-top:8px;text-align:center}';

  function injectCss() {
    if (document.getElementById('consult-css')) return;
    var s = document.createElement('style'); s.id = 'consult-css'; s.textContent = CSS;
    document.head.appendChild(s);
  }

  function loadSb(cb) {
    if (window.supabase && window.supabase.createClient) return cb();
    var s = document.createElement('script');
    s.src = 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2';
    s.onload = cb; s.onerror = function () { cb('load-fail'); };
    document.head.appendChild(s);
  }

  function render(el) {
    var cat = el.getAttribute('data-cat') || '서비스';
    var region = el.getAttribute('data-region') || '';
    el.innerHTML =
      '<div class="consult-box">' +
        '<h3>📋 ' + region + ' ' + cat + ' 무료 상담 신청</h3>' +
        '<div class="sub">연락처를 남겨 주시면 빠르게 연락드립니다. (전화 상담도 가능)</div>' +
        '<div class="row">' +
          '<input type="text" class="c-name" placeholder="성함" autocomplete="name">' +
          '<input type="tel" class="c-phone" placeholder="연락처 (예: 010-1234-5678)" autocomplete="tel">' +
        '</div>' +
        '<textarea class="c-msg" placeholder="요청 내용 (선택) — 예: ' + cat + ' 견적 문의"></textarea>' +
        '<button type="button" class="c-submit">무료 상담 신청하기 →</button>' +
        '<div class="msg"></div>' +
        '<div class="priv">남겨주신 정보는 상담 목적 외에 사용되지 않습니다.</div>' +
      '</div>';

    var msg = el.querySelector('.msg');
    var btn = el.querySelector('.c-submit');
    btn.addEventListener('click', function () {
      var name = el.querySelector('.c-name').value.trim();
      var phone = el.querySelector('.c-phone').value.trim();
      var memo = el.querySelector('.c-msg').value.trim();
      msg.className = 'msg';
      if (!name || !phone) { msg.className = 'msg err'; msg.textContent = '성함과 연락처를 입력해 주세요.'; return; }
      if (!/[0-9]{8,}/.test(phone.replace(/[^0-9]/g, ''))) { msg.className = 'msg err'; msg.textContent = '연락처를 정확히 입력해 주세요.'; return; }
      btn.disabled = true; btn.textContent = '신청 중…';

      loadSb(function (err) {
        if (err) { msg.className = 'msg err'; msg.textContent = '잠시 후 다시 시도해 주세요.'; btn.disabled = false; btn.textContent = '무료 상담 신청하기 →'; return; }
        var sb = window.supabase.createClient(SB_URL, SB_KEY);
        sb.from('bni_contacts').insert({
          name: name,
          phone: phone,
          field: cat,
          company: region || null,
          message: memo || null
        }).then(function (res) {
          if (res.error) {
            msg.className = 'msg err'; msg.textContent = '오류가 발생했습니다. 전화로 문의해 주세요.';
            btn.disabled = false; btn.textContent = '무료 상담 신청하기 →';
          } else {
            el.querySelector('.consult-box').innerHTML =
              '<h3>✅ 신청이 접수되었습니다</h3>' +
              '<div class="sub" style="margin-top:8px">담당자가 확인 후 입력하신 연락처로 빠르게 연락드리겠습니다. 감사합니다.</div>';
          }
        });
      });
    });
  }

  function init() {
    var els = document.querySelectorAll('.consult-form');
    if (!els.length) return;
    injectCss();
    for (var i = 0; i < els.length; i++) render(els[i]);
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
  else init();
})();
