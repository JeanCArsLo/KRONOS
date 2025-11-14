import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
import '../widgets/main_layout.dart';
import '../dialogs/streak_detail_dialog.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  CalendarScreenState createState() => CalendarScreenState();
}

class CalendarScreenState extends State<CalendarScreen> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;

  Artboard? _artboard;
  late RiveAnimationController _controller;

  // 🔹 Variables para tamaño y posición de la mascota
  double _mascotaWidth = 250;
  double _mascotaHeight = 250;
  Offset _mascotaOffset = const Offset(145, 10);

  @override
  void initState() {
    super.initState();

    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();

    // Cargar Rive
    rootBundle.load('assets/mascota/PetanimU.riv').then((data) {
      final file = RiveFile.import(data);
      final artboard = file.mainArtboard;

      var controller = SimpleAnimation('idle');
      if (!artboard.animations.any((a) => a.name == 'idle')) {
        controller = SimpleAnimation('Petidle');
      }

      artboard.addController(controller);

      setState(() {
        _artboard = artboard;
        _controller = controller;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 0,
      child: Stack(
        children: [
          // ********************* MASCOTA DETRÁS DE TODO *********************
          Positioned(
            left: _mascotaOffset.dx,
            top: _mascotaOffset.dy,
            child: IgnorePointer(
              child: SizedBox(
                width: _mascotaWidth,
                height: _mascotaHeight,
                child: _artboard == null
                    ? const Text(
                  'Cargando...',
                  style: TextStyle(color: Colors.white),
                )
                    : Rive(artboard: _artboard!),
              ),
            ),
          ),

          // ********************* CONTENIDO PRINCIPAL *********************
            SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(), // ⛔ scroll bloqueado
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                const Divider(
                  color: Color.fromARGB(255, 0, 4, 255),
                  thickness: 2,
                  indent: 20,
                  endIndent: 20,
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    ' CALENDARIO',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono_Regular',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                const Divider(
                  color: Color.fromARGB(255, 0, 4, 255),
                  thickness: 2,
                  indent: 20,
                  endIndent: 20,
                ),

                const SizedBox(height: 15),

                // ================= ENCABEZADO =================
                Transform.translate(
                  offset: const Offset(0, -25), // 🔼 Mueve el cuadro día/racha hacia arriba
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 🧾 CONTADOR
                        Container(
                          width: MediaQuery.of(context).size.width * 0.45,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.orange, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_selectedDay.day}',
                                    style: const TextStyle(
                                      fontFamily: 'JetBrainsMono_Regular',
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _getMonth(_selectedDay),
                                        style: const TextStyle(
                                          fontFamily: 'JetBrainsMono_Regular',
                                          fontSize: 12,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      Text(
                                        '${_selectedDay.year}',
                                        style: const TextStyle(
                                          fontFamily: 'JetBrainsMono_Regular',
                                          fontSize: 12,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Row(
                                children: const [
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '07',
                                        style: TextStyle(
                                          fontFamily: 'JetBrainsMono_Regular',
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        'racha',
                                        style: TextStyle(
                                          fontFamily: 'JetBrainsMono_Regular',
                                          fontSize: 10,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 10),
                                  Icon(
                                    Icons.local_fire_department,
                                    color: Colors.orange,
                                    size: 32,
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

                // ================= CALENDARIO REDUCIDO + MOVIDO HACIA ARRIBA =================
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  child: Transform.translate(
                    offset: const Offset(0, -45), // 🔼 Mueve el calendario hacia arriba
                    child: Transform.scale(
                      scale: 0.90,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
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
      'December'
    ];
    return months[date.month - 1];
  }
}
