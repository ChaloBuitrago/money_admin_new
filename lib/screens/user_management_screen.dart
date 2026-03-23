import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../services/database_helper.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  late Future<List<User>> _usuarios;

  @override
  void initState() {
    super.initState();
    _refreshUsuarios();
  }

  void _refreshUsuarios() {
    setState(() {
      _usuarios = UserService.instance.getUsuarios();
    });
  }

  void _crearUsuario() async {
    final nombreController = TextEditingController();
    final telefonoController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Crear Usuario"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nombreController, decoration: const InputDecoration(labelText: "Nombre")),
            TextField(controller: telefonoController, decoration: const InputDecoration(labelText: "Teléfono")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              if (nombreController.text.isNotEmpty && telefonoController.text.isNotEmpty) {
                final user = User(
                  nombre: nombreController.text,
                  telefono: telefonoController.text,
                );
                await UserService.instance.insertUsuario(user);
                Navigator.pop(context);
                _refreshUsuarios();
              }
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  void _editarUsuario(User user) async {
    final nombreController = TextEditingController(text: user.nombre);
    final telefonoController = TextEditingController(text: user.telefono);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Editar Usuario"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nombreController, decoration: const InputDecoration(labelText: "Nombre")),
            TextField(controller: telefonoController, decoration: const InputDecoration(labelText: "Teléfono")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              final updatedUser = User(
                id: user.id,
                nombre: nombreController.text,
                telefono: telefonoController.text,
              );
              await UserService.instance.updateUsuario(updatedUser);
              Navigator.pop(context);
              _refreshUsuarios();
            },
            child: const Text("Actualizar"),
          ),
        ],
      ),
    );
  }

  void _eliminarUsuarioSeguro(User usuario) async {
    bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.person_remove, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Text("Eliminar Usuario"),
          ],
        ),
        content: Text(
          "¿Estás seguro de que deseas eliminar a *${usuario.nombre}*?\n\n"
              "⚠️ ¡ADVERTENCIA!: Al eliminar al usuario, también se podrían perder sus registros de préstamos asociados. Esta acción no se puede deshacer.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("CANCELAR", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("BORRAR TODO"),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      // Llamada a tu DatabaseHelper para borrar el usuario por ID
      await DatabaseHelper.instance.deleteUser(usuario.id!);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("👤 Usuario ${usuario.nombre} eliminado"),
          backgroundColor: Colors.green,
        ),
      );

      _refreshUsuarios(); // La función que uses para recargar la lista de usuarios
    } catch (e) {
      if (!mounted) return;
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Acción Bloqueada"),
            content: Text("No puedes eliminar a ${usuario.nombre} porque tiene préstamos registrados. Debes eliminar o liquidar primero sus préstamos para poderlo borrar."),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("ENTENDIDO"))
            ],
          ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gestión de Usuarios")),
      body: FutureBuilder<List<User>>(
        future: _usuarios,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final usuarios = snapshot.data!;
          if (usuarios.isEmpty) {
            return const Center(child: Text("No hay usuarios registrados"));
          }
          return ListView.builder(
            itemCount: usuarios.length,
            itemBuilder: (context, index) {
              final user = usuarios[index];
              return Card(
                child: ListTile(
                  title: Text(user.nombre),
                  subtitle: Text("Tel: ${user.telefono}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.pink), onPressed: () => _editarUsuario(user)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.purple), onPressed: () => _eliminarUsuarioSeguro(user)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _crearUsuario,
        child: const Icon(Icons.add),
      ),
    );
  }
}
