import 'package:flutter/material.dart';
import 'package:money_admin_new/models/prestamo.dart';
import 'package:money_admin_new/models/pago.dart';
import 'package:money_admin_new/models/user.dart';
import '../services/database_helper.dart';

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
    User? selectedUser;
    String? selectedPeriodicidad;
    DateTime? selectedDate;

    final usuarios = await DatabaseHelper.instance.getUsuarios();

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Crear Préstamo"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Campo monto
                TextField(
                  controller: montoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Monto"),
                ),

                // Dropdown de usuarios
                DropdownButton<User>(
                  value: selectedUser,
                  hint: const Text("Seleccionar Usuario"),
                  isExpanded: true,
                  items: usuarios.map((user) {
                    return DropdownMenuItem<User>(
                      value: user,
                      child: Text("${user.nombre} - ${user.telefono}"),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedUser = value;
                    });
                  },
                ),

                // Dropdown de periodicidad
                DropdownButton<String>(
                  value: selectedPeriodicidad,
                  hint: const Text("Seleccionar Periodicidad"),
                  isExpanded: true,
                  items: ["Semanal", "Quincenal", "Mensual"].map((periodo) {
                    return DropdownMenuItem<String>(
                      value: periodo,
                      child: Text(periodo),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedPeriodicidad = value;
                    });
                  },
                ),

                // DatePicker para fecha
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: Text(selectedDate == null
                      ? "Seleccionar Fecha"
                      : selectedDate!.toIso8601String()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
              try {
                if (selectedUser != null &&
                    selectedPeriodicidad != null &&
                    selectedDate != null &&
                    montoController.text.isNotEmpty) {

                  final prestamo = Prestamo(
                    userId: selectedUser!.id!,
                    monto: double.tryParse(montoController.text) ?? 0.0,
                    fecha: selectedDate!.toIso8601String(),
                    estado: "Pendiente",
                    periodicidad: selectedPeriodicidad!,
                  );
                  await DatabaseHelper.instance.insertPrestamo(prestamo);
                  _refreshPrestamos();
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Por favor, complete todos los campos")),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error al guardar el préstamo: $e")),
                );
              }
            },
              child: const Text("Guardar"),
            ),
          ],
        ),
      ),
    );
  }

  void _editarPrestamo(Prestamo loan) async {
    final montoController = TextEditingController(text: loan.monto.toString());
    DateTime? selectedDate = DateTime.tryParse(loan.fecha);
    String? selectedPeriodicidad = loan.periodicidad;
    User? selectedUser;

    // Obtener lista de usuarios
    final usuarios = await DatabaseHelper.instance.getUsuarios();
    // Buscar el usuario actual del préstamo
    selectedUser = usuarios.firstWhere((u) => u.id == loan.userId);

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Editar Préstamo"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Campo monto
                TextField(
                  controller: montoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Monto"),
                ),

                // Dropdown de usuarios
                DropdownButton<User>(
                  value: selectedUser,
                  hint: const Text("Seleccionar Usuario"),
                  isExpanded: true,
                  items: usuarios.map((user) {
                    return DropdownMenuItem<User>(
                      value: user,
                      child: Text("${user.nombre} - ${user.telefono}"),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedUser = value;
                    });
                  },
                ),

                // Dropdown de periodicidad
                DropdownButton<String>(
                  value: selectedPeriodicidad,
                  hint: const Text("Seleccionar Periodicidad"),
                  isExpanded: true,
                  items: ["Semanal", "Quincenal", "Mensual"].map((periodo) {
                    return DropdownMenuItem<String>(
                      value: periodo,
                      child: Text(periodo),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedPeriodicidad = value;
                    });
                  },
                ),

                // DatePicker para fecha
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: Text(selectedDate == null
                      ? "Seleccionar Fecha"
                      : selectedDate!.toIso8601String()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedUser != null &&
                    selectedPeriodicidad != null &&
                    selectedDate != null &&
                    montoController.text.isNotEmpty) {
                  final updatedLoan = Prestamo(
                    id: loan.id,
                    userId: selectedUser!.id!,
                    monto: double.parse(montoController.text),
                    fecha: selectedDate!.toIso8601String(),
                    estado: loan.estado,
                    periodicidad: selectedPeriodicidad!,
                  );
                  await DatabaseHelper.instance.updatePrestamo(updatedLoan);
                  Navigator.pop(context);
                  _refreshPrestamos();
                }
              },
              child: const Text("Actualizar"),
            ),
          ],
        ),
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
      fecha: DateTime.now().toIso8601String(),
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
                subtitle: Text(
                    "Fecha: ${loan.fecha} - Estado: ${loan.estado} - Periodicidad: ${loan.periodicidad}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        icon: const Icon(Icons.payment, color: Colors.green),
                        onPressed: () => _registrarPago(loan)),
                    IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _eliminarPrestamo(loan.id!)),
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