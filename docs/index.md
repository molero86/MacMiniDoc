# Mac Mini M4 — Cuartel General

Bienvenido al centro de documentación de todos los proyectos desplegados en el **Mac Mini M4 (48 GB RAM)**.

Este repositorio sirve como fuente de verdad para las empresas, agentes IA y proyectos que corren sobre este servidor.

---

## Empresas activas

| Empresa | Descripción | Estado |
|---|---|---|
| [El Alambique](empresas/el-alambique/index.md) | Periodismo destilado, sin sensacionalismo ni clickbait | 🚧 En construcción |
| [Domus Gestión](empresas/domus-gestion/index.md) | Gestoría financiera del hogar con enfoque de pyme | 🚧 En construcción |
| [Argos Capital](empresas/argos-capital/index.md) | Gestora de inversión orientada a maximizar rentabilidad ajustada a riesgo | 🚧 En construcción |
| [Forja Digital](empresas/forja-digital/index.md) | Factoría integral: detecta oportunidades, construye producto y lo lanza al mercado | 🚧 En construcción |

---

## Servidor

- **Hardware:** Apple Mac Mini M4 · 48 GB RAM
- **SO:** macOS (Apple Silicon)
- **Modelos IA locales:** Ollama
- **Orquestación agentes:** LangGraph + CrewAI

Ver [detalles del servidor](servidor/hardware.md).

---

## Estrategia de Arranque

Para arrancar con el menor riesgo posible:

1. **Forja Digital Lite** (marco operativo mínimo).
2. **El Alambique** como primer producto real construido con ese marco.
3. Convertir aprendizajes en estándares de Forja y reutilizarlos en Domus y Argos.

## Roadmap 30 Días

### Semana 1 — Forja Digital Lite

- Definir flujo mínimo de ejecución: descubrimiento -> PRD -> arquitectura -> entrega -> lanzamiento.
- Crear plantillas operativas mínimas (PRD, checklist técnico, checklist de lanzamiento).
- Definir métricas de control de proyecto (tiempo, coste, calidad, adopción inicial).
- Resultado esperado: Forja lista para ejecutar un primer proyecto real.

### Semana 2 — El Alambique Core

- Implementar pipeline de agentes y base de datos con el modelo de coberturas multi-fuente.
- Integrar 10 fuentes iniciales de León (RSS o scraping según disponibilidad).
- Ejecutar lotes programados cada 6 horas en entorno local.
- Resultado esperado: artículos compuestos generados y guardados en base de datos.

### Semana 3 — API + Web Inicial de El Alambique

- Exponer endpoints de portada, sección y detalle.
- Publicar web inicial para lectura de coberturas.
- Validar calidad editorial (neutralidad, no clickbait, trazabilidad de fuentes).
- Resultado esperado: versión utilizable de El Alambique en web.

### Semana 4 — Estabilización y Estandarización

- Añadir observabilidad y alarmas básicas de pipeline.
- Corregir fallos de clasificación, deduplicación y publicación.
- Formalizar playbook de Forja con lecciones del primer producto.
- Resultado esperado: método repetible para lanzar Domus Gestión y Argos Capital.
