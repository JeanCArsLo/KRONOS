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
      _hasMinLength && _hasUppercase && _hasNumber && _hasSpecialChar && _notOnlyNumbers;

  // === ENVIAR OTP POR GMAIL ===
  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showError('Ingresa un correo válido');
      return;
    }

    setState(() => _isLoading = true);
    try {
      _generatedOtp = (100000 + DateTime.now().millisecondsSinceEpoch % 900000).toString();

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
              primary: Color(0xFFFF8C42),
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF8C42)),
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
    if (_selectedDate == null) return _showError('Selecciona tu fecha de nacimiento');
    if (!_isPasswordValid()) return _showError('La contraseña no cumple los requisitos');
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
          const SnackBar(content: Text('¡Cuenta creada exitosamente!'), backgroundColor: Colors.green),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text(
                'Sign Up',
                style: TextStyle(
                  fontFamily: 'JetBrainsMono_Regular',
                  fontSize: 32,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 30),

              // === PASO 1: CORREO ===
              if (_currentStep == 1) ...[
                _buildLabel('Correo Electrónico'),
                _buildTextField(_emailController, 'ejemplo@gmail.com', TextInputType.emailAddress),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isLoading ? null : _sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8C42),
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'ENVIAR CÓDIGO',
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono_Regular',
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                          ),
                        ),
                ),
              ]

              // === PASO 2: CÓDIGO OTP ===
              else if (_currentStep == 2) ...[
                Text(
                  'Código enviado a:',
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  _emailController.text,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                    fontFamily: 'JetBrainsMono_Regular',
                  ),
                  decoration: InputDecoration(
                    hintText: '------',
                    counterText: '',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFF8C42), width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8C42),
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'VERIFICAR CÓDIGO',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono_Regular',
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _resendTimer > 0 ? null : _sendOtp,
                  child: Text(
                    _resendTimer > 0 ? 'Reenviar en $_resendTimer s' : 'Reenviar código',
                    style: TextStyle(
                      color: _resendTimer > 0 ? Colors.grey : const Color(0xFFFF8C42),
                      fontFamily: 'JetBrainsMono_Regular',
                    ),
                  ),
                ),
              ]

              // === PASO 3: FORMULARIO COMPLETO ===
              else if (_currentStep == 3) ...[
                _buildLabel('Nombres y Apellidos'),
                _buildTextField(_fullNameController, 'Juan Pérez'),
                const SizedBox(height: 20),

                // === FECHA DE NACIMIENTO ===
                _buildLabel('Fecha de Nacimiento'),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF003D82)),
                      borderRadius: BorderRadius.circular(10),
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
                            color: _selectedDate == null ? Colors.grey[600] : Colors.black,
                            fontFamily: 'JetBrainsMono_Regular',
                          ),
                        ),
                        const Icon(Icons.calendar_today, color: Color(0xFFFF8C42)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // === GÉNERO ===
                _buildLabel('Género'),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Hombre', style: TextStyle(fontFamily: 'JetBrainsMono_Regular')),
                        value: 'M',
                        groupValue: _selectedGender,
                        onChanged: (value) => setState(() => _selectedGender = value!),
                        activeColor: const Color(0xFFFF8C42),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Mujer', style: TextStyle(fontFamily: 'JetBrainsMono_Regular')),
                        value: 'F',
                        groupValue: _selectedGender,
                        onChanged: (value) => setState(() => _selectedGender = value!),
                        activeColor: const Color(0xFFFF8C42),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // === CONTRASEÑA ===
                _buildLabel('Contraseña'),
                _buildPasswordField(_passwordController, _obscurePassword, () {
                  setState(() => _obscurePassword = !_obscurePassword);
                }),
                const SizedBox(height: 12),
                _buildPasswordRequirements(),
                const SizedBox(height: 20),

                // === CONFIRMAR CONTRASEÑA ===
                _buildLabel('Confirmar Contraseña'),
                _buildPasswordField(_confirmPasswordController, _obscureConfirmPassword, () {
                  setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                }),
                const SizedBox(height: 30),

                // === BOTÓN REGISTRO ===
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8C42),
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'CREAR CUENTA',
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono_Regular',
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                          ),
                        ),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // === WIDGETS AUXILIARES ===
  Widget _buildLabel(String text) => Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'JetBrainsMono_Regular',
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      );

  Widget _buildTextField(TextEditingController c, String hint, [TextInputType? kt]) => TextField(
        controller: c,
        keyboardType: kt,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontFamily: 'JetBrainsMono_Regular', color: Colors.grey[400], fontSize: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF003D82), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF003D82), width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );

  Widget _buildPasswordField(TextEditingController c, bool obscure, VoidCallback toggle) => TextField(
        controller: c,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: 'Contraseña segura',
          hintStyle: TextStyle(fontFamily: 'JetBrainsMono_Regular', color: Colors.grey[400], fontSize: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF003D82), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF003D82), width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: IconButton(
            icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey[600]),
            onPressed: toggle,
          ),
        ),
      );

  Widget _buildPasswordRequirements() => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tu contraseña debe contener:',
              style: TextStyle(fontFamily: 'JetBrainsMono_Regular', fontSize: 12, color: Colors.grey[600]),
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
              color: valid ? Colors.green : Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: valid ? Colors.green[700] : Colors.grey[600],
                fontWeight: valid ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ],
        ),
      );
}