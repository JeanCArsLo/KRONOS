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

  // === VERIFICAR BLOQUEO AL ABRIR ===
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

  // === TEMPORIZADOR EN VIVO ===
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

  // === LOGIN ===
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
            SnackBar(content: Text('¡Bienvenido ${user.fullName}!'), backgroundColor: Colors.green),
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
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    }
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
              const SizedBox(height: 60),
              const Text('Login', style: TextStyle(fontFamily: 'JetBrainsMono_Regular', fontSize: 32)),
              const SizedBox(height: 60),

              _buildLabel('Correo Electrónico'),
              _buildTextField(_emailController, 'ejemplo@gmail.com', TextInputType.emailAddress),
              const SizedBox(height: 24),

              _buildLabel('Contraseña'),
              _buildPasswordField(_passwordController, _obscurePassword, () {
                setState(() => _obscurePassword = !_obscurePassword);
              }),
              const SizedBox(height: 20),

              if (_attempts > 0 && _blockedUntil == null)
                Text('Intentos fallidos: $_attempts/3', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),

              if (_blockedUntil != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(color: Colors.red[50], border: Border.all(color: Colors.red), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock, color: Colors.red),
                      const SizedBox(width: 8),
                      Text('Bloqueado: $_blockedUntil', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _isLoading || _blockedUntil != null ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003D82),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('INICIAR SESIÓN', style: TextStyle(color: Colors.white, fontFamily: 'JetBrainsMono_Regular')),
              ),
              const SizedBox(height: 24),

              TextButton(onPressed: () => Navigator.pushNamed(context, Routes.register), child: const Text('¿No tienes cuenta? Regístrate', style: TextStyle(color: Color(0xFF003D82)))),
              TextButton(onPressed: () => Navigator.pushNamed(context, Routes.forgotPassword), child: const Text('¿Olvidaste tu contraseña?', style: TextStyle(color: Colors.grey))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String t) => Align(alignment: Alignment.centerLeft, child: Text(t, style: const TextStyle(fontFamily: 'JetBrainsMono_Regular', fontSize: 14)));
  Widget _buildTextField(TextEditingController c, String h, [TextInputType? k]) => TextField(
        controller: c,
        keyboardType: k,
        decoration: InputDecoration(hintText: h, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)), contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
      );
  Widget _buildPasswordField(TextEditingController c, bool o, VoidCallback t) => TextField(
        controller: c,
        obscureText: o,
        decoration: InputDecoration(
          hintText: 'Contraseña segura',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          suffixIcon: IconButton(icon: Icon(o ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: t),
        ),
      );
}