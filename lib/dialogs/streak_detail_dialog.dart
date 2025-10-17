import 'package:flutter/material.dart';

class StreakDetailDialog extends StatelessWidget {
  final int streakDays;
  final String petEmoji;

  const StreakDetailDialog({
    super.key,
    required this.streakDays,
    required this.petEmoji,
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
              'Llevas una racha de',
              style: TextStyle(
                fontFamily: 'JetBrainsMono_Regular',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),

            SizedBox(height: 10),

            // ========== NÚMERO DE DÍAS CON FUEGO ==========
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_fire_department,
                    color: Colors.orange, size: 28),
                SizedBox(width: 8),
                Text(
                  '$streakDays',
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono_Regular',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'días',
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono_Regular',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),

            SizedBox(height: 15),

            // ========== INDICADORES DE DÍAS ==========
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDayIndicator('1d', Colors.orange),
                SizedBox(width: 8),
                _buildDayIndicator('30d', Colors.purple),
                SizedBox(width: 8),
                _buildDayIndicator('68d', Colors.deepPurple),
              ],
            ),

            SizedBox(height: 20),

            // ========== MASCOTA ==========
            Text(
              petEmoji,
              style: TextStyle(fontSize: 60),
            ),

            SizedBox(height: 20),

            
          ],
        ),
      ),
    );
  }

  Widget _buildDayIndicator(String day, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: Center(
        child: Text(
          day,
          style: TextStyle(
            fontFamily: 'JetBrainsMono_Regular',
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}