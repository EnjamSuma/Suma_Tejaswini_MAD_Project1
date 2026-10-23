import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:budget_bites/data/app_database.dart';
import 'package:budget_bites/data/meal_repository.dart';
import 'package:budget_bites/data/models.dart';
import 'package:budget_bites/data/purchase_repository.dart';
import 'package:budget_bites/state/purchases_notifier.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  setUp(() async {
    await AppDatabase.instance.close();
    AppDatabase.instance.testPath = inMemoryDatabasePath;
  });

  test('notifier ignores a second tap while saving', () async {
    final repo = PurchaseRepository();
    final notifier = PurchasesNotifier(repo);
    final mealId = await MealRepository().insert(const Meal(
        name: 'Chicken Bowl', cuisine: 'Asian', estimatedPriceMinor: 750));
    final log = PurchaseLog(
        mealId: mealId,
        purchasedAt: '2026-10-23',
        actualPriceMinor: 450,
        saveKey: 'tap');
    final results = await Future.wait([notifier.add(log), notifier.add(log)]);
    expect(results, [true, false]);
    expect((await repo.forMeal(mealId)).length, 1);
  });
}