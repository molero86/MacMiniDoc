# Base de Datos — El Alambique

## Objetivo

La base de datos de El Alambique debe cubrir cuatro necesidades desde el primer día:

- almacenar las fuentes configuradas
- conservar los artículos brutos y los artículos destilados
- registrar qué ha pasado en cada ejecución del pipeline
- servir de base estable para la API, la web y la app

## Motor elegido

| Elemento | Decisión |
|---|---|
| **Motor** | PostgreSQL |
| **Motivo principal** | Buen soporte relacional, búsquedas, índices y crecimiento futuro |
| **Uso inicial** | Fuente de verdad única para agentes, API y clientes |

## Principios de diseño

- no perder el enlace con la fuente original
- separar artículo bruto, cobertura y artículo editorial final
- mantener trazabilidad por ejecución del pipeline
- permitir reintentos sin corromper datos ya procesados
- facilitar filtros por sección, fecha, fuente y estado
- permitir que una pieza publicada se nutra de varias fuentes

## Tablas principales

### `sources`

Define los medios monitorizados por el Corresponsal.

| Campo | Tipo | Notas |
|---|---|---|
| `id` | UUID PK | Identificador interno |
| `slug` | VARCHAR UNIQUE | Ej. `diario-de-leon` |
| `name` | VARCHAR | Nombre público del medio |
| `base_url` | VARCHAR | URL principal |
| `rss_url` | VARCHAR NULL | Feed RSS/Atom si existe |
| `collection_mode` | VARCHAR | `rss`, `scraping`, `rss_or_scraping` |
| `region` | VARCHAR | León, Bierzo, Astorga, etc. |
| `is_active` | BOOLEAN | Si la fuente participa en el pipeline |
| `last_checked_at` | TIMESTAMP NULL | Última comprobación |
| `created_at` | TIMESTAMP | Alta del registro |
| `updated_at` | TIMESTAMP | Última modificación |

### `pipeline_runs`

Registra cada ejecución programada del Redactor Jefe.

| Campo | Tipo | Notas |
|---|---|---|
| `id` | UUID PK | Identificador del lote |
| `scheduled_at` | TIMESTAMP | Hora prevista del job |
| `started_at` | TIMESTAMP | Inicio real |
| `finished_at` | TIMESTAMP NULL | Fin real |
| `scope` | VARCHAR | Ej. `leon` |
| `status` | VARCHAR | `running`, `completed`, `partial_failure`, `failed` |
| `sources_checked` | INTEGER | Fuentes visitadas |
| `articles_found` | INTEGER | Artículos detectados |
| `articles_unique` | INTEGER | Tras deduplicación |
| `articles_published` | INTEGER | Publicados |
| `articles_failed` | INTEGER | Fallidos |
| `error_summary` | TEXT NULL | Resumen del lote |
| `created_at` | TIMESTAMP | Alta del registro |

### `raw_articles`

Conserva la materia prima extraída por el Corresponsal antes de la destilación.

| Campo | Tipo | Notas |
|---|---|---|
| `id` | UUID PK | Identificador interno |
| `pipeline_run_id` | UUID FK | Referencia a `pipeline_runs.id` |
| `source_id` | UUID FK | Referencia a `sources.id` |
| `original_url` | VARCHAR UNIQUE | URL original del artículo |
| `url_hash` | VARCHAR | Hash normalizado de URL |
| `original_title` | TEXT | Titular original |
| `raw_excerpt` | TEXT NULL | Extracto si existe |
| `raw_body` | TEXT | Texto extraído |
| `author_name` | VARCHAR NULL | Autor si puede extraerse |
| `published_at` | TIMESTAMP NULL | Fecha original del medio |
| `collected_at` | TIMESTAMP | Momento de ingesta |
| `language` | VARCHAR DEFAULT `es` | Idioma detectado |
| `extraction_status` | VARCHAR | `collected`, `incomplete`, `failed` |

### `article_fingerprints`

Soporta al Documentalista para deduplicar y comparar artículos.

| Campo | Tipo | Notas |
|---|---|---|
| `id` | UUID PK | Identificador interno |
| `raw_article_id` | UUID FK | Referencia a `raw_articles.id` |
| `url_hash` | VARCHAR | Hash de URL |
| `normalized_title` | TEXT | Título normalizado |
| `title_hash` | VARCHAR | Hash del título |
| `similarity_group` | VARCHAR NULL | Agrupación futura |
| `created_at` | TIMESTAMP | Alta del registro |

### `dedup_events`

Deja traza de la decisión del Documentalista.

