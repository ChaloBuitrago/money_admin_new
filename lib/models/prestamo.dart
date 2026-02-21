class Prestamo {
  final int? id;
  final double monto;
  final String fecha;
  final String estado;

  Prestamo({this.id, required this.monto, required this.fecha, required this.estado});

  factory Prestamo.fromMap(Map<String, dynamic> json) => Prestamo(
    id: json['id'],
    monto: json['monto'],
    fecha: json['fecha'],
    estado: json['estado'],
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'monto': monto,
      'fecha': fecha,
      'estado': estado,
    };
  }
}