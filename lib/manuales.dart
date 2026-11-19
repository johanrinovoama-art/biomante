import 'dart:convert';
import 'dart:typed_data';
import 'almacen_documentos.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'datos.dart';
import 'documento.dart';
import 'equipo.dart';
import 'asistente_tecnico.dart';

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

  // =============================================================
  // SUBIR DOCUMENTO PDF
  // =============================================================

  Future<void> subirDocumento() async {
    try {
      final resultado = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (resultado == null) {
        return;
      }

      final archivo = resultado.files.first;

      if (archivo.bytes == null) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo leer el archivo seleccionado.',
            ),
          ),
        );

        return;
      }

      debugPrint(
        'Archivo seleccionado: ${archivo.name}',
      );

      debugPrint(
        'Bytes originales: ${archivo.bytes!.length}',
      );

      if (archivo.bytes!.isEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'El archivo seleccionado está vacío.',
            ),
          ),
        );

        return;
      }

      // Seleccionar tipo de documento
      final tipo = await seleccionarTipoDocumento();

      if (tipo == null) {
        return;
      }

      // Convertir PDF a Base64
      final contenidoBase64 = base64Encode(
        archivo.bytes!,
      );

      debugPrint(
        'Base64 generado: ${contenidoBase64.length} caracteres',
      );

      // Crear documento
      final documento = Documento(
        nombre: archivo.name,
        tipo: tipo,
        equipoInventario: widget.equipo.inventario,
        contenidoBase64: contenidoBase64,
      );

      // Agregar documento
      documentos.add(documento);

      // Guardar
      await guardarDatos();

      if (!mounted) return;

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Documento guardado correctamente.',
          ),
        ),
      );
    } catch (e) {
      debugPrint(
        'ERROR AL SUBIR DOCUMENTO: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al subir el documento: $e',
          ),
        ),
      );
    }
  }

  // =============================================================
  // SELECCIONAR TIPO DE DOCUMENTO
  // =============================================================

  Future<String?> seleccionarTipoDocumento() async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Tipo de documento',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _opcionTipo(
                'Manual de usuario',
                Icons.menu_book,
              ),
              _opcionTipo(
                'Manual de servicio',
                Icons.build,
              ),
              _opcionTipo(
                'Manual técnico',
                Icons.engineering,
              ),
              _opcionTipo(
                'Protocolo',
                Icons.assignment,
              ),
              _opcionTipo(
                'Otro documento',
                Icons.description,
              ),
            ],
          ),
        );
      },
    );
  }

  // =============================================================
  // OPCIÓN DE TIPO
  // =============================================================

  Widget _opcionTipo(
    String tipo,
    IconData icono,
  ) {
    return ListTile(
      leading: Icon(icono),
      title: Text(tipo),
      onTap: () {
        Navigator.pop(
          context,
          tipo,
        );
      },
    );
  }

  // =============================================================
  // DOCUMENTOS DEL EQUIPO
  // =============================================================

  List<Documento> get documentosDelEquipo {
    return documentos.where((documento) {
      return documento.equipoInventario ==
          widget.equipo.inventario;
    }).toList();
  }

  // =============================================================
  // ABRIR DOCUMENTO
  // =============================================================

  void abrirDocumento(
    Documento documento,
  ) {
    try {
      debugPrint(
        'Abriendo documento: ${documento.nombre}',
      );

      debugPrint(
        'Base64 almacenado: '
        '${documento.contenidoBase64.length} caracteres',
      );

      if (documento.contenidoBase64.isEmpty) {
        throw Exception(
          'El documento no contiene datos.',
        );
      }

      // Convertir Base64 a bytes
      final Uint8List bytes = base64Decode(
        documento.contenidoBase64.trim(),
      );

      debugPrint(
        'Bytes recuperados: ${bytes.length}',
      );

      if (bytes.isEmpty) {
        throw Exception(
          'El archivo PDF recuperado está vacío.',
        );
      }

      // Comprobar encabezado PDF
      if (bytes.length >= 4) {
        final encabezado = String.fromCharCodes(
          bytes.sublist(0, 4),
        );

        debugPrint(
          'Encabezado del archivo: $encabezado',
        );

        if (encabezado != '%PDF') {
          throw Exception(
            'El archivo recuperado no parece ser un PDF válido.',
          );
        }
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return PdfViewerMemoryPage(
              titulo: documento.nombre,
              bytes: bytes,
            );
          },
        ),
      );
    } catch (e) {
      debugPrint(
        'ERROR AL ABRIR PDF: $e',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo abrir el documento: $e',
          ),
          duration: const Duration(
            seconds: 8,
          ),
        ),
      );
    }
  }

  // =============================================================
  // ELIMINAR DOCUMENTO
  // =============================================================

  Future<void> eliminarDocumento(
    Documento documento,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Eliminar documento',
          ),
          content: Text(
            '¿Deseas eliminar "${documento.nombre}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'Cancelar',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Eliminar',
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    documentos.remove(
      documento,
    );

    await guardarDatos();

    if (!mounted) return;

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Documento eliminado.',
        ),
      ),
    );
  }

  // =============================================================
  // INTERFAZ
  // =============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final documentosEquipo =
        documentosDelEquipo;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manuales y documentación',
        ),
        actions: [
          IconButton(
            tooltip: 'Subir documento',
            icon: const Icon(
              Icons.upload_file,
            ),
            onPressed: subirDocumento,
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // =====================================================
          // INFORMACIÓN DEL EQUIPO
          // =====================================================

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.medical_services,
                    size: 45,
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Text(
                    widget.equipo.nombre,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    '${widget.equipo.marca} • '
                    '${widget.equipo.modelo}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    'Inventario: '
                    '${widget.equipo.inventario.isEmpty ? "No registrado" : widget.equipo.inventario}',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          // =====================================================
          // SUBIR PDF
          // =====================================================

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: subirDocumento,
              icon: const Icon(
                Icons.upload_file,
              ),
              label: const Text(
                'Subir documento PDF',
              ),
            ),
          ),

          const SizedBox(
            height: 25,
          ),

          // =====================================================
          // DOCUMENTOS
          // =====================================================

          const Text(
            'Documentos del equipo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          if (documentosEquipo.isEmpty)

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.folder_open,
                      size: 50,
                      color: Colors.grey.shade500,
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    const Text(
                      'No hay documentos cargados.',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Text(
                      'Sube el manual o documento técnico '
                      'correspondiente a este equipo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            )

          else

            ...documentosEquipo.map(
              (documento) {
                return Card(
                  margin: const EdgeInsets.only(
                    bottom: 12,
                  ),

                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(
                        Icons.picture_as_pdf,
                      ),
                    ),

                    title: Text(
                      documento.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    subtitle: Text(
                      documento.tipo,
                    ),

                    trailing:
                        PopupMenuButton<String>(
                      onSelected: (opcion) {
                        if (opcion == 'abrir') {
                          abrirDocumento(
                            documento,
                          );
                        }

                        if (opcion == 'eliminar') {
                          eliminarDocumento(
                            documento,
                          );
                        }
                      },

                      itemBuilder: (context) {
                        return const [
                          PopupMenuItem(
                            value: 'abrir',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.open_in_new,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Abrir',
                                ),
                              ],
                            ),
                          ),

                          PopupMenuItem(
                            value: 'eliminar',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Eliminar',
                                ),
                              ],
                            ),
                          ),
                        ];
                      },
                    ),

                    onTap: () {
                      abrirDocumento(
                        documento,
                      );
                    },
                  ),
                );
              },
            ),

          const SizedBox(
            height: 25,
          ),

          // =====================================================
          // ASISTENTE TÉCNICO
          // =====================================================

          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(
                  Icons.smart_toy,
                ),
              ),

              title: const Text(
                'Asistente técnico',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              subtitle: const Text(
                'Consulta fallas, diagnóstico y '
                'posibles soluciones.',
              ),

              trailing: const Icon(
                Icons.arrow_forward_ios,
              ),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AsistenteTecnicoPage(
                      equipo: widget.equipo,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          // =====================================================
          // INFORMACIÓN
          // =====================================================

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 28,
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child: Text(
                      'Los documentos se asocian '
                      'individualmente a cada equipo. '
                      'Así podrás consultar el manual '
                      'correspondiente sin mezclar la '
                      'documentación de otros equipos.',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}

// =============================================================
// VISOR PDF
// =============================================================

class PdfViewerMemoryPage extends StatelessWidget {
  final String titulo;
  final Uint8List bytes;

  const PdfViewerMemoryPage({
    super.key,
    required this.titulo,
    required this.bytes,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          titulo,
        ),
      ),

      body: SfPdfViewer.memory(
        bytes,

        onDocumentLoaded: (details) {
          debugPrint(
            'PDF cargado correctamente.',
          );
        },

        onDocumentLoadFailed: (details) {
          debugPrint(
            'ERROR PDF: '
            '${details.description}',
          );

          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              content: Text(
                'No se pudo abrir el PDF: '
                '${details.description}',
              ),
              duration: const Duration(
                seconds: 8,
              ),
            ),
          );
        },
      ),
    );
  }
}