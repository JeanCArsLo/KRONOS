// services/auth_service.dart
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../db/database_helper.dart';
import '../models/user.dart';

class AuthService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // === ENCRIPTAR CONTRASEÑA ===
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // === REGISTRO CON NUEVOS CAMPOS ===
  Future<void> register({
    required String email,
    required String fullName,
    required String password,
    required DateTime birthDate,
    required String gender,
  }) async {
    try {
      // === VALIDACIONES ===
      if (email.isEmpty || fullName.isEmpty || password.isEmpty) {
        throw Exception('Completa todos los campos');
      }
      if (!email.contains('@') || !email.contains('.')) {
        throw Exception('Ingresa un correo válido');
      }
      if (password.length < 8) {
        throw Exception('La contraseña debe tener al menos 8 caracteres');
      }
      if (birthDate.isAfter(DateTime.now())) {
        throw Exception('Fecha de nacimiento inválida');
      }
      if (DateTime.now().difference(birthDate).inDays < 13 * 365) {
        throw Exception('Debes tener al menos 13 años');
      }
      if (!['M', 'F'].contains(gender)) {
        throw Exception('Género debe ser M o F');
      }

      // === VERIFICAR DUPLICADOS ===
      final existingUser = await _dbHelper.getUserByEmail(email);
      if (existingUser != null) {
        throw Exception('El correo ya está registrado');
      }

      // === CREAR USUARIO CON HASH ===
      final user = User(
        id: 0,
        fullName: fullName,
        email: email,
        passwordHash: _hashPassword(password), // ← ENCRIPTADA
        birthDate: birthDate,
        gender: gender,
      );

      await _dbHelper.insertUser(user);
    } catch (e) {
      rethrow;
    }
  }

  // === LOGIN POR CORREO ===
  Future<User?> login(String email, String password) async {
    final user = await _dbHelper.getUserByEmail(email);
    if (user != null && user.passwordHash == _hashPassword(password)) {
      return user;
    }
    return null;
  }

  // === VERIFICAR SI EL CORREO EXISTE (PARA CAMBIO DE CONTRASEÑA) ===
  Future<bool> userExists(String email) async {
    final user = await _dbHelper.getUserByEmail(email);
    return user != null;
  }

  // === ACTUALIZAR CONTRASEÑA ===
  Future<void> updatePassword(String email, String newPassword) async {
    try {
      final user = await _dbHelper.getUserByEmail(email);
      if (user == null) {
        throw Exception('Usuario no encontrado');
      }

      final hashed = _hashPassword(newPassword);
      await _dbHelper.updateUserPassword(email, hashed);
    } catch (e) {
      rethrow;
    }
  }

  // === OBTENER USUARIO ACTUAL (FUTURO) ===
  Future<User?> getCurrentUser() async {
    return null; // Implementar con SharedPreferences
  }
}