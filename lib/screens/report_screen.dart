import 'package:flutter/material.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  void _generateReport(BuildContext context) {
    // Placeholder para lógica de generación de reportes
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Reporte generado (placeholder)")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reportes")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _generateReport(context),
          child: const Text("Generar reporte Trimestral/Semestral"),
        ),
      ),
    );
  }
}