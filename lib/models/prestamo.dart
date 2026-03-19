class Prestamo {
  final int? id;
  final int userId;  //FK a usuarios
  final double monto;
  final String fecha; //Guardada como texto ISO
  final String estado; //Pendiente o Pagado
  final String periodicidad;  //Semanal, Quincenal y Mensual
  final double interes; //Interés aplicado al préstamo
  final double saldoPendiente; //Saldo pendiente del préstamo
  final int plazo;

  Prestamo({
    this.id,
    required this.userId,
    required this.monto,
    required this.fecha,
    required this.estado,
    required this.periodicidad,
    required this.interes,
    required this.saldoPendiente,
    required this.plazo,
  });

  // Factory para convertir de Mapa (SQLite) a Objeto
  factory Prestamo.fromMap(Map<String, dynamic> json) => Prestamo(
    id: json['id'],
    userId: json['userId'],
    //Lógica robusta para parsear doubles sin errores de tipo
    monto: (json['monto'] is String) ? double.parse(json['monto']) : (json['monto'] as num).toDouble(),
    fecha: json['fecha'],
    estado: json['estado'],
    periodicidad: json['periodicidad'],
    interes: (json['interes'] is String) ? double.parse(json['interes']) : (json['interes'] as num).toDouble(),
    saldoPendiente: (json['saldoPendiente'] is String) ? double.parse(json['saldoPendiente']) : (json['saldoPendiente'] as num).toDouble(),
    plazo: json['plazo'],
  );

  //Convertir objeto a mapa para guardar en SQLite
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
      'plazo': plazo,
    };
  }

  // Metodo para crear una copia del prestamo con valores modificados
  // Util para actualizar saldos y estados sin mutar el objeto original
  Prestamo copyWith({
    int? id,
    int? userId,
    double? monto,
    String? fecha,
    String? estado,
    String? periodicidad,
    double? interes,
    double? saldoPendiente,
    int? plazo,
  }) {
    return Prestamo(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      monto: monto ?? this.monto,
      fecha: fecha ?? this.fecha,
      estado: estado ?? this.estado,
      periodicidad: periodicidad ?? this.periodicidad,
      interes: interes ?? this.interes,
      saldoPendiente: saldoPendiente ?? this.saldoPendiente,
      plazo: plazo ?? this.plazo,
    );
  }
}