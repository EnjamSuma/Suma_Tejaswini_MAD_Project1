import 'package:sqflite/sqflite.dart';
import 'app_database.dart';
import 'models.dart';

class PurchaseRepository {
  Future<Database> get _db => AppDatabase.instance.db;

  /// Saving twice with the same saveKey records one row only.
  Future<int> insert(PurchaseLog p) async {
    final db = await _db;
    await db.insert('purchase_logs', p.toMap()..remove('id'),
        conflictAlgorithm: ConflictAlgorithm.ignore);
    final r = await db.query('purchase_logs',
        columns: ['id'],
        where: 'save_key = ?',
        whereArgs: [p.saveKey],
        limit: 1);
    return r.first['id'] as int;
  }

  Future<int> update(PurchaseLog p) async => (await _db).update(
      'purchase_logs', p.toMap(),
      where: 'id = ?', whereArgs: [p.id]);

  Future<int> delete(int id) async =>
      (await _db).delete('purchase_logs', where: 'id = ?', whereArgs: [id]);

  Future<List<PurchaseLog>> forMeal(int mealId) async {
    final rows = await (await _db).query('purchase_logs',
        where: 'meal_id = ?',
        whereArgs: [mealId],
        orderBy: 'purchased_at DESC, id DESC');
    return rows.map(PurchaseLog.fromMap).toList();
  }
  Future<List<PurchaseLog>> inRange(
      {required String from, required String to}) async {
    final rows = await (await _db).query('purchase_logs',
        where: "status = 'final' AND purchased_at >= ? AND purchased_at < ?",
        whereArgs: [from, to],
        orderBy: 'purchased_at DESC, id DESC');
    return rows.map(PurchaseLog.fromMap).toList();
  }

  /// Total of final purchases from [from] (inclusive) to [to] (exclusive).
  Future<int> totalFinal({required String from, required String to}) async {
    final r = await (await _db).rawQuery('''
      SELECT COALESCE(SUM(actual_price_minor), 0) AS t
      FROM purchase_logs
      WHERE status = 'final' AND purchased_at >= ? AND purchased_at < ?
      ''', [from, to]);
    return (r.first['t'] as int?) ?? 0;
  }
}