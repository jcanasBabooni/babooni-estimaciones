# Estimaciones Babooni / Vitaly

Repositorio centralizado de documentación, estimaciones y seguimiento de proyectos MINERVA para Vitaly.

## Estructura

| Carpeta | Contenido |
|---------|-----------|
| `registro-horas/` | Registro horario Fase II — alcance, estimación, seguimiento CA, informes |
| `justificantes-asistencias/` | Justificante de asistencia — funcional, estimación, seguimiento |
| `cambios-puesto/` | Cambio de puesto RM — documentación técnica, QA, entregables |
| `plantilla-estimaciones/` | Metodología y plantilla base para nuevas estimaciones |
| `guia/` | Guía de pasos antes de enviar estimación a Vitaly |
| `clickUps/` | Exportaciones CSV para ClickUp |
| `jira/` | Exportaciones CSV para Jira |
| `funcionales-vitaly-md/` | Documentos funcionales Vitaly en Markdown |
| `cursor-rules/` | Reglas y convenciones para trabajo con Cursor |

## Convenciones

- **Seguimiento**: los CSV `Seguimiento_CA_*.csv` son la fuente de verdad del estado de criterios de aceptación.
- **Estimaciones**: HTML/Markdown por proyecto; versiones de entrega en subcarpetas `entrega-*`.
- **Exportaciones**: CSV de ClickUp/Jira/Monday en sus carpetas correspondientes.

## Metodología

Ver [plantilla-estimaciones/plantilla_estimaciones.md](plantilla-estimaciones/plantilla_estimaciones.md) para capacidad del equipo, criterios de estimación BE/FE y restricciones de alcance.

## Flujo de trabajo

```bash
# Clonar (tras crear el repo remoto)
git clone <url>
cd estimaciones

# Actualizar cambios locales
git add .
git commit -m "Descripción del cambio"
git push
```
