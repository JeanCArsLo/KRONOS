import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import '../routes.dart';
import '../screens/calendar_screen.dart';
import '../screens/home_screen.dart';
import '../screens/record_pr_screen.dart';
import '../screens/workout_area_screen.dart';
import '../screens/Profile_Screen.dart';
import '../screens/edit_profile_screen.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final int currentIndex;

  const MainLayout({super.key, required this.child, this.currentIndex = 0});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false, // ← ESTA ES LA LÍNEA CLAVE
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0a0a0a), Color(0xFF121212), Color(0xFF1a1a1a)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFF0a0a0a),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x4D000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFe0e0e0),
                            Color(0xFFffffff),
                            Color(0xFFc0c0c0),
                            Color(0xFF8d8d8d),
                            Color(0xFFffffff),
                          ],
                          stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                        ).createShader(bounds);
                      },
                      child: Text(
                        'KRONOS FIT',
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono_Regular',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: widget.child),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: SizedBox(
          width: screenWidth - 16,
          height: 70,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(screenWidth - 16, 70),
                painter: NotchNavBarPainter(
                  ballPositionRatio: _getBallPositionRatio(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavIcon(
                      0,
                      Icons.calendar_today_outlined,
                      Icons.calendar_today,
                    ),
                    _buildNavIcon(
                      1,
                      Icons.fitness_center_outlined,
                      Icons.fitness_center,
                    ),
                    _buildNavIcon(2, Icons.home_outlined, Icons.home),
                    _buildNavIcon(
                      3,
                      Icons.military_tech_outlined,
                      Icons.military_tech,
                    ),
                    _buildNavIcon(4, Icons.person_outline, Icons.person),
                  ],
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                top: -25,
                left: _getBallPosition(screenWidth),
                child: TweenAnimationBuilder<double>(
                  key: ValueKey(widget.currentIndex),
                  tween: Tween(begin: -40.0, end: 0.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, value),
                      child: Container(
                        width: 65,
                        height: 65,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFe0e0e0),
                              Color(0xFFc0c0c0),
                              Color(0xFF8d8d8d),
                              Color(0xFFffffff),
                            ],
                            stops: [0.0, 0.4, 0.7, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x66ffffff),
                              blurRadius: 25,
                              spreadRadius: 3,
                            ),
                            BoxShadow(
                              color: Color(0x66000000),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          _getActiveIcon(widget.currentIndex),
                          color: Color(0xFF2d2d2d),
                          size: 28,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  double _getBallPositionRatio() {
    switch (widget.currentIndex) {
      case 0:
        return 0.1;
      case 1:
        return 0.3;
      case 2:
        return 0.5;
      case 3:
        return 0.7;
      case 4:
        return 0.9;
      default:
        return 0.5;
    }
  }

  double _getBallPosition(double screenWidth) {
    final containerWidth = screenWidth - 16;
    final iconWidth = containerWidth / 5;

    switch (widget.currentIndex) {
      case 0:
        return iconWidth * 0.5 - 32.5;
      case 1:
        return iconWidth * 1.5 - 32.5;
      case 2:
        return iconWidth * 2.5 - 32.5;
      case 3:
        return iconWidth * 3.5 - 32.5;
      case 4:
        return iconWidth * 4.5 - 32.5;
      default:
        return iconWidth * 2.5 - 32.5;
    }
  }

  IconData _getActiveIcon(int index) {
    switch (index) {
      case 0:
        return Icons.calendar_today;
      case 1:
        return Icons.fitness_center;
      case 2:
        return Icons.home;
      case 3:
        return Icons.military_tech;
      case 4:
        return Icons.person;
      default:
        return Icons.home;
    }
  }

  Widget _buildNavIcon(int index, IconData icon, IconData activeIcon) {
    final isActive = widget.currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _navigateTo(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Icon(
            isActive ? activeIcon : icon,
            color: isActive ? Colors.transparent : Color(0xFFe0e0e0),
            size: 24,
          ),
        ),
      ),
    );
  }

  void _navigateTo(int index) {
    Widget screen;
    switch (index) {
      case 0:
        screen = const CalendarScreen();
        break;
      case 1:
        screen = const RecordPRScreen();
        break;
      case 2:
        screen = const HomeScreen();
        break;
      case 3:
        screen = const WorkoutAreaScreen();
        break;
      case 4:
        screen = const ProfileScreen();
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        duration: const Duration(milliseconds: 300),
        child: screen,
      ),
    );
  }
}

class NotchNavBarPainter extends CustomPainter {
  final double ballPositionRatio;

  NotchNavBarPainter({required this.ballPositionRatio});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF3d3d3d),
          Color(0xFF5a5a5a),
          Color(0xFF7a7a7a),
          Color(0xFF5a5a5a),
          Color(0xFF3d3d3d),
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final ballX = size.width * ballPositionRatio;
    final notchWidth = 30.0;
    final notchDepth = 15.0;
    final cornerRadius = 35.0;

    path.moveTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0);
    path.lineTo(ballX - notchWidth, 0);
    path.quadraticBezierTo(
      ballX - notchWidth * 0.5,
      notchDepth,
      ballX,
      notchDepth,
    );
    path.quadraticBezierTo(
      ballX + notchWidth * 0.5,
      notchDepth,
      ballX + notchWidth,
      0,
    );
    path.lineTo(size.width - cornerRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);
    path.lineTo(size.width, size.height - cornerRadius);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - cornerRadius,
      size.height,
    );
    path.lineTo(cornerRadius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);
    path.close();

    canvas.drawShadow(path, Color(0x4D000000), 12, true);
    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          Color(0x66c0c0c0),
          Color(0x4Dffffff),
          Color(0x66c0c0c0),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, 2))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(NotchNavBarPainter oldDelegate) {
    return oldDelegate.ballPositionRatio != ballPositionRatio;
  }
}
