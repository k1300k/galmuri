import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../domain/entities/galmuri_item.dart';

/// Local SQLite Database
/// Implements Local First strategy
class LocalDatabase {
  static Database? _database;
  static const String _dbName = 'galmuri.db';
  static const int _dbVersion = 1;

  /// Initialize database
  static Future<void> init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    _database = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create database schema
  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE galmuri_items (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        image_data TEXT NOT NULL,
        source_url TEXT,
        page_title TEXT NOT NULL,
        memo_content TEXT NOT NULL,
        ocr_text TEXT NOT NULL,
        ocr_status TEXT NOT NULL,
        platform TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create indexes for performance
    await db.execute('''
      CREATE INDEX idx_user_id ON galmuri_items(user_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_is_synced ON galmuri_items(is_synced)
    ''');

    await db.execute('''
      CREATE INDEX idx_created_at ON galmuri_items(created_at DESC)
    ''');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
  }

  /// Get database instance
  static Database get database {
    if (_database == null) {
      throw Exception('Database not initialized. Call LocalDatabase.init() first.');
    }
    return _database!;
  }

  /// Close database
  static Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}


