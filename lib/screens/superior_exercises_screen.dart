import 'package:flutter/material.dart';
import '../widgets/main_layout.dart';
import '../routes.dart';
import '../db/database_helper.dart';
import '../models/ejercicios.dart';

class BodyPartExercisesScreen extends StatefulWidget {
  final int? idPartesC;
  const BodyPartExercisesScreen({super.key, this.idPartesC});

  @override
  BodyPartExercisesScreenState createState() => BodyPartExercisesScreenState();
}

class BodyPartExercisesScreenState extends State<BodyPartExercisesScreen> {
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
    String folder = widget.idPartesC == 1 ? 'superior' : 'inferior';
    String title = widget.idPartesC == 1 ? 'TREN SUPERIOR' : 'TREN INFERIOR';

    return MainLayout(
      currentIndex: 3,
      child: Column(
        children: [
          SizedBox(height: 20),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono_Regular',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Selecciona un grupo muscular',
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono_Regular',
                    fontSize: 13,
                    color: Color(0x99FFFFFF),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: zonas.isEmpty
                  ? Center(
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
                  : SingleChildScrollView(
                      child: Column(
                        children: zonas.map((zona) {
                          String imagePath =
                              'assets/workout_area/$folder/${zona.nombre.toLowerCase().replaceAll(' ', '_')}.jpg';

                          return Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  Routes.exerciseDetail,
                                  arguments: ZonaMuscular(
                                    idPartesC:
                                        zona.idPartesC ?? widget.idPartesC!,
                                    idAreaM: zona.idAreaM,
                                    nombre: zona.nombre,
                                  ),
                                );
                              },
                              child: Container(
                                height: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x262563eb),
                                      blurRadius: 12,
                                      offset: Offset(0, 6),
                                      spreadRadius: -4,
                                    ),
                                    BoxShadow(
                                      color: Color(0x66000000),
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.asset(
                                        imagePath,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                                  color: Colors.grey[850],
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.image_not_supported,
                                                      color: Colors.grey[600],
                                                      size: 48,
                                                    ),
                                                  ),
                                                ),
                                      ),
                                      // ✅ CAPA NEGRA EXACTA DE WORKOUT AREA (diagonal, 0.8 → 0.9)
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.black.withValues(
                                                alpha: 0.8,
                                              ),
                                              Colors.black.withValues(
                                                alpha: 0.9,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Texto con rallita vertical y plateado
                                      Padding(
                                        padding: EdgeInsets.all(20),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 4,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                color: Color(0xFF2563eb),
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                zona.nombre.toUpperCase(),
                                                style: TextStyle(
                                                  fontFamily:
                                                      'JetBrainsMono_Regular',
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFFc0c0c0),
                                                  height: 1.1,
                                                ),
                                              ),
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
            ),
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }
}
