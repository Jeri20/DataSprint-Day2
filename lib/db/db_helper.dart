import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

import '../models/user.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> getDB() async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  static Future<Database> initDB() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Initialize FFI for desktop
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String path = join(await getDatabasesPath(), "users.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE,
            password TEXT
          )
        ''');
      },
    );
  }

  static Future<int> insertUser(User user) async {
    final db = await getDB();
    return await db.insert("users", user.toMap());
  }

  static Future<User?> getUser(String username, String password) async {
    final db = await getDB();
    final res = await db.query(
      "users",
      where: "username = ? AND password = ?",
      whereArgs: [username, password],
    );
    if (res.isNotEmpty) return User.fromMap(res.first);
    return null;
  }
}
