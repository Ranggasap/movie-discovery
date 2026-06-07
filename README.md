# Movie Discovery App

A Flutter mobile application for browsing, searching, and saving favorite movies — built as a technical study case for Ternak Klip.

---

## How to Run

Make sure you have Flutter 3.44.x (stable) installed.

```bash
git clone https://github.com/Ranggasap/movie-discovery.git
cd movie_discovery
flutter pub get
flutter run
```

No API key, no additional configuration, no registration required. The app runs entirely from local assets.

---

## Architecture

This project uses **Clean Architecture** with a **feature-first** folder structure.

lib/
├── core/
│   ├── data/
│   │   ├── datasources/     # MovieLocalDataSource
│   │   ├── models/          # MovieModel (fromJson/toJson)
│   │   └── repositories/    # MovieRepositoryImpl
│   ├── domain/
│   │   ├── entities/        # Movie (pure Dart class)
│   │   ├── repositories/    # MovieRepository (abstract interface)
│   │   └── usecases/        # GetMovies, SearchMovies, ManageFavorites
│   └── providers/           # Riverpod dependency injection
├── features/
│   ├── movie_list/
│   ├── search/
│   ├── detail/
│   └── favorites/
└── main.dart

### Why Clean Architecture?

**Separation of concerns.** Each layer has one responsibility:

- **Domain layer** — pure Dart, no Flutter dependency. Contains business rules only. `Movie` entity knows what a movie is. `MovieRepository` is an abstract contract — it does not care where data comes from.
- **Data layer** — fulfills the domain contract. `MovieRepositoryImpl` reads from a JSON asset. `LocalDataSource` handles SharedPreferences for favorites. If the data source changes from JSON to a REST API tomorrow, only this layer needs to change.
- **Presentation layer** — Flutter widgets + Riverpod providers. Widgets never touch JSON or storage directly.

**Dependency rule:** arrows only point inward. Presentation depends on Domain. Data depends on Domain. Domain depends on nothing.

---

## State Management

This project uses **Riverpod** with the **Notifier pattern**.

### Why Riverpod?

- **Compile-safe** — errors are caught before runtime, unlike Provider which can throw at runtime.
- **No BuildContext dependency** — providers can be accessed and tested without a widget tree.
- **Notifier pattern** separates state (what the UI shows) from logic (how state changes), making both easier to read and test.
- **Explicit dependency graph** — each provider declares what it depends on via `ref.watch`, making the data flow easy to trace.

### Providers in this project

| Provider | Type | Purpose |
|---|---|---|
| `movieLocalDataSourceProvider` | `Provider` | Creates datasource instance |
| `movieRepositoryProvider` | `Provider` | Creates repository with injected datasource |
| `getMoviesProvider` | `Provider` | Creates GetMovies use case |
| `movieListProvider` | `NotifierProvider` | Manages movie list state, pagination, sort, filter |
| `searchProvider` | `NotifierProvider` | Manages search state with 300ms debounce |
| `favoritesProvider` | `NotifierProvider` | Manages favorites list with persistence |

---

## Features

- **Screen 1 — Movie List** — scrollable grid with pagination (10 items/batch), pull-to-refresh, sort by rating/title/date, filter by genre, loading/error/empty states
- **Screen 2 — Search** — full-page search with 300ms debounce, auto-focus keyboard, empty and no-result states
- **Screen 3 — Detail** — full-width backdrop, rating, runtime, release date, genre chips, overview, add/remove favorite
- **Screen 4 — Favorites** — persistent grid of saved movies, empty state, remove from favorites directly from card

---

## Limitations & Trade-offs

**Static data source.** All 40 movies are loaded from a local JSON asset. This was intentional per the study case requirement (no API key setup), but it means search and filter operate entirely in-memory. In a real app, these would be server-side queries.

**Search is local only.** The search implementation filters an already-loaded list. For large datasets this approach would not scale — a real implementation would debounce API calls.

**No image caching library.** I used `Image.network` directly instead of `cached_network_image` to keep dependencies minimal. Images reload on every cold start. In production, proper caching would be essential.

**Favorites use SharedPreferences.** Storing serialized JSON strings in SharedPreferences is simple and sufficient for this scale. For a larger dataset, a local database like Drift or Isar would be more appropriate.

**No error boundary per feature.** Error handling is implemented at the provider level. A more robust approach would add per-feature error recovery so one failing feature doesn't affect others.

---

## Time Spent

| Phase | Time |
|---|---|
| Project setup, pubspec, JSON data | 30 min |
| Domain layer (entities, repository interface, use cases) | 45 min |
| Data layer (model, datasource, repository impl) | 45 min |
| Riverpod providers | 30 min |
| Screen 1 — Movie List + sort/filter | 75 min |
| Screen 2 — Search + debounce | 45 min |
| Screen 3 — Detail | 45 min |
| Screen 4 — Favorites | 30 min |
| Unit tests | 30 min |
| README + cleanup | 25 min |
| **Total** | **~6 hours** |

---

## AI Tools Usage

I used **Claude (claude.ai)** as a pair programming assistant throughout this project.

**Architecture decisions**
Claude helped me evaluate trade-offs between different architectural approaches — feature-first vs layer-first structure, which state management to use, and how to design the repository pattern. All decisions were made after I understood the reasoning behind each option through discussion.

**Code generation**
Claude generated initial boilerplate for repetitive patterns such as `MovieModel` fromJson/toJson, provider wiring, and widget scaffolding. I reviewed every generated file, asked questions about parts I did not understand, and modified code where needed.

**Debugging**
Used Claude to understand error messages (e.g. `empty_constructor_bodies`, `missing_function_body`, mocktail `registerFallbackValue`) and learn why they occurred — not just to copy the fix.

**Concepts I learned through this process**
- Why `Future` is required for async data loading and how it keeps UI from freezing
- The difference between `ref.watch` and `ref.read` in Riverpod and when to use each
- How `dispose()` prevents memory leaks for controllers and listeners
- The role of abstract interfaces in Clean Architecture and why the repository exists in both Domain and Data layers
- The AAA pattern in unit testing (Arrange, Act, Assert)
- Why immutable state with `copyWith` is preferred over direct mutation
- How `FocusNode` and `Future.microtask` solve Flutter lifecycle timing issues

I can explain every line of code in this submission.

---

## Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flutter_riverpod` | ^2.6.1 | State management |
| `shared_preferences` | ^2.3.3 | Persistent favorites storage |
| `mocktail` | ^1.0.4 | Mocking for unit tests |

---

*Built by Rangga Saputra — 2026*