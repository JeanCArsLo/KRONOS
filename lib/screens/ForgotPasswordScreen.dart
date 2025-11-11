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
      _hasMinLength &&
      _hasUppercase &&
      _hasNumber &&
      _hasSpecialChar &&
      _notOnlyNumbers;

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

      _generatedOtp = (100000 + DateTime.now().millisecondsSinceEpoch % 900000)
          .toString();

      final smtpServer = gmail(_gmailEmail, _gmailAppPassword);
      final message = Message()
        ..from = Address(_gmailEmail, 'Kronos')
        ..recipients.add(email)
        ..subject = 'Código para cambiar contraseña'
        ..html =
            '''
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo con imagen (igual que en LoginScreen)
          Image.asset(
            'assets/gym/gym6.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          // Overlay más oscuro (igual que en LoginScreen)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.black.withOpacity(0.9),
                ],
              ),
            ),
          ),

          // Contenido del ForgotPasswordScreen (botón arriba, resto centrado)
          SafeArea(
            child: Column(
              children: [
                // Botón de regreso (arriba del todo)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

                // Cuerpo principal centrado
                Expanded(
                  child: Center(
                    // Añadido Center aquí
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment
                            .center, // Asegura centrado vertical
                        children: [
                          // Título centrado y más pequeño
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'Cambiar Contraseña',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 30, // Tamaño reducido
                                fontWeight: FontWeight.w400, // Peso reducido
                                color: Colors.white,
                                letterSpacing: 1.5, // Ajuste de espaciado
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // === PASO 1: INGRESAR CORREO ===
                          if (_currentStep == 1) ...[
                            // Texto con color más claro
                            Text(
                              'Ingresa tu correo para recibir un código',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(
                                  0.9,
                                ), // Color más claro
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 35),

                            // Campo de correo electrónico (estilo del LoginScreen)
                            _buildInputField(
                              controller: _emailController,
                              label: 'Correo Electrónico',
                              hint: 'ejemplo@correo.com',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                            ),

                            const SizedBox(height: 50),

                            // Botón de enviar código (estilo original de ForgotPasswordScreen)
                            ElevatedButton(
                              onPressed: _isLoading ? null : _sendCode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF8C42),
                                minimumSize: const Size(double.infinity, 55),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      'ENVIAR CÓDIGO',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'JetBrainsMono_Regular',
                                      ),
                                    ),
                            ),
                          ]
                          // === PASO 2: INGRESAR CÓDIGO ===
                          else if (_currentStep == 2) ...[
                            Text(
                              'Código enviado a:',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            Text(
                              _emailController.text,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Campo de código OTP (estilo del LoginScreen)
                            _buildInputField(
                              controller: _otpController,
                              label: 'Código de Verificación',
                              hint: '------',
                              icon: Icons.lock_outline,
                              keyboardType: TextInputType.number,
                              maxLength: 6, // Limitar a 6 dígitos
                            ),

                            const SizedBox(height: 20),

                            // Botón de verificar (estilo original de ForgotPasswordScreen)
                            ElevatedButton(
                              onPressed: _verifyCode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF8C42),
                                minimumSize: const Size(double.infinity, 55),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                'VERIFICAR',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'JetBrainsMono_Regular',
                                ),
                              ),
                            ),

                            // Botón de reenviar código (estilo original de ForgotPasswordScreen)
                            TextButton(
                              onPressed: _resendTimer > 0 ? null : _sendCode,
                              child: Text(
                                _resendTimer > 0
                                    ? 'Reenviar en $_resendTimer s'
                                    : 'Reenviar',
                                style: TextStyle(
                                  color: _resendTimer > 0
                                      ? Colors.grey
                                      : const Color(0xFFFF8C42),
                                ),
                              ),
                            ),
                          ]
                          // === PASO 3: NUEVA CONTRASEÑA ===
                          else if (_currentStep == 3) ...[
                            // Campo de nueva contraseña (estilo del LoginScreen)
                            _buildInputField(
                              controller: _newPasswordController,
                              label: 'Nueva Contraseña',
                              hint: 'Contraseña segura',
                              icon: Icons.lock_outline,
                              obscureText: _obscureNew,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureNew
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.white70,
                                  size: 22,
                                ),
                                onPressed: () {
                                  setState(() => _obscureNew = !_obscureNew);
                                },
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Requisitos contraseña (estilo original de ForgotPasswordScreen)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Requisitos:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors
                                          .white70, // Color claro para que se vea bien
                                    ),
                                  ),
                                  _req('8+ caracteres', _hasMinLength),
                                  _req('Mayúscula', _hasUppercase),
                                  _req('Número', _hasNumber),
                                  _req('Especial', _hasSpecialChar),
                                  _req('No solo números', _notOnlyNumbers),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Campo de confirmar contraseña (estilo del LoginScreen)
                            _buildInputField(
                              controller: _confirmPasswordController,
                              label: 'Confirmar Contraseña',
                              hint: 'Confirmar contraseña',
                              icon: Icons.lock_outline,
                              obscureText: _obscureConfirm,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.white70,
                                  size: 22,
                                ),
                                onPressed: () {
                                  setState(
                                    () => _obscureConfirm = !_obscureConfirm,
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 40),

                            // Botón de cambiar contraseña (estilo original de ForgotPasswordScreen)
                            ElevatedButton(
                              onPressed: _isLoading ? null : _changePassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF8C42),
                                minimumSize: const Size(double.infinity, 55),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      'CAMBIAR CONTRASEÑA',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'JetBrainsMono_Regular',
                                      ),
                                    ),
                            ),
                          ],

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget para construir campos de texto con el mismo estilo que el LoginScreen
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    int? maxLength, // Agregar maxLength como parámetro opcional
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            maxLength: maxLength, // Aplicar maxLength si se proporciona
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 15,
              ),
              prefixIcon: Icon(icon, color: Colors.white60, size: 22),
              suffixIcon: suffixIcon,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(
                  color: Color(0xFF1976D2),
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              counterText: maxLength != null
                  ? '${controller.text.length}/$maxLength'
                  : '', // Mostrar contador si maxLength está definido
            ),
          ),
        ),
      ],
    );
  }

  // Widget para mostrar los requisitos de la contraseña (estilo original de ForgotPasswordScreen)
  Widget _req(String t, bool v) => Row(
    children: [
      Icon(
        v ? Icons.check_circle : Icons.radio_button_unchecked,
        size: 16,
        color: v ? Colors.green : Colors.grey,
      ),
      const SizedBox(width: 6),
      Text(
        t,
        style: TextStyle(
          fontSize: 12,
          color: v ? Colors.green : Colors.white70, // <-- Añadido color
        ),
      ),
    ],
  );
}
