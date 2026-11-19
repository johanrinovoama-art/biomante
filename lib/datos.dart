import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'almacen_documentos.dart';
import 'documento.dart';
import 'equipo.dart';
import 'mantenimiento_modelo.dart';
import 'prueba_funcional_modelo.dart';

List<Equipo> equipos = [];
List<Mantenimiento> mantenimientos = [];
List<Documento> documentos = [];
List<PruebaFuncional> pruebasFuncionales = [];

bool _datosInicializados = false;
bool get datosInicializados => _datosInicializados;

DateTime? _leerFecha(dynamic valor) {
  if (valor == null) return null;
  return DateTime.tryParse(valor.toString());
}

List<dynamic> _leerLista(String? contenido, String clave) {
  if (contenido == null || contenido.trim().isEmpty) {
    return <dynamic>[];
  }

  final decoded = jsonDecode(contenido);
  if (decoded is! List) {
    throw FormatException('El dato "$clave" no tiene formato de lista.');
  }
  return decoded;
}

String _idLegado(String inventario, String serie, int indice) {
  final clave = inventario.trim().isNotEmpty
      ? inventario.trim()
      : serie.trim().isNotEmpty
          ? serie.trim()
          : 'sin_codigo';

  final normalizada = clave.toLowerCase().replaceAll(
        RegExp(r'[^a-z0-9_-]'),
        '_',
      );

  return 'eq_legacy_${normalizada}_$indice';
}

String _resolverEquipoId(List<Equipo> lista, String inventario) {
  if (inventario.trim().isEmpty) return '';

  final coincidencias = lista.where(
    (equipo) => equipo.inventario.trim() == inventario.trim(),
  );

  // Solo asociar automáticamente cuando la coincidencia no es ambigua.
  return coincidencias.length == 1 ? coincidencias.first.id : '';
}

