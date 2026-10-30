# Architecture: Budget Bites


## 1. Overview

Budget Bites is a Flutter app (Flutter 3.47.7, Dart 3.13.5) that helps students plan lunch spending. Meals and purchases are stored in a local SQLite database, so the whole app works offline. The code is organised in layers with a one-way dependency direction.

Packages: `sqflite`, `path`, `path_provider`, `shared_preferences`, `provider`, `intl`, `flutter_local_notifications` (pinned to ^19.5.0 because newer versions changed the method signatures). Dev: `flutter_test`, `integration_test`, `sqflite_common_ffi`, `flutter_lints`.

## 2. Layers and folders

```
lib/ui         Presentation: screens and reusable widgets
   |
   v
lib/state      State: ChangeNotifier classes, used through Provider
   |
   v
lib/data       Data: models, repositories, AppDatabase (SQLite), seed, CSV export
lib/domain     Domain: pure rules (Lunch Lens, summarize)
lib/core       Helpers: money.dart, dates.dart
lib/services   Platform service: reminder_service.dart (notifications)
```

| Layer | Files | Responsibility |
|---|---|---|
| Presentation | `app_shell.dart`, `meal_catalog_screen.dart`, `meal_detail_screen.dart`, `meal_editor_screen.dart`, `history_screen.dart`, `settings_screen.dart`, `widgets.dart` | Draw screens, read state with Provider, pass user actions to notifiers |
| State | `meals_notifier.dart`, `purchases_notifier.dart`, `settings_notifier.dart` | Hold screen state, call repositories, guard against double save, expose an `error` message, call `notifyListeners()` |
| Data | `models.dart`, `app_database.dart`, `meal_repository.dart`, `purchase_repository.dart`, `seed.dart`, `csv_export.dart` | Tables, CRUD, queries, seed data, CSV writing |
| Domain | `lunch_lens.dart`, `summary.dart` | Plain Dart functions, no Flutter or database code, easy to unit test |
| Core | `money.dart`, `dates.dart` | `formatMinor`, `parseToMinor`, `differenceWords`, `ymd`, `periodRange` |
| Services | `reminder_service.dart` | Test and daily notifications (Android) |

## 3. Navigation

`AppShell` shows a Material 3 `NavigationBar` with three tabs, Meals, History and Settings, over an `IndexedStack`. The IndexedStack keeps each tab alive, so switching tabs does not lose a screen's state (for example the History cuisine filter). The meal detail screen and the meal editor are opened on top of the Meals tab with normal route pushes. Together that makes the five screens.

## 4. Dependency direction and injection

UI -> notifiers -> repositories -> `AppDatabase` -> SQLite.

