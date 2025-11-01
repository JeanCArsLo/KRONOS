import 'package:flutter/material.dart';
import '../widgets/main_layout.dart';
import '../db/database_helper.dart';
import 'dart:async'; // Para manejar Future en initState
import '../widgets/add_weight.dart'; // Importamos el nuevo archivo
import 'package:diacritic/diacritic.dart'; // Añade esta línea

class ExerciseDetailScreen extends StatefulWidget {
  final int idPartesC;
  final int idAreaM;
  
  const ExerciseDetailScreen({
    super.key,
    required this.idPartesC,
    required this.idAreaM,
  });

  @override
  ExerciseDetailScreenState createState() => ExerciseDetailScreenState();
}

class ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  late DatabaseHelper _dbHelper;
  String zonaNombre = ''; // Para almacenar el nombre de la zona muscular
  Map<String, dynamic> currentExercise = {
    'description': 'Cargando...',
    'advice': 'Cargando...',
    'variants': [],
  }; // Inicialización con valores por defecto
  late Map<String, bool> checkedVariants;
  late Map<String, TextEditingController> weightControllers; // Restauramos los controladores

  // Mapa estático para descripciones y consejos por nombre de zona
  final Map<String, Map<String, String>> staticData = {
    'Espalda': {
      'description': 'Trabajo integral de espalda, mejora la postura, la fuerza y la estabilidad corporal. Una espalda fuerte protege la columna y equilibra el desarrollo muscular.',
      'advice': 'Realiza los ejercicios con peso moderado y buena técnica. Aumenta el peso sólo cuando controles el movimiento. La clave está en la forma, no sólo en la fuerza.',
    },
    'Hombros': {
      'description': 'Fortalecen los deltoides y músculos circundantes, mejorando la movilidad y estabilidad de la articulación. Es clave para movimientos de empuje y levantamiento.',
      'advice': 'Usa pesos ligeros al inicio para dominar la técnica. Mantén los hombros relajados y evita movimientos bruscos para proteger las articulaciones.',
    },
    'Pecho': {
      'description': 'Desarrolla los pectorales, mejorando la fuerza en movimientos de empuje y la estética torácica. También fortalece músculos estabilizadores del tronco.',
      'advice': 'Controla la fase excéntrica (descenso) del movimiento. Mantén los hombros hacia atrás y el pecho elevado para maximizar la activación muscular.',
    },
    'Bíceps': {
      'description': 'Trabaja los músculos del brazo anterior, esenciales para movimientos de tracción y levantamiento. Mejora la fuerza y definición del brazo.',
      'advice': 'Evita balancear el cuerpo durante los curls. Mantén los codos fijos y concéntrate en contraer el bíceps en cada repetición.',
    },
    'Tríceps': {
      'description': 'Fortalece los músculos posteriores del brazo, clave para movimientos de empuje y extensión. Mejora la estabilidad del codo y la fuerza general del brazo.',
      'advice': 'Mantén los codos cerca del cuerpo en ejercicios como extensiones. Usa un rango de movimiento completo para activar todas las cabezas del tríceps.',
    },
    'Antebrazo': {
      'description': 'Desarrolla la fuerza de agarre y la resistencia muscular, esenciales para ejercicios de tracción y levantamiento de peso. Mejora la funcionalidad diaria.',
      'advice': 'Incorpora ejercicios específicos como flexiones de muñeca. No descuides el estiramiento para evitar rigidez y mejorar la movilidad.',
    },
    'Cuádriceps': {
      'description': 'Fortalece los músculos frontales del muslo, esenciales para movimientos como caminar, correr y saltar. Mejora la estabilidad de la rodilla y la potencia en las piernas.',
      'advice': 'Mantén las rodillas alineadas con los pies durante sentadillas y prensas. Controla el descenso para proteger las articulaciones y maximizar la activación muscular.'
    },
    'Femoral': {
      'description': 'Trabaja los músculos posteriores del muslo, clave para la flexión de la rodilla y la extensión de la cadera. Equilibra la fuerza de las piernas y previene lesiones.',
      'advice': 'Enfócate en la contracción al subir el peso en ejercicios como peso muerto rumano. Evita arquear la espalda y usa un rango de movimiento controlado.'
    },
    'Glúteos': {
      'description': 'Desarrolla los músculos de la cadera, fundamentales para la estabilidad pélvica, la potencia en movimientos explosivos y una postura sólida.',
      'advice': 'Activa los glúteos antes de entrenar con puentes o sentadillas ligeras. Mantén el core firme para evitar compensar con la espalda baja.'
    },
    'Pantorrillas': {
      'description': 'Fortalece los músculos de la parte inferior de la pierna, esenciales para la propulsión al caminar, correr o saltar. Mejora la estabilidad del tobillo.',
      'advice': 'Usa un rango completo de movimiento, estirando y contrayendo al máximo en cada repetición. Varía entre ejercicios con rodilla recta y flexionada para trabajar todas las fibras.'
    },

  };

  // Series estáticas
  final Map<String, String> staticSeries = {
    'series': '4x8-10',
    'hypertrophy': '4x10-12',
    'tonification': '3x12-15',
  };

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper();
    _loadData();
  }

  Future<void> _loadData() async {
    final zona = await _dbHelper.getZonaMuscularById(widget.idAreaM);
    if (zona != null) {
      setState(() {
        zonaNombre = zona['Nombre'];
      });

      final staticInfo = staticData[zonaNombre] ?? {
        'description': 'Descripción no disponible',
        'advice': 'Consejo no disponible',
      };

      final ejercicios = await _dbHelper.getEjerciciosByZona(widget.idAreaM);

      final variants = ejercicios.map((ejercicio) {
        final ejercicioNombreLower = removeDiacritics(ejercicio['Nombre']).toLowerCase().replaceAll(' ', '_');
        final parteFolder = widget.idPartesC == 1 ? 'superior' : 'inferior';
        final zonaFolder = removeDiacritics(zonaNombre).toLowerCase();
        return {
          'name': ejercicio['Nombre'],
          'description': ejercicio['Descripcion'] ?? 'Sin descripción',
          'series': staticSeries['series'],
          'hypertrophy': staticSeries['hypertrophy'],
          'tonification': staticSeries['tonification'],
          'image': 'assets/workout_area/$parteFolder/$zonaFolder/$ejercicioNombreLower.jpg',
          'idEjercicio': ejercicio['IdEjercicio'],
          'idPartesC': widget.idPartesC,
          'idAreaM': widget.idAreaM,
          'peso': ejercicio['Peso']?.toString() ?? 'No establecido',
        };
      }).toList();

      setState(() {
        currentExercise = {
          'description': staticInfo['description'],
          'advice': staticInfo['advice'],
          'variants': variants,
        };
        checkedVariants = {
          for (var variant in variants) variant['name']: false,
        };
        weightControllers = {
          for (var variant in variants) variant['name']: TextEditingController(text: variant['peso'] ?? ''), // Restauramos los controladores
        };
      });
    } else {
      setState(() {
        zonaNombre = 'Zona no encontrada';
        currentExercise = {
          'description': 'Error al cargar datos',
          'advice': 'Error al cargar datos',
          'variants': [],
        };
        checkedVariants = {};
        weightControllers = {};
      });
    }
  }

  @override
  void dispose() {
    for (var controller in weightControllers.values) {
      controller.dispose(); // Restauramos la limpieza de controladores
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (zonaNombre.isEmpty) {
      return MainLayout(
        currentIndex: 3,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return MainLayout(
      currentIndex: 3,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(color: const Color.fromARGB(255, 0, 4, 255), thickness: 2, indent: 20, endIndent: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                " ${zonaNombre.toUpperCase()}",
                style: TextStyle(
                  fontFamily: 'JetBrainsMono_Regular',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Divider(color: const Color.fromARGB(255, 0, 4, 255), thickness: 2, indent: 20, endIndent: 20),

            SizedBox(height: 20),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color.fromARGB(255, 255, 140, 0), width: 2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Descripción:', style: TextStyle(fontFamily: 'JetBrainsMono_Regular', fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    SizedBox(height: 8),
                    Text(currentExercise['description'] ?? 'Sin descripción', style: TextStyle(fontFamily: 'JetBrainsMono_Regular', fontSize: 11, height: 1.5, color: const Color.fromARGB(255, 0, 0, 0))),
                  ],
                ),
              ),
            ),

            SizedBox(height: 15),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color.fromARGB(255, 255, 140, 0), width: 2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Consejo:', style: TextStyle(fontFamily: 'JetBrainsMono_Regular', fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    SizedBox(height: 8),
                    Text(currentExercise['advice'] ?? 'Sin consejo', style: TextStyle(fontFamily: 'JetBrainsMono_Regular', fontSize: 11, height: 1.5, color: const Color.fromARGB(255, 0, 0, 0))),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: currentExercise['variants'].isEmpty
                  ? Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Ejercicios no encontrados',
                        style: TextStyle(fontFamily: 'JetBrainsMono_Regular', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color.fromARGB(255, 0, 0, 0), width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.all(12),
                      child: Column(
                      children: List.generate(
                        currentExercise['variants'].length,
                        (index) {
                          var variant = currentExercise['variants'][index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: 20),
                            // child: Container(
                            //   decoration: BoxDecoration(
                            //     border: Border.all(color: const Color.fromARGB(255, 0, 0, 0), width: 1),
                            //     borderRadius: BorderRadius.circular(8),
                            //   ),
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => Dialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(17),
                                              side: BorderSide(color: const Color.fromARGB(255, 0, 26, 255), width: 3),
                                            ),
                                            backgroundColor: Colors.white,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(17),
                                                  child: Image.asset(
                                                    variant['image'],
                                                    fit: BoxFit.contain,
                                                    errorBuilder: (context, error, stackTrace) => Icon(Icons.error, size: 120), // Manejo de error
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.asset(
                                          variant['image'],
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          alignment: Alignment.centerLeft,
                                          errorBuilder: (context, error, stackTrace) => Icon(Icons.error), // Manejo de error
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(variant['name'], style: TextStyle(fontFamily: 'JetBrainsMono_Regular', fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.6)),
                                          SizedBox(height: 6),
                                          Text(variant['description'] ?? 'Sin descripción', style: TextStyle(fontFamily: 'JetBrainsMono_Regular', fontSize: 10, color: const Color.fromARGB(255, 0, 0, 0), height: 1.4)),
                                          SizedBox(height: 8),
                                          RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(text: 'Series y reps\n', style: TextStyle(fontFamily: 'JetBrainsMono_Regular', fontSize: 9, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 0, 0, 0))),
                                                TextSpan(text: 'Fuerza: ${variant['series']}\n', style: TextStyle(fontFamily: 'JetBrainsMono_Regular', fontSize: 8, color: const Color.fromARGB(255, 0, 0, 0))),
                                                TextSpan(text: 'Hipertrofia: ${variant['hypertrophy']}\n', style: TextStyle(fontFamily: 'JetBrainsMono_Regular', fontSize: 8, color: const Color.fromARGB(255, 0, 0, 0))),
                                                TextSpan(text: 'Tonificación: ${variant['tonification']}', style: TextStyle(fontFamily: 'JetBrainsMono_Regular', fontSize: 8, color: const Color.fromARGB(255, 0, 0, 0))),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextField(
                                                  controller: weightControllers[variant['name']],
                                                  decoration: InputDecoration(
                                                    hintText: 'Peso:',
                                                    hintStyle: TextStyle(fontFamily: 'JetBrainsMono_Regular', fontSize: 9, color: Colors.grey[500]),
                                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(4),
                                                      borderSide: BorderSide(color: Colors.grey[600]!),
                                                    ),
                                                  ),
                                                  style: TextStyle(fontFamily: 'JetBrainsMono_Regular', fontSize: 10),
                                                  keyboardType: TextInputType.number,
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: const Color.fromARGB(255, 255, 255, 255), width: 1),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Checkbox(
                                                  value: checkedVariants[variant['name']] ?? false,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      checkedVariants[variant['name']] = value ?? false;
                                                    });
                                                  },
                                                  activeColor: const Color.fromARGB(255, 255, 140, 0),
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
                            
                          );
                        },
                      ),
                    ),
                  ),
            ),

            SizedBox(height: 20),

            // ========== BOTÓN GUARDAR ==========
            Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 30),
                child: ElevatedButton(
                  onPressed: () {
                    AgregarPeso.guardarPesos(context, currentExercise, checkedVariants, weightControllers); // Restauramos weightControllers
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 140, 0),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    'Guardar',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono_Regular',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}