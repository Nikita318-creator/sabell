import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_sabel/features/audio_photo_feature/models/media_item_model.dart';

abstract class MediaRepository {
  Future<List<MediaItemModel>> getMediaFiles();
  Future<MediaItemModel> saveMedia({
    required File tempFile,
    required MediaType type,
  });
}

class MediaRepositoryImpl implements MediaRepository {
  Database? _db;

  Future<Database> get _database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final String dbFolderPath = Platform.isIOS
        ? (await getApplicationSupportDirectory()).path
        : await getDatabasesPath();

    final path = p.join(dbFolderPath, 'media_vault.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE media (
            id TEXT PRIMARY KEY,
            file_path TEXT NOT NULL,
            type TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  @override
  Future<List<MediaItemModel>> getMediaFiles() async {
    final db = await _database;
    final maps = await db.query('media', orderBy: 'created_at DESC');

    // Получаем АКТУАЛЬНУЮ директорию текущего сеанса iOS Sandbox
    final appDir = await getApplicationSupportDirectory();
    final mediaDirPath = p.join(appDir.path, 'permanet_media');

    return maps.map((map) {
      // Достаем имя файла из сохраненного значение в БД
      final fileName = p.basename(map['file_path'] as String);

      // Склеиваем актуальный путь
      final actualPath = p.join(mediaDirPath, fileName);

      return MediaItemModel(
        id: map['id'] as String,
        filePath: actualPath,
        type: MediaType.values.byName(map['type'] as String),
        createdAt: DateTime.parse(map['created_at'] as String),
      );
    }).toList();
  }

  @override
  Future<MediaItemModel> saveMedia({
    required File tempFile,
    required MediaType type,
  }) async {
    final appDir = await getApplicationSupportDirectory();
    final mediaDir = Directory(p.join(appDir.path, 'permanet_media'));
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }

    final String ext = p.extension(tempFile.path);
    final String newFileName = '${DateTime.now().millisecondsSinceEpoch}$ext';
    final String permanentPath = p.join(mediaDir.path, newFileName);

    // Копируем из temporary в долговременную папку
    final savedFile = await tempFile.copy(permanentPath);

    final item = MediaItemModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      filePath: savedFile.path,
      type: type,
      createdAt: DateTime.now(),
    );

    final db = await _database;

    // В базу пишем ТОЛЬКО имя файла (без UUID симулятора)
    final dbMap = item.toMap();
    dbMap['file_path'] = newFileName;

    await db.insert('media', dbMap);

    return item;
  }
}
