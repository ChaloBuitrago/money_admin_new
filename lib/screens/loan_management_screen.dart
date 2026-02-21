import 'package:flutter/material.dart';
import 'package:money_admin_new/models/prestamo.dart';
import '../services/database_helper.dart';
import '../models/pago.dart';


class PrestamoManagementScreen extends StatefulWidget {
  const PrestamoManagementScreen({super.key});

  @override
  State<PrestamoManagementScreen> createState() => _PrestamoManagementScreenState();
}

class _PrestamoManagementScreenState extends State<PrestamoManagementScreen> {
  late Future<List<Prestamo>> _prestamos;

  @override
  void initState() {
    super.initState();
    _refreshPrestamos();
  }

  void _refreshPrestamos() {
    setState(() {
      _prestamos = DatabaseHelper.instance.getPrestamos();
    });
  }

  void _crearPrestamo() async {
    final montoController = TextEditingController();
    final fechaController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Crear Préstamo"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: montoController, decoration: const InputDecoration(labelText: "Monto")),
            TextField(controller: fechaController, decoration: const InputDecoration(labelText: "Fecha")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              final loan = Prestamo(monto: double.parse(montoController.text), fecha: fechaController.text, estado: "Pendiente");
              await DatabaseHelper.instance.insertPrestamo(loan);
              Navigator.pop(context);
              _refreshPrestamos();
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  void _editarPrestamo(Prestamo loan) async {
    final montoController = TextEditingController(text: loan.monto.toString());
    final fechaController = TextEditingController(text: loan.fecha);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Editar Préstamo"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: montoController, decoration: const InputDecoration(labelText: "Monto")),
            TextField(controller: fechaController, decoration: const InputDecoration(labelText: "Fecha")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              final updatedLoan = Prestamo(id: loan.id, monto: double.parse(montoController.text), fecha: fechaController.text, estado: loan.estado);
              await DatabaseHelper.instance.updatePrestamo(updatedLoan);
              Navigator.pop(context);
              _refreshPrestamos();
            },
            child: const Text("Actualizar"),
          ),
        ],
      ),
    );
  }

  void _eliminarPrestamo(int id) async {
    await DatabaseHelper.instance.deletePrestamo(id);
    _refreshPrestamos();
  }

  void _registrarPago(Prestamo prestamo) async {
    final pago = Pago(
      prestamoId: prestamo.id!,
      monto: prestamo.monto, // Para demo, se registra el pago completo
      fecha: DateTime.now().toString(),
    );
    await DatabaseHelper.instance.insertPago(pago);
    _refreshPrestamos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gestión de Préstamos")),
      body: FutureBuilder<List<Prestamo>>(
        future: _prestamos,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final prestamos = snapshot.data!;
          return ListView.builder(
            itemCount: prestamos.length,
            itemBuilder: (context, index) {
              final loan = prestamos[index];
              return ListTile(
                title: Text("Monto: \$${loan.monto}"),
                subtitle: Text("Fecha: ${loan.fecha} - Estado: ${loan.estado}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.payment, color: Colors.green), onPressed: () => _registrarPago(loan)),
                    IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _eliminarPrestamo(loan.id!)),
                  ],
                ),
                onTap: () => _editarPrestamo(loan),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _crearPrestamo,
        child: const Icon(Icons.add),
      ),
    );
  }
}