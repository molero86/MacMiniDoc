# Agentes IA — Domus Gestión

## Contable de Datos

| Campo | Detalle |
|---|---|
| **Rol** | Leer y normalizar datos de gastos desde múltiples fuentes |
| **Entradas** | CSV de extractos bancarios, facturas PDF, tickets de imagen |
| **Salidas** | Lista de transacciones normalizadas |
| **Herramientas** | `pandas`, OCR (por definir) |
| **Modelo LLM** | Opcional para extracción de PDFs complejos |

## Clasificador Fiscal

| Campo | Detalle |
|---|---|
| **Rol** | Categorizar cada gasto (alimentación, transporte, ocio...) |
| **Entradas** | Transacción normalizada (descripción, importe, fecha) |
| **Salidas** | Transacción con categoría asignada y confianza |
| **Herramientas** | LLM local vía Ollama |
| **Modelo LLM** | Por definir |

## Analista Financiero

| Campo | Detalle |
|---|---|
| **Rol** | Analizar tendencias, detectar anomalías y generar informes |
| **Entradas** | Historial de transacciones clasificadas |
| **Salidas** | Informe mensual, alertas de gasto inusual |
| **Herramientas** | `pandas`, `matplotlib`, LLM para redactar el informe |
| **Estado** | 🚧 Por diseñar |
