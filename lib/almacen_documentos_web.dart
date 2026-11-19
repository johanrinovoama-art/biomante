import 'package:sembast_web/sembast_web.dart';

Future<Database> abrirBaseDocumentos() {
  return databaseFactoryWeb.openDatabase('biomante_documentos.db');
}
