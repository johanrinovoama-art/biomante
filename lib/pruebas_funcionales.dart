import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'almacen_documentos.dart';
import 'datos.dart';
import 'equipo.dart';
import 'prueba_funcional_modelo.dart';

class PruebasFuncionalesPage extends StatefulWidget {
  final Equipo equipo;

  const PruebasFuncionalesPage({super.key, required this.equipo});

  @override
  State<PruebasFuncionalesPage> createState() => _PruebasFuncionalesPageState();
}

class _PruebasFuncionalesPageState extends State<PruebasFuncionalesPage> {
  static const List<String> _itemsChecklist = [
    'Inspección visual y estado físico',
    'Integridad de cables y accesorios',
    'Encendido y apagado seguro',
    'Controles, botones e indicadores',
    'Alarmas e indicadores de seguridad',
    'Verificación de funciones principales',
    'Comprobación de parámetros operativos',
    'Limpieza y condiciones de operación',
  ];

  final tecnicoController = TextEditingController();
  final observacionesController = TextEditingController();
  late final Map<String, String> resultados;
  final List<EvidenciaFuncional> evidenciasTemporales = [];
  bool guardando = false;

  @override
  void initState() {
    super.initState();
    resultados = {for (final item in _itemsChecklist) item: ''};
  }

  @override
  void dispose() {
    tecnicoController.dispose();
    observacionesController.dispose();
    super.dispose();
  }

  List<PruebaFuncional> get historialEquipo => pruebasFuncionales
      .where((prueba) => prueba.equipoId == widget.equipo.id)
      .toList()
    ..sort((a, b) => b.fecha.compareTo(a.fecha));

  String _formatFecha(DateTime fecha) =>
      '${fecha.day.toString().padLeft(2, '0')}/'
      '${fecha.month.toString().padLeft(2, '0')}/'
      '${fecha.year}';

