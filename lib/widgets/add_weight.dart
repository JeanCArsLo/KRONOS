import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../dialogs/success_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    List<String> nuevosRecords = []; // 🏆 Para guardar los récords QUE SE DEBEN CELEBRAR

    for (var exerciseName in completedExercises) {
      try {
        final variant = currentExercise['variants'].firstWhere(
          (v) => v['name'] == exerciseName,
          orElse: () => <String, dynamic>{},
        );
        
        if (variant.isEmpty) {
          continue;
        }

        final pesoText = weightControllers[exerciseName]!.text.trim();
        double? peso = pesoText.isNotEmpty ? double.tryParse(pesoText) : null;

        if (peso == null || peso <= 0) {
          SuccessNotification.showError(context, 'Peso inválido en $exerciseName');
          return;
        }

        // 1️⃣ GUARDAR EN LA TABLA EJERCICIO
        final updateData = {
          'IdEjercicio': variant['idEjercicio'],
          'IdPartesC': variant['idPartesC'],
          'IdAreaM': variant['idAreaM'],
          'Nombre': variant['name'],
          'Descripcion': variant['description'],
          'Peso': peso,
        };
        await dbHelper.updateEjercicio(updateData);

        // 2️⃣ 🔥 GUARDAR EN RecordPersonal Y OBTENER INFO DETALLADA
        var resultado = await dbHelper.registrarPesoYDetectarRecord(
          idUsuario: idUsuario,
          idEjercicio: variant['idEjercicio'],
          pesoNuevo: peso,
        );

        // 🎉 SOLO AGREGAR A LA LISTA SI SE DEBE CELEBRAR
        if (resultado['mostrarCelebracion'] == true) {
          nuevosRecords.add(exerciseName);
        }
        
        // 📊 DEBUG (opcional, puedes quitar esto)
        print('📊 $exerciseName: ${resultado['razon']}');

      } catch (e) {
        SuccessNotification.showError(context, 'Error al guardar $exerciseName');
        return;
      }
    }

    // 🎊 MOSTRAR RESULTADO
    if (nuevosRecords.isNotEmpty) {
      // 🏆 SI HAY RÉCORDS NUEVOS PARA CELEBRAR
      _mostrarDialogoRecord(context, nuevosRecords, completedExercises);
    } else {
      // ✅ SI NO HAY RÉCORDS, NOTIFICACIÓN NORMAL
      SuccessNotification.show(
        context,
        'Ejercicios guardados: ${completedExercises.join(", ")}',
      );
    }
  }

  // 🔥 MÉTODO PARA OBTENER EL USUARIO ACTUAL
  static Future<int?> _getUsuarioActual() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('current_user_id'); // Asume que guardas el ID con esta key
    } catch (e) {
      print('Error obteniendo usuario: $e');
      return null;
    }
  }

  // 🎉 DIÁLOGO ESPECIAL PARA CELEBRAR RÉCORDS
  static void _mostrarDialogoRecord(
    BuildContext context,
    List<String> records,
    List<String> allCompleted,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false, // No se cierra tocando afuera
      builder: (context) => Dialog(
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
              // 🏆 ICONO DE TROFEO
              Icon(
                Icons.emoji_events,
                size: 80,
                color: const Color.fromARGB(255, 255, 140, 0),
              ),
              SizedBox(height: 15),
              
              // 🎉 TÍTULO
              Text(
                '¡NUEVO RÉCORD!',
                style: TextStyle(
                  fontFamily: 'JetBrainsMono_Regular',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 255, 140, 0),
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 10),
              
              // 📝 SUBTÍTULO
              Text(
                'Superaste tu marca en:',
                style: TextStyle(
                  fontFamily: 'JetBrainsMono_Regular',
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 15),
              
              // 🏆 LISTA DE RÉCORDS
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
              
              // 📊 EJERCICIOS TOTALES GUARDADOS
              if (allCompleted.length > records.length) ...[
                SizedBox(height: 10),
                Text(
                  'Otros ejercicios guardados: ${allCompleted.where((e) => !records.contains(e)).join(", ")}',
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono_Regular',
                    fontSize: 9,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              
              SizedBox(height: 20),
              
              // 🎯 BOTÓN CERRAR
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
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
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}