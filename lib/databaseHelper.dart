import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class DatabaseHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE items(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      name TEXT,
      description TEXT,
      imageUrl TEXT,
      createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP  
    )
    """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'dbbook.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  static Future<int> createItem(String name, String? description, String? imageUrl) async {
    final db = await DatabaseHelper.db(); // Fix: Use fully qualified name

    final data = {'name': name, 'description': description, 'imageUrl': imageUrl};

    final id = await db.insert(
      'items',
      data,
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );
    return id;
  }

  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await DatabaseHelper.db();
    return db.query('items', orderBy: "id");
  }

  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await DatabaseHelper.db();
    return db.query('items', where: "id = ?", whereArgs: [id], limit: 1);
  }

  static Future<int> updateItem(int id, String name, String? description, String? imageUrl) async {
    final db = await DatabaseHelper.db(); // Fix: Use fully qualified name

    final data = {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': DateTime.now().toString(),
    };

    final result = await db.update('items', data, where: 'id = ?', whereArgs: [id]);
    return result;
  }

  static Future<void> deleteItem(int id) async {
    final db = await DatabaseHelper.db(); // Fix: Use fully qualified name
    try {
      await db.delete('items', where: 'id = ?', whereArgs: [id]);
    } catch (err) {
      debugPrint('Something went wrong when deleting an item: $err');
    }
  }
}
