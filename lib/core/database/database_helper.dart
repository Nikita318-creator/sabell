import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_cache.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    String dbPath;

    // 👈 Выбираем правильную директорию в зависимости от платформы
    if (Platform.isIOS) {
      final libraryDir = await getApplicationSupportDirectory();
      dbPath = libraryDir.path;
    } else {
      dbPath = await getDatabasesPath();
    }

    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        imageUrl TEXT
      )
    ''');
  }
}
