import 'package:flutter/material.dart';
import '../widgets/main_layout.dart';
import '../routes.dart';
import '../db/database_helper.dart';
import '../models/ejercicios.dart';

class SuperiorExercisesScreen extends StatefulWidget {
  final int? idPartesC; // Recibe el ID de la parte del cuerpo
  const SuperiorExercisesScreen({super.key, this.idPartesC});

  @override
  SuperiorExercisesScreenState createState() => SuperiorExercisesScreenState();
}

class SuperiorExercisesScreenState extends State<SuperiorExercisesScreen> {
  late DatabaseHelper _dbHelper;
  late List<ZonaMuscular> zonas = [];

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper();
    _loadZonas();
  }

  Future<void> _loadZonas() async {
    if (widget.idPartesC != null) {
      final result = await _dbHelper.getZonasMusculares();
      setState(() {
        zonas = result
            .map((map) => ZonaMuscular.fromMap(map))
            .where((zona) => zona.idPartesC == widget.idPartesC)
            .toList();
       
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Debugging the received idPartesC

    String title = widget.idPartesC == 1 ? 'TREN SUPERIOR' : 'TREN INFERIOR';
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
                title,
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

            // ========== LISTA DE ZONAS MUSCULARES ==========
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: zonas.isEmpty
                  ? Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Músculos no encontrados',
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono_Regular',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    )
                  : Column(
                      children: zonas.map((zona) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                Routes.exerciseDetail,
                                arguments: ZonaMuscular(
                                  idPartesC: zona.idPartesC ?? widget.idPartesC!,
                                  idAreaM: zona.idAreaM,
                                  nombre: zona.nombre,
                                ),
                              );
                            },
                            child: Container(
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: AssetImage(
                                    'assets/workout_area/superior/${zona.nombre.toLowerCase()}.jpg',
                                  ),
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
                                      zona.nombre,
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