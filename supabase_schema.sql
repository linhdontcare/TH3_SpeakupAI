-- ============================================================
-- SCRIPT TẠO CƠ SỞ DỮ LIỆU SUPABASE CHO ỨNG DỤNG SPEAKUP AI
-- Cá nhân hóa cho học viên: linhdontcare (LDC)
-- ============================================================

-- 1. Bảng USERS (Lưu thông tin học viên, chuỗi streak, mục tiêu)
CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    nickname TEXT DEFAULT 'LDC',
    avatar TEXT,
    target_minutes_per_day INTEGER DEFAULT 15,
    target_exercises_per_day INTEGER DEFAULT 5,
    reminder_enabled BOOLEAN DEFAULT TRUE,
    reminder_hour INTEGER DEFAULT 20,
    reminder_minute INTEGER DEFAULT 0,
    current_streak INTEGER DEFAULT 0,
    max_streak INTEGER DEFAULT 0,
    last_active_date TEXT,
    level TEXT DEFAULT 'PRO Scholar 💎',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Bảng PRONUNCIATION_RECORDS (Lưu kết quả phân tích âm vị AI)
CREATE TABLE IF NOT EXISTS pronunciation_records (
    id TEXT PRIMARY KEY,
    exercise_id TEXT,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    target_text TEXT NOT NULL,
    recognized_text TEXT NOT NULL,
    overall_score NUMERIC NOT NULL,
    accuracy_score NUMERIC NOT NULL,
    fluency_score NUMERIC NOT NULL,
    completeness_score NUMERIC NOT NULL,
    words_json JSONB,
    mispronounced_sounds TEXT,
    general_feedback TEXT,
    recommended_drills TEXT
);

-- 3. Bảng PRACTICE_SESSIONS (Lưu phiên học tập, thời lượng)
CREATE TABLE IF NOT EXISTS practice_sessions (
    id TEXT PRIMARY KEY,
    date_string TEXT NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    duration_seconds INTEGER NOT NULL,
    exercises_completed INTEGER NOT NULL,
    average_score NUMERIC NOT NULL
);

-- 4. Bảng DAILY_STATS (Lưu dữ liệu vẽ biểu đồ tiến độ & streak)
CREATE TABLE IF NOT EXISTS daily_stats (
    date TEXT PRIMARY KEY,
    minutes_learned INTEGER DEFAULT 0,
    exercises_completed INTEGER DEFAULT 0,
    streak_count INTEGER DEFAULT 0,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Chèn dữ liệu khởi tạo cho học viên linhdontcare (LDC)
INSERT INTO users (id, name, nickname, target_minutes_per_day, target_exercises_per_day, reminder_enabled, reminder_hour, reminder_minute, current_streak, max_streak, level)
VALUES ('default_user', 'linhdontcare', 'LDC', 15, 5, TRUE, 20, 0, 0, 0, 'PRO Scholar 💎')
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    nickname = EXCLUDED.nickname,
    level = EXCLUDED.level;

-- Cấu hình Row Level Security (RLS) cho phép đọc ghi công khai để demo đồ án
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE pronunciation_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE practice_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_stats ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Cho phep thao tac users" ON users;
CREATE POLICY "Cho phep thao tac users" ON users FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Cho phep thao tac pronunciation_records" ON pronunciation_records;
CREATE POLICY "Cho phep thao tac pronunciation_records" ON pronunciation_records FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Cho phep thao tac practice_sessions" ON practice_sessions;
CREATE POLICY "Cho phep thao tac practice_sessions" ON practice_sessions FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Cho phep thao tac daily_stats" ON daily_stats;
CREATE POLICY "Cho phep thao tac daily_stats" ON daily_stats FOR ALL USING (true) WITH CHECK (true);

