# Modelo Operativo — Forja Digital

## Objetivo

Convertir ideas en productos reales con un proceso repetible, medible y con decisiones de inversión de tiempo/capital basadas en evidencia.

## Fases y Gates

| Fase | Objetivo | Entregable | Gate de salida |
|---|---|---|---|
| Discovery | Detectar oportunidad | Opportunity Brief | Problema real + mercado suficiente |
| Definicion | Diseñar producto | PRD + backlog + KPI objetivo | Alcance acotado y medible |
| Arquitectura | Reducir riesgo tecnico | ADR + arquitectura + plan de entrega | Riesgos criticos mitigados |
| Delivery | Construir MVP | Release candidata | Calidad minima cumplida |
| Go-To-Market | Lanzar y captar usuarios | Plan GTM + embudo + medicion | Traccion inicial validada |

## Compuertas (decisiones)

Cada iniciativa recibe una decision formal al final de cada fase:

- `go`: avanza a la siguiente fase
- `rework`: vuelve a la fase actual con acciones concretas
- `hold`: se congela por falta de capacidad o contexto
- `kill`: se cancela por baja viabilidad

## Artefactos obligatorios por iniciativa

- Opportunity Brief
- PRD v1
- Architecture Decision Record (ADR)
- Plan de entrega por sprints
- Checklist de release
- Reporte de resultados a 7 y 30 dias

## Ciclo semanal

| Dia | Actividad |
|---|---|
| Lunes | Seleccion de iniciativas y prioridades |
| Martes | Refinamiento de producto y arquitectura |
| Miercoles | Entrega tecnica y pruebas |
| Jueves | Preparacion de release y GTM |
| Viernes | Revision de KPIs y decisiones de gate |

## Regla de capacidad

Forja Lite ejecuta **1 iniciativa principal** y **1 iniciativa en discovery** en paralelo.  
No se abre una tercera sin cerrar una de las anteriores para evitar dispersion.
