// services/login_block_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class LoginBlockService {
  static const String _attemptsKey = 'login_failed_attempts';
  static const String _blockTimeKey = 'login_block_time';
  static const int maxAttempts = 3;
  static const int blockDurationMinutes = 1;

  // === INTENTOS FALLIDOS (GLOBAL) ===
  Future<int> getFailedAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_attemptsKey) ?? 0;
  }

  Future<void> incrementFailedAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getFailedAttempts();
    if (current < maxAttempts) {
      await prefs.setInt(_attemptsKey, current + 1);
    }
  }

  Future<void> resetFailedAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_attemptsKey);
    await prefs.remove(_blockTimeKey);
  }

  // === BLOQUEO GLOBAL ===
  Future<bool> isBlocked() async {
    final prefs = await SharedPreferences.getInstance();
    final blockTime = prefs.getInt(_blockTimeKey);
    if (blockTime == null) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    final blockEnd = blockTime + (blockDurationMinutes * 60 * 1000);

    if (now < blockEnd) {
      return true;
    } else {
      await resetFailedAttempts();
      return false;
    }
  }

  Future<void> blockDevice() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_blockTimeKey, DateTime.now().millisecondsSinceEpoch);
    await prefs.setInt(_attemptsKey, maxAttempts);
  }

  // === TIEMPO RESTANTE ===
  Future<String> getRemainingTime() async {
    final prefs = await SharedPreferences.getInstance();
    final blockTime = prefs.getInt(_blockTimeKey);
    if (blockTime == null) return '';

    final now = DateTime.now().millisecondsSinceEpoch;
    final blockEnd = blockTime + (blockDurationMinutes * 60 * 1000);
    final remaining = blockEnd - now;

    if (remaining <= 0) return '0:00';

    final minutes = (remaining / 60000).floor();
    final seconds = ((remaining % 60000) / 1000).floor();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}