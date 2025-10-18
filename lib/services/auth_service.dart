import 'dart:convert';  // 🔥 AGREGADO
import 'package:crypto/crypto.dart';  // 🔥 AGREGADO
import '../db/database_helper.dart';
import '../models/user.dart';

class AuthService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // 🔥 HASH CONTRASEÑA (NUEVO)
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> register({
    required String email,
    required String fullName,
    required String password,
  }) async {
    try {
      if (email.isEmpty || fullName.isEmpty || password.isEmpty) {
        throw Exception('Completa todos los campos');
      }
      if (password.length < 8) {
        throw Exception('Contraseña debe tener mínimo 8 caracteres');
      }

      final existingUser = await _dbHelper.getUserByEmail(email);
      if (existingUser != null) {
        throw Exception('El email ya está registrado');
      }

      final existingName = await _dbHelper.getUserByFullName(fullName);
      if (existingName != null) {
        throw Exception('El nombre ya está registrado');
      }

      await _dbHelper.registerUser(fullName, password, email);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  // 🔥 LOGIN CON EMAIL (FIX)
  Future<User?> login(String email, String password) async {
    String passwordHash = _hashPassword(password);
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND passwordHash = ?',
      whereArgs: [email, passwordHash],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getCurrentUser() async {
    return null;
  }
}