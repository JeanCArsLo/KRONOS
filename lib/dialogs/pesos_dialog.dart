import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/record_personal.dart';

class PesosDialog extends StatefulWidget {
  final Map<String, dynamic> exercise;

  const PesosDialog({
    super.key,
    required this.exercise,
  });

  @override
  State<PesosDialog> createState() => _PesosDialogState();
}

class _PesosDialogState extends State<PesosDialog> {
  late DatabaseHelper _dbHelper;
  List<RecordPersonal> _records = [];
  bool _isLoading = true;

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

      setState(() {
        _records = records;
        _isLoading = false;
      });
    } catch (e) {
      print('Error cargando historial: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
        child: _isLoading
            ? SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              )
            : _records.isEmpty
                ? SizedBox(
                    height: 200,
                    child: Center(
                      child: Text(
                        'No hay historial',
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono_Regular',
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ========== TÍTULO ==========
                      Text(
                        widget.exercise['name'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono_Regular',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 255, 140, 0),
                        ),
                      ),
                      SizedBox(height: 15),

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
                              'Peso (kg)',
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
                      ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 300),
                        child: SingleChildScrollView(
                          child: Column(
                            children: _records.map((record) {
                              final isRecord = record.esRecordMaximo == 1;
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _formatearFecha(record.fecha),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'JetBrainsMono_Regular',
                                          fontSize: 13,
                                          color: Colors.black87,
                                          letterSpacing: 0.3,
                                          fontWeight: isRecord ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 2,
                                      height: 25,
                                      color: const Color.fromARGB(255, 255, 140, 0),
                                    ),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          if (isRecord)
                                            Icon(
                                              Icons.emoji_events,
                                              size: 16,
                                              color: const Color.fromARGB(255, 255, 140, 0),
                                            ),
                                          SizedBox(width: 5),
                                          Text(
                                            record.peso.toStringAsFixed(1),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: 'JetBrainsMono_Regular',
                                              fontSize: 13,
                                              color: isRecord
                                                  ? const Color.fromARGB(255, 255, 140, 0)
                                                  : Colors.black87,
                                              letterSpacing: 0.3,
                                              fontWeight: isRecord ? FontWeight.bold : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
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
        return '${partes[2]}-${partes[1]}-${partes[0]}'; // DD-MM-YYYY
      }
      return fecha;
    } catch (e) {
      return fecha;
    }
  }
}