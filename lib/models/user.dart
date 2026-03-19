class User {
  final int? id;
  final String nombre;
  final String telefono;

  User({this.id, required this.nombre, required this.telefono});

  //Convertir objeto a mapa para SQLite
  factory User.fromMap(Map<String, dynamic> map) => User(
    id: map['id'],
    nombre: map['nombre'],
    telefono: map['telefono'],
  );
    Map<String, dynamic> toMap(){
      return {
      'id': id,
      'nombre': nombre,
      'telefono': telefono,
    };
  }


  // Método auxiliar para generar resumen del usuario
  String generarResumen() {
    return "Usuario #$id: $nombre, Teléfono: $telefono";
  }
}