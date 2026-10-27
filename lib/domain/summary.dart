/// Returns [total, count, average] in minor units.
/// Top-level so compute() can run it in a separate isolate.
List<int> summarize(List<int> prices) {
  final total = prices.fold<int>(0, (s, p) => s + p);
  final avg = prices.isEmpty ? 0 : total ~/ prices.length;
  return [total, prices.length, avg];
}