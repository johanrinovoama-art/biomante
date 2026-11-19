import 'package:flutter_test/flutter_test.dart';

import 'package:biomante/datos.dart';
import 'package:biomante/equipo.dart';
import 'package:biomante/indicadores.dart';
import 'package:biomante/mantenimiento_modelo.dart';

void main() {
  group('Indicadores de mantenimiento', () {
    late Equipo equipo;

    setUp(() {
      equipo = Equipo(
        id: 'eq-test',
        nombre: 'Monitor de prueba',
        marca: 'Demo',
        modelo: 'M1',
        serie: 'S-01',
        inventario: 'INV-01',
        ubicacion: 'Laboratorio',
        estado: 'Operativo',
      );
      mantenimientos = [];
    });

    test('calcula MTBF, MTTR y disponibilidad con fechas reales', () {
      mantenimientos = [
        Mantenimiento(
          equipoId: equipo.id,
          equipoInventario: equipo.inventario,
          tipo: 'Correctivo',
          tecnico: 'Técnico',
          descripcion: 'Reparación 1',
          fallas: '',
          repuestos: '',
          resultado: 'Operativo',
          observaciones: '',
          fecha: DateTime(2025, 1, 1),
          fechaFalla: DateTime(2025, 1, 1),
          inicioReparacion: DateTime(2025, 1, 1, 1),
          retornoOperacion: DateTime(2025, 1, 1, 3),
        ),
        Mantenimiento(
          equipoId: equipo.id,
          equipoInventario: equipo.inventario,
          tipo: 'Correctivo',
          tecnico: 'Técnico',
          descripcion: 'Reparación 2',
          fallas: '',
          repuestos: '',
          resultado: 'Operativo',
          observaciones: '',
          fecha: DateTime(2025, 1, 11),
          fechaFalla: DateTime(2025, 1, 11),
          inicioReparacion: DateTime(2025, 1, 11, 1),
          finReparacion: DateTime(2025, 1, 11, 4),
          retornoOperacion: DateTime(2025, 1, 11, 5),
        ),
      ];

      final indicadores = calcularIndicadores(equipo);
      expect(indicadores.mtbfHoras, 240);
      expect(indicadores.mttrHoras, 3);
      expect(
        indicadores.disponibilidadPorcentaje,
        closeTo(240 / 243 * 100, 0.0001),
      );
    });

    test('no inventa indicadores cuando faltan marcas de tiempo', () {
      mantenimientos = [
        Mantenimiento(
          equipoId: equipo.id,
          equipoInventario: equipo.inventario,
          tipo: 'Correctivo',
          tecnico: 'Técnico',
          descripcion: 'Sin hora de falla',
          fallas: '',
          repuestos: '',
          resultado: 'Pendiente',
          observaciones: '',
          fecha: DateTime(2025, 1, 1),
        ),
      ];

      final indicadores = calcularIndicadores(equipo);
      expect(indicadores.mtbfHoras, isNull);
      expect(indicadores.mttrHoras, isNull);
      expect(indicadores.disponibilidadPorcentaje, isNull);
    });
  });
}
