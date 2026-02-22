class Prestamo {
  final int? id;
  final int userId;  //FK a usuarios
  final double monto;
  final String fecha; //Guardada como texto ISO
  final String estado; //Pendiente o Pagado
  final String periodicidad;  //Semanal, Quincenal y Mensual

  Prestamo({
    this.id,
    required this.userId,
    required this.monto,
    required this.fecha,
    required this.estado,
    required this.periodicidad,
  });

  factory Prestamo.fromMap(Map<String, dynamic> json) => Prestamo(
    id: json['id'],
    userId: json['userId'],
    monto: json['monto'],
    fecha: json['fecha'],
    estado: json['estado'],
    periodicidad: json['periodicidad'],
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'monto': monto,
      'fecha': fecha,
      'estado': estado,
      'periodicidad': periodicidad,
    };
  }
}