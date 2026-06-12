# Agentes IA — Noticias Claras

## Agente Recopilador

| Campo | Detalle |
|---|---|
| **Rol** | Monitorizar fuentes y extraer artículos nuevos |
| **Entradas** | Lista de fuentes RSS / URLs |
| **Salidas** | Artículos en bruto (título, cuerpo, fuente, fecha) |
| **Herramientas** | `feedparser`, `requests`, `BeautifulSoup` |
| **Modelo LLM** | No necesario (extracción estructurada) |
| **Frecuencia** | Cada X horas (a definir) |

## Agente Redactor

| Campo | Detalle |
|---|---|
| **Rol** | Reescribir artículos de forma neutral y sin clickbait |
| **Entradas** | Artículo en bruto |
| **Salidas** | Artículo reescrito (título neutral, cuerpo limpio) |
| **Herramientas** | LLM local vía Ollama |
| **Modelo LLM** | Por definir (ej. `llama3.1`, `qwen2.5`) |
| **Prompt guía** | Redacta sin sensacionalismo, cita hechos verificables |

## Agente Publicador

| Campo | Detalle |
|---|---|
| **Rol** | Publicar artículos procesados en la web |
| **Entradas** | Artículo reescrito |
| **Salidas** | Página HTML / post publicado |
| **Herramientas** | Por definir |
| **Estado** | 🚧 Por diseñar |
