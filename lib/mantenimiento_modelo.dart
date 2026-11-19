class Mantenimiento {
  /// Identificador interno del equipo al que pertenece la intervención.
  /// Se deja vacío únicamente para registros antiguos no conciliados.
  String equipoId;

  /// Se conserva para compatibilidad con datos históricos.
  String equipoInventario;
  String tipo;
  String tecnico;
  String descripcion;
  String fallas;
  String repuestos;
  String resultado;
  String observaciones;
  DateTime fecha;

  /// Tiempos opcionales para futuros cálculos de MTTR y disponibilidad.
  DateTime? fechaFalla;
  DateTime? inicioReparacion;
  DateTime? finReparacion;
  DateTime? retornoOperacion;

  Mantenimiento({
    this.equipoId = '',
    required this.equipoInventario,
    required this.tipo,
    required this.tecnico,
    required this.descripcion,
    required this.fallas,
    required this.repuestos,
    required this.resultado,
    required this.observaciones,
    required this.fecha,
    this.fechaFalla,
    this.inicioReparacion,
    this.finReparacion,
    this.retornoOperacion,
  });
}
