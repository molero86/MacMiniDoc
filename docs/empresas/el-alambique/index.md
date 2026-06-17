# El Alambique

## Misión

Destilar noticias de múltiples fuentes eliminando el sensacionalismo y el clickbait, para entregar información periodística **pura, neutral y rigurosa**. Como un alambique separa la esencia del ruido, nuestros agentes IA extraen solo lo que importa.

## Descripción general

| Campo | Detalle |
|---|---|
| **Sector** | Medios / Información |
| **Estado** | 🚧 En construcción |
| **Stack IA** | Ollama + LangGraph |

## Equipo de agentes

Ver [Agentes IA](agentes.md).

## Base de datos

Ver [Base de datos](bbdd.md).

## Proyectos

Ver [Proyectos](proyectos/index.md).

## Stack tecnológico

| Capa | Tecnología |
|---|---|
| Agentes | Python + LangGraph |
| Modelos IA | Ollama (local, Mac Mini M4) |
| Scheduler | APScheduler (cada 6 horas) |
| Base de datos | PostgreSQL |
| API | FastAPI |
| Web | Next.js |
| App | React Native (Expo) — iOS + Android |

## Decisiones operativas actuales

| Tema | Decisión |
|---|---|
| **Ámbito geográfico inicial** | León capital, provincia, Bierzo y Astorga |
| **Fuentes iniciales** | 10 medios definidos en la documentación de fuentes |
| **Modo de ingesta** | RSS cuando exista; scraping cuando no exista |
| **Cadencia** | Un job cada 6 horas |
| **Patrón de orquestación** | Scheduler -> Redactor Jefe -> resto de agentes |
| **Unidad editorial real** | Una cobertura compuesta a partir de varias fuentes relacionadas |
| **Persistencia obligatoria** | Todos los artículos procesados y eventos del pipeline |
| **Canales de salida** | API, web y app móvil |

## Flujo de la redacción

```
[10 fuentes de León — RSS / Web]
          ↓
    Corresponsal       — extrae artículos nuevos cada 6h
          ↓
    Documentalista     — agrupa artículos en coberturas
          ↓
    Redactor           — redacta una pieza compuesta desde varias fuentes
          ↓
    Jefe de Sección    — categoriza la noticia
          ↓
    Maquetador         — persiste en BD y expone vía API
          ↓
  [Web Next.js]  [App React Native]

  ── Redactor Jefe orquesta todo el flujo (LangGraph) ──
```

## Regla editorial estructural

El Alambique no publicará una pieza por cada artículo detectado. La unidad de publicación será una **cobertura** o **historia**:

- varios artículos de distintos medios pueden pertenecer a la misma cobertura
- el sistema evita publicar duplicados sobre el mismo hecho
- el Redactor compone una única pieza editorial usando varias fuentes del mismo acontecimiento
- siempre debe mantenerse trazabilidad hacia todas las fuentes utilizadas

## Secciones

- Local (León capital)
- El Bierzo
- Astorga y Comarca
- Provincia
- Sucesos
- Cultura
- Deportes

## Qué queda por definir antes de programar

- feeds RSS reales disponibles por medio
- modelo Ollama principal y modelo de reserva
- política editorial para artículos incompletos o contradictorios
- reglas de priorización si entran demasiadas noticias en un mismo lote
