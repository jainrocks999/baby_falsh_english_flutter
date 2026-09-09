import 'dart:io';
import 'package:baby_flash_apps/core/constants/app_language.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppLanguageConfig.databaseFileName);

    if (!await File(path).exists()) {
      ByteData data = await rootBundle.load(AppLanguageConfig.databaseAsset);

      List<int> bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      await File(path).writeAsBytes(bytes, flush: true);
    }
    return await openDatabase(path);
  }
}
