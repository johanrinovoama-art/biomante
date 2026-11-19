import 'package:flutter/material.dart';
import 'registrar_equipo.dart';
import 'equipos.dart';
import 'datos.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await cargarDatos();

  runApp(const BiomanteApp());
}

class BiomanteApp extends StatelessWidget {
  const BiomanteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Biomante',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const InicioPage(),
    );
  }
}

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> actualizarDatos() async {
    await cargarDatos();

    if (mounted) {
      setState(() {});
    }
  }

  int calcularPendientes() {
    final hoy = DateTime.now();

    return equipos.where((equipo) {
      if (equipo.proximoMantenimiento == null) {
        return false;
      }

      final fechaHoy = DateTime(
        hoy.year,
        hoy.month,
        hoy.day,
      );

      final fechaMantenimiento = DateTime(
        equipo.proximoMantenimiento!.year,
        equipo.proximoMantenimiento!.month,
        equipo.proximoMantenimiento!.day,
      );

      final diferencia =
          fechaMantenimiento.difference(fechaHoy).inDays;

      return diferencia >= 0 && diferencia <= 30;
    }).length;
  }

  int calcularVencidos() {
    final hoy = DateTime.now();

    return equipos.where((equipo) {
      if (equipo.proximoMantenimiento == null) {
        return false;
      }

      final fechaHoy = DateTime(
        hoy.year,
        hoy.month,
        hoy.day,
      );

      final fechaMantenimiento = DateTime(
        equipo.proximoMantenimiento!.year,
        equipo.proximoMantenimiento!.month,
        equipo.proximoMantenimiento!.day,
      );

      final diferencia =
          fechaMantenimiento.difference(fechaHoy).inDays;

      return diferencia < 0;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final totalEquipos = equipos.length;
    final totalRealizados = mantenimientos.length;
    final totalPendientes = calcularPendientes();
    final totalVencidos = calcularVencidos();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Biomante',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: actualizarDatos,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: actualizarDatos,

        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const Text(
                'Panel principal',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Sistema de mantenimiento biomédico',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: _CardResumen(
                      titulo: 'Equipos',
                      valor: totalEquipos.toString(),
                      icono: Icons.medical_services,
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: _CardResumen(
                      titulo: 'Pendientes',
                      valor: totalPendientes.toString(),
                      icono: Icons.build,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: _CardResumen(
                      titulo: 'Vencidos',
                      valor: totalVencidos.toString(),
                      icono: Icons.warning,
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: _CardResumen(
                      titulo: 'Realizados',
                      valor: totalRealizados.toString(),
                      icono: Icons.check_circle,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const EquiposPage(),
                      ),
                    );

                    await actualizarDatos();
                  },
                  icon: const Icon(
                    Icons.medical_services,
                  ),
                  label: const Text(
                    'Ver mis equipos',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(18),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              _BotonAccion(
                icono: Icons.add,
                texto: 'Registrar equipo',
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const RegistrarEquipoPage(),
                    ),
                  );

                  await actualizarDatos();
                },
              ),

              const SizedBox(height: 10),

              _BotonAccion(
                icono: Icons.build,
                texto: 'Registrar mantenimiento',
                onPressed: () async {
                  if (equipos.isEmpty) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Primero debes registrar un equipo',
                        ),
                      ),
                    );
                    return;
                  }

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const EquiposPage(),
                    ),
                  );

                  await actualizarDatos();
                },
              ),

              const SizedBox(height: 10),

              _BotonAccion(
                icono: Icons.history,
                texto: 'Ver historial',
                onPressed: () async {
                  if (equipos.isEmpty) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'No hay equipos registrados',
                        ),
                      ),
                    );
                    return;
                  }

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const EquiposPage(),
                    ),
                  );

                  await actualizarDatos();
                },
              ),

              const SizedBox(height: 25),

              // INFORMACIÓN DEL SISTEMA
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),

                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 28,
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          'Biomante permite gestionar equipos '
                          'biomédicos, registrar mantenimientos, '
                          'consultar historiales y acceder a '
                          'la documentación técnica.',
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
      ),
    );
  }
}

class _CardResumen extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;

  const _CardResumen({
    required this.titulo,
    required this.valor,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          children: [
            Icon(
              icono,
              size: 35,
            ),

            const SizedBox(height: 10),

            Text(
              valor,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              titulo,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BotonAccion extends StatelessWidget {
  final IconData icono;
  final String texto;
  final VoidCallback onPressed;

  const _BotonAccion({
    required this.icono,
    required this.texto,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,

      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icono),
        label: Text(texto),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(18),
        ),
      ),
    );
  }
}

