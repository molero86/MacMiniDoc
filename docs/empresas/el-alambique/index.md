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

## Proyectos

Ver [Proyectos](proyectos/index.md).

## Arquitectura de alto nivel

```
[Fuentes RSS / Web] 
        ↓
[Agente Recopilador] — extrae artículos
        ↓
[Agente Redactor]    — neutraliza tono, elimina clickbait
        ↓
[Agente Publicador]  — genera HTML y publica en la web
```
