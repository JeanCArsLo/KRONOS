// services/auth_service.dart
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

      final existingUser = await _dbHelper.getUserByEmail(email);
      if (existingUser != null) {
        throw Exception('El correo ya está registrado');
      }

      final user = User(
        id: 0,
        fullName: fullName,
        email: email,
        passwordHash: _hashPassword(password),
        birthDate: birthDate,
        gender: gender,
        photoPath: null, // ← FOTO INICIAL
      );

      final userId = await _dbHelper.insertUser(user);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('current_user_id', userId);
    } catch (e) {
      rethrow;
    }
  }

  // === LOGIN ===
  Future<User?> login(String email, String password) async {
    final user = await _dbHelper.getUserByEmail(email);
    if (user != null && user.passwordHash == _hashPassword(password)) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('current_user_id', user.id);
      return user;
    }
    return null;
  }

  // === OBTENER USUARIO ACTUAL (RECARGA FOTO Y NOMBRE) ===
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('current_user_id');
    if (userId == null) return null;

    return await _dbHelper.getUserById(userId);
  }

  // === ACTUALIZAR PERFIL (NOMBRE + FOTO) ===
  Future<void> updateProfile({
    required String newName,
    String? newPhotoPath,
  }) async {
    final currentUser = await getCurrentUser();
    if (currentUser == null) throw Exception('No hay sesión activa');

    final db = DatabaseHelper();

    if (newName.trim().isNotEmpty) {
      await db.updateUserName(currentUser.id, newName.trim());
    }

    if (newPhotoPath != null) {
      await db.updateUserPhoto(currentUser.id, newPhotoPath);
    }

    // SESIÓN SIGUE ACTIVA → NO TOCAMOS SharedPreferences
  }

  // === CERRAR SESIÓN ===
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_id');
  }

  // === VERIFICAR SESIÓN ===
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('current_user_id');
  }

  // === VERIFICAR SI EL CORREO EXISTE ===
  Future<bool> userExists(String email) async {
    final user = await _dbHelper.getUserByEmail(email);
    return user != null;
  }

  // === ACTUALIZAR CONTRASEÑA ===
  Future<void> updatePassword(String email, String newPassword) async {
    final hashed = _hashPassword(newPassword);
    await _dbHelper.updateUserPassword(email, hashed);
  }
}