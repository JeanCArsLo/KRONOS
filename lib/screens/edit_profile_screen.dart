// screens/edit_profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../routes.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../widgets/main_layout.dart';
import '../db/database_helper.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  User? _user;
  File? _image;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _authService.getCurrentUser();
    if (user != null && mounted) {
      setState(() {
        _user = user;
        _nameController.text = user.fullName;
        if (user.photoPath != null && File(user.photoPath!).existsSync()) {
          _image = File(user.photoPath!);
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = path.basename(pickedFile.path);
      final savedImage = await File(
        pickedFile.path,
      ).copy('${appDir.path}/$fileName');
      setState(() => _image = savedImage);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final dbHelper = DatabaseHelper();
      final userId = _user!.id;

      await dbHelper.updateUserName(userId, _nameController.text.trim());

      if (_image != null) {
        await dbHelper.updateUserPhoto(userId, _image!.path);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Perfil actualizado!'),
            backgroundColor: Color(0xFF2563eb), // Color azul en lugar de verde
          ),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 4,
      child: Scaffold(
        backgroundColor: Colors
            .transparent, // Fondo transparente para mostrar el degradado de MainLayout
        body: _user == null
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF2563eb)),
              )
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),

                      // ========== SOLO LA PALABRA "EDITAR PERFIL" EN EL CENTRO ==========
                      Center(
                        child: Text(
                          'EDITAR PERFIL',
                          style: const TextStyle(
                            fontFamily: 'JetBrainsMono_Regular',
                            fontSize: 24, // Tamaño grande y visible
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: Colors.white, // Color blanco
                          ),
                        ),
                      ),

                      // ✅ QUITADA LA RAYA AZUL: const Divider(...),
                      const SizedBox(height: 30),

                      // ========== FOTO DE PERFIL CON BORDE GRADIENTE ==========
                      Stack(
                        children: [
                          Container(
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
                              radius: 60, // Ajustado para el padding
                              backgroundColor: Color(
                                0xFF1A1A1A,
                              ), // Fondo oscuro dentro del borde
                              backgroundImage: _image != null
                                  ? FileImage(_image!)
                                  : null,
                              child: _image == null
                                  ? Icon(
                                      Icons.person_outline,
                                      size: 60, // Ajustado
                                      color: Color(0xFF505050),
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 5, // Ajustado para centrar el botón
                            right: 5,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Color(
                                    0xFF2563eb,
                                  ), // Azul en lugar de naranja
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Color(0xFFC0C0C0), // Borde plateado
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // ========== CAMPO DE NOMBRE CON ESTILO ==========
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Color(
                            0xFF1A1A1A,
                          ), // Fondo oscuro para el campo
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Color(0xFF303030), // Borde sutil
                            width: 1,
                          ),
                        ),
                        child: TextFormField(
                          controller: _nameController,
                          validator: (val) =>
                              val!.trim().isEmpty ? 'Ingresa tu nombre' : null,
                          style: const TextStyle(
                            color: Color(0xFFE0E0E0), // Texto plateado
                            fontFamily: 'JetBrainsMono_Regular',
                          ),
                          decoration: InputDecoration(
                            labelText: 'Nombre completo',
                            labelStyle: const TextStyle(
                              color: Color(0xFF808080), // Etiqueta gris clara
                              fontFamily: 'JetBrainsMono_Regular',
                              fontSize: 12,
                            ),
                            // Elimina el borde predeterminado
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors
                                    .transparent, // Borde inferior transparente
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(
                                  0xFF2563eb,
                                ), // Borde inferior azul al enfocar
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal:
                                  0, // El padding horizontal ya lo maneja el contenedor exterior
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // ========== BOTÓN GUARDAR CON ESTILO ==========
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _saveProfile,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ), // Ajustado padding
                            side: BorderSide(
                              color: Color(0xFF2563eb), // Borde azul
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Colors.transparent,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Color(0xFF2563eb),
                                  strokeWidth: 2, // Ajustado para consistencia
                                )
                              : const Text(
                                  'GUARDAR',
                                  style: TextStyle(
                                    fontFamily: 'JetBrainsMono_Regular',
                                    fontSize: 14,
                                    color: Color(0xFF2563eb), // Texto azul
                                    letterSpacing: 1.0,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
