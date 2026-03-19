class Pago {
  final int? id;
  final int prestamoId; // FK a prestamos
  final double monto;
  final String fecha;
  final double cuotaEsperada; // Cuota calculada al momento del pago

  Pago({
    this.id,
    required this.prestamoId,
    required this.monto,
    required this.fecha,
    required this.cuotaEsperada,
  });

  factory Pago.fromMap(Map<String, dynamic> json) => Pago(
      id: json['id'],
      prestamoId: json['prestamoId'],
      monto: (json['monto'] is String)
          ? double.parse(json['monto'])
          : (json['monto'] as num).toDouble(),
      fecha: json['fecha'],
      cuotaEsperada: (json['cuotaEsperada'] is String)
          ? double.parse(json['cuotaEsperada'])
          : (json['cuotaEsperada'] as num).toDouble(),
    );

    Map<String, dynamic> toMap() {
      return {
      'id': id,
      'prestamoId': prestamoId,
      'monto': monto,
      'fecha': fecha,
      'cuotaEsperada': cuotaEsperada,
      };
    }
  }