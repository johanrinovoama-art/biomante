
```dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'equipo.dart';
import 'mantenimiento_modelo.dart';
import 'documento.dart';
import 'almacen_documentos.dart';

List<Equipo> equipos = [];
List<Mantenimiento> mantenimientos = [];
List<Documento> documentos = [];

/// Guarda los datos de Biomante.
Future<void> guardarDatos() async {
  final prefs = await SharedPreferences.getInstance();

  // Migrar documentos antiguos: pasar los PDF en Base64
  // al almacenamiento independiente.
  for (var i = 0; i < documentos.length; i++) {
    final documento = documentos[i];

    if (documento.almacenamientoId == null &&
        documento.contenidoBase64.trim().isNotEmpty) {
      try {
        final bytes = base64Decode(
          documento.contenidoBase64.trim(),
        );

        final id =
            'doc_${DateTime.now().microsecondsSinceEpoch}_$i';

        await AlmacenDocumentos.guardar(id, bytes);

        documento.almacenamientoId = id;
        documento.contenidoBase64 = '';
      } catch (e) {
        debugPrint(
          'Error al migrar el documento ${documento.nombre}: $e',
        );

        // Si la migración falla, no continuar guardando
        // metadatos que puedan hacer perder el documento.
        rethrow;
      }
    }
  }

  // Convertir los equipos a JSON.
  final equiposJson = equipos.map((equipo) {
    return {
      'nombre': equipo.nombre,
      'marca': equipo.marca,
      'modelo': equipo.modelo,
      'serie': equipo.serie,
      'inventario': equipo.inventario,
      'ubicacion': equipo.ubicacion,
      'estado': equipo.estado,
      'ultimoMantenimiento':
          equipo.ultimoMantenimiento?.toIso8601String(),
      'proximoMantenimiento':
          equipo.proximoMantenimiento?.toIso8601String(),
    };
  }).toList();

  // Convertir los mantenimientos a JSON.
  final mantenimientosJson = mantenimientos.map((mantenimiento) {
    return {
      'equipoInventario': mantenimiento.equipoInventario,
      'tipo': mantenimiento.tipo,
      'tecnico': mantenimiento.tecnico,
      'descripcion': mantenimiento.descripcion,
      'fallas': mantenimiento.fallas,
      'repuestos': mantenimiento.repuestos,
      'resultado': mantenimiento.resultado,
      'observaciones': mantenimiento.observaciones,
      'fecha': mantenimiento.fecha.toIso8601String(),
    };
  }).toList();

  // Guardar los metadatos de los documentos.
  // El contenido completo de los PDF se almacena aparte.
  final documentosJson = documentos.map((documento) {
    return {
      'nombre': documento.nombre,
      'tipo': documento.tipo,
      'equipoInventario': documento.equipoInventario,
      'contenidoBase64': documento.contenidoBase64,
      'almacenamientoId': documento.almacenamientoId,
    };
  }).toList();

  // Guardar la información.
  final resultadoEquipos = await prefs.setString(
    'equipos',
    jsonEncode(equiposJson),
  );

  final resultadoMantenimientos = await prefs.setString(
    'mantenimientos',
    jsonEncode(mantenimientosJson),
  );

  final resultadoDocumentos = await prefs.setString(
    'documentos',
    jsonEncode(documentosJson),
  );

  if (!resultadoEquipos ||
      !resultadoMantenimientos ||
      !resultadoDocumentos) {
    throw Exception(
      'No se pudieron guardar todos los datos de Biomante.',
    );
  }
}

/// Carga los datos guardados de Biomante.
Future<void> cargarDatos() async {
  final prefs = await SharedPreferences.getInstance();

  final equiposGuardados = prefs.getString('equipos');
  final mantenimientosGuardados =
      prefs.getString('mantenimientos');
  final documentosGuardados = prefs.getString('documentos');

  // -----------------------------------------
  // CARGAR EQUIPOS
  // -----------------------------------------
  if (equiposGuardados != null &&
      equiposGuardados.isNotEmpty) {
    try {
      final List<dynamic> datosEquipos =
          jsonDecode(equiposGuardados);

      equipos = datosEquipos.map((dato) {
        return Equipo(
          nombre: dato['nombre']?.toString() ?? '',
          marca: dato['marca']?.toString() ?? '',
          modelo: dato['modelo']?.toString() ?? '',
          serie: dato['serie']?.toString() ?? '',
          inventario: dato['inventario']?.toString() ?? '',
          ubicacion: dato['ubicacion']?.toString() ?? '',
          estado: dato['estado']?.toString() ?? '',
          ultimoMantenimiento:
              dato['ultimoMantenimiento'] != null
                  ? DateTime.tryParse(
                      dato['ultimoMantenimiento'].toString(),
                    )
                  : null,
          proximoMantenimiento:
              dato['proximoMantenimiento'] != null
                  ? DateTime.tryParse(
                      dato['proximoMantenimiento'].toString(),
                    )
                  : null,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error al recuperar equipos: $e');
      equipos = [];
    }
  } else {
    equipos = [];
  }

  // -----------------------------------------
  // CARGAR MANTENIMIENTOS
  // -----------------------------------------
  if (mantenimientosGuardados != null &&
      mantenimientosGuardados.isNotEmpty) {
    try {
      final List<dynamic> datosMantenimientos =
          jsonDecode(mantenimientosGuardados);

      mantenimientos = datosMantenimientos.map((dato) {
        return Mantenimiento(
          equipoInventario:
              dato['equipoInventario']?.toString() ?? '',
          tipo: dato['tipo']?.toString() ?? '',
          tecnico: dato['tecnico']?.toString() ?? '',
          descripcion: dato['descripcion']?.toString() ?? '',
          fallas: dato['fallas']?.toString() ?? '',
          repuestos: dato['repuestos']?.toString() ?? '',
          resultado: dato['resultado']?.toString() ?? '',
          observaciones:
              dato['observaciones']?.toString() ?? '',
          fecha: DateTime.tryParse(
                dato['fecha']?.toString() ?? '',
              ) ??
              DateTime.now(),
        );
      }).toList();
    } catch (e) {
      debugPrint('Error al recuperar mantenimientos: $e');
      mantenimientos = [];
    }
  } else {
    mantenimientos = [];
  }

  // -----------------------------------------
  // CARGAR DOCUMENTOS
  // -----------------------------------------
  if (documentosGuardados != null &&
      documentosGuardados.isNotEmpty) {
    try {
      final List<dynamic> datosDocumentos =
          jsonDecode(documentosGuardados);

      documentos = datosDocumentos.map((dato) {
        return Documento(
          nombre: dato['nombre']?.toString() ?? '',
          tipo: dato['tipo']?.toString() ?? '',
          equipoInventario:
              dato['equipoInventario']?.toString() ?? '',
          contenidoBase64:
              dato['contenidoBase64']?.toString() ?? '',
          almacenamientoId:
              dato['almacenamientoId']?.toString(),
        );
      }).toList();
    } catch (e) {
      debugPrint('Error al recuperar documentos: $e');
      documentos = [];
    }
  } else {
    documentos = [];
  }
}
