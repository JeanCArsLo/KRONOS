import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'auth_service.dart';

class ForgotPasswordController extends ChangeNotifier {
  // === PASOS ===
  int currentStep = 1;

  // === CONTROLADORES ===
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // === ESTADO ===
  String? generatedOtp;
  bool isLoading = false;
  int resendTimer = 0;

  // === CONTRASEÑA ===
  bool obscureNew = true;
  bool obscureConfirm = true;
  bool hasMinLength = false;
  bool hasUppercase = false;
  bool hasNumber = false;
  bool hasSpecialChar = false;
  bool notOnlyNumbers = true;

  // === GMAIL ===
  final String _gmailEmail = 'jeanflores831@gmail.com';
  final String _gmailAppPassword = 'jwbh fotp ejjv lazk';

  // === SERVICIO ===
  final AuthService _authService = AuthService();

  // === CONTROL DE TIMER ===
  bool _isDisposed = false; // ← AÑADIDO

  ForgotPasswordController() {
    newPasswordController.addListener(_updateValidation);
  }

  void _updateValidation() {
    final p = newPasswordController.text;
    hasMinLength = p.length >= 8;
    hasUppercase = p.contains(RegExp(r'[A-Z]'));
    hasNumber = p.contains(RegExp(r'[0-9]'));
    hasSpecialChar = p.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
    notOnlyNumbers = !RegExp(r'^\d+$').hasMatch(p);
    notifyListeners();
  }

  bool get isPasswordValid =>
      hasMinLength && hasUppercase && hasNumber && hasSpecialChar && notOnlyNumbers;

  // === PASO 1: ENVIAR CÓDIGO ===
  Future<String?> sendCode() async {
    final email = emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      return 'Ingresa un correo válido';
    }

    isLoading = true;
    notifyListeners();

    try {
      final userExists = await _authService.userExists(email);
      if (!userExists) {
        return 'Este correo no está registrado';
      }

      generatedOtp = (100000 + DateTime.now().millisecondsSinceEpoch % 900000).toString();

      final smtpServer = gmail(_gmailEmail, _gmailAppPassword);
      final message = Message()
        ..from = Address(_gmailEmail, 'Kronos')
        ..recipients.add(email)
        ..subject = 'Código para cambiar contraseña'
        ..html = '''
          <h2>¡Hola!</h2>
          <p>Tu código para cambiar la contraseña es:</p>
          <h1 style="color: #FF8C42; font-size: 32px; letter-spacing: 8px;"><b>$generatedOtp</b></h1>
          <p>Expira en 5 minutos.</p>
        ''';

      await send(message, smtpServer);

      currentStep = 2;
      resendTimer = 60;
      _startTimer(); // ← Timer seguro
      return null;
    } catch (e) {
      return 'Error: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _startTimer() {
    Future.doWhile(() async {
      if (_isDisposed) return false; // ← DETENER SI SE CIERRA LA PANTALLA
      await Future.delayed(const Duration(seconds: 1));
      if (resendTimer > 0) {
        resendTimer--;
        notifyListeners();
        return true;
      }
      return false;
    });
  }

  // === PASO 2: VERIFICAR CÓDIGO ===
  String? verifyCode() {
    if (otpController.text.length != 6) {
      return 'Ingresa 6 dígitos';
    }
    if (otpController.text != generatedOtp) {
      return 'Código incorrecto';
    }
    currentStep = 3;
    notifyListeners();
    return null;
  }

  // === PASO 3: CAMBIAR CONTRASEÑA ===
  Future<String?> changePassword(BuildContext context) async {
    final newPass = newPasswordController.text;
    final confirm = confirmPasswordController.text;

    if (!isPasswordValid) {
      return 'Contraseña débil';
    }
    if (newPass != confirm) {
      return 'No coinciden';
    }

    isLoading = true;
    notifyListeners();

    try {
      await _authService.updatePassword(emailController.text.trim(), newPass);
      if (context.mounted) {
        Navigator.pop(context);
      }
      return null;
    } catch (e) {
      return 'Error al cambiar';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // === UTILIDADES ===
  void toggleNewPassword() {
    obscureNew = !obscureNew;
    notifyListeners();
  }

  void toggleConfirmPassword() {
    obscureConfirm = !obscureConfirm;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true; // ← DETENER TIMER
    emailController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}