import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
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

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 0, // ← Marca el icono de Calendario
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(
              color: const Color.fromARGB(255, 0, 4, 255),
              thickness: 2,
              indent: 20,
              endIndent: 20,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'CALENDARIO',
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

            SizedBox(height: 15),

            // ========== ENCABEZADO CON FECHA Y RACHA ==========
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // COLUMNA 1: Fecha y Racha
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.orange,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Fecha
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_selectedDay.day}',
                              style: TextStyle(
                                fontFamily: 'JetBrainsMono_Regular',
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getMonth(_selectedDay),
                                  style: TextStyle(
                                    fontFamily: 'JetBrainsMono_Regular',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Text(
                                  '${_selectedDay.year}',
                                  style: TextStyle(
                                    fontFamily: 'JetBrainsMono_Regular',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        // Racha
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '07',
                                  style: TextStyle(
                                    fontFamily: 'JetBrainsMono_Regular',
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  'racha',
                                  style: TextStyle(
                                    fontFamily: 'JetBrainsMono_Regular',
                                    fontSize: 10,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 10),
                            Icon(Icons.local_fire_department,
                                color: Colors.orange, size: 32),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // COLUMNA 2: Mascota
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => StreakDetailDialog(
                          streakDays: 7,
                          petEmoji: '🐯',
                        ),
                      );
                    },
                    child: Text(
                      '🐯',
                      style: TextStyle(fontSize: 80),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // ========== CALENDARIO ==========
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TableCalendar(
                  firstDay: DateTime(2020),
                  lastDay: DateTime(2030),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                      // ========== AQUÍ VA LA LÓGICA CUANDO SELECCIONES UN DÍA ==========
                      // Por ejemplo: cargar entrenamientos, eventos, etc.
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    weekendTextStyle: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                  headerStyle: HeaderStyle(
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
                  daysOfWeekStyle: DaysOfWeekStyle(
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

            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ========== FUNCIÓN AUXILIAR PARA OBTENER MES Y AÑO ==========
  // String _getMonthYear(DateTime date) {
  //   final months = [
  //     'January',
  //     'February',
  //     'March',
  //     'April',
  //     'May',
  //     'June',
  //     'July',
  //     'August',
  //     'September',
  //     'October',
  //     'November',
  //     'December'
  //   ];
  //   return '${months[date.month - 1]} ${date.year}';
  // }
  // ========== FUNCIÓN AUXILIAR PARA OBTENER SOLO EL MES ==========
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