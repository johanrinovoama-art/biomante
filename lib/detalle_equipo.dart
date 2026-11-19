
import 'package:flutter/material.dart';
import 'equipo.dart';
import 'manuales.dart';
import 'mantenimiento.dart';
import 'historial.dart';
import 'pruebas_funcionales.dart';
import 'codigo_qr.dart';
import 'informe_tecnico.dart';

class DetalleEquipoPage extends StatelessWidget {
  final Equipo equipo;

  const DetalleEquipoPage({
    super.key,
    required this.equipo,
  });

  String obtenerEstadoMantenimiento() {
    if (equipo.proximoMantenimiento == null) {
      return 'Sin fecha programada';
    }

    final hoy = DateTime.now();
    final proximo = equipo.proximoMantenimiento!;

    final diferencia = proximo.difference(
      DateTime(hoy.year, hoy.month, hoy.day),
    ).inDays;

    if (diferencia < 0) {
      return 'Mantenimiento vencido';
    } else if (diferencia <= 30) {
      return 'Mantenimiento próximo';
    } else {
      return 'Mantenimiento al día';
    }
  }

  IconData obtenerIconoMantenimiento() {
    if (equipo.proximoMantenimiento == null) {
      return Icons.help_outline;
    }

    final hoy = DateTime.now();
    final proximo = equipo.proximoMantenimiento!;

    final diferencia = proximo.difference(
      DateTime(hoy.year, hoy.month, hoy.day),
    ).inDays;

    if (diferencia < 0) {
      return Icons.warning;
    } else if (diferencia <= 30) {
      return Icons.event;
    } else {
      return Icons.check_circle;
    }
  }

  String mostrarFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
  }

  Color obtenerColorEstado() {
    switch (equipo.estado) {
      case 'Operativo':
        return Colors.green;
      case 'En mantenimiento':
        return Colors.orange;
      case 'Fuera de servicio':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ficha del equipo'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ENCABEZADO DEL EQUIPO
            Center(
              child: CircleAvatar(
                radius: 50,
                child: Icon(
                  Icons.medical_services,
                  size: 50,
                ),
              ),
            ),

            const SizedBox(height: 15),

            Center(
              child: Text(
                equipo.nombre,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 5),

            Center(
              child: Text(
                '${equipo.marca} ${equipo.modelo}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ESTADO
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: obtenerColorEstado().withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 12,
                      color: obtenerColorEstado(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      equipo.estado,
                      style: TextStyle(
                        color: obtenerColorEstado(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Información del equipo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            _Dato(
              titulo: 'Marca',
              valor: equipo.marca,
              icono: Icons.business,
            ),

            _Dato(
              titulo: 'Modelo',
              valor: equipo.modelo,
              icono: Icons.devices,
            ),

            _Dato(
              titulo: 'Número de serie',
              valor: equipo.serie,
              icono: Icons.numbers,
            ),

            _Dato(
              titulo: 'Código de inventario',
              valor: equipo.inventario,
              icono: Icons.qr_code,
            ),

            _Dato(
              titulo: 'Ubicación',
              valor: equipo.ubicacion,
              icono: Icons.location_on,
            ),

            const SizedBox(height: 20),

            // MANTENIMIENTO
            const Text(
              'Mantenimiento',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: ListTile(
                leading: Icon(
                  obtenerIconoMantenimiento(),
                  size: 32,
                ),
                title: const Text(
                  'Estado del mantenimiento',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  obtenerEstadoMantenimiento(),
                ),
              ),
            ),

            const SizedBox(height: 10),

            if (equipo.ultimoMantenimiento != null)
              _Dato(
                titulo: 'Último mantenimiento',
                valor: mostrarFecha(
                  equipo.ultimoMantenimiento!,
                ),
                icono: Icons.history,
              ),

            if (equipo.proximoMantenimiento != null)
              _Dato(
                titulo: 'Próximo mantenimiento',
                valor: mostrarFecha(
                  equipo.proximoMantenimiento!,
                ),
                icono: Icons.calendar_month,
              ),

            const SizedBox(height: 25),

            // ACCIONES
            const Text(
              'Acciones',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MantenimientoPage(
                        equipo: equipo,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.build),
                label: const Text(
                  'Registrar mantenimiento',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(18),
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HistorialPage(
                        equipo: equipo,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.history),
                label: const Text(
                  'Ver historial',
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(18),
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ManualesPage(
                        equipo: equipo,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.menu_book),
                label: const Text(
                  'Manuales y documentación',
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(18),
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PruebasFuncionalesPage(equipo: equipo),
                    ),
                  );
                },
                icon: const Icon(Icons.fact_check),
                label: const Text('Pruebas funcionales y checklist'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(18)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CodigoQrEquipoPage(equipo: equipo),
                    ),
                  );
                },
                icon: const Icon(Icons.qr_code_2),
                label: const Text('Generar código QR'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(18)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InformeTecnicoPage(equipo: equipo),
                    ),
                  );
                },
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Generar informe técnico PDF'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(18)),
              ),
            ),
            const SizedBox(height: 25),

            // INFORMACIÓN FUTURA
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Desde esta ficha podrás consultar la información '
                        'del equipo, registrar mantenimientos, consultar '
                        'el historial y acceder a sus manuales y documentación.',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;

  const _Dato({
    required this.titulo,
    required this.valor,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),

      child: ListTile(
        leading: Icon(icono),

        title: Text(
          titulo,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),

        subtitle: Text(
          valor.isEmpty ? 'No registrado' : valor,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

