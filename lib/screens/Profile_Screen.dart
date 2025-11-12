// screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../routes.dart';
import '../services/auth_service.dart';
import 'dart:io'; // ← NUEVO
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
      Navigator.pushNamedAndRemoveUntil(context, Routes.welcome, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 4,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // FOTO DE PERFIL
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xFF003D82),
                    child: CircleAvatar(
                      radius: 56,
                      backgroundColor: Colors.white,
                      backgroundImage: _user?.photoPath != null && File(_user!.photoPath!).existsSync()
                          ? FileImage(File(_user!.photoPath!))
                          : null,
                      child: _user?.photoPath == null || !File(_user!.photoPath!).existsSync()
                          ? const Icon(Icons.person, size: 70, color: Color(0xFF003D82))
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // BOTÓN EDITAR PERFIL
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.pushNamed(context, Routes.editProfile);
                      if (result == true && mounted) {
                        await _loadUser(); // ← RECARGA EL USUARIO
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8C42),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: const Text(
                      'Editar Perfil',
                      style: TextStyle(fontFamily: 'JetBrainsMono_Regular', color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // NOMBRE
                  _buildInfoRow('Nombre', _user?.fullName ?? 'Usuario'),
                  const Divider(height: 32, thickness: 0.5, color: Colors.grey),

                  // FECHA DE NACIMIENTO
                  _buildInfoRow(
                    'Fecha de Nacimiento',
                    _user?.birthDate != null
                        ? '${_user!.birthDate.day.toString().padLeft(2, '0')}-${_user!.birthDate.month.toString().padLeft(2, '0')}-${_user!.birthDate.year}'
                        : '16-05-2004',
                  ),
                  const Divider(height: 32, thickness: 0.5, color: Colors.grey),

                  // GÉNERO → AHORA MISMO PATRÓN
                  _buildInfoRow('Género', _user?.gender == 'F' ? 'Mujer' : 'Hombre'),
                  const SizedBox(height: 60),

                  // SALIR
                  TextButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout, color: Color(0xFFFF8C42)),
                    label: const Text(
                      'Salir de la cuenta',
                      style: TextStyle(color: Color(0xFFFF8C42), fontFamily: 'JetBrainsMono_Regular'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ÚNICO MÉTODO DE ESTILO (TODOS LOS CAMPOS)
  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ],
    );
  }
}