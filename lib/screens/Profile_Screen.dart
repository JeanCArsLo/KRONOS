// screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../routes.dart';
import '../services/auth_service.dart';
import 'dart:io';
import '../models/user.dart';
import '../widgets/main_layout.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await _authService.getCurrentUser();
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.welcome,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 4,
      child: Container(
        color: Color(0xFF0A0A0A),
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: Color(0xFF2563eb)))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 30),

                    // ========== FOTO DE PERFIL CLICKEABLE ==========
                    GestureDetector(
                      onTap: () {
                        if (_user?.photoPath != null &&
                            File(_user!.photoPath!).existsSync()) {
                          showDialog(
                            context: context,
                            barrierColor: Color(0xE6000000),
                            builder: (context) => Dialog(
                              backgroundColor: Colors.transparent,
                              insetPadding: EdgeInsets.all(20),
                              child: Stack(
                                children: [
                                  Container(
                                    constraints: BoxConstraints(
                                      maxHeight:
                                          MediaQuery.of(context).size.height *
                                          0.7,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Color(0xFF1A1A1A),
                                      border: Border.all(
                                        color: Color(0xFFC0C0C0),
                                        width: 2,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(17),
                                      child: Image.file(
                                        File(_user!.photoPath!),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color(0xFF1A1A1A),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Color(0xFFC0C0C0),
                                            width: 2,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFE0E0E0),
                              Color(0xFFC0C0C0),
                              Color(0xFF8D8D8D),
                            ],
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: Color(0xFF1A1A1A),
                          backgroundImage:
                              _user?.photoPath != null &&
                                  File(_user!.photoPath!).existsSync()
                              ? FileImage(File(_user!.photoPath!))
                              : null,
                          child:
                              _user?.photoPath == null ||
                                  !File(_user!.photoPath!).existsSync()
                              ? Icon(
                                  Icons.person_outline,
                                  size: 50,
                                  color: Color(0xFF505050),
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // ========== BOTÓN EDITAR PERFIL ==========
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            Routes.editProfile,
                          );
                          if (result == true && mounted) {
                            await _loadUser();
                          }
                        },
                        icon: Icon(
                          Icons.edit_outlined,
                          size: 16,
                          color: Color(0xFFFF8C00),
                        ),
                        label: Text(
                          'Editar perfil',
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono_Regular',
                            fontSize: 13,
                            color: Color(0xFFFF8C00),
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: Color(0xFFFF8C00), width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // ========== INFORMACIÓN DEL USUARIO ==========
                    Container(
                      padding: EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFF303030), width: 1),
                      ),
                      child: Column(
                        children: [
                          // NOMBRE
                          _buildInfoRow(
                            Icons.person_outline,
                            'Nombre',
                            _user?.fullName ?? 'Usuario',
                          ),

                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Divider(
                              height: 1,
                              thickness: 1,
                              color: Color(0xFF303030),
                            ),
                          ),

                          // FECHA DE NACIMIENTO
                          _buildInfoRow(
                            Icons.calendar_today_outlined,
                            'Fecha de Nacimiento',
                            _user?.birthDate != null
                                ? '${_user!.birthDate.day.toString().padLeft(2, '0')}-${_user!.birthDate.month.toString().padLeft(2, '0')}-${_user!.birthDate.year}'
                                : '16-05-2004',
                          ),

                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Divider(
                              height: 1,
                              thickness: 1,
                              color: Color(0xFF303030),
                            ),
                          ),

                          // GÉNERO
                          _buildInfoRow(
                            _user?.gender == 'F' ? Icons.female : Icons.male,
                            'Género',
                            _user?.gender == 'F' ? 'Mujer' : 'Hombre',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 50),

                    // ========== BOTÓN CERRAR SESIÓN ==========
                    TextButton.icon(
                      onPressed: _logout,
                      icon: Icon(
                        Icons.logout,
                        color: Color(0xFFFF8C00),
                        size: 18,
                      ),
                      label: Text(
                        'Cerrar sesión',
                        style: TextStyle(
                          color: Color(0xFFFF8C00),
                          fontFamily: 'JetBrainsMono_Regular',
                          fontSize: 13,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
      ),
    );
  }

  // ========== WIDGET DE INFORMACIÓN ==========
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFFC0C0C0), size: 20),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'JetBrainsMono_Regular',
                  fontSize: 11,
                  color: Color(0xFF808080),
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'JetBrainsMono_Regular',
                  fontSize: 15,
                  color: Color(0xFFE0E0E0),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
