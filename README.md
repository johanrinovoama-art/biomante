# Biomante

**Biomante** es una aplicación Flutter orientada a la gestión del inventario y del mantenimiento de equipos biomédicos.

## Funcionalidades actuales

- Registro y consulta de equipos biomédicos.
- Ficha técnica básica por equipo.
- Registro de mantenimiento preventivo y correctivo.
- Historial de intervenciones por equipo.
- Asociación y consulta de manuales y documentos PDF.
- Asistente técnico inicial basado en reglas.
- Panel principal con resumen de equipos y mantenimientos.

## Tecnologías

- Flutter y Dart.
- SharedPreferences para persistencia de datos estructurados locales.
- Sembast para almacenamiento independiente de documentos.
- Sembast Web / IndexedDB para navegador.
- Sembast IO para Android, iOS y escritorio.
- File Picker y Syncfusion PDF Viewer para documentos PDF.

## Preparar el proyecto

Desde la carpeta raíz del proyecto:

```bash
flutter pub get
flutter analyze
flutter test
```

Para ejecutar en Chrome:

```bash
flutter run -d chrome
```

## Persistencia

Los equipos, mantenimientos y metadatos de documentos se guardan localmente. Los PDF se almacenan por separado: en IndexedDB para web y en el directorio privado de soporte de la aplicación para plataformas nativas.

> Los datos locales no se sincronizan automáticamente entre dispositivos. Para un despliegue multiusuario se requiere incorporar un backend y autenticación.

## Estado del desarrollo

Biomante está en desarrollo académico. Los indicadores de confiabilidad, informes técnicos, checklist, pruebas funcionales, evidencias, generación QR e integración con un servicio de IA requieren módulos adicionales antes de considerarse finalizados.
