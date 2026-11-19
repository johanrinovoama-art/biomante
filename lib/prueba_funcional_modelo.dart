class EvidenciaFuncional {
  final String nombre;
  final String almacenamientoId;

  const EvidenciaFuncional({
    required this.nombre,
    required this.almacenamientoId,
  });
}

class PruebaFuncional {
  final String id;
  final String equipoId;
  final String equipoInventario;
  final String tecnico;
  final DateTime fecha;
  final Map<String, String> checklist;
  final String observaciones;
  final List<EvidenciaFuncional> evidencias;

  PruebaFuncional({
    String? id,
    required this.equipoId,
    required this.equipoInventario,
    required this.tecnico,
    required this.fecha,
    required this.checklist,
    required this.observaciones,
    required this.evidencias,
  }) : id = (id == null || id.trim().isEmpty)
            ? 'pf_${DateTime.now().microsecondsSinceEpoch}'
            : id.trim();

  int get cantidadNoConformes =>
      checklist.values.where((resultado) => resultado == 'No cumple').length;

  int get cantidadCumple =>
      checklist.values.where((resultado) => resultado == 'Cumple').length;

  bool get aprobada =>
      checklist.isNotEmpty &&
      cantidadNoConformes == 0 &&
      checklist.values.every((resultado) =>
          resultado == 'Cumple' || resultado == 'No aplica');
}
