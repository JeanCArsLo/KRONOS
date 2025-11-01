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
    'description': 'Apasionada por la salud integral.\nTe ayuda a lograr tus metas con nutrición y ejercicio.',
  },
  {
    'name': 'Nick',
    'specialty': 'ENTRENADOR PERSONAL',
    'image': 'assets/trainers/trainer2.jpg',
    'description': 'Entusiasta, estudioso y enfocado en resultados.\nEntrena contigo para que rompas tus propios límites.',
  },
  {
    'name': 'Carlos',
    'specialty': 'ENTRENADOR FUNCIONAL',
    'image': 'assets/trainers/trainer3.jpg',
    'description': 'Especialista en movimientos naturales.\nTe enseña a entrenar de forma segura y efectiva.',
  },
  {
    'name': 'María',
    'specialty': 'YOGA Y PILATES',
    'image': 'assets/trainers/trainer4.jpg',
    'description': 'Experta en flexibilidad y equilibrio mental.\nTe guía hacia la paz y el bienestar corporal.',
  },
];

  // ========== ÍNDICE ACTUAL DEL CARRUSEL ==========
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 2, // ← Marca el icono de Home
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========== CARRUSEL DE IMÁGENES ==========
            CarouselSlider(
              options: CarouselOptions(
                height: 200,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 4),
                enlargeCenterPage: false,
                viewportFraction: 1.0,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
              items: carouselImages.map((imagePath) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: AssetImage(imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }).toList(),
            ),

            // ========== INDICADORES DEL CARRUSEL ==========
            SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: carouselImages.asMap().entries.map((entry) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == entry.key
                        ? const Color.fromARGB(255, 0, 0, 0)
                        : const Color.fromARGB(255, 95, 95, 95).withValues(alpha: 0x66),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 20),

            // ========== TÍTULO "ENTRENADORES" ==========
            Divider(
              color: Colors.orange,
              thickness: 2,
              indent: 20,
              endIndent: 20,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                ' ENTRENADORES',
                style: TextStyle(
                  fontFamily: 'JetBrainsMono_Regular',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Divider(
              color: Colors.orange,
              thickness: 2,
              indent: 20,
              endIndent: 20,
            ),

            SizedBox(height: 15),

            // ========== GRID DE ENTRENADORES ==========
            
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.75,
                ),
                itemCount: trainers.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => TrainerDetailDialog(
                          trainer: trainers[index],
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Imagen del entrenador
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(10),
                                ),
                                image: DecorationImage(
                                  image: AssetImage(trainers[index]['image']!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          // Información del entrenador
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  trainers[index]['name']!,
                                  style: TextStyle(
                                    fontFamily: 'JetBrainsMono_Regular',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  trainers[index]['specialty']!,
                                  style: TextStyle(
                                    fontFamily: 'JetBrainsMono_Regular',
                                    fontSize: 9,
                                    color: Colors.grey[600],
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}