import 'package:flutter/material.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gestión de Usuarios")),
      body: Column(
        children: [
          Expanded(child: ListView(
            children: const [
              ListTile(
                title: Text("Usuario 1"),
                subtitle: Text("Telefono: 3237595438"),
              ),
              ListTile(
                title: Text("Usuario 2"),
                subtitle: Text("Telefono: 3237594558"),
              ),
            ],
          ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: () {
                    // Lógica para agregar usuario
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Crear Usuario")),
                  );
                  },
                  child: const Text("Crear"),
              ),
              ElevatedButton(
                  onPressed: () {
                    // Lógica para editar usuario
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Editar Usuario")),
                  );
                  },
                  child: const Text("Editar"),
              ),
              ElevatedButton(
                  onPressed: () {
                    // Lógica para eliminar usuario
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Eliminar Usuario")),
                  );
                  },
                  child: const Text("Eliminar"),
              ),
            ],
          )
        ]
      ),
    );
  }
}