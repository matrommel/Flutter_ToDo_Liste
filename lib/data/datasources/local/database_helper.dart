// Data Layer - SQLite Datenbank Helper

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('todo_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      throw UnsupportedError(
        'Die Web-Version wird derzeit nicht unterstützt. '
        'Bitte verwenden Sie die Mobile- oder Desktop-Version der App.'
      );
    }

    // Mobile/Desktop: Verwende sqflite
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 7,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  // Foreign Keys aktivieren (nur für Mobile/Desktop)
  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _createDB(Database db, int version) async {
    // Kategorien Tabelle
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        order_num INTEGER DEFAULT 0,
        icon_code INTEGER,
        is_protected INTEGER DEFAULT 0,
        parent_category_id INTEGER,
        FOREIGN KEY (parent_category_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');

    // Todo Items Tabelle
    await db.execute('''
      CREATE TABLE todo_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        count INTEGER DEFAULT 1,
        order_num INTEGER DEFAULT 0,
        original_order INTEGER,
        is_completed INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        completed_at INTEGER,
        description TEXT,
        links TEXT,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');

    // Indizes für bessere Performance
    await db.execute('''
      CREATE INDEX idx_todo_items_category_id ON todo_items(category_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_todo_items_is_completed ON todo_items(is_completed)
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE categories ADD COLUMN icon_code INTEGER');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE todo_items ADD COLUMN order_num INTEGER DEFAULT 0');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE categories ADD COLUMN is_protected INTEGER DEFAULT 0');
    }
    if (oldVersion < 5) {
      // Neue Spalten für Beschreibung und Links
      await db.execute('ALTER TABLE todo_items ADD COLUMN description TEXT');
      await db.execute('ALTER TABLE todo_items ADD COLUMN links TEXT'); // JSON Array als String
    }
    if (oldVersion < 6) {
      // Neue Spalte für Verschachtelung von Kategorien
      await db.execute('ALTER TABLE categories ADD COLUMN parent_category_id INTEGER');
      // Index für bessere Performance bei Hierarchie-Abfragen
      await db.execute('CREATE INDEX idx_categories_parent_id ON categories(parent_category_id)');
    }
    if (oldVersion < 7) {
      // Neue Spalte für ursprüngliche Position vor dem Abhaken
      await db.execute('ALTER TABLE todo_items ADD COLUMN original_order INTEGER');
    }
  }

  Future close() async {
    final db = await instance.database;
    await db.close();
  }
}
