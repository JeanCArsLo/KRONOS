import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'auth_service.dart';

class RegisterController extends ChangeNotifier {
  // === CONTROLADORES ===
  final emailController = TextEditingController();
  final fullNameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final otpController = TextEditingController();

  // === ESTADOS ===
  int currentStep = 1;
  String? generatedOtp;
  bool isLoading = false;
  int resendTimer = 0;

  // === FORMULARIO ===
  DateTime? selectedDate;
  String selectedGender = 'M';

  // === CONTRASEÑA ===
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool hasMinLength = false;
  bool hasUppercase = false;
  bool hasNumber = false;
  bool hasSpecialChar = false;
  bool notOnlyNumbers = true;

  // === SERVICIO ===
  final AuthService _authService = AuthService();

  // === GMAIL ===
  final String _gmailEmail = 'jeanflores831@gmail.com';
  final String _gmailAppPassword = 'jwbh fotp ejjv lazk';

  // === CONTROL DE TIMER ===
  bool _isDisposed = false; // ← AÑADIDO

  RegisterController() {
    passwordController.addListener(_updatePasswordValidation);
  }

  void _updatePasswordValidation() {
    final p = passwordController.text;
    hasMinLength = p.length >= 8;
    hasUppercase = p.contains(RegExp(r'[A-Z]'));
    hasNumber = p.contains(RegExp(r'[0-9]'));
    hasSpecialChar = p.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
    notOnlyNumbers = !RegExp(r'^\d+$').hasMatch(p);
    notifyListeners();
  }

  bool get isPasswordValid =>
      hasMinLength && hasUppercase && hasNumber && hasSpecialChar && notOnlyNumbers;

  // === ENVIAR OTP ===
  Future<String?> sendOtp() async {
    final email = emailController.text.trim();
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Ingresa un correo válido';
    }

    isLoading = true;
    notifyListeners();

    try {
      generatedOtp = (100000 + DateTime.now().millisecondsSinceEpoch % 900000).toString();

      final smtpServer = gmail(_gmailEmail, _gmailAppPassword);
      final message = Message()
        ..from = Address(_gmailEmail, 'Kronos App')
        ..recipients.add(email)
        ..subject = 'Tu código de verificación - Kronos'
        ..html = '''
          <div style="font-family: Arial, sans-serif; text-align: center; padding: 20px;">
            <h2 style="color: #003D82;">¡Hola!</h2>
            <p>Tu código de verificación es:</p>
            <h1 style="font-size: 36px; letter-spacing: 10px; color: #FF8C42; font-weight: bold;">
              $generatedOtp
            </h1>
            <p style="color: #666;">Expira en 5 minutos.</p>
          </div>
        ''';

      await send(message, smtpServer);

      currentStep = 2;
      resendTimer = 60;
      _startResendTimer(); // ← Timer seguro
      return null;
    } catch (e) {
      return 'Error al enviar: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _startResendTimer() {
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

  // === VERIFICAR OTP ===
  String? verifyOtp() {
    final code = otpController.text.trim();
    if (code.length != 6) return 'Ingresa un código de 6 dígitos';
    if (code != generatedOtp) return 'Código incorrecto';
    currentStep = 3;
    notifyListeners();
    return null;
  }

  // === SELECCIONAR FECHA ===
  void selectDate(DateTime? date) {
    selectedDate = date;
    notifyListeners();
  }

  // === REGISTRO FINAL ===
  Future<String?> register(BuildContext context) async {
    final email = emailController.text.trim();
    final fullName = fullNameController.text.trim();
    final password = passwordController.text;
    final confirm = confirmPasswordController.text;

    if (fullName.isEmpty) return 'Ingresa tu nombre completo';
    if (selectedDate == null) return 'Selecciona tu fecha de nacimiento';
    if (!isPasswordValid) return 'La contraseña no cumple los requisitos';
    if (password != confirm) return 'Las contraseñas no coinciden';

    isLoading = true;
    notifyListeners();

    try {
      await _authService.register(
        email: email,
        fullName: fullName,
        password: password,
        birthDate: selectedDate!,
        gender: selectedGender,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Cuenta creada!'), backgroundColor: Colors.green),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // === UTILIDADES ===
  void setGender(String gender) {
    selectedGender = gender;
    notifyListeners();
  }

  void togglePassword() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPassword() {
    obscureConfirmPassword = !obscureConfirmPassword;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true; // ← DETENER TIMER
    emailController.dispose();
    fullNameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    otpController.dispose();
    super.dispose();
  }
}