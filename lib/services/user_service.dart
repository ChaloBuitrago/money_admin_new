import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';

class UserService {
  static final UserService instance = UserService._init();
  static Database? _database;

  UserService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        telefono TEXT
      )
    ''');
  }

  Future<int> insertUsuario(User user) async {
    final db = await instance.database;
    return await db.insert('usuarios', user.toMap());
  }

  Future<int> updateUsuario(User user) async {
    final db = await instance.database;
    return await db.update(
      'usuarios',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUsuario(int id) async {
    final db = await instance.database;
    return await db.delete(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<User>> getUsuarios() async {
    final db = await instance.database;
    final result = await db.query('usuarios');
    return result.map((json) => User.fromMap(json)).toList();
  }

  Future<User?> getUsuarioById(int id) async {
    final db = await instance.database;
    final result = await db.query(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }
}