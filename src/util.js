import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

export const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
// OUT_DIR permite escribir los datos fuera del repo (en GitHub Actions es la carpeta con lo publicado en gh-pages).
export const OUT_DIR = process.env.OUT_DIR ? path.resolve(process.env.OUT_DIR) : path.join(ROOT, 'site');

// Fecha AAAA-MM-DD en hora de Lima.
export function limaDate(d = new Date()) {
  return new Intl.DateTimeFormat('en-CA', { timeZone: 'America/Lima', year: 'numeric', month: '2-digit', day: '2-digit' }).format(d);
}

// true si este archivo es el que se ejecutó con node (y no uno importado).
export function isMain(metaUrl) {
  return process.argv[1] && metaUrl === pathToFileURL(path.resolve(process.argv[1])).href;
}
