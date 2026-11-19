import 'package:flutter/material.dart';

import 'datos.dart';
import 'equipos.dart';
import 'registrar_equipo.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await cargarDatos();
    runApp(const BiomanteApp());
  } catch (error, stackTrace) {
    debugPrint('No se pudieron cargar los datos de Biomante: $error');
    debugPrintStack(stackTrace: stackTrace);
    runApp(BiomanteErrorApp(error: error.toString()));
  }
}

class BiomanteApp extends StatelessWidget {
  const BiomanteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Biomante',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const InicioPage(),
    );
  }
}

class BiomanteErrorApp extends StatelessWidget {
  final String error;

  const BiomanteErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Biomante',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('Biomante')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.storage_rounded, size: 56),
                const SizedBox(height: 16),
                const Text(
                  'No se pudieron cargar los datos locales',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(error, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                const Text(
                  'No hemos sobrescrito los datos. Revisa el almacenamiento y vuelve a iniciar la aplicación.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  Future<void> actualizarDatos() async {
    try {
      await cargarDatos();
      if (mounted) setState(() {});
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudieron actualizar los datos: $error')),
      );
    }
  }

  int calcularPendientes() {
    final hoy = DateTime.now();
    final fechaHoy = DateTime(hoy.year, hoy.month, hoy.day);

    return equipos.where((equipo) {
      final proximo = equipo.proximoMantenimiento;
      if (proximo == null) return false;

      final fecha = DateTime(proximo.year, proximo.month, proximo.day);
      final diferencia = fecha.difference(fechaHoy).inDays;
      return diferencia >= 0 && diferencia <= 30;
    }).length;
  }

  int calcularVencidos() {
    final hoy = DateTime.now();
    final fechaHoy = DateTime(hoy.year, hoy.month, hoy.day);

    return equipos.where((equipo) {
      final proximo = equipo.proximoMantenimiento;
      if (proximo == null) return false;

      final fecha = DateTime(proximo.year, proximo.month, proximo.day);
      return fecha.difference(fechaHoy).inDays < 0;
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
          style: TextStyle(fontWeight: FontWeight.bold),
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
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sistema de mantenimiento biomédico',
                style: TextStyle(fontSize: 16, color: Colors.grey),
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
                        builder: (context) => const EquiposPage(),
                      ),
                    );
                    await actualizarDatos();
                  },
                  icon: const Icon(Icons.medical_services),
                  label: const Text('Ver mis equipos'),
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
                      builder: (context) => const RegistrarEquipoPage(),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Primero debes registrar un equipo'),
                      ),
                    );
                    return;
                  }
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EquiposPage(),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No hay equipos registrados'),
                      ),
                    );
                    return;
                  }
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EquiposPage(),
                    ),
                  );
                  await actualizarDatos();
                },
              ),
              const SizedBox(height: 25),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Biomante permite gestionar equipos biomédicos, '
                          'registrar mantenimientos, consultar historiales '
                          'y acceder a la documentación técnica.',
                          style: TextStyle(color: Colors.grey.shade700),
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
            Icon(icono, size: 35),
            const SizedBox(height: 10),
            Text(
              valor,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(titulo, style: const TextStyle(fontSize: 14)),
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
