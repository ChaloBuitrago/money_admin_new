import 'package:flutter/material.dart';
import 'package:money_admin_new/models/prestamo.dart';
import 'package:money_admin_new/models/pago.dart';
import 'package:money_admin_new/models/user.dart';
import '../services/database_helper.dart';
import '../services/user_service.dart';

class PrestamoManagementScreen extends StatefulWidget {
  const PrestamoManagementScreen({super.key});

  @override
  State<PrestamoManagementScreen> createState() => _PrestamoManagementScreenState();
}

class _PrestamoManagementScreenState extends State<PrestamoManagementScreen> {
  late Future<List<Prestamo>> _prestamos;
  late Future<List<Prestamo>> _prestamosPendientes;

  @override
  void initState() {
    super.initState();
    _refreshAll();
  }

  // Unificamos el refresco para evitar redundancia
  void _refreshAll() {
    setState(() {
      _prestamos = DatabaseHelper.instance.getPrestamos();
      _prestamosPendientes = DatabaseHelper.instance.getPrestamosPendientes();
    });
  }

  // --- LÓGICA DE CÁLCULO ---
  double calcularCuota(Prestamo prestamo) {
    double montoReal = prestamo.monto + (prestamo.monto * prestamo.interes / 100);
    int numeroCuotas;
    if (prestamo.periodicidad == "Mensual") {
      numeroCuotas = prestamo.plazo;
    } else if (prestamo.periodicidad == "Quincenal") {
      numeroCuotas = prestamo.plazo * 2;
    } else {
      numeroCuotas = prestamo.plazo * 4;
    }
    return numeroCuotas > 0 ? montoReal / numeroCuotas : 0;
  }

