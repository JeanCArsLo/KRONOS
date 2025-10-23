import 'package:flutter/material.dart';
import '../widgets/main_layout.dart';
import '../dialogs/pesos_dialog.dart';

class RecordPRScreen extends StatefulWidget {
  const RecordPRScreen({super.key});

  @override
  RecordPRScreenState createState() => RecordPRScreenState();
}

class RecordPRScreenState extends State<RecordPRScreen> {
  // ========== DATOS DE EJERCICIOS ORGANIZADOS POR CATEGORÍA ==========
  final Map<String, List<Map<String, dynamic>>> exercisesByCategory = {
    'Espalda': [
      {
        'name': 'Jalón al pecho',
        'image': 'assets/workout_area/superior/espalda/jalon_al_pecho.jpg',
        'exerciseTitle': 'Espalda',
      },
      {
        'name': 'Remo unilateral',
        'image': 'assets/workout_area/superior/espalda/remo_unilateral.jpg',
        'exerciseTitle': 'Espalda',
      },
      {
        'name': 'Remo con barra inclinado',
        'image': 'assets/workout_area/superior/espalda/remo_con_barra_inclinada.jpg',
        'exerciseTitle': 'Espalda',
      },
      {
        'name': 'Remo sentado',
        'image': 'assets/workout_area/superior/espalda/remo_sentado.jpg',
        'exerciseTitle': 'Espalda',
      },
    ],
    'Pecho': [
      {
        'name': 'Cruce de poleas',
        'image': 'assets/workout_area/superior/pecho/cruce_de_poleas.jpg',
        'exerciseTitle': 'Pecho',
      },
      {
        'name': 'Apertura en maquina',
        'image': 'assets/workout_area/superior/pecho/apertura_en_maquina.jpg',
        'exerciseTitle': 'Pecho',
      },
      {
        'name': 'Press inclinado con mancuerna',
        'image': 'assets/workout_area/superior/pecho/press_inclinado_con_mancuerna.jpg',
        'exerciseTitle': 'Pecho',
      },
      {
        'name': 'Press de banca inclinado con banca',
        'image': 'assets/workout_area/superior/pecho/press_de_banca_inclinado_con_barra.jpg',
        'exerciseTitle': 'Pecho',
      },
    ],
    'Hombros': [
      // Aquí puedes agregar los ejercicios de hombros cuando tengas las imágenes
    ],
  };

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 1, // Índice para el ícono de medalla en el bottom navigation
      child: SingleChildScrollView(
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
            }),//.toList(),

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
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            categoryName,
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
      width: 160,
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