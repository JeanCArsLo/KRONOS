import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/register_controller.dart';
import '../routes.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterController(),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatelessWidget {
  const _RegisterView();

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<RegisterController>(context);

    return Scaffold(
      body: Stack(
        children: [
          Image.asset('assets/gym/gym7.jpg', fit: BoxFit.cover, width: double.infinity, height: double.infinity),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xCC000000), Color(0xE6000000)],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    const Text('Sign Up', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w300, color: Colors.white)),
                    const SizedBox(height: 30),

                    // === PASO 1: CORREO ===
                    if (controller.currentStep == 1) ...[
                      _buildLabel('Correo Electrónico'),
                      const SizedBox(height: 12),
                      _buildTextField(controller.emailController, 'ejemplo@gmail.com', TextInputType.emailAddress),
                      const SizedBox(height: 30),
                      _buildButton('ENVIAR CÓDIGO', controller.isLoading, () async {
                        final error = await controller.sendOtp();
                        if (error != null && context.mounted) _showError(context, error);
                      }),
                    ]

                    // === PASO 2: OTP ===
                    else if (controller.currentStep == 2) ...[
                      Text('Código enviado a:', style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 14)),
                      Text(controller.emailController.text, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                      const SizedBox(height: 20),
                      _buildOtpField(controller.otpController),
                      const SizedBox(height: 20),
                      _buildButton('VERIFICAR CÓDIGO', false, () {
                        final error = controller.verifyOtp();
                        if (error != null) _showError(context, error);
                      }),
                      TextButton(
                        onPressed: controller.resendTimer > 0 ? null : () => controller.sendOtp(),
                        child: Text(
                          controller.resendTimer > 0 ? 'Reenviar en ${controller.resendTimer}s' : 'Reenviar código',
                          style: TextStyle(color: controller.resendTimer > 0 ? Colors.white54 : const Color(0xFF1976D2)),
                        ),
                      ),
                    ]

                    // === PASO 3: FORMULARIO ===
                    else if (controller.currentStep == 3) ...[
                      _buildLabel('Nombres y Apellidos'),
                      const SizedBox(height: 12),
                      _buildTextField(controller.fullNameController, 'Juan Pérez'),
                      const SizedBox(height: 20),

                      _buildLabel('Fecha de Nacimiento'),
                      const SizedBox(height: 12),
                      _buildDateField(context, controller),
                      const SizedBox(height: 20),

                      _buildLabel('Género'),
                      const SizedBox(height: 12),
                      _buildGenderSelector(controller),
                      const SizedBox(height: 20),

                      _buildLabel('Contraseña'),
                      const SizedBox(height: 12),
                      _buildPasswordField(controller.passwordController, controller.obscurePassword, controller.togglePassword),
                      const SizedBox(height: 12),
                      _buildPasswordRequirements(controller),
                      const SizedBox(height: 20),

                      _buildLabel('Confirmar Contraseña'),
                      const SizedBox(height: 12),
                      _buildPasswordField(controller.confirmPasswordController, controller.obscureConfirmPassword, controller.toggleConfirmPassword),
                      const SizedBox(height: 30),

                      _buildButton('CREAR CUENTA', controller.isLoading, () async {
                        final error = await controller.register(context);
                        if (error != null && context.mounted) _showError(context, error);
                      }),
                    ],

                    const SizedBox(height: 20),
                    _buildLoginLink(context),
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
        child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
      );

  Widget _buildTextField(TextEditingController c, String hint, [TextInputType? kt]) => Container(
        decoration: BoxDecoration(
          color: const Color(0x0DFFFFFF),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0x1AFFFFFF)),
        ),
        child: TextField(
          controller: c,
          keyboardType: kt,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0x4DFFFFFF)),
            border: InputBorder.none,
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      );

  Widget _buildPasswordField(TextEditingController c, bool obscure, VoidCallback toggle) => Container(
        decoration: BoxDecoration(
          color: const Color(0x0DFFFFFF),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0x1AFFFFFF)),
        ),
        child: TextField(
          controller: c,
          obscureText: obscure,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Contraseña segura',
            hintStyle: const TextStyle(color: Color(0x4DFFFFFF)),
            border: InputBorder.none,
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            suffixIcon: IconButton(icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.white70), onPressed: toggle),
          ),
        ),
      );

  Widget _buildOtpField(TextEditingController c) => TextField(
        controller: c,
        keyboardType: TextInputType.number,
        maxLength: 6,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold, color: Colors.white),
        decoration: InputDecoration(
          hintText: '------',
          hintStyle: const TextStyle(color: Color(0x4DFFFFFF)),
          counterText: '',
          filled: true,
          fillColor: const Color(0x0DFFFFFF),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0x1AFFFFFF))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2)),
        ),
      );

  Widget _buildButton(String text, bool isLoading, VoidCallback? onPressed) => SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1976D2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
          child: isLoading
              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        ),
      );

  Widget _buildDateField(BuildContext context, RegisterController c) => GestureDetector(
        onTap: () async {
          final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime.now());
          if (date != null) c.selectDate(date);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(color: const Color(0x0DFFFFFF), borderRadius: BorderRadius.circular(28), border: Border.all(color: const Color(0x1AFFFFFF))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(c.selectedDate == null ? 'Selecciona una fecha' : '${c.selectedDate!.day}/${c.selectedDate!.month}/${c.selectedDate!.year}', style: TextStyle(color: c.selectedDate == null ? const Color(0x4DFFFFFF) : Colors.white)),
              const Icon(Icons.calendar_today, color: Color(0x99FFFFFF), size: 20),
            ],
          ),
        ),
      );

  Widget _buildGenderSelector(RegisterController c) => Row(
        children: [
          Expanded(child: _genderButton('Hombre', 'M', c)),
          const SizedBox(width: 12),
          Expanded(child: _genderButton('Mujer', 'F', c)),
        ],
      );

  Widget _genderButton(String label, String value, RegisterController c) => GestureDetector(
        onTap: () => c.setGender(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: c.selectedGender == value ? const Color(0x4D1976D2) : const Color(0x0DFFFFFF),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: c.selectedGender == value ? const Color(0xFF1976D2) : const Color(0x1AFFFFFF), width: c.selectedGender == value ? 2 : 1),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(c.selectedGender == value ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: c.selectedGender == value ? const Color(0xFF1976D2) : const Color(0x80FFFFFF), size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: c.selectedGender == value ? Colors.white : const Color(0xB3FFFFFF), fontWeight: c.selectedGender == value ? FontWeight.bold : FontWeight.normal)),
          ]),
        ),
      );

  Widget _buildPasswordRequirements(RegisterController c) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0x0DFFFFFF), border: Border.all(color: const Color(0x1AFFFFFF)), borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Tu contraseña debe contener:', style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 12)),
          const SizedBox(height: 6),
          _reqItem('Mínimo 8 caracteres', c.hasMinLength),
          _reqItem('Al menos una mayúscula', c.hasUppercase),
          _reqItem('Al menos un número', c.hasNumber),
          _reqItem('Al menos un carácter especial', c.hasSpecialChar),
          _reqItem('No puede ser solo números', c.notOnlyNumbers),
        ]),
      );

  Widget _reqItem(String text, bool valid) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(children: [
          Icon(valid ? Icons.check_circle : Icons.radio_button_unchecked, size: 16, color: valid ? Colors.green : const Color(0x80FFFFFF)),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontSize: 12, color: valid ? Colors.green[300] : const Color(0xB3FFFFFF), fontWeight: valid ? FontWeight.w500 : FontWeight.w400)),
        ]),
      );

  Widget _buildLoginLink(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('¿Ya tienes una cuenta? ', style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 14)),
          TextButton(onPressed: () => Navigator.pushReplacementNamed(context, Routes.login), child: const Text('Inicia Sesión', style: TextStyle(color: Color(0xFF1976D2), fontWeight: FontWeight.bold))),
        ],
      );

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }
}