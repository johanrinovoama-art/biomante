# Manual de usuario — Biomante

## 1. Propósito

Biomante permite registrar equipos biomédicos, documentar intervenciones de mantenimiento, consultar historiales y almacenar documentación técnica de cada equipo.

## 2. Inicio

Al abrir la aplicación se muestra el panel principal con los contadores de equipos, mantenimientos próximos, mantenimientos vencidos y registros realizados. Usa el botón de actualizar o desliza hacia abajo para refrescar los datos guardados.

## 3. Registrar un equipo

1. Selecciona **Registrar equipo**.
2. Completa nombre, marca y modelo. Son campos obligatorios.
3. Registra número de serie, código de inventario y ubicación cuando estén disponibles.
4. Selecciona el estado inicial.
5. Guarda el registro.

El código de inventario y el número de serie se validan para evitar duplicados cuando se ingresan.

## 4. Consultar la ficha del equipo

En **Ver mis equipos**, abre un equipo para consultar su identificación, estado y fechas de mantenimiento. Desde la ficha puedes registrar mantenimiento, consultar el historial, abrir manuales, realizar pruebas funcionales, generar un QR o elaborar un informe técnico.

## 5. Registrar mantenimiento

1. Abre la ficha del equipo y selecciona **Registrar mantenimiento**.
2. Escoge preventivo o correctivo.
3. Indica el técnico responsable y describe el trabajo realizado.
4. Registra fallas, repuestos, resultado y observaciones.
5. Actualiza la fecha del próximo mantenimiento si corresponde.
6. Guarda el registro.

Para mantenimientos correctivos se pueden registrar fecha y hora de falla, inicio de reparación, fin de reparación y retorno a operación. Ingresa tiempos reales, porque se utilizan en los indicadores.

El estado del equipo se actualiza según el resultado: operativo, en mantenimiento o fuera de servicio.

## 6. Checklist y pruebas funcionales

Desde la ficha selecciona **Pruebas funcionales y checklist**. Registra el técnico, marca cada verificación como Cumple, No cumple o No aplica, agrega observaciones y adjunta fotografías cuando sea necesario.

La lista es una guía general: debe adaptarse al tipo de equipo, al manual del fabricante y al procedimiento institucional. Una prueba con puntos No cumple se conserva como no conforme.

## 7. Manuales y documentos PDF

Desde la ficha abre **Manuales y documentación**, selecciona un PDF, clasifícalo y guárdalo. Los documentos se pueden abrir y eliminar desde la lista.

## 8. Código QR

En la ficha selecciona **Generar código QR**. El QR contiene un identificador interno de Biomante. Usa el lector desde el panel o desde la pantalla del QR para identificar un equipo registrado.

El lector requiere cámara y, en navegador, contexto seguro HTTPS o localhost y permiso de cámara.

## 9. Indicadores y reportes

La pantalla **Indicadores y reportes** muestra cantidades generales y los indicadores disponibles por equipo:

- **MTBF:** promedio de horas entre fechas de falla consecutivas registradas.
- **MTTR:** promedio de horas desde el inicio de la reparación hasta el retorno a operación (o fin de reparación si no se registró retorno).
- **Disponibilidad estimada:** MTBF / (MTBF + MTTR) × 100.

Cuando no hay registros suficientes se muestra **Sin datos suficientes**. No se deben crear fechas o duraciones ficticias para obtener un indicador.

## 10. Informe técnico individual

En la ficha del equipo selecciona **Generar informe técnico PDF**. El documento incluye identificación, indicadores disponibles, historial de mantenimiento y pruebas funcionales.

## 11. Asistente técnico

El asistente ofrece orientación inicial usando la información del equipo y sus últimos mantenimientos. Si se configura el endpoint de IA y se despliega el backend, puede enviar preguntas a un modelo remoto. Sin esa configuración utiliza respuestas locales por reglas.

La orientación automática no sustituye al manual del fabricante, los procedimientos de seguridad ni la evaluación del técnico responsable. No uses el asistente para tomar decisiones clínicas.

## 12. Datos y copias

Los datos se almacenan localmente en el dispositivo o navegador. No existe sincronización automática entre dispositivos. Evita borrar los datos del navegador o desinstalar la aplicación sin contar con una copia adecuada.
