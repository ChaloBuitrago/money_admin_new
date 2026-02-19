import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            //Métricas rápidas (placeholder por ahora
            Card (
              child: ListTile(
                title: const Text("Prestamos Activos"),
                subtitle: const Text("0"),  //Luego se conecta con BD
              ),
            ),
            Card (child: ListTile(
              title: const Text("Pagos Pendientes"),
              subtitle: const Text("0"),  //Luego se conecta con BD)
              ),
            ),
            Card (
              child: ListTile(
                title: const Text("Usuarios Resgistrados"),
                subtitle: const Text("0"),
              ),
            ),
            const SizedBox(height: 20),

            //Botones de Navegación 
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/users');
                },
                child: const Text("Gestionar Usuarios"),
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/loans");
                },
                child: const Text("Gestionar Prestamos"),
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/reports");
                },
                child: const Text("Ver Reportes"),
            ),
          ],
        ),
      ),
    );
  }
}