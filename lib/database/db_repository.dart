import 'package:baby_flash_apps/core/constants/app_language.dart';
import 'package:baby_flash_apps/database/db_services.dart';
import 'package:sqflite/sqlite_api.dart';

class DbRepository {
  /// Get database instance
  Future<Database> get _db async => await DatabaseService.database;

  // Fetch Data
  Future<List<Map<String, dynamic>>> fetchData({
    required String tableName,
    String? category,
    bool random = false,
    int limit = 0,
  }) async {
    final db = await _db;
    String sqlQuery = 'SELECT * FROM $tableName';
    List<dynamic> params = [];

    if (category != null) {
      sqlQuery += ' WHERE Category = ?';
      params.add(category);
    }

    if (random) {
      sqlQuery += ' ORDER BY RANDOM()';
    }

    if (limit > 0) {
      sqlQuery += ' LIMIT ?';
      params.add(limit);
    }

    final result = await db.rawQuery(sqlQuery, params);
    return result.map(_normalizeRow).toList();
  }

  Future<Map<String, int>> getCategoryCounts({
    required String tableName,
  }) async {
    final db = await _db;

    final result = await db.rawQuery('''
    SELECT Category as category, COUNT(*) as count
    FROM $tableName
    GROUP BY Category
  ''');

    return {
      for (var row in result)
        row['category'] as String: (row['count'] as int),
    };
  }

  Future<Map<String, dynamic>?> getSingleData({
    required String tableName,
    required String whereClause,
    required List<dynamic> whereArgs,
  }) async {
    final db = await _db;

    final result = await db.query(
      tableName,
      where: whereClause,
      whereArgs: whereArgs,
      limit: 1,
    );

    if (result.isNotEmpty) {
      return _normalizeRow(result.first);
    }
    return null;
  }

  Map<String, dynamic> _normalizeRow(Map<String, dynamic> row) {
    final lower = <String, dynamic>{
      for (final entry in row.entries) entry.key.toLowerCase(): entry.value,
    };

    dynamic pick(List<String> keys) {
      for (final key in keys) {
        if (lower[key.toLowerCase()] != null) {
          return lower[key.toLowerCase()];
        }
      }
      return null;
    }

    return {
      ...row,
      'title': pick(['title']),
      'category': pick(['category']),
      'image': pick(['image']),
      'sound': pick(['sound']),
      'actualsound': pick(['actualsound']),
      'word': pick(['word', 'lenguagetext']),
      'language_name':
          pick(['language_name']) ?? AppLanguageConfig.soundFolder,
    };
  }
}
