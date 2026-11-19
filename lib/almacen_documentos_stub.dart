import 'package:sembast/sembast.dart';

Future<Database> abrirBaseDocumentos() {
  return Future<Database>.error(
    UnsupportedError('El almacenamiento de documentos no está disponible en esta plataforma.'),
  );
}
