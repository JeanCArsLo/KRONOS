class User {
  final int id;
  final String fullName;
  final String email;
  final String passwordHash; // contraseña hasheada
  final DateTime birthDate;
  final String gender; // 'M' o 'F'

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.passwordHash,
    required this.birthDate,
    required this.gender,
  });

  // === FROM MAP (SEGURO CON FECHA) ===
  factory User.fromMap(Map<String, dynamic> map) {
    final fechaStr = map['Fecha_nac'] as String?;
    DateTime birthDate;

    if (fechaStr == null || fechaStr.isEmpty) {
      birthDate = DateTime(2000, 1, 1);
    } else {
      final parts = fechaStr.split('-');
      if (parts.length == 3 &&
          parts[0].length == 4 &&
          parts[1].length == 2 &&
          parts[2].length == 2) {
        try {
          birthDate = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
        } catch (e) {
          birthDate = DateTime(2000, 1, 1);
        }
      } else {
        // Fallback: intentar parsear como ISO
        try {
          birthDate = DateTime.parse('$fechaStr' + (fechaStr.contains('T') ? '' : 'T00:00:00'));
        } catch (e) {
          birthDate = DateTime(2000, 1, 1);
        }
      }
    }

    return User(
      id: map['IdUsuario'] as int,
      fullName: map['Nombres'] as String? ?? '',
      email: map['Correo'] as String? ?? '',
      passwordHash: map['Contraseña'] as String? ?? '',
      birthDate: birthDate,
      gender: (map['Genero'] as String?)?.toUpperCase() == 'F' ? 'F' : 'M',
    );
  }

  // === TO MAP (PARA INSERT/UPDATE) ===
  Map<String, dynamic> toMap() {
    return {
      'IdUsuario': id,
      'Nombres': fullName,
      'Correo': email,
      'Contraseña': passwordHash,
      'Fecha_nac': birthDate.toIso8601String().split('T').first, // YYYY-MM-DD
      'Genero': gender.toUpperCase(),
    };
  }

  // === COPYWITH ===
  User copyWith({
    int? id,
    String? fullName,
    String? email,
    String? passwordHash,
    DateTime? birthDate,
    String? gender,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
    );
  }

  // === UTILS ===
  int get age {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  @override
  String toString() {
    return 'User(id: $id, name: $fullName, email: $email, age: $age, gender: $gender)';
  }
}