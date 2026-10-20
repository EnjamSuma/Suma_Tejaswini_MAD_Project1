/// 750 -> "$7.50"
String formatMinor(int minor, {bool cents = true}) {
  final dollars = minor ~/ 100;
  final c = (minor % 100).toString().padLeft(2, '0');
  return cents ? '\$$dollars.$c' : '\$$dollars';
}

/// "7.5" -> 750, "abc" -> null, "-3" -> null
int? parseToMinor(String input) {
  final t = input.trim().replaceAll('\$', '');
  if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(t)) return null;
  final parts = t.split('.');
  final dollars = int.parse(parts[0]);
  final cents = parts.length == 2 ? int.parse(parts[1].padRight(2, '0')) : 0;
  return dollars * 100 + cents;
}