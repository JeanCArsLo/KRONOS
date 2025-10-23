import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class AgregarPeso {
  static Future<void> guardarPesos(BuildContext context, Map<String, dynamic> currentExercise, Map<String, bool> checkedVariants, Map<String, TextEditingController> weightControllers) async {
    final dbHelper = DatabaseHelper();
    List<String> completedExercises = checkedVariants.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (completedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selecciona al menos un ejercicio')),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar $exerciseName: $e')),
        );
      }
    }

    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text('Ejercicios guardados: ${completedExercises.join(", ")}')),
    // );
  }
}