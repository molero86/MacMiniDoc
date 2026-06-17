# Agentes IA — El Alambique

La redacción de El Alambique está formada por seis agentes IA, cada uno con un cargo equivalente al de un periódico real. El **Redactor Jefe** orquesta el flujo completo mediante LangGraph.

## Qué faltaba por definir

La información previa era suficiente para entender la idea general, pero no para empezar a implementar sin ambigüedad. Para arrancar bien, cada agente necesita un contrato mínimo:

- cuándo se ejecuta
- quién lo invoca
- qué entrada recibe
- qué validaciones aplica
- qué salida produce
- qué escribe en base de datos
- qué pasa si falla

## Cadencia y modelo de ejecución

| Elemento | Decisión actual |
|---|---|
| **Frecuencia del pipeline** | Cada 6 horas |
| **Quién inicia el proceso** | APScheduler |
| **Quién coordina el flujo** | Redactor Jefe |
| **Unidad de trabajo** | Un lote de artículos detectados en una ejecución |
| **Modo de procesamiento** | Por lote, con procesamiento individual por artículo |
| **Persistencia** | PostgreSQL |
| **Consumo final** | API FastAPI, web Next.js y app React Native |

## Flujo de llamadas

```text
APScheduler
	 -> Redactor Jefe
			-> Corresponsal
			-> Documentalista
			-> Redactor
			-> Jefe de Sección
			-> Maquetador
```

El scheduler solo despierta al **Redactor Jefe**. Ningún otro agente se ejecuta por su cuenta en esta primera versión.

---

## Redactor Jefe

> *Orquesta el flujo completo y gestiona errores.*

| Campo | Detalle |
|---|---|
| **Cargo** | Redactor Jefe |
| **Rol técnico** | Orquestador del pipeline (LangGraph) |
| **Se ejecuta** | Cada 6 horas |
| **Lo invoca** | APScheduler |
| **Invoca a** | Corresponsal, Documentalista, Redactor, Jefe de Sección y Maquetador |
| **Responsabilidad** | Coordina a todos los agentes, aplica reglas de flujo, gestiona reintentos y errores |
| **Herramientas** | LangGraph StateGraph |
| **Modelo LLM** | No necesario |

### Entrada

```json
{
	"run_id": "uuid",
	"scheduled_at": "2026-06-17T06:00:00Z",
	"sources_scope": "leon",
	"force_reprocess": false
}
```

### Qué hace

1. Crea un `run_id` único para la ejecución.
2. Carga la lista de fuentes activas.
3. Llama al Corresponsal para obtener artículos candidatos.
4. Envía esos candidatos al Documentalista para filtrar duplicados.
5. Procesa cada artículo único con Redactor, Jefe de Sección y Maquetador.
6. Registra métricas de la ejecución: cuántos artículos entraron, cuántos se descartaron y cuántos se publicaron.

### Salida

```json
{
	"run_id": "uuid",
	"sources_checked": 10,
	"articles_found": 54,
	"articles_unique": 21,
	"articles_published": 18,
	"articles_failed": 3,
	"status": "completed"
}
```

### Persistencia

- tabla `pipeline_runs`
- logs estructurados por ejecución

### Si falla

- reintento automático en errores transitorios de red
- marca el artículo como fallido sin bloquear el lote entero
- cierra la ejecución con estado `partial_failure` si hay errores parciales

---

## Corresponsal

> *Recorre las fuentes y trae las noticias en bruto.*

| Campo | Detalle |
|---|---|
| **Cargo** | Corresponsal |
| **Rol técnico** | Recopilador RSS / Web scraper |
| **Se ejecuta** | En cada ejecución del pipeline |
| **Lo invoca** | Redactor Jefe |
| **Invoca a** | Ninguno |
| **Responsabilidad** | Monitoriza las fuentes de León y extrae artículos candidatos |
| **Herramientas** | `feedparser`, `requests`, `BeautifulSoup` |
| **Modelo LLM** | No necesario |

