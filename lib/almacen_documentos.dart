import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';

/// Almacenamiento persistente de PDF.
///
/// Web: IndexedDB.
/// Android/iOS/escritorio: archivo Sembast en el directorio privado de la app.
class AlmacenDocumentos {
  static Database? _database;
  static Future<Database>? _databaseFuture;

  static final StoreRef<String, Map<String, Object?>> _store =
      StoreRef<String, Map<String, Object?>>.main();

  static Future<Database> _abrir() {
    if (_database != null) {
      return Future.value(_database);
    }

    return _databaseFuture ??= _abrirInterno().then((db) {
      _database = db;
      return db;
    }).catchError((Object error) {
      _databaseFuture = null;
      throw error;
    });
  }

  static Future<Database> _abrirInterno() async {
    if (kIsWeb) {
      return databaseFactoryWeb.openDatabase(
        'biomante_documentos.db',
      );
    }

    final directorio = await getApplicationSupportDirectory();
    await directorio.create(recursive: true);

    final ruta = p.join(
      directorio.path,
      'biomante_documentos.db',
    );

    return databaseFactoryIo.openDatabase(ruta);
  }

  static Future<void> guardar(
    String id,
    Uint8List bytes,
  ) async {
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

    if (registro == null) {
      return null;
    }

    final contenido = registro['bytes'];
    if (contenido is! List) {
      return null;
    }

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
