class Equipo {
  /// Identificador interno estable. No depende del código de inventario.
  final String id;

  String nombre;
  String marca;
  String modelo;
  String serie;
  String inventario;
  String ubicacion;
  String estado;

  DateTime? ultimoMantenimiento;
  DateTime? proximoMantenimiento;

  Equipo({
    String? id,
    required this.nombre,
    required this.marca,
    required this.modelo,
    required this.serie,
    required this.inventario,
    required this.ubicacion,
    required this.estado,
    this.ultimoMantenimiento,
    this.proximoMantenimiento,
  }) : id = (id == null || id.trim().isEmpty)
            ? _crearId()
            : id.trim();

  static String _crearId() {
    return 'eq_${DateTime.now().microsecondsSinceEpoch}';
  }
}
