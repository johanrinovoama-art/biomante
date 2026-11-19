class Documento {
  String nombre;
  String tipo;

  /// Identificador interno del equipo asociado.
  String equipoId;

  /// Se conserva para migrar y consultar documentos históricos.
  String equipoInventario;

  /// Compatible con documentos antiguos guardados en Base64.
  String contenidoBase64;

  /// Identificador del PDF guardado en Sembast.
  String? almacenamientoId;

  Documento({
    required this.nombre,
    required this.tipo,
    this.equipoId = '',
    required this.equipoInventario,
    required this.contenidoBase64,
    this.almacenamientoId,
  });
}
