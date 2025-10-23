import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user.dart';

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
      version: 1,
      onCreate: _onCreate,
    );
  }

  // 🔥 CREAR TABLAS
  Future _onCreate(Database db, int version) async {
    // Tabla para usuarios
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL UNIQUE,
        passwordHash TEXT NOT NULL,
        email TEXT UNIQUE,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
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

    // Inserciones iniciales de datos
    await _insertInitialData(db);
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
  }

  // 🔐 HASH CONTRASEÑA
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // 🔥 REGISTRO
  Future<int> registerUser(String fullName, String password, [String? email]) async {
    final db = await database;
    return await db.insert('users', {
      'fullName': fullName,
      'passwordHash': _hashPassword(password),
      'email': email,
    });
  }

  // 🔥 LOGIN
  Future<User?> validateLogin(String fullName, String password) async {
    final db = await database;
    String passwordHash = _hashPassword(password);
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'fullName = ? AND passwordHash = ?',
      whereArgs: [fullName, passwordHash],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // 🔥 BUSCAR POR EMAIL
  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // 🔥 BUSCAR POR FULLNAME
  Future<User?> getUserByFullName(String fullName) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'fullName = ?',
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

}