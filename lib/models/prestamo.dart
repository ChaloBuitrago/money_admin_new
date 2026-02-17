import 'pago.dart';

class Prestamo {
  final int id;
  final int userId;
  final double monto;
  final DateTime fecha;
  final List<Pago> pagos; //Lista de pagos asociados

  Prestamo({
    required this.id,
    required this.userId,
    required this.monto,
    required this.fecha,
    this.pagos = const [],
  });

  Map <String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'monto': monto,
      'fecha': fecha.toIso8601String(),
    };
  }

  factory Prestamo.fromMap(Map<String, dynamic> map) {
    return Prestamo(
      id: map['id'],
      userId: map['userId'],
      monto: map['monto'],
      fecha: DateTime.parse(map['fecha']),
    );
  }

  ///Método auxiliar: calcula el saldo pendiente
  double saldoPendiente() {
    double totalPagado = pagos.fold(0, (sum, pago) => sum + pago.monto);
    return monto - totalPagado;
  }

  ///Método auxiliar para generar resumen del préstamo
  String generarResumen () {
    return "Préstamo #$id de \$${monto.toStringAsFixed(2)}"
        "al usuario $userId, fecha: ${fecha.toIso8601String()},"
        "saldo pendiente: \$${saldoPendiente().toStringAsFixed(2)}";
  }
}