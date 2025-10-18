import 'package:flutter/material.dart';
import '../widgets/main_layout.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final String exerciseTitle;
  
  const ExerciseDetailScreen({
    super.key,
    required this.exerciseTitle,
  });

  @override
  ExerciseDetailScreenState createState() => ExerciseDetailScreenState();
}

class ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  // ========== MAPA DE EJERCICIOS CON SUS DETALLES ==========
  final Map<String, Map<String, dynamic>> exercisesData = {
    'Espalda': {
      'description': 'Trabajo integral de espalda, mejora la postura, la fuerza y la estabilidad corporal. Una espalda fuerte protege la columna y equilibra el desarrollo muscular.',
      'advice': 'Realiza los ejercicios con peso moderado y buena técnica. Aumenta el peso sólo cuando controles el movimiento. La clave está en la forma, no sólo en la fuerza.',
      'variants': [
        {
          'name': 'Jalón al pecho',
          'description': 'Fortalece la parte superior de la espalda y mejora la postura.',
          'series': '4x8-10',
          'hypertrophy': '4x10-12',
          'tonification': '3x12-15',
          'image': 'assets/workout_area/superior/espalda/jalon_al_pecho.jpg',
        },
        {
          'name': 'Remo sentado',
          'description': 'Trabaja la espalda media y ayuda a definir los dorsales.',
          'series': '4x8',
          'hypertrophy': '4x10-12',
          'tonification': '3x15',
          'image': 'assets/workout_area/superior/espalda/remo_sentado.jpg',
        },
        {
          'name': 'Remo unilateral',
          'description': 'Aumenta grosor y fuerza en la espalda media.',
          'series': '4x6-8',
          'hypertrophy': '4x10',
          'tonification': '3x12-15',
          'image': 'assets/workout_area/superior/espalda/remo_unilateral.jpg',
        },
        {
          'name': 'Remo con barra inclinado',
          'description': 'Ejercicio completo que fortalece toda la espalda.',
          'series': '4x5-6',
          'hypertrophy': '4x8-10',
          'tonification': '3x12',
          'image': 'assets/workout_area/superior/espalda/remo_con_barra_inclinada.jpg',
        },
      ],
    },
  };

  late Map<String, dynamic> currentExercise;
  late Map<String, bool> checkedVariants;

  @override
  void initState() {
    super.initState();
    currentExercise = exercisesData[widget.exerciseTitle]!;
    checkedVariants = {
      for (var variant in currentExercise['variants'])
        variant['name']: false,
    };
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 3,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========== HEADER ==========
            Divider(
              color: const Color.fromARGB(255, 0, 4, 255),
              thickness: 2,
              indent: 20,
              endIndent: 20,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                widget.exerciseTitle.toUpperCase(),
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

            SizedBox(height: 20),

            // ========== DESCRIPCIÓN ==========
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(255, 255, 140, 0),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Descripción:',
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono_Regular',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      currentExercise['description'],
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono_Regular',
                        fontSize: 11,
                        height: 1.5,
                        color: const Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 15),

            // ========== CONSEJO ==========
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(255, 255, 140, 0),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Consejo:',
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono_Regular',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      currentExercise['advice'],
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono_Regular',
                        fontSize: 11,
                        height: 1.5,
                        color: const Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // ========== VARIANTES DE EJERCICIOS (IMAGEN IZQUIERDA + INFO DERECHA) ==========
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: List.generate(
                  currentExercise['variants'].length,
                  (index) {
                    var variant = currentExercise['variants'][index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color.fromARGB(255, 0, 0, 0),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ========== IMAGEN A LA IZQUIERDA ==========
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: BorderSide(
                                          color: const Color.fromARGB(255, 255, 140, 0),
                                          width: 3,
                                        ),
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
                                  ),
                                ),
                              ),

                              SizedBox(width: 12),

                              // ========== INFO A LA DERECHA ==========
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ========== NOMBRE ==========
                                    Text(
                                      variant['name'],
                                      style: TextStyle(
                                        fontFamily: 'JetBrainsMono_Regular',
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.6,
                                      ),
                                    ),

                                    SizedBox(height: 6),

                                    // ========== DESCRIPCIÓN DEL EJERCICIO ==========
                                    Text(
                                      variant['description'],
                                      style: TextStyle(
                                        fontFamily: 'JetBrainsMono_Regular',
                                        fontSize: 10,
                                        color: const Color.fromARGB(255, 0, 0, 0),
                                        height: 1.4,
                                      ),
                                    ),

                                    SizedBox(height: 8),

                                    // ========== SERIES Y REPS ==========
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Series y reps\n',
                                            style: TextStyle(
                                              fontFamily: 'JetBrainsMono_Regular',
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: const Color.fromARGB(255, 0, 0, 0),
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Fuerza: ${variant['series']}\n',
                                            style: TextStyle(
                                              fontFamily: 'JetBrainsMono_Regular',
                                              fontSize: 8,
                                              color: const Color.fromARGB(255, 0, 0, 0),
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Hipertrofia: ${variant['hypertrophy']}\n',
                                            style: TextStyle(
                                              fontFamily: 'JetBrainsMono_Regular',
                                              fontSize: 8,
                                              color: const Color.fromARGB(255, 0, 0, 0),
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Tonificación: ${variant['tonification']}',
                                            style: TextStyle(
                                              fontFamily: 'JetBrainsMono_Regular',
                                              fontSize: 8,
                                              color: const Color.fromARGB(255, 0, 0, 0),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(height: 10),

                                    // ========== INPUT Y CHECKBOX ==========
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            decoration: InputDecoration(
                                              hintText: 'Peso:',
                                              hintStyle: TextStyle(
                                                fontFamily: 'JetBrainsMono_Regular',
                                                fontSize: 9,
                                                color: Colors.grey[500],
                                              ),
                                              contentPadding: EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 6,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(4),
                                                borderSide: BorderSide(
                                                  color: Colors.grey[600]!,
                                                ),
                                              ),
                                            ),
                                            style: TextStyle(
                                              fontFamily: 'JetBrainsMono_Regular',
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: const Color.fromARGB(255, 0, 0, 0),
                                              width: 1,
                                            ),
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
                      ),
                    );
                  },
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
                    // ========== LÓGICA AL GUARDAR ==========
                    List<String> completedExercises = checkedVariants.entries
                        .where((e) => e.value)
                        .map((e) => e.key)
                        .toList();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          completedExercises.isEmpty
                              ? 'Selecciona al menos un ejercicio'
                              : 'Ejercicios guardados: ${completedExercises.join(", ")}',
                        ),
                      ),
                    );
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