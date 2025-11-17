import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../db/database_helper.dart';
import '../dialogs/success_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rive/rive.dart' as Rive;
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
      SuccessNotification.showError(
        context,
        'Selecciona al menos un ejercicio',
      );
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
          SuccessNotification.showError(
            context,
            'Peso inválido en $exerciseName',
          );
          return;
        }

        var resultado = await dbHelper.registrarPesoYDetectarRecord(
          idUsuario: idUsuario,
          idEjercicio: variant['idEjercicio'],
          pesoNuevo: peso,
        );

        if (resultado['mostrarCelebracion'] == true) {
          nuevosRecords.add(exerciseName);
        }
      } catch (e) {
        SuccessNotification.showError(
          context,
          'Error al guardar $exerciseName',
        );
        return;
      }
    }

    // GUARDAR TIMESTAMP Y ACTUALIZAR RACHA (CON ID DE USUARIO)
    await _guardarUltimoRegistro(idUsuario);
    await _actualizarRacha(idUsuario);

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

  // Guardar timestamp del último registro de peso (POR USUARIO)
  static Future<void> _guardarUltimoRegistro(int idUsuario) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        'ultimo_registro_peso_user_$idUsuario',
        DateTime.now().millisecondsSinceEpoch,
      );
      print('Timestamp guardado para usuario $idUsuario: ${DateTime.now()}');
    } catch (e) {
      print('Error guardando timestamp: $e');
    }
  }

  // SISTEMA DE RACHAS (POR USUARIO)
  static Future<void> _actualizarRacha(int idUsuario) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // CLAVES CON ID DE USUARIO
      final keyRacha = 'racha_actual_user_$idUsuario';
      final keyUltimaFecha = 'ultima_fecha_registro_user_$idUsuario';
      final keyFechasRegistro = 'fechas_con_registro_user_$idUsuario';
      final keyFechasPerdida = 'fechas_racha_perdida_user_$idUsuario';

      // Obtener fecha de hoy (sin hora, solo día)
      final hoy = DateTime.now();
      final hoyString =
          '${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}';

      // Obtener datos de racha del usuario actual
      int rachaActual = prefs.getInt(keyRacha) ?? 0;
      String? ultimaFechaRegistroStr = prefs.getString(keyUltimaFecha);
      List<String> fechasConRegistro =
          prefs.getStringList(keyFechasRegistro) ?? [];

      // PRIMERO: Verificar si se perdió la racha ANTES de verificar si ya registró hoy
      if (ultimaFechaRegistroStr != null &&
          !fechasConRegistro.contains(hoyString)) {
        final ultimaFechaRegistro = DateTime.parse(ultimaFechaRegistroStr);

        // Calcular diferencia en días completos (sin considerar horas)
        final ultimaFechaSoloFecha = DateTime(
          ultimaFechaRegistro.year,
          ultimaFechaRegistro.month,
          ultimaFechaRegistro.day,
        );
        final hoySoloFecha = DateTime(hoy.year, hoy.month, hoy.day);
        final diferenciaDias = hoySoloFecha
            .difference(ultimaFechaSoloFecha)
            .inDays;

        // Si pasaron 3 o más días → Se pierde la racha
        if (diferenciaDias >= 3) {
          print('Racha perdida! Diferencia: $diferenciaDias días');

          // Guardar fecha donde se perdió la racha (día 3)
          List<String> fechasRachaPerdida =
              prefs.getStringList(keyFechasPerdida) ?? [];

          // Calcular el día exacto donde se perdió (3 días después del último registro)
          final fechaPerdida = ultimaFechaSoloFecha.add(
            const Duration(days: 3),
          );
          final fechaPerdidaString =
              '${fechaPerdida.year}-${fechaPerdida.month.toString().padLeft(2, '0')}-${fechaPerdida.day.toString().padLeft(2, '0')}';

          if (!fechasRachaPerdida.contains(fechaPerdidaString)) {
            fechasRachaPerdida.add(fechaPerdidaString);
            await prefs.setStringList(keyFechasPerdida, fechasRachaPerdida);
          }

          // Reiniciar racha a 0
          rachaActual = 0;
          await prefs.setInt(keyRacha, 0);
          print('Racha reiniciada a 0 (día perdido: $fechaPerdidaString)');
        }
      }

      // SEGUNDO: Si ya registró hoy, no hacer nada más
      if (fechasConRegistro.contains(hoyString)) {
        print('Ya se registró peso hoy, racha mantiene: $rachaActual');
        return;
      }

      // TERCERO: Incrementar racha (nuevo día registrado)
      rachaActual++;

      // Agregar fecha de hoy a las fechas con registro
      fechasConRegistro.add(hoyString);

      // Guardar datos actualizados
      await prefs.setInt(keyRacha, rachaActual);
      await prefs.setString(keyUltimaFecha, hoyString);
      await prefs.setStringList(keyFechasRegistro, fechasConRegistro);

      print('Racha actualizada para usuario $idUsuario: $rachaActual días');
      print('Fecha registrada: $hoyString');
    } catch (e) {
      print('Error actualizando racha: $e');
    }
  }

  // DIALOGO MINIMALISTA DE RÉCORD
  static void _mostrarDialogoRecord(
    BuildContext context,
    List<String> records,
    List<String> allCompleted,
  ) {
    Rive.Artboard? artboard;
    Rive.RiveAnimationController? controller;
    bool loadingFallback = false;

    try {
      final cached = RiveCache.artboardPopup;
      if (cached != null) {
        artboard = cached.instance();
        controller = Rive.SimpleAnimation('PetCel');
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
        final file = Rive.RiveFile.import(data);
        final ab = file.mainArtboard.instance();
        final c = Rive.SimpleAnimation('PetCel');
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
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: const EdgeInsets.symmetric(horizontal: 30),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0d1117), Color(0xFF161b22)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x4D000000),
                    blurRadius: 16,
                    spreadRadius: 0,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF8d8d8d),
                          Color(0xFFffffff),
                          Color(0xFFc0c0c0),
                          Color(0xFF6b6b6b),
                          Color(0xFFffffff),
                        ],
                        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                      ).createShader(bounds);
                    },
                    child: Text(
                      '¡Nuevo récord!',
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono_Regular',
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.3,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.8),
                            offset: Offset(0, 4),
                            blurRadius: 8,
                          ),
                          Shadow(
                            color: Color(0xFFc0c0c0).withOpacity(0.5),
                            offset: Offset(0, 0),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Superaste tu marca en:',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono_Regular',
                      fontSize: 10,
                      color: Color(0xFFD0D0D0),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0x0DFFFFFF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0x1AFFFFFF),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: records.map((record) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Container(
                                width: 3,
                                height: 12,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFF2563eb),
                                      Color(0xFFc0c0c0),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  record,
                                  style: const TextStyle(
                                    fontFamily: 'JetBrainsMono_Regular',
                                    fontSize: 10,
                                    color: Color(0xFFD0D0D0),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 14),

                  if (artboard != null)
                    RepaintBoundary(
                      child: SizedBox(
                        width: 150,
                        height: 150,
                        child: Transform.translate(
                          offset: const Offset(-25, -40),
                          child: Rive.Rive(
                            artboard: artboard!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox(
                      height: 100,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF2563eb),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: ElevatedButton(
                      onPressed: () {
                        try {
                          controller?.isActive = false;
                        } catch (_) {}
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(
                            color: Colors.white70,
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: const Text(
                        'CERRAR',
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono_Regular',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                          letterSpacing: 1.5,
                        ),
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
