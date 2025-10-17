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
    'assets/welcome/welcome.jpg',
    'assets/welcome/welcome2.jpg',
    'assets/welcome/welcome3.jpg',
    'assets/welcome/welcome4.jpg',
  ];

  // ========== TEXTOS PARA CADA IMAGEN ==========
  final List<String> textList = [
    'Tu viaje hacia una mejor versión empieza hoy, y no lo harás solo. ¡Bienvenido a Kronos Fit!',
    'Transforma tu cuerpo y tu mente con nuestros planes personalizados',
    'Entrena donde quieras, cuando quieras, a tu ritmo',
    'Únete a nuestra comunidad y alcanza tus metas',
  ];

  // ========== ÍNDICE ACTUAL DEL CARRUSEL ==========
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ========== CARRUSEL DE IMÁGENES ==========
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
                );
              }).toList(),
            ),
          ),

          // ========== DIFUMINADO EN LA PARTE INFERIOR ==========
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color.fromARGB(0, 235, 235, 235),
                    const Color.fromARGB(255, 255, 255, 255).withValues(alpha: 0xB3), // 70% de opacidad aprox.
                    const Color.fromARGB(255, 255, 255, 255).withValues(alpha: 0xE6), // 90% de opacidad aprox.
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // ========== CONTENIDO: TEXTO, PUNTOS Y BOTONES ==========
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
                    color: const Color.fromARGB(255, 0, 0, 0),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
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
                            ? const Color.fromARGB(255, 0, 0, 0)
                            : const Color.fromARGB(255, 102, 100, 100).withValues(alpha: 0x66),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 30),

                // ========== BOTÓN "CREAR CUENTA" ==========
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, Routes.register);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF003D82),
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'CREAR CUENTA',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono_Regular',
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
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
                        color: const Color.fromARGB(255, 0, 0, 0),
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
                          color: Colors.orange,
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