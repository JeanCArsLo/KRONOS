import 'package:flutter/material.dart';
import '../routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
                // ========== TÍTULO "SIGN UP" ==========
                Text(
                  'Sign Up',
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono_Regular',
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1.0,
                  ),
                ),
                SizedBox(height: 40),
                
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
                  decoration: InputDecoration(
                    hintText: 'ejemplo@correo.com',
                    hintStyle: TextStyle(
                      fontFamily: 'JetBrainsMono_Regular',
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color(0xFF003D82), // Azul para el borde del correo
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color(0xFF003D82), // Azul cuando está enfocado
                        width: 1.5,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 20),
                
                // ========== CAMPO DE NOMBRES Y APELLIDOS ==========
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Nombres y Apellidos',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono_Regular',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Tus nombres y apellidos',
                    hintStyle: TextStyle(
                      fontFamily: 'JetBrainsMono_Regular',
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color(0xFF003D82), // Azul para el borde del nombre
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color(0xFF003D82), // Azul cuando está enfocado
                        width: 1.5,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                
                // ========== CAMPO DE CONTRASEÑA (PRIMERA) ==========
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
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Contraseña segura',
                    hintStyle: TextStyle(
                      fontFamily: 'JetBrainsMono_Regular',
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color(0xFF003D82), // Azul para el borde de contraseña
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color(0xFF003D82), // Azul cuando está enfocado
                        width: 1.5,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
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
                SizedBox(height: 12),
                
                // ========== CAJA DE REQUISITOS DE CONTRASEÑA ==========
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tu contraseña debe contener:',
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono_Regular',
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.check, size: 14, color: Colors.grey[600]),
                          SizedBox(width: 6),
                          Text(
                            'Mínimo 8 caracteres',
                            style: TextStyle(
                              fontFamily: 'JetBrainsMono_Regular',
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.check, size: 14, color: Colors.grey[600]),
                          SizedBox(width: 6),
                          Text(
                            'No puede ser muy común',
                            style: TextStyle(
                              fontFamily: 'JetBrainsMono_Regular',
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.check, size: 14, color: Colors.grey[600]),
                          SizedBox(width: 6),
                          Text(
                            'No puede ser solo números',
                            style: TextStyle(
                              fontFamily: 'JetBrainsMono_Regular',
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                
                // ========== CAMPO DE CONFIRMAR CONTRASEÑA ==========
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Confirmar Contraseña',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono_Regular',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText: 'Contraseña segura',
                    hintStyle: TextStyle(
                      fontFamily: 'JetBrainsMono_Regular',
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color(0xFF003D82), // Azul para el borde de confirmación
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color(0xFF003D82), // Azul cuando está enfocado
                        width: 1.5,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 30),
                
                // ========== BOTÓN PARA CREAR CUENTA ==========
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, Routes.welcome);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF8C42), // Naranja del botón
                    minimumSize: Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
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
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}