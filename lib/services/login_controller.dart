import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'login_block_service.dart';

class LoginController extends ChangeNotifier {
  // === CONTROLADORES ===
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // === ESTADOS ===
  bool obscurePassword = true;
  bool isLoading = false;
  String? blockedUntil;
  int attempts = 0;

  // === SERVICIOS ===
  final AuthService _authService = AuthService();
  final LoginBlockService _blockService = LoginBlockService();

  // === CONTROL DE TIMER ===
  bool _isDisposed = false; // ← AÑADIDO

  LoginController() {
    _checkBlockOnStart();
  }

  Future<void> _checkBlockOnStart() async {
    isLoading = true;
    notifyListeners();

    try {
      final blocked = await _blockService.isBlocked();
      if (blocked) {
        final time = await _blockService.getRemainingTime();
        blockedUntil = time;
        attempts = 3;
        _startTimer();
      } else {
        final attemptsCount = await _blockService.getFailedAttempts();
        attempts = attemptsCount;
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _startTimer() {
    Future.doWhile(() async {
      if (_isDisposed) return false; // ← DETENER SI SE CIERRA
      await Future.delayed(const Duration(seconds: 1));

      final blocked = await _blockService.isBlocked();
      if (!blocked) {
        blockedUntil = null;
        attempts = 0;
        await _blockService.resetFailedAttempts();
        notifyListeners();
        return false;
      }

      final time = await _blockService.getRemainingTime();
      blockedUntil = time;
      notifyListeners();
      return true;
    });
  }

  Future<String?> login(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      return 'Completa todos los campos';
    }

    isLoading = true;
    notifyListeners();

    try {
      final blocked = await _blockService.isBlocked();
      if (blocked) {
        final time = await _blockService.getRemainingTime();
        return 'Bloqueado. Espera $time';
      }

      final user = await _authService.login(email, password);
      if (user != null) {
        await _blockService.resetFailedAttempts();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Bienvenido!'),
              backgroundColor: Color(0xFF4CAF50),
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pushReplacementNamed(context, '/home');
        }
        return null;
      } else {
        final newAttempts = (await _blockService.getFailedAttempts()) + 1;
        await _blockService.incrementFailedAttempts();

        if (newAttempts >= 3) {
          await _blockService.blockDevice();
          final time = await _blockService.getRemainingTime();
          blockedUntil = time;
          attempts = 3;
          _startTimer();
          return 'Bloqueado por 15 minutos';
        } else {
          attempts = newAttempts;
          return 'Contraseña incorrecta. Intentos: $newAttempts/3';
        }
      }
    } catch (e) {
      return 'Error de conexión';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void togglePassword() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true; // ← DETENER TIMER
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}