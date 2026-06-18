# Proyectos — El Alambique

| Proyecto | Repositorio | Descripción | Estado |
|---|---|---|---|
| **el-alambique-agents** | — | Pipeline de agentes (Corresponsal, Documentalista, Redactor, Jefe de Sección, Maquetador) | 🚧 En construcción |
| **el-alambique-api** | — | API REST con FastAPI que expone los artículos destilados | 🚧 En construcción |
| **el-alambique-web** | — | Web periodística con Next.js | 🚧 En construcción |
| **el-alambique-app** | — | App móvil con React Native (Expo) para iOS y Android | 🚧 En construcción |

## Reparto de responsabilidades

### el-alambique-agents

- contiene el scheduler APScheduler
- contiene el grafo LangGraph del Redactor Jefe
- implementa Corresponsal, Documentalista, Redactor, Jefe de Sección y Maquetador
- registra ejecuciones, métricas y errores del pipeline

### el-alambique-api

- expone artículos, secciones, búsqueda y detalle
- ofrece endpoints internos para salud, métricas y revisión manual
- actúa como capa de acceso a PostgreSQL para clientes externos
- no escribe lógica editorial; consume la verdad ya preparada en `articles` y tablas auxiliares

### el-alambique-web

- consume la API pública
- muestra portada, listados por sección y detalle de noticia
- incorpora buscador, navegación por secciones y diseño editorial

### el-alambique-app

- consume la misma API que la web
- ofrece portada móvil, lectura por secciones y guardado local
- permite notificaciones push en una fase posterior

## Orden recomendado de construcción

1. `el-alambique-agents`
2. `el-alambique-api`
3. `el-alambique-web`
4. `el-alambique-app`

## Definición de hecho mínima por proyecto

| Proyecto | Debe quedar listo cuando... |
|---|---|
| **el-alambique-agents** | Sea capaz de procesar un lote completo y publicar artículos en la base de datos |
| **el-alambique-api** | Exponga artículos publicados y filtros básicos por sección y fecha |
| **el-alambique-web** | Permita leer la portada y el detalle de noticia con buena experiencia móvil y escritorio |
| **el-alambique-app** | Permita consultar portada, secciones y detalle desde iOS y Android |

## Dependencias de arranque

| Proyecto | Depende primero de |
|---|---|
| **el-alambique-agents** | esquema PostgreSQL y configuración de fuentes |
| **el-alambique-api** | tablas `articles`, `article_tags`, `sources` |
| **el-alambique-web** | endpoints estables de portada, sección y detalle |
| **el-alambique-app** | los mismos endpoints que la web |

## Plan de ejecución (30 días)

### Semana 1

- cerrar fuentes de entrada y validar RSS/scraping por medio
- preparar entorno y esquema PostgreSQL
- scaffold de `el-alambique-agents`

### Semana 2

- implementar Corresponsal + Documentalista + agrupación en coberturas
- ejecutar jobs cada 6 horas
- persistir resultados de pipeline y errores

### Semana 3

- implementar Redactor + Jefe de Sección + Maquetador
- habilitar `el-alambique-api` con endpoints base
- publicar una web inicial de lectura

### Semana 4

- ajustar calidad editorial y deduplicación
- mejorar observabilidad y alertas
- preparar backlog de `el-alambique-app`
