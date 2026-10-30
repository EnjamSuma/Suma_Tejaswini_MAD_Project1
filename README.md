# Budget Bites

A campus meal decision desk that connects what a student plans to spend with what lunch actually cost. Plan a meal, log a purchase, and see how small choices add up against a weekly budget. Everything stays on the phone: no account, no cloud, no internet needed.

Course: Mobile Application Development (CSC 6360, Section 004, CRN 83642), Project One, Fall 2026.

## Who it is for

College students with a limited lunch budget who buy or cook most of their own food and want a simple, private way to see whether their plan matches their spending. Venue notes and prices are entered by the user. They are the user's own estimates, not live listings.

## Team

| Member              | Pathway  | Main responsibilities                                                                                                                     |
| ------------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| Suma Enjam          | Graduate | UI and navigation, reusable widgets, Lunch Lens helper, receipt card, animations, README and AI_FEATURE.md                                |
| Tejaswini Kolliboni | Graduate | SQLite database and repositories, Provider state, double-save protection, reminder, CSV export, background totals, tests, ARCHITECTURE.md |

We reviewed each other's pull requests. The ClickUp board is at https://app.clickup.com/90141778294/v/l/s/90149396688 and the evidence file is `Kanban_Contribution_Evidence.pdf` in the repository root.

## Features

- Add, view, edit and delete meals (name, venue note, cuisine, estimated price), with validation.
- Filter meals by cuisine.
- Start a plan from a meal, set the actual price with a slider, and save the purchase. An unfinished purchase is restored after the app restarts. Reset asks for confirmation and never deletes saved purchases.
- Receipt card showing planned price, actual price, and the difference in words (for example "Under plan by $1.00") as well as color.
- History screen with period and cuisine filters, a total, a count, an average, and the percentage of the weekly budget used. Edit or delete any purchase and the totals update.
- Weekly budget slider (with its value shown) saved in SharedPreferences.
- Lunch Lens: a rule-based estimate of the next cost for a meal. See `AI_FEATURE.md`.
- Deleting a meal also deletes its purchases, but only after a dialog that says how many purchases will be removed.
- Saving twice never records two purchases (pending-save guard plus a unique save key).
- Daily planning reminder (local notification) with a switch and a test button in Settings.
- Export purchases to a CSV file in the app documents folder.
- Totals on the History screen are computed in a background isolate with `compute()`.
- Animations: an animated budget progress bar (implicit) and a receipt reveal after saving (explicit). Both respect the phone's reduced-motion setting.

## How to run it

Requirements:

- Flutter 3.47.6 (stable)
- Dart 3.13.5
- Android phone with USB debugging enabled or Android emulator

Clone the repository:

```bash
git clone https://github.com/EnjamSuma/Suma_Tejaswini_MAD_Project1.git
cd Suma_Tejaswini_MAD_Project1
flutter pub get
```

Check connected devices:

```bash
flutter devices
```

Run the application:

```bash
flutter run
```

Run tests:

```bash
flutter test
flutter test integration_test -d <device-id>
flutter test --coverage
```

Build the release APK:

```bash
flutter build apk --release
```

The APK will be generated at:

`build/app/outputs/flutter-apk/app-release.apk`

Note: The application uses SQLite through `sqflite` and is intended to run on Android devices or emulators, not Chrome.

## User guide

1. Open the **Meals** tab. The card at the top shows how much of this week's budget has been used. Tap a cuisine chip to filter.
2. Tap **+** to add a meal. Enter a name and a price like `7.50`. A wrong price shows an error and nothing is saved.
3. Tap a meal to open it. Lunch Lens shows an estimate once the meal has at least three saved purchases.
4. Press **Start**, move the slider to the real price, and press **Save purchase**. The receipt shows the difference from your plan.
5. Open **History** to see totals, change the period, edit a price by tapping it, or delete a purchase.
6. Open **Settings** to change the weekly budget, turn on the daily reminder, or export a CSV.

Long-press a meal to edit it. The three-dot menu does the same without a gesture.

## Tech and data

- Flutter version: 3.47.6 (stable)
- Dart version: 3.13.5
- DevTools version: 2.60.0
- Packages: sqflite, path, path_provider, shared_preferences, provider, intl, flutter_local_notifications (pinned to 19.x), plus sqflite_common_ffi and integration_test for testing. Exact versions are in `pubspec.lock`.
- Architecture: three layers (presentation, domain, data). See `ARCHITECTURE.md`.

Database schema (SQLite, money stored as integer minor units, so $7.50 is stored as 750):

| Table           | Columns                                                                                                                                                                |
| --------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `meals`         | id, name, venue_note, cuisine, estimated_price_minor (must be 0 or more)                                                                                               |
| `purchase_logs` | id, meal_id (foreign key to meals, ON DELETE CASCADE), purchased_at (yyyy-MM-dd), actual_price_minor (0 or more), note, status (`draft` or `final`), save_key (unique) |

Settings in SharedPreferences: `weekly_budget_minor`, `reminder_on`, and a small draft entry per meal for an unfinished purchase.

## Known issues

- The daily reminder works, and the test notification was successfully received on an Android phone while offline. Currently, users cannot choose a specific reminder time.
- The app supports Android devices but does not support Chrome or other web platforms because it uses SQLite through sqflite.
- Lunch Lens requires at least three saved purchases for a meal to generate an estimate. Unusually high or low purchase prices can affect the calculated average.
- Daily reminder delivery may be affected by battery optimization settings on some Android devices.

## Testing and Validation

The application was tested on a physical Android phone in airplane mode to verify offline functionality.

Manual testing covered:

- Meal creation, editing, deletion, and input validation
- Purchase saving and duplicate prevention
- History filtering and summary calculations
- Weekly budget settings
- Lunch Lens estimation
- Draft restoration and data persistence after restart
- Cascade deletion and cancellation
- CSV export
- Local reminder notifications

Automated widget and integration tests are also included in the project.

Manual test results are documented in the Offline and Restart Test Checklist.

## Future enhancements

- Choose the reminder time.
- Show spending by cuisine as a chart.
- Import a CSV back into the app.
- Compare Lunch Lens with other windows or a median estimate.

## License

This project was developed by Suma Enjam and Tejaswini Kolliboni as part of the Mobile Application Development course at Georgia State University.

Copyright © 2026 Suma Enjam and Tejaswini Kolliboni. All rights reserved.
