import 'package:sqflite/sqflite.dart';
import 'app_database.dart';
import 'models.dart';

class MealRepository {
  Future<Database> get _db => AppDatabase.instance.db;

  Future<int> insert(Meal m) async =>
      (await _db).insert('meals', m.toMap()..remove('id'));

  Future<List<Meal>> getAll({String? cuisine}) async {
    final all = cuisine == null || cuisine == 'All';
    final rows = await (await _db).query(
      'meals',
      where: all ? null : 'cuisine = ?',
      whereArgs: all ? null : [cuisine],
      orderBy: 'name',
    );
    return rows.map(Meal.fromMap).toList();
  }

  Future<int> update(Meal m) async => (await _db)
      .update('meals', m.toMap(), where: 'id = ?', whereArgs: [m.id]);

  /// Used by the delete dialog: "This also deletes N purchases".
  Future<int> countLogs(int mealId) async {
    final r = await (await _db).rawQuery(
        'SELECT COUNT(*) FROM purchase_logs WHERE meal_id = ?', [mealId]);
    return Sqflite.firstIntValue(r) ?? 0;
  }

  Future<int> delete(int id) async =>
      (await _db).delete('meals', where: 'id = ?', whereArgs: [id]);
}