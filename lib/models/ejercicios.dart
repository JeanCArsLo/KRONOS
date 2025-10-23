class PartesCuerpo {
  final int idPartesC;
  final String nombre;

  PartesCuerpo({
    required this.idPartesC,
    required this.nombre,
  });

  factory PartesCuerpo.fromMap(Map<String, dynamic> map) {
    return PartesCuerpo(
      idPartesC: map['IdPartesC'],
      nombre: map['Nombre'],
    );
  }

  Map<String, dynamic> toMap() => {
    'IdPartesC': idPartesC,
    'Nombre': nombre,
  };
}

class ZonaMuscular {
  final int idAreaM;
  final int? idPartesC; // Opcional si no siempre está presente
  final String nombre;

  ZonaMuscular({
    required this.idAreaM,
    this.idPartesC,
    required this.nombre,
  });

  factory ZonaMuscular.fromMap(Map<String, dynamic> map) {
    return ZonaMuscular(
      idAreaM: map['IdAreaM'],
      idPartesC: map['IdPartesC'],
      nombre: map['Nombre'],
    );
  }

  Map<String, dynamic> toMap() => {
    'IdAreaM': idAreaM,
    'IdPartesC': idPartesC,
    'Nombre': nombre,
  };
}

class Ejercicio {
  final int idEjercicio;
  final int idPartesC;
  final int idAreaM;
  final String nombre;
  final String? descripcion;
  final double? peso;

  Ejercicio({
    required this.idEjercicio,
    required this.idPartesC,
    required this.idAreaM,
    required this.nombre,
    this.descripcion,
    this.peso,
  });

  factory Ejercicio.fromMap(Map<String, dynamic> map) {
    return Ejercicio(
      idEjercicio: map['IdEjercicio'],
      idPartesC: map['IdPartesC'],
      idAreaM: map['IdAreaM'],
      nombre: map['Nombre'],
      descripcion: map['Descripcion'],
      peso: map['Peso'] != null ? map['Peso'].toDouble() : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'IdEjercicio': idEjercicio,
    'IdPartesC': idPartesC,
    'IdAreaM': idAreaM,
    'Nombre': nombre,
    'Descripcion': descripcion,
    'Peso': peso,
  };
}