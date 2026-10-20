import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;
  String? testPath; // set to inMemoryDatabasePath in tests

  Future<Database> get db async => _db ??= await _open();

  Future<Database> _open() async {
    final path = testPath ?? join(await getDatabasesPath(), 'budget_bites.db');
    return openDatabase(
      path,
      version: 1,
      onConfigure: (d) async => d.execute('PRAGMA foreign_keys = ON'),
      onCreate: (d, v) async {
        await d.execute('''
          CREATE TABLE meals(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            venue_note TEXT NOT NULL DEFAULT '',
            cuisine TEXT NOT NULL,
            estimated_price_minor INTEGER NOT NULL
              CHECK(estimated_price_minor >= 0)
          )''');
        await d.execute('''
          CREATE TABLE purchase_logs(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            meal_id INTEGER NOT NULL,
            purchased_at TEXT NOT NULL,
            actual_price_minor INTEGER NOT NULL
              CHECK(actual_price_minor >= 0),
            note TEXT NOT NULL DEFAULT '',
            status TEXT NOT NULL DEFAULT 'final',
            save_key TEXT NOT NULL UNIQUE,
            FOREIGN KEY(meal_id) REFERENCES meals(id) ON DELETE CASCADE
          )''');
      },
    );
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}