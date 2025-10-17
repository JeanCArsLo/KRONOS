import 'package:flutter/material.dart';

class TrainerDetailDialog extends StatelessWidget {
  final Map<String, String> trainer;

  const TrainerDetailDialog({
    super.key,
    required this.trainer,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.orange,
          width: 3,
        ),
      ),
      backgroundColor: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ========== TÍTULO ==========
            Text(
              'EL es ${trainer['name']}',
              style: TextStyle(
                fontFamily: 'JetBrainsMono_Regular',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 15),

            // ========== CONTENEDOR BLANCO CON IMAGEN Y TEXTO ==========
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              padding: EdgeInsets.all(15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ========== IMAGEN A LA IZQUIERDA ==========
                  Container(
                    width: 100,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: AssetImage(trainer['image']!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  SizedBox(width: 15),

                  // ========== TEXTO A LA DERECHA ==========
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trainer['specialty']!,
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono_Regular',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Horario disponible:',
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono_Regular',
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          '6:00 am - 12:00pm\n18:00 pm - 21:00 pm',
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono_Regular',
                            fontSize: 9,
                            color: Colors.blue,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 15),

            // ========== DESCRIPCIÓN ABAJO ==========
            Text(
              trainer['description']!,
              style: TextStyle(
                fontFamily: 'JetBrainsMono_Regular',
                fontSize: 10,
                color: Colors.black87,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}