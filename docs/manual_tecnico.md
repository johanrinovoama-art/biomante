# Manual técnico — Biomante

## 1. Arquitectura

Biomante es una aplicación Flutter/Dart. La interfaz está separada por páginas y modelos. Los archivos principales están en `lib/`.

- `main.dart`: inicialización, tema y panel.
- `equipo.dart`: modelo de equipo con identificador interno.
- `mantenimiento_modelo.dart`: modelo de intervención y marcas de tiempo.
- `datos.dart`: carga, serialización, migración y persistencia local.
- `almacen_documentos.dart`: interfaz de almacenamiento binario.
- `almacen_documentos_web.dart`: almacenamiento Sembast en IndexedDB.
- `almacen_documentos_io.dart`: almacenamiento Sembast en plataformas con sistema de archivos.
- `manuales.dart`: selección, visualización y eliminación de PDF.
- `pruebas_funcionales.dart`: checklist, resultados y evidencias.
- `indicadores.dart`: cálculo de confiabilidad.
- `reportes.dart`: resumen y reporte PDF general.
- `informe_tecnico.dart`: informe PDF por equipo.
- `codigo_qr.dart`: creación y lectura de QR.
- `asistente_tecnico.dart`: interfaz conversacional.
- `asistente_ia_service.dart`: cliente del backend de IA.

## 2. Preparación

Requisitos: Flutter estable compatible con Dart 3.13 o superior, Git y Node.js 20 o superior para el backend opcional de IA.

Desde la raíz del proyecto:

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

## 3. Persistencia

Equipos, mantenimientos, metadatos de documentos y pruebas funcionales se almacenan con SharedPreferences. PDF y fotografías se guardan por separado usando Sembast:

- Web: IndexedDB.
- Android/iOS/escritorio: archivo dentro del directorio privado de soporte de la aplicación.

Los registros incluyen identificadores internos de equipo. Los datos históricos sin ID se relacionan por inventario solo cuando la coincidencia no es ambigua.

No hay sincronización remota ni respaldo multiusuario.

## 4. Seguridad y datos

- No registrar claves API dentro de Flutter ni del repositorio.
- No subir archivos `.env`, certificados o credenciales.
- Los documentos deben ser PDF válidos y las evidencias imágenes.
- Realizar copias de seguridad antes de migraciones.
- La carga de datos debe completarse antes de permitir nuevos guardados.
- El contenido Base64 histórico no se limpia hasta guardar su referencia en almacenamiento independiente.

## 5. Indicadores

```text
MTBF = promedio de (fecha de falla actual - fecha de falla anterior)
MTTR = promedio de (retorno a operación - inicio de reparación)
Disponibilidad estimada = MTBF / (MTBF + MTTR) × 100
```

Los tiempos se expresan en horas. MTBF requiere al menos dos fechas de falla válidas. MTTR requiere pares válidos de inicio y retorno. Los valores ausentes no se sustituyen por cero.

La disponibilidad calculada es una aproximación basada en MTBF y MTTR; no equivale a disponibilidad operacional auditada si no se registran todos los tiempos del periodo.

## 6. Pruebas funcionales y evidencias

Cada prueba conserva técnico, fecha, checklist, observaciones y referencias a fotografías. La guía inicial debe adecuarse al manual y al protocolo del equipo. Una prueba registrada no certifica calibración ni seguridad eléctrica por sí sola.

## 7. PDF y QR

Los reportes se generan con `pdf` y se abren con `printing`. El QR almacena el ID interno con el prefijo `BIOMANTE:`; el lector usa la cámara mediante `mobile_scanner`. El navegador requiere HTTPS o localhost y permiso de cámara.

## 8. Backend del asistente IA

El backend Node.js está en `backend/`. Usa la Responses API y mantiene la clave del proveedor en una variable de entorno del servidor.

```bash
cd backend
cp .env.example .env
# Editar OPENAI_API_KEY y OPENAI_MODEL en .env
node --env-file=.env server.mjs
```

Ejecuta Flutter con:

```bash
flutter run -d chrome --dart-define=BIOMANTE_AI_ENDPOINT=http://localhost:8787/api/chat
```

Para producción, desplegar backend bajo HTTPS, configurar secretos en el hosting, restringir el origen permitido y añadir autenticación y cuotas por usuario. El limitador básico por IP no basta para un servicio público.

## 9. Validación continua

GitHub Actions ejecuta `flutter pub get`, `flutter analyze --no-fatal-infos` y `flutter test`. La validación remota no sustituye las pruebas de interfaz en dispositivos, cámara, impresión o permisos nativos.
