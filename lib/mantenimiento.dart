import 'package:flutter/material.dart';

import 'datos.dart';
import 'equipo.dart';
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
  DateTime? fechaFalla;
  DateTime? inicioReparacion;
  DateTime? finReparacion;
  DateTime? retornoOperacion;
  bool guardando = false;

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
      initialDate: proximoMantenimiento ??
          DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (fecha != null && mounted) {
      setState(() => proximoMantenimiento = fecha);
    }
  }

  Future<DateTime?> seleccionarFechaHora(String titulo, DateTime? actual) async {
    final base = actual ?? DateTime.now();
    final fecha = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: titulo,
    );
    if (fecha == null || !mounted) return actual;

    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
      helpText: 'Hora: $titulo',
    );
    if (hora == null) return actual;

    return DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute);
  }

  Widget selectorFechaHora(String titulo, DateTime? valor, ValueChanged<DateTime?> onChanged) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(titulo),
      subtitle: Text(valor == null ? 'No registrada' : '${mostrarFecha(valor)} ${TimeOfDay.fromDateTime(valor).format(context)}'),
      trailing: const Icon(Icons.event),
      onTap: guardando
          ? null
          : () async {
              final nueva = await seleccionarFechaHora(titulo, valor);
              if (nueva != null && mounted) onChanged(nueva);
            },
    );
  }

  String mostrarFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
  }

  Future<void> guardarMantenimiento() async {
    if (guardando) return;

    if (tecnicoController.text.trim().isEmpty ||
        descripcionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa los campos obligatorios')),
      );
      return;
    }

    if (tipoMantenimiento == 'Correctivo') {
      if (inicioReparacion != null && finReparacion != null &&
          finReparacion!.isBefore(inicioReparacion!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El fin de reparación no puede ser anterior al inicio.')),
        );
        return;
      }
      if (inicioReparacion != null && retornoOperacion != null &&
          retornoOperacion!.isBefore(inicioReparacion!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El retorno a operación no puede ser anterior al inicio de reparación.')),
        );
        return;
      }
      if (fechaFalla != null && inicioReparacion != null &&
          inicioReparacion!.isBefore(fechaFalla!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El inicio de reparación no puede ser anterior a la fecha de falla.')),
        );
        return;
      }
    }

    final fechaRegistro = DateTime.now();
    final fechaAnterior = widget.equipo.ultimoMantenimiento;
    final proximaAnterior = widget.equipo.proximoMantenimiento;
    final estadoAnterior = widget.equipo.estado;

    final nuevoMantenimiento = Mantenimiento(
      equipoId: widget.equipo.id,
      equipoInventario: widget.equipo.inventario,
      tipo: tipoMantenimiento,
      tecnico: tecnicoController.text.trim(),
      descripcion: descripcionController.text.trim(),
      fallas: fallasController.text.trim(),
      repuestos: repuestosController.text.trim(),
      resultado: resultado,
      observaciones: observacionesController.text.trim(),
      fecha: fechaRegistro,
      fechaFalla: fechaFalla,
      inicioReparacion: inicioReparacion,
      finReparacion: finReparacion,
      retornoOperacion: retornoOperacion,
    );

    setState(() => guardando = true);
    mantenimientos.add(nuevoMantenimiento);
    widget.equipo.ultimoMantenimiento = fechaRegistro;

    if (proximoMantenimiento != null) {
      widget.equipo.proximoMantenimiento = proximoMantenimiento;
    }

    switch (resultado) {
      case 'Equipo operativo':
        widget.equipo.estado = 'Operativo';
        break;
      case 'Equipo parcialmente operativo':
        widget.equipo.estado = 'En mantenimiento';
        break;
      case 'Equipo fuera de servicio':
        widget.equipo.estado = 'Fuera de servicio';
        break;
    }

    try {
      await guardarDatos();
    } catch (error) {
      mantenimientos.remove(nuevoMantenimiento);
      widget.equipo.ultimoMantenimiento = fechaAnterior;
      widget.equipo.proximoMantenimiento = proximaAnterior;
      widget.equipo.estado = estadoAnterior;

      if (!mounted) return;
      setState(() => guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar el mantenimiento: $error')),
      );
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mantenimiento registrado y guardado correctamente'),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar mantenimiento')),
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
              style: const TextStyle(color: Colors.grey),
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
                DropdownMenuItem(value: 'Preventivo', child: Text('Preventivo')),
                DropdownMenuItem(value: 'Correctivo', child: Text('Correctivo')),
              ],
              onChanged: guardando
                  ? null
                  : (valor) {
                      if (valor != null) setState(() => tipoMantenimiento = valor);
                    },
            ),
            if (tipoMantenimiento == 'Correctivo') ...[
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tiempos de falla y reparación', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Text('Registra fecha y hora reales. Estos datos permiten calcular MTBF, MTTR y disponibilidad.', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      selectorFechaHora('Fecha y hora de la falla', fechaFalla, (v) => setState(() => fechaFalla = v)),
                      selectorFechaHora('Inicio de reparación', inicioReparacion, (v) => setState(() => inicioReparacion = v)),
                      selectorFechaHora('Fin de reparación', finReparacion, (v) => setState(() => finReparacion = v)),
                      selectorFechaHora('Retorno a operación', retornoOperacion, (v) => setState(() => retornoOperacion = v)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
            ],
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
                DropdownMenuItem(value: 'Equipo operativo', child: Text('Equipo operativo')),
                DropdownMenuItem(value: 'Equipo parcialmente operativo', child: Text('Equipo parcialmente operativo')),
                DropdownMenuItem(value: 'Equipo fuera de servicio', child: Text('Equipo fuera de servicio')),
              ],
              onChanged: guardando
                  ? null
                  : (valor) {
                      if (valor != null) setState(() => resultado = valor);
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
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  proximoMantenimiento == null
                      ? 'Sin cambios (conservar fecha actual)'
                      : mostrarFecha(proximoMantenimiento!),
                ),
                trailing: const Icon(Icons.edit_calendar),
                onTap: guardando ? null : seleccionarFecha,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: guardando ? null : guardarMantenimiento,
                icon: const Icon(Icons.save),
                label: Text(
                  guardando ? 'Guardando...' : 'Guardar mantenimiento',
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
