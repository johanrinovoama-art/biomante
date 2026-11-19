import 'package:flutter/material.dart';
import 'equipo.dart';

class AsistenteTecnicoPage extends StatefulWidget {
  final Equipo equipo;

  const AsistenteTecnicoPage({
    super.key,
    required this.equipo,
  });

  @override
  State<AsistenteTecnicoPage> createState() =>
      _AsistenteTecnicoPageState();
}

class _AsistenteTecnicoPageState
    extends State<AsistenteTecnicoPage> {
  final TextEditingController controlador =
      TextEditingController();

  final List<Map<String, String>> mensajes = [];

  void enviarPregunta() {
    final pregunta = controlador.text.trim();

    if (pregunta.isEmpty) {
      return;
    }

    setState(() {
      mensajes.add({
        'tipo': 'usuario',
        'texto': pregunta,
      });

      mensajes.add({
        'tipo': 'asistente',
        'texto': generarRespuesta(pregunta),
      });
    });

    controlador.clear();
  }

  String generarRespuesta(String pregunta) {
    final texto = pregunta.toLowerCase();

    if (texto.contains('no enciende') ||
        texto.contains('no prende')) {
      return '''
Posibles causas:

• Problema de alimentación eléctrica.
• Cable de alimentación desconectado o defectuoso.
• Fusible o protección interna activada.
• Falla en la fuente de alimentación.

Qué revisar:

1. Verificar que el equipo esté conectado.
2. Comprobar la alimentación eléctrica.
3. Revisar el cable y el interruptor.
4. Consultar el procedimiento técnico del fabricante.

⚠️ No intervenir componentes internos con el equipo energizado.
''';
    }

    if (texto.contains('no emite luz') ||
        texto.contains('no da luz') ||
        texto.contains('luz')) {
      return '''
Posibles causas:

• Fuente de luz o módulo LED defectuoso.
• Conexión interna suelta.
• Falla del controlador de iluminación.
• Problema en la alimentación del módulo de luz.

Qué revisar:

1. Confirmar que el equipo encienda correctamente.
2. Revisar los indicadores del equipo.
3. Verificar las conexiones correspondientes.
4. Consultar el manual de servicio antes de realizar una intervención.

⚠️ Si se requiere abrir el equipo, debe realizarse con el equipo desconectado y siguiendo el procedimiento técnico.
''';
    }

    if (texto.contains('temperatura') ||
        texto.contains('calienta')) {
      return '''
Posibles causas:

• Sistema de control de temperatura con anomalía.
• Sensor de temperatura defectuoso.
• Ventilación insuficiente.
• Problema en el sistema electrónico de control.

Se recomienda verificar primero las condiciones de operación y los indicadores del equipo.

⚠️ No realizar mediciones internas sin conocer el procedimiento de seguridad correspondiente.
''';
    }

    if (texto.contains('mantenimiento')) {
      return '''
Para realizar mantenimiento preventivo se recomienda:

• Inspección visual.
• Limpieza del equipo.
• Revisión de conexiones.
• Verificación de componentes.
• Comprobación de funcionamiento.
• Registro de las actividades realizadas.

Consulta siempre el manual de servicio específico del equipo antes de intervenirlo.
''';
    }

    return '''
Para el equipo ${widget.equipo.marca} ${widget.equipo.modelo}, necesito más información para orientar el diagnóstico.

Puedes describir:

• Qué está haciendo el equipo.
• Qué debería hacer.
• Si presenta algún mensaje o código de error.
• Si el problema apareció de repente o después de un mantenimiento.

Con esos datos puedo ayudarte a establecer posibles causas, comprobaciones y una solución recomendada.

⚠️ Antes de intervenir el equipo, aplica las medidas de seguridad correspondientes.
''';
  }

  @override
  void dispose() {
    controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistente técnico'),
      ),

      body: Column(
        children: [
          // INFORMACIÓN DEL EQUIPO
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                const CircleAvatar(
                  child: Icon(Icons.medical_services),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Equipo seleccionado',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        widget.equipo.nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      Text(
                        '${widget.equipo.marca} ${widget.equipo.modelo}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // MENSAJES
          Expanded(
            child: mensajes.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.smart_toy,
                            size: 70,
                          ),
                          SizedBox(height: 15),
                          Text(
                            'Asistente técnico',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Describe una falla o problema '
                            'del equipo para recibir una '
                            'orientación inicial.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: mensajes.length,
                    itemBuilder: (context, index) {
                      final mensaje = mensajes[index];
                      final usuario =
                          mensaje['tipo'] == 'usuario';

                      return Align(
                        alignment: usuario
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints:
                              const BoxConstraints(
                            maxWidth: 350,
                          ),
                          margin:
                              const EdgeInsets.only(bottom: 10),
                          padding:
                              const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: usuario
                                ? Colors.blue
                                : Colors.grey.shade200,
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                          child: Text(
                            mensaje['texto']!,
                            style: TextStyle(
                              color: usuario
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // CAMPO DE PREGUNTA
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controlador,
                      textInputAction:
                          TextInputAction.send,
                      onSubmitted: (_) =>
                          enviarPregunta(),
                      decoration: InputDecoration(
                        hintText:
                            'Describe la falla...',
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    mini: true,
                    onPressed: enviarPregunta,
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}