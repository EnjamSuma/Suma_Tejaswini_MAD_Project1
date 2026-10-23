import 'package:flutter_test/flutter_test.dart';
import 'package:budget_bites/data/models.dart';
import 'package:budget_bites/domain/lunch_lens.dart';

PurchaseLog p(int id, int price, String date) => PurchaseLog(
    id: id, mealId: 1, purchasedAt: date, actualPriceMinor: price,
    saveKey: 'k$id');

void main() {
  test('450, 600, 750 gives 600', () {
    final r = estimateNextCost(
        [p(1, 450, '2026-10-01'), p(2, 600, '2026-10-02'), p(3, 750, '2026-10-03')]);
    expect(r.estimateMinor, 600);
  });

  test('error 50 vs last-price baseline error 100 when next is 650', () {
    final r = estimateNextCost(
        [p(1, 450, '2026-10-01'), p(2, 600, '2026-10-02'), p(3, 750, '2026-10-03')]);
    expect((r.estimateMinor! - 650).abs(), 50);
    expect((r.baselineMinor! - 650).abs(), 100);
  });

  test('changing the last input to 900 gives 650', () {
    final r = estimateNextCost(
        [p(1, 450, '2026-10-01'), p(2, 600, '2026-10-02'), p(3, 900, '2026-10-03')]);
    expect(r.estimateMinor, 650);
  });

  test('fewer than three purchases says not enough history', () {
    final r = estimateNextCost([p(1, 450, '2026-10-01'), p(2, 600, '2026-10-02')]);
    expect(r.hasEstimate, false);
    expect(r.explanation, 'Not enough history');
  });

  test('draft and negative amounts are ignored', () {
    final d = PurchaseLog(id: 9, mealId: 1, purchasedAt: '2026-10-04',
        actualPriceMinor: 9999, status: 'draft', saveKey: 'd');
    final r = estimateNextCost(
        [p(1, 450, '2026-10-01'), p(2, 600, '2026-10-02'), d]);
    expect(r.hasEstimate, false);
  });

  test('outlier drags the mean up (counterexample)', () {
    final r = estimateNextCost(
        [p(1, 450, '2026-10-01'), p(2, 450, '2026-10-02'), p(3, 1800, '2026-10-03')]);
    expect(r.estimateMinor, 900); // baseline says 1800; both miss a normal 450
  });
}