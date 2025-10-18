import 'package:flutter/material.dart';

class PesosDialog extends StatelessWidget {
  final Map<String, dynamic> exercise;

  const PesosDialog({
    super.key,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    // ========== DATOS ESTÁTICOS DE EJEMPLO ==========
    final List<Map<String, String>> pesosData = [
      {'fecha': '2025 - 10 - 07', 'peso': '7,5'},
      {'fecha': '2025 - 10 - 14', 'peso': '7,5'},
      {'fecha': '2025 - 10 - 21', 'peso': '10'},
      {'fecha': '2025 - 10 - 28', 'peso': '10'},
      {'fecha': '2025 - 11 - 04', 'peso': '12,5'},
    ];

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
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
            // ========== ENCABEZADOS DE LA TABLA ==========
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Fecha',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono_Regular',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 0, 4, 255),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Container(
                  width: 2,
                  height: 30,
                  color: const Color.fromARGB(255, 255, 140, 0),
                ),
                Expanded(
                  child: Text(
                    'Peso',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono_Regular',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 0, 4, 255),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),

            // ========== LÍNEA DIVISORIA HORIZONTAL ==========
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              height: 2,
              color: const Color.fromARGB(255, 255, 140, 0),
            ),

            // ========== FILAS DE DATOS ==========
            ...pesosData.map((data) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        data['fecha']!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono_Regular',
                          fontSize: 13,
                          color: Colors.black87,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 25,
                      color: const Color.fromARGB(255, 255, 140, 0),
                    ),
                    Expanded(
                      child: Text(
                        data['peso']!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono_Regular',
                          fontSize: 13,
                          color: Colors.black87,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            })//.toList(),
          ],
        ),
      ),
    );
  }
}