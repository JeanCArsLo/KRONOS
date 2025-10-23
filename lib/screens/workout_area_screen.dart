import 'package:flutter/material.dart';
import '../widgets/main_layout.dart';
import '../routes.dart';
import '../db/database_helper.dart';
import '../models/ejercicios.dart';

class WorkoutAreaScreen extends StatefulWidget {
  const WorkoutAreaScreen({super.key});

  @override
  WorkoutAreaScreenState createState() => WorkoutAreaScreenState();
}

class WorkoutAreaScreenState extends State<WorkoutAreaScreen> {
  late DatabaseHelper _dbHelper;
  late List<PartesCuerpo> workoutAreas = [];

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper();
    _loadWorkoutAreas();
  }

  Future<void> _loadWorkoutAreas() async {
    final result = await _dbHelper.getPartesCuerpo();
    setState(() {
      workoutAreas = result.map((map) => PartesCuerpo.fromMap(map)).toList();
    });
  }

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
              children: workoutAreas.map((area) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        Routes.bodyPartExercises,
                        arguments: area.idPartesC,
                      );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width for padding
                      height: 200,
                      margin: EdgeInsets.symmetric(horizontal: 10), // Horizontal margin for edge spacing
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            'assets/workout_area/${area.nombre.toLowerCase().replaceAll(' ', '_')}.jpg',
                          ),
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
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                area.nombre.split(' ').join('\n'), // Divide "Tren Superior" en líneas
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