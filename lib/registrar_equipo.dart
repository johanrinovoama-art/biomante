import 'package:flutter/material.dart';

import 'datos.dart';
import 'equipo.dart';

class RegistrarEquipoPage extends StatefulWidget {
  const RegistrarEquipoPage({super.key});

  @override
  State<RegistrarEquipoPage> createState() => _RegistrarEquipoPageState();
}

class _RegistrarEquipoPageState extends State<RegistrarEquipoPage> {
  final nombreController = TextEditingController();
  final marcaController = TextEditingController();
  final modeloController = TextEditingController();
  final serieController = TextEditingController();
  final inventarioController = TextEditingController();
  final ubicacionController = TextEditingController();

  String estado = 'Operativo';
  bool guardando = false;

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
    if (guardando) return;

    final nombre = nombreController.text.trim();
    final marca = marcaController.text.trim();
    final modelo = modeloController.text.trim();
    final serie = serieController.text.trim();
    final inventario = inventarioController.text.trim();

    if (nombre.isEmpty || marca.isEmpty || modelo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa los campos obligatorios')),
      );
      return;
    }

    if (inventario.isNotEmpty &&
        equipos.any(
          (equipo) =>
              equipo.inventario.trim().toLowerCase() ==
              inventario.toLowerCase(),
        )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ya existe un equipo con ese código de inventario.'),
        ),
      );
      return;
    }

    if (serie.isNotEmpty &&
        equipos.any(
          (equipo) =>
              equipo.serie.trim().toLowerCase() == serie.toLowerCase(),
        )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ya existe un equipo con ese número de serie.'),
        ),
      );
      return;
    }

    final nuevoEquipo = Equipo(
      nombre: nombre,
      marca: marca,
      modelo: modelo,
      serie: serie,
      inventario: inventario,
      ubicacion: ubicacionController.text.trim(),
      estado: estado,
    );

    setState(() => guardando = true);
    equipos.add(nuevoEquipo);

    try {
      await guardarDatos();
    } catch (error) {
      equipos.remove(nuevoEquipo);
      if (!mounted) return;
      setState(() => guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar el equipo: $error')),
      );
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Equipo registrado y guardado correctamente')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar equipo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información del equipo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del equipo *',
                hintText: 'Ej: Monitor de signos vitales',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medical_services),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: marcaController,
              decoration: const InputDecoration(
                labelText: 'Marca *',
                hintText: 'Ej: Mindray',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: modeloController,
              decoration: const InputDecoration(
                labelText: 'Modelo *',
                hintText: 'Ej: uMEC12',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.devices),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: serieController,
              decoration: const InputDecoration(
                labelText: 'Número de serie',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: inventarioController,
              decoration: const InputDecoration(
                labelText: 'Código de inventario',
                helperText: 'Debe ser único cuando se registre.',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: ubicacionController,
              decoration: const InputDecoration(
                labelText: 'Ubicación',
                hintText: 'Ej: UCI - Piso 3',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              initialValue: estado,
              decoration: const InputDecoration(
                labelText: 'Estado del equipo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.health_and_safety),
              ),
              items: const [
                DropdownMenuItem(value: 'Operativo', child: Text('Operativo')),
                DropdownMenuItem(value: 'En mantenimiento', child: Text('En mantenimiento')),
                DropdownMenuItem(value: 'Fuera de servicio', child: Text('Fuera de servicio')),
              ],
              onChanged: guardando
                  ? null
                  : (valor) {
                      if (valor != null) setState(() => estado = valor);
                    },
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: guardando ? null : guardarEquipo,
                icon: const Icon(Icons.save),
                label: Text(guardando ? 'Guardando...' : 'Guardar equipo'),
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
