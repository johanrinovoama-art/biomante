import 'equipo.dart';
import 'datos.dart';

class IndicadoresMantenimiento {
  final double? mtbfHoras;
  final double? mttrHoras;
  final double? disponibilidadPorcentaje;
  final int fallasRegistradas;
  final int reparacionesMedibles;

  const IndicadoresMantenimiento({
    required this.mtbfHoras,
    required this.mttrHoras,
    required this.disponibilidadPorcentaje,
    required this.fallasRegistradas,
    required this.reparacionesMedibles,
  });
}

/// MTBF: promedio entre fechas de fallas consecutivas registradas.
/// MTTR: promedio desde inicio de reparación hasta retorno a operación.
/// Disponibilidad estimada: MTBF / (MTBF + MTTR).
/// Los datos ausentes no se sustituyen por valores inventados.
IndicadoresMantenimiento calcularIndicadores(Equipo equipo) {
  final correctivos = mantenimientos.where((mantenimiento) {
    final coincidePorId = mantenimiento.equipoId.isNotEmpty &&
        mantenimiento.equipoId == equipo.id;
    final coincideLegado = mantenimiento.equipoId.isEmpty &&
        equipo.inventario.trim().isNotEmpty &&
        mantenimiento.equipoInventario.trim() == equipo.inventario.trim();

    return (coincidePorId || coincideLegado) &&
        mantenimiento.tipo.toLowerCase() == 'correctivo';
  }).toList();

  final fallas = correctivos
      .where((mantenimiento) => mantenimiento.fechaFalla != null)
      .map((mantenimiento) => mantenimiento.fechaFalla!)
      .toList()
    ..sort();

  final intervalos = <double>[];
  for (var i = 1; i < fallas.length; i++) {
    final horas = fallas[i].difference(fallas[i - 1]).inMinutes / 60;
    if (horas > 0) intervalos.add(horas);
  }

  final tiemposReparacion = <double>[];
  for (final mantenimiento in correctivos) {
    final inicio = mantenimiento.inicioReparacion;
    final retorno = mantenimiento.retornoOperacion ?? mantenimiento.finReparacion;
    if (inicio == null || retorno == null || retorno.isBefore(inicio)) continue;

    final horas = retorno.difference(inicio).inMinutes / 60;
    if (horas > 0) tiemposReparacion.add(horas);
  }

  double? promedio(List<double> valores) {
    if (valores.isEmpty) return null;
    return valores.reduce((a, b) => a + b) / valores.length;
  }

  final mtbf = promedio(intervalos);
  final mttr = promedio(tiemposReparacion);
  double? disponibilidad;

  if (mtbf != null && mttr != null && mtbf + mttr > 0) {
    disponibilidad = mtbf / (mtbf + mttr) * 100;
  }

  return IndicadoresMantenimiento(
    mtbfHoras: mtbf,
    mttrHoras: mttr,
    disponibilidadPorcentaje: disponibilidad,
    fallasRegistradas: fallas.length,
    reparacionesMedibles: tiemposReparacion.length,
  );
}
