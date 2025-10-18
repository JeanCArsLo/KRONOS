import 'package:flutter/material.dart';
import '../routes.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  // 🔥 CONTROLADORES (NUEVO)
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // 🔥 BACKEND (NUEVO)
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();      // 🔥 AGREGADO
    _passwordController.dispose();   // 🔥 AGREGADO
    super.dispose();
  }

  Future<void> _login() async {
    try {
      final user = await _authService.login(
        _emailController.text.trim(),  // 🔥 CAMBIO: email
        _passwordController.text,
      );

      if (user != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('¡Bienvenido ${user.fullName}!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacementNamed(context, Routes.home);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Correo o contraseña incorrectos')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 60),
                
                // ========== TÍTULO "LOGIN" ==========
                Text(
                  'Login',
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono_Regular',
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1.0,
                  ),
                ),
                SizedBox(height: 60),
                
                // ========== CAMPO DE CORREO ELECTRÓNICO ==========
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Correo Electronico',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono_Regular',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'ejemplo@correo.com',
                    hintStyle: TextStyle(
                      fontFamily: 'JetBrainsMono_Regular',
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: Colors.orange, // Borde naranja para el correo
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: Colors.orange, // Naranja cuando está enfocado
                        width: 2,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 24),
                
                // ========== CAMPO DE CONTRASEÑA CON OJITO ==========
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Contraseña',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono_Regular',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Contraseña segura',
                    hintStyle: TextStyle(
                      fontFamily: 'JetBrainsMono_Regular',
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: Colors.orange, // Borde naranja para la contraseña
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: Colors.orange, // Naranja cuando está enfocado
                        width: 2,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 40),
                
                // ========== BOTÓN DE LOGIN ==========
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF003D82), // Azul oscuro del botón
                    minimumSize: Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono_Regular',
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                SizedBox(height: 120),
                
                // ========== TEXTO DE "¿HAS OLVIDADO TU CONTRASEÑA?" ==========
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, Routes.register);
                  },
                  child: Text(
                    '¿Has olvidado tu contraseña?',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono_Regular',
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}