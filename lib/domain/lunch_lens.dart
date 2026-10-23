import '../core/money.dart';
import '../data/models.dart';

class LensResult {
  final int? estimateMinor;
  final List<int> usedMinor; // newest first
  final String? fromDate;
  final String? toDate;
  final int? baselineMinor; // last price

  const LensResult({
    this.estimateMinor,
    this.usedMinor = const [],
    this.fromDate,
    this.toDate,
    this.baselineMinor,
  });

  bool get hasEstimate => estimateMinor != null;

  String get explanation => hasEstimate
      ? 'Mean of your last ${usedMinor.length} purchases '
          '(${usedMinor.map(formatMinor).join(', ')}), $fromDate to $toDate. '
          'Suggested, not guaranteed.'
      : 'Not enough history';
}

/// Rule-based estimate: mean of the last 3 earlier final purchases.
/// [beforeDate] (yyyy-MM-dd) keeps a purchase from predicting itself.
LensResult estimateNextCost(List<PurchaseLog> history, {String? beforeDate}) {
  final valid = history
      .where((p) =>
          p.status == 'final' &&
          p.actualPriceMinor >= 0 &&
          (beforeDate == null || p.purchasedAt.compareTo(beforeDate) < 0))
      .toList()
    ..sort((a, b) {
      final c = b.purchasedAt.compareTo(a.purchasedAt);
      return c != 0 ? c : (b.id ?? 0).compareTo(a.id ?? 0); // tie: log id
    });

  final baseline = valid.isEmpty ? null : valid.first.actualPriceMinor;
  if (valid.length < 3) return LensResult(baselineMinor: baseline);

  final last3 = valid.take(3).toList();
  final sum = last3.fold<int>(0, (s, p) => s + p.actualPriceMinor);
  final mean = (2 * sum + 3) ~/ 6; // round to nearest, halves up
  return LensResult(
    estimateMinor: mean,
    usedMinor: last3.map((p) => p.actualPriceMinor).toList(),
    fromDate: last3.last.purchasedAt,
    toDate: last3.first.purchasedAt,
    baselineMinor: baseline,
  );
}