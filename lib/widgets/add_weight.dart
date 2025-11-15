import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../db/database_helper.dart';
import '../dialogs/success_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rive/rive.dart';
import 'dart:convert';

import '../rive_cache.dart';

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

    // 🔥 GUARDAR TIMESTAMP Y ACTUALIZAR RACHA
    await _guardarUltimoRegistro();
    await _actualizarRacha();

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

  // 🔥 Guardar timestamp del último registro de peso
  static Future<void> _guardarUltimoRegistro() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('ultimo_registro_peso', DateTime.now().millisecondsSinceEpoch);
      print('✅ Timestamp guardado: ${DateTime.now()}');
    } catch (e) {
      print('❌ Error guardando timestamp: $e');
    }
  }

  // 🔥 SISTEMA DE RACHAS
  static Future<void> _actualizarRacha() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Obtener fecha de hoy (sin hora, solo día)
      final hoy = DateTime.now();
      final hoyString = '${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}';

      // Obtener datos de racha
      int rachaActual = prefs.getInt('racha_actual') ?? 0;
      String? ultimaFechaRegistroStr = prefs.getString('ultima_fecha_registro');
      List<String> fechasConRegistro = prefs.getStringList('fechas_con_registro') ?? [];

      // ✅ PRIMERO: Verificar si se perdió la racha ANTES de verificar si ya registró hoy
      if (ultimaFechaRegistroStr != null && !fechasConRegistro.contains(hoyString)) {
        final ultimaFechaRegistro = DateTime.parse(ultimaFechaRegistroStr);

        // Calcular diferencia en días completos (sin considerar horas)
        final ultimaFechaSoloFecha = DateTime(ultimaFechaRegistro.year, ultimaFechaRegistro.month, ultimaFechaRegistro.day);
        final hoySoloFecha = DateTime(hoy.year, hoy.month, hoy.day);
        final diferenciaDias = hoySoloFecha.difference(ultimaFechaSoloFecha).inDays;

        // Si pasaron 3 o más días → Se pierde la racha
        if (diferenciaDias >= 3) {
          // Se perdió la racha
          print('❌ Racha perdida! Diferencia: $diferenciaDias días');

          // Guardar fecha donde se perdió la racha (día 3)
          List<String> fechasRachaPerdida = prefs.getStringList('fechas_racha_perdida') ?? [];

          // Calcular el día exacto donde se perdió (3 días después del último registro)
          final fechaPerdida = ultimaFechaSoloFecha.add(const Duration(days: 3));
          final fechaPerdidaString = '${fechaPerdida.year}-${fechaPerdida.month.toString().padLeft(2, '0')}-${fechaPerdida.day.toString().padLeft(2, '0')}';

          if (!fechasRachaPerdida.contains(fechaPerdidaString)) {
            fechasRachaPerdida.add(fechaPerdidaString);
            await prefs.setStringList('fechas_racha_perdida', fechasRachaPerdida);
          }

          // ✅ Reiniciar racha a 0
          rachaActual = 0;
          await prefs.setInt('racha_actual', 0);
          print('🔄 Racha reiniciada a 0 (día perdido: $fechaPerdidaString)');
        }
      }

      // ✅ SEGUNDO: Si ya registró hoy, no hacer nada más
      if (fechasConRegistro.contains(hoyString)) {
        print('✅ Ya se registró peso hoy, racha mantiene: $rachaActual');
        return;
      }

      // ✅ TERCERO: Incrementar racha (nuevo día registrado)
      rachaActual++;

      // Agregar fecha de hoy a las fechas con registro
      fechasConRegistro.add(hoyString);

      // Guardar datos actualizados
      await prefs.setInt('racha_actual', rachaActual);
      await prefs.setString('ultima_fecha_registro', hoyString);
      await prefs.setStringList('fechas_con_registro', fechasConRegistro);

      print('✅ Racha actualizada: $rachaActual días');
      print('✅ Fecha registrada: $hoyString');

    } catch (e) {
      print('❌ Error actualizando racha: $e');
    }
  }

  // 🔥 DIALOGO OPTIMIZADO: CLONAR ARTBOARD PRECARGADO (o fallback asíncrono)
  static void _mostrarDialogoRecord(
      BuildContext context,
      List<String> records,
      List<String> allCompleted,
      ) {
    Artboard? artboard;
    RiveAnimationController? controller;
    bool loadingFallback = false;

    try {
      final cached = RiveCache.artboardPopup;
      if (cached != null) {
        artboard = cached.instance();
        controller = SimpleAnimation('PetCel');
        artboard.addController(controller);
      }
    } catch (e) {
      artboard = null;
      controller = null;
      print('Error clonando artboardPopup: $e');
    }

    Future<void> _loadFallback() async {
      try {
        loadingFallback = true;
        final data = await rootBundle.load('assets/mascota/PetanimU.riv');
        final file = RiveFile.import(data);
        final ab = file.mainArtboard.instance();
        final c = SimpleAnimation('PetCel');
        ab.addController(c);
        artboard = ab;
        controller = c;
      } catch (e) {
        print('Error cargando fallback Rive para popup: $e');
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          if (artboard == null && !loadingFallback) {
            _loadFallback().then((_) {
              try {
                (context as Element).markNeedsBuild();
              } catch (_) {}
            });
          }

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
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.emoji_events,
                    size: 80,
                    color: Color.fromARGB(255, 255, 140, 0),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    '¡NUEVO RÉCORD!',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono_Regular',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 140, 0),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Superaste tu marca en:',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono_Regular',
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 248, 240),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: const Color.fromARGB(255, 255, 140, 0),
                          width: 1),
                    ),
                    child: Column(
                      children: records.map((record) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.stars,
                                  color: Color.fromARGB(255, 255, 140, 0),
                                  size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  record,
                                  style: const TextStyle(
                                    fontFamily: 'JetBrainsMono_Regular',
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  if (artboard != null)
                    RepaintBoundary(
                      child: SizedBox(
                        width: 150,
                        height: 150,
                        child: Transform.translate(
                          offset: const Offset(-25, -40),
                          child: Rive(
                            artboard: artboard!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    ),

                  const SizedBox(height: 5),

                  ElevatedButton(
                    onPressed: () {
                      try {
                        controller?.isActive = false;
                      } catch (_) {}
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 140, 0),
                      padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
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