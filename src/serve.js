// Vista previa local del dashboard con los datos de la última captura: http://localhost:8080
//   npm run serve
import http from 'node:http';
import fs from 'node:fs/promises';
import path from 'node:path';
import { ROOT, OUT_DIR } from './util.js';

const TYPES = { '.html': 'text/html; charset=utf-8', '.json': 'application/json; charset=utf-8', '.jpg': 'image/jpeg', '.js': 'text/javascript', '.css': 'text/css' };
const port = Number(process.env.PORT || 8080);

http.createServer(async (req, res) => {
  const url = decodeURIComponent(new URL(req.url, 'http://x').pathname);
  const rel = url === '/' ? 'index.html' : url.slice(1);
  // index.html sale del repo; data/ e img/ de la carpeta de salida.
  const base = rel === 'index.html' ? ROOT : OUT_DIR;
  const file = path.resolve(base, rel);
  if (!file.startsWith(base)) { res.writeHead(403).end(); return; }
  try {
    const body = await fs.readFile(file);
    res.writeHead(200, { 'content-type': TYPES[path.extname(file)] || 'application/octet-stream' }).end(body);
  } catch {
    res.writeHead(404).end('No encontrado');
  }
}).listen(port, () => console.log(`Dashboard en http://localhost:${port}`));
