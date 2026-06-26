-- Mini Habit RPG — Phase 3 schema upgrade
-- Run in Supabase SQL Editor or via: supabase db push

-- ============================================================
-- 1. Add quest_type and mood columns to daily_quests
-- ============================================================
ALTER TABLE daily_quests
  ADD COLUMN IF NOT EXISTS quest_type TEXT NOT NULL DEFAULT 'normal'
  CHECK (quest_type IN ('normal', 'challenge', 'bonus', 'wellness'));

ALTER TABLE daily_quests
  ADD COLUMN IF NOT EXISTS mood TEXT
  CHECK (mood IS NULL OR mood IN ('motivated', 'tired', 'stressed', 'happy'));

CREATE INDEX IF NOT EXISTS idx_daily_quests_type
  ON daily_quests (user_id, quest_type, quest_date);

-- ============================================================
-- 2. Expand habit categories (health, social)
-- ============================================================
ALTER TABLE habits DROP CONSTRAINT IF EXISTS habits_category_check;

ALTER TABLE habits
  ADD CONSTRAINT habits_category_check
  CHECK (category IN ('study', 'fitness', 'health', 'creative', 'social'));

-- ============================================================
-- 3. Mood history (if not already created)
-- ============================================================
CREATE TABLE IF NOT EXISTS mood_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  mood TEXT NOT NULL CHECK (mood IN ('motivated', 'tired', 'stressed', 'happy')),
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_mood_history_user
  ON mood_history (user_id, recorded_at DESC);

ALTER TABLE mood_history ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users read own mood history" ON mood_history;
CREATE POLICY "Users read own mood history"
  ON mood_history FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users insert own mood history" ON mood_history;
CREATE POLICY "Users insert own mood history"
  ON mood_history FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ============================================================
-- 4. Weekly stats view (optional — for dashboards)
-- ============================================================
CREATE OR REPLACE VIEW weekly_habit_stats
WITH (security_invoker = true) AS
SELECT
  user_id,
  date_trunc('week', completed_at)::date AS week_start,
  COUNT(*) AS habits_completed,
  SUM(xp_reward) AS xp_earned
FROM habits
WHERE completed = true AND completed_at IS NOT NULL
GROUP BY user_id, date_trunc('week', completed_at);

GRANT SELECT ON weekly_habit_stats TO authenticated;
