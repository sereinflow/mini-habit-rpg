-- Mini Habit RPG — Phase 4: Shop, Inventory, and Login Rewards Schema
-- Run in Supabase SQL Editor or via: supabase db push

-- ============================================================
-- 1. Create user_inventory table
-- ============================================================
CREATE TABLE IF NOT EXISTS public.user_inventory (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  item_id TEXT NOT NULL,
  item_type TEXT NOT NULL CHECK (item_type IN ('outfit', 'hairstyle', 'accessory', 'theme', 'consumable')),
  quantity INT NOT NULL DEFAULT 1 CHECK (quantity >= 0),
  equipped BOOLEAN NOT NULL DEFAULT false,
  purchased_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, item_id)
);

CREATE INDEX IF NOT EXISTS idx_user_inventory_user ON public.user_inventory (user_id);

-- Enable RLS
ALTER TABLE public.user_inventory ENABLE ROW LEVEL SECURITY;

-- Policies
DROP POLICY IF EXISTS "Users can view own inventory" ON public.user_inventory;
CREATE POLICY "Users can view own inventory"
  ON public.user_inventory FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own inventory" ON public.user_inventory;
CREATE POLICY "Users can insert own inventory"
  ON public.user_inventory FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own inventory" ON public.user_inventory;
CREATE POLICY "Users can update own inventory"
  ON public.user_inventory FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own inventory" ON public.user_inventory;
CREATE POLICY "Users can delete own inventory"
  ON public.user_inventory FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================
-- 2. Create user_login_rewards table
-- ============================================================
CREATE TABLE IF NOT EXISTS public.user_login_rewards (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  last_claimed_date DATE NOT NULL DEFAULT CURRENT_DATE,
  consecutive_days INT NOT NULL DEFAULT 1 CHECK (consecutive_days >= 1 AND consecutive_days <= 7)
);

-- Enable RLS
ALTER TABLE public.user_login_rewards ENABLE ROW LEVEL SECURITY;

-- Policies
DROP POLICY IF EXISTS "Users can view own login rewards" ON public.user_login_rewards;
CREATE POLICY "Users can view own login rewards"
  ON public.user_login_rewards FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own login rewards" ON public.user_login_rewards;
CREATE POLICY "Users can insert own login rewards"
  ON public.user_login_rewards FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own login rewards" ON public.user_login_rewards;
CREATE POLICY "Users can update own login rewards"
  ON public.user_login_rewards FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own login rewards" ON public.user_login_rewards;
CREATE POLICY "Users can delete own login rewards"
  ON public.user_login_rewards FOR DELETE
  USING (auth.uid() = user_id);
