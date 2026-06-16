# Agentes IA — El Alambique

La redacción de El Alambique está formada por seis agentes IA, cada uno con un cargo equivalente al de un periódico real. El **Redactor Jefe** orquesta el flujo completo mediante LangGraph.

---

## Redactor Jefe

> *Orquesta el flujo completo y gestiona errores.*

| Campo | Detalle |
|---|---|
| **Cargo** | Redactor Jefe |
| **Rol técnico** | Orquestador del pipeline (LangGraph) |
| **Responsabilidad** | Coordina a todos los agentes, gestiona reintentos y errores, decide qué artículos avanzan al siguiente paso |
| **Herramientas** | LangGraph StateGraph |
| **Modelo LLM** | No necesario (lógica de flujo) |

---

## Corresponsal

> *Recorre las fuentes y trae las noticias en bruto.*

| Campo | Detalle |
|---|---|
| **Cargo** | Corresponsal |
| **Rol técnico** | Recopilador RSS / Web scraper |
| **Responsabilidad** | Monitoriza las 10 fuentes de León cada 6 horas y extrae artículos nuevos |
| **Entradas** | Lista de fuentes RSS / URLs configuradas |
| **Salidas** | Artículos en bruto: título, cuerpo, URL original, fuente, fecha |
| **Herramientas** | `feedparser`, `requests`, `BeautifulSoup` |
| **Modelo LLM** | No necesario |
| **Frecuencia** | Cada 6 horas (APScheduler) |

---

## Documentalista

> *Consulta el archivo para evitar duplicados.*

| Campo | Detalle |
|---|---|
| **Cargo** | Documentalista |
| **Rol técnico** | Deduplicador |
| **Responsabilidad** | Compara los artículos nuevos contra la base de datos y descarta los ya procesados |
| **Entradas** | Artículos en bruto del Corresponsal |
| **Salidas** | Artículos únicos pendientes de procesar |
| **Herramientas** | PostgreSQL (búsqueda por URL hash y similitud de título) |
| **Modelo LLM** | No necesario |

---

## Redactor

> *Destila la noticia: elimina clickbait y neutraliza el tono.*

| Campo | Detalle |
|---|---|
| **Cargo** | Redactor |
| **Rol técnico** | Destilador LLM |
| **Responsabilidad** | Reescribe el artículo en bruto de forma neutral, rigurosa y sin sensacionalismo |
| **Entradas** | Artículo en bruto (título + cuerpo) |
| **Salidas** | Artículo destilado: título neutro, cuerpo limpio, resumen de 2 líneas |
| **Herramientas** | Ollama (LLM local) |
| **Modelo LLM** | Por definir (`llama3.1`, `qwen2.5` u otro) |
| **Prompt guía** | *"Reescribe esta noticia sin sensacionalismo. Usa hechos verificables. Elimina titulares clickbait. Tono periodístico sobrio."* |

---

## Jefe de Sección

> *Asigna cada noticia a su sección.*

| Campo | Detalle |
|---|---|
| **Cargo** | Jefe de Sección |
| **Rol técnico** | Clasificador |
| **Responsabilidad** | Categoriza el artículo destilado en la sección correspondiente |
| **Entradas** | Artículo destilado |
| **Salidas** | Artículo con sección asignada y etiquetas |
| **Secciones** | Local · El Bierzo · Astorga y Comarca · Provincia · Sucesos · Cultura · Deportes |
| **Herramientas** | Ollama (LLM local) o clasificador ligero |
| **Modelo LLM** | Por definir |

---

## Maquetador

> *Prepara y publica el artículo en la web y la app.*

| Campo | Detalle |
|---|---|
| **Cargo** | Maquetador |
| **Rol técnico** | Publicador |
| **Responsabilidad** | Persiste el artículo final en PostgreSQL y lo expone vía API para que la web y la app lo consuman |
| **Entradas** | Artículo destilado, categorizado y listo |
| **Salidas** | Registro en base de datos · Endpoint API disponible |
| **Herramientas** | FastAPI · PostgreSQL |
| **Modelo LLM** | No necesario |
