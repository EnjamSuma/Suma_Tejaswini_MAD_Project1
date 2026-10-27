import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'meal_repository.dart';
import 'purchase_repository.dart';

String _cell(String v) =>
    (v.contains(',') || v.contains('"') || v.contains('\n'))
        ? '"${v.replaceAll('"', '""')}"'
        : v;

String buildCsv(List<List<String>> rows) =>
    rows.map((r) => r.map(_cell).join(',')).join('\n');

/// Returns the saved file path. Throws if writing fails.
Future<String> exportPurchasesCsv(
    MealRepository meals, PurchaseRepository buys) async {
  final names = {for (final m in await meals.getAll()) m.id: m.name};
  final logs = await buys.inRange(from: '0000-01-01', to: '9999-12-31');
  final rows = <List<String>>[
    ['date', 'meal', 'actual_price_usd'],
    for (final p in logs)
      [
        p.purchasedAt,
        names[p.mealId] ?? 'Unknown',
        (p.actualPriceMinor / 100).toStringAsFixed(2),
      ],
  ];
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/budget_bites_purchases.csv');
  await file.writeAsString(buildCsv(rows));
  return file.path;
}