import 'package:flutter/material.dart';
import 'equipo.dart';
import 'datos.dart';
import 'mantenimiento_modelo.dart';

class MantenimientoPage extends StatefulWidget {
  final Equipo equipo;

  const MantenimientoPage({
    super.key,
    required this.equipo,
  });

  @override
  State<MantenimientoPage> createState() => _MantenimientoPageState();
}

class _MantenimientoPageState extends State<MantenimientoPage> {
  final tecnicoController = TextEditingController();
  final descripcionController = TextEditingController();
  final fallasController = TextEditingController();
  final repuestosController = TextEditingController();
  final observacionesController = TextEditingController();

  String tipoMantenimiento = 'Preventivo';
  String resultado = 'Equipo operativo';

  DateTime? proximoMantenimiento;

  @override
  void dispose() {
    tecnicoController.dispose();
    descripcionController.dispose();
    fallasController.dispose();
    repuestosController.dispose();
    observacionesController.dispose();
    super.dispose();
  }

  Future<void> seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(
        const Duration(days: 30),
      ),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (fecha != null) {
      setState(() {
        proximoMantenimiento = fecha;
      });
    }
  }

  String mostrarFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
  }

  Future<void> guardarMantenimiento() async {
    if (tecnicoController.text.isEmpty ||
        descripcionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa los campos obligatorios'),
        ),
      );
      return;
    }

    final nuevoMantenimiento = Mantenimiento(
      equipoInventario: widget.equipo.inventario,
      tipo: tipoMantenimiento,
      tecnico: tecnicoController.text,
      descripcion: descripcionController.text,
      fallas: fallasController.text,
      repuestos: repuestosController.text,
      resultado: resultado,
      observaciones: observacionesController.text,
      fecha: DateTime.now(),
    );

    mantenimientos.add(nuevoMantenimiento);

    // Actualizar las fechas del equipo
    widget.equipo.ultimoMantenimiento = DateTime.now();
    widget.equipo.proximoMantenimiento = proximoMantenimiento;

    // Guardar equipos y mantenimientos permanentemente
    await guardarDatos();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Mantenimiento registrado y guardado correctamente',
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar mantenimiento'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.equipo.nombre,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              '${widget.equipo.marca} • ${widget.equipo.modelo}',
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 25),

            DropdownButtonFormField<String>(
              initialValue: tipoMantenimiento,
              decoration: const InputDecoration(
                labelText: 'Tipo de mantenimiento',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.build),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Preventivo',
                  child: Text('Preventivo'),
                ),
                DropdownMenuItem(
                  value: 'Correctivo',
                  child: Text('Correctivo'),
                ),
              ],
              onChanged: (valor) {
                setState(() {
                  tipoMantenimiento = valor!;
                });
              },
            ),

            const SizedBox(height: 15),

            TextField(
              controller: tecnicoController,
              decoration: const InputDecoration(
                labelText: 'Técnico responsable *',
                hintText: 'Nombre del técnico',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: descripcionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Trabajo realizado *',
                hintText: 'Describe las actividades realizadas',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: fallasController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Fallas encontradas',
                hintText: 'Describe las fallas encontradas',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.warning),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: repuestosController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Repuestos utilizados',
                hintText: 'Indica los repuestos utilizados',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.settings),
              ),
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              initialValue: resultado,
              decoration: const InputDecoration(
                labelText: 'Resultado',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.check_circle),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Equipo operativo',
                  child: Text('Equipo operativo'),
                ),
                DropdownMenuItem(
                  value: 'Equipo parcialmente operativo',
                  child: Text('Equipo parcialmente operativo'),
                ),
                DropdownMenuItem(
                  value: 'Equipo fuera de servicio',
                  child: Text('Equipo fuera de servicio'),
                ),
              ],
              onChanged: (valor) {
                setState(() {
                  resultado = valor!;
                });
              },
            ),

            const SizedBox(height: 15),

            TextField(
              controller: observacionesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Observaciones',
                hintText: 'Observaciones adicionales',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_month),
                title: const Text(
                  'Próximo mantenimiento',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  proximoMantenimiento == null
                      ? 'No programado'
                      : mostrarFecha(proximoMantenimiento!),
                ),
                trailing: const Icon(Icons.edit_calendar),
                onTap: seleccionarFecha,
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: guardarMantenimiento,
                icon: const Icon(Icons.save),
                label: const Text(
                  'Guardar mantenimiento',
                  style: TextStyle(fontSize: 16),
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