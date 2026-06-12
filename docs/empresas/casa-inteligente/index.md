# Casa Inteligente

## Misión

Llevar la **contabilidad completa del hogar** de forma automática: importar gastos, clasificarlos, detectar patrones y generar informes periódicos, todo gestionado por agentes IA.

## Descripción general

| Campo | Detalle |
|---|---|
| **Sector** | Finanzas personales / Hogar |
| **Estado** | 🚧 En construcción |
| **Stack IA** | Ollama + LangGraph |

## Equipo de agentes

Ver [Agentes IA](agentes.md).

## Proyectos

Ver [Proyectos](proyectos/index.md).

## Arquitectura de alto nivel

```
[Extractos bancarios / Tickets / Facturas]
        ↓
[Agente Importador]   — parsea y normaliza datos
        ↓
[Agente Clasificador] — categoriza cada gasto
        ↓
[Agente Analista]     — detecta tendencias, genera alertas
        ↓
[Informe mensual PDF/HTML]
```
