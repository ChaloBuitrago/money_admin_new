class Pago {
  final int? id;
  final int prestamoId; //FK a prestamos
  final double monto;
  final String fecha;

  Pago({
    this.id,
    required this.prestamoId,
    required this.monto,
    required this.fecha,
  });

  factory Pago.fromMap(Map<String, dynamic> json) => Pago(
      id: json['id'],
      prestamoId: json['loan_id'],
      monto: json['monto'],
      fecha: json['fecha'],
    );

    Map<String, dynamic> toMap() {
return {
  'id': id,
  'prestamoId': prestamoId,
  'monto': monto,
  'fecha': fecha,
};
}
}