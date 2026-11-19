import 'dart:convert';

import 'package:http/http.dart' as http;

/// Cliente del backend de Biomante.
///
/// La URL se inyecta al compilar. La clave privada del proveedor solo vive
/// en el servidor y nunca se incluye en el código Flutter.
class AsistenteIaService {
  static const String endpoint = String.fromEnvironment(
    'BIOMANTE_AI_ENDPOINT',
    defaultValue: '',
  );

  static bool get configurado => endpoint.trim().isNotEmpty;

  static Future<String?> responder({
    required String contextoEquipo,
    required String pregunta,
  }) async {
    if (!configurado) return null;

    final uri = Uri.tryParse(endpoint);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw const FormatException('BIOMANTE_AI_ENDPOINT no es una URL válida.');
    }

    final response = await http
        .post(
          uri,
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contextoEquipo': contextoEquipo,
            'pregunta': pregunta,
          }),
        )
        .timeout(const Duration(seconds: 35));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('El servidor de IA respondió HTTP ${response.statusCode}.');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const FormatException('Respuesta del servidor de IA no válida.');
    }

    final respuesta = decoded['respuesta']?.toString().trim();
    if (respuesta == null || respuesta.isEmpty) {
      throw const FormatException('El servidor de IA no devolvió texto.');
    }

    return respuesta;
  }
}
