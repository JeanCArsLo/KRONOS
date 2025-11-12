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

  // 🔥 CARGAR SOLO EJERCICIOS CON RÉCORDS
  Future<void> _loadExercisesWithRecords() async {
    setState(() => _isLoading = true);

    try {
      // Obtener ID del usuario actual
      final prefs = await SharedPreferences.getInstance();
      final idUsuario = prefs.getInt('userId');

      if (idUsuario == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Obtener todos los récords del usuario
      final records = await _dbHelper.getRecordsByUsuario(idUsuario);

      if (records.isEmpty) {
        setState(() {
          exercisesByCategory = {};
          _isLoading = false;
        });
        return;
      }

      // Agrupar por zona muscular
      Map<String, List<Map<String, dynamic>>> tempMap = {};

      for (var record in records) {
        // Obtener info del ejercicio
        final ejercicioData = await _dbHelper.database.then((db) async {
          final result = await db.query(
            'Ejercicio',
            where: 'IdEjercicio = ?',
            whereArgs: [record.idEjercicio],
          );
          return result.isNotEmpty ? result.first : null;
        });

        if (ejercicioData == null) continue;

        // Obtener zona muscular
        final zonaData = await _dbHelper.getZonaMuscularById(
          ejercicioData['IdAreaM'] as int,
        );

        if (zonaData == null) continue;

        final zonaNombre = zonaData['Nombre'] as String;
        final ejercicioNombre = ejercicioData['Nombre'] as String;
        final idPartesC = ejercicioData['IdPartesC'] as int;

        // Construir ruta de imagen
        final parteFolder = idPartesC == 1 ? 'superior' : 'inferior';
        final zonaFolder = _normalizarTexto(zonaNombre);
        final ejercicioFile = _normalizarTexto(ejercicioNombre);
        final imagePath = 'assets/workout_area/$parteFolder/$zonaFolder/$ejercicioFile.jpg';

        // Agregar al mapa por categoría
        if (!tempMap.containsKey(zonaNombre)) {
          tempMap[zonaNombre] = [];
        }

        // Verificar que no esté duplicado
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

  // Normalizar texto para rutas de archivos
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
      child: _isLoading
          ? Center(child: CircularProgressIndicator())
          : exercisesByCategory.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Aún no tienes récords registrados',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono_Regular',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Comienza a entrenar y registra tus pesos para ver tus récords aquí',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono_Regular',
                            fontSize: 12,
                            color: Colors.grey[500],
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
                      SizedBox(height: 10),

                      // ========== SECCIONES DE EJERCICIOS ==========
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
    );
  }

  // ========== WIDGET PARA CADA CATEGORÍA ==========
  Widget _buildExerciseCategory(
    BuildContext context,
    String categoryName,
    List<Map<String, dynamic>> exercises,
  ) {
    if (exercises.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ========== TÍTULO DE LA CATEGORÍA CON DIVIDERS ==========
        Divider(
          color: const Color.fromARGB(255, 0, 4, 255),
          thickness: 2,
          indent: 20,
          endIndent: 20,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            " $categoryName",
            style: TextStyle(
              fontFamily: 'JetBrainsMono_Regular',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
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

        // ========== CARRUSEL HORIZONTAL DE EJERCICIOS ==========
        SizedBox(
          height: 250,
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

  // ========== TARJETA DE EJERCICIO INDIVIDUAL ==========
  Widget _buildExerciseCard(BuildContext context, Map<String, dynamic> exercise) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color.fromARGB(255, 0, 0, 0),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ========== IMAGEN DEL EJERCICIO ==========
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
              child: Image.asset(
                exercise['image'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: Icon(Icons.fitness_center, size: 60, color: Colors.grey[600]),
                ),
              ),
            ),
          ),

          // ========== NOMBRE DEL EJERCICIO ==========
          Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              exercise['name'],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'JetBrainsMono_Regular',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // ========== BOTÓN "Pesos" ==========
          Padding(
            padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => PesosDialog(
                    exercise: exercise,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 140, 0),
                padding: EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                elevation: 0,
              ),
              child: Text(
                'Pesos',
                style: TextStyle(
                  fontFamily: 'JetBrainsMono_Regular',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}