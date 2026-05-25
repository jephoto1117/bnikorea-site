-- ============================================================
-- BNI OCEAN 사이트 Supabase 테이블 설정
-- Supabase 대시보드 → SQL Editor 에서 실행
-- ============================================================

-- 1. 멤버 테이블
CREATE TABLE IF NOT EXISTS bni_members (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name          text NOT NULL,
  company       text,
  field         text,
  photo_url     text,
  instagram_url text,
  bio           text,
  display_order int  DEFAULT 0,
  is_active     boolean DEFAULT true,
  created_at    timestamptz DEFAULT now()
);

-- 2. 성공사례 후기 테이블
CREATE TABLE IF NOT EXISTS bni_reviews (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  member_name   text NOT NULL,
  member_title  text,
  rating        int  DEFAULT 5 CHECK (rating BETWEEN 1 AND 5),
  content       text NOT NULL,
  revenue_text  text,
  photo_url     text,
  is_active     boolean DEFAULT true,
  created_at    timestamptz DEFAULT now()
);

-- 3. 통계 수치 테이블
CREATE TABLE IF NOT EXISTS bni_stats (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  stat_key    text UNIQUE NOT NULL,
  stat_value  text NOT NULL,
  stat_label  text NOT NULL,
  updated_at  timestamptz DEFAULT now()
);

-- 4. 갤러리 테이블
CREATE TABLE IF NOT EXISTS bni_gallery (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  image_url     text NOT NULL,
  caption       text,
  display_order int  DEFAULT 0,
  created_at    timestamptz DEFAULT now()
);

-- 5. 참관 신청 테이블
CREATE TABLE IF NOT EXISTS bni_contacts (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name       text NOT NULL,
  phone      text NOT NULL,
  email      text,
  company    text,
  field      text,
  message    text,
  status     text DEFAULT 'pending',
  created_at timestamptz DEFAULT now()
);

-- ============================================================
-- RLS (Row Level Security) 설정
-- ============================================================
ALTER TABLE bni_members  ENABLE ROW LEVEL SECURITY;
ALTER TABLE bni_reviews  ENABLE ROW LEVEL SECURITY;
ALTER TABLE bni_stats    ENABLE ROW LEVEL SECURITY;
ALTER TABLE bni_gallery  ENABLE ROW LEVEL SECURITY;
ALTER TABLE bni_contacts ENABLE ROW LEVEL SECURITY;

-- 공개 읽기 (누구나)
CREATE POLICY "public_read_members"  ON bni_members  FOR SELECT USING (true);
CREATE POLICY "public_read_reviews"  ON bni_reviews  FOR SELECT USING (true);
CREATE POLICY "public_read_stats"    ON bni_stats    FOR SELECT USING (true);
CREATE POLICY "public_read_gallery"  ON bni_gallery  FOR SELECT USING (true);

-- 참관 신청은 누구나 INSERT 가능
CREATE POLICY "public_insert_contacts" ON bni_contacts FOR INSERT WITH CHECK (true);

-- 인증된 관리자 전체 권한
CREATE POLICY "admin_all_members"  ON bni_members  FOR ALL USING (auth.uid() IS NOT NULL);
CREATE POLICY "admin_all_reviews"  ON bni_reviews  FOR ALL USING (auth.uid() IS NOT NULL);
CREATE POLICY "admin_all_stats"    ON bni_stats    FOR ALL USING (auth.uid() IS NOT NULL);
CREATE POLICY "admin_all_gallery"  ON bni_gallery  FOR ALL USING (auth.uid() IS NOT NULL);
CREATE POLICY "admin_all_contacts" ON bni_contacts FOR ALL USING (auth.uid() IS NOT NULL);

-- ============================================================
-- 초기 데이터 입력
-- ============================================================

-- 통계 초기값
INSERT INTO bni_stats (stat_key, stat_value, stat_label) VALUES
  ('monthly_referrals', '350+',   '월 평균 고객 추천'),
  ('total_revenue',     '35억+',  '누적 리퍼럴 매출'),
  ('member_count',      '14',     '전문가 멤버'),
  ('global_chapters',   '11,000+','글로벌 챕터')
ON CONFLICT (stat_key) DO NOTHING;

-- 멤버 초기 데이터 (14명)
INSERT INTO bni_members (name, company, field, display_order) VALUES
  ('김종은',  '삼칠',             '마케팅 AI 자동화',    1),
  ('박귀붕',  '디자인 공간의힘',   '인테리어 (주거)',     2),
  ('정완식',  '영진에셋',          '기업보험',            3),
  ('강경석',  '디자인아톰',        '인테리어 (뷰티샵)',   4),
  ('이보영',  '독일피엠',          '혈관·염증관리',       5),
  ('강밀알',  '선한파트너스',      '정책자금',            6),
  ('김민규',  '다인세무회계파트너스','법인세무',          7),
  ('방혜정',  'JARREL LAB',       '글로벌 유통',         8),
  ('양정훈',  '법무법인 베테랑',   '형사변호사',          9),
  ('박성준',  '박성준세무회계사무소','개인세무',          10),
  ('변종훈',  '태흥당한의원',      '한의사',             11),
  ('이성우',  '더베스트금융서비스', '개인보험',           12),
  ('이은주',  '슬리밍고',          '바른자세 습관지도',   13),
  ('박주영',  '스텔라디자인',      '인테리어 (상가)',     14)
ON CONFLICT DO NOTHING;