### Entrada

```json
{
	"run_id": "uuid",
	"sources": [
		{
			"source_id": "diario-de-leon",
			"name": "Diario de León",
			"url": "https://www.diariodeleon.es/",
			"rss_url": null,
			"collection_mode": "rss_or_scraping"
		}
	]
}
```

### Qué hace

1. Recorre cada fuente activa.
2. Detecta si puede usar RSS; si no, aplica scraping controlado.
3. Extrae metadatos básicos del artículo.
4. Normaliza fechas, URLs y nombres de fuente.
5. Devuelve un lote homogéneo de artículos en bruto.

### Salida

```json
{
	"run_id": "uuid",
	"raw_articles": [
		{
			"source_id": "diario-de-leon",
			"source_name": "Diario de León",
			"original_url": "https://...",
			"original_title": "Titular original",
			"published_at": "2026-06-17T05:20:00Z",
			"raw_body": "Texto extraído...",
			"raw_excerpt": "Resumen breve..."
		}
	]
}
```

### Persistencia

- opcionalmente guarda una copia en `raw_articles`
- registra errores de extracción por fuente

### Si falla

- reintenta por fuente
- si una fuente no responde, se marca y el resto del lote sigue adelante

---

## Documentalista

> *Consulta el archivo para evitar duplicados.*

| Campo | Detalle |
|---|---|
| **Cargo** | Documentalista |
| **Rol técnico** | Deduplicador |
| **Se ejecuta** | Después del Corresponsal |
| **Lo invoca** | Redactor Jefe |
| **Invoca a** | PostgreSQL |
| **Responsabilidad** | Compara los artículos nuevos contra la base de datos y descarta los ya procesados |
| **Herramientas** | PostgreSQL (URL hash y similitud de título) |
| **Modelo LLM** | No necesario |

### Entrada

```json
{
	"run_id": "uuid",
	"raw_articles": []
}
```

### Qué hace

1. Calcula un hash por URL original.
2. Busca coincidencias exactas por URL.
3. Busca similitudes por título normalizado.
4. Marca cada candidato como `new`, `duplicate` o `review`.
5. Devuelve solo los artículos que deben seguir el pipeline.

### Salida

```json
{
	"run_id": "uuid",
	"unique_articles": [],
	"duplicates": [],
	"manual_review": []
}
```

### Persistencia

- tabla `article_fingerprints`
- tabla `dedup_events`

### Si falla

- el artículo se marca para revisión manual
- no se publica automáticamente un artículo si no ha pasado por deduplicación

---

## Redactor

> *Destila la noticia: elimina clickbait y neutraliza el tono.*

| Campo | Detalle |
|---|---|
| **Cargo** | Redactor |
| **Rol técnico** | Destilador LLM |
| **Se ejecuta** | Por cada artículo único |
| **Lo invoca** | Redactor Jefe |
| **Invoca a** | Ollama |
| **Responsabilidad** | Reescribe el artículo en bruto de forma neutral, rigurosa y sin sensacionalismo |
| **Herramientas** | Ollama (LLM local) |
| **Modelo LLM** | Por definir (`llama3.1`, `qwen2.5` u otro) |

### Entrada

```json
{
	"run_id": "uuid",
	"article_id": "uuid",
	"original_title": "Titular original",
	"raw_body": "Texto extraído...",
	"source_name": "Diario de León"
}
```

### Qué hace

1. Recibe el texto bruto del artículo.
2. Reescribe el titular para quitar sesgo, exageración o clickbait.
3. Resume y limpia el cuerpo, manteniendo hechos verificables.
4. Genera un resumen corto para listados y notificaciones.
5. Devuelve texto listo para clasificación y publicación.

### Salida

```json
{
	"article_id": "uuid",
	"clean_title": "Titular neutral",
	"clean_body": "Artículo destilado...",
	"short_summary": "Resumen de 2 líneas",
	"editor_notes": "Sin cifras no verificadas"
}
```

