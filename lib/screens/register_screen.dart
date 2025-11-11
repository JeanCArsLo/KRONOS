import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import '../routes.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // === CONTROLADORES ===
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController();

  // === ESTADOS ===
  int _currentStep = 1; // 1: correo, 2: OTP, 3: formulario
  String? _generatedOtp;
  bool _isLoading = false;
  int _resendTimer = 0;

  // === FECHA Y GÉNERO ===
  DateTime? _selectedDate;
  String _selectedGender = 'M'; // 'M' o 'F'

  // === CONTRASEÑA ===
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;
  bool _notOnlyNumbers = true;

  // === SERVICIO ===
  final AuthService _authService = AuthService();

  // === GMAIL CREDENTIALS (CAMBIAR AQUÍ) ===
  final String _gmailEmail = 'jeanflores831@gmail.com';
  final String _gmailAppPassword = 'jwbh fotp ejjv lazk';

  // === IMAGEN DE FONDO ===
  final String _backgroundImage = 'assets/gym/gym7.jpg';

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updatePasswordValidation);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // === VALIDACIÓN DE CONTRASEÑA ===
  void _updatePasswordValidation() {
    final p = _passwordController.text;
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

  // === ENVIAR OTP POR GMAIL ===
  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showError('Ingresa un correo válido');
      return;
    }

    setState(() => _isLoading = true);
    try {
      _generatedOtp = (100000 + DateTime.now().millisecondsSinceEpoch % 900000)
          .toString();

      final smtpServer = gmail(_gmailEmail, _gmailAppPassword);
      final message = Message()
        ..from = Address(_gmailEmail, 'Kronos App')
        ..recipients.add(email)
        ..subject = 'Tu código de verificación - Kronos'
        ..html =
            '''
          <div style="font-family: Arial, sans-serif; text-align: center; padding: 20px;">
            <h2 style="color: #003D82;">¡Hola!</h2>
            <p>Tu código de verificación es:</p>
            <h1 style="font-size: 36px; letter-spacing: 10px; color: #FF8C42; font-weight: bold;">
              $_generatedOtp
            </h1>
            <p style="color: #666;">Expira en 5 minutos.</p>
            <p style="font-size: 12px; color: #999;">Si no solicitaste esto, ignora este mensaje.</p>
          </div>
        ''';

      await send(message, smtpServer);

      setState(() {
        _currentStep = 2;
        _resendTimer = 60;
      });
      _startResendTimer();
      _showSuccess('Código enviado a $email');
    } catch (e) {
      _showError('Error al enviar: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _startResendTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
        return true;
      }
      return false;
    });
  }

  // === VERIFICAR OTP ===
  void _verifyOtp() {
    final code = _otpController.text.trim();
    if (code.length != 6) {
      _showError('Ingresa un código de 6 dígitos');
      return;
    }
    if (code != _generatedOtp) {
      _showError('Código incorrecto');
      return;
    }
    setState(() => _currentStep = 3);
    _showSuccess('¡Correo verificado!');
  }

  // === SELECCIONAR FECHA ===
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1976D2),
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1976D2),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  // === REGISTRO FINAL ===
  Future<void> _register() async {
    final email = _emailController.text.trim();
    final fullName = _fullNameController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (fullName.isEmpty) return _showError('Ingresa tu nombre completo');
    if (_selectedDate == null)
      return _showError('Selecciona tu fecha de nacimiento');
    if (!_isPasswordValid())
      return _showError('La contraseña no cumple los requisitos');
    if (password != confirm) return _showError('Las contraseñas no coinciden');

    setState(() => _isLoading = true);
    try {
      await _authService.register(
        email: email,
        fullName: fullName,
        password: password,
        birthDate: _selectedDate!,
        gender: _selectedGender,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Cuenta creada exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, Routes.login);
      }
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // === MENSAJES ===
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
          // Fondo con imagen
          Image.asset(
            _backgroundImage,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          // Overlay más oscuro
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xCC000000), // 80% opacity
                  Color(0xE6000000), // 90% opacity
                ],
              ),
            ),
          ),

          // Contenido
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),

                    // Título
                    const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // === PASO 1: CORREO ===
                    if (_currentStep == 1) ...[
                      _buildLabel('Correo Electrónico'),
                      const SizedBox(height: 12),
                      _buildTextField(
                        _emailController,
                        'ejemplo@gmail.com',
                        TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 30),
                      _buildButton(
                        text: 'ENVIAR CÓDIGO',
                        onPressed: _isLoading ? null : _sendOtp,
                        isLoading: _isLoading,
                      ),
                    ]
                    // === PASO 2: CÓDIGO OTP ===
                    else if (_currentStep == 2) ...[
                      Text(
                        'Código enviado a:',
                        style: TextStyle(
                          color: Color(0xB3FFFFFF), // 70% opacity
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _emailController.text,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // CAMPO DE CÓDIGO (6 DÍGITOS)
                      TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          letterSpacing: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: '------',
                          hintStyle: TextStyle(
                            color: Color(0x4DFFFFFF), // 30% opacity
                          ),
                          counterText: '',
                          filled: true,
                          fillColor: Color(0x0DFFFFFF), // 5% opacity
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Color(0x1AFFFFFF), // 10% opacity
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF1976D2),
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Color(0x1AFFFFFF), // 10% opacity
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      _buildButton(
                        text: 'VERIFICAR CÓDIGO',
                        onPressed: _verifyOtp,
                      ),
                      TextButton(
                        onPressed: _resendTimer > 0 ? null : _sendOtp,
                        child: Text(
                          _resendTimer > 0
                              ? 'Reenviar en $_resendTimer s'
                              : 'Reenviar código',
                          style: TextStyle(
                            color: _resendTimer > 0
                                ? Color(0x80FFFFFF) // 50% opacity
                                : const Color(0xFF1976D2),
                          ),
                        ),
                      ),
                    ]
                    // === PASO 3: FORMULARIO COMPLETO ===
                    else if (_currentStep == 3) ...[
                      _buildLabel('Nombres y Apellidos'),
                      const SizedBox(height: 12),
                      _buildTextField(_fullNameController, 'Juan Pérez'),
                      const SizedBox(height: 20),

                      // === FECHA DE NACIMIENTO ===
                      _buildLabel('Fecha de Nacimiento'),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0x0DFFFFFF), // 5% opacity
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Color(0x1AFFFFFF), // 10% opacity
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedDate == null
                                    ? 'Selecciona una fecha'
                                    : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _selectedDate == null
                                      ? Color(0x4DFFFFFF) // 30% opacity
                                      : Colors.white,
                                ),
                              ),
                              Icon(
                                Icons.calendar_today,
                                color: Color(0x99FFFFFF), // 60% opacity
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // === GÉNERO ===
                      _buildLabel('Género'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedGender = 'M'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: _selectedGender == 'M'
                                      ? Color(0x4D1976D2) // 30% opacity
                                      : Color(0x0DFFFFFF), // 5% opacity
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(
                                    color: _selectedGender == 'M'
                                        ? const Color(0xFF1976D2)
                                        : Color(0x1AFFFFFF), // 10% opacity
                                    width: _selectedGender == 'M' ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _selectedGender == 'M'
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_unchecked,
                                      color: _selectedGender == 'M'
                                          ? const Color(0xFF1976D2)
                                          : Color(0x80FFFFFF), // 50% opacity
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Hombre',
                                      style: TextStyle(
                                        color: _selectedGender == 'M'
                                            ? Colors.white
                                            : Color(0xB3FFFFFF), // 70% opacity
                                        fontWeight: _selectedGender == 'M'
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedGender = 'F'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: _selectedGender == 'F'
                                      ? Color(0x4D1976D2) // 30% opacity
                                      : Color(0x0DFFFFFF), // 5% opacity
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(
                                    color: _selectedGender == 'F'
                                        ? const Color(0xFF1976D2)
                                        : Color(0x1AFFFFFF), // 10% opacity
                                    width: _selectedGender == 'F' ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _selectedGender == 'F'
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_unchecked,
                                      color: _selectedGender == 'F'
                                          ? const Color(0xFF1976D2)
                                          : Color(0x80FFFFFF), // 50% opacity
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Mujer',
                                      style: TextStyle(
                                        color: _selectedGender == 'F'
                                            ? Colors.white
                                            : Color(0xB3FFFFFF), // 70% opacity
                                        fontWeight: _selectedGender == 'F'
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // === CONTRASEÑA ===
                      _buildLabel('Contraseña'),
                      const SizedBox(height: 12),
                      _buildPasswordField(
                        _passwordController,
                        _obscurePassword,
                        () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildPasswordRequirements(),
                      const SizedBox(height: 20),

                      // === CONFIRMAR CONTRASEÑA ===
                      _buildLabel('Confirmar Contraseña'),
                      const SizedBox(height: 12),
                      _buildPasswordField(
                        _confirmPasswordController,
                        _obscureConfirmPassword,
                        () => setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // === BOTÓN REGISTRO ===
                      _buildButton(
                        text: 'CREAR CUENTA',
                        onPressed: _isLoading ? null : _register,
                        isLoading: _isLoading,
                      ),
                    ],

                    const SizedBox(height: 20),

                    // ¿Ya tienes cuenta?
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿Ya tienes una cuenta? ',
                          style: TextStyle(
                            color: Color(0xB3FFFFFF), // 70% opacity
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              Routes.login,
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Inicia Sesión',
                            style: TextStyle(
                              color: Color(0xFF1976D2),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // === WIDGETS AUXILIARES ===
  Widget _buildLabel(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    ),
  );

  Widget _buildTextField(
    TextEditingController c,
    String hint, [
    TextInputType? kt,
  ]) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0x0DFFFFFF), // 5% opacity
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Color(0x1AFFFFFF), width: 1), // 10% opacity
      ),
      child: TextField(
        controller: c,
        keyboardType: kt,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Color(0x4DFFFFFF), // 30% opacity
            fontSize: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    TextEditingController c,
    bool obscure,
    VoidCallback toggle,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0x0DFFFFFF), // 5% opacity
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Color(0x1AFFFFFF), width: 1), // 10% opacity
      ),
      child: TextField(
        controller: c,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Contraseña segura',
          hintStyle: TextStyle(
            color: Color(0x4DFFFFFF), // 30% opacity
            fontSize: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.white70,
              size: 22,
            ),
            onPressed: toggle,
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1976D2),
          disabledBackgroundColor: Colors.grey[800],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
      ),
    );
  }

  Widget _buildPasswordRequirements() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Color(0x0DFFFFFF), // 5% opacity
      border: Border.all(color: Color(0x1AFFFFFF)), // 10% opacity
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tu contraseña debe contener:',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xB3FFFFFF),
          ), // 70% opacity
        ),
        const SizedBox(height: 6),
        _reqItem('Mínimo 8 caracteres', _hasMinLength),
        _reqItem('Al menos una mayúscula', _hasUppercase),
        _reqItem('Al menos un número', _hasNumber),
        _reqItem('Al menos un carácter especial', _hasSpecialChar),
        _reqItem('No puede ser solo números', _notOnlyNumbers),
      ],
    ),
  );

  Widget _reqItem(String text, bool valid) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Icon(
          valid ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: valid ? Colors.green : Color(0x80FFFFFF), // 50% opacity
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: valid ? Colors.green[300] : Color(0xB3FFFFFF), // 70% opacity
            fontWeight: valid ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ],
    ),
  );
}