- `main.dart` creates `MealRepository` and `PurchaseRepository` once, runs `seedIfEmpty`, and provides everything with a `MultiProvider`: both repositories as plain `Provider`s, and `SettingsNotifier`, `MealsNotifier` and `PurchasesNotifier` as `ChangeNotifierProvider`s whose `load()` runs on creation.
- Notifiers receive their repository through the constructor, for example `PurchasesNotifier(purchaseRepo)`. Screens that only need to read data (a meal's history, the CSV export) get a repository with `context.read`, so no screen runs SQL.
- Repositories obtain the database from the `AppDatabase.instance` singleton, and none of them import widgets or notifiers.
- Domain functions depend only on models, money helpers and Dart.

Honest note on testing: the code is *structured* for injection (constructors and Provider), but the current tests do not use fake repositories. `data_test.dart` and `notifier_test.dart` use the real repositories on an in-memory SQLite database (`sqflite_common_ffi`, with `AppDatabase.instance.testPath = inMemoryDatabasePath`). That tests the real SQL, but it is closer to an integration test of notifier plus repository than a pure unit test of the notifier. The comment in `main.dart` that says "so tests can swap in fakes" describes the design intent, not what the tests do today.

## 5. Data model

Two entities in a one-to-many relationship: one Meal has many PurchaseLogs. Database file `budget_bites.db`, version 1, created in `onCreate`.

**meals**
`id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT NOT NULL, `venue_note` TEXT NOT NULL DEFAULT '', `cuisine` TEXT NOT NULL (Asian, Mexican, American or Other), `estimated_price_minor` INTEGER NOT NULL CHECK >= 0.

**purchase_logs**
`id` INTEGER PRIMARY KEY AUTOINCREMENT, `meal_id` INTEGER NOT NULL, `purchased_at` TEXT NOT NULL (`yyyy-MM-dd`), `actual_price_minor` INTEGER NOT NULL CHECK >= 0, `note` TEXT NOT NULL DEFAULT '', `status` TEXT NOT NULL DEFAULT 'final', `save_key` TEXT NOT NULL **UNIQUE**, FOREIGN KEY(meal_id) REFERENCES meals(id) **ON DELETE CASCADE**.

`PRAGMA foreign_keys = ON` is set in `onConfigure`. SQLite leaves foreign keys off by default, so without this line the cascade would silently do nothing.

Design choices:

- **Money is stored as integer minor units** (cents): 750 means $7.50. This avoids floating-point rounding errors. Conversion happens only in `formatMinor` and `parseToMinor`. The CHECK constraints reject negative prices at the database level as well as in the UI.
- **Cascade delete:** `MealRepository.delete` removes only the meal row; the database deletes its purchases. The delete dialog first calls `countLogs(mealId)` so it can say how many purchases will go too.
- **Reports count final purchases only:** `inRange` and `totalFinal` filter `status = 'final'`, the start date is inclusive and the end date is exclusive.
- **Periods:** `periodRange` supports This week (Monday to Sunday), This month and All time.
- **Seed data:** `seedIfEmpty` inserts 3 example meals and 5 purchases on first run (Chicken Bowl 450, 600 and 750; Veggie Wrap 500; Bean Burrito 325), so Lunch Lens has a meal with 3 purchases to demonstrate.

## 6. Key flows

**Save a purchase (double-save protection).** Start creates a draft with a new `saveKey`. Save calls `PurchasesNotifier.add`, which has two independent guards:

1. If `saving` is already true the call returns false at once, and the Save button is disabled while saving.
2. The repository inserts with `ConflictAlgorithm.ignore`. Because `save_key` is UNIQUE, a second insert with the same key is ignored and the existing row's id is returned.

`notifier_test.dart` fires two `add` calls at the same moment and expects the results `[true, false]` and exactly one stored row.

**Loading and errors.** `load()` reads the selected period with `periodRange` and the current week's total, and on failure sets a user-friendly `error` message instead of crashing. `update` and `remove` call the repository directly with no try/catch (a known limitation).

**Draft restore after restart.** The unfinished purchase (price and `saveKey`) is stored as JSON in SharedPreferences under `draft_<mealId>`. It is restored in `initState` and cleared on Save or Reset. Reusing the saved `saveKey` means a duplicate save after a restart still cannot create two rows. The `status = 'draft'` option in the model is not what stores this draft.

**History totals.** The filtered prices go to `summarize()` through `compute()`, which runs in a separate isolate so the UI thread is not blocked. A `FutureBuilder` shows a progress bar until the result arrives, and the computation reruns only when the list of prices changes.

**Lunch Lens** (`estimateNextCost`). Rule-based:

1. Keep only final purchases with a non-negative price, optionally only those before a given date, so a purchase cannot predict itself.
2. Sort newest first; ties on the same date are broken by the higher log id.
3. If fewer than 3 remain, there is no estimate and the card shows "Not enough history".
4. Otherwise the estimate is the mean of the last 3, rounded to the nearest minor unit with halves rounding up, computed with integers as `(2 * sum + 3) ~/ 6`.
5. The baseline is the single most recent price. The result also carries the three prices used and the date range, which become the on-screen explanation.

The estimate is only displayed. It never overwrites the price the user enters.

**Reminder and export.** `ReminderService` can show an immediate test notification or a daily repeating one (limit: it repeats from the moment it is switched on, with no chosen time of day). `exportPurchasesCsv` reads all meals and all final purchases and writes `budget_bites_purchases.csv` to the app documents folder; the UI shows the saved path or an error message.

## 7. Trade-offs

1. **SharedPreferences for the draft instead of a SQLite row.** Simple, and enough for one small JSON value per meal. But it sits outside the relational model, so the cascade does not clean it up: deleting a meal does not remove its `draft_<id>` key, so an orphan key can remain. Tested on the emulator: deleting a meal that had a saved draft caused no error or crash, and the leftover key is harmless. The unused `draft` value in `status` is a small leftover from an earlier design.
2. **`compute()` for totals.** It satisfies the background-processing requirement and keeps the UI responsive. For a few dozen rows, starting an isolate costs more than the sum itself, so it would only pay off with thousands of rows.
3. **A global `AppDatabase.instance` singleton.** Easy to use and guarantees one connection, but it is hidden global state. Tests have to flip `testPath`, and a fake repository cannot be substituted without more changes.
4. **Rule-based Lunch Lens instead of a trained model.** Explainable, works offline and needs no training data. But it only reacts to recent history, and on the held-out set it was closer than the last-price baseline in only 5 of 9 cases.
5. **IndexedStack navigation.** Keeps tab state alive, at the cost of building all three tabs at start-up.

## 8. Testing and coverage

| Item | Result |
|---|---|
| `flutter test` | 21 tests passing: `data_test`, `notifier_test` (double save), `lunch_lens_test`, `lens_eval_test`, `money_test` (money helpers and `summarize`), `receipt_test`, `widget_test` (3 widget tests) |
| Integration test | `integration_test/app_test.dart` passing on the Android emulator (launch and navigation) |
| Line coverage | 169/211 lines = 80.1% (unit and widget tests only; the integration test is not included) |
| Lunch Lens held-out evaluation | 9 cases: lensMAE = 149.11, baselineMAE = 211.11 (minor units), Lunch Lens closer in 5 of 9 |

Limits: the evaluation uses a small fictional sample, so it shows the method works, not that it generalises. Coverage counts only the files the test suite loads.

Manual testing: the 25-step offline and restart checklist (`Offline_Test_Checklist.xlsx`) is run on Suma's phone and Tejaswini's Android emulator; the filled-in results are in the evidence PDF.

## 9. Known limitations

- The reminder has no chosen time of day.
- The draft is stored outside SQLite (see trade-off 1).
- `update` and `remove` in `PurchasesNotifier` have no error handling.
- The tests use a real in-memory database rather than fake repositories.
- The app is built and tested for Android only; iOS was not tested.
