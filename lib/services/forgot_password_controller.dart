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
  DateTime? otpGeneratedAt; // ← NUEVO: para expiración real
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
  bool _isDisposed = false;

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
      hasMinLength &&
      hasUppercase &&
      hasNumber &&
      hasSpecialChar &&
      notOnlyNumbers;

  // === PASO 1: ENVIAR CÓDIGO ===
  Future<String?> sendCode() async {
    final email = emailController.text.trim();

    // Validar formato de correo
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Ingresa un correo válido';
    }

    isLoading = true;
    notifyListeners();

    try {
      // COMPROBAR SI EL CORREO SÍ EXISTE
      final userExists = await _authService.userExists(email);
      if (!userExists) {
        isLoading = false;
        notifyListeners();
        return 'Este correo no está registrado';
      }

      // Invalidar OTP anterior (por si se reenvía)
      generatedOtp = null;
      otpGeneratedAt = null;

      // Generar nuevo OTP
      generatedOtp = (100000 + DateTime.now().millisecondsSinceEpoch % 900000)
          .toString();
      otpGeneratedAt = DateTime.now(); // ← GUARDAR MOMENTO DE GENERACIÓN

      // Enviar por Gmail
      final smtpServer = gmail(_gmailEmail, _gmailAppPassword);
      final message = Message()
        ..from = Address(_gmailEmail, 'Kronos')
        ..recipients.add(email)
        ..subject = 'Código para cambiar contraseña'
        ..html =
            '''
          <div style="font-family: Arial, sans-serif; text-align: center; padding: 20px;">
            <h2 style="color: #003D82;">¡Hola!</h2>
            <p>Tu código para cambiar la contraseña es:</p>
            <h1 style="color: #FF8C42; font-size: 36px; letter-spacing: 10px; font-weight: bold;">
              $generatedOtp
            </h1>
            <p style="color: #666;">Expira en 5 minutos.</p>
          </div>
        ''';

      await send(message, smtpServer);

      currentStep = 2;
      resendTimer = 60;
      _startTimer();
      return null;
    } catch (e) {
      return 'Error al enviar: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _startTimer() {
    Future.doWhile(() async {
      if (_isDisposed) return false;
      await Future.delayed(const Duration(seconds: 1));
      if (resendTimer > 0) {
        resendTimer--;
        notifyListeners();
        return true;
      }
      return false;
    });
  }

  // === PASO 2: VERIFICAR CÓDIGO (CON EXPIRACIÓN REAL) ===
  String? verifyCode() {
    final code = otpController.text.trim();

    if (code.length != 6) {
      return 'Ingresa un código de 6 dígitos';
    }
    if (code != generatedOtp) {
      return 'Código incorrecto';
    }

    // VERIFICAR EXPIRACIÓN
    if (otpGeneratedAt == null) return 'Código no generado';

    final now = DateTime.now();
    final difference = now.difference(otpGeneratedAt!);

    if (difference.inMinutes >= 5) {
      generatedOtp = null;
      otpGeneratedAt = null;
      notifyListeners();
      return 'Código expirado. Solicita uno nuevo';
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
      return 'Las contraseñas no coinciden';
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
      return 'Error al cambiar la contraseña';
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
    _isDisposed = true;
    emailController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
