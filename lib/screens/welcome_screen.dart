import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../routes.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  // ========== LISTA DE IMÁGENES DEL CARRUSEL ==========
  final List<String> imgList = [
    'assets/welcome/welcome.png',
    'assets/welcome/welcome2.png',
    'assets/welcome/welcome3.png',
    'assets/welcome/welcome4.jpg',
    'assets/welcome/welcome5.png',
  ];

  // ========== TEXTOS PARA CADA IMAGEN ==========
  final List<String> textList = [
    'Tu viaje hacia una mejor versión empieza hoy, y no lo harás solo. ¡Bienvenido a Kronos Fit!',
    'Planifica y orgaliza tus rutinas facilmente. Con nuestro calendario interactivo, entrenar será parte de tu día',
    'Motivate con tu mascota virtual. Tu compañero de entrenamiento que celebra cada logro contigo',
    'Registra tu progreso y supera tus récords personales. Convierte cada sesión en una oportunidad para avanzar',
    'Kronos Fit: constancia, motivación y bienestar en un solo lugar. Tu espacio digital para contruir un estilo de vida saludable!',
  ];

  // ========== ÍNDICE ACTUAL DEL CARRUSEL ==========
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ========== CARRUSEL DE IMÁGENES (CON FILTRO DE OPACIDAD) ==========
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: CarouselSlider(
              options: CarouselOptions(
                height: MediaQuery.of(context).size.height,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 3),
                enlargeCenterPage: true,
                viewportFraction: 1.0,
                enableInfiniteScroll: true,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
              items: imgList.map((imagePath) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    // Overlay oscuro para que el texto se vea bien
                    decoration: BoxDecoration(
                      color: Color(0x99000000), // 60% opacity black
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // ========== CONTENIDO: TEXTO, PUNTOS Y BOTONES (CON DISEÑO OSCURO) ==========
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // ========== TEXTO DESCRIPTIVO DE CADA IMAGEN ==========
                Text(
                  textList[_currentIndex],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono_Regular',
                    color: Colors.white, // Texto blanco para contraste
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 20),

                // ========== PUNTOS INDICADORES DEL CARRUSEL ==========
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: imgList.asMap().entries.map((entry) {
                    return Container(
                      width: 8,
                      height: 8,
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == entry.key
                            ? Color(
                                0xFFFF6B35,
                              ) // Naranja vibrante para el activo
                            : Color(
                                0x80FFFFFF,
                              ), // 50% opacity white para inactivos
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 30),

                // ========== BOTÓN "CREAR CUENTA" (CON ESTILO CONSISTENTE) ==========
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1e3a8a), Color(0xFF2563eb)],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x4D1e3a8a), // 30% opacity
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, Routes.register);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Text(
                      'CREAR CUENTA',
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono_Regular',
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15),

                // ========== TEXTO "YA TENGO CUENTA. INICIAR SESIÓN" ==========
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Ya tengo cuenta. ',
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono_Regular',
                        color: Color(
                          0xB3FFFFFF,
                        ), // 70% opacity white (Colors.white70)
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, Routes.login);
                      },
                      child: Text(
                        'Iniciar Sesión.',
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono_Regular',
                          color: Color(
                            0xFFFF6B35,
                          ), // Naranja vibrante para el enlace
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
