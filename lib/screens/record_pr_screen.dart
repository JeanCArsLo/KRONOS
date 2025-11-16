import 'package:flutter/material.dart';
import '../widgets/main_layout.dart';
import '../dialogs/pesos_dialog.dart';
import '../db/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecordPRScreen extends StatefulWidget {
  const RecordPRScreen({super.key});

  @override
  RecordPRScreenState createState() => RecordPRScreenState();
}

class RecordPRScreenState extends State<RecordPRScreen> {
  late DatabaseHelper _dbHelper;
  Map<String, List<Map<String, dynamic>>> exercisesByCategory = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper();
    _loadExercisesWithRecords();
  }

  Future<void> _loadExercisesWithRecords() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final idUsuario = prefs.getInt('current_user_id');

      if (idUsuario == null) {
        setState(() => _isLoading = false);
        return;
      }

      final records = await _dbHelper.getRecordsByUsuario(idUsuario);

      if (records.isEmpty) {
        setState(() {
          exercisesByCategory = {};
          _isLoading = false;
        });
        return;
      }

      Map<String, List<Map<String, dynamic>>> tempMap = {};

      for (var record in records) {
        final ejercicioData = await _dbHelper.database.then((db) async {
          final result = await db.query(
            'Ejercicio',
            where: 'IdEjercicio = ?',
            whereArgs: [record.idEjercicio],
          );
          return result.isNotEmpty ? result.first : null;
        });

        if (ejercicioData == null) continue;

        final zonaData = await _dbHelper.getZonaMuscularById(
          ejercicioData['IdAreaM'] as int,
        );

        if (zonaData == null) continue;

        final zonaNombre = zonaData['Nombre'] as String;
        final ejercicioNombre = ejercicioData['Nombre'] as String;
        final idPartesC = ejercicioData['IdPartesC'] as int;

        final parteFolder = idPartesC == 1 ? 'superior' : 'inferior';
        final zonaFolder = _normalizarTexto(zonaNombre);
        final ejercicioFile = _normalizarTexto(ejercicioNombre);
        final imagePath =
            'assets/workout_area/$parteFolder/$zonaFolder/$ejercicioFile.jpg';

        if (!tempMap.containsKey(zonaNombre)) {
          tempMap[zonaNombre] = [];
        }

        final yaExiste = tempMap[zonaNombre]!.any(
          (e) => e['idEjercicio'] == record.idEjercicio,
        );

        if (!yaExiste) {
          tempMap[zonaNombre]!.add({
            'name': ejercicioNombre,
            'image': imagePath,
            'exerciseTitle': zonaNombre,
            'idEjercicio': record.idEjercicio,
            'idUsuario': idUsuario,
          });
        }
      }

      setState(() {
        exercisesByCategory = tempMap;
        _isLoading = false;
      });
    } catch (e) {
      print('Error cargando récords: $e');
      setState(() => _isLoading = false);
    }
  }

  String _normalizarTexto(String texto) {
    return texto
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll(' ', '_');
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 1,
      child: Container(
        color: Color(0xFF0A0A0A),
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: Color(0xFF2563eb)))
            : exercisesByCategory.isEmpty
            ? Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Color(0xFF1A1A1A),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Color(0xFF2563eb),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.fitness_center,
                          size: 60,
                          color: Color(0xFF2563eb),
                        ),
                      ),
                      SizedBox(height: 30),
                      Text(
                        'Aún no tienes récords registrados',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono_Regular',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFC0C0C0),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Comienza a entrenar y registra tus pesos\npara ver tus récords aquí',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono_Regular',
                          fontSize: 12,
                          color: Color(0xFF808080),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),

                    ...exercisesByCategory.entries.map((category) {
                      return _buildExerciseCategory(
                        context,
                        category.key,
                        category.value,
                      );
                    }),

                    SizedBox(height: 30),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildExerciseCategory(
    BuildContext context,
    String categoryName,
    List<Map<String, dynamic>> exercises,
  ) {
    if (exercises.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: Color(0xFF2563eb),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 12),
              Text(
                categoryName.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'JetBrainsMono_Regular',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 16),

        // ✅ Altura reducida a 240
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 15),
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: 15),
                child: _buildExerciseCard(context, exercises[index]),
              );
            },
          ),
        ),

        SizedBox(height: 25),
      ],
    );
  }

  Widget _buildExerciseCard(
    BuildContext context,
    Map<String, dynamic> exercise,
  ) {
    return Container(
      // ✅ Ancho aumentado a 280
      width: 280,
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF303030), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ========== IMAGEN — SIN CAPA NEGRA, DIRECTA ==========
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
              ),
              padding: EdgeInsets.all(2),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                child: Image.asset(
                  exercise['image'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Color(0xFF0F0F0F),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 50,
                          color: Color(0xFF505050),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Sin imagen',
                          style: TextStyle(
                            color: Color(0xFF505050),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ========== CONTENEDOR INFERIOR ==========
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF0F0F0F),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(11)),
            ),
            child: Column(
              children: [
                Text(
                  exercise['name'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono_Regular',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    height: 1.3,
                    color: Color(0xFFE0E0E0),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 12),

                // ✅ BOTÓN CON FONDO TRANSPARENTE Y BORDE NARANJA
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xFFff6b35), // 🔥 Borde naranja
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x66ff6b35), // Sombra naranja suave
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => PesosDialog(exercise: exercise),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.transparent, // ✅ Fondo transparente
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.military_tech,
                          size: 16,
                          color: Colors.white, // ✅ Icono blanco
                        ),
                        SizedBox(width: 6),
                        Text(
                          'VER RÉCORDS',
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono_Regular',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // ✅ Texto blanco
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
