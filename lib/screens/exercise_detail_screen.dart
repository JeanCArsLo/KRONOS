import 'package:flutter/material.dart';
import '../widgets/main_layout.dart';
import '../db/database_helper.dart';
import 'dart:async';
import '../widgets/add_weight.dart';
import 'package:diacritic/diacritic.dart';

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
  String zonaNombre = '';
  Map<String, dynamic> currentExercise = {
    'description': 'Cargando...',
    'advice': 'Cargando...',
    'variants': [],
  };
  late Map<String, bool> checkedVariants;
  late Map<String, TextEditingController> weightControllers;

  final Map<String, Map<String, String>> staticData = {
    'Espalda': {
      'description':
          'Trabajo integral de espalda, mejora la postura, la fuerza y la estabilidad corporal. Una espalda fuerte protege la columna y equilibra el desarrollo muscular.',
      'advice':
          'Realiza los ejercicios con peso moderado y buena técnica. Aumenta el peso sólo cuando controles el movimiento. La clave está en la forma, no sólo en la fuerza.',
    },
    'Hombros': {
      'description':
          'Fortalecen los deltoides y músculos circundantes, mejorando la movilidad y estabilidad de la articulación. Es clave para movimientos de empuje y levantamiento.',
      'advice':
          'Usa pesos ligeros al inicio para dominar la técnica. Mantén los hombros relajados y evita movimientos bruscos para proteger las articulaciones.',
    },
    'Pecho': {
      'description':
          'Desarrolla los pectorales, mejorando la fuerza en movimientos de empuje y la estética torácica. También fortalece músculos estabilizadores del tronco.',
      'advice':
          'Controla la fase excéntrica (descenso) del movimiento. Mantén los hombros hacia atrás y el pecho elevado para maximizar la activación muscular.',
    },
    'Bíceps': {
      'description':
          'Trabaja los músculos del brazo anterior, esenciales para movimientos de tracción y levantamiento. Mejora la fuerza y definición del brazo.',
      'advice':
          'Evita balancear el cuerpo durante los curls. Mantén los codos fijos y concéntrate en contraer el bíceps en cada repetición.',
    },
    'Tríceps': {
      'description':
          'Fortalece los músculos posteriores del brazo, clave para movimientos de empuje y extensión. Mejora la estabilidad del codo y la fuerza general del brazo.',
      'advice':
          'Mantén los codos cerca del cuerpo en ejercicios como extensiones. Usa un rango de movimiento completo para activar todas las cabezas del tríceps.',
    },
    'Antebrazo': {
      'description':
          'Desarrolla la fuerza de agarre y la resistencia muscular, esenciales para ejercicios de tracción y levantamiento de peso. Mejora la funcionalidad diaria.',
      'advice':
          'Incorpora ejercicios específicos como flexiones de muñeca. No descuides el estiramiento para evitar rigidez y mejorar la movilidad.',
    },
    'Cuádriceps': {
      'description':
          'Fortalece los músculos frontales del muslo, esenciales para movimientos como caminar, correr y saltar. Mejora la estabilidad de la rodilla y la potencia en las piernas.',
      'advice':
          'Mantén las rodillas alineadas con los pies durante sentadillas y prensas. Controla el descenso para proteger las articulaciones y maximizar la activación muscular.',
    },
    'Femoral': {
      'description':
          'Trabaja los músculos posteriores del muslo, clave para la flexión de la rodilla y la extensión de la cadera. Equilibra la fuerza de las piernas y previene lesiones.',
      'advice':
          'Enfócate en la contracción al subir el peso en ejercicios como peso muerto rumano. Evita arquear la espalda y usa un rango de movimiento controlado.',
    },
    'Glúteos': {
      'description':
          'Desarrolla los músculos de la cadera, fundamentales para la estabilidad pélvica, la potencia en movimientos explosivos y una postura sólida.',
      'advice':
          'Activa los glúteos antes de entrenar con puentes o sentadillas ligeras. Mantén el core firme para evitar compensar con la espalda baja.',
    },
    'Pantorrillas': {
      'description':
          'Fortalece los músculos de la parte inferior de la pierna, esenciales para la propulsión al caminar, correr o saltar. Mejora la estabilidad del tobillo.',
      'advice':
          'Usa un rango completo de movimiento, estirando y contrayendo al máximo en cada repetición. Varía entre ejercicios con rodilla recta y flexionada para trabajar todas las fibras.',
    },
  };

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

      final staticInfo =
          staticData[zonaNombre] ??
          {
            'description': 'Descripción no disponible',
            'advice': 'Consejo no disponible',
          };

      final ejercicios = await _dbHelper.getEjerciciosByZona(widget.idAreaM);

      final variants = ejercicios.map((ejercicio) {
        final ejercicioNombreLower = removeDiacritics(
          ejercicio['Nombre'],
        ).toLowerCase().replaceAll(' ', '_');
        final parteFolder = widget.idPartesC == 1 ? 'superior' : 'inferior';
        final zonaFolder = removeDiacritics(zonaNombre).toLowerCase();
        return {
          'name': ejercicio['Nombre'],
          'description': ejercicio['Descripcion'] ?? 'Sin descripción',
          'series': staticSeries['series'],
          'hypertrophy': staticSeries['hypertrophy'],
          'tonification': staticSeries['tonification'],
          'image':
              'assets/workout_area/$parteFolder/$zonaFolder/$ejercicioNombreLower.jpg',
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
          for (var variant in variants)
            variant['name']: TextEditingController(text: variant['peso'] ?? ''),
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
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    if (zonaNombre.isEmpty) {
      return MainLayout(
        currentIndex: 3,
        child: Container(
          color: Color(0xFF0A0A0A),
          child: Center(
            child: CircularProgressIndicator(color: Color(0xFFFF8C00)),
          ),
        ),
      );
    }

    return MainLayout(
      currentIndex: 3,
      child: Container(
        color: Color(0xFF0A0A0A),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: bottomPadding > 0 ? bottomPadding + 20 : 20,
          ),
          physics: ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header sin fondo, solo texto con rallita azul
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Color(0xFF2563eb),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      zonaNombre.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono_Regular',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Descripción - Estilo moderno sin bordes
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.info_outline,
                            color: Color(0xFF2563eb),
                            size: 18,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'DESCRIPCIÓN',
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono_Regular',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: Color(0xFF2563eb),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      currentExercise['description'] ?? 'Sin descripción',
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono_Regular',
                        fontSize: 12,
                        height: 1.6,
                        color: Color(0xFFc0c0c0),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Consejo - Estilo moderno sin bordes
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.lightbulb_outline,
                            color: Color(0xFFFF8C00),
                            size: 18,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'CONSEJO',
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono_Regular',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: Color(0xFFFF8C00),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      currentExercise['advice'] ?? 'Sin consejo',
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono_Regular',
                        fontSize: 12,
                        height: 1.6,
                        color: Color(0xFFc0c0c0),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Lista de ejercicios
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: currentExercise['variants'].isEmpty
                    ? Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red, width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            'Ejercicios no encontrados',
                            style: TextStyle(
                              fontFamily: 'JetBrainsMono_Regular',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      )
                    : Column(
                        children: List.generate(currentExercise['variants'].length, (
                          index,
                        ) {
                          var variant = currentExercise['variants'][index];
                          return Container(
                            margin: EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Color(0xFF303030),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x66000000),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(14),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Imagen del ejercicio mejorada
                                      GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            barrierColor: Color(0xE6000000),
                                            builder: (context) => Dialog(
                                              backgroundColor:
                                                  Colors.transparent,
                                              insetPadding: EdgeInsets.all(20),
                                              child: Stack(
                                                children: [
                                                  Container(
                                                    constraints: BoxConstraints(
                                                      maxHeight:
                                                          MediaQuery.of(
                                                            context,
                                                          ).size.height *
                                                          0.7,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                      border: Border.all(
                                                        color: Color(
                                                          0xFFC0C0C0,
                                                        ),
                                                        width: 3,
                                                      ),
                                                      color: Color(0xFF0A0A0A),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Color(
                                                            0x99C0C0C0,
                                                          ),
                                                          blurRadius: 30,
                                                          spreadRadius: 5,
                                                        ),
                                                      ],
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            17,
                                                          ),
                                                      child: Image.asset(
                                                        variant['image'],
                                                        fit: BoxFit.contain,
                                                        errorBuilder:
                                                            (
                                                              context,
                                                              error,
                                                              stackTrace,
                                                            ) => Container(
                                                              padding:
                                                                  EdgeInsets.all(
                                                                    40,
                                                                  ),
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .error_outline,
                                                                    size: 80,
                                                                    color: Colors
                                                                        .red,
                                                                  ),
                                                                  SizedBox(
                                                                    height: 16,
                                                                  ),
                                                                  Text(
                                                                    'Imagen no disponible',
                                                                    style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          16,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 10,
                                                    right: 10,
                                                    child: GestureDetector(
                                                      onTap: () =>
                                                          Navigator.pop(
                                                            context,
                                                          ),
                                                      child: Container(
                                                        padding: EdgeInsets.all(
                                                          8,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                              color: Color(
                                                                0xFF1A1A1A,
                                                              ),
                                                              shape: BoxShape
                                                                  .circle,
                                                              border: Border.all(
                                                                color: Color(
                                                                  0xFFC0C0C0,
                                                                ),
                                                                width: 2,
                                                              ),
                                                            ),
                                                        child: Icon(
                                                          Icons.close,
                                                          color: Colors.white,
                                                          size: 20,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: 130,
                                          height: 130,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Color(0xFFE0E0E0),
                                                Color(0xFFC0C0C0),
                                                Color(0xFF8D8D8D),
                                              ],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color(0x4DC0C0C0),
                                                blurRadius: 12,
                                                offset: Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          padding: EdgeInsets.all(3),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Color(0xFF0F0F0F),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Stack(
                                                fit: StackFit.expand,
                                                children: [
                                                  Image.asset(
                                                    variant['image'],
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) => Container(
                                                          color: Color(
                                                            0xFF1A1A1A,
                                                          ),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .fitness_center,
                                                                size: 40,
                                                                color: Color(
                                                                  0xFF505050,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 8,
                                                              ),
                                                              Text(
                                                                'Sin imagen',
                                                                style: TextStyle(
                                                                  color: Color(
                                                                    0xFF505050,
                                                                  ),
                                                                  fontSize: 10,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                  ),
                                                  // Icono de zoom sutil
                                                  Positioned(
                                                    bottom: 6,
                                                    right: 6,
                                                    child: Container(
                                                      padding: EdgeInsets.all(
                                                        4,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Color(
                                                          0xCC000000,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                      ),
                                                      child: Icon(
                                                        Icons.zoom_in,
                                                        color: Color(
                                                          0xFFC0C0C0,
                                                        ),
                                                        size: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 14),
                                      // Información del ejercicio
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              variant['name'],
                                              style: TextStyle(
                                                fontFamily:
                                                    'JetBrainsMono_Regular',
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                                color: Color(0xFFFFFFFF),
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              variant['description'] ??
                                                  'Sin descripción',
                                              style: TextStyle(
                                                fontFamily:
                                                    'JetBrainsMono_Regular',
                                                fontSize: 10,
                                                color: Color(0xFFB0B0B0),
                                                height: 1.5,
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 14),
                                  // Series y reps
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF0F0F0F),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Color(0xFF252525),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'SERIES Y REPETICIONES',
                                          style: TextStyle(
                                            fontFamily: 'JetBrainsMono_Regular',
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFFF8C00),
                                            letterSpacing: 1,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            _buildSeriesChip(
                                              'Fuerza',
                                              variant['series'],
                                            ),
                                            _buildSeriesChip(
                                              'Hipertrofia',
                                              variant['hypertrophy'],
                                            ),
                                            _buildSeriesChip(
                                              'Tonificación',
                                              variant['tonification'],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 14),
                                  // Peso y checkbox
                                  Row(
                                    key: ValueKey(
                                      'weight_field_${variant['name']}',
                                    ),
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Color(0xFF0F0F0F),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Color(0xFFC0C0C0),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: TextField(
                                            controller:
                                                weightControllers[variant['name']],
                                            onTap: () {
                                              Future.delayed(
                                                Duration(milliseconds: 100),
                                                () {
                                                  final RenderBox? box =
                                                      context.findRenderObject()
                                                          as RenderBox?;
                                                  if (box != null) {
                                                    Scrollable.ensureVisible(
                                                      context,
                                                      duration: Duration(
                                                        milliseconds: 500,
                                                      ),
                                                      curve: Curves.easeInOut,
                                                      alignmentPolicy:
                                                          ScrollPositionAlignmentPolicy
                                                              .keepVisibleAtEnd,
                                                    );
                                                  }
                                                },
                                              );
                                            },
                                            decoration: InputDecoration(
                                              hintText: 'Peso (kg)',
                                              hintStyle: TextStyle(
                                                fontFamily:
                                                    'JetBrainsMono_Regular',
                                                fontSize: 11,
                                                color: Color(0xFF505050),
                                              ),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 12,
                                                  ),
                                              border: InputBorder.none,
                                              prefixIcon: Icon(
                                                Icons.fitness_center,
                                                color: Color(0xFFC0C0C0),
                                                size: 18,
                                              ),
                                            ),
                                            style: TextStyle(
                                              fontFamily:
                                                  'JetBrainsMono_Regular',
                                              fontSize: 12,
                                              color: Color(0xFFC0C0C0),
                                              fontWeight: FontWeight.bold,
                                            ),
                                            keyboardType: TextInputType.number,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Color(0xFF0F0F0F),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color:
                                                checkedVariants[variant['name']] ==
                                                    true
                                                ? Color(0xFFC0C0C0)
                                                : Color(0xFF303030),
                                            width: 2,
                                          ),
                                        ),
                                        child: Theme(
                                          data: ThemeData(
                                            checkboxTheme: CheckboxThemeData(
                                              fillColor:
                                                  MaterialStateProperty.resolveWith(
                                                    (states) {
                                                      if (states.contains(
                                                        MaterialState.selected,
                                                      )) {
                                                        return Color(
                                                          0xFFC0C0C0,
                                                        );
                                                      }
                                                      return Colors.transparent;
                                                    },
                                                  ),
                                              checkColor:
                                                  MaterialStateProperty.all(
                                                    Color(0xFF0A0A0A),
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                          ),
                                          child: Checkbox(
                                            value:
                                                checkedVariants[variant['name']] ??
                                                false,
                                            onChanged: (value) {
                                              setState(() {
                                                checkedVariants[variant['name']] =
                                                    value ?? false;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
              ),

              SizedBox(height: 24),

              // Botón Guardar
              Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF2563eb), Color(0xFF1e40af)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x662563eb),
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        AgregarPeso.guardarPesos(
                          context,
                          currentExercise,
                          checkedVariants,
                          weightControllers,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(
                          horizontal: 60,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.save, color: Colors.white, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'GUARDAR',
                            style: TextStyle(
                              fontFamily: 'JetBrainsMono_Regular',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeriesChip(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Color(0x4D0066FF), width: 1),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'JetBrainsMono_Regular',
              fontSize: 7,
              color: Color(0xFF808080),
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'JetBrainsMono_Regular',
              fontSize: 9,
              color: Color(0xFFE0E0E0),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
