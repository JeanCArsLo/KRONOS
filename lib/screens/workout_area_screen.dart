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
      currentIndex: 3,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ========== TÍTULO "WORKOUT AREA" + RALLITA HORIZONTAL AZUL CENTRADA EN LA MITAD ==========
            Padding(
              padding: EdgeInsets.symmetric(vertical: 55),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    'WORKOUT AREA',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono_Regular',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                    bottom: -6, // ajusta para que quede debajo del texto
                    child: Container(
                      width:
                          MediaQuery.of(context).size.width *
                          0.3, // ≈ mitad del ancho de la pantalla
                      height: 4,
                      decoration: BoxDecoration(
                        color: Color(0xFF2563eb), // Azul primario
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ========== LISTA DE ÁREAS DE ENTRENAMIENTO ==========
            Center(
              child: Column(
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
                        width: double.infinity,
                        height: 200,
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          image: DecorationImage(
                            image: AssetImage(
                              'assets/workout_area/${area.nombre.toLowerCase().replaceAll(' ', '_')}.jpg',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.8),
                                      Colors.black.withValues(alpha: 0.9),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 40),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // ✅ RALLITA VERTICAL AZUL AL LADO DEL TEXTO
                                        Container(
                                          width: 4,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: Color(0xFF2563eb),
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            area.nombre.split(' ').join('\n'),
                                            style: TextStyle(
                                              fontFamily:
                                                  'JetBrainsMono_Regular',
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Color(
                                                0xFFc0c0c0,
                                              ), // Plateado
                                              letterSpacing: 1.0,
                                              height: 1.2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
