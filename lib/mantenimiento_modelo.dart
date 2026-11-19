class Mantenimiento {
  String equipoInventario;
  String tipo;
  String tecnico;
  String descripcion;
  String fallas;
  String repuestos;
  String resultado;
  String observaciones;
  DateTime fecha;

  Mantenimiento({
    required this.equipoInventario,
    required this.tipo,
    required this.tecnico,
    required this.descripcion,
    required this.fallas,
    required this.repuestos,
    required this.resultado,
    required this.observaciones,
    required this.fecha,
  });
}