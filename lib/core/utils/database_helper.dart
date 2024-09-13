import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "rebrickable.sqlite");

    if (await io.File(path).exists()) {
      return await openDatabase(path);
    } else {
      ByteData data = await rootBundle.load("assets/database/rebrickable.sqlite");
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await io.File(path).writeAsBytes(bytes);
      return await openDatabase(path);
    }
  }

  Future<List<Map<String, dynamic>>> fetchSetsByParts(List<String> recognizedTags) async {
    final db = await database;

    String query = '''
      SELECT si.set_num, si.name, si.img_url, COUNT(p.part_num) AS recognized_part_count
      FROM sets s
      JOIN setInfo si ON s.set_num = si.set_num
      JOIN partsInfo p ON s.partsInfo_id = p.partsInfo_id
      WHERE p.part_num IN (${recognizedTags.map((_) => '?').join(',')})
      GROUP BY si.set_num
      ORDER BY recognized_part_count DESC
    ''';

    return await db.rawQuery(query, recognizedTags);
  }

}
