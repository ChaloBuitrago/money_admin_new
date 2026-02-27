class Prestamo {
  final int? id;
  final int userId;  //FK a usuarios
  final double monto;
  final String fecha; //Guardada como texto ISO
  final String estado; //Pendiente o Pagado
  final String periodicidad;  //Semanal, Quincenal y Mensual
  final double interes; //Interés aplicado al préstamo
  final double saldoPendiente; //Saldo pendiente del préstamo

  Prestamo({
    this.id,
    required this.userId,
    required this.monto,
    required this.fecha,
    required this.estado,
    required this.periodicidad,
    required this.interes,
    required this.saldoPendiente,
  });

  factory Prestamo.fromMap(Map<String, dynamic> json) => Prestamo(
    id: json['id'],
    userId: json['userId'],
    monto: (json['monto'] is String) ? double.parse(json['monto']) : (json['monto'] as num).toDouble(),
    fecha: json['fecha'],
    estado: json['estado'],
    periodicidad: json['periodicidad'],
    interes: (json['interes'] is String) ? double.parse(json['interes']) : (json['interes'] as num).toDouble(),
    saldoPendiente: (json['saldoPendiente'] is String) ? double.parse(json['saldoPendiente']) : (json['saldoPendiente'] as num).toDouble(),
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'monto': monto,
      'fecha': fecha,
      'estado': estado,
      'periodicidad': periodicidad,
      'interes': interes,
      'saldoPendiente': saldoPendiente,
    };
  }
}