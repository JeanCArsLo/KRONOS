import 'package:flutter/material.dart';
import '../routes.dart';
import '../services/auth_service.dart';
import '../services/login_block_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final LoginBlockService _blockService = LoginBlockService();

  String? _blockedUntil;
  int _attempts = 0;
  bool _isLoading = false;

  // CONFIGURA AQUÍ LA RUTA DE TU IMAGEN DE FONDO
  final String _backgroundImage = 'assets/gym/gym6.jpg';

  @override
  void initState() {
    super.initState();
    _checkBlockOnStart();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkBlockOnStart() async {
    setState(() => _isLoading = true);
    try {
      final blocked = await _blockService.isBlocked();
      if (blocked) {
        final time = await _blockService.getRemainingTime();
        setState(() {
          _blockedUntil = time;
          _attempts = 3;
        });
        _startTimer();
      } else {
        final attempts = await _blockService.getFailedAttempts();
        setState(() => _attempts = attempts);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;

      final blocked = await _blockService.isBlocked();
      if (!blocked) {
        setState(() {
          _blockedUntil = null;
          _attempts = 0;
        });
        await _blockService.resetFailedAttempts();
        return false;
      }

      final time = await _blockService.getRemainingTime();
      setState(() => _blockedUntil = time);
      return true;
    });
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('Completa todos los campos');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final blocked = await _blockService.isBlocked();
      if (blocked) {
        final time = await _blockService.getRemainingTime();
        _showError('Bloqueado. Espera $time');
        return;
      }

      final user = await _authService.login(email, password);
      if (user != null) {
        await _blockService.resetFailedAttempts();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Bienvenido!'),
              backgroundColor: Color(0xFF4CAF50),
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pushReplacementNamed(context, Routes.home);
        }
      } else {
        final attempts = (await _blockService.getFailedAttempts()) + 1;
        await _blockService.incrementFailedAttempts();

        if (attempts >= 3) {
          await _blockService.blockDevice();
          final time = await _blockService.getRemainingTime();
          setState(() {
            _blockedUntil = time;
            _attempts = 3;
          });
          _startTimer();
          _showError('Bloqueado por 15 minutos');
        } else {
          setState(() => _attempts = attempts);
          _showError('Contraseña incorrecta. Intentos: $attempts/3');
        }
      }
    } catch (e) {
      _showError('Error de conexión');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: const Color(0xFFD32F2F),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
                  Colors.black.withOpacity(0.8),
                  Colors.black.withOpacity(0.9),
                ],
              ),
            ),
          ),

          // Contenido del login
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),

                    // Título "Login"
                    const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: 60),

                    // Alerta de bloqueo
                    if (_blockedUntil != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD32F2F).withValues(alpha: 0.2),
                          border: Border.all(
                            color: const Color(0xFFD32F2F),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.lock_clock,
                              color: Color(0xFFEF5350),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Cuenta bloqueada',
                                    style: TextStyle(
                                      color: Color(0xFFEF5350),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Tiempo restante: $_blockedUntil',
                                    style: const TextStyle(
                                      color: Color(0xFFE57373),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Alerta de intentos
                    if (_attempts > 0 && _blockedUntil == null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9800).withValues(alpha: 0.2),
                          border: Border.all(
                            color: const Color(0xFFFF9800),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Color(0xFFFFB74D),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Intentos fallidos: $_attempts/3',
                                style: const TextStyle(
                                  color: Color(0xFFFFB74D),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Campo de correo electrónico
                    _buildInputField(
                      controller: _emailController,
                      label: 'Correo Electronico',
                      hint: 'ejemplo@correo.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 24),

                    // Campo de contraseña
                    _buildInputField(
                      controller: _passwordController,
                      label: 'Contraseña',
                      hint: 'Contraseña segura',
                      icon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.white70,
                          size: 22,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Botón de login
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: (_isLoading || _blockedUntil != null)
                            ? null
                            : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          disabledBackgroundColor: Colors.grey[800],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ¿Olvidaste tu contraseña?
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, Routes.forgotPassword);
                      },
                      child: const Text(
                        '¿Has olvidado tu contraseña?',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Divisor OR
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.white.withValues(alpha: 0.3),
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.white.withValues(alpha: 0.3),
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ¿No tienes cuenta? Regístrate
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "¿No tienes cuenta? ",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 15,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, Routes.register);
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Regístrate',
                            style: TextStyle(
                              color: Color(0xFF1976D2),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
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
            ),
          ),
        ),
      ],
    );
  }
}
