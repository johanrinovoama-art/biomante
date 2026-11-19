import { createServer } from 'node:http';

const PORT = Number(process.env.PORT || 8787);
const API_KEY = process.env.OPENAI_API_KEY || '';
const MODEL = process.env.OPENAI_MODEL || '';
const ALLOWED_ORIGIN = process.env.ALLOWED_ORIGIN || '*';
const MAX_BODY_BYTES = 32 * 1024;
const MAX_REQUESTS_PER_MINUTE = 20;
const requestsByIp = new Map();

function sendJson(response, status, body) {
  response.writeHead(status, {
    'Content-Type': 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin': ALLOWED_ORIGIN,
    'Access-Control-Allow-Methods': 'POST, OPTIONS, GET',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Cache-Control': 'no-store',
  });
  response.end(JSON.stringify(body));
}

function permitido(ip) {
  const ahora = Date.now();
  const actual = requestsByIp.get(ip);
  if (!actual || ahora - actual.inicio >= 60_000) {
    requestsByIp.set(ip, { inicio: ahora, cantidad: 1 });
    return true;
  }
  actual.cantidad += 1;
  return actual.cantidad <= MAX_REQUESTS_PER_MINUTE;
}

async function leerCuerpo(request) {
  let cuerpo = '';
  for await (const fragmento of request) {
    cuerpo += fragmento;
    if (Buffer.byteLength(cuerpo, 'utf8') > MAX_BODY_BYTES) {
      throw new Error('BODY_TOO_LARGE');
    }
  }
  return JSON.parse(cuerpo);
}

function extraerTexto(datos) {
  if (typeof datos.output_text === 'string') return datos.output_text.trim();
  const partes = [];
  for (const item of datos.output || []) {
    if (item.type !== 'message' || !Array.isArray(item.content)) continue;
    for (const bloque of item.content) {
      if (bloque.type === 'output_text' && typeof bloque.text === 'string') {
        partes.push(bloque.text);
      }
    }
  }
  return partes.join('\n').trim();
}

const server = createServer(async (request, response) => {
  if (request.method === 'OPTIONS') {
    sendJson(response, 204, {});
    return;
  }

  if (request.method === 'GET' && request.url === '/health') {
    sendJson(response, 200, { status: 'ok', configured: Boolean(API_KEY && MODEL) });
    return;
  }

  if (request.method !== 'POST' || request.url !== '/api/chat') {
    sendJson(response, 404, { error: 'Ruta no encontrada.' });
    return;
  }

  const ip = request.socket.remoteAddress || 'unknown';
  if (!permitido(ip)) {
    sendJson(response, 429, { error: 'Límite temporal de solicitudes alcanzado.' });
    return;
  }

  if (!API_KEY || !MODEL) {
    sendJson(response, 503, { error: 'Configura OPENAI_API_KEY y OPENAI_MODEL en el servidor.' });
    return;
  }

  let body;
  try {
    body = await leerCuerpo(request);
  } catch (error) {
    const tooLarge = error.message === 'BODY_TOO_LARGE';
    sendJson(response, tooLarge ? 413 : 400, {
      error: tooLarge ? 'La solicitud supera el tamaño permitido.' : 'JSON no válido.',
    });
    return;
  }

  if (typeof body.pregunta !== 'string' ||
      body.pregunta.trim().length === 0 ||
      body.pregunta.length > 8000 ||
      typeof body.contextoEquipo !== 'string' ||
      body.contextoEquipo.length > 12000) {
    sendJson(response, 400, { error: 'Los datos de la consulta no son válidos.' });
    return;
  }

  const instructions = `
Eres el asistente técnico de Biomante, una herramienta de apoyo para tecnólogos
y técnicos de mantenimiento de equipos biomédicos.

Orienta de forma prudente. Distingue hechos, hipótesis y comprobaciones.
No inventes manuales, especificaciones, códigos de error ni valores de calibración.
No indiques anular alarmas, interbloqueos o protecciones. No recomiendes trabajar
sobre circuitos energizados ni realizar intervenciones clínicas. Si faltan datos,
solicita marca, modelo, código de error y condiciones observadas. Recomienda
consultar el manual de servicio específico y los procedimientos institucionales.

Contexto del equipo:
${body.contextoEquipo}
`;

  try {
    const upstream = await fetch('https://api.openai.com/v1/responses', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${API_KEY}`,
      },
      body: JSON.stringify({
        model: MODEL,
        instructions,
        input: body.pregunta,
      }),
      signal: AbortSignal.timeout(30_000),
    });

    const raw = await upstream.text();
    let datos;
    try {
      datos = JSON.parse(raw);
    } catch (_) {
      sendJson(response, 502, { error: 'El proveedor devolvió una respuesta no válida.' });
      return;
    }

    if (!upstream.ok) {
      console.error('OpenAI API error:', upstream.status, datos.error?.type || 'unknown');
      sendJson(response, upstream.status, { error: 'El proveedor de IA no pudo procesar la consulta.' });
      return;
    }

    const respuesta = extraerTexto(datos);
    if (!respuesta) {
      sendJson(response, 502, { error: 'El proveedor no devolvió texto.' });
      return;
    }
    sendJson(response, 200, { respuesta });
  } catch (error) {
    console.error('Fallo al consultar IA:', error.message);
    sendJson(response, 502, { error: 'No fue posible consultar el servicio de IA.' });
  }
});

server.listen(PORT, () => {
  console.log(`Biomante IA backend listening on port ${PORT}`);
});
