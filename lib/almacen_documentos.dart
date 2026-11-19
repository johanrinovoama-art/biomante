import 'dart:typed_data';

import 'package:sembast/sembast.dart';

import 'almacen_documentos_stub.dart'
    if (dart.library.html) 'almacen_documentos_web.dart'
    if (dart.library.io) 'almacen_documentos_io.dart' as plataforma;

/// Almacenamiento persistente de documentos.
///
/// La implementación se selecciona en compilación para evitar importar
/// dart:io dentro de una compilación web.
class AlmacenDocumentos {
  static Database? _database;
  static Future<Database>? _databaseFuture;

  static final StoreRef<String, Map<String, Object?>> _store =
      StoreRef<String, Map<String, Object?>>.main();

  static Future<Database> _abrir() {
    if (_database != null) {
      return Future.value(_database);
    }

    return _databaseFuture ??= plataforma.abrirBaseDocumentos().then((db) {
      _database = db;
      return db;
    }).catchError((Object error) {
      _databaseFuture = null;
      throw error;
    });
  }

  static Future<void> guardar(String id, Uint8List bytes) async {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'No puede estar vacío');
    }

    final db = await _abrir();
    await _store.record(id).put(db, {
      'bytes': bytes.toList(growable: false),
    });
  }

  static Future<Uint8List?> leer(String id) async {
    final db = await _abrir();
    final registro = await _store.record(id).get(db);
    if (registro == null) return null;

    final contenido = registro['bytes'];
    if (contenido is! List) return null;

    try {
      return Uint8List.fromList(
        contenido.map((valor) => (valor as num).toInt()).toList(),
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> eliminar(String id) async {
    final db = await _abrir();
    await _store.record(id).delete(db);
  }
}
