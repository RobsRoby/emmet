import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:typed_data';
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
        version: 2, // Increment the version number to reflect schema change
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
        cameraResolution TEXT DEFAULT 'medium',
        GeminiApiKey TEXT
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

    // Create 'generatedSets' table for storing generated sets
    await db.execute('''
      CREATE TABLE generatedSets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        set_num TEXT,
        img_data BLOB,
        set_name TEXT,
        ldr_model TEXT
      )
    ''');

    // Insert default settings values
    await db.insert('settings', {
      'iouThreshold': 0.5,
      'confThreshold': 0.5,
      'classThreshold': 0.5,
      'cameraResolution': 'medium',
      'GeminiApiKey': ''
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

  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "user_database.sqlite");
    await io.File(path).delete();
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

  // Fetch all captures
  Future<List<Map<String, dynamic>>> fetchAllCaptures() async {
    final db = await database;

    // Fetch captures
    List<Map<String, dynamic>> captures = await db.query('captures');

    // Fetch generated sets and convert BLOB to URL
    List<Map<String, dynamic>> generatedSets = await db.query('generatedSets');
    List<Map<String, dynamic>> convertedGeneratedSets = generatedSets.map((set) {
      Uint8List imgData = getImageDataFromGeneratedSet(set);

      // Update the set with the in-memory image data (as Uint8List)
      return {
        'id': set['id'],
        'set_num': set['set_num'],
        'img_data': imgData,
        'set_name': set['set_name'],
      };
    }).toList();
    return await captures + convertedGeneratedSets;
  }

  // Delete a capture
  Future<void> deleteCapture(String set_num, bool isGeneratedSet) async {
    final db = await database;

    if (isGeneratedSet) {
      await db.delete(
        'generatedSets',
        where: 'set_num = ?',
        whereArgs: [set_num],
      );
    } else {
      await db.delete(
        'captures',
        where: 'set_num = ?',
        whereArgs: [set_num],
      );
    }
  }

  // Convert your image to Uint8List (byte array)
  Future<void> saveGeneratedSet(String setNum, Uint8List imgData, String setName, String ldrModel) async {
    final db = await database;
    await db.insert('generatedSets', {
      'set_num': setNum,
      'img_data': imgData,
      'set_name': setName,
      'ldr_model': ldrModel
    });
  }

  // Fetch all generated sets
  Future<List<Map<String, dynamic>>> fetchAllGeneratedSets() async {
    final db = await database;
    return await db.query('generatedSets');
  }

  // Convert BLOB back to image data
  Uint8List getImageDataFromGeneratedSet(Map<String, dynamic> generatedSet) {
    return generatedSet['img_data'] as Uint8List; // Convert to Uint8List
  }

}

