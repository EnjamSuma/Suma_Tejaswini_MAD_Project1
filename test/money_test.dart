import 'package:flutter_test/flutter_test.dart';
import 'package:budget_bites/core/money.dart';
import 'package:budget_bites/domain/summary.dart';

void main() {
  test('formatMinor formats 750 as \$7.50', () {
    expect(formatMinor(750), '\$7.50');
  });
  test('formatMinor pads cents', () {
    expect(formatMinor(5), '\$0.05');
  });
  test('parseToMinor accepts 7.5', () {
    expect(parseToMinor('7.5'), 750);
  });
  test('parseToMinor rejects text and negatives', () {
    expect(parseToMinor('abc'), isNull);
    expect(parseToMinor('-3'), isNull);
  });
  test('summarize of an empty list is zeros', () {
    expect(summarize([]), [0, 0, 0]);
  });
  test('summarize 450 + 600', () {
    expect(summarize([450, 600]), [1050, 2, 525]);
  });
}