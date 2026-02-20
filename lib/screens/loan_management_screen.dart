import 'package:flutter/material.dart';

class LoanManagementScreen extends StatelessWidget {
  const LoanManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gestiónar Usuarios")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Formulario básico para crear préstamo (placeholder)
            TextField(
              decoration: const InputDecoration(labelText: "Monto del préstamo"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Fecha"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
                onPressed:() {
                  //Placeholder para lógica de creación de préstamo
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Prestamo creado(placeholder)")),
                  );
                },
                child: const Text("Crear Prestamo")
            ),
            const SizedBox(height: 20),

            //Lista de préstamos (placeholder)
            Expanded(
                child: ListView(
                  children: const [
                    ListTile(
                      title: Text("Prestamo #1"),
                      subtitle: Text("Monto: \$1000 - Estado: Pendiente"),
                    ),
                    ListTile(
                      title: Text("Prestamo #2"),
                      subtitle: Text("Monto: \$2000, Estado: Pagado"),
                    ),
                  ],
                ),
            ),

            //Boton para registrar pago (placeholder)
            ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Pago Registrado (placeholder)")),
                  );
                },
                child: const Text("Registrar Pago")
            ),
          ],
        ),
      ),
    );
  }
}