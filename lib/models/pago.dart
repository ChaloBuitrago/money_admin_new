class Pago {
  final int? id;
  final int prestamoId; //FK a prestamos
  final double monto;
  final String fecha;
  final double cuotaEsperada; //Opcional para para registrar cuota calculada

  Pago({
    this.id,
    required this.prestamoId,
    required this.monto,
    required this.fecha,
    required this.cuotaEsperada,
  });

  factory Pago.fromMap(Map<String, dynamic> json) => Pago(
      id: json['id'],
      prestamoId: json['loan_id'],
      monto: json['monto'],
      fecha: json['fecha'],
      cuotaEsperada: json['cuotaEsperada']
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