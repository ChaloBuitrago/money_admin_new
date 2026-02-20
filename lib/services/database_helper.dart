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

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        telefono TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE prestamos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        monto REAL NOT NULL,
        fecha TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE pagos (
        id TEXT PRIMARY KEY,
        prestamoId INTEGER NOT NULL,
        monto REAL NOT NULL,
        fecha TEXT NOT NULL,
        FOREIGN KEY (prestamoId) REFERENCES prestamos (id)
      )
    ''');
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

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
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
    return await db.update('prestamos', prestamo.toMap(), where: 'id = ?', whereArgs: [prestamo.id]);
  }

  Future<int> deletePrestamo(int id) async {
    final db = await database;
    return await db.delete('prestamos', where: 'id = ?', whereArgs: [id]);
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
    return await db.update('pagos', pago.toMap(), where: 'id = ?', whereArgs: [pago.id]);
  }

  Future<int> deletePago(String id) async {
    final db = await database;
    return await db.delete('pagos', where: 'id = ?', whereArgs: [id]);
  }



}