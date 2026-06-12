# Noticias Claras

## Misión

Agregar noticias de múltiples fuentes y reescribirlas de forma **neutral, rigurosa y sin clickbait**. El objetivo es ofrecer información periodística de calidad, generada y supervisada por agentes IA.

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
