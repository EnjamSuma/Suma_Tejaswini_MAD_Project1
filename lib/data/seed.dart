import '../core/dates.dart';
import 'meal_repository.dart';
import 'models.dart';
import 'purchase_repository.dart';

Future<void> seedIfEmpty(MealRepository meals, PurchaseRepository buys) async {
  if ((await meals.getAll()).isNotEmpty) return;
  final bowl = await meals.insert(const Meal(
      name: 'Chicken Bowl', venueNote: 'Example: campus cafe',
      cuisine: 'Asian', estimatedPriceMinor: 750));
  final wrap = await meals.insert(const Meal(
      name: 'Veggie Wrap', venueNote: 'Example: food court',
      cuisine: 'American', estimatedPriceMinor: 500));
  final burrito = await meals.insert(const Meal(
      name: 'Bean Burrito', venueNote: 'Example: dining hall',
      cuisine: 'Mexican', estimatedPriceMinor: 325));
  final now = DateTime.now();
  Future<void> add(int mealId, int price, int daysAgo, String key) =>
      buys.insert(PurchaseLog(
          mealId: mealId,
          purchasedAt: ymd(now.subtract(Duration(days: daysAgo))),
          actualPriceMinor: price,
          saveKey: 'seed-$key'));
  await add(bowl, 450, 6, 'b1');
  await add(bowl, 600, 4, 'b2');
  await add(bowl, 750, 2, 'b3');
  await add(wrap, 500, 3, 'w1');
  await add(burrito, 325, 1, 'c1');
}