# Library Scrapping · anuncios de la competencia

Monitor diario de los anuncios de la competencia en **Meta Ad Library** (Facebook e Instagram) y
**Google Ads Transparency Center** (Search, Display y YouTube) durante una campaña, por ejemplo Cyber Wow, Black Friday o
Navidad. Publica un dashboard en GitHub Pages con tres pestañas, **Meta**, **Google** y **Meta vs Google**. Cada día
compara con el anterior y marca como **Nuevo** lo que apareció.

**Dashboard:** https://palomapillco-blip.github.io/library_scrapping/

## Cómo funciona

- **Meta:** `src/capture.js` abre el Ad Library de cada marca con Playwright (Chromium headless), recorre toda la lista
  (scroll y "Ver más") y se queda con los anuncios activos cuyo texto contiene la palabra clave.
- **Google:** consulta el centro de transparencia sin navegador y toma los anuncios que se mostraron por primera vez
  desde `startDate`. De los nuevos lee el titular y la descripción. A los banners sin texto les pasa OCR
  (tesseract.js): si encuentra la palabra clave quedan **Sí**, si no, **Por revisar**.
- **Miniaturas propias** en `img/`, porque los links de imagen de Meta caducan en días.
- **Datos del día** en `data/AAAA-MM-DD.json`.
- **Publicación:** `src/publish.js` publica en la rama `gh-pages` con un solo commit. Si dos corridas coinciden, mezcla por
  marca y fuente: una captura que falló no reemplaza a una buena del mismo día.

## Configuración (`config.json`)

- `settings`:
  - `campaign`: nombre que muestra el dashboard.
  - `keyword`: palabra clave, por ejemplo `cyber`, `black friday` o `navidad`.
  - `startDate` / `endDate`: ventana de la campaña, en formato `AAAA-MM-DD`.
- `brands`: una entrada por marca:
  - `metaPageId`: el número `view_all_page_id` de la URL del anunciante en el Ad Library.
  - `googleDomain`: por ejemplo `ripley.com.pe`.
  - Para pausar una marca sin borrarla, agrega `"enabled": false`.

**Corregir la clasificación de Google:** en `revision.json`, agrega `"<link del anuncio en Google>": "Sí"` (o `"No"`).
Se aplica en la siguiente corrida.

## Publicar (GitHub Actions + Pages, gratis en repos públicos)

1. **Primera corrida:** en el repo, entra a **Actions**, abre **Captura diaria** y haz clic en **Run workflow**.
2. **Activar Pages:** cuando termine, ve a **Settings → Pages → Source: Deploy from a branch**, rama `gh-pages`,
   carpeta `/ (root)`.
3. **Corridas diarias:** a las 7:00 a. m. y a la 1:00 p. m. (Lima). **Run workflow** captura cuando quieras, y permite
   elegir marcas o una sola fuente.
4. **Cambios al dashboard:** si subes un cambio de `index.html` a `main`, se publica solo, sin capturar.

## Uso local (opcional; requiere Node 20 o superior)

```bash
npm install
npx playwright install chromium
npm run capture                              # todas las marcas, Meta y Google
npm run capture -- --only ripley,wong        # solo algunas marcas
npm run capture -- --source google           # solo una fuente
npm run serve                                # dashboard en http://localhost:8080
npm run publish -- --from site               # publicar la corrida local en gh-pages
```

## Limitaciones

- **No hay inversión ni impresiones:** las bibliotecas no publican esos datos de anuncios comerciales en Perú.
- **Meta puede bloquear a los servidores de GitHub.** Si una marca sale con error en el resumen de la corrida, se
  conserva lo último que salió bien.
- **El OCR de banners con tipografías de campaña no es perfecto.** Lo dudoso queda **Por revisar**, con su link al
  anuncio original.
- **GitHub pausa los workflows programados** tras 60 días sin actividad en el repo. Si pasa, reactívalo desde Actions.
