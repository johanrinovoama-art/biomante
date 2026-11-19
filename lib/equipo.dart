class Equipo {
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
    required this.nombre,
    required this.marca,
    required this.modelo,
    required this.serie,
    required this.inventario,
    required this.ubicacion,
    required this.estado,
    this.ultimoMantenimiento,
    this.proximoMantenimiento,
  });
}