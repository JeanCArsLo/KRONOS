import 'package:flutter/material.dart';
import '../widgets/main_layout.dart';
import '../routes.dart';

class SuperiorExercisesScreen extends StatefulWidget {
  const SuperiorExercisesScreen({super.key});

  @override
  SuperiorExercisesScreenState createState() => SuperiorExercisesScreenState();
}

class SuperiorExercisesScreenState extends State<SuperiorExercisesScreen> {
  // ========== LISTA DE EJERCICIOS TREN SUPERIOR ==========
  final List<Map<String, String>> exercises = [
    {
      'title': 'Espalda',
      'image': 'assets/workout_area/superior/espalda.jpg',
    },
    {
      'title': 'Hombros',
      'image': 'assets/workout_area/superior/hombro.jpg',
    },
    {
      'title': 'Pecho',
      'image': 'assets/workout_area/superior/pecho.jpg',
    },
    {
      'title': 'Bíceps',
      'image': 'assets/workout_area/superior/biceps.jpg',
    },
    {
      'title': 'Tríceps',
      'image': 'assets/workout_area/superior/triceps.jpg',
    },
    {
      'title': 'Antebrazo',
      'image': 'assets/workout_area/superior/antebrazo.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 3,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(
              color: const Color.fromARGB(255, 0, 4, 255),
              thickness: 2,
              indent: 20,
              endIndent: 20,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'TREN SUPERIOR',
                style: TextStyle(
                  fontFamily: 'JetBrainsMono_Regular',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Divider(
              color: const Color.fromARGB(255, 0, 4, 255),
              thickness: 2,
              indent: 20,
              endIndent: 20,
            ),

            SizedBox(height: 15),

            // ========== LISTA DE EJERCICIOS ==========
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: exercises.map((exercise) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () {
                        // ========== AQUÍ VA LA LÓGICA AL SELECCIONAR UN EJERCICIO ==========
                        // Por ejemplo: navegar a detalles del ejercicio, abrir video, etc.
                       Navigator.pushNamed(
                        context,
                        Routes.exerciseDetail,
                        arguments: exercise['title'],
                      );
                      },
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: AssetImage(exercise['image']!),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.black.withValues(alpha: 0.6),
                                Colors.black.withValues(alpha: 0.3),
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                exercise['title']!,
                                style: TextStyle(
                                  fontFamily: 'JetBrainsMono_Regular',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}