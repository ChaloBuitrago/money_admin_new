import 'package:flutter/material.dart';
import '../services/database_helper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Variables para guardar los números de la BD
  int _prestamosActivos = 0;
  int _pagosPendientes = 0;
  int _usuariosRegistrados = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos(); // Cargamos los datos apenas se abre la pantalla
  }

  // Función principal para obtener los datos
  // En dashboard_screen.dart (dentro de _DashboardScreenState)

  Future<void> _cargarDatos() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      // 1. Obtenemos los valores directamente de la BD
      final int cantUsuarios = await DatabaseHelper.instance.getUsersCount();
      final int cantPrestamos = await DatabaseHelper.instance.getActiveLoansCount();
      final int cantPendientes = await DatabaseHelper.instance.getPendingPaymentsCount();

      // LOG DE SEGURIDAD (Para verificar que aquí no sea 0)
      debugPrint("VALOR REAL RECUPERADO: $cantUsuarios");

      if (mounted) {
        setState(() {
          // 2. ASIGNACIÓN CRÍTICA:
          // Asegúrate de que los nombres a la izquierda sean tus variables de clase
          _usuariosRegistrados = cantUsuarios;
          _prestamosActivos = cantPrestamos;
          _pagosPendientes = cantPendientes;

          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error cargando dashboard: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MoneyAdmin Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarDatos, // Botón para refrescar manualmente
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Spinner mientras carga
          : RefreshIndicator(
        onRefresh: _cargarDatos, // Deslizar hacia abajo para actualizar
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildMetricCard("Prestamos Activos", _prestamosActivos.toString(), Colors.blue),
              _buildMetricCard("Pagos Pendientes", _pagosPendientes.toString(), Colors.orange),
              _buildMetricCard("Usuarios Registrados", "$_usuariosRegistrados", Colors.green),

              const SizedBox(height: 30),
              const Text("Acciones Rápidas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),

              _buildNavButton(context, "Gestionar Usuarios", Icons.people, '/users'),
              _buildNavButton(context, "Gestionar Prestamos", Icons.monetization_on, '/loans'),
              _buildNavButton(context, "Ver Reportes", Icons.bar_chart, '/reports'),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES PARA LIMPIEZA DEL CÓDIGO ---

  Widget _buildMetricCard(String title, String value, Color color) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.2), child: Icon(Icons.analytics, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, String text, IconData icon, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.centerLeft,
        ),
        onPressed: () => Navigator.pushNamed(context, route).then((_) => _cargarDatos()),
        // El .then((_) => _cargarDatos()) hace que al volver de la otra pantalla, el dashboard se actualice solo
        icon: Icon(icon),
        label: Text(text),
      ),
    );
  }
}