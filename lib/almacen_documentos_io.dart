import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

Future<Database> abrirBaseDocumentos() async {
  final directorio = await getApplicationSupportDirectory();
  await directorio.create(recursive: true);

  final ruta = p.join(directorio.path, 'biomante_documentos.db');
  return databaseFactoryIo.openDatabase(ruta);
}
