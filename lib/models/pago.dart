class Pago{
  final String id;
  final String prestamoId;
  final double monto;
  final DateTime fecha;

  Pago({required this.id, required this.prestamoId, required this.monto, required this.fecha});

  Map <String, dynamic> toMap() {
    return {
      'id': id,
      'prestamoId': prestamoId,
      'monto': monto,
      'fecha': fecha.toIso8601String(),
    };
  }

  factory Pago.fromMap(Map<String, dynamic> map) {
    return Pago(
      id: map['id'],
      prestamoId: map['prestamoId'],
      monto: map['monto'],
      fecha: DateTime.parse(map['fecha']),
    );
  }

  ///Método auxiliar para generar resumen del pago
  String generarResumen() {
    return "Pago #$id de \$${monto.toStringAsFixed(2)}"
        "para el préstamo $prestamoId, fecha: ${fecha.toIso8601String()}";
  }
}