### Reglas editoriales

- no inventar hechos
- no añadir opiniones
- no ocultar incertidumbre si la fuente original la contiene
- mantener nombres propios, fechas y cifras cuando estén en la fuente

### Si falla

- se registra el error del modelo
- el artículo queda en cola `pending_redaction`
- puede reintentarse con un segundo modelo si lo definimos más adelante

---

## Jefe de Sección

> *Asigna cada noticia a su sección.*

| Campo | Detalle |
|---|---|
| **Cargo** | Jefe de Sección |
| **Rol técnico** | Clasificador |
| **Se ejecuta** | Después del Redactor |
| **Lo invoca** | Redactor Jefe |
| **Invoca a** | Ollama o clasificador ligero |
| **Responsabilidad** | Categoriza el artículo destilado en la sección correspondiente |
| **Secciones** | Local · El Bierzo · Astorga y Comarca · Provincia · Sucesos · Cultura · Deportes |
| **Herramientas** | Ollama (LLM local) o clasificador ligero |
| **Modelo LLM** | Por definir |

### Entrada

```json
{
	"article_id": "uuid",
	"clean_title": "Titular neutral",
	"clean_body": "Artículo destilado..."
}
```

### Qué hace

1. Lee el titular y el cuerpo ya destilados.
2. Determina la sección principal.
3. Añade etiquetas secundarias útiles para búsqueda.
4. Devuelve una clasificación con confianza.

### Salida

```json
{
	"article_id": "uuid",
	"section": "Local",
	"tags": ["ayuntamiento", "movilidad"],
	"confidence": 0.92
}
```

### Persistencia

- tabla `article_taxonomy`

### Si falla

- asigna `Provincia` como sección de reserva
- etiqueta el artículo para revisión manual

---

## Maquetador

> *Prepara y publica el artículo en la web y la app.*

| Campo | Detalle |
|---|---|
| **Cargo** | Maquetador |
| **Rol técnico** | Publicador |
| **Se ejecuta** | Al final del pipeline por cada artículo válido |
| **Lo invoca** | Redactor Jefe |
| **Invoca a** | PostgreSQL y API FastAPI |
| **Responsabilidad** | Persiste el artículo final y lo deja disponible para la web y la app |
| **Herramientas** | FastAPI · PostgreSQL |
| **Modelo LLM** | No necesario |

### Entrada

```json
{
	"article_id": "uuid",
	"clean_title": "Titular neutral",
	"clean_body": "Artículo destilado...",
	"short_summary": "Resumen de 2 líneas",
	"section": "Local",
	"tags": ["ayuntamiento", "movilidad"],
	"source_name": "Diario de León",
	"original_url": "https://..."
}
```

### Qué hace

1. Inserta o actualiza el artículo final en la base de datos.
2. Genera `slug`, fecha editorial y estado de publicación.
3. Marca el artículo como disponible para la API.
4. Deja trazabilidad hacia la fuente original.

### Salida

```json
{
	"article_id": "uuid",
	"slug": "obras-en-el-centro-de-leon",
	"publication_status": "published",
	"published_at": "2026-06-17T06:12:00Z"
}
```

### Persistencia

- tabla `articles`
- tabla `publication_events`

### Si falla

- el artículo queda en `ready_to_publish`
- no se pierde el trabajo previo del pipeline

## Estado mínimo compartido del pipeline

Para implementar LangGraph sin ambigüedad, el estado compartido de la ejecución debería incluir como mínimo:

```json
{
	"run_id": "uuid",
	"scheduled_at": "datetime",
	"sources": [],
	"raw_articles": [],
	"unique_articles": [],
	"processed_articles": [],
	"failed_articles": [],
	"metrics": {
		"found": 0,
		"unique": 0,
		"published": 0,
		"failed": 0
	}
}
```
