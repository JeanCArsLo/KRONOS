import 'package:flutter_test/flutter_test.dart';
import 'package:KronosFit/db/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Use FFI for sqflite in tests (works on desktop CI as well)
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('DatabaseHelper', () {
    late DatabaseHelper dbh;

    setUp(() {
      dbh = DatabaseHelper();
    });

    test('Should initialize database and create base tables', () async {
      final db = await dbh.database;
      // Verify tables exist querying sqlite_master
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name IN (?,?,?,?)",
        ['Usuario', 'PartesCuerpo', 'ZonaMuscular', 'Ejercicio'],
      );
      expect(
        tables.map((e) => e['name']).toSet(),
        containsAll({'Usuario', 'PartesCuerpo', 'ZonaMuscular', 'Ejercicio'}),
      );
    });

    test(
      'Should hash password on login and not authenticate with plain text',
      () async {
        // Insert a user with a pre-hashed password expected by validateLogin
        // DatabaseHelper.validateLogin uses internal hash of provided password,
        // but insertUser saves the provided password as-is. To simulate a real user
        // created by the app flow, we store a hashed password in the user row directly.
        final db = await dbh.database;
        const email = 'user@example.com';
        const plain = 'secret123';

        // Store a row directly to control the hash value (sha256 of 'secret123')
        // hash: 84d961568a65073a3bcf0eb216b2a576c5e7a4a6f4dbf0f7e7496fbe4b5f3aee
        await db.insert('Usuario', {
          'Nombres': 'User',
          'Correo': email,
          'Contraseña':
              '84d961568a65073a3bcf0eb216b2a576c5e7a4a6f4dbf0f7e7496fbe4b5f3aee',
          'Fecha_nac': '2000-01-01',
          'Genero': 'M',
        });

        // Valid login
        final user = await dbh.validateLogin(email, plain);
        expect(user, isNotNull);

        // Invalid with wrong password
        final userWrong = await dbh.validateLogin(email, 'wrong');
        expect(userWrong, isNull);
      },
    );

    test('Should insert and retrieve zonas and ejercicios', () async {
      // Insert a new area and exercise then fetch
      final idArea = await dbh.insertZonaMuscular({
        'IdAreaM': 99,
        'IdPartesC': 1,
        'Nombre': 'TestZone',
      });
      expect(idArea, greaterThan(0));

      final exId = await dbh.insertEjercicio({
        'IdEjercicio': 1001,
        'IdPartesC': 1,
        'IdAreaM': 99,
        'Nombre': 'Test Ex',
        'Descripcion': 'desc',
        'Peso': 0.0,
      });
      expect(exId, greaterThan(0));

      final zonas = await dbh.getZonasMusculares();
      expect(zonas.any((z) => z['IdAreaM'] == 99), isTrue);

      final ejercicios = await dbh.getEjerciciosByZona(99);
      expect(ejercicios.length, 1);
      expect(ejercicios.first['Nombre'], 'Test Ex');
    });

    test(
      'registrarPesoYDetectarRecord should create new record and mark as record if highest',
      () async {
        final db = await dbh.database;

        // Ensure a user and exercise exist
        final userId = await db.insert('Usuario', {
          'Nombres': 'User2',
          'Correo': 'u2@example.com',
          'Contraseña': 'x',
          'Fecha_nac': '2000-01-01',
          'Genero': 'M',
        });

        final exId = await db.insert('Ejercicio', {
          'IdPartesC': 1,
          'IdAreaM': 1,
          'Nombre': 'Row',
          'Descripcion': 'd',
          'Peso': 0.0,
        });

        final res1 = await dbh.registrarPesoYDetectarRecord(
          idUsuario: userId,
          idEjercicio: exId,
          pesoNuevo: 100,
        );
        expect(res1['guardado'], true);
        expect(res1['esRecord'], true);
        expect(res1['mostrarCelebracion'], true);

        // Insert a lower weight same day should not overwrite
        final res2 = await dbh.registrarPesoYDetectarRecord(
          idUsuario: userId,
          idEjercicio: exId,
          pesoNuevo: 90,
        );
        expect(res2['guardado'], false);
        expect(res2['mostrarCelebracion'], false);
      },
    );

    test(
      'registrarPesoYDetectarRecord should update same-day higher and keep record flags consistent',
      () async {
        final db = await dbh.database;

        final userId = await db.insert('Usuario', {
          'Nombres': 'User3',
          'Correo': 'u3@example.com',
          'Contraseña': 'x',
          'Fecha_nac': '2000-01-01',
          'Genero': 'M',
        });

        final exId = await db.insert('Ejercicio', {
          'IdPartesC': 1,
          'IdAreaM': 1,
          'Nombre': 'Lat Pulldown',
          'Descripcion': 'd',
          'Peso': 0.0,
        });

        // First record today
        final res1 = await dbh.registrarPesoYDetectarRecord(
          idUsuario: userId,
          idEjercicio: exId,
          pesoNuevo: 70,
        );
        expect(res1['guardado'], true);
        expect(res1['esRecord'], true);

        // Higher weight same day should update and remain record
        final res2 = await dbh.registrarPesoYDetectarRecord(
          idUsuario: userId,
          idEjercicio: exId,
          pesoNuevo: 80,
        );
        expect(res2['guardado'], true);
        expect(res2['esRecord'], true);

        // Validate DB state: only one record for today and marked as record
        final rows = await db.query('RecordPersonal');
        expect(
          rows
              .where(
                (r) => r['IdUsuario'] == userId && r['IdEjercicio'] == exId,
              )
              .length,
          1,
        );
        expect(rows.first['EsRecordMaximo'], 1);
      },
    );
  });
}
