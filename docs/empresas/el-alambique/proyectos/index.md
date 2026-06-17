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
