# Mini Habit RPG – A Gamified Habit Tracking Application

## Project Description

Mini Habit RPG transforms everyday habit tracking into a role-playing game. Users build habits as quests, earn experience points and coins, level up a character, and evolve an adaptive personality based on habit categories.

**Current completion: 100%** — all core RPG systems, cloud backend syncing, custom shop & inventory customizations, daily login rewards, and settings dashboards are fully implemented.

## Key Features

### Phase 1 (MVP) — Done

- Email/password authentication
- User profiles and onboarding
- Habit management (add, complete, delete)
- XP, leveling, and streak tracking
- Personality archetypes (Scholar, Warrior, Artist)
- RPG-style dashboard

### Phase 2 — Done

- **Supabase integration** — repository layer with demo/Supabase toggle
- **Mood-based recommendations** — Motivated, Tired, Happy, Stressed
- **Daily quests** — 1–3 generated per day with XP + coin rewards
- **Achievement framework** — First Habit, Level 5, 3 Day Streak, 10 Habits
- **RPG currency** — coins from habits, quests, and achievements
- **Statistics dashboard** — completion %, streaks, XP, achievements
- **Adaptive personality** — Scholar/Warrior/Artist percentages from categories

### Phase 3 — Done

- **Advanced mood system** — dedicated mood screen with themes, gradients, and recommendations
- **Quest types** — Normal, Challenge, Bonus, Wellness linked to mood
- **Character screen** — RPG profile with class stats and personality evolution
- **Habit categories** — Study, Fitness, Health, Creativity, Social
- **Statistics upgrade** — weekly progress, XP charts, category analysis
- **Achievement animations** — animated unlock popup
- **Bottom navigation** — Home, Quests, Character, Stats, Profile

### Phase 4 — Done

- **RPG Shop System** — purchase custom avatar outfits, hairstyles, accessories, environment theme packs, Wisdom Elixirs, and Streak Aegises.
- **Inventory System** — preview locked cosmetics, view owned equipment, equip customized items/themes, and consume elixirs for instant XP.
- **Daily Login Rewards** — seven-day reward calendar (XP, coins, elixirs, shields, wings) with duplicate-claim protection.
- **Streak Shield** — purchase a Streak Aegis from the shop to automatically protect streaks from breaking when a day is missed.
- **Settings Screen** — toggle light/dark theme modes, configure sound effects/notifications, reset progress, and logout.
- **Dashboard Polish** — display current active environment background, quest completion ratios, active stats, and Quick Shop navigation.

## Tech Stack

| Technology | Role |
|------------|------|
| Flutter | Cross-platform mobile UI |
| Dart | Application language |
| Supabase | Auth + PostgreSQL backend |
| Provider | State management |
| SharedPreferences | Local demo mode persistence |

## Architecture

```text
lib/
├── config/          # App and Supabase configuration
├── models/          # Domain models
├── repositories/    # Data access (demo + Supabase)
├── services/        # Business logic services
├── providers/       # State management
├── screens/         # UI screens
├── widgets/         # Reusable components
├── utils/           # XP, mood, personality logic
└── theme/           # RPG theming
```

## Getting Started

### Prerequisites

- Flutter SDK (stable channel)
- Android Studio or VS Code with Flutter extension
- Git

### 1. Clone and install

```bash
git clone https://github.com/sereinflow/mini-habit-rpg.git
cd mini-habit-rpg
flutter pub get
```

### 2. Run in demo mode (default)

```bash
flutter run
```

No backend setup required — data persists locally.

### 3. Run with Supabase (optional)

1. Create a Supabase project and run the SQL schemas (see `supabase/migrations/`)
2. Set `demoMode = false` in `lib/config/app_config.dart`
3. Run:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

## License

MIT License. See [LICENSE](LICENSE) for details.