  Future<void> agregarEvidencias() async {
    try {
      final seleccion = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
      );
      if (seleccion == null) return;

      for (final archivo in seleccion.files) {
        final bytes = archivo.bytes;
        if (bytes == null || bytes.isEmpty) continue;

        final extension = (archivo.extension ?? '').toLowerCase();
        if (!['jpg', 'jpeg', 'png', 'webp'].contains(extension)) continue;

        final id = 'evidencia_${DateTime.now().microsecondsSinceEpoch}_${evidenciasTemporales.length}';
        await AlmacenDocumentos.guardar(id, bytes);
        evidenciasTemporales.add(
          EvidenciaFuncional(nombre: archivo.name, almacenamientoId: id),
        );
      }

      if (mounted) setState(() {});
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudieron cargar las evidencias: $error')),
      );
    }
  }

  Future<void> verEvidencia(EvidenciaFuncional evidencia) async {
    try {
      final bytes = await AlmacenDocumentos.leer(evidencia.almacenamientoId);
      if (bytes == null || bytes.isEmpty) {
        throw Exception('No se encontró la imagen almacenada.');
      }
      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (context) => Dialog(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(evidencia.nombre),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 480, maxWidth: 480),
                  child: Image.memory(bytes, fit: BoxFit.contain),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir la evidencia: $error')),
      );
    }
  }

  Future<void> quitarEvidencia(EvidenciaFuncional evidencia) async {
    evidenciasTemporales.remove(evidencia);
    try {
      await AlmacenDocumentos.eliminar(evidencia.almacenamientoId);
    } catch (error) {
      debugPrint('No se pudo eliminar la imagen temporal: $error');
    }
    if (mounted) setState(() {});
  }

  Future<void> guardarPrueba() async {
    if (guardando) return;

    if (tecnicoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa el técnico responsable.')),
      );
      return;
    }
    if (resultados.values.any((resultado) => resultado.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes marcar cada punto del checklist.')),
      );
      return;
    }

    final prueba = PruebaFuncional(
      equipoId: widget.equipo.id,
      equipoInventario: widget.equipo.inventario,
      tecnico: tecnicoController.text.trim(),
      fecha: DateTime.now(),
      checklist: Map<String, String>.from(resultados),
      observaciones: observacionesController.text.trim(),
      evidencias: List<EvidenciaFuncional>.from(evidenciasTemporales),
    );

    setState(() => guardando = true);
    pruebasFuncionales.add(prueba);

    try {
      await guardarDatos();
    } catch (error) {
      pruebasFuncionales.remove(prueba);
      for (final evidencia in evidenciasTemporales) {
        try {
          await AlmacenDocumentos.eliminar(evidencia.almacenamientoId);
        } catch (_) {}
      }
      evidenciasTemporales.clear();
      if (!mounted) return;
      setState(() => guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar la prueba: $error')),
      );
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          prueba.aprobada
              ? 'Prueba funcional guardada: cumple.'
              : 'Prueba funcional guardada: se encontraron no conformidades.',
        ),
      ),
    );

    setState(() {
      guardando = false;
      evidenciasTemporales.clear();
      for (final item in _itemsChecklist) {
        resultados[item] = '';
      }
      tecnicoController.clear();
      observacionesController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final historial = historialEquipo;

    return Scaffold(
      appBar: AppBar(title: const Text('Pruebas funcionales')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.medical_services),
              title: Text(
                widget.equipo.nombre,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${widget.equipo.marca} ${widget.equipo.modelo} · '
                'Inventario: ${widget.equipo.inventario.isEmpty ? "No registrado" : widget.equipo.inventario}',
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Checklist de verificación', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text(
            'Registra el resultado de cada comprobación según el procedimiento y el manual del fabricante. Esta lista es una guía general y debe adaptarse al equipo.',
          ),
          const SizedBox(height: 12),
          ..._itemsChecklist.map(
            (item) => Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: Text(item)),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 132,
                      child: DropdownButtonFormField<String>(
                        initialValue: resultados[item]!.isEmpty ? null : resultados[item],
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          border: OutlineInputBorder(),
                        ),
                        hint: const Text('Resultado'),
                        items: const [
                          DropdownMenuItem(value: 'Cumple', child: Text('Cumple')),
                          DropdownMenuItem(value: 'No cumple', child: Text('No cumple')),
                          DropdownMenuItem(value: 'No aplica', child: Text('No aplica')),
                        ],
                        onChanged: guardando
                            ? null
                            : (valor) {
                                if (valor != null) setState(() => resultados[item] = valor);
                              },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: tecnicoController,
            decoration: const InputDecoration(
              labelText: 'Técnico responsable *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: observacionesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Observaciones y resultados',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.notes),
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: guardando ? null : agregarEvidencias,
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Adjuntar evidencias fotográficas'),
          ),
          if (evidenciasTemporales.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...evidenciasTemporales.map(
              (evidencia) => ListTile(
                leading: const Icon(Icons.image),
                title: Text(evidencia.nombre),
                onTap: () => verEvidencia(evidencia),
                trailing: IconButton(
                  tooltip: 'Quitar',
                  onPressed: guardando ? null : () => quitarEvidencia(evidencia),
                  icon: const Icon(Icons.delete_outline),
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: guardando ? null : guardarPrueba,
              icon: const Icon(Icons.save),
              label: Text(guardando ? 'Guardando...' : 'Guardar prueba funcional'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
          ),
          const SizedBox(height: 28),
          const Text('Historial de pruebas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (historial.isEmpty)
            const Text('Todavía no hay pruebas funcionales registradas.')
          else
            ...historial.map(
              (prueba) => Card(
                child: ExpansionTile(
                  leading: Icon(
                    prueba.aprobada ? Icons.check_circle : Icons.warning,
                    color: prueba.aprobada ? Colors.green : Colors.orange,
                  ),
                  title: Text(_formatFecha(prueba.fecha)),
                  subtitle: Text(
                    'Técnico: ${prueba.tecnico} · No conformidades: ${prueba.cantidadNoConformes}',
                  ),
                  children: [
                    ...prueba.checklist.entries.map(
                      (entry) => ListTile(
                        dense: true,
                        title: Text(entry.key),
                        trailing: Text(entry.value),
                      ),
                    ),
                    if (prueba.observaciones.isNotEmpty)
                      ListTile(
                        title: const Text('Observaciones'),
                        subtitle: Text(prueba.observaciones),
                      ),
                    ...prueba.evidencias.map(
                      (evidencia) => ListTile(
                        leading: const Icon(Icons.image),
                        title: Text(evidencia.nombre),
                        onTap: () => verEvidencia(evidencia),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
