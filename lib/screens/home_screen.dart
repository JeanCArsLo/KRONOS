import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../widgets/main_layout.dart';
import '../dialogs/trainer_detail_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  // ========== IMÁGENES DEL CARRUSEL ==========
  final List<String> carouselImages = [
    'assets/gym/gym1.jpg',
    'assets/gym/gym2.jpg',
    'assets/gym/gym3.jpg',
    'assets/gym/gym4.jpg',
    'assets/gym/gym5.jpg',
  ];

  // ========== LISTA DE ENTRENADORES ==========
  final List<Map<String, String>> trainers = [
    {
      'name': 'Sofía',
      'specialty': 'ENTRENADORA PERSONAL Y\nNUTRICIONISTA',
      'image': 'assets/trainers/trainer1.jpg',
      'description':
          'Apasionada por la salud integral.\nTe ayuda a lograr tus metas con nutrición y ejercicio.',
    },
    {
      'name': 'Nick',
      'specialty': 'ENTRENADOR PERSONAL',
      'image': 'assets/trainers/trainer2.jpg',
      'description':
          'Entusiasta, estudioso y enfocado en resultados.\nEntrena contigo para que rompas tus propios límites.',
    },
    {
      'name': 'Carlos',
      'specialty': 'ENTRENADOR FUNCIONAL',
      'image': 'assets/trainers/trainer3.jpg',
      'description':
          'Especialista en movimientos naturales.\nTe enseña a entrenar de forma segura y efectiva.',
    },
    {
      'name': 'María',
      'specialty': 'YOGA Y PILATES',
      'image': 'assets/trainers/trainer4.jpg',
      'description':
          'Experta en flexibilidad y equilibrio mental.\nTe guía hacia la paz y el bienestar corporal.',
    },
  ];

  // ========== ÍNDICE ACTUAL DEL CARRUSEL ==========
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 2,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0a0a0a), Color(0xFF121212), Color(0xFF1a1a1a)],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),

              // ========== CARRUSEL MEJORADO ==========
              Stack(
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 240,
                      autoPlay: true,
                      autoPlayInterval: Duration(seconds: 4),
                      enlargeCenterPage: true,
                      viewportFraction: 0.92,
                      autoPlayCurve: Curves.easeInOutCubic,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                    ),
                    items: carouselImages.map((imagePath) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x4DFF6B35), // 30% opacity
                              blurRadius: 20,
                              offset: Offset(0, 8),
                              spreadRadius: -5,
                            ),
                            BoxShadow(
                              color: Color(0x80000000), // 50% opacity
                              blurRadius: 15,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(imagePath, fit: BoxFit.cover),
                              // Gradient overlay sutil
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Color(0x66000000), // 40% opacity
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              // ========== INDICADORES MEJORADOS ==========
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: carouselImages.asMap().entries.map((entry) {
                  bool isActive = _currentIndex == entry.key;
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: isActive ? 24 : 8,
                    height: 8,
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: isActive
                          ? Color(0xFFFF6B35)
                          : Color(0x4DFFFFFF), // 30% opacity white
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: Color(0x80FF6B35), // 50% opacity
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : [],
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: 40),

              // ========== HEADER DE ENTRENADORES MEJORADO ==========
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Color(0xFFFF6B35),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'ENTRENADORES',
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono_Regular',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Text(
                        'Conoce a nuestro equipo profesional',
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono_Regular',
                          fontSize: 13,
                          color: Color(0x99FFFFFF), // 60% opacity white
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // ========== GRID DE ENTRENADORES MEJORADO ==========
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: trainers.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) =>
                              TrainerDetailDialog(trainer: trainers[index]),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x26FF6B35), // 15% opacity
                              blurRadius: 12,
                              offset: Offset(0, 6),
                              spreadRadius: -4,
                            ),
                            BoxShadow(
                              color: Color(0x66000000), // 40% opacity
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Stack(
                            children: [
                              // Imagen de fondo
                              Positioned.fill(
                                child: Image.asset(
                                  trainers[index]['image']!,
                                  fit: BoxFit.cover,
                                ),
                              ),

                              // Gradient overlay más sofisticado
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Color(0x4D000000), // 30% opacity
                                        Color(0xD9000000), // 85% opacity
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      stops: [0.0, 0.5, 1.0],
                                    ),
                                  ),
                                ),
                              ),

                              // Badge decorativo superior
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0xE6FF6B35), // 90% opacity
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0x66FF6B35), // 40% opacity
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.star,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),

                              // Información del entrenador
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        trainers[index]['name']!,
                                        style: TextStyle(
                                          fontFamily: 'JetBrainsMono_Regular',
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          shadows: [
                                            Shadow(
                                              color: Color(
                                                0x80000000,
                                              ), // 50% opacity
                                              offset: Offset(0, 2),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Color(
                                            0x26FFFFFF,
                                          ), // 15% opacity white
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Color(
                                              0x4DFFFFFF,
                                            ), // 30% opacity white
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          trainers[index]['specialty']!,
                                          style: TextStyle(
                                            fontFamily: 'JetBrainsMono_Regular',
                                            fontSize: 9,
                                            fontWeight: FontWeight.w500,
                                            color: Color(
                                              0xF2FFFFFF,
                                            ), // 95% opacity white
                                            height: 1.3,
                                            letterSpacing: 0.5,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
