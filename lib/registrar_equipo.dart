import 'package:flutter/material.dart';
import 'equipo.dart';
import 'datos.dart';

class RegistrarEquipoPage extends StatefulWidget {
  const RegistrarEquipoPage({super.key});

  @override
  State<RegistrarEquipoPage> createState() =>
      _RegistrarEquipoPageState();
}

class _RegistrarEquipoPageState
    extends State<RegistrarEquipoPage> {
  final nombreController = TextEditingController();
  final marcaController = TextEditingController();
  final modeloController = TextEditingController();
  final serieController = TextEditingController();
  final inventarioController = TextEditingController();
  final ubicacionController = TextEditingController();

  String estado = 'Operativo';

  @override
  void dispose() {
    nombreController.dispose();
    marcaController.dispose();
    modeloController.dispose();
    serieController.dispose();
    inventarioController.dispose();
    ubicacionController.dispose();
    super.dispose();
  }

  Future<void> guardarEquipo() async {
    if (nombreController.text.trim().isEmpty ||
        marcaController.text.trim().isEmpty ||
        modeloController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Completa los campos obligatorios',
          ),
        ),
      );
      return;
    }

    final nuevoEquipo = Equipo(
      nombre: nombreController.text.trim(),
      marca: marcaController.text.trim(),
      modelo: modeloController.text.trim(),
      serie: serieController.text.trim(),
      inventario: inventarioController.text.trim(),
      ubicacion: ubicacionController.text.trim(),
      estado: estado,
    );

    equipos.add(nuevoEquipo);

    // Guardar permanentemente
    await guardarDatos();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Equipo registrado y guardado correctamente',
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar equipo'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'Información del equipo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del equipo *',
                hintText:
                    'Ej: Monitor de signos vitales',
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.medical_services,
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: marcaController,
              decoration: const InputDecoration(
                labelText: 'Marca *',
                hintText: 'Ej: Mindray',
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.business,
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: modeloController,
              decoration: const InputDecoration(
                labelText: 'Modelo *',
                hintText: 'Ej: uMEC12',
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.devices,
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: serieController,
              decoration: const InputDecoration(
                labelText: 'Número de serie',
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.numbers,
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: inventarioController,
              decoration: const InputDecoration(
                labelText: 'Código de inventario',
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.qr_code,
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: ubicacionController,
              decoration: const InputDecoration(
                labelText: 'Ubicación',
                hintText: 'Ej: UCI - Piso 3',
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.location_on,
                ),
              ),
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              initialValue: estado,

              decoration: const InputDecoration(
                labelText: 'Estado del equipo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.health_and_safety,
                ),
              ),

              items: const [
                DropdownMenuItem(
                  value: 'Operativo',
                  child: Text('Operativo'),
                ),
                DropdownMenuItem(
                  value: 'En mantenimiento',
                  child: Text(
                    'En mantenimiento',
                  ),
                ),
                DropdownMenuItem(
                  value: 'Fuera de servicio',
                  child: Text(
                    'Fuera de servicio',
                  ),
                ),
              ],

              onChanged: (valor) {
                if (valor == null) return;

                setState(() {
                  estado = valor;
                });
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed: guardarEquipo,

                icon: const Icon(
                  Icons.save,
                ),

                label: const Text(
                  'Guardar equipo',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),

                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}