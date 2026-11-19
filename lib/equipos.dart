import 'package:flutter/material.dart';
import 'datos.dart';
import 'equipo.dart';
import 'detalle_equipo.dart';

class EquiposPage extends StatefulWidget {
  const EquiposPage({super.key});

  @override
  State<EquiposPage> createState() => _EquiposPageState();
}

class _EquiposPageState extends State<EquiposPage> {
  final TextEditingController busquedaController =
      TextEditingController();

  String busqueda = '';

  @override
  void dispose() {
    busquedaController.dispose();
    super.dispose();
  }

  List<Equipo> obtenerEquiposFiltrados() {
    if (busqueda.trim().isEmpty) {
      return equipos;
    }

    final texto = busqueda.toLowerCase().trim();

    return equipos.where((equipo) {
      return equipo.nombre.toLowerCase().contains(texto) ||
          equipo.marca.toLowerCase().contains(texto) ||
          equipo.modelo.toLowerCase().contains(texto) ||
          equipo.serie.toLowerCase().contains(texto) ||
          equipo.inventario.toLowerCase().contains(texto) ||
          equipo.ubicacion.toLowerCase().contains(texto) ||
          equipo.estado.toLowerCase().contains(texto);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final equiposFiltrados = obtenerEquiposFiltrados();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis equipos'),
      ),

      body: Column(
        children: [
          // BUSCADOR
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              8,
            ),
            child: TextField(
              controller: busquedaController,
              onChanged: (valor) {
                setState(() {
                  busqueda = valor;
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar equipo...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: busqueda.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          busquedaController.clear();

                          setState(() {
                            busqueda = '';
                          });
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
          ),

          // RESULTADOS
          Expanded(
            child: equipos.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.medical_services_outlined,
                          size: 70,
                        ),
                        SizedBox(height: 15),
                        Text(
                          'No hay equipos registrados',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Registra tu primer equipo biomédico',
                        ),
                      ],
                    ),
                  )
                : equiposFiltrados.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 70,
                            ),
                            SizedBox(height: 15),
                            Text(
                              'No se encontraron equipos',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Intenta con otro término de búsqueda',
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: equiposFiltrados.length,
                        itemBuilder: (context, index) {
                          final Equipo equipo =
                              equiposFiltrados[index];

                          return Card(
                            margin: const EdgeInsets.only(
                              bottom: 12,
                            ),
                            child: ListTile(
                              leading: const CircleAvatar(
                                child: Icon(
                                  Icons.medical_services,
                                ),
                              ),
                              title: Text(
                                equipo.nombre,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${equipo.marca} • '
                                '${equipo.modelo}\n'
                                'Inventario: '
                                '${equipo.inventario.isEmpty ? "No registrado" : equipo.inventario}\n'
                                'Ubicación: '
                                '${equipo.ubicacion.isEmpty ? "No registrada" : equipo.ubicacion}',
                              ),
                              isThreeLine: true,
                              trailing: const Icon(
                                Icons.chevron_right,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetalleEquipoPage(
                                      equipo: equipo,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

