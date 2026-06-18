# Domus Gestión

## Misión

Operar como una **gestoría financiera del hogar** con disciplina de pyme: registrar movimientos, clasificar gastos, planificar tesorería y emitir informes accionables, todo asistido por agentes IA.

## Descripción general

| Campo | Detalle |
|---|---|
| **Sector** | Finanzas personales / Hogar (modelo gestoría) |
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
[Contable de Datos]   — parsea y normaliza datos
        ↓
[Clasificador Fiscal] — categoriza cada gasto
        ↓
[Analista Financiero] — detecta tendencias, genera alertas
        ↓
[Informe mensual + presupuesto + alertas]
```