| Campo | Tipo | Notas |
|---|---|---|
| `id` | UUID PK | Identificador interno |
| `pipeline_run_id` | UUID FK | Referencia a `pipeline_runs.id` |
| `raw_article_id` | UUID FK | Referencia a `raw_articles.id` |
| `decision` | VARCHAR | `new`, `duplicate`, `update`, `review` |
| `matched_cluster_id` | UUID NULL | Cobertura relacionada si existe |
| `reason` | TEXT NULL | Motivo de la decisión |
| `created_at` | TIMESTAMP | Alta del registro |

### `story_clusters`

Representa una cobertura o historia compuesta a partir de varios artículos fuente que hablan del mismo hecho.

| Campo | Tipo | Notas |
|---|---|---|
| `id` | UUID PK | Identificador de la cobertura |
| `pipeline_run_id` | UUID FK | Ejecución que creó o actualizó la cobertura |
| `topic_hint` | TEXT | Resumen técnico del hecho agrupado |
| `cluster_status` | VARCHAR | `new`, `update`, `duplicate`, `review`, `published` |
| `canonical_region` | VARCHAR NULL | Región principal detectada |
| `first_seen_at` | TIMESTAMP | Primera vez detectada |
| `last_seen_at` | TIMESTAMP | Última vez actualizada |
| `created_at` | TIMESTAMP | Alta del registro |
| `updated_at` | TIMESTAMP | Último cambio |

### `story_cluster_items`

Une cada cobertura con los artículos brutos que la alimentan.

| Campo | Tipo | Notas |
|---|---|---|
| `id` | UUID PK | Identificador interno |
| `cluster_id` | UUID FK | Referencia a `story_clusters.id` |
| `raw_article_id` | UUID FK | Referencia a `raw_articles.id` |
| `is_primary` | BOOLEAN | Si es una fuente principal dentro de la cobertura |
| `relevance_score` | NUMERIC(4,3) NULL | Peso relativo dentro del grupo |
| `created_at` | TIMESTAMP | Alta del registro |

### `articles`

Es la tabla editorial principal. Solo contiene artículos ya destilados y listos para servir.

| Campo | Tipo | Notas |
|---|---|---|
| `id` | UUID PK | Identificador editorial |
| `cluster_id` | UUID FK UNIQUE | Referencia a la cobertura origen |
| `section` | VARCHAR | `Local`, `El Bierzo`, etc. |
| `slug` | VARCHAR UNIQUE | URL amigable |
| `clean_title` | TEXT | Titular destilado |
| `clean_body` | TEXT | Cuerpo final |
| `short_summary` | TEXT | Resumen corto |
| `editor_notes` | TEXT NULL | Observaciones internas |
| `source_count` | INTEGER | Número de fuentes utilizadas |
| `primary_source_url` | VARCHAR NULL | URL principal de referencia |
| `publication_status` | VARCHAR | `draft`, `ready_to_publish`, `published`, `rejected` |
| `published_at` | TIMESTAMP NULL | Fecha de publicación en El Alambique |
| `created_at` | TIMESTAMP | Alta del registro |
| `updated_at` | TIMESTAMP | Último cambio |

### `article_sources`

Relaciona cada artículo editorial final con todas las fuentes que se han utilizado para construirlo.

| Campo | Tipo | Notas |
|---|---|---|
| `id` | UUID PK | Identificador interno |
| `article_id` | UUID FK | Referencia a `articles.id` |
| `raw_article_id` | UUID FK | Referencia a `raw_articles.id` |
| `source_id` | UUID FK | Referencia a `sources.id` |
| `source_name_snapshot` | VARCHAR | Nombre de la fuente congelado |
| `source_url_snapshot` | VARCHAR | URL fuente congelada |
| `used_for` | VARCHAR | `primary`, `supporting`, `context` |
| `created_at` | TIMESTAMP | Alta del registro |

### `article_tags`

Etiquetas secundarias para búsqueda y navegación.

| Campo | Tipo | Notas |
|---|---|---|
| `id` | UUID PK | Identificador interno |
| `article_id` | UUID FK | Referencia a `articles.id` |
| `tag` | VARCHAR | Ej. `ayuntamiento` |
| `confidence` | NUMERIC(4,3) NULL | Confianza del clasificador |

### `publication_events`

Bitácora del Maquetador y de cambios de estado editoriales.

| Campo | Tipo | Notas |
|---|---|---|
| `id` | UUID PK | Identificador interno |
| `article_id` | UUID FK | Referencia a `articles.id` |
| `event_type` | VARCHAR | `created`, `updated`, `published`, `rejected` |
| `payload` | JSONB NULL | Contexto del cambio |
| `created_at` | TIMESTAMP | Momento del evento |

### `agent_failures`

Registra errores por agente sin perder el contexto del artículo o del lote.

| Campo | Tipo | Notas |
|---|---|---|
| `id` | UUID PK | Identificador interno |
| `pipeline_run_id` | UUID FK | Lote asociado |
| `raw_article_id` | UUID NULL FK | Artículo bruto si aplica |
| `article_id` | UUID NULL FK | Artículo editorial si aplica |
| `agent_name` | VARCHAR | `corresponsal`, `documentalista`, etc. |
| `error_type` | VARCHAR | Tipo técnico |
| `error_message` | TEXT | Mensaje de error |
| `retryable` | BOOLEAN | Si permite reintento |
| `created_at` | TIMESTAMP | Alta del registro |

## Relaciones principales

```text
sources 1 --- n raw_articles
pipeline_runs 1 --- n raw_articles
raw_articles 1 --- n dedup_events
raw_articles 1 --- 1 article_fingerprints
pipeline_runs 1 --- n story_clusters
story_clusters 1 --- n story_cluster_items
raw_articles 1 --- n story_cluster_items
story_clusters 1 --- 0..1 articles
articles 1 --- n article_tags
articles 1 --- n article_sources
articles 1 --- n publication_events
pipeline_runs 1 --- n agent_failures
```

## Estados clave del flujo

### Estado de extracción en `raw_articles.extraction_status`

| Estado | Significado |
|---|---|
| `collected` | Extracción correcta y suficiente |
| `incomplete` | Texto parcial, pero utilizable o revisable |
| `failed` | No se pudo extraer el contenido |

### Decisión de deduplicación en `dedup_events.decision`

| Estado | Significado |
|---|---|
| `new` | Alimenta una cobertura nueva |
| `duplicate` | Es repetición exacta o irrelevante |
| `update` | Amplía una cobertura ya existente |
| `review` | Requiere revisión posterior |

### Estado de cobertura en `story_clusters.cluster_status`

| Estado | Significado |
|---|---|
| `new` | Cobertura recién detectada |
| `update` | Cobertura existente con nuevas fuentes |
| `duplicate` | Grupo redundante, no debe avanzar |
| `review` | Dudas de agrupación o conflicto |
| `published` | Ya existe pieza editorial publicada |

### Estado editorial en `articles.publication_status`

| Estado | Significado |
|---|---|
| `draft` | Redactado pero aún no listo |
| `ready_to_publish` | Listo tras clasificación |
| `published` | Visible para API, web y app |
| `rejected` | No se publicará |

### Estado del lote en `pipeline_runs.status`

| Estado | Significado |
|---|---|
| `running` | Ejecución en curso |
| `completed` | Todo correcto |
| `partial_failure` | Hubo errores parciales |
| `failed` | Falló el lote completo |

## Índices recomendados desde el inicio

- índice único en `sources.slug`
- índice único en `raw_articles.original_url`
- índice en `raw_articles.source_id, published_at desc`
- índice en `story_clusters.cluster_status, last_seen_at desc`
- índice único compuesto en `story_cluster_items.cluster_id, raw_article_id`
- índice en `articles.section, published_at desc`
- índice en `articles.publication_status, published_at desc`
- índice en `article_sources.article_id`
- índice en `publication_events.article_id, created_at desc`
- índice en `dedup_events.raw_article_id`
- índice en `agent_failures.pipeline_run_id`

## Qué proyecto es dueño de cada tabla

| Tabla | Dueño principal |
|---|---|
| `sources` | `el-alambique-agents` |
| `pipeline_runs` | `el-alambique-agents` |
| `raw_articles` | `el-alambique-agents` |
| `article_fingerprints` | `el-alambique-agents` |
| `dedup_events` | `el-alambique-agents` |
| `story_clusters` | `el-alambique-agents` |
| `story_cluster_items` | `el-alambique-agents` |
| `articles` | compartido: escribe `el-alambique-agents`, lee `el-alambique-api` |
| `article_sources` | compartido: escribe `el-alambique-agents`, lee `el-alambique-api` |
| `article_tags` | compartido: escribe `el-alambique-agents`, lee `el-alambique-api` |
| `publication_events` | `el-alambique-agents` |
| `agent_failures` | `el-alambique-agents` |

## MVP mínimo de base de datos

Si quisiéramos simplificar la primera versión sin romper el diseño, el MVP puede arrancar con estas tablas:

1. `sources`
2. `pipeline_runs`
3. `raw_articles`
4. `dedup_events`
5. `story_clusters`
6. `story_cluster_items`
7. `articles`
8. `article_sources`
9. `article_tags`
10. `agent_failures`

`article_fingerprints` y `publication_events` pueden añadirse justo después si preferimos salir antes con un primer pipeline funcional.