import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();
    String path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // 🔥 CREAR TABLA USERS
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL UNIQUE,
        passwordHash TEXT NOT NULL,
        email TEXT UNIQUE,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  // 🔐 HASH CONTRASEÑA
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // 🔥 REGISTRO
  Future<int> registerUser(String fullName, String password, [String? email]) async {
    final db = await database;
    return await db.insert('users', {
      'fullName': fullName,
      'passwordHash': _hashPassword(password),
      'email': email,
    });
  }

  // 🔥 LOGIN
  Future<User?> validateLogin(String fullName, String password) async {
    final db = await database;
    String passwordHash = _hashPassword(password);
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'fullName = ? AND passwordHash = ?',
      whereArgs: [fullName, passwordHash],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // 🔥 BUSCAR POR EMAIL
  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // 🔥 BUSCAR POR FULLNAME
  Future<User?> getUserByFullName(String fullName) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'fullName = ?',
      whereArgs: [fullName],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }
}