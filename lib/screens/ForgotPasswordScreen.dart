import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/forgot_password_controller.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ForgotPasswordController(),
      child: const _ForgotPasswordView(),
    );
  }
}

class _ForgotPasswordView extends StatelessWidget {
  const _ForgotPasswordView();

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ForgotPasswordController>(context);
    final String backgroundImage = 'assets/gym/gym6.jpg';

    return Scaffold(
      body: Stack(
        children: [
          // Fondo
          Image.asset(backgroundImage, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.8), Colors.black.withOpacity(0.9)],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Botón de regreso
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

                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'Cambiar Contraseña',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w400, color: Colors.white, letterSpacing: 1.5),
                            ),
                          ),
                          const SizedBox(height: 30),

                          // === PASO 1 ===
                          if (controller.currentStep == 1) ...[
                            Text(
                              'Ingresa tu correo para recibir un código',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 35),
                            _buildInputField(
                              controller: controller.emailController,
                              label: 'Correo Electrónico',
                              hint: 'ejemplo@correo.com',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 50),
                            ElevatedButton(
                              onPressed: controller.isLoading ? null : () async {
                                final error = await controller.sendCode();
                                if (error != null && context.mounted) {
                                  _showSnackBar(context, error, Colors.red);
                                } else if (context.mounted) {
                                  _showSnackBar(context, 'Código enviado', Colors.green);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF8C42),
                                minimumSize: const Size(double.infinity, 55),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                              child: controller.isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text('ENVIAR CÓDIGO', style: TextStyle(color: Colors.white, fontFamily: 'JetBrainsMono_Regular')),
                            ),
                          ]

                          // === PASO 2 ===
                          else if (controller.currentStep == 2) ...[
                            Text('Código enviado a:', style: TextStyle(color: Colors.grey[700])),
                            Text(controller.emailController.text, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 20),
                            _buildInputField(
                              controller: controller.otpController,
                              label: 'Código de Verificación',
                              hint: '------',
                              icon: Icons.lock_outline,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                final error = controller.verifyCode();
                                if (error != null) {
                                  _showSnackBar(context, error, Colors.red);
                                } else {
                                  _showSnackBar(context, 'Código correcto', Colors.green);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF8C42),
                                minimumSize: const Size(double.infinity, 55),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                              child: const Text('VERIFICAR', style: TextStyle(color: Colors.white, fontFamily: 'JetBrainsMono_Regular')),
                            ),
                            TextButton(
                              onPressed: controller.resendTimer > 0 ? null : () => controller.sendCode(),
                              child: Text(
                                controller.resendTimer > 0 ? 'Reenviar en ${controller.resendTimer}s' : 'Reenviar',
                                style: TextStyle(color: controller.resendTimer > 0 ? Colors.grey : const Color(0xFFFF8C42)),
                              ),
                            ),
                          ]

                          // === PASO 3 ===
                          else if (controller.currentStep == 3) ...[
                            _buildInputField(
                              controller: controller.newPasswordController,
                              label: 'Nueva Contraseña',
                              hint: 'Contraseña segura',
                              icon: Icons.lock_outline,
                              obscureText: controller.obscureNew,
                              suffixIcon: IconButton(
                                icon: Icon(controller.obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.white70, size: 22),
                                onPressed: controller.toggleNewPassword,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildPasswordRequirements(controller),
                            const SizedBox(height: 20),
                            _buildInputField(
                              controller: controller.confirmPasswordController,
                              label: 'Confirmar Contraseña',
                              hint: 'Confirmar contraseña',
                              icon: Icons.lock_outline,
                              obscureText: controller.obscureConfirm,
                              suffixIcon: IconButton(
                                icon: Icon(controller.obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.white70, size: 22),
                                onPressed: controller.toggleConfirmPassword,
                              ),
                            ),
                            const SizedBox(height: 40),
                            ElevatedButton(
                              onPressed: controller.isLoading ? null : () async {
                                final error = await controller.changePassword(context);
                                if (error != null && context.mounted) {
                                  _showSnackBar(context, error, Colors.red);
                                } else if (context.mounted) {
                                  _showSnackBar(context, '¡Contraseña cambiada!', Colors.green);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF8C42),
                                minimumSize: const Size(double.infinity, 55),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                              child: controller.isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text('CAMBIAR CONTRASEÑA', style: TextStyle(color: Colors.white, fontFamily: 'JetBrainsMono_Regular')),
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

  // === WIDGETS AUXILIARES ===
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.5)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            maxLength: maxLength,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 15),
              prefixIcon: Icon(icon, color: Colors.white60, size: 22),
              suffixIcon: suffixIcon,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2)),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              counterText: maxLength != null ? '${controller.text.length}/$maxLength' : '',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordRequirements(ForgotPasswordController c) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Requisitos:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70)),
            _req('8+ caracteres', c.hasMinLength),
            _req('Mayúscula', c.hasUppercase),
            _req('Número', c.hasNumber),
            _req('Especial', c.hasSpecialChar),
            _req('No solo números', c.notOnlyNumbers),
          ],
        ),
      );

  Widget _req(String t, bool v) => Row(
        children: [
          Icon(v ? Icons.check_circle : Icons.radio_button_unchecked, size: 16, color: v ? Colors.green : Colors.grey),
          const SizedBox(width: 6),
          Text(t, style: TextStyle(fontSize: 12, color: v ? Colors.green : Colors.white70)),
        ],
      );

  void _showSnackBar(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }
}