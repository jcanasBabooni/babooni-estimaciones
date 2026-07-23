# Babooni — Documentación de desarrollo

Repositorio de **metodología y documentación interna** Babooni: cómo elaborar funcionales, cómo estimar proyectos y cómo implantar el entorno de desarrollo (PaaS).

---

## Mapa del repositorio

```text
babooni-estimaciones/
├── guia-funcional/                 Análisis funcional
├── guia-estimaciones/              Estimaciones de proyecto
└── plan-configuracion-tecnica/     Organización + PaaS / entorno de desarrollo
```

| Icono | Carpeta | Para qué sirve |
|:-----:|---------|----------------|
| 📋 | [guia-funcional](./guia-funcional/) | Plantilla y guía para crear el análisis funcional Babooni |
| ⏱️ | [guia-estimaciones](./guia-estimaciones/) | Plantilla, guía de proceso y ejemplo real de estimación |
| ⚙️ | [plan-configuracion-tecnica](./plan-configuracion-tecnica/) | Plan organizacional y técnico para el nuevo sistema de desarrollo (PaaS) |

---

## 📋 Guía funcional

Documentos para **definir y completar** un análisis funcional al estándar Babooni.

| Icono | Documento | Descripción |
|:-----:|-----------|-------------|
| 📄 | [plantilla-analisis-funcional.docx](./guia-funcional/plantilla-analisis-funcional.docx) | Plantilla base del análisis funcional |
| 📖 | [guia-completar-plantilla-analisis-funcional.html](./guia-funcional/guia-completar-plantilla-analisis-funcional.html) | Guía paso a paso para rellenar la plantilla (estructura, CU, CA, versionado…) |

> 💡 Abrir la guía HTML en el navegador y trabajar sobre la plantilla.

---

## ⏱️ Guía estimaciones

Documentos para **elaborar estimaciones** defendibles (BE + FE [+ UX/UI]) antes de enviar a Dirección.

| Icono | Documento | Descripción |
|:-----:|-----------|-------------|
| 🧭 | [Guia_creacion_estimaciones_Babooni.html](./guia-estimaciones/Guia_creacion_estimaciones_Babooni.html) | Procedimiento completo: funcional → diseño cerrado → estimación → revisión → Dirección → post-OK |
| 📝 | [plantilla_estimaciones.md](./guia-estimaciones/plantilla_estimaciones.md) | Plantilla / metodología de estimación (capacidad, bloques, premisas) |
| 💡 | [EJEMPLO ESTIMACION PROYECTO CAMBIOS DE PUESTO](./guia-estimaciones/EJEMPLO%20ESTIMACION%20PROYECTO%20CAMBIOS%20DE%20PUESTO/) | Ejemplo de estimación del proyecto **Cambios de puesto** |

### Ejemplo incluido

- 📌 [Estimacion_Minerva_Cambio_Puesto.html](./guia-estimaciones/EJEMPLO%20ESTIMACION%20PROYECTO%20CAMBIOS%20DE%20PUESTO/Estimacion_Minerva_Cambio_Puesto.html)

### Orden recomendado

1. ✅ Funcional cerrado (ver Guía funcional)
2. ✅ Diseño UX/UI cerrado
3. ✅ Estimación con la plantilla + guía Babooni
4. ✅ Revisión línea a línea y buffer interno antes de Dirección

---

## ⚙️ Plan configuración técnica

Documentación para **plantear e implantar** el nuevo sistema de desarrollo en Babooni: organización del equipo y configuración técnica orientada a un **PaaS** con un entorno de desarrollo correcto.

| Icono | Documento | Descripción |
|:-----:|-----------|-------------|
| 🏢 | [Plan_Organizacional_Desarrollo.html](./plan-configuracion-tecnica/Plan_Organizacional_Desarrollo.html) | Plan organizacional de desarrollo |
| 🔧 | [Plan_Configuracion_Tecnica.html](./plan-configuracion-tecnica/Plan_Configuracion_Tecnica.html) | Plan de configuración técnica |
| 🚀 | [Plan_Configuracion_Tecnica_Operativo.html](./plan-configuracion-tecnica/Plan_Configuracion_Tecnica_Operativo.html) | Plan operativo de la configuración técnica |

> ☁️ Enfoque: cómo se quiere implantar el PaaS para disponer de un entorno de desarrollo homogéneo, trazable y operable.

---

## 🔄 Flujo rápido

```text
Funcional (plantilla + guía)
        ↓
Diseño UX/UI cerrado
        ↓
Estimación (plantilla + guía Babooni)
        ↓
Revisión interna → Dirección → cliente
        ↓
Post-OK: funcional técnico + QA
```

---

## 📌 Notas

- Uso **interno Babooni**
- Los HTML se abren en el navegador (doble clic o Live Server)
