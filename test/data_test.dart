import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:budget_bites/data/app_database.dart';
import 'package:budget_bites/data/meal_repository.dart';
import 'package:budget_bites/data/models.dart';
import 'package:budget_bites/data/purchase_repository.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final meals = MealRepository();
  final buys = PurchaseRepository();

  setUp(() async {
    await AppDatabase.instance.close();
    AppDatabase.instance.testPath = inMemoryDatabasePath;
  });

  Future<int> addMeal() => meals.insert(const Meal(
      name: 'Chicken Bowl', cuisine: 'Asian', estimatedPriceMinor: 750));

  PurchaseLog log(int mealId, int price, String key) => PurchaseLog(
      mealId: mealId,
      purchasedAt: '2026-10-20',
      actualPriceMinor: price,
      saveKey: key);

  test('totals: 450 + 600 = 1050, edit to 550 = 1000, delete first = 550',
      () async {
    final m = await addMeal();
    final a = await buys.insert(log(m, 450, 'k1'));
    final b = await buys.insert(log(m, 600, 'k2'));
    Future<int> total() =>
        buys.totalFinal(from: '2026-10-19', to: '2026-10-26');
    expect(await total(), 1050);
    await buys.update(PurchaseLog(
        id: b, mealId: m, purchasedAt: '2026-10-20',
        actualPriceMinor: 550, saveKey: 'k2'));
    expect(await total(), 1000);
    await buys.delete(a);
    expect(await total(), 550);
  });

  test('double save records exactly one row', () async {
    final m = await addMeal();
    await buys.insert(log(m, 450, 'same'));
    await buys.insert(log(m, 450, 'same'));
    expect((await buys.forMeal(m)).length, 1);
  });

  test('deleting a meal cascades to its purchases', () async {
    final m = await addMeal();
    await buys.insert(log(m, 450, 'k1'));
    expect(await meals.countLogs(m), 1);
    await meals.delete(m);
    expect((await buys.forMeal(m)).length, 0);
  });
}