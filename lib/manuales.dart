import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'almacen_documentos.dart';
import 'asistente_tecnico.dart';
import 'datos.dart';
import 'documento.dart';
import 'equipo.dart';

class ManualesPage extends StatefulWidget {
  final Equipo equipo;

  const ManualesPage({
    super.key,
    required this.equipo,
  });

  @override
  State<ManualesPage> createState() => _ManualesPageState();
}

class _ManualesPageState extends State<ManualesPage> {
  bool _ocupado = false;

  List<Documento> get documentosDelEquipo {
    return documentos.where((documento) {
      if (documento.equipoId.isNotEmpty) {
        return documento.equipoId == widget.equipo.id;
      }

      // Compatibilidad con documentos históricos que aún no tienen ID.
      return widget.equipo.inventario.trim().isNotEmpty &&
          documento.equipoInventario.trim() ==
              widget.equipo.inventario.trim();
    }).toList();
  }

  bool _esPdf(Uint8List bytes) {
    if (bytes.length < 5) return false;
    return String.fromCharCodes(bytes.sublist(0, 5)) == '%PDF-';
  }

  Future<String?> _seleccionarTipoDocumento() {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tipo de documento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _opcionTipo('Manual de usuario', Icons.menu_book),
            _opcionTipo('Manual de servicio', Icons.build),
            _opcionTipo('Manual técnico', Icons.engineering),
            _opcionTipo('Protocolo', Icons.assignment),
            _opcionTipo('Otro documento', Icons.description),
          ],
        ),
      ),
    );
  }

  Widget _opcionTipo(String tipo, IconData icono) {
    return ListTile(
      leading: Icon(icono),
      title: Text(tipo),
      onTap: () => Navigator.pop(context, tipo),
    );
  }

  Future<void> subirDocumento() async {
    if (_ocupado) return;
    setState(() => _ocupado = true);

    String? almacenamientoId;
    Documento? documentoCreado;

    try {
      final resultado = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
        withData: true,
      );
      if (resultado == null || resultado.files.isEmpty) return;

      final archivo = resultado.files.first;
      final bytes = archivo.bytes;

      if (bytes == null || bytes.isEmpty) {
        throw Exception('No se pudo leer el archivo seleccionado.');
      }
      if (!_esPdf(bytes)) {
        throw Exception('El archivo seleccionado no tiene una firma PDF válida.');
      }

      if (!mounted) return;
      final tipo = await _seleccionarTipoDocumento();
      if (tipo == null || !mounted) return;

      almacenamientoId = 'doc_${DateTime.now().microsecondsSinceEpoch}';
      await AlmacenDocumentos.guardar(almacenamientoId, bytes);

      documentoCreado = Documento(
        nombre: archivo.name,
        tipo: tipo,
        equipoId: widget.equipo.id,
        equipoInventario: widget.equipo.inventario,
        contenidoBase64: '',
        almacenamientoId: almacenamientoId,
      );

      documentos.add(documentoCreado);
      try {
        await guardarDatos();
      } catch (_) {
        documentos.remove(documentoCreado);
        rethrow;
      }

      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Documento guardado correctamente.')),
      );
    } catch (error) {
      if (documentoCreado != null) {
        documentos.remove(documentoCreado);
      }
      if (almacenamientoId != null) {
        try {
          await AlmacenDocumentos.eliminar(almacenamientoId);
        } catch (errorLimpieza) {
          debugPrint('No se pudo limpiar el PDF temporal: $errorLimpieza');
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo subir el documento: $error')),
      );
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> abrirDocumento(Documento documento) async {
    try {
      Uint8List? bytes;
      final id = documento.almacenamientoId;

      if (id != null && id.isNotEmpty) {
        bytes = await AlmacenDocumentos.leer(id);
      }

      // Respaldo para documentos históricos que aún están en Base64.
      if ((bytes == null || bytes.isEmpty) &&
          documento.contenidoBase64.trim().isNotEmpty) {
        bytes = base64Decode(documento.contenidoBase64.trim());
      }

      if (bytes == null || bytes.isEmpty || !_esPdf(bytes)) {
        throw Exception('No se encontró un PDF válido en el almacenamiento.');
      }

      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerMemoryPage(
            titulo: documento.nombre,
            bytes: bytes!,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo abrir el documento: $error'),
          duration: const Duration(seconds: 8),
        ),
      );
    }
  }

  Future<void> eliminarDocumento(Documento documento) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar documento'),
        content: Text('¿Deseas eliminar "${documento.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;
    final indice = documentos.indexOf(documento);
    if (indice < 0) return;

    documentos.removeAt(indice);
    try {
      await guardarDatos();
    } catch (error) {
      documentos.insert(indice, documento);
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar el registro: $error')),
      );
      return;
    }

    final id = documento.almacenamientoId;
    if (id != null && id.isNotEmpty) {
      try {
        await AlmacenDocumentos.eliminar(id);
      } catch (error) {
        debugPrint('No se pudo eliminar el archivo $id: $error');
      }
    }

    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Documento eliminado.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final documentosEquipo = documentosDelEquipo;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manuales y documentación'),
        actions: [
          IconButton(
            tooltip: 'Subir documento',
            onPressed: _ocupado ? null : subirDocumento,
            icon: const Icon(Icons.upload_file),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.medical_services, size: 45),
                  const SizedBox(height: 12),
                  Text(
                    widget.equipo.nombre,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${widget.equipo.marca} • ${widget.equipo.modelo}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Inventario: ${widget.equipo.inventario.isEmpty ? "No registrado" : widget.equipo.inventario}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _ocupado ? null : subirDocumento,
              icon: const Icon(Icons.upload_file),
              label: Text(
                _ocupado ? 'Guardando documento...' : 'Subir documento PDF',
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Documentos del equipo',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (documentosEquipo.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.folder_open, size: 50),
                    SizedBox(height: 10),
                    Text(
                      'No hay documentos cargados.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Sube el manual o documento técnico correspondiente a este equipo.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ...documentosEquipo.map(
              (documento) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.picture_as_pdf),
                  ),
                  title: Text(
                    documento.nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(documento.tipo),
                  trailing: PopupMenuButton<String>(
                    onSelected: (opcion) {
                      if (opcion == 'abrir') {
                        abrirDocumento(documento);
                      } else if (opcion == 'eliminar') {
                        eliminarDocumento(documento);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'abrir', child: Text('Abrir')),
                      PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
                    ],
                  ),
                  onTap: () => abrirDocumento(documento),
                ),
              ),
            ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.smart_toy)),
              title: const Text(
                'Asistente técnico',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Consulta fallas y orientación inicial del equipo.',
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AsistenteTecnicoPage(
                      equipo: widget.equipo,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PdfViewerMemoryPage extends StatelessWidget {
  final String titulo;
  final Uint8List bytes;

  const PdfViewerMemoryPage({
    super.key,
    required this.titulo,
    required this.bytes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: SfPdfViewer.memory(
        bytes,
        onDocumentLoadFailed: (details) {
          debugPrint('ERROR PDF: ${details.description}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'No se pudo abrir el PDF: ${details.description}',
              ),
              duration: const Duration(seconds: 8),
            ),
          );
        },
      ),
    );
  }
}
