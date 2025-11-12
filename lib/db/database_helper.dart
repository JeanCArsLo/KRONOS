import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user.dart';
import '../models/record_personal.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();
    String path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      path,
      version: 4, // ¡SUBIMOS LA VERSIÓN!
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // Para migrar datos existentes
    );
  }

  // 🔥 CREAR TABLAS (versión 2)
  Future _onCreate(Database db, int version) async {
    // === TABLA USUARIO ===
    await db.execute('''
      CREATE TABLE Usuario (
        IdUsuario INTEGER PRIMARY KEY AUTOINCREMENT,
        Nombres text NOT NULL,
        Correo text NOT NULL UNIQUE,
        Contraseña TEXT NOT NULL,
        Fecha_nac DATE NOT NULL,
        Genero CHAR(1) NOT NULL CHECK (Genero IN ('M', 'F')),
        FotoPerfil TEXT
      )
    ''');
    // Nueva tabla: PartesCuerpo (contiene las partes generales del cuerpo como Tren Superior, Tren Inferior)
    await db.execute('''
      CREATE TABLE PartesCuerpo (
        IdPartesC INTEGER PRIMARY KEY,
        Nombre TEXT NOT NULL
      )
    ''');

    // Nueva tabla: ZonaMuscular (contiene las zonas musculares específicas como Espalda, Hombros, etc.)
    await db.execute('''
      CREATE TABLE ZonaMuscular (
        IdAreaM INTEGER PRIMARY KEY,
        IdPartesC INTEGER,
        Nombre TEXT NOT NULL,
        FOREIGN KEY (IdPartesC) REFERENCES PartesCuerpo(IdPartesC)
      )
    ''');

    // Nueva tabla: Ejercicio (contiene los ejercicios con relación a PartesCuerpo y ZonaMuscular)
    await db.execute('''
      CREATE TABLE Ejercicio (
        IdEjercicio INTEGER PRIMARY KEY,
        IdPartesC INTEGER,
        IdAreaM INTEGER,
        Nombre TEXT NOT NULL,
        Descripcion TEXT,
        Peso REAL,
        FOREIGN KEY (IdPartesC) REFERENCES PartesCuerpo(IdPartesC),
        FOREIGN KEY (IdAreaM) REFERENCES ZonaMuscular(IdAreaM)
      )
    ''');

    // === TABLA RECORD PERSONAL ===
    await db.execute('''
      CREATE TABLE RecordPersonal (
        idRecord INTEGER PRIMARY KEY AUTOINCREMENT,
        IdUsuario INTEGER NOT NULL,
        IdEjercicio INTEGER NOT NULL,
        Peso REAL NOT NULL CHECK (Peso > 0),
        Fecha DATE DEFAULT (date('now')),
        EsRecordMaximo INTEGER DEFAULT 0 CHECK (EsRecordMaximo IN (0, 1)),
        estado TEXT DEFAULT 'vigente' CHECK (estado IN ('vigente', 'superado')),
        FOREIGN KEY (IdUsuario) REFERENCES Usuario(IdUsuario),
        FOREIGN KEY (IdEjercicio) REFERENCES Ejercicio(IdEjercicio),
        UNIQUE(IdUsuario, IdEjercicio, Fecha)
      )
    ''');

    // Inserciones iniciales de datos
    await _insertInitialData(db);
  }
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Renombrar tabla antigua
      await db.execute('ALTER TABLE users RENAME TO users_old');

      // Crear nueva tabla
      await db.execute('''
        CREATE TABLE Usuario (
          IdUsuario INTEGER PRIMARY KEY AUTOINCREMENT,
          Nombres VARCHAR(100) NOT NULL,
          Correo VARCHAR(100) NOT NULL UNIQUE,
          Contraseña TEXT NOT NULL,
          Fecha_nac DATE NOT NULL,
          Genero CHAR(1) NOT NULL CHECK (Genero IN ('M', 'F'))
        )
      ''');

      // Migrar datos (con valores por defecto)
      await db.execute('''
        INSERT INTO Usuario (IdUsuario, Nombres, Correo, Contraseña, Fecha_nac, Genero)
        SELECT id, fullName, COALESCE(email, 'sin_correo@example.com'), passwordHash, '2000-01-01', 'M'
        FROM users_old
      ''');
      
      // Eliminar tabla vieja
      await db.execute('DROP TABLE users_old');
    }
    // MIGRACIÓN VERSIÓN 3: FOTO DE PERFIL
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE Usuario ADD COLUMN FotoPerfil TEXT');
    }
    if (oldVersion < 4) {
      // Recrear la tabla con la estructura correcta
      await db.execute('DROP TABLE IF EXISTS RecordPersonal');
      
      await db.execute('''
        CREATE TABLE RecordPersonal (
          idRecord INTEGER PRIMARY KEY AUTOINCREMENT,
          IdUsuario INTEGER NOT NULL,
          IdEjercicio INTEGER NOT NULL,
          Peso REAL NOT NULL CHECK (Peso > 0),
          Fecha DATE DEFAULT (date('now')),
          EsRecordMaximo INTEGER DEFAULT 0 CHECK (EsRecordMaximo IN (0, 1)),
          estado TEXT DEFAULT 'vigente' CHECK (estado IN ('vigente', 'superado')),
          FOREIGN KEY (IdUsuario) REFERENCES Usuario(IdUsuario),
          FOREIGN KEY (IdEjercicio) REFERENCES Ejercicio(IdEjercicio),
          UNIQUE(IdUsuario, IdEjercicio, Fecha)
        )
      ''');
    }
  }

  // Método para insertar datos iniciales
  Future<void> _insertInitialData(Database db) async {
    // Insertar partes del cuerpo
    await db.insert('PartesCuerpo', {'IdPartesC': 1, 'Nombre': 'Tren Superior'});
    await db.insert('PartesCuerpo', {'IdPartesC': 2, 'Nombre': 'Tren Inferior'});

    // Insertar zonas musculares para Tren Superior
    await db.insert('ZonaMuscular', {'IdAreaM': 1, 'IdPartesC': 1, 'Nombre': 'Espalda'});
    await db.insert('ZonaMuscular', {'IdAreaM': 2, 'IdPartesC': 1, 'Nombre': 'Hombros'});
    await db.insert('ZonaMuscular', {'IdAreaM': 3, 'IdPartesC': 1, 'Nombre': 'Pecho'});
    await db.insert('ZonaMuscular', {'IdAreaM': 4, 'IdPartesC': 1, 'Nombre': 'Bíceps'});
    await db.insert('ZonaMuscular', {'IdAreaM': 5, 'IdPartesC': 1, 'Nombre': 'Tríceps'});
    await db.insert('ZonaMuscular', {'IdAreaM': 6, 'IdPartesC': 1, 'Nombre': 'Antebrazo'});
    await db.insert('ZonaMuscular', {'IdAreaM': 7, 'IdPartesC': 2, 'Nombre': 'Cuádriceps'});
    await db.insert('ZonaMuscular', {'IdAreaM': 8, 'IdPartesC': 2, 'Nombre': 'Femoral'});
    await db.insert('ZonaMuscular', {'IdAreaM': 9, 'IdPartesC': 2, 'Nombre': 'Glúteos'});
    await db.insert('ZonaMuscular', {'IdAreaM': 10, 'IdPartesC': 2, 'Nombre': 'Pantorrillas'});

    // Insertar ejercicios de ejemplo para Tren Superior
    //ESPALDA
    await db.insert('Ejercicio', {
      'IdPartesC': 1, // Tren Superior
      'IdAreaM': 1,   // Espalda
      'Nombre': 'Jalón al pecho',
      'Descripcion': 'Fortalece la parte superior de la espalda y mejora la postura.',
      'Peso': 0.0
    });

    await db.insert('Ejercicio', {
      'IdPartesC': 1, // Tren Superior
      'IdAreaM': 1,   // Espalda
      'Nombre': 'Remo sentado',
      'Descripcion': 'Trabaja la espalda media y ayuda a definir los dorsales.',
      'Peso': 0.0
    });

    await db.insert('Ejercicio', {
      'IdPartesC': 1, // Tren Superior
      'IdAreaM': 1,   // Espalda
      'Nombre': 'Remo unilateral',
      'Descripcion': 'Aumenta grosor y fuerza en la espalda media.',
      'Peso': 0.0
    });

    await db.insert('Ejercicio', {
      'IdPartesC': 1, // Tren Superior
      'IdAreaM': 1,   // Espalda
      'Nombre': 'Remo con barra inclinada',
      'Descripcion': 'Ejercicio completo que fortalece toda la espalda.',
      'Peso': 0.0
    });

    //PECHO
    await db.insert('Ejercicio', {
      'IdPartesC': 1, // Tren Superior
      'IdAreaM': 3,   // Pecho
      'Nombre': 'Apertura en máquina',
      'Descripcion': 'Aísla y trabaja los pectorales, mejorando la amplitud del pecho.',
      'Peso': 0.0
    });

    await db.insert('Ejercicio', {
      'IdPartesC': 1, // Tren Superior
      'IdAreaM': 3,   // Pecho
      'Nombre': 'Cruce de poleas',
      'Descripcion': 'Define el pecho central y mejora la contracción muscular.',
      'Peso': 0.0
    });

    await db.insert('Ejercicio', {
      'IdPartesC': 1, // Tren Superior
      'IdAreaM': 3,   // Pecho
      'Nombre': 'Press de banca inclinado con barra',
      'Descripcion': 'Desarrolla el pecho superior y aumenta la fuerza general.',
      'Peso': 0.0
    });

    await db.insert('Ejercicio', {
      'IdPartesC': 1, // Tren Superior
      'IdAreaM': 3,   // Pecho
      'Nombre': 'Press inclinado con mancuerna',
      'Descripcion': 'Fortalece el pecho superior con mayor rango de movimiento.',
      'Peso': 0.0
    });

    //ANTEBRAZOS
    await db.insert('Ejercicio', {
      'IdPartesC': 1, // Tren Superior
      'IdAreaM': 6,   // Antebrazo
      'Nombre': 'Curl inverso con disco',
      'Descripcion': 'Fortalece los antebrazos y mejora el agarre con pronación.',
      'Peso': 0.0
    });

    await db.insert('Ejercicio', {
      'IdPartesC': 1, // Tren Superior
      'IdAreaM': 6,   // Antebrazo
      'Nombre': 'Curl de muñecas con barra',
      'Descripcion': 'Desarrolla la parte flexora del antebrazo y aumenta la fuerza de agarre.',
      'Peso': 0.0
    });

    await db.insert('Ejercicio', {
      'IdPartesC': 1, // Tren Superior
      'IdAreaM': 6,   // Antebrazo
      'Nombre': 'Curl de muñecas inverso con mancuernas',
      'Descripcion': 'Trabaja los extensores del antebrazo y mejora el equilibrio muscular.',
      'Peso': 0.0
    });

    await db.insert('Ejercicio', {
      'IdPartesC': 1, // Tren Superior
      'IdAreaM': 6,   // Antebrazo
      'Nombre': 'Rodillo de muñeca',
      'Descripcion': 'Ejercicio completo que fortalece antebrazos y mejora la resistencia del agarre.',
      'Peso': 0.0
    });

    //Bíceps
    await db.insert('Ejercicio', {
      'IdPartesC': 1, // Tren Superior
      'IdAreaM': 4,   // Bíceps
      'Nombre': 'Curl con barra Z',
      'Descripcion': 'Desarrolla el bíceps completo con menor tensión en las muñecas.',
      'Peso': 0.0
    });

    await db.insert('Ejercicio', {
      'IdPartesC': 1, // Tren Superior
      'IdAreaM': 4,   // Bíceps
      'Nombre': 'Curl martillo',
      'Descripcion': 'Fortalece el bíceps y el braquial, aumentando el grosor del brazo.',
      'Peso': 0.0
    });

    await db.insert('Ejercicio', {
      'IdPartesC': 1, // Tren Superior
      'IdAreaM': 4,   // Bíceps
      'Nombre': 'Curl martillo inclinado',
      'Descripcion': 'Trabaja el bíceps con mayor estiramiento y rango de movimiento.',
      'Peso': 0.0
    });

    await db.insert('Ejercicio', {
      'IdPartesC': 1, // Tren Superior
      'IdAreaM': 4,   // Bíceps
      'Nombre': 'Curl predicador',
      'Descripcion': 'Aísla el bíceps eliminando el impulso y mejorando el pico muscular.',
      'Peso': 0.0
    });

    //HOMBRO
    await db.insert('Ejercicio', {
      'IdPartesC': 1, // Tren Superior
      'IdAreaM': 2,   // Hombros
      'Nombre': 'Remo vertical con cable',
      'Descripcion': 'Desarrolla los deltoides y trapecios, mejorando la anchura de hombros.',
      'Peso': 0.0
    });

    await db.insert('Ejercicio', {
      'IdPartesC': 1, // Tren Superior
      'IdAreaM': 2,   // Hombros
      'Nombre': 'Elevación lateral',
      'Descripcion': 'Aísla el deltoides medio y aumenta la anchura de los hombros.',
      'Peso': 0.0
    });

    await db.insert('Ejercicio', {
      'IdPartesC': 1, // Tren Superior
      'IdAreaM': 2,   // Hombros
      'Nombre': 'Face pull',
      'Descripcion': 'Fortalece el deltoides posterior y mejora la salud del hombro.',
      'Peso': 0.0
    });

    await db.insert('Ejercicio', {
      'IdPartesC': 1, // Tren Superior
      'IdAreaM': 2,   // Hombros
      'Nombre': 'Press militar en máquina',
      'Descripcion': 'Desarrolla fuerza y masa en los deltoides con estabilidad controlada.',
      'Peso': 0.0
    });    

    //Triceps
    await db.insert('Ejercicio', {
      'IdPartesC': 1, // Tren Superior
      'IdAreaM': 5,   // Tríceps
      'Nombre': 'Copa unilateral',
      'Descripcion': 'Trabaja la cabeza larga del tríceps y mejora la simetría muscular.',
      'Peso': 0.0
    });

    await db.insert('Ejercicio', {
      'IdPartesC': 1, // Tren Superior
      'IdAreaM': 5,   // Tríceps
      'Nombre': 'Extensión en polea',
      'Descripcion': 'Aísla el tríceps con tensión constante y mejora la definición.',
      'Peso': 0.0
    });

    await db.insert('Ejercicio', {
      'IdPartesC': 1, // Tren Superior
      'IdAreaM': 5,   // Tríceps
      'Nombre': 'Extensión en polea alta',
      'Descripcion': 'Fortalece el tríceps completo con énfasis en la cabeza lateral.',
      'Peso': 0.0
    });

    await db.insert('Ejercicio', {
      'IdPartesC': 1, // Tren Superior
      'IdAreaM': 5,   // Tríceps
      'Nombre': 'Fondo en banco',
      'Descripcion': 'Ejercicio compuesto que desarrolla fuerza y masa en el tríceps.',
      'Peso': 0.0
    });

    // CUADRICEPS - IdAreaM: 7, IdPartesC: 2
    await db.insert('Ejercicio', {
      'IdPartesC': 2, // Tren Inferior
      'IdAreaM': 7,   // Cuádriceps
      'Nombre': 'Extensiones de cuádriceps',
      'Descripcion': 'Aísla el cuádriceps y mejora la definición de la parte frontal del muslo.',
      'Peso': 0.0
    });

    await db.insert('Ejercicio', {
      'IdPartesC': 2, // Tren Inferior
      'IdAreaM': 7,   // Cuádriceps
      'Nombre': 'Hack squats',
      'Descripcion': 'Desarrolla fuerza y masa en el cuádriceps con mayor estabilidad.',
      'Peso': 0.0
    });

    await db.insert('Ejercicio', {
      'IdPartesC': 2, // Tren Inferior
      'IdAreaM': 7,   // Cuádriceps
      'Nombre': 'Prensa de piernas',
      'Descripcion': 'Ejercicio completo que fortalece cuádriceps y glúteos con alto peso.',
      'Peso': 0.0
    });

    await db.insert('Ejercicio', {
      'IdPartesC': 2, // Tren Inferior
      'IdAreaM': 7,   // Cuádriceps
      'Nombre': 'Sentadilla libre',
      'Descripcion': 'Ejercicio fundamental que desarrolla fuerza y masa en todo el tren inferior.',
      'Peso': 0.0
    });

    // FEMORAL - IdAreaM: 8, IdPartesC: 2
    await db.insert('Ejercicio', {
      'IdPartesC': 2, // Tren Inferior
      'IdAreaM': 8,   // Femoral
      'Nombre': 'Aducción de piernas',
      'Descripcion': 'Trabaja los aductores y fortalece la parte interna del muslo.',
      'Peso': 0.0
    });

    await db.insert('Ejercicio', {
      'IdPartesC': 2, // Tren Inferior
      'IdAreaM': 8,   // Femoral
      'Nombre': 'Curl femoral acostado',
      'Descripcion': 'Aísla los femorales en posición prona, mejorando la definición.',
      'Peso': 0.0
    });

    await db.insert('Ejercicio', {
      'IdPartesC': 2, // Tren Inferior
      'IdAreaM': 8,   // Femoral
      'Nombre': 'Curl femoral parado',
      'Descripcion': 'Fortalece los femorales de forma unilateral mejorando el equilibrio.',
      'Peso': 0.0
    });

    await db.insert('Ejercicio', {
      'IdPartesC': 2, // Tren Inferior
      'IdAreaM': 8,   // Femoral
      'Nombre': 'Curl femoral sentado',
      'Descripcion': 'Trabaja los femorales con énfasis en la contracción máxima.',
      'Peso': 0.0
    });

    await db.insert('Ejercicio', {
      'IdPartesC': 2, // Tren Inferior
      'IdAreaM': 8,   // Femoral
      'Nombre': 'Peso muerto',
      'Descripcion': 'Ejercicio compuesto que desarrolla femorales, glúteos y espalda baja.',
      'Peso': 0.0
    });

    // GLÚTEOS - IdAreaM: 9, IdPartesC: 2
    await db.insert('Ejercicio', {
      'IdPartesC': 2, // Tren Inferior
      'IdAreaM': 9,   // Glúteos
      'Nombre': 'Buenos días',
      'Descripcion': 'Fortalece glúteos y femorales con énfasis en la cadena posterior.',
      'Peso': 0.0
    });

    await db.insert('Ejercicio', {
      'IdPartesC': 2, // Tren Inferior
      'IdAreaM': 9,   // Glúteos
      'Nombre': 'Hip thrust',
      'Descripcion': 'Ejercicio clave para desarrollar fuerza y volumen en los glúteos.',
      'Peso': 0.0
    });

    await db.insert('Ejercicio', {
      'IdPartesC': 2, // Tren Inferior
      'IdAreaM': 9,   // Glúteos
      'Nombre': 'Hiperextensión',
      'Descripcion': 'Trabaja glúteos, femorales y espalda baja mejorando la postura.',
      'Peso': 0.0
    });

    await db.insert('Ejercicio', {
      'IdPartesC': 2, // Tren Inferior
      'IdAreaM': 9,   // Glúteos
      'Nombre': 'Patada lateral',
      'Descripcion': 'Aísla el glúteo medio y mejora la estabilidad de la cadera.',
      'Peso': 0.0
    });

    await db.insert('Ejercicio', {
      'IdPartesC': 2, // Tren Inferior
      'IdAreaM': 9,   // Glúteos
      'Nombre': 'Patada de glúteo',
      'Descripcion': 'Activa y tonifica los glúteos con movimiento de extensión de cadera.',
      'Peso': 0.0
    });

    // PANTORRILLAS - IdAreaM: 10, IdPartesC: 2
    await db.insert('Ejercicio', {
      'IdPartesC': 2, // Tren Inferior
      'IdAreaM': 10,  // Pantorrillas
      'Nombre': 'Curl de pantorrilla sentado',
      'Descripcion': 'Trabaja el sóleo con las rodillas flexionadas mejorando la definición.',
      'Peso': 0.0
    });

    await db.insert('Ejercicio', {
      'IdPartesC': 2, // Tren Inferior
      'IdAreaM': 10,  // Pantorrillas
      'Nombre': 'Elevación de talones con barra',
      'Descripcion': 'Desarrolla fuerza y masa en las pantorrillas con peso libre.',
      'Peso': 0.0
    });

    await db.insert('Ejercicio', {
      'IdPartesC': 2, // Tren Inferior
      'IdAreaM': 10,  // Pantorrillas
      'Nombre': 'Elevación de talones convencional',
      'Descripcion': 'Ejercicio básico que fortalece los gemelos de forma efectiva.',
      'Peso': 0.0
    });

    await db.insert('Ejercicio', {
      'IdPartesC': 2, // Tren Inferior
      'IdAreaM': 10,  // Pantorrillas
      'Nombre': 'Elevación de talones en máquina',
      'Descripcion': 'Aísla las pantorrillas con resistencia controlada y estable.',
      'Peso': 0.0
    });


  }

  // 🔐 HASH CONTRASEÑA
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // 🔥 REGISTRO
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('Usuario', {
      'Nombres': user.fullName,
      'Correo': user.email,
      'Contraseña': user.passwordHash, // ← SIN _hashPassword()
      'Fecha_nac': user.birthDate.toIso8601String().split('T').first,
      'Genero': user.gender,
    });
  }

  // LOGIN
  Future<User?> validateLogin(String email, String password) async {
    final db = await database;
    String passwordHash = _hashPassword(password);
    final List<Map<String, dynamic>> maps = await db.query(
      'Usuario',
      where: 'Correo = ? AND Contraseña = ?',
      whereArgs: [email, passwordHash],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  /// BUSCAR POR CORREO
  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Usuario',
      where: 'Correo = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // 🔥 CORREGIDO: getUserByFullName apunta a tabla 'Usuario' y campo 'Nombres'
  Future<User?> getUserByFullName(String fullName) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Usuario',
      where: 'Nombres = ?',
      whereArgs: [fullName],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Nuevos métodos para manejar las tablas de ejercicios

  // Insertar una nueva parte del cuerpo
  Future<int> insertPartesCuerpo(Map<String, dynamic> parte) async {
    final db = await database;
    return await db.insert('PartesCuerpo', parte);
  }

  // Insertar una nueva zona muscular
  Future<int> insertZonaMuscular(Map<String, dynamic> zona) async {
    final db = await database;
    return await db.insert('ZonaMuscular', zona);
  }

  // Insertar un nuevo ejercicio
  Future<int> insertEjercicio(Map<String, dynamic> ejercicio) async {
    final db = await database;
    return await db.insert('Ejercicio', ejercicio);
  }

  // Obtener todas las partes del cuerpo
  Future<List<Map<String, dynamic>>> getPartesCuerpo() async {
    final db = await database;
    return await db.query('PartesCuerpo');
  }

  // Obtener todas las zonas musculares
  Future<List<Map<String, dynamic>>> getZonasMusculares() async {
    final db = await database;
    return await db.query('ZonaMuscular');
  }

  // Obtener ejercicios por IdAreaM
  Future<List<Map<String, dynamic>>> getEjerciciosByZona(int idAreaM) async {
    final db = await database;
    return await db.query(
      'Ejercicio',
      where: 'IdAreaM = ?',
      whereArgs: [idAreaM],
    );
  }

  // Obtener zona muscular por IdAreaM
  Future<Map<String, dynamic>?> getZonaMuscularById(int idAreaM) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ZonaMuscular',
      where: 'IdAreaM = ?',
      whereArgs: [idAreaM],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }
  Future<int> updateEjercicio(Map<String, dynamic> ejercicio) async {
    final db = await database;
    return await db.update(
      'Ejercicio',
      ejercicio,
      where: 'IdEjercicio = ?',
      whereArgs: [ejercicio['IdEjercicio']],
    );
  }
  // === ACTUALIZAR CONTRASEÑA ===
  Future<void> updateUserPassword(String email, String newHash) async {
    final db = await database;
    await db.update(
      'Usuario',
      {'Contraseña': newHash},
      where: 'Correo = ?',
      whereArgs: [email],
    );
  }
  // ACTUALIZAR NOMBRE
  Future<void> updateUserName(int userId, String newName) async {
    final db = await database;
    await db.update(
      'Usuario',
      {'Nombres': newName},
      where: 'IdUsuario = ?',
      whereArgs: [userId],
    );
  }

  // ACTUALIZAR FOTO
  Future<void> updateUserPhoto(int userId, String photoPath) async {
    final db = await database;
    await db.update(
      'Usuario',
      {'FotoPerfil': photoPath},
      where: 'IdUsuario = ?',
      whereArgs: [userId],
    );
  }
  // === OBTENER USUARIO POR ID ===
  Future<User?> getUserById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Usuario',
      where: 'IdUsuario = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }
  // ============================================
  // 🔥 MÉTODOS PARA RecordPersonal
  // ============================================

  /// Insertar un nuevo récord personal
  Future<int> insertRecordPersonal(RecordPersonal record) async {
    final db = await database;
    return await db.insert('RecordPersonal', record.toMap());
  }

  /// Obtener todos los récords de un usuario
  Future<List<RecordPersonal>> getRecordsByUsuario(int idUsuario) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'RecordPersonal',
      where: 'IdUsuario = ?',
      whereArgs: [idUsuario],
      orderBy: 'Fecha DESC',
    );
    return maps.map((map) => RecordPersonal.fromMap(map)).toList();
  }

  /// Obtener récords de un usuario para un ejercicio específico
  Future<List<RecordPersonal>> getRecordsByEjercicio(
    int idUsuario, 
    int idEjercicio
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'RecordPersonal',
      where: 'IdUsuario = ? AND IdEjercicio = ?',
      whereArgs: [idUsuario, idEjercicio],
      orderBy: 'Fecha DESC',
    );
    return maps.map((map) => RecordPersonal.fromMap(map)).toList();
  }

  /// Obtener el récord máximo actual de un ejercicio
  Future<RecordPersonal?> getRecordMaximo(int idUsuario, int idEjercicio) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'RecordPersonal',
      where: 'IdUsuario = ? AND IdEjercicio = ? AND EsRecordMaximo = 1',
      whereArgs: [idUsuario, idEjercicio],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return RecordPersonal.fromMap(maps.first);
    }
    return null;
  }

  /// Actualizar un récord personal
  Future<int> updateRecordPersonal(RecordPersonal record) async {
    final db = await database;
    return await db.update(
      'RecordPersonal',
      record.toMap(),
      where: 'idRecord = ?',
      whereArgs: [record.idRecord],
    );
  }

  /// Marcar récord anterior como superado
  Future<void> marcarRecordComoSuperado(int idRecord) async {
    final db = await database;
    await db.update(
      'RecordPersonal',
      {'estado': 'superado', 'EsRecordMaximo': 0},
      where: 'idRecord = ?',
      whereArgs: [idRecord],
    );
  }

  /// 🔥 LÓGICA COMPLETA: Registrar nuevo peso y detectar récord
  /// Actualiza si ya existe registro del mismo día, crea nuevo si es otro día
  /// 🔥 LÓGICA MEJORADA: Guarda el peso máximo del día automáticamente
  /// 🔥 LÓGICA COMPLETA: Registrar peso y detectar récord con información detallada
  /// 🔥 LÓGICA FINAL: Guarda siempre en nuevo día, celebra solo si supera récord histórico
  Future<Map<String, dynamic>> registrarPesoYDetectarRecord({
    required int idUsuario,
    required int idEjercicio,
    required double pesoNuevo,
  }) async {
    try {
      final db = await database;
      
      // 📅 Obtener fecha actual (solo día, sin hora)
      final hoy = DateTime.now();
      final fechaHoy = DateTime(hoy.year, hoy.month, hoy.day);
      final fechaHoyStr = fechaHoy.toIso8601String().split('T')[0];
      
      // 1️⃣ Verificar si ya existe un registro HOY
      final registroHoy = await db.query(
        'RecordPersonal',
        where: 'IdUsuario = ? AND IdEjercicio = ? AND DATE(Fecha) = ?',
        whereArgs: [idUsuario, idEjercicio, fechaHoyStr],
        limit: 1,
      );
      
      if (registroHoy.isNotEmpty) {
        // ✏️ YA EXISTE UN REGISTRO HOY
        final idRecordHoy = registroHoy.first['idRecord'] as int;
        final pesoActualHoy = registroHoy.first['Peso'] as double;
        
        // 🚨 SI EL NUEVO PESO ES MENOR O IGUAL AL DE HOY → NO ACTUALIZAR
        if (pesoNuevo <= pesoActualHoy) {
          return {
            'guardado': false,
            'esRecord': (registroHoy.first['EsRecordMaximo'] as int) == 1,
            'mostrarCelebracion': false,
            'razon': 'Ya tienes $pesoActualHoy kg registrado hoy',
            'pesoActual': pesoActualHoy,
          };
        }
        
        // ✅ EL NUEVO PESO ES MAYOR AL DE HOY → ACTUALIZAR
        
        // 🏆 Buscar récord ANTERIOR (excluyendo hoy)
        final recordAnterior = await db.rawQuery('''
          SELECT MAX(Peso) as maxPeso 
          FROM RecordPersonal 
          WHERE IdUsuario = ? 
            AND IdEjercicio = ? 
            AND DATE(Fecha) < ?
            AND estado = 'vigente'
        ''', [idUsuario, idEjercicio, fechaHoyStr]);
        
        final pesoMaximoAnterior = recordAnterior.first['maxPeso'] as double?;
        
        // Determinar si es récord
        bool esRecordMaximo = pesoMaximoAnterior == null || pesoNuevo > pesoMaximoAnterior;
        
        // Si es récord y hay uno anterior, marcarlo como superado
        if (esRecordMaximo && pesoMaximoAnterior != null && pesoNuevo > pesoMaximoAnterior) {
          await db.update(
            'RecordPersonal',
            {'estado': 'superado', 'EsRecordMaximo': 0},
            where: 'IdUsuario = ? AND IdEjercicio = ? AND EsRecordMaximo = 1 AND idRecord != ?',
            whereArgs: [idUsuario, idEjercicio, idRecordHoy],
          );
        }
        
        // Actualizar el registro de hoy
        await db.update(
          'RecordPersonal',
          {
            'Peso': pesoNuevo,
            'EsRecordMaximo': esRecordMaximo ? 1 : 0,
            'estado': 'vigente',
          },
          where: 'idRecord = ?',
          whereArgs: [idRecordHoy],
        );
        
        return {
          'guardado': true,
          'esRecord': esRecordMaximo,
          'mostrarCelebracion': esRecordMaximo, // 🎉 Celebrar si supera récord histórico
          'razon': esRecordMaximo 
              ? '¡Nuevo récord personal!' 
              : 'Peso actualizado (no supera el récord anterior)',
          'pesoActual': pesoNuevo,
        };
        
      } else {
        // ➕ NO EXISTE REGISTRO HOY → CREAR NUEVO (SIEMPRE SE GUARDA)
        
        // 🏆 Obtener el récord máximo histórico
        final recordAnterior = await db.rawQuery('''
          SELECT MAX(Peso) as maxPeso 
          FROM RecordPersonal 
          WHERE IdUsuario = ? 
            AND IdEjercicio = ?
            AND estado = 'vigente'
        ''', [idUsuario, idEjercicio]);
        
        final pesoMaximoAnterior = recordAnterior.first['maxPeso'] as double?;
        
        // Determinar si es récord
        bool esNuevoRecord = pesoMaximoAnterior == null || pesoNuevo > pesoMaximoAnterior;
        
        // Si es nuevo récord, marcar los anteriores como superados
        if (esNuevoRecord && pesoMaximoAnterior != null) {
          await db.update(
            'RecordPersonal',
            {'estado': 'superado', 'EsRecordMaximo': 0},
            where: 'IdUsuario = ? AND IdEjercicio = ? AND EsRecordMaximo = 1',
            whereArgs: [idUsuario, idEjercicio],
          );
        }
        
        // Insertar nuevo registro
        await insertRecordPersonal(RecordPersonal(
          idUsuario: idUsuario,
          idEjercicio: idEjercicio,
          peso: pesoNuevo,
          fecha: fechaHoyStr,
          esRecordMaximo: esNuevoRecord ? 1 : 0,
          estado: 'vigente',
        ));
        
        return {
          'guardado': true,
          'esRecord': esNuevoRecord,
          'mostrarCelebracion': esNuevoRecord, // 🎉 Celebrar solo si es récord
          'razon': esNuevoRecord 
              ? '¡Nuevo récord personal!' 
              : 'Peso registrado (nuevo día)',
          'pesoActual': pesoNuevo,
        };
      }
      
    } catch (e) {
      print('❌ Error en registrarPesoYDetectarRecord: $e');
      return {
        'guardado': false,
        'esRecord': false,
        'mostrarCelebracion': false,
        'razon': 'Error al guardar',
      };
    }
  }

  /// Eliminar un récord personal
  Future<int> deleteRecordPersonal(int idRecord) async {
    final db = await database;
    return await db.delete(
      'RecordPersonal',
      where: 'idRecord = ?',
      whereArgs: [idRecord],
    );
  }
}
