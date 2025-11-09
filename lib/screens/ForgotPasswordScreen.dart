import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _currentStep = 1; // 1: correo, 2: código, 3: nueva contraseña
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _generatedOtp;
  bool _isLoading = false;
  int _resendTimer = 0;

  // === VALIDACIÓN CONTRASEÑA ===
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;
  bool _notOnlyNumbers = true;

  // === GMAIL ===
  final String _gmailEmail = 'jeanflores831@gmail.com';
  final String _gmailAppPassword = 'jwbh fotp ejjv lazk';

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_updateValidation);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updateValidation() {
    final p = _newPasswordController.text;
    setState(() {
      _hasMinLength = p.length >= 8;
      _hasUppercase = p.contains(RegExp(r'[A-Z]'));
      _hasNumber = p.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = p.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
      _notOnlyNumbers = !RegExp(r'^\d+$').hasMatch(p);
    });
  }

  bool _isPasswordValid() =>
      _hasMinLength && _hasUppercase && _hasNumber && _hasSpecialChar && _notOnlyNumbers;

  // === PASO 1: ENVIAR CÓDIGO ===
  Future<void> _sendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showError('Ingresa un correo válido');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final userExists = await _authService.userExists(email);
      if (!userExists) {
        _showError('Este correo no está registrado');
        return;
      }

      _generatedOtp = (100000 + DateTime.now().millisecondsSinceEpoch % 900000).toString();

      final smtpServer = gmail(_gmailEmail, _gmailAppPassword);
      final message = Message()
        ..from = Address(_gmailEmail, 'Kronos')
        ..recipients.add(email)
        ..subject = 'Código para cambiar contraseña'
        ..html = '''
          <h2>¡Hola!</h2>
          <p>Tu código para cambiar la contraseña es:</p>
          <h1 style="color: #FF8C42; font-size: 32px; letter-spacing: 8px;"><b>$_generatedOtp</b></h1>
          <p>Expira en 5 minutos.</p>
        ''';

      await send(message, smtpServer);

      setState(() {
        _currentStep = 2;
        _resendTimer = 60;
      });
      _startTimer();
      _showSuccess('Código enviado');
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
        return true;
      }
      return false;
    });
  }

  // === PASO 2: VERIFICAR CÓDIGO ===
  void _verifyCode() {
    if (_otpController.text.length != 6) {
      _showError('Ingresa 6 dígitos');
      return;
    }
    if (_otpController.text != _generatedOtp) {
      _showError('Código incorrecto');
      return;
    }
    setState(() => _currentStep = 3);
    _showSuccess('Código correcto');
  }

  // === PASO 3: CAMBIAR CONTRASEÑA ===
  Future<void> _changePassword() async {
    final newPass = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;

    if (!_isPasswordValid()) {
      _showError('Contraseña débil');
      return;
    }
    if (newPass != confirm) {
      _showError('No coinciden');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.updatePassword(_emailController.text.trim(), newPass);
      _showSuccess('¡Contraseña cambiada!');
      if (mounted) Navigator.pop(context); // Regresa al login
    } catch (e) {
      _showError('Error al cambiar');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF003D82)), onPressed: () => Navigator.pop(context)),
        title: const Text('Cambiar Contraseña', style: TextStyle(fontFamily: 'JetBrainsMono_Regular', color: Color(0xFF003D82))),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // === PASO 1: INGRESAR CORREO ===
              if (_currentStep == 1) ...[
                const Text('Ingresa tu correo para recibir un código', textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
                const SizedBox(height: 20),
                _buildTextField(_emailController, 'tuemail@ejemplo.com', TextInputType.emailAddress),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isLoading ? null : _sendCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8C42),
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('ENVIAR CÓDIGO', style: TextStyle(color: Colors.white, fontFamily: 'JetBrainsMono_Regular')),
                ),
              ]

              // === PASO 2: INGRESAR CÓDIGO ===
              else if (_currentStep == 2) ...[
                Text('Código enviado a:', style: TextStyle(color: Colors.grey[700])),
                Text(_emailController.text, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: '------',
                    counterText: '',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8C42),
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('VERIFICAR', style: TextStyle(color: Colors.white, fontFamily: 'JetBrainsMono_Regular')),
                ),
                TextButton(
                  onPressed: _resendTimer > 0 ? null : _sendCode,
                  child: Text(_resendTimer > 0 ? 'Reenviar en $_resendTimer s' : 'Reenviar', style: TextStyle(color: _resendTimer > 0 ? Colors.grey : const Color(0xFFFF8C42))),
                ),
              ]

              // === PASO 3: NUEVA CONTRASEÑA ===
              else if (_currentStep == 3) ...[
                _buildLabel('Nueva Contraseña'),
                _buildPasswordField(_newPasswordController, _obscureNew, () => setState(() => _obscureNew = !_obscureNew)),
                const SizedBox(height: 12),
                _buildPasswordRequirements(),
                const SizedBox(height: 20),
                _buildLabel('Confirmar Contraseña'),
                _buildPasswordField(_confirmPasswordController, _obscureConfirm, () => setState(() => _obscureConfirm = !_obscureConfirm)),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isLoading ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8C42),
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('CAMBIAR CONTRASEÑA', style: TextStyle(color: Colors.white, fontFamily: 'JetBrainsMono_Regular')),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Align(alignment: Alignment.centerLeft, child: Text(text, style: const TextStyle(fontSize: 14, fontFamily: 'JetBrainsMono_Regular')));

  Widget _buildTextField(TextEditingController c, String hint, [TextInputType? kt]) => TextField(
        controller: c,
        keyboardType: kt,
        decoration: InputDecoration(hintText: hint, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
      );

  Widget _buildPasswordField(TextEditingController c, bool obscure, VoidCallback toggle) => TextField(
        controller: c,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: 'Contraseña segura',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: IconButton(icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: toggle),
        ),
      );

  Widget _buildPasswordRequirements() => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Requisitos:'),
            _req('8+ caracteres', _hasMinLength),
            _req('Mayúscula', _hasUppercase),
            _req('Número', _hasNumber),
            _req('Especial', _hasSpecialChar),
            _req('No solo números', _notOnlyNumbers),
          ],
        ),
      );

  Widget _req(String t, bool v) => Row(children: [Icon(v ? Icons.check_circle : Icons.radio_button_unchecked, size: 16, color: v ? Colors.green : Colors.grey), const SizedBox(width: 6), Text(t, style: TextStyle(fontSize: 12))]);
}