import 'package:flutter/material.dart';

class TrainerDetailDialog extends StatelessWidget {
  final Map<String, String> trainer;

  const TrainerDetailDialog({super.key, required this.trainer});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        // side: BorderSide.none, // Opcional: Elimina cualquier borde predeterminado del Dialog
      ),
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0d1117), Color(0xFF161b22)],
            ),
            borderRadius: BorderRadius.circular(24),
            // border: Border.all(color: Color(0xFF2563eb), width: 1.5), // ← ELIMINADO
            boxShadow: [
              BoxShadow(
                color: Color(
                  0x4D000000,
                ), // ← Cambiado a negro semi-transparente
                blurRadius: 16,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ========== TÍTULO MINIMALISTA ==========
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF2563eb), Color(0xFFc0c0c0)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x662563eb),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        '${trainer['name']!.endsWith('a') ? 'Ella' : 'El'} es ${trainer['name']}',
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono_Regular',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 18),

                // ========== CONTENEDOR PRINCIPAL ==========
                Container(
                  decoration: BoxDecoration(
                    color: Color(0x0DFFFFFF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Color(0x1AFFFFFF), width: 1),
                  ),
                  padding: EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ========== IMAGEN ==========
                      Container(
                        width: 95,
                        height: 115,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            width: 1.5,
                            color: Color(
                              0xFF2563eb,
                            ), // Este borde azul dentro de la imagen se mantiene si lo deseas
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x332563eb),
                              blurRadius: 8,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.5),
                          child: Image.asset(
                            trainer['image']!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      SizedBox(width: 14),

                      // ========== INFO ==========
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Especialidad
                            Text(
                              trainer['specialty']!,
                              style: TextStyle(
                                fontFamily: 'JetBrainsMono_Regular',
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFc0c0c0),
                                letterSpacing: 0.5,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            SizedBox(height: 12),

                            // Horario título
                            Row(
                              children: [
                                Container(
                                  width: 3,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF2563eb),
                                        Color(0xFFc0c0c0),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'Horario disponible:',
                                    style: TextStyle(
                                      fontFamily: 'JetBrainsMono_Regular',
                                      fontSize: 9,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFFE0E0E0),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 8),

                            // Horarios
                            Row(
                              children: [
                                Icon(
                                  Icons.wb_sunny_outlined,
                                  color: Color(0xFF2563eb),
                                  size: 11,
                                ),
                                SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    '6:00 am - 12:00 pm',
                                    style: TextStyle(
                                      fontFamily: 'JetBrainsMono_Regular',
                                      fontSize: 9,
                                      color: Color(0xFFB3B3B3),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 4),

                            Row(
                              children: [
                                Icon(
                                  Icons.nightlight_round,
                                  color: Color(0xFFc0c0c0),
                                  size: 11,
                                ),
                                SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    '6:00 pm - 9:00 pm',
                                    style: TextStyle(
                                      fontFamily: 'JetBrainsMono_Regular',
                                      fontSize: 9,
                                      color: Color(0xFFB3B3B3),
                                    ),
                                    overflow: TextOverflow.ellipsis,
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

                SizedBox(height: 14),

                // ========== DESCRIPCIÓN ==========
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0x0DFFFFFF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0x1AFFFFFF), width: 1),
                  ),
                  child: Text(
                    trainer['description']!,
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono_Regular',
                      fontSize: 10,
                      color: Color(0xFFD0D0D0),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: 16),

                // ========== BOTÓN CERRAR MINIMALISTA (MODIFICADO) ==========
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, // Fondo transparente
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          // Borde plateado
                          color: Colors.white70,
                          width: 1.5,
                        ),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      'CERRAR',
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono_Regular',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70, // Texto plateado
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
