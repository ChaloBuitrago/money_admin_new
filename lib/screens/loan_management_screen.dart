import 'package:flutter/material.dart';
import 'package:money_admin_new/models/prestamo.dart';
import 'package:money_admin_new/models/pago.dart';
import 'package:money_admin_new/models/user.dart';
import '../services/database_helper.dart';
import '../services/user_service.dart';
import 'package:url_launcher/url_launcher.dart';

class PrestamoManagementScreen extends StatefulWidget {
  const PrestamoManagementScreen({super.key});

  @override
  State<PrestamoManagementScreen> createState() => _PrestamoManagementScreenState();
}

class _PrestamoManagementScreenState extends State<PrestamoManagementScreen> {
  List<Prestamo> _listaDePrestamosCargada = [];

  @override
  void initState() {
    super.initState();
    _refreshAll();
  }

  // Unificamos el refresco para evitar redundancia
  void _refreshAll() async {
    final data = await DatabaseHelper.instance.getPrestamos();
    setState(() {
      _listaDePrestamosCargada = data; // Aquí guardamos la lista REAL
    });
  }

  void _enviarCobroWhatsApp(String? telefono, String nombre, double saldoTotal, double cuota) async {
    // Limpieza de seguridad
    if (telefono == null || telefono.isEmpty) return;


    String numLimpio = telefono.replaceAll(RegExp(r'\D'), '');
    if (!numLimpio.startsWith('57')) numLimpio = '57$numLimpio';

    // Se identifica si es el ultimo pago
    bool esUltimoPago = saldoTotal <= (cuota + 0.05);
    double montoACobrar = esUltimoPago ? saldoTotal : cuota;

    String mensaje;

    if (esUltimoPago) {
      mensaje = "¡Excelentes noticias, *${nombre.toUpperCase()}*! 🎉\n\n"
    "Te informamos que hoy realizas tu *PAGO FINAL* para liquidar tu préstamo.\n\n"
    "✅ Monto a pagar: *\$${montoACobrar.toStringAsFixed(2)}*\n"
    "Con este pago quedarás totalmente al día. ¡Gracias por tu puntualidad! 👋";
    } else {
      mensaje = "Hola *${nombre}*, te recordamos hacer el pago de tu cuota en los próximos días. 👋\n\n"
          "💵 Valor de la cuota: *\$${montoACobrar.toStringAsFixed(2)}*\n"
          "📉 Saldo restante: \$${(saldoTotal - montoACobrar).toStringAsFixed(2)}\n\n"
          "Quedamos atentos al comprobante de pago. ¡Feliz día!";
    }

    final String urlFull = "https://wa.me/$numLimpio?text=${Uri.encodeComponent(mensaje)}";
    final Uri uri = Uri.parse(urlFull);

    debugPrint("LOG_MONEY: Enviando mensaje de ${esUltimoPago ? 'LIQUIDACIÓN' : 'CUOTA NORMAL'}");

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Error al lanzar WhatsApp: $e");
    }
  }

  DateTime calcularProximaFecha(Prestamo prestamo) {
    DateTime fechaInicio = DateTime.parse(prestamo.fecha);

    // Calculamos cuántas cuotas se han pagado ya (basado en el saldo)
    double montoTotal = prestamo.monto + (prestamo.monto * prestamo.interes / 100);
    double pagado = montoTotal - prestamo.saldoPendiente;
    double valorCuota = calcularCuota(prestamo);

    // Si no hay cuota (evitar división por cero)
    if (valorCuota <= 0) return fechaInicio;

    int cuotasCompletadas = (pagado / valorCuota).round();

    // La próxima cuota es la (cuotasCompletadas + 1)
    if (prestamo.periodicidad == "Mensual") {
      return DateTime(fechaInicio.year, fechaInicio.month + cuotasCompletadas + 1, fechaInicio.day);
    } else if (prestamo.periodicidad == "Quincenal") {
      return fechaInicio.add(Duration(days: (cuotasCompletadas + 1) * 15));
    } else { // Semanal
      return fechaInicio.add(Duration(days: (cuotasCompletadas + 1) * 7));
    }
  }

  // --- LÓGICA DE CÁLCULO ---
  double calcularCuota(Prestamo prestamo) {
    // Aqui se calcula el total a pagar (Capital + Interés)
    double montoTotal = prestamo.monto + (prestamo.monto * prestamo.interes / 100);

    int factor;
    if (prestamo.periodicidad == "Mensual") {
      factor = 1;
    } else if (prestamo.periodicidad == "Quincenal") {
      factor = 2;
    } else if (prestamo.periodicidad == "Semanal") {
      factor = 4;
    } else {
      factor = 1; // Por defecto mensual
    }

    int numeroCuotas = prestamo.plazo * factor;

    if (numeroCuotas > 0) {
      double resultado = montoTotal / numeroCuotas;
      // Se redondea a 2 decimales para evitar residuos en el saldoPendiente
      return double.parse(resultado.toStringAsFixed(2));
    }
    return 0.0;
  }

  // --- ACCIONES ---
  void _crearPrestamo() async {
    final montoController = TextEditingController();
    final interesController = TextEditingController();
    final plazoController = TextEditingController();
    User? selectedUser;
    String? selectedPeriodicidad;
    DateTime selectedDate = DateTime.now();

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

                //---Nuevo boton de Fecha ----
                Padding(
                    padding:const EdgeInsets.symmetric(vertical:10.0),
                    child: OutlinedButton.icon(
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            //Importante: setDialogState para refrescar el boton del dialogo
                            setDialogState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          "Fecha: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                        ),
                    ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
            ElevatedButton(
              onPressed: () async {
                if (selectedUser != null &&
                    selectedPeriodicidad != null &&
                    montoController.text.isNotEmpty &&
                    plazoController.text.isNotEmpty) {

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
                  if (!mounted) return;
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

    DateTime fechaSeleccionada = DateTime.parse(prestamo.fecha);
    String periodoSeleccionado = prestamo.periodicidad;

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
                  initialValue: userSel,
                  items: usuarios.map((u) => DropdownMenuItem(value: u, child: Text(u.nombre))).toList(),
                  onChanged: (val) => setDialogState(() => userSel = val),
                  decoration: const InputDecoration(labelText: "Usuario"),
                ),

                DropdownButtonFormField<String>(
                  initialValue: periodoSeleccionado,
                  decoration: const InputDecoration(labelText: "Periodicidad"),
                  items: ["Semanal", "Quincenal", "Mensual"]
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => periodoSeleccionado = val);
                    }
                  },
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: fechaSeleccionada,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          fechaSeleccionada = picked;
                        });
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text("Fecha: ${fechaSeleccionada.day}/${fechaSeleccionada.month}/${fechaSeleccionada.year}"),
                  ),
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
                    fecha: fechaSeleccionada.toIso8601String(),
                    estado: prestamo.estado,
                    periodicidad: periodoSeleccionado,
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
    double cuotaTeorica = calcularCuota(prestamo);
    double montoFinalAPagar;
    bool esPagoFinal = false;

    // 1. DETERMINAR EL MONTO (Lógica financiera)
    if (prestamo.saldoPendiente <= (cuotaTeorica + 0.05)) {
      montoFinalAPagar = prestamo.saldoPendiente;
      esPagoFinal = true;
    } else {
      montoFinalAPagar = cuotaTeorica;
    }

    // 2. DIÁLOGO DE CONFIRMACIÓN (Para cualquier pago)
    bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(esPagoFinal ? "⚠️ Liquidar Préstamo" : "💵 Confirmar Pago"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("¿Deseas registrar este pago para ${prestamo.userId}?"), // Si tienes el nombre a la mano, úsalo
            const SizedBox(height: 15),
            Text(
              "Monto a cobrar: \$${montoFinalAPagar.toStringAsFixed(2)}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
            ),
            if (esPagoFinal)
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  "Nota: Este pago cubrirá el total de la deuda.",
                  style: TextStyle(color: Colors.orange, fontStyle: FontStyle.italic),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("CANCELAR", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: esPagoFinal ? Colors.blue : Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(esPagoFinal ? "LIQUIDAR" : "CONFIRMAR PAGO"),
          ),
        ],
      ),
    );

    // Si el usuario cierra el diálogo o da en Cancelar, salimos
    if (confirmar != true) return;

    // 3. PROCESAR EL PAGO (Solo si confirmó)
    double nuevoSaldo = prestamo.saldoPendiente - montoFinalAPagar;
    if (nuevoSaldo < 0.01) nuevoSaldo = 0.0;
    String nuevoEstado = nuevoSaldo <= 0 ? "Pagado" : "En curso";

    final pago = Pago(
      prestamoId: prestamo.id!,
      monto: montoFinalAPagar,
      fecha: DateTime.now().toIso8601String(),
      cuotaEsperada: cuotaTeorica,
    );

    try {
      await DatabaseHelper.instance.registrarPagoTransaccion(pago, nuevoSaldo, nuevoEstado);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(esPagoFinal
              ? "✅ Préstamo liquidado con éxito"
              : "✅ Pago de \$${montoFinalAPagar.toStringAsFixed(2)} guardado."),
          backgroundColor: Colors.black87,
        ),
      );
      _refreshAll();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void _eliminarPrestamo(int id) async {
    await DatabaseHelper.instance.deletePrestamo(id);
    _refreshAll();
  }

  // --- UI BUILDING ---
  @override
  Widget build(BuildContext context) {
    final DateTime hoy = DateTime.now();
    final DateTime fechaLimite = DateTime(hoy.year, hoy.month, hoy.day).add(const Duration(days: 3, hours: 23, minutes: 59));

    // Filtro 1: Pendientes por cobrar (3 días antes o vencidos)
    final List<Prestamo> pendientesFiltrados = _listaDePrestamosCargada.where((p) {
      if (p.estado == "Pagado") return false;
      DateTime proxima = calcularProximaFecha(p);
      return proxima.isBefore(fechaLimite);
    }).toList();

    // Filtro 2: Todos los que no han terminado de pagar
    final List<Prestamo> todosActivos = _listaDePrestamosCargada.where((p) => p.estado != "Pagado").toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Gestión de Préstamos"), centerTitle: true),
      body: Column(
        children: [
          _buildHeader("Préstamos por Cobrar (Próximos 3 días)"),
          Expanded(child: _buildList(pendientesFiltrados, true)), // Pasamos la LISTA REAL
          const Divider(),
          _buildHeader("Todos los Préstamos Activos"),
          Expanded(child: _buildList(todosActivos, false)), // Pasamos la LISTA REAL
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: _crearPrestamo,
          child: const Icon(Icons.add)
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildList(List<Prestamo> prestamos, bool esListaDeCobro) {
    if (prestamos.isEmpty) {
      return const Center(child: Text("No hay datos disponibles"));
    }

    return ListView.builder(
      itemCount: prestamos.length,
      itemBuilder: (context, index) {
        final p = prestamos[index];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: FutureBuilder<User?>(
            // Buscamos al usuario dueño de este préstamo por su ID
            future: UserService.instance.getUsuarioById(p.userId),
            builder: (context, snapshot) {
              final user = snapshot.data;
              // Mientras carga mostramos un texto genérico o el ID
              String nombre = user?.nombre ?? "Cargando...";

              return ListTile(
                title: Text(nombre),
                subtitle: Text("Saldo: \$${p.saldoPendiente.toStringAsFixed(
                    2)} | Cuota: \$${calcularCuota(p).toStringAsFixed(2)}"),
                trailing: esListaDeCobro
                    ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.message, color: Colors.green),
                      onPressed: () {
                        // Usamos el nombre y tel que acabamos de obtener
                        if (user != null) {
                          _enviarCobroWhatsApp(
                              user.telefono, user.nombre, p.saldoPendiente,
                              calcularCuota(p));
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                          Icons.monetization_on, color: Colors.blue),
                      onPressed: () => _confirmarPago(p),
                    ),
                  ],
                )
                    : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        icon: const Icon(Icons.edit, color: Colors.pink),
                        onPressed: () => _editarPrestamo(p)),
                    IconButton(
                        icon: const Icon(Icons.delete, color: Colors.purple),
                        onPressed: () => _eliminarPrestamo(p.id!)),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}