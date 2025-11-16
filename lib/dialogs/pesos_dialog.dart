import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/record_personal.dart';

class PesosDialog extends StatefulWidget {
  final Map<String, dynamic> exercise;

  const PesosDialog({super.key, required this.exercise});

  @override
  State<PesosDialog> createState() => _PesosDialogState();
}

class _PesosDialogState extends State<PesosDialog> {
  late DatabaseHelper _dbHelper;
  List<RecordPersonal> _allRecords = [];
  List<RecordPersonal> _last4Records = [];
  bool _isLoading = true;
  double? _prActual;

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    try {
      final records = await _dbHelper.getRecordsByEjercicio(
        widget.exercise['idUsuario'],
        widget.exercise['idEjercicio'],
      );

      if (records.isEmpty) {
        setState(() {
          _allRecords = [];
          _last4Records = [];
          _prActual = null;
          _isLoading = false;
        });
        return;
      }

      records.sort((a, b) {
        try {
          return b.fecha.compareTo(a.fecha);
        } catch (e) {
          return 0;
        }
      });

      setState(() {
        _allRecords = records;
        _prActual = records
            .map((r) => r.peso)
            .reduce((max, peso) => peso > max ? peso : max);
        _last4Records = records.take(4).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: const Color(0xFF1e1e1e),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 40,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ Header: más ligero, centrado, sin barra izquierda
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Text(
                widget.exercise['name'].toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'JetBrainsMono_Regular',
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Línea divisoria más sutil
            Container(
              height: 0.5,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              color: const Color(0xFF444444),
            ),

            // Contenido
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: _isLoading
                  ? const SizedBox(
                      height: 180,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFF6B35),
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : _allRecords.isEmpty
                  ? const SizedBox(
                      height: 180,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 40,
                              color: Color(0xFF6b6b6b),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Sin registros',
                              style: TextStyle(
                                fontFamily: 'JetBrainsMono_Regular',
                                fontSize: 13,
                                color: Color(0xFF808080),
                                fontWeight: FontWeight.normal,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ✅ PR Actual: más compacto, letra más fina
                        // ✅ PR Actual: fondo plateado brillante pero sutil + naranja en icono/texto
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF3a3a3a), // Plateado oscuro
                                const Color(0xFF4a4a4a), // Plateado medio
                                const Color(0xFF3a3a3a),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              // ✅ Brillo interno plateado (simula reflejo)
                              BoxShadow(
                                color: const Color(
                                  0x40ffffff,
                                ), // Blanco muy transparente
                                blurRadius: 20,
                                spreadRadius: -8,
                                offset: const Offset(0, -2),
                              ),
                              // ✅ Sombra exterior suave (profundidad)
                              BoxShadow(
                                color: const Color(0x30000000),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // ✅ Reflejo radial plateado (brillo metálico realista)
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: RadialGradient(
                                    center: Alignment.topLeft,
                                    radius: 1.2,
                                    colors: [
                                      Colors.transparent,
                                      const Color(
                                        0x20ffffff,
                                      ), // Brillo blanco suave
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFFF7a45),
                                          Color(0xFFFF5522),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0x66FF6B35),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.emoji_events,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'PR',
                                          style: TextStyle(
                                            fontFamily: 'JetBrainsMono_Regular',
                                            fontSize: 14,
                                            color: Color(0xFFbbbbbb),
                                            fontWeight: FontWeight.normal,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${_prActual?.toStringAsFixed(1) ?? '0.0'} kg',
                                          style: const TextStyle(
                                            fontFamily: 'JetBrainsMono_Regular',
                                            fontSize: 26,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.white,
                                            letterSpacing: 0.2,
                                            shadows: [
                                              Shadow(
                                                blurRadius: 6,
                                                color: const Color(
                                                  0x88FF6B35,
                                                ), // ✅ Naranja brillante pero suave
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
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
                        const SizedBox(height: 20),

                        // ✅ Título historial: 'HISTORIAL' en mayúsculas (compatible)
                        const Text(
                          'HISTORIAL',
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono_Regular',
                            fontSize: 10,
                            color: Color(0xFF777777),
                            fontWeight: FontWeight.normal,
                            letterSpacing: 1.2,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // ✅ Lista de registros: más compacta, letras finas
                        ..._last4Records.asMap().entries.map((entry) {
                          final record = entry.value;
                          final isPR = record.peso == _prActual;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 14,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF252525),
                              borderRadius: BorderRadius.circular(8),
                              border: isPR
                                  ? Border.all(
                                      color: const Color(0xFFFF6B35),
                                      width: 1,
                                    )
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _formatearFecha(record.fecha),
                                        style: const TextStyle(
                                          fontFamily: 'JetBrainsMono_Regular',
                                          fontSize: 11,
                                          color: Color(0xFFbbbbbb),
                                          fontWeight: FontWeight.normal,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      if (isPR)
                                        const Padding(
                                          padding: EdgeInsets.only(top: 2),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.emoji_events,
                                                size: 8,
                                                color: Color(0xFFFF6B35),
                                              ),
                                              SizedBox(width: 3),
                                              Text(
                                                'PR',
                                                style: TextStyle(
                                                  fontFamily:
                                                      'JetBrainsMono_Regular',
                                                  fontSize: 8,
                                                  color: Color(0xFFFF6B35),
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${record.peso.toStringAsFixed(1)} kg',
                                  style: TextStyle(
                                    fontFamily: 'JetBrainsMono_Regular',
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                    color: isPR
                                        ? const Color(0xFFFF6B35)
                                        : const Color(0xFFe0e0e0),
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),

                        if (_allRecords.length > 4)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '+ ${_allRecords.length - 4}',
                              style: const TextStyle(
                                fontFamily: 'JetBrainsMono_Regular',
                                fontSize: 10,
                                color: Color(0xFF6b6b6b),
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                      ],
                    ),
            ),

            // ✅ Botón CERRAR: minimalista, compatible
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 1.2),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                  child: const Text(
                    'CERRAR',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono_Regular',
                      fontSize: 11,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatearFecha(String fecha) {
    try {
      final partes = fecha.split('-');
      if (partes.length == 3) {
        return '${partes[2]}/${partes[1]}'; // Ej: "15/04"
      }
      return fecha;
    } catch (e) {
      return fecha;
    }
  }
}
