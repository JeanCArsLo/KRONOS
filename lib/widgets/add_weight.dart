import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../dialogs/success_notification.dart'; // ← CAMBIO DE NOMBRE

class AgregarPeso {
  static Future<void> guardarPesos(BuildContext context, Map<String, dynamic> currentExercise, Map<String, bool> checkedVariants, Map<String, TextEditingController> weightControllers) async {
    final dbHelper = DatabaseHelper();
    List<String> completedExercises = checkedVariants.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (completedExercises.isEmpty) {
      SuccessNotification.showError(context, 'Selecciona al menos un ejercicio'); // ← USA NOTIFICATION
      return;
    }

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

        final updateData = {
          'IdEjercicio': variant['idEjercicio'],
          'IdPartesC': variant['idPartesC'],
          'IdAreaM': variant['idAreaM'],
          'Nombre': variant['name'],
          'Descripcion': variant['description'],
          'Peso': peso,
        };
        final rowsAffected = await dbHelper.updateEjercicio(updateData);
      } catch (e) {
        SuccessNotification.showError(context, 'Error al guardar $exerciseName'); // ← USA NOTIFICATION
        return;
      }
    }

    SuccessNotification.show(context, 'Ejercicios guardados: ${completedExercises.join(", ")}'); // ← USA NOTIFICATION
  }
}