/// Guarda los datos estructurados y migra documentos Base64 antiguos.
///
/// El contenido Base64 solo se limpia de memoria después de que los
/// metadatos hayan quedado guardados correctamente.
Future<void> guardarDatos() async {
  if (!_datosInicializados) {
    throw StateError(
      'Los datos no se han cargado. No se permite sobrescribir el almacenamiento.',
    );
  }

  final prefs = await SharedPreferences.getInstance();

  for (var i = 0; i < documentos.length; i++) {
    final documento = documentos[i];

    if ((documento.almacenamientoId == null ||
            documento.almacenamientoId!.isEmpty) &&
        documento.contenidoBase64.trim().isNotEmpty) {
      final bytes = base64Decode(documento.contenidoBase64.trim());
      final id = 'doc_${DateTime.now().microsecondsSinceEpoch}_$i';

      await AlmacenDocumentos.guardar(id, bytes);
      documento.almacenamientoId = id;
    }
  }

  final equiposJson = equipos.map((equipo) {
    return {
      'id': equipo.id,
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

  final mantenimientosJson = mantenimientos.map((mantenimiento) {
    return {
      'equipoId': mantenimiento.equipoId,
      'equipoInventario': mantenimiento.equipoInventario,
      'tipo': mantenimiento.tipo,
      'tecnico': mantenimiento.tecnico,
      'descripcion': mantenimiento.descripcion,
      'fallas': mantenimiento.fallas,
      'repuestos': mantenimiento.repuestos,
      'resultado': mantenimiento.resultado,
      'observaciones': mantenimiento.observaciones,
      'fecha': mantenimiento.fecha.toIso8601String(),
      'fechaFalla': mantenimiento.fechaFalla?.toIso8601String(),
      'inicioReparacion':
          mantenimiento.inicioReparacion?.toIso8601String(),
      'finReparacion':
          mantenimiento.finReparacion?.toIso8601String(),
      'retornoOperacion': mantenimiento.retornoOperacion?.toIso8601String(),
    };
  }).toList();

  final pruebasJson = pruebasFuncionales.map((prueba) => {
    'id': prueba.id,
    'equipoId': prueba.equipoId,
    'equipoInventario': prueba.equipoInventario,
    'tecnico': prueba.tecnico,
    'fecha': prueba.fecha.toIso8601String(),
    'checklist': prueba.checklist,
    'observaciones': prueba.observaciones,
    'evidencias': prueba.evidencias.map((evidencia) => {
      'nombre': evidencia.nombre,
      'almacenamientoId': evidencia.almacenamientoId,
    }).toList(),
  }).toList();

  final documentosJson = documentos.map((documento) {
    return {
      'nombre': documento.nombre,
      'tipo': documento.tipo,
      'equipoId': documento.equipoId,
      'equipoInventario': documento.equipoInventario,
      'contenidoBase64': documento.almacenamientoId == null
          ? documento.contenidoBase64
          : '',
      'almacenamientoId': documento.almacenamientoId,
    };
  }).toList();

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
  final resultadoPruebas = await prefs.setString(
    'pruebasFuncionales',
    jsonEncode(pruebasJson),
  );

  if (!resultadoEquipos ||
      !resultadoMantenimientos ||
      !resultadoDocumentos ||
      !resultadoPruebas) {
    throw Exception('No se pudieron guardar todos los datos de Biomante.');
  }

  for (final documento in documentos) {
    if (documento.almacenamientoId != null) {
      documento.contenidoBase64 = '';
    }
  }
}

/// Carga los datos guardados y migra registros históricos a IDs internos.
///
/// Si el JSON está dañado, la función lanza el error y conserva las listas
/// actuales para evitar que un guardado posterior borre los datos originales.
Future<void> cargarDatos() async {
  final prefs = await SharedPreferences.getInstance();

  final datosEquipos = _leerLista(prefs.getString('equipos'), 'equipos');
  final datosMantenimientos = _leerLista(
    prefs.getString('mantenimientos'),
    'mantenimientos',
  );
  final datosDocumentos = _leerLista(
    prefs.getString('documentos'),
    'documentos',
  );
  final datosPruebas = _leerLista(
    prefs.getString('pruebasFuncionales'),
    'pruebas funcionales',
  );

  final equiposNuevos = datosEquipos.asMap().entries.map((entrada) {
    final dato = Map<String, dynamic>.from(entrada.value as Map);
    final inventario = dato['inventario']?.toString() ?? '';
    final serie = dato['serie']?.toString() ?? '';

    return Equipo(
      id: dato['id']?.toString() ??
          _idLegado(inventario, serie, entrada.key),
      nombre: dato['nombre']?.toString() ?? '',
      marca: dato['marca']?.toString() ?? '',
      modelo: dato['modelo']?.toString() ?? '',
      serie: serie,
      inventario: inventario,
      ubicacion: dato['ubicacion']?.toString() ?? '',
      estado: dato['estado']?.toString() ?? 'Operativo',
      ultimoMantenimiento: _leerFecha(dato['ultimoMantenimiento']),
      proximoMantenimiento: _leerFecha(dato['proximoMantenimiento']),
    );
  }).toList();

  final mantenimientosNuevos = datosMantenimientos.map((elemento) {
    final dato = Map<String, dynamic>.from(elemento as Map);
    final inventario = dato['equipoInventario']?.toString() ?? '';
    final equipoIdGuardado = dato['equipoId']?.toString() ?? '';

    return Mantenimiento(
      equipoId: equipoIdGuardado.isNotEmpty
          ? equipoIdGuardado
          : _resolverEquipoId(equiposNuevos, inventario),
      equipoInventario: inventario,
      tipo: dato['tipo']?.toString() ?? '',
      tecnico: dato['tecnico']?.toString() ?? '',
      descripcion: dato['descripcion']?.toString() ?? '',
      fallas: dato['fallas']?.toString() ?? '',
      repuestos: dato['repuestos']?.toString() ?? '',
      resultado: dato['resultado']?.toString() ?? '',
      observaciones: dato['observaciones']?.toString() ?? '',
      fecha: _leerFecha(dato['fecha']) ?? DateTime.now(),
      fechaFalla: _leerFecha(dato['fechaFalla']),
      inicioReparacion: _leerFecha(dato['inicioReparacion']),
      finReparacion: _leerFecha(dato['finReparacion']),
      retornoOperacion: _leerFecha(dato['retornoOperacion']),
    );
  }).toList();

  final documentosNuevos = datosDocumentos.map((elemento) {
    final dato = Map<String, dynamic>.from(elemento as Map);
    final inventario = dato['equipoInventario']?.toString() ?? '';
    final equipoIdGuardado = dato['equipoId']?.toString() ?? '';

    return Documento(
      nombre: dato['nombre']?.toString() ?? '',
      tipo: dato['tipo']?.toString() ?? '',
      equipoId: equipoIdGuardado.isNotEmpty
          ? equipoIdGuardado
          : _resolverEquipoId(equiposNuevos, inventario),
      equipoInventario: inventario,
      contenidoBase64: dato['contenidoBase64']?.toString() ?? '',
      almacenamientoId: dato['almacenamientoId']?.toString(),
    );
  }).toList();

  final pruebasNuevas = datosPruebas.map((elemento) {
    final dato = Map<String, dynamic>.from(elemento as Map);
    final checklistDato = dato['checklist'];
    final checklist = checklistDato is Map
        ? checklistDato.map((key, value) => MapEntry(key.toString(), value.toString()))
        : <String, String>{};
    final evidenciasDato = dato['evidencias'];
    final evidencias = evidenciasDato is List
        ? evidenciasDato.map((elementoEvidencia) {
            final evidencia = Map<String, dynamic>.from(elementoEvidencia as Map);
            return EvidenciaFuncional(
              nombre: evidencia['nombre']?.toString() ?? 'Evidencia',
              almacenamientoId: evidencia['almacenamientoId']?.toString() ?? '',
            );
          }).toList()
        : <EvidenciaFuncional>[];

    return PruebaFuncional(
      id: dato['id']?.toString(),
      equipoId: dato['equipoId']?.toString() ?? '',
      equipoInventario: dato['equipoInventario']?.toString() ?? '',
      tecnico: dato['tecnico']?.toString() ?? '',
      fecha: _leerFecha(dato['fecha']) ?? DateTime.now(),
      checklist: checklist,
      observaciones: dato['observaciones']?.toString() ?? '',
      evidencias: evidencias,
    );
  }).toList();

  equipos = equiposNuevos;
  mantenimientos = mantenimientosNuevos;
  documentos = documentosNuevos;
  pruebasFuncionales = pruebasNuevas;
  _datosInicializados = true;

  final hayMigraciones = documentos.any(
    (documento) =>
        (documento.almacenamientoId == null ||
            documento.almacenamientoId!.isEmpty) &&
        documento.contenidoBase64.trim().isNotEmpty,
  );

  if (hayMigraciones) {
    await guardarDatos();
  }
}
