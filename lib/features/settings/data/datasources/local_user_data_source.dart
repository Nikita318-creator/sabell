import 'package:flutter_sabel/core/database/database_helper.dart';
import 'package:flutter_sabel/features/settings/data/models/test_user_model.dart';
import 'package:sqflite/sqflite.dart';

abstract class LocalUserDataSource {
  Future<List<User>> getUsersFromCache();
  Future<void> saveUsersToCache(List<User> users);
  Future<void> clearCache();
}

class LocalUserDataSourceImpl implements LocalUserDataSource {
  final DatabaseHelper dbHelper;

  LocalUserDataSourceImpl({DatabaseHelper? dbHelper})
    : dbHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<List<User>> getUsersFromCache() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('users');

    if (maps.isEmpty) return [];

    return maps.map((json) => User.fromJson(json)).toList();
  }

  @override
  Future<void> saveUsersToCache(List<User> users) async {
    final db = await dbHelper.database;

    // Используем Batch для атомарной записи списка за 1 транзакцию
    final batch = db.batch();
    for (var user in users) {
      batch.insert(
        'users',
        user.toMap(),
        conflictAlgorithm:
            ConflictAlgorithm.replace, // Перезапишет, если такой id есть
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> clearCache() async {
    final db = await dbHelper.database;
    await db.delete('users');
  }
}
