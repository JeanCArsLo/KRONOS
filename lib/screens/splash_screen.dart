import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late AnimationController _shakeController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    // Animación de escala (impacto)
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    // Animación de resplandor pulsante
    _glowController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Animación de shake (sacudida)
    _shakeController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _startAnimations();
    _navigateToWelcome();
  }

  void _startAnimations() async {
    await Future.delayed(Duration(milliseconds: 100));
    _scaleController.forward();
    _shakeController.forward();
  }

  _navigateToWelcome() async {
    await Future.delayed(Duration(seconds: 8));
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, Routes.welcome);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a1a1a), // Negro
              Color(0xFF2d2d2d), // Gris oscuro
              Color(0xFF1a1a1a), // Negro
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _scaleController,
              _glowController,
              _shakeController,
            ]),
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(math.sin(_shakeAnimation.value) * 5, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo principal con todos los efectos
                    Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Resplandor exterior (glow)
                          AnimatedBuilder(
                            animation: _glowAnimation,
                            builder: (context, child) {
                              return Container(
                                width: 300 * _glowAnimation.value,
                                height: 100 * _glowAnimation.value,
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(
                                        0xFFc0c0c0,
                                      ).withOpacity(0.3 * _glowAnimation.value),
                                      blurRadius: 60,
                                      spreadRadius: 20,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          // Texto principal con gradiente metálico
                          ShaderMask(
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF8d8d8d), // Gris medio
                                  Color(0xFFffffff), // Blanco brillante
                                  Color(0xFFc0c0c0), // Plateado
                                  Color(0xFF6b6b6b), // Gris oscuro
                                  Color(0xFFffffff), // Blanco brillante
                                ],
                                stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                              ).createShader(bounds);
                            },
                            child: Text(
                              'KRONOS',
                              style: TextStyle(
                                fontFamily: 'AldrichRegular',
                                fontSize: 60,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 4,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.8),
                                    offset: Offset(0, 4),
                                    blurRadius: 8,
                                  ),
                                  Shadow(
                                    color: Color(0xFFc0c0c0).withOpacity(0.5),
                                    offset: Offset(0, 0),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
