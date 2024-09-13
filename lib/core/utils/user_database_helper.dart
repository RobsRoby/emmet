import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;

class UserDatabaseHelper {
  static final UserDatabaseHelper _instance = UserDatabaseHelper._internal();
  factory UserDatabaseHelper() => _instance;

  UserDatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "user_database.sqlite");

    // Check if the database already exists
    if (await io.File(path).exists()) {
      return await openDatabase(path);
    } else {
      // Create a new database if it doesn't exist
      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create 'settings' table with default values
    await db.execute('''
      CREATE TABLE settings (
        iouThreshold REAL DEFAULT 0.5,
        confThreshold REAL DEFAULT 0.5,
        classThreshold REAL DEFAULT 0.5,
        cameraResolution TEXT DEFAULT 'medium'
      )
    ''');

    // Create 'captures' table with auto-incrementing 'id'
    await db.execute('''
      CREATE TABLE captures (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        set_num TEXT,
        img_url TEXT
      )
    ''');

    // Insert default settings values
    await db.insert('settings', {
      'iouThreshold': 0.5,
      'confThreshold': 0.5,
      'classThreshold': 0.5,
      'cameraResolution': 'medium'
    });
  }

  // Fetch the settings from the database
  Future<Map<String, dynamic>> getSettings() async {
    final db = await database;
    final settingsList = await db.query('settings', limit: 1);
    if (settingsList.isNotEmpty) {
      return settingsList.first;
    }
    return {}; // Return an empty map if no settings are found
  }

  // Update the settings in the database
  Future<int> updateSettings(Map<String, dynamic> settings) async {
    final db = await database;
    return await db.update('settings', settings);
  }

  // Check if a set already exists in the 'captures' table
  Future<bool> doesSetExist(String setNum) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'captures',
      where: 'set_num = ?',
      whereArgs: [setNum],
    );
    return results.isNotEmpty;
  }

  // Insert a new capture into the 'captures' table
  Future<void> saveSet(String setNum, String imgUrl) async {
    final db = await database;
    await db.insert('captures', {'set_num': setNum, 'img_url': imgUrl});
  }

  // To fetch all captures
  Future<List<Map<String, dynamic>>> fetchAllCaptures() async {
    final db = await database;
    return await db.query('captures'); // Retrieve all entries from the 'captures' table
  }

// To Delete a capture
  Future<void> deleteCapture(int id) async {
    final db = await database;
    await db.delete(
      'captures',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

}
