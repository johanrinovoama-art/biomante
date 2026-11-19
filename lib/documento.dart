
class Documento {
  String nombre;
  String tipo;
  String equipoInventario;

  // Compatible con los PDF guardados anteriormente.
  String contenidoBase64;

  // Identificador del PDF almacenado en IndexedDB.
  String? almacenamientoId;

  Documento({
    required this.nombre,
    required this.tipo,
    required this.equipoInventario,
    required this.contenidoBase64,
    this.almacenamientoId,
  });
}
