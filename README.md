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

## Documentación del proyecto

- [Manual de usuario](docs/manual_usuario.md)
- [Manual técnico](docs/manual_tecnico.md)
- [Backend del asistente IA](backend/README.md)

## Estado del desarrollo

Biomante está en desarrollo académico. Los módulos de checklist, pruebas funcionales, evidencias fotográficas, indicadores, reportes PDF y QR están incorporados en la rama de estabilización. La IA requiere desplegar el backend y configurar credenciales del proveedor.
