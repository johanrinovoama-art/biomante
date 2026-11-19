
import 'dart:typed_data';

import 'package:sembast/sembast.dart';
import 'package:sembast_web/sembast_web.dart';

class AlmacenDocumentos {
  static Database? _database;

  static final StoreRef<String, Map<String, Object?>> _store =
      StoreRef<String, Map<String, Object?>>.main();

  static Future<Database> _abrir() async {
    if (_database != null) {
      return _database!;
    }

    _database = await databaseFactoryWeb.openDatabase(
      'biomante_documentos.db',
    );

    return _database!;
  }

  static Future<void> guardar(
    String id,
    Uint8List bytes,
  ) async {
    final db = await _abrir();

    await _store.record(id).put(db, {
      'bytes': bytes.toList(),
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

    return Uint8List.fromList(
      contenido.cast<int>(),
    );
  }

  static Future<void> eliminar(String id) async {
    final db = await _abrir();

    await _store.record(id).delete(db);
  }
}
