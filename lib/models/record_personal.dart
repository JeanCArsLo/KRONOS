class RecordPersonal {
  final int? idRecord;
  final int idUsuario;
  final int idEjercicio;
  final double peso;
  final String fecha; // Formato: 'YYYY-MM-DD'
  final int esRecordMaximo; // 0 o 1
  final String estado; // 'vigente' o 'superado'

  RecordPersonal({
    this.idRecord,
    required this.idUsuario,
    required this.idEjercicio,
    required this.peso,
    required this.fecha,
    this.esRecordMaximo = 0,
    this.estado = 'vigente',
  });

  factory RecordPersonal.fromMap(Map<String, dynamic> map) {
    return RecordPersonal(
      idRecord: map['idRecord'],
      idUsuario: map['IdUsuario'],
      idEjercicio: map['IdEjercicio'],
      peso: map['Peso'].toDouble(),
      fecha: map['Fecha'],
      esRecordMaximo: map['EsRecordMaximo'] ?? 0,
      estado: map['estado'] ?? 'vigente',
    );
  }

  Map<String, dynamic> toMap() => {
    if (idRecord != null) 'idRecord': idRecord,
    'IdUsuario': idUsuario,
    'IdEjercicio': idEjercicio,
    'Peso': peso,
    'Fecha': fecha,
    'EsRecordMaximo': esRecordMaximo,
    'estado': estado,
  };

  // Método auxiliar para copiar con modificaciones
  RecordPersonal copyWith({
    int? idRecord,
    int? idUsuario,
    int? idEjercicio,
    double? peso,
    String? fecha,
    int? esRecordMaximo,
    String? estado,
  }) {
    return RecordPersonal(
      idRecord: idRecord ?? this.idRecord,
      idUsuario: idUsuario ?? this.idUsuario,
      idEjercicio: idEjercicio ?? this.idEjercicio,
      peso: peso ?? this.peso,
      fecha: fecha ?? this.fecha,
      esRecordMaximo: esRecordMaximo ?? this.esRecordMaximo,
      estado: estado ?? this.estado,
    );
  }
}