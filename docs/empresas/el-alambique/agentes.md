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
| **Unidad editorial** | Una cobertura compuesta por varios artículos fuente |
| **Modo de procesamiento** | Por lote, con agrupación previa en coberturas |
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
4. Envía esos candidatos al Documentalista para agruparlos en coberturas y descartar ruido.
5. Procesa cada cobertura con Redactor, Jefe de Sección y Maquetador.
6. Registra métricas de la ejecución: cuántos artículos entraron, cuántas coberturas se formaron y cuántas piezas se publicaron.

### Salida

```json
{
	"run_id": "uuid",
	"sources_checked": 10,
	"articles_found": 54,
	"story_clusters": 12,
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
| **Rol técnico** | Agrupador y deduplicador semántico |
| **Se ejecuta** | Después del Corresponsal |
| **Lo invoca** | Redactor Jefe |
| **Invoca a** | PostgreSQL |
| **Responsabilidad** | Detecta qué artículos hablan del mismo acontecimiento, los agrupa en una cobertura y evita coberturas duplicadas ya publicadas |
| **Herramientas** | PostgreSQL, similitud de título, reglas heurísticas y comparación semántica ligera |
| **Modelo LLM** | No necesario |

### Entrada

```json
{
	"run_id": "uuid",
	"raw_articles": []
}
```

### Qué hace

1. Calcula hash y huellas básicas por URL y título.
2. Busca duplicados exactos por URL o contenido claramente repetido.
3. Detecta artículos relacionados entre sí por tema, entidades, tiempo y lugar.
4. Agrupa esos artículos en una cobertura común.
5. Comprueba si esa cobertura ya existe en la base de datos.
6. Marca cada artículo y cada cobertura como `new`, `duplicate`, `update` o `review`.
7. Devuelve coberturas listas para redacción, no artículos sueltos.

### Salida

```json
{
	"run_id": "uuid",
	"story_clusters": [
		{
			"cluster_id": "uuid",
			"topic_hint": "obras en el centro de leon",
			"raw_article_ids": ["uuid-1", "uuid-2", "uuid-3"],
			"status": "new"
		}
	],
	"duplicates": [],
	"manual_review": []
}
```

### Persistencia

- tabla `article_fingerprints`
- tabla `dedup_events`
- tabla `story_clusters`
- tabla `story_cluster_items`

### Si falla

- el artículo se marca para revisión manual
- no se publica automáticamente un artículo si no ha pasado por deduplicación

---

## Redactor

> *Destila la noticia: elimina clickbait y neutraliza el tono.*

| Campo | Detalle |
|---|---|
| **Cargo** | Redactor |
| **Rol técnico** | Redactor-sintetizador LLM |
| **Se ejecuta** | Por cada cobertura nueva o actualizada |
| **Lo invoca** | Redactor Jefe |
| **Invoca a** | Ollama |
| **Responsabilidad** | Compone una pieza editorial única a partir de varias fuentes relacionadas, eliminando sensacionalismo y consolidando hechos |
| **Herramientas** | Ollama (LLM local) |
| **Modelo LLM** | Por definir (`llama3.1`, `qwen2.5` u otro) |

### Entrada

```json
{
	"run_id": "uuid",
	"cluster_id": "uuid",
	"topic_hint": "obras en el centro de leon",
	"source_articles": [
		{
			"source_name": "Diario de León",
			"original_title": "Titular original",
			"raw_body": "Texto extraído..."
		},
		{
			"source_name": "iLeon.com",
			"original_title": "Otro titular",
			"raw_body": "Otro texto extraído..."
		}
	]
}
```

### Qué hace

1. Recibe un dossier con varios artículos fuente sobre el mismo hecho.
2. Extrae hechos coincidentes y detecta diferencias relevantes entre medios.
3. Redacta un titular neutro basado en el conjunto, no en una sola fuente.
4. Compone un cuerpo único, consolidado y sin clickbait.
5. Genera un resumen corto para listados y notificaciones.
6. Devuelve también la lista de fuentes usadas y posibles contradicciones detectadas.

### Salida

```json
{
	"cluster_id": "uuid",
	"clean_title": "Titular neutral",
	"clean_body": "Artículo destilado...",
	"short_summary": "Resumen de 2 líneas",
	"editor_notes": "Sin cifras no verificadas",
	"source_count": 3,
	"source_attributions": [
		"Diario de León",
		"iLeon.com",
		"La Nueva Crónica"
	],
	"contradictions": []
}
```

### Reglas editoriales

- no inventar hechos
- no añadir opiniones
- no ocultar incertidumbre si la fuente original la contiene
- mantener nombres propios, fechas y cifras cuando estén en la fuente
- priorizar los hechos coincidentes cuando varias fuentes cubren el mismo asunto
- si dos fuentes discrepan, reflejar la discrepancia o dejarla en notas internas

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
	"cluster_id": "uuid",
	"clean_title": "Titular neutral",
	"clean_body": "Artículo destilado..."
}
```

### Qué hace

1. Lee el titular y el cuerpo ya destilados.
2. Determina la sección principal.
3. Añade etiquetas secundarias útiles para búsqueda.
4. Puede ajustar el foco geográfico de la cobertura si las fuentes mezclan varias zonas.
5. Devuelve una clasificación con confianza.

### Salida

```json
{
	"cluster_id": "uuid",
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
	"cluster_id": "uuid",
	"clean_title": "Titular neutral",
	"clean_body": "Artículo destilado...",
	"short_summary": "Resumen de 2 líneas",
	"section": "Local",
	"tags": ["ayuntamiento", "movilidad"],
	"source_attributions": ["Diario de León", "iLeon.com"],
	"primary_source_url": "https://..."
}
```

### Qué hace

1. Inserta o actualiza el artículo final en la base de datos.
2. Genera `slug`, fecha editorial y estado de publicación.
3. Marca el artículo como disponible para la API.
4. Guarda las relaciones entre la pieza editorial y todos los artículos fuente utilizados.
5. Deja trazabilidad hacia cada fuente original.

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
- tabla `article_sources`
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
	"story_clusters": [],
	"processed_articles": [],
	"failed_articles": [],
	"metrics": {
		"found": 0,
		"clusters": 0,
		"published": 0,
		"failed": 0
	}
}
```
