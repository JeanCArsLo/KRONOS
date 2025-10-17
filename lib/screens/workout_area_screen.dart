import 'package:flutter/material.dart';
import '../widgets/main_layout.dart';

class WorkoutAreaScreen extends StatefulWidget {
  const WorkoutAreaScreen({super.key});

  @override
  WorkoutAreaScreenState createState() => WorkoutAreaScreenState();
}

class WorkoutAreaScreenState extends State<WorkoutAreaScreen> {
  // ========== LISTA DE ÁREAS DE ENTRENAMIENTO ==========
  final List<Map<String, String>> workoutAreas = [
    {
      'title': 'TREN\nSUPERIOR',
      'image': 'assets/workout_area/tren_superior.jpg',
      'description': 'Ejercicios para pecho, espalda, hombros y brazos.',
    },
    {
      'title': 'TREN\nINFERIOR',
      'image': 'assets/workout_area/tren_inferior.jpg',
      'description': 'Ejercicios para piernas, glúteos y pantorrillas.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 3, // ← Marca el icono de Workout
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ========== TÍTULO "WORKOUT AREA" ==========
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'WORKOUT AREA',
                style: TextStyle(
                  fontFamily: 'JetBrainsMono_Regular',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            SizedBox(height: 20),

            // ========== LISTA DE ÁREAS DE ENTRENAMIENTO ==========
            Column(
              children: workoutAreas.asMap().entries.map((entry) {
                Map<String, String> workout = entry.value;

                return Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: GestureDetector(
                    onTap: () {
                      // ========== AQUÍ VA LA LÓGICA CUANDO SELECCIONES UN ÁREA ==========
                      // Por ejemplo: navegar a pantalla de ejercicios, abrir dialog, etc.
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width for padding
                      height: 200,
                      margin: EdgeInsets.symmetric(horizontal: 10), // Horizontal margin for edge spacing
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(workout['image']!),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.black.withValues(alpha: 0.4),
                              Colors.black.withValues(alpha: 0.6),
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end, // Center vertically
                            crossAxisAlignment: CrossAxisAlignment.start, // Center horizontally
                            children: [
                              Text(
                                workout['title']!,
                                style: TextStyle(
                                  fontFamily: 'JetBrainsMono_Regular',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.0,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}