# Agentes IA — Forja Digital

## Cadencia y orquestación

| Elemento | Definición |
|---|---|
| **Cadencia de ejecución** | Ciclos semanales (lunes a domingo) |
| **Disparo principal** | Reunión de pipeline (o job planificado) |
| **Orquestador** | Director de Operaciones (agente orquestador) |
| **Unidad de trabajo** | Una iniciativa de producto |
| **Salida de ciclo** | Decisión de continuar, pivotar o descartar |

## Flujo de llamadas

```text
Director de Operaciones
	-> Scout de Oportunidades
	-> Product Manager IA
	-> Arquitecto Tecnico
	-> Equipo de Entrega
	-> Growth Lead IA
	-> Director de Operaciones (decision de gate)
```

## Director de Operaciones

| Campo | Detalle |
|---|---|
| **Rol** | Orquestar el pipeline y aplicar compuertas de calidad |
| **Entradas** | Estado de iniciativas, metricas, entregables de cada agente |
| **Salidas** | Decisiones de gate: `go`, `rework`, `kill`, `hold` |
| **Herramientas** | Reglas de negocio, scorecards, checklists |

## Scout de Oportunidades

| Campo | Detalle |
|---|---|
| **Rol** | Detectar problemas de mercado con señal de compra |
| **Entradas** | Tendencias, búsquedas, foros, marketplaces, feedback de usuarios |
| **Salidas** | Lista priorizada de ideas con hipótesis de negocio |
| **Herramientas** | Scraping, NLP, análisis de tendencias |

### Contrato operativo

| Elemento | Definición |
|---|---|
| **Lo invoca** | Director de Operaciones |
| **Frecuencia** | Semanal o bajo demanda |
| **Criterio de salida** | Entregar backlog de ideas con score de oportunidad |

## Product Manager IA

| Campo | Detalle |
|---|---|
| **Rol** | Convertir la idea en producto viable |
| **Entradas** | Idea priorizada, restricciones técnicas y de negocio |
| **Salidas** | PRD, roadmap, backlog inicial y criterios de éxito |
| **Herramientas** | Plantillas de producto, LLM para estructuración |

### Contrato operativo

| Elemento | Definición |
|---|---|
| **Lo invoca** | Director de Operaciones |
| **Frecuencia** | Por iniciativa validada en discovery |
| **Criterio de salida** | PRD completo + backlog priorizado + metricas objetivo |

## Arquitecto Técnico

| Campo | Detalle |
|---|---|
| **Rol** | Definir arquitectura y decisiones técnicas clave |
| **Entradas** | PRD, NFRs, expectativas de coste/escala |
| **Salidas** | Diseño técnico, stack recomendado, riesgos y trade-offs |
| **Herramientas** | Patrones de arquitectura, análisis de coste-rendimiento |

### Contrato operativo

| Elemento | Definición |
|---|---|
| **Lo invoca** | Director de Operaciones |
| **Frecuencia** | Una vez aprobado PRD |
| **Criterio de salida** | Arquitectura aprobada + riesgos mitigados + plan de entrega |

## Equipo de Entrega

| Campo | Detalle |
|---|---|
| **Rol** | Construir el producto de extremo a extremo |
| **Entradas** | Backlog priorizado + arquitectura validada |
| **Salidas** | MVP funcional, pruebas, despliegue y observabilidad básica |
| **Herramientas** | CI/CD, testing, IaC, frameworks según proyecto |

### Contrato operativo

| Elemento | Definición |
|---|---|
| **Lo invoca** | Director de Operaciones |
| **Frecuencia** | Ciclos semanales de build |
| **Criterio de salida** | Incremento desplegable + pruebas verdes + observabilidad minima |

## Growth Lead IA

| Campo | Detalle |
|---|---|
| **Rol** | Diseñar y ejecutar estrategia de lanzamiento y crecimiento |
| **Entradas** | Producto desplegado, propuesta de valor, ICP |
| **Salidas** | Plan de canales, copy, campañas y métricas de adquisición |
| **Herramientas** | SEO/SEM, contenido, analítica y experimentación |

### Contrato operativo

| Elemento | Definición |
|---|---|
| **Lo invoca** | Director de Operaciones |
| **Frecuencia** | Desde primera release candidata |
| **Criterio de salida** | Plan de lanzamiento + embudo inicial + metricas de adquisicion |
