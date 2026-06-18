# Agentes IA — Argos Capital

## Analista Macro

| Campo | Detalle |
|---|---|
| **Rol** | Determinar contexto macro y régimen de mercado |
| **Entradas** | Tipos de interés, inflación, empleo, liquidez, curva de tipos, noticias macro |
| **Salidas** | Escenario macro + sesgo de riesgo (`risk_on`, `risk_off`, `neutral`) |
| **Herramientas** | Series temporales, fuentes macro, LLM para síntesis |

## Selector de Activos

| Campo | Detalle |
|---|---|
| **Rol** | Identificar y puntuar activos candidatos |
| **Entradas** | Universo de activos, métricas técnicas/fundamentales, señales macro |
| **Salidas** | Ranking de activos con score y justificación |
| **Herramientas** | Modelos cuantitativos + LLM para razonamiento asistido |

## Gestor de Cartera

| Campo | Detalle |
|---|---|
| **Rol** | Definir pesos de cartera y plan de rebalanceo |
| **Entradas** | Ranking de activos + restricciones de riesgo |
| **Salidas** | Cartera objetivo, pesos, cambios respecto a cartera previa |
| **Herramientas** | Optimización de cartera, reglas de rebalanceo |

## Control de Riesgo

| Campo | Detalle |
|---|---|
| **Rol** | Aplicar límites y frenos de riesgo antes de ejecutar |
| **Entradas** | Cartera objetivo, volatilidad, correlaciones, liquidez |
| **Salidas** | Cartera aprobada/ajustada + alertas de riesgo |
| **Herramientas** | VaR, drawdown, stress test |
