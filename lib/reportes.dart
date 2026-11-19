import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'datos.dart';
import 'indicadores.dart';

class ReportesPage extends StatelessWidget {
  const ReportesPage({super.key});

  String _valorHoras(double? valor) =>
      valor == null ? 'Sin datos suficientes' : '${valor.toStringAsFixed(2)} h';

  String _valorDisponibilidad(double? valor) =>
      valor == null ? 'Sin datos suficientes' : '${valor.toStringAsFixed(2)} %';

  Future<void> _generarReporte() async {
    final documento = pw.Document();
    final fecha = DateTime.now();
    final fechaTexto =
        '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';

    documento.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text(
            'BIOMANTE',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text('Reporte general de mantenimiento biomédico'),
          pw.Text('Fecha de generación: ${fechaTexto}'),
          pw.SizedBox(height: 12),
          pw.Text('Resumen'),
          pw.Text('Equipos registrados: ${equipos.length}'),
          pw.Text('Mantenimientos registrados: ${mantenimientos.length}'),
          pw.Text('Pruebas funcionales: ${pruebasFuncionales.length}'),
          pw.SizedBox(height: 16),
          pw.Text('Indicadores por equipo', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Equipo')),
                  pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('MTBF (h)')),
                  pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('MTTR (h)')),
                  pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Disponibilidad')),
                ],
              ),
              ...equipos.map((equipo) {
                final m = calcularIndicadores(equipo);
                return pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('${equipo.nombre}\n${equipo.inventario}')),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(m.mtbfHoras?.toStringAsFixed(2) ?? 'N/D')),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(m.mttrHoras?.toStringAsFixed(2) ?? 'N/D')),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(m.disponibilidadPorcentaje?.toStringAsFixed(2) ?? 'N/D')),
                  ],
                );
              }),
            ],
          ),
          pw.SizedBox(height: 14),
          pw.Text('Criterio de interpretación', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(
            'MTBF se calcula como el promedio de intervalos entre fechas de falla consecutivas registradas. '
            'MTTR se calcula desde el inicio de la reparación hasta el retorno a operación (o fin de reparación si no se registra retorno). '
            'La disponibilidad se estima con MTBF / (MTBF + MTTR). Los indicadores se muestran como N/D cuando faltan datos; '
            'los registros antiguos sin tiempos no se interpretan como cero.',
          ),
          pw.SizedBox(height: 14),
          pw.Text('Últimos mantenimientos', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ...((mantenimientos.toList()..sort((a, b) => b.fecha.compareTo(a.fecha)))
              .take(30)
              .map((m) => pw.Text(
                    '${m.fecha.toIso8601String()} · ${m.tipo} · ${m.equipoInventario} · ${m.tecnico} · ${m.resultado}',
                    style: const pw.TextStyle(fontSize: 9),
                  ))),
          pw.SizedBox(height: 12),
          pw.Text(
            'Documento generado por Biomante. La información depende de los registros ingresados por los usuarios.',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => documento.save());
  }

  @override
  Widget build(BuildContext context) {
    final indicadores = equipos
        .map((equipo) => (equipo: equipo, datos: calcularIndicadores(equipo)))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Indicadores y reportes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            children: [
              _Resumen(titulo: 'Equipos', valor: equipos.length.toString(), icono: Icons.medical_services),
              _Resumen(titulo: 'Mantenimientos', valor: mantenimientos.length.toString(), icono: Icons.build),
              _Resumen(titulo: 'Pruebas funcionales', valor: pruebasFuncionales.length.toString(), icono: Icons.fact_check),
              _Resumen(titulo: 'Correctivos', valor: mantenimientos.where((m) => m.tipo.toLowerCase() == 'correctivo').length.toString(), icono: Icons.warning),
            ],
          ),
          const SizedBox(height: 18),
          const Text('Indicadores de confiabilidad', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Los indicadores requieren fechas reales de falla y reparación. Los equipos sin registros suficientes se muestran sin dato.'),
          const SizedBox(height: 12),
          if (indicadores.isEmpty)
            const Text('Registra equipos para comenzar a calcular indicadores.')
          else
            ...indicadores.map(
              (item) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.equipo.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Inventario: ${item.equipo.inventario.isEmpty ? "No registrado" : item.equipo.inventario}'),
                      const SizedBox(height: 8),
                      _LineaIndicador(titulo: 'MTBF', valor: _valorHoras(item.datos.mtbfHoras)),
                      _LineaIndicador(titulo: 'MTTR', valor: _valorHoras(item.datos.mttrHoras)),
                      _LineaIndicador(titulo: 'Disponibilidad estimada', valor: _valorDisponibilidad(item.datos.disponibilidadPorcentaje)),
                      Text(
                        'Fallas con fecha: ${item.datos.fallasRegistradas} · Reparaciones medibles: ${item.datos.reparacionesMedibles}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _generarReporte,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Generar informe PDF'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Resumen extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;

  const _Resumen({required this.titulo, required this.valor, required this.icono});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono),
            const SizedBox(height: 6),
            Text(valor, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
            Text(titulo, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _LineaIndicador extends StatelessWidget {
  final String titulo;
  final String valor;

  const _LineaIndicador({required this.titulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(titulo),
          Flexible(
            child: Text(valor, textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