  // --- ACCIONES ---
  void _crearPrestamo() async {
    final montoController = TextEditingController();
    final interesController = TextEditingController();
    final plazoController = TextEditingController();
    User? selectedUser;
    String? selectedPeriodicidad;
    DateTime? selectedDate = DateTime.now();

    final usuarios = await UserService.instance.getUsuarios();

    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Crear Préstamo"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: montoController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Monto")),
                TextField(controller: interesController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Interés (%)")),
                TextField(controller: plazoController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Plazo (meses)")),
                DropdownButton<User>(
                  value: selectedUser,
                  hint: const Text("Seleccionar Usuario"),
                  isExpanded: true,
                  items: usuarios.map((u) => DropdownMenuItem(value: u, child: Text(u.nombre))).toList(),
                  onChanged: (val) => setDialogState(() => selectedUser = val),
                ),
                DropdownButton<String>(
                  value: selectedPeriodicidad,
                  hint: const Text("Periodicidad"),
                  isExpanded: true,
                  items: ["Semanal", "Quincenal", "Mensual"].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                  onChanged: (val) => setDialogState(() => selectedPeriodicidad = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
            ElevatedButton(
              onPressed: () async {
                if (selectedUser != null && selectedPeriodicidad != null && montoController.text.isNotEmpty) {
                  final monto = double.parse(montoController.text);
                  final interes = double.parse(interesController.text);
                  final prestamo = Prestamo(
                    userId: selectedUser!.id!,
                    monto: monto,
                    fecha: selectedDate.toIso8601String(),
                    estado: "Pendiente",
                    periodicidad: selectedPeriodicidad!,
                    interes: interes,
                    saldoPendiente: monto + (monto * interes / 100),
                    plazo: int.parse(plazoController.text),
                  );
                  await DatabaseHelper.instance.insertPrestamo(prestamo);
                  Navigator.pop(context);
                  _refreshAll();
                }
              },
              child: const Text("Guardar"),
            ),
          ],
        ),
      ),
    );
  }

  void _editarPrestamo(Prestamo prestamo) async {
    final montoCtrl = TextEditingController(text: prestamo.monto.toString());
    final interesCtrl = TextEditingController(text: prestamo.interes.toString());
    final plazoCtrl = TextEditingController(text: prestamo.plazo.toString());
    String periodo = prestamo.periodicidad;
    final usuarios = await UserService.instance.getUsuarios();
    User? userSel = usuarios.firstWhere((u) => u.id == prestamo.userId, orElse: () => usuarios.first);

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Editar Préstamo"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: montoCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Monto")),
                TextField(controller: interesCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Interés %")),
                TextField(controller: plazoCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Plazo")),
                DropdownButtonFormField<User>(
                  value: userSel,
                  items: usuarios.map((u) => DropdownMenuItem(value: u, child: Text(u.nombre))).toList(),
                  onChanged: (val) => setDialogState(() => userSel = val),
                  decoration: const InputDecoration(labelText: "Usuario"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
            ElevatedButton(
              onPressed: () async {
                if (montoCtrl.text.isNotEmpty && plazoCtrl.text.isNotEmpty) {
                  final updateLoan = Prestamo(
                    id: prestamo.id,
                    userId: userSel!.id!,
                    monto: double.parse(montoCtrl.text),
                    fecha: prestamo.fecha,
                    estado: prestamo.estado,
                    periodicidad: periodo,
                    interes: double.parse(interesCtrl.text),
                    saldoPendiente: prestamo.saldoPendiente,
                    plazo: int.parse(plazoCtrl.text),
                  );
                  await DatabaseHelper.instance.updatePrestamo(updateLoan);
                  //Solución al Async GAP
                  if (!mounted) return;

                  Navigator.pop(context);
                  _refreshAll();
                }
              },
              child: const Text("Actualizar"),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarPago(Prestamo prestamo) async {
    double cuota = calcularCuota(prestamo);
    final pago = Pago(
      prestamoId: prestamo.id!,
      monto: cuota,
      fecha: DateTime.now().toIso8601String(),
      cuotaEsperada: cuota,
    );
    await DatabaseHelper.instance.insertPago(pago);

    double nuevoSaldo = prestamo.saldoPendiente - cuota;
    final updateLoan = Prestamo(
      id: prestamo.id,
      userId: prestamo.userId,
      monto: prestamo.monto,
      fecha: prestamo.fecha,
      estado: nuevoSaldo <= 0 ? "Pagado" : "En curso",
      periodicidad: prestamo.periodicidad,
      interes: prestamo.interes,
      saldoPendiente: nuevoSaldo < 0 ? 0 : nuevoSaldo,
      plazo: prestamo.plazo,
    );
    await DatabaseHelper.instance.updatePrestamo(updateLoan);
    _refreshAll();
  }

  void _eliminarPrestamo(int id) async {
    await DatabaseHelper.instance.deletePrestamo(id);
    _refreshAll();
  }

  // --- UI BUILDING ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gestión de Préstamos"), centerTitle: true),
      body: Column(
        children: [
          _buildHeader("Préstamos Pendientes"),
          Expanded(child: _buildList(_prestamosPendientes, true)),
          const Divider(),
          _buildHeader("Todos los Préstamos"),
          Expanded(child: _buildList(_prestamos, false)),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: _crearPrestamo, child: const Icon(Icons.add)),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildList(Future<List<Prestamo>> future, bool isPendiente) {
    return FutureBuilder<List<Prestamo>>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final prestamos = snapshot.data!;
        if (prestamos.isEmpty) return const Center(child: Text("No hay datos"));

        return ListView.builder(
          itemCount: prestamos.length,
          itemBuilder: (context, index) {
            final p = prestamos[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: FutureBuilder<User?>(
                future: UserService.instance.getUsuarioById(p.userId),
                builder: (context, userSnap) {
                  final user = userSnap.data;
                  return ListTile(
                    title: Text(user != null ? "${user.nombre} - ${user.telefono}" : "Cargando usuario..."),
                    subtitle: Text("Saldo: ${p.saldoPendiente.toStringAsFixed(2)} | Cuota: ${calcularCuota(p).toStringAsFixed(2)}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isPendiente)
                          ElevatedButton(onPressed: () => _confirmarPago(p), child: const Text("Pagar"))
                        else ...[
                          IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _editarPrestamo(p)),
                          IconButton(icon: const Icon(Icons.delete, color: Colors.purple), onPressed: () => _eliminarPrestamo(p.id!)),
                        ]
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}