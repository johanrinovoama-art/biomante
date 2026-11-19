import 'package:flutter/material.dart';
import 'equipo.dart';
import 'datos.dart';
import 'mantenimiento_modelo.dart';

class HistorialPage extends StatelessWidget {
  final Equipo equipo;

  const HistorialPage({
    super.key,
    required this.equipo,
  });

  String formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
  }

  void mostrarDetalle(
    BuildContext context,
    Mantenimiento mantenimiento,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(mantenimiento.tipo),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Detalle(
                  titulo: 'Fecha',
                  valor: formatearFecha(mantenimiento.fecha),
                ),
                _Detalle(
                  titulo: 'Técnico responsable',
                  valor: mantenimiento.tecnico,
                ),
                _Detalle(
                  titulo: 'Trabajo realizado',
                  valor: mantenimiento.descripcion,
                ),
                _Detalle(
                  titulo: 'Fallas encontradas',
                  valor: mantenimiento.fallas.isEmpty
                      ? 'Ninguna registrada'
                      : mantenimiento.fallas,
                ),
                _Detalle(
                  titulo: 'Repuestos utilizados',
                  valor: mantenimiento.repuestos.isEmpty
                      ? 'Ninguno registrado'
                      : mantenimiento.repuestos,
                ),
                _Detalle(
                  titulo: 'Resultado',
                  valor: mantenimiento.resultado,
                ),
                _Detalle(
                  titulo: 'Observaciones',
                  valor: mantenimiento.observaciones.isEmpty
                      ? 'Sin observaciones'
                      : mantenimiento.observaciones,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final historial = mantenimientos
        .where(
          (mantenimiento) =>
              mantenimiento.equipoInventario == equipo.inventario,
        )
        .toList();

    historial.sort(
      (a, b) => b.fecha.compareTo(a.fecha),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de mantenimiento'),
      ),

      body: historial.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: 70,
                    ),
                    SizedBox(height: 15),
                    Text(
                      'No hay mantenimientos',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Todavía no hay registros para este equipo.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: historial.length,
              itemBuilder: (context, index) {
                final Mantenimiento mantenimiento =
                    historial[index];

                final esPreventivo =
                    mantenimiento.tipo == 'Preventivo';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),

                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(
                        esPreventivo
                            ? Icons.build
                            : Icons.warning,
                      ),
                    ),

                    title: Text(
                      mantenimiento.tipo,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        'Fecha: ${formatearFecha(mantenimiento.fecha)}\n'
                        'Técnico: ${mantenimiento.tecnico}\n'
                        'Resultado: ${mantenimiento.resultado}',
                      ),
                    ),

                    isThreeLine: true,

                    trailing: const Icon(
                      Icons.chevron_right,
                    ),

                    onTap: () {
                      mostrarDetalle(
                        context,
                        mantenimiento,
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class _Detalle extends StatelessWidget {
  final String titulo;
  final String valor;

  const _Detalle({
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(valor),
        ],
      ),
    );
  }
}