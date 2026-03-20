// lib/database/db_helper.dart
// SQLite 数据库管理

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/period.dart';
import '../models/daily_log.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'period_tracker.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE periods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        start_date TEXT NOT NULL,
        end_date TEXT,
        cycle_length INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        flow_level INTEGER DEFAULT 0,
        symptoms TEXT DEFAULT '',
        moods TEXT DEFAULT '',
        note TEXT
      )
    ''');
  }

  // ---- 经期 CRUD ----

  Future<int> insertPeriod(Period period) async {
    final db = await database;
    return db.insert('periods', period.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Period>> getAllPeriods() async {
    final db = await database;
    final maps = await db.query('periods',
        orderBy: 'start_date DESC');
    return maps.map(Period.fromMap).toList();
  }

  Future<Period?> getActivePeriod() async {
    final db = await database;
    final maps = await db.query('periods',
        where: 'end_date IS NULL',
        orderBy: 'start_date DESC',
        limit: 1);
    if (maps.isEmpty) return null;
    return Period.fromMap(maps.first);
  }

  Future<void> updatePeriod(Period period) async {
    final db = await database;
    await db.update('periods', period.toMap(),
        where: 'id = ?', whereArgs: [period.id]);
  }

  Future<void> deletePeriod(int id) async {
    final db = await database;
    await db.delete('periods', where: 'id = ?', whereArgs: [id]);
  }

  // ---- 每日记录 CRUD ----

  Future<void> upsertDailyLog(DailyLog log) async {
    final db = await database;
    await db.insert('daily_logs', log.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<DailyLog?> getDailyLog(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().substring(0, 10);
    final maps = await db.query('daily_logs',
        where: 'date = ?', whereArgs: [dateStr]);
    if (maps.isEmpty) return null;
    return DailyLog.fromMap(maps.first);
  }

  Future<List<DailyLog>> getLogsInRange(
      DateTime start, DateTime end) async {
    final db = await database;
    final maps = await db.query(
      'daily_logs',
      where: 'date >= ? AND date <= ?',
      whereArgs: [
        start.toIso8601String().substring(0, 10),
        end.toIso8601String().substring(0, 10),
      ],
      orderBy: 'date DESC',
    );
    return maps.map(DailyLog.fromMap).toList();
  }
}
