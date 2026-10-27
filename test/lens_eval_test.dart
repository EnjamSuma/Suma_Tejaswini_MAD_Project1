import 'package:flutter_test/flutter_test.dart';
import 'package:budget_bites/data/models.dart';
import 'package:budget_bites/domain/lunch_lens.dart';

// These series were NOT used to choose the rule or the window of 3.
const heldOut = [
  [400, 450, 500, 600, 550, 500],
  [700, 650, 750, 700, 1500, 720], // contains an outlier on purpose
  [320, 300, 340, 310, 330, 350],
];

PurchaseLog p(int i, int price) => PurchaseLog(
    id: i,
    mealId: 1,
    purchasedAt: '2026-09-${(i + 1).toString().padLeft(2, '0')}',
    actualPriceMinor: price,
    saveKey: 'e$i');

void main() {
  test('held-out: Lunch Lens vs last-price baseline', () {
    var lensError = 0, baselineError = 0, cases = 0, lensCloser = 0;
    for (final s in heldOut) {
      for (var i = 3; i < s.length; i++) {
        final history = [for (var j = 0; j < i; j++) p(j, s[j])];
        final r = estimateNextCost(history); // only earlier purchases
        final e1 = (r.estimateMinor! - s[i]).abs();
        final e2 = (r.baselineMinor! - s[i]).abs();
        lensError += e1;
        baselineError += e2;
        cases++;
        if (e1 < e2) lensCloser++;
      }
    }
    expect(cases, greaterThanOrEqualTo(5));
    // ignore: avoid_print
    print('cases=$cases lensMAE=${lensError / cases} '
        'baselineMAE=${baselineError / cases} lensCloser=$lensCloser');
  });
}