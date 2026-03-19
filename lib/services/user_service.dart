import '../models/user.dart';
import 'database_helper.dart'; // Importamos el único Helper

class UserService {
  // Mantenemos el Singleton
  static final UserService instance = UserService._init();
  UserService._init();

  // ELIMINAMOS: Toda la lógica de _initDB, _createDB y el objeto Database.
  // Ahora usamos directamente la instancia de DatabaseHelper.

  Future<int> insertUsuario(User user) async {
    return await DatabaseHelper.instance.insertUser(user);
  }

  Future<int> updateUsuario(User user) async {
    return await DatabaseHelper.instance.updateUser(user);
  }

  Future<int> deleteUsuario(int id) async {
    return await DatabaseHelper.instance.deleteUser(id);
  }

  Future<List<User>> getUsuarios() async {
    return await DatabaseHelper.instance.getUsuarios();
  }

  Future<User?> getUsuarioById(int id) async {
    return await DatabaseHelper.instance.getUsuarioById(id);
  }
}