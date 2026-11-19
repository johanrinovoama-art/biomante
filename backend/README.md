# Backend del asistente IA de Biomante

Este servicio mantiene la clave del proveedor fuera de Flutter y del navegador. Utiliza la Responses API de OpenAI desde el servidor.

## Requisitos

- Node.js 20 o superior.
- Un proyecto de API con una clave y un modelo habilitado.
- Un servidor HTTPS para producción.

## Configuración local

1. Copia `.env.example` como `.env`.
2. Introduce la clave API y el modelo que tengas habilitado.
3. Ejecuta:

```bash
node --env-file=.env server.mjs
```

El backend queda disponible en `http://localhost:8787`.

Comprueba su estado:

```bash
curl http://localhost:8787/health
```

Ejecuta Flutter Web en otra terminal:

```bash
flutter run -d chrome --dart-define=BIOMANTE_AI_ENDPOINT=http://localhost:8787/api/chat
```

## Despliegue

Despliega esta carpeta en un hosting que permita ejecutar Node.js. Define `OPENAI_API_KEY`, `OPENAI_MODEL`, `PORT` y `ALLOWED_ORIGIN` en el administrador de secretos del hosting. Configura `ALLOWED_ORIGIN` con el dominio HTTPS de Biomante.

Antes de exponerlo públicamente, añade autenticación de usuarios y controles de cuota por cuenta. El límite por IP incluido es una protección inicial, no sustituye una capa de autenticación.

No subas `.env`, no introduzcas claves en Flutter y no compartas una clave privada en capturas o chats.
