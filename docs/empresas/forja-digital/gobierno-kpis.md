# Gobierno y KPIs — Forja Digital

## Gobierno operativo

| Rol | Responsabilidad |
|---|---|
| Director de Operaciones | Priorizar iniciativas y aprobar gates |
| Product Manager IA | Control de alcance y valor de producto |
| Arquitecto Tecnico | Control de riesgo tecnico |
| Growth Lead IA | Control de traccion y crecimiento |

## KPIs de ejecucion (factoria)

| KPI | Formula | Objetivo inicial |
|---|---|---|
| Lead time a MVP | dias desde Discovery hasta primer release | <= 30 dias |
| Throughput mensual | numero de iniciativas que alcanzan release | >= 1 |
| Gate pass rate | iniciativas que pasan gate / iniciativas evaluadas | >= 60% |
| Rework rate | iniciativas que requieren retrabajo | <= 30% |
| Kill rate temprano | iniciativas canceladas en Discovery/Definicion | >= 20% |

## KPIs de producto (por iniciativa)

| KPI | Formula | Objetivo inicial |
|---|---|---|
| Activacion | usuarios que completan accion clave / registros | >= 25% |
| Retencion 7 dias | usuarios activos dia 7 / cohort inicial | >= 20% |
| CAC inicial | gasto de captacion / nuevos usuarios activos | por definir |
| Tiempo a valor | tiempo medio hasta accion de valor | <= 10 min |

## Reglas de decision

- Si una iniciativa falla 2 gates consecutivos: `hold` o `kill`.
- Si supera objetivos 2 semanas seguidas: priorizar escalado.
- Si el coste de oportunidad sube frente a otras iniciativas: reevaluar prioridad.

## Cadencia de reporting

- Diario: bloqueos y estado de entrega.
- Semanal: KPIs de pipeline y decision por iniciativa.
- Mensual: balance de portfolio y reasignacion de capacidad.
