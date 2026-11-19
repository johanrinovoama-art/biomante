import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'datos.dart';
import 'equipo.dart';

class CodigoQrEquipoPage extends StatelessWidget {
  final Equipo equipo;

  const CodigoQrEquipoPage({super.key, required this.equipo});

  @override
  Widget build(BuildContext context) {
    final contenido = 'BIOMANTE:${equipo.id}';

    return Scaffold(
      appBar: AppBar(title: const Text('Código QR del equipo')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                equipo.nombre,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text('Inventario: ${equipo.inventario.isEmpty ? "No registrado" : equipo.inventario}'),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(18),
                color: Colors.white,
                child: QrImageView(
                  data: contenido,
                  version: QrVersions.auto,
                  size: 250,
                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                ),
              ),
              const SizedBox(height: 16),
              const Text('Este código identifica el equipo dentro de Biomante.', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: contenido));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Identificador copiado.')),
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copiar identificador'),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  final id = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(builder: (_) => const EscanerQrPage()),
                  );
                  if (id == null || !context.mounted) return;
                  final coincide = equipos.where((item) => item.id == id);
                  if (coincide.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('El QR no corresponde a un equipo registrado.')),
                    );
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Equipo identificado: ${coincide.first.nombre}'),
                    ),
                  );
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Probar lector QR'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EscanerQrPage extends StatefulWidget {
  const EscanerQrPage({super.key});

  @override
  State<EscanerQrPage> createState() => _EscanerQrPageState();
}

class _EscanerQrPageState extends State<EscanerQrPage> {
  bool procesado = false;
  final MobileScannerController controller = MobileScannerController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void detectar(BarcodeCapture captura) {
    if (procesado) return;

    for (final codigo in captura.barcodes) {
      final valor = codigo.rawValue;
      if (valor == null || !valor.startsWith('BIOMANTE:')) continue;

      final id = valor.substring('BIOMANTE:'.length);
      final existe = equipos.any((equipo) => equipo.id == id);
      if (!existe) continue;

      procesado = true;
      Navigator.of(context).pop(id);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear equipo')),
      body: Stack(
        children: [
          MobileScanner(controller: controller, onDetect: detectar),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.black54,
              child: const Text(
                'Centra el código QR de Biomante dentro del área de lectura.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
