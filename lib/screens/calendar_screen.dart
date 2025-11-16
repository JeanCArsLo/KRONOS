import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:rive/rive.dart';
import '../widgets/main_layout.dart';
import '../dialogs/streak_detail_dialog.dart';
import '../rive_cache.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  CalendarScreenState createState() => CalendarScreenState();
}

class CalendarScreenState extends State<CalendarScreen> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;

  // DOS ARTBOARDS: uno para cada animación (precargados)
  Artboard? _artboardPetidle;
  Artboard? _artboardPETSad;

  RiveAnimationController? _controllerPetidle;
  RiveAnimationController? _controllerPETSad;

  Timer? _checkTimer;
  String _animacionActual = 'Petidle';

  // SISTEMA DE RACHAS
  int _rachaActual = 0;
  List<String> _fechasConRegistro = [];
  List<String> _fechasRachaPerdida = [];

  // 🔹 Tamaño y posición de la mascota
  double _mascotaWidth = 250;
  double _mascotaHeight = 250;
  Offset _mascotaOffset = const Offset(145, 10);

  @override
  void initState() {
    super.initState();

    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();

    // Cargar AMBOS artboards al inicio
    _cargarAmbosArtboards();

    // Cargar datos de racha
    _cargarDatosRacha();

    // Iniciar verificación periódica
    _iniciarVerificacionTiempo();
  }

  // CARGAR DATOS DE RACHA
  Future<void> _cargarDatosRacha() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        _rachaActual = prefs.getInt('racha_actual') ?? 0;
        _fechasConRegistro = prefs.getStringList('fechas_con_registro') ?? [];
        _fechasRachaPerdida = prefs.getStringList('fechas_racha_perdida') ?? [];
      });

      // Verificar si hay racha perdida no marcada
      await _verificarYMarcarRachaPerdida();

      debugPrint(' Racha actual: $_rachaActual');
      debugPrint(' Fechas con registro: ${_fechasConRegistro.length}');
      debugPrint(' Fechas racha perdida: ${_fechasRachaPerdida.length}');
    } catch (e) {
      debugPrint('Error cargando datos de racha: $e');
    }
  }

  // VERIFICAR SI HAY RACHA PERDIDA NO MARCADA
  Future<void> _verificarYMarcarRachaPerdida() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ultimoRegistro = prefs.getInt('ultimo_registro_peso');

      if (ultimoRegistro == null) return;

      final fechaUltimoRegistro = DateTime.fromMillisecondsSinceEpoch(
        ultimoRegistro,
      );
      final ahora = DateTime.now();

      // Calcular diferencia en días completos (ignorando horas)
      final fechaUltimoSoloFecha = DateTime(
        fechaUltimoRegistro.year,
        fechaUltimoRegistro.month,
        fechaUltimoRegistro.day,
      );
      final ahoraSoloFecha = DateTime(ahora.year, ahora.month, ahora.day);
      final diferenciaDias = ahoraSoloFecha
          .difference(fechaUltimoSoloFecha)
          .inDays;

      // Si pasaron 3 o más días y hay racha activa → Se pierde la racha
      if (diferenciaDias >= 3 && _rachaActual > 0) {
        // Calcular el día exacto donde se perdió (3 días después del último registro)
        final fechaPerdida = fechaUltimoSoloFecha.add(const Duration(days: 3));
        final fechaPerdidaString =
            '${fechaPerdida.year}-${fechaPerdida.month.toString().padLeft(2, '0')}-${fechaPerdida.day.toString().padLeft(2, '0')}';

        if (!_fechasRachaPerdida.contains(fechaPerdidaString)) {
          _fechasRachaPerdida.add(fechaPerdidaString);
          await prefs.setStringList(
            'fechas_racha_perdida',
            _fechasRachaPerdida,
          );

          // Reiniciar racha
          await prefs.setInt('racha_actual', 0);

          setState(() {
            _rachaActual = 0;
          });

          debugPrint(
            ' Racha perdida marcada en: $fechaPerdidaString (pasaron $diferenciaDias días)',
          );
        }
      }
    } catch (e) {
      debugPrint('Error verificando racha perdida: $e');
    }
  }

  // PRECARGAR AMBAS ANIMACIONES
  Future<void> _cargarAmbosArtboards() async {
    try {
      final cached = RiveCache.artboardCalendario;

      if (cached != null) {
        _artboardPetidle = cached.instance();
        _controllerPetidle = SimpleAnimation('Petidle', autoplay: false);
        _artboardPetidle!.addController(_controllerPetidle!);

        _artboardPETSad = cached.instance();
        _controllerPETSad = SimpleAnimation('PETSad', autoplay: false);
        _artboardPETSad!.addController(_controllerPETSad!);

        debugPrint(' Ambos artboards precargados desde caché');
      } else {
        final data = await rootBundle.load('assets/mascota/PetanimU.riv');
        final file = RiveFile.import(data);

        _artboardPetidle = file.mainArtboard.instance();
        _controllerPetidle = SimpleAnimation('Petidle', autoplay: false);
        _artboardPetidle!.addController(_controllerPetidle!);

        _artboardPETSad = file.mainArtboard.instance();
        _controllerPETSad = SimpleAnimation('PETSad', autoplay: false);
        _artboardPETSad!.addController(_controllerPETSad!);

        debugPrint(' Ambos artboards precargados desde assets');
      }

      // Activar solo Petidle al inicio
      _controllerPetidle?.isActive = true;

      setState(() {});
    } catch (e) {
      debugPrint(' Error cargando artboards: $e');
    }
  }

  void _iniciarVerificacionTiempo() {
    _checkTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _verificarTiempoTranscurrido();
    });

    _verificarTiempoTranscurrido();
  }

  Future<void> _verificarTiempoTranscurrido() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ultimoRegistro = prefs.getInt('ultimo_registro_peso');

      if (ultimoRegistro == null) {
        _cambiarAnimacion('PETSad');
        return;
      }

      final fechaUltimoRegistro = DateTime.fromMillisecondsSinceEpoch(
        ultimoRegistro,
      );
      final ahora = DateTime.now();

      // Calcular diferencia en días completos
      final fechaUltimoSoloFecha = DateTime(
        fechaUltimoRegistro.year,
        fechaUltimoRegistro.month,
        fechaUltimoRegistro.day,
      );
      final ahoraSoloFecha = DateTime(ahora.year, ahora.month, ahora.day);
      final diferenciaDias = ahoraSoloFecha
          .difference(fechaUltimoSoloFecha)
          .inDays;

      // Si pasaron 3 o más días → Mascota triste (racha perdida)
      // Días 0-2 sin registro → Mascota feliz (racha activa)
      if (diferenciaDias >= 3) {
        _cambiarAnimacion('PETSad');
        debugPrint('Mascota triste: $diferenciaDias días sin registro');
      } else {
        _cambiarAnimacion('Petidle');
        debugPrint('Mascota feliz: $diferenciaDias días sin registro');
      }
    } catch (e) {
      debugPrint('Error verificando tiempo: $e');
    }
  }

  void _cambiarAnimacion(String nuevaAnimacion) {
    if (_animacionActual == nuevaAnimacion) return;

    debugPrint('Cambiando a: $nuevaAnimacion');

    _controllerPetidle?.isActive = false;
    _controllerPETSad?.isActive = false;

    if (nuevaAnimacion == 'Petidle' && _controllerPetidle != null) {
      _controllerPetidle!.isActive = true;
      if (_controllerPetidle is SimpleAnimation) {
        (_controllerPetidle as SimpleAnimation).reset();
      }
    } else if (nuevaAnimacion == 'PETSad' && _controllerPETSad != null) {
      _controllerPETSad!.isActive = true;
      if (_controllerPETSad is SimpleAnimation) {
        (_controllerPETSad as SimpleAnimation).reset();
      }
    }

    setState(() {
      _animacionActual = nuevaAnimacion;
    });

    debugPrint('Animación $nuevaAnimacion activada y reiniciada');
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _controllerPetidle?.dispose();
    _controllerPETSad?.dispose();
    super.dispose();
  }

  // VERIFICAR SI UN DÍA TIENE REGISTRO
  bool _tieneRegistro(DateTime dia) {
    final diaString =
        '${dia.year}-${dia.month.toString().padLeft(2, '0')}-${dia.day.toString().padLeft(2, '0')}';
    return _fechasConRegistro.contains(diaString);
  }

  // VERIFICAR SI UN DÍA PERDIÓ LA RACHA
  bool _perdioRacha(DateTime dia) {
    final diaString =
        '${dia.year}-${dia.month.toString().padLeft(2, '0')}-${dia.day.toString().padLeft(2, '0')}';
    return _fechasRachaPerdida.contains(diaString);
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 0,
      child: Stack(
        children: [
          // ********************* MASCOTA PETIDLE *********************
          if (_artboardPetidle != null)
            Positioned(
              left: _mascotaOffset.dx,
              top: _mascotaOffset.dy,
              child: IgnorePointer(
                child: Opacity(
                  opacity: _animacionActual == 'Petidle' ? 1.0 : 0.0,
                  child: SizedBox(
                    width: _mascotaWidth,
                    height: _mascotaHeight,
                    child: RepaintBoundary(
                      child: Rive(
                        artboard: _artboardPetidle!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // ********************* MASCOTA PETSAD *********************
          if (_artboardPETSad != null)
            Positioned(
              left: _mascotaOffset.dx,
              top: _mascotaOffset.dy,
              child: IgnorePointer(
                child: Opacity(
                  opacity: _animacionActual == 'PETSad' ? 1.0 : 0.0,
                  child: SizedBox(
                    width: _mascotaWidth,
                    height: _mascotaHeight,
                    child: RepaintBoundary(
                      child: Rive(
                        artboard: _artboardPETSad!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // ********************* CONTENIDO PRINCIPAL *********************
          SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= ENCABEZADO ESTILO ENTRENADORES (sin rayas) =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Color(0xFF2563eb), // Azul brillante
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'CALENDARIO',
                        style: const TextStyle(
                          fontFamily: 'JetBrainsMono_Regular',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: Colors.white, // Texto blanco
                        ),
                      ),
                    ],
                  ),
                ),

                // QUITAMOS LAS RAYAS: const Divider(...),
                const SizedBox(height: 15),

                // ================= ENCABEZADO =================
                // Reemplazo del recuadro de fecha y racha
                // Busca la sección "ENCABEZADO" y reemplázala con este código:
                Transform.translate(
                  offset: const Offset(0, -10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.45,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Color(0xFF2563eb),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x4D000000),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ========== FECHA ==========
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_selectedDay.day}',
                                    style: const TextStyle(
                                      fontFamily: 'JetBrainsMono_Regular',
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2563eb),
                                      height: 1,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _getMonth(_selectedDay),
                                        style: const TextStyle(
                                          fontFamily: 'JetBrainsMono_Regular',
                                          fontSize: 12,
                                          color: Color(0xFFC0C0C0),
                                        ),
                                      ),
                                      Text(
                                        '${_selectedDay.year}',
                                        style: const TextStyle(
                                          fontFamily: 'JetBrainsMono_Regular',
                                          fontSize: 12,
                                          color: Color(0xFFC0C0C0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // ========== RAYA DIVISORIA HORIZONTAL ==========
                              Container(height: 1.5, color: Color(0xFF2563eb)),

                              const SizedBox(height: 16),

                              // ========== RACHA ==========
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _rachaActual.toString().padLeft(2, '0'),
                                        style: const TextStyle(
                                          fontFamily: 'JetBrainsMono_Regular',
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFFF8C00),
                                          height: 1,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'racha',
                                        style: TextStyle(
                                          fontFamily: 'JetBrainsMono_Regular',
                                          fontSize: 11,
                                          color: Color(0xFFC0C0C0),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  // ========== FUEGO REALISTA MINIMALISTA ==========
                                  SizedBox(
                                    width: 36,
                                    height: 36,
                                    child: Stack(
                                      children: [
                                        // Capa base (naranja oscuro)
                                        Positioned(
                                          bottom: 0,
                                          left: 8,
                                          child: Icon(
                                            Icons.local_fire_department,
                                            color: Color(0xFFFF4500),
                                            size: 36,
                                          ),
                                        ),
                                        // Capa intermedia (naranja brillante)
                                        Positioned(
                                          bottom: 2,
                                          left: 8,
                                          child: Icon(
                                            Icons.local_fire_department,
                                            color: Color(0xFFFF8C00),
                                            size: 30,
                                          ),
                                        ),
                                        // Capa superior (amarillo/blanco centro)
                                        Positioned(
                                          bottom: 6,
                                          left: 12,
                                          child: Icon(
                                            Icons.local_fire_department,
                                            color: Color(0xFFFFD700),
                                            size: 20,
                                          ),
                                        ),
                                      ],
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
                const SizedBox(height: 10),

                // ================= CALENDARIO CON MARCADORES =================
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  child: Transform.translate(
                    offset: const Offset(0, -10),
                    child: Transform.scale(
                      scale: 0.90,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 191, 190, 197),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TableCalendar(
                          firstDay: DateTime(2020),
                          lastDay: DateTime(2030),
                          focusedDay: _focusedDay,
                          selectedDayPredicate: (day) =>
                              isSameDay(_selectedDay, day),
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                          },
                          onPageChanged: (focusedDay) {
                            _focusedDay = focusedDay;
                          },

                          // MARCADORES PERSONALIZADOS
                          calendarBuilders: CalendarBuilders(
                            defaultBuilder: (context, day, focusedDay) {
                              if (_perdioRacha(day)) {
                                // Día donde se perdió la racha - X roja
                                return Container(
                                  margin: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: Text(
                                            '${day.day}',
                                            style: const TextStyle(
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        const Center(
                                          child: Icon(
                                            Icons.close,
                                            color: Colors.red,
                                            size: 30,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else if (_tieneRegistro(day)) {
                                // Día con registro - círculo naranja
                                return Container(
                                  margin: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${day.day}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return null;
                            },
                          ),

                          calendarStyle: CalendarStyle(
                            todayDecoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            selectedTextStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            weekendTextStyle: TextStyle(
                              color: Colors.grey[700],
                            ),
                          ),
                          headerStyle: const HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            titleTextStyle: TextStyle(
                              fontFamily: 'JetBrainsMono_Regular',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            leftChevronIcon: Icon(Icons.chevron_left),
                            rightChevronIcon: Icon(Icons.chevron_right),
                          ),
                          daysOfWeekStyle: const DaysOfWeekStyle(
                            weekdayStyle: TextStyle(
                              fontFamily: 'JetBrainsMono_Regular',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                            weekendStyle: TextStyle(
                              fontFamily: 'JetBrainsMono_Regular',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 70),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMonth(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[date.month - 1];
  }
}
