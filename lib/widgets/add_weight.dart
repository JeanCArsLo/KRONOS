import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../dialogs/success_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

class AgregarPeso {
  static Future<void> guardarPesos(
      BuildContext context,
      Map<String, dynamic> currentExercise,
      Map<String, bool> checkedVariants,
      Map<String, TextEditingController> weightControllers,
      ) async {
    final dbHelper = DatabaseHelper();

    List<String> completedExercises = checkedVariants.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (completedExercises.isEmpty) {
      SuccessNotification.showError(context, 'Selecciona al menos un ejercicio');
      return;
    }

    int? idUsuario = await _getUsuarioActual();

    if (idUsuario == null) {
      SuccessNotification.showError(context, 'Error: Usuario no identificado');
      return;
    }

    List<String> nuevosRecords = [];

    for (var exerciseName in completedExercises) {
      try {
        final variant = currentExercise['variants'].firstWhere(
              (v) => v['name'] == exerciseName,
          orElse: () => <String, dynamic>{},
        );

        if (variant.isEmpty) continue;

        final pesoText = weightControllers[exerciseName]!.text.trim();
        double? peso = pesoText.isNotEmpty ? double.tryParse(pesoText) : null;

        if (peso == null || peso <= 0) {
          SuccessNotification.showError(context, 'Peso inválido en $exerciseName');
          return;
        }

        final updateData = {
          'IdEjercicio': variant['idEjercicio'],
          'IdPartesC': variant['idPartesC'],
          'IdAreaM': variant['idAreaM'],
          'Nombre': variant['name'],
          'Descripcion': variant['description'],
          'Peso': peso,
        };
        await dbHelper.updateEjercicio(updateData);

        var resultado = await dbHelper.registrarPesoYDetectarRecord(
          idUsuario: idUsuario,
          idEjercicio: variant['idEjercicio'],
          pesoNuevo: peso,
        );

        if (resultado['mostrarCelebracion'] == true) {
          nuevosRecords.add(exerciseName);
        }

      } catch (e) {
        SuccessNotification.showError(context, 'Error al guardar $exerciseName');
        return;
      }
    }

    if (nuevosRecords.isNotEmpty) {
      _mostrarDialogoRecord(context, nuevosRecords, completedExercises);
    } else {
      SuccessNotification.show(
        context,
        'Ejercicios guardados: ${completedExercises.join(", ")}',
      );
    }
  }

  static Future<int?> _getUsuarioActual() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('current_user_id');
    } catch (e) {
      print('Error obteniendo usuario: $e');
      return null;
    }
  }

  // 🔥🔥🔥 DIALOGO COMPLETO CON LA MASCOTA DEBAJO DEL CUADRO 🔥🔥🔥
  static void _mostrarDialogoRecord(
      BuildContext context,
      List<String> records,
      List<String> allCompleted,
      ) {
    Artboard? artboard;
    RiveAnimationController? controller;

    // Cargar animación
    rootBundle.load('assets/mascota/PetanimU.riv').then((data) {
      final file = RiveFile.import(data);
      final ab = file.mainArtboard;
      controller = SimpleAnimation('PetCel');
      ab.addController(controller!);
      artboard = ab;

      (context as Element).markNeedsBuild();
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(17),
              side: BorderSide(
                color: const Color.fromARGB(255, 255, 140, 0),
                width: 3,
              ),
            ),
            backgroundColor: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.emoji_events,
                    size: 80,
                    color: const Color.fromARGB(255, 255, 140, 0),
                  ),
                  SizedBox(height: 15),

                  Text(
                    '¡NUEVO RÉCORD!',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono_Regular',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 255, 140, 0),
                    ),
                  ),
                  SizedBox(height: 10),

                  Text(
                    'Superaste tu marca en:',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono_Regular',
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: 15),

                  // ⭐⭐⭐ CUADRO DE LOS RECORDS ⭐⭐⭐
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 248, 240),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color.fromARGB(255, 255, 140, 0),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: records.map((record) => Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.stars,
                              color: const Color.fromARGB(255, 255, 140, 0),
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                record,
                                style: TextStyle(
                                  fontFamily: 'JetBrainsMono_Regular',
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                    ),
                  ),

                  SizedBox(height: 15),

                  // ⭐⭐⭐ MASCOTA DEBAJO DEL CUADRO ⭐⭐⭐
                  if (artboard != null)
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: Transform.translate(
                        offset: Offset(-25, -40), // ⬅ más a la izquierda
                        child: Rive(
                          artboard: artboard!,
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 100,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),

                  SizedBox(height: 0),

                  ElevatedButton(
                    onPressed: () {
                      controller?.isActive = false;
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 140, 0),
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      '¡Genial!',
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono_Regular',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
