String ymd(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class DateRange {
  final String from; // inclusive
  final String to; // exclusive
  const DateRange(this.from, this.to);
}

const periods = ['This week', 'This month', 'All time'];

DateRange periodRange(String period, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  switch (period) {
    case 'This week':
      final start = today.subtract(Duration(days: today.weekday - 1));
      return DateRange(ymd(start), ymd(start.add(const Duration(days: 7))));
    case 'This month':
      return DateRange(ymd(DateTime(now.year, now.month, 1)),
          ymd(DateTime(now.year, now.month + 1, 1)));
    default:
      return const DateRange('0000-01-01', '9999-12-31');
  }
}