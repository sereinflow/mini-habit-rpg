# Mini Habit RPG – A Gamified Habit Tracking Application

## Project Description

Mini Habit RPG transforms everyday habit tracking into a role-playing game. Users build habits as quests, earn experience points, level up a character, and follow a personality path that shapes their journey. Instead of passive checklists, progress feels like advancement in a game world, which improves motivation, consistency, and long-term engagement.

The application targets users who want structure without boredom: clear goals, visible rewards, and a sense of identity tied to how they grow over time.

## Problem Statement

Traditional habit trackers rely on simple to-do lists and streak counters. Over time, this becomes repetitive. Users complete tasks mechanically without emotional connection, personalization, or a reason to return beyond guilt or obligation.

Common failures include low motivation after the first week, no meaningful reward loop, and no visual representation of personal growth. When engagement drops, habits are abandoned even when the user still cares about self-improvement.

## Proposed Solution

Mini Habit RPG applies game design to habit formation. Completing habits grants XP, fills a progress bar, and levels up the user’s character. Personality archetypes (Scholar, Warrior, Artist) add identity and light theme variation so the experience feels personal rather than generic.

The full vision extends this core loop with mood-based task filtering, daily quests, an energy system, rewards, and boss-battle-style goal challenges. The current release delivers the foundation: authentication, profiles, habits, XP, leveling, and an RPG-inspired dashboard.

## Key Features

**Implemented (MVP)**

- Character leveling system
- XP and streak system
- Personality archetypes (Scholar, Warrior, Artist)
- Habit management (add, complete, delete)
- User profile stored in the cloud
- RPG-style home dashboard

**Planned**

- Mood-based task filtering
- Daily quests
- Energy system
- Reward system
- Boss battle challenges

## Tech Stack

| Technology | Role |
|------------|------|
| Flutter | Cross-platform mobile UI |
| Dart | Application language |
| Firebase Authentication | Email/password sign-in |
| Cloud Firestore | User profiles and habits |
| Provider | State management |

## Architecture Overview

The project uses a layered, beginner-friendly structure that separates concerns and scales as features grow.

| Layer | Responsibility | Project location |
|-------|----------------|------------------|
| Presentation | Screens, navigation, user input | `lib/screens/`, `lib/widgets/` |
| Application state | Connects UI to services | `lib/providers/` |
| Domain / models | Data shapes and business rules | `lib/models/`, `lib/utils/` |
| Data | Firebase and external APIs | `lib/services/` |
| Shared UI & config | Theme, constants | `lib/theme/`, `lib/utils/` |

**Conceptual mapping (clean architecture)**

- **Features** — user-facing flows (auth, onboarding, dashboard, profile), implemented under `lib/screens/`
- **Services** — Firestore and Auth access, isolated from widgets
- **Data** — models and serialization in `lib/models/`
- **Core** — shared utilities, XP logic, and app constants in `lib/utils/`

Widgets stay reusable; services do not import UI code. Providers expose state to screens so Firebase details remain testable and maintainable.

## Project Structure

```text
lib/
├── main.dart
├── app.dart
├── firebase_options.dart
├── models/
├── screens/
│   ├── auth/
│   ├── onboarding/
│   ├── home/
│   └── profile/
├── widgets/
├── services/
├── providers/
├── utils/
└── theme/
```

## Getting Started

### Prerequisites

- Flutter SDK (stable channel)
- Android Studio or VS Code with Flutter extension
- Git
- A Firebase project (for auth and database)

### 1. Clone the repository

```bash
git clone https://github.com/sereinflow/mini-habit-rpg.git
cd mini-habit-rpg
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

1. Create a project in the [Firebase Console](https://console.firebase.google.com/).
2. Enable **Authentication** with **Email/Password**.
3. Create a **Firestore** database.
4. Register an Android app with package name `com.example.mini_habit_rpg`.
5. Download `google-services.json` and place it in `android/app/`.
6. Run FlutterFire configuration:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

7. Deploy security rules from `firestore.rules` in the Firebase Console.
8. Add a Firestore composite index on the `habits` collection: `userId` (ascending), `title` (ascending).

### 4. Run the app

```bash
flutter run
```

Connect a device or start an Android emulator before running. On first launch, create an account, complete onboarding, and add habits from the dashboard.

## License

MIT License. See [LICENSE](LICENSE) for details.
