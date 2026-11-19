import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'datos.dart';
import 'equipo.dart';
import 'indicadores.dart';
import 'prueba_funcional_modelo.dart';

class InformeTecnicoPage extends StatelessWidget {
  final Equipo equipo;

  const InformeTecnicoPage({super.key, required this.equipo});

  List<dynamic> get _mantenimientos {
    final lista = mantenimientos.where((m) {
      if (m.equipoId.isNotEmpty) return m.equipoId == equipo.id;
      return equipo.inventario.trim().isNotEmpty &&
          m.equipoInventario.trim() == equipo.inventario.trim();
    }).toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
    return lista;
  }

  List<PruebaFuncional> get _pruebas => pruebasFuncionales
      .where((p) => p.equipoId == equipo.id)
      .toList()
    ..sort((a, b) => b.fecha.compareTo(a.fecha));

  String _fecha(DateTime fecha) =>
      '${fecha.day.toString().padLeft(2, '0')}/'
      '${fecha.month.toString().padLeft(2, '0')}/'
      '${fecha.year} '
      '${fecha.hour.toString().padLeft(2, '0')}:'
      '${fecha.minute.toString().padLeft(2, '0')}';

  Future<void> _generar() async {
    final metricas = calcularIndicadores(equipo);
    final listaMantenimientos = _mantenimientos;
    final listaPruebas = _pruebas;
    final ahora = DateTime.now();
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text(
            'BIOMANTE',
            style: pw.TextStyle(fontSize: 23, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            'INFORME TÉCNICO DE EQUIPO BIOMÉDICO',
            style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text('Generado: ${_fecha(ahora)}'),
          pw.SizedBox(height: 12),
          pw.Text('1. Identificación del equipo', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text('Nombre: ${equipo.nombre}'),
          pw.Text('Marca / modelo: ${equipo.marca} / ${equipo.modelo}'),
          pw.Text('Serie: ${equipo.serie.isEmpty ? "No registrada" : equipo.serie}'),
          pw.Text('Inventario: ${equipo.inventario.isEmpty ? "No registrado" : equipo.inventario}'),
          pw.Text('Ubicación: ${equipo.ubicacion.isEmpty ? "No registrada" : equipo.ubicacion}'),
          pw.Text('Estado actual registrado: ${equipo.estado}'),
          pw.SizedBox(height: 12),
          pw.Text('2. Indicadores de mantenimiento', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text('MTBF: ${metricas.mtbfHoras?.toStringAsFixed(2) ?? "N/D"} horas'),
          pw.Text('MTTR: ${metricas.mttrHoras?.toStringAsFixed(2) ?? "N/D"} horas'),
          pw.Text('Disponibilidad estimada: ${metricas.disponibilidadPorcentaje?.toStringAsFixed(2) ?? "N/D"} %'),
          pw.Text('Los indicadores solo se calculan cuando existen fechas reales suficientes.'),
          pw.SizedBox(height: 12),
          pw.Text('3. Historial de mantenimiento', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          if (listaMantenimientos.isEmpty)
            pw.Text('No hay mantenimientos registrados.')
          else
            ...listaMantenimientos.map((m) => pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('${_fecha(m.fecha)} · ${m.tipo}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('Técnico: ${m.tecnico}'),
                  pw.Text('Trabajo: ${m.descripcion}'),
                  pw.Text('Fallas: ${m.fallas.isEmpty ? "No registradas" : m.fallas}'),
                  pw.Text('Repuestos: ${m.repuestos.isEmpty ? "No registrados" : m.repuestos}'),
                  pw.Text('Resultado: ${m.resultado}'),
                  if (m.fechaFalla != null) pw.Text('Fecha de falla: ${_fecha(m.fechaFalla!)}'),
                  if (m.inicioReparacion != null) pw.Text('Inicio de reparación: ${_fecha(m.inicioReparacion!)}'),
                  if (m.finReparacion != null) pw.Text('Fin de reparación: ${_fecha(m.finReparacion!)}'),
                  if (m.retornoOperacion != null) pw.Text('Retorno a operación: ${_fecha(m.retornoOperacion!)}'),
                  pw.Text('Observaciones: ${m.observaciones.isEmpty ? "Sin observaciones" : m.observaciones}'),
                ],
              ),
            )),
          pw.SizedBox(height: 12),
          pw.Text('4. Pruebas funcionales', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          if (listaPruebas.isEmpty)
            pw.Text('No hay pruebas funcionales registradas.')
          else
            ...listaPruebas.map((prueba) => pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('${_fecha(prueba.fecha)} · Técnico: ${prueba.tecnico}'),
                  pw.Text('Resultado: ${prueba.aprobada ? "Cumple" : "Con no conformidades"}'),
                  ...prueba.checklist.entries.map((entry) => pw.Text('• ${entry.key}: ${entry.value}')),
                  if (prueba.observaciones.isNotEmpty) pw.Text('Observaciones: ${prueba.observaciones}'),
                  if (prueba.evidencias.isNotEmpty)
                    pw.Text('Evidencias adjuntas en Biomante: ${prueba.evidencias.map((e) => e.nombre).join(", ")}'),
                ],
              ),
            )),
          pw.SizedBox(height: 14),
          pw.Text('5. Observaciones y alcance', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(
            'Este informe recopila los datos ingresados en Biomante. No sustituye el protocolo de mantenimiento, '
            'los resultados de instrumentos calibrados ni la validación técnica requerida por el fabricante o la institución. '
            'La disponibilidad mostrada es una estimación basada en MTBF y MTTR registrados.',
          ),
          pw.SizedBox(height: 20),
          pw.Text('Técnico responsable: __________________________________________'),
          pw.Text('Firma: ____________________________    Fecha: ________________'),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    final metricas = calcularIndicadores(equipo);

    return Scaffold(
      appBar: AppBar(title: const Text('Informe técnico')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.medical_services),
              title: Text(equipo.nombre),
              subtitle: Text('${equipo.marca} ${equipo.modelo} · ${equipo.inventario}'),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'El informe reúne identificación del equipo, indicadores disponibles, mantenimientos, pruebas funcionales y observaciones.',
          ),
          const SizedBox(height: 12),
          ListTile(title: const Text('MTBF'), trailing: Text(metricas.mtbfHoras == null ? 'N/D' : '${metricas.mtbfHoras!.toStringAsFixed(2)} h')),
          ListTile(title: const Text('MTTR'), trailing: Text(metricas.mttrHoras == null ? 'N/D' : '${metricas.mttrHoras!.toStringAsFixed(2)} h')),
          ListTile(title: const Text('Disponibilidad estimada'), trailing: Text(metricas.disponibilidadPorcentaje == null ? 'N/D' : '${metricas.disponibilidadPorcentaje!.toStringAsFixed(2)} %')),
          ListTile(title: const Text('Mantenimientos registrados'), trailing: Text(_mantenimientos.length.toString())),
          ListTile(title: const Text('Pruebas funcionales'), trailing: Text(_pruebas.length.toString())),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _generar,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Generar / imprimir informe PDF'),
            ),
          ),
        ],
      ),
    );
  }
}
