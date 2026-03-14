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
    _refreshPrestamos();
    _refreshPendientes();
  }

  void _refreshPendientes() {
    setState(() {
      _prestamosPendientes = DatabaseHelper.instance.getPrestamosPendientes();
    });
  }

  void _refreshPrestamos() {
    setState(() {
      _prestamos = DatabaseHelper.instance.getPrestamos();
    });
  }

  void _crearPrestamo() async {
    final montoController = TextEditingController();
    final interesController = TextEditingController();
    final plazoController = TextEditingController();
    User? selectedUser;
    String? selectedPeriodicidad;
    DateTime? selectedDate;

    final usuarios = await UserService.instance.getUsuarios();

    await showDialog(
      context: context,
      builder: (_) =>
          StatefulBuilder(
            builder: (context, setState) =>
                AlertDialog(
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
                        //Porcentaje del prestamo
                        TextField(
                          controller: interesController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: "Porcentaje de interés (%)"),
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

                        TextField(
                          controller: plazoController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: "Plazo del prestamo en meses"),
                        ),

                        // Dropdown de periodicidad
                        DropdownButton<String>(
                          value: selectedPeriodicidad,
                          hint: const Text("Seleccionar Periodicidad"),
                          isExpanded: true,
                          items: ["Semanal", "Quincenal", "Mensual"].map((
                              periodo) {
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
                        if (selectedUser != null &&
                            selectedPeriodicidad != null &&
                            selectedDate != null &&
                            montoController.text.isNotEmpty &&
                            interesController.text.isNotEmpty) {
                          final monto = double.parse(montoController.text);
                          final interes = double.parse(interesController.text);
                          final plazo = int.parse(plazoController.text);
                          final montoTotal = monto + (monto * interes / 100);

                          final prestamo = Prestamo(
                            userId: selectedUser!.id!,
                            monto: monto,
                            fecha: selectedDate!.toIso8601String(),
                            estado: "Pendiente",
                            periodicidad: selectedPeriodicidad!,
                            interes: interes,
                            saldoPendiente: montoTotal,
                            //saldo inicial con interes
                            plazo: plazo,

                          );
                          await DatabaseHelper.instance.insertPrestamo(
                              prestamo);
                          Navigator.pop(context);
                          _refreshPrestamos();
                          _refreshPendientes();
                        }
                      },
                      child: const Text("Guardar"),
                    ),
                  ],
                ),
          ),
    );
  }

  //Calcular cuota segun periodicidad y plazo
  double calcularCuota(Prestamo prestamo) {
    double montoReal = prestamo.monto +
        (prestamo.monto * prestamo.interes / 100);

    int numeroCuotas;
    if (prestamo.periodicidad == "Mensual") {
      numeroCuotas = prestamo.plazo;
    } else if (prestamo.periodicidad == "Quincenal") {
      numeroCuotas = prestamo.plazo * 2;
    } else {
      numeroCuotas = prestamo.plazo * 4;
    }
    return montoReal / numeroCuotas;
  }

  void _editarPrestamo(Prestamo loan) async {
    final montoController = TextEditingController(text: loan.monto.toString());
    final interesController = TextEditingController(
        text: loan.interes.toString());
    DateTime? selectedDate = DateTime.tryParse(loan.fecha);
    String? selectedPeriodicidad = loan.periodicidad;
    User? selectedUser;

    // Obtener lista de usuarios
    final usuarios = await DatabaseHelper.instance.getUsuarios();
    // Buscar el usuario actual del préstamo
    selectedUser = usuarios.firstWhere((u) => u.id == loan.userId);

    await showDialog(
      context: context,
      builder: (_) =>
          StatefulBuilder(
            builder: (context, setState) =>
                AlertDialog(
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
                        TextField(
                          controller: interesController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: "Porcentaje de interés (%)"),
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
                          items: ["Semanal", "Quincenal", "Mensual"].map((
                              periodo) {
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
                            interes: double.parse(interesController.text),
                            saldoPendiente: loan.saldoPendiente,
                            // Para simplificar o recalcular
                            plazo: loan
                                .plazo, // Mantener el plazo original o agregar campo para editarlo
                          );
                          await DatabaseHelper.instance.updatePrestamo(
                              updatedLoan);
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
    //Tomar fecha inicial del prestamo
    DateTime fechaPrestamo = DateTime.parse(prestamo.fecha);
    //Definir el intervalo segun la periodicidad
    Duration intervalo;
    if (prestamo.periodicidad == "Semanal") {
      intervalo = const Duration(days: 7);
    } else if (prestamo.periodicidad == "Quincenal") {
      intervalo = const Duration(days: 15);
    } else {
      intervalo = const Duration(days: 30);
    }

    //Calcular la fecha del próximo pago
    DateTime proximoPago = fechaPrestamo.add(intervalo);

    //Validar si ya corresponde registrar el pago
    if (DateTime.now().isBefore(proximoPago)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(
            "Aún no corresponde registrar el pago segun la periodicidad")),
      );
      return; // No se registra el pago
    }
    //Calcular el monto real con el interes aplicado
    double montoReal = prestamo.monto +
        (prestamo.monto * prestamo.interes / 100);

    //Definir numero de cuotas segun la periodicidad
    int numeroCuotas;
    if (prestamo.periodicidad == "Semanal") {
      numeroCuotas = 4; // 4 semanas en un mes
    } else if (prestamo.periodicidad == "Quincenal") {
      numeroCuotas = 2; // 2 quincenas en un mes
    } else {
      numeroCuotas = 1; // Pago mensual completo
    }
    //Calcular el valor de cada cuota
    double cuota = montoReal / numeroCuotas;
    //Crear el objeto pago
    final pago = Pago(
      prestamoId: prestamo.id!,
      monto: cuota, // Para demo, se registra el pago completo
      fecha: DateTime.now().toIso8601String(),
      cuotaEsperada: cuota,
    );
    //insertar el pago en la base de datos
    await DatabaseHelper.instance.insertPago(pago);

    // Actualizar el saldo pendiente del préstamo
    double nuevoSaldo = prestamo.saldoPendiente - cuota;
    String nuevoEstado = nuevoSaldo <= 0 ? "Pagado" : "En curso";

    final updateLoan = Prestamo(
      id: prestamo.id,
      userId: prestamo.userId,
      monto: prestamo.monto,
      fecha: prestamo.fecha,
      estado: nuevoEstado,
      periodicidad: prestamo.periodicidad,
      interes: prestamo.interes,
      saldoPendiente: nuevoSaldo,
      plazo: prestamo.plazo,
    );
    //Guardar actualizacion en la BD
    await DatabaseHelper.instance.updatePrestamo(updateLoan);
    //Refrescar la lista en pantalla
    _refreshPrestamos();
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
    String nuevoEstado = nuevoSaldo <= 0 ? "Pagado" : "En curso";

    final updateLoan = Prestamo(
      id: prestamo.id,
      userId: prestamo.userId,
      monto: prestamo.monto,
      fecha: prestamo.fecha,
      estado: nuevoEstado,
      periodicidad: prestamo.periodicidad,
      interes: prestamo.interes,
      saldoPendiente: nuevoSaldo,
      plazo: prestamo.plazo,
    );

    await DatabaseHelper.instance.updatePrestamo(updateLoan);
    _refreshPendientes();
    _refreshPrestamos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gestión de Préstamos")),
      body: Column(
        children: [
          // Sección de préstamos pendientes
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Préstamos pendientes de pago",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Prestamo>>(
              future: _prestamosPendientes,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final prestamos = snapshot.data!;

                final pendientes = prestamos.where((prestamo) {
                  DateTime fechaPrestamo = DateTime.parse(prestamo.fecha);

                  Duration intervalo;
                  if (prestamo.periodicidad == "Semanal") {
                    intervalo = const Duration(days: 7);
                  } else if (prestamo.periodicidad == "Quincenal") {
                    intervalo = const Duration(days: 15);
                  } else {
                    intervalo = const Duration(days: 30);
                  }

                  final diferenciaDias = DateTime
                      .now()
                      .difference(fechaPrestamo)
                      .inDays;
                  final intervalosPasados = (diferenciaDias / intervalo.inDays)
                      .floor();

                  return intervalosPasados > 0 && prestamo.saldoPendiente > 0;
                }).toList();

                if (pendientes.isEmpty) {
                  return const Center(child: Text("No hay pagos pendientes"));
                }
                return ListView.builder(
                  itemCount: pendientes.length,
                  itemBuilder: (context, index) {
                    final prestamo = pendientes[index];

                    double montoReal =
                        prestamo.monto +
                            (prestamo.monto * prestamo.interes / 100);
                    int numeroCuotas;
                    if (prestamo.periodicidad == "Mensual") {
                      numeroCuotas = prestamo.plazo;
                    } else if (prestamo.periodicidad == "Quincenal") {
                      numeroCuotas = prestamo.plazo * 2;
                    } else {
                      numeroCuotas = prestamo.plazo * 4;
                    }

                    double cuota = montoReal / numeroCuotas;

                    return Card(
                      child: ListTile(
                        title: Text(
                            "Usuario: ${prestamo
                                .userId} - Monto Total: ${prestamo.monto}"),
                        subtitle: Text(
                          "Saldo pendiente: ${prestamo
                              .saldoPendiente} - Estado: ${prestamo.estado}\n"
                              "Cuota esperada: $cuota",
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => _confirmarPago(prestamo),
                          child: const Text("Confirmar Pago"),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Sección de todos los préstamos
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Todos los préstamos",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Prestamo>>(
              future: _prestamos,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final prestamos = snapshot.data!;
                if (prestamos.isEmpty) {
                  return const Center(
                      child: Text("No hay préstamos registrados"));
                }
                return ListView.builder(
                  itemCount: prestamos.length,
                  itemBuilder: (context, index) {
                    final prestamo = prestamos[index];
                    return Card(
                      child: FutureBuilder<User?>(
                        future: UserService.instance.getUsuarioById(prestamo
                            .userId),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const ListTile(
                                title: Text("Cargando usuario..."));
                          }

                          final usuario = snapshot.data!;
                          return ListTile(
                            title: Text(
                                "Usuario: ${usuario.nombre} - ${usuario
                                    .telefono}"),
                            subtitle: Text(
                              "Monto: ${prestamo.monto}\n"
                                  "Interés: ${prestamo.interes}%\n"
                                  "Plazo: ${prestamo.plazo} meses\n"
                                  "Periodicidad: ${prestamo.periodicidad}\n"
                                  "Cuota esperada: ${calcularCuota(prestamo)
                                  .toStringAsFixed(2)}",
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                      Icons.payment, color: Colors.green),
                                  onPressed: () => _registrarPago(prestamo),
                                ),
                              ],
                            ),
                            onTap: () => _editarPrestamo(prestamo),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _crearPrestamo,
        child: const Icon(Icons.add),
      ),

    );
  }
}