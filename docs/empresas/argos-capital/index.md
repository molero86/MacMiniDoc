# Argos Capital

## Misión

Diseñar y gestionar estrategias de inversión para crear un fondo de alto rendimiento ajustado a riesgo, combinando análisis cuantitativo, señales macro y ejecución disciplinada.

## Descripción general

| Campo | Detalle |
|---|---|
| **Sector** | Inversión y gestión de carteras |
| **Estado** | 🚧 En construcción |
| **Stack IA** | Ollama + LangGraph |

## Equipo de agentes

Ver [Agentes IA](agentes.md).

## Proyectos

Ver [Proyectos](proyectos/index.md).

## Arquitectura de alto nivel

```
[Datos de mercado + macro + noticias + on-chain]
        ↓
[Analista Macro]      — detecta régimen de mercado
        ↓
[Selector de Activos] — puntúa activos y construye universo elegible
        ↓
[Gestor de Cartera]   — asignación de pesos y rebalanceo
        ↓
[Control de Riesgo]   — límites, drawdown, correlación, VaR
        ↓
[Informe de Fondo + señales de ejecución]
```
