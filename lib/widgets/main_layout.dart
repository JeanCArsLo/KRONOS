import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart'; // 👈 Importa la librería
import '../routes.dart';
import '../screens/calendar_screen.dart';
import '../screens/home_screen.dart';
import '../screens/record_pr_screen.dart';
import '../screens/workout_area_screen.dart';
import '../screens/Profile_Screen.dart';

class MainLayout extends StatefulWidget {
  final Widget child; // ← El contenido que cambia
  final int currentIndex; // ← Para saber qué icono marcar

  const MainLayout({super.key, required this.child, this.currentIndex = 0});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Fondo oscuro principal
      body: SafeArea(
        child: Column(
          children: [
            // ========== LOGO "KRONOS FIT" (FIJO) ==========
            Container(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'KRONOS FIT',
                    style: TextStyle(
                      fontFamily:
                          'JetBrainsMono_Regular', // Cambiado a tu fuente
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Colors.white, // Texto blanco para contraste
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey[700]),

            // ========== CONTENIDO QUE CAMBIA ==========
            Expanded(child: widget.child),

            // ========== BARRA DE NAVEGACIÓN INFERIOR (FIJA) ==========
            Container(
              height: 80, // Altura para acomodar el diseño curvo
              decoration: BoxDecoration(
                color: const Color(0xFF1a1a1a), // Fondo oscuro para la barra
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // ========== CURVA CENTRAL (como en la imagen) ==========
                  Positioned.fill(
                    child: CustomPaint(
                      size: Size(double.infinity, 80),
                      painter: BottomBarCurvePainter(),
                    ),
                  ),
                  // ========== ICONOS DE NAVEGACIÓN ==========
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(
                        index: 0,
                        icon: Icons.calendar_today_outlined,
                        activeIcon: Icons.calendar_today,
                        label: 'Calendar',
                      ),
                      _buildNavItem(
                        index: 1,
                        icon: Icons.military_tech_outlined,
                        activeIcon: Icons.military_tech,
                        label: 'Record PR',
                      ),
                      // Botón central Home
                      _buildNavItem(
                        index: 2,
                        icon: Icons.home_outlined,
                        activeIcon: Icons.home,
                        label: 'Home',
                      ),
                      _buildNavItem(
                        index: 3,
                        icon: Icons.fitness_center_outlined,
                        activeIcon: Icons.fitness_center,
                        label: 'Workouts',
                      ),
                      _buildNavItem(
                        index: 4,
                        icon: Icons.person_outline,
                        activeIcon: Icons.person,
                        label: 'Profile',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para construir cada ítem de navegación
  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isActive = widget.currentIndex == index;
    return GestureDetector(
      onTap: () {
        // Usar PageTransition para una transición suave
        switch (index) {
          case 0:
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                duration: Duration(milliseconds: 300),
                child: CalendarScreen(), // ← Widget directo
              ),
            );
            break;
          case 1:
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                duration: Duration(milliseconds: 300),
                child: RecordPRScreen(), // ← Widget directo
              ),
            );
            break;
          case 2:
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                duration: Duration(milliseconds: 300),
                child: HomeScreen(), // ← Widget directo
              ),
            );
            break;
          case 3:
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                duration: Duration(milliseconds: 300),
                child: WorkoutAreaScreen(), // ← Widget directo
              ),
            );
            break;
          case 4:
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                duration: Duration(milliseconds: 300),
                child: ProfileScreen(), // ← Widget directo
              ),
            );
            break;
        }
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive
              ? const Color(0xFF1e3a8a)
              : null, // Azul oscuro energético para el activo
        ),
        child: Center(
          child: Icon(
            isActive ? activeIcon : icon,
            color: isActive
                ? Colors.white
                : Colors
                      .white70, // Blanco para activo, gris claro para inactivo
            size: 24,
          ),
        ),
      ),
    );
  }
}

// Clase para pintar la curva central
class BottomBarCurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.35, 0)
      ..quadraticBezierTo(size.width * 0.5, 0, size.width * 0.65, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final paint = Paint()
      ..color =
          const Color(0xFF1a1a1a) // Mismo fondo oscuro
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
