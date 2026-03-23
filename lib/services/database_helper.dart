import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/prestamo.dart';
import '../models/pago.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('money_admin.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
        onConfigure: _onConfigure,
    );
  }

  //Apartado esencial: Si se borra un usuario, se borra el pretamo para que no quede huerfano
  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _createDB(Database db, int version) async {

    //Tabla Usuarios
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        telefono TEXT NOT NULL
      )
    ''');

    //Tabla de prestamos
    await db.execute('''
      CREATE TABLE prestamos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        monto REAL NOT NULL,
        fecha TEXT NOT NULL,
        estado TEXT NOT NULL,
        periodicidad TEXT NOT NULL,
        interes REAL NOT NULL,
        saldoPendiente REAL NOT NULL,
        plazo INTEGER,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    //Tabla de pagos
    await db.execute('''
      CREATE TABLE pagos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        prestamoId INTEGER NOT NULL,
        monto REAL NOT NULL,
        fecha TEXT NOT NULL,
        cuotaEsperada REAL,
        FOREIGN KEY (prestamoId) REFERENCES prestamos (id) ON DELETE CASCADE
      )
    ''');
  }

  // ------- MÉTODOS MEJORADOS ------

  //1. Transacción de Pago: Evita que se registre el pago pero no se descuente del saldo
  Future<void> registrarPago(Pago pago, double nuevoSaldo, String nuevoEstado) async {
    final db = await database;

    await db.transaction((txn) async {
      // Insertar el pago
      await txn.insert('pagos', pago.toMap());

      // Actualizar el préstamo dentro de la misma operación
      await txn.update(
        'prestamos',
        {'saldoPendiente': nuevoSaldo, 'estado': nuevoEstado},
        where: 'id = ?',
        whereArgs: [pago.prestamoId],
      );
    });
  }

  Future<void> registrarPagoTransaccion(Pago pago, double nuevoSaldo, String nuevoEstado) async {
    final db = await instance.database;

    // Iniciamos la transacción
    await db.transaction((txn) async {
      // 1. Insertar el registro del pago
      await txn.insert('pagos', pago.toMap());

      // 2. Actualizar el saldo y estado en la tabla de préstamos
      await txn.update(
        'prestamos',
        {
          'saldoPendiente': nuevoSaldo,
          'estado': nuevoEstado,
        },
        where: 'id = ?',
        whereArgs: [pago.prestamoId],
      );
    });
  }

  //2. Obtener pagos de un préstamo especifico
  Future<List<Pago>> getPagosPorPrestamo(int prestamoId) async {
    final db = await database;
    final result = await db.query(
      'pagos',
      where: 'prestamoId = ?',
      whereArgs: [prestamoId],
      orderBy: 'fecha DESC',
    );
    return result.map((map) => Pago.fromMap(map)).toList();
  }

  //-------------- Métodos CRUD para Users -------------

  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<List<User>> getUsuarios() async {
    final db = await database;
    final result = await db.query('users');
    return result.map((map) => User.fromMap(map)).toList();
  }

  Future<User?> getUsuarioById(int id) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
        'users',
        user.toMap(),
        where: 'id = ?',
        whereArgs: [user.id]
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(
        'users',
        where: 'id = ?',
        whereArgs: [id]
    );
  }

  //-------------- Métodos CRUD para Prestamos -------------

  Future<int> insertPrestamo(Prestamo prestamo) async {
    final db = await database;
    return await db.insert('prestamos', prestamo.toMap());
  }

  Future<List<Prestamo>> getPrestamos() async {
    final db = await database;
    final result = await db.query('prestamos');
    return result.map((map) => Prestamo.fromMap(map)).toList();
  }

  Future <int> updatePrestamo(Prestamo prestamo) async {
    final db = await database;
    return await db.update(
      'prestamos',
      prestamo.toMap(),
      where: 'id = ?',
      whereArgs: [prestamo.id],
    );
  }

  Future<int> deletePrestamo(int id) async {
    final db = await database;
    return await db.delete(
        'prestamos',
        where: 'id = ?',
        whereArgs: [id]
    );
  }

  Future<List<Prestamo>> getPrestamosPendientes() async {
    final db = await database;
    //Filtrar solo los usuarios que si deben dinero
    final result = await db.query(
        'prestamos',
        where: 'saldoPendiente > 0',
    );
    return result.map((json) => Prestamo.fromMap(json)).toList();
  }

  // ------------- Métodos CRUD para Pagos -------------

  Future<int> insertPago(Pago pago) async {
    final db = await database;
    return await db.insert('pagos', pago.toMap());
  }

  Future<List<Pago>> getPagos() async {
    final db = await database;
    final result = await db.query('pagos');
    return result.map((map) => Pago.fromMap(map)).toList();
  }

  Future<int> updatePago(Pago pago) async {
    final db = await database;
    return await db.update('pagos', pago.toMap(),
        where: 'id = ?', whereArgs: [pago.id]
    );
  }

  Future<int> deletePago(String id) async {
    final db = await database;
    return await db.delete(
      'pagos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}