import 'package:flutter_test/flutter_test.dart';
import 'package:budget_bites/core/money.dart';

void main() {
  test('difference in words: under, over and on plan', () {
    expect(differenceWords(750, 650), 'Under plan by \$1.00');
    expect(differenceWords(750, 800), 'Over plan by \$0.50');
    expect(differenceWords(750, 750), 'On plan');
  });
}
