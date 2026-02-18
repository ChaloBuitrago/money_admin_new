import 'dart:io';

class ReportService {
  //Generar reporte Trimestral
  Future<void> generarReporteTrimestral(List<Map<String, dynamic>> pagos) async {
    //Aqui se podrá procesar la lista de pagos y generar un archivo
    final reporte = StringBuffer();
    reporte.writeln("=== Reporte Trimestral ===");
    for (var pago in pagos) {
      reporte.writeln(
          "Cliente: ${pago['cliente']} - Monto: \$${pago['monto']} - Fecha: ${pago['fecha']}");
    }

    //Guardar el reporte en un archivo local(ejemplo simple)
    final file = File('reporte_trimestral.txt');
    await file.writeAsString(reporte.toString());
    print("Reporte trimestral generado en %{file.path");
  }

  //Generar reporte Semestral
Future<void> generarReporteSemestral(List<Map<String, dynamic>> pagos) async {
    final reporte = StringBuffer();
    reporte.writeln("=== Reporte Semestral ===");
    for (var pago in pagos) {
      reporte.writeln(
          "Cliente: ${pago['cliente']} - Monto: \$${pago['monto']} - Fecha: ${pago['fecha']}");
    }

    final file = File('reporte_semestral.txt');
    await file.writeAsString(reporte.toString());
    print("Reporte semestral generado en ${file.path}");

  }
}