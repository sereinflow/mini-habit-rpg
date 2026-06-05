# Mini Habit RPG – A Gamified Habit Tracking Application

## Project Description

Mini Habit RPG transforms everyday habit tracking into a role-playing game. Users build habits as quests, earn experience points and coins, level up a character, and evolve an adaptive personality based on habit categories.

**Current completion: ~50%** — cloud backend ready, mood system, daily quests, achievements, coins, statistics, and personality evolution.

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

### Planned (Phase 3)

- Energy system
- Boss battle challenges
- Advanced reward shop
- Social / guild features

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

1. Create a Supabase project and run the schema (see local `docs/SUPABASE_SETUP.md`)
2. Set `demoMode = false` in `lib/config/app_config.dart`
3. Run:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

## License

MIT License. See [LICENSE](LICENSE) for details.
