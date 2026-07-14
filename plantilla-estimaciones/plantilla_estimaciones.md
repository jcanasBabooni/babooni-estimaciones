# Metodología de Estimación de Proyectos

## Objetivo

Generar estimaciones homogéneas para proyectos cerrados de desarrollo software, permitiendo comparar proyectos entre sí y obtener fechas de entrega realistas.

## Equipo de Desarrollo

Todos los proyectos disponen de:

- 1 desarrollador Backend
- 1 desarrollador Frontend

Tecnologías habituales:

- Backend: Java 17 + Spring Boot
- Frontend: Angular

## Capacidad

### Jornada laboral

- 40 horas semanales por recurso

### Sprint

- Duración: 2 semanas
- Capacidad por recurso: 80 horas por sprint
- Capacidad total del equipo: 160 horas por sprint

### Disponibilidad real

Las estimaciones deben considerar que no todo el tiempo se dedica a desarrollo.

Aplicar factor de productividad del 80%.

Capacidad efectiva:

- Backend: 64 horas por sprint
- Frontend: 64 horas por sprint
- Equipo completo: 128 horas por sprint

## Restricciones

- La duración total del proyecto no debe superar los 2 meses.
- Máximo recomendado:
  - 4 sprints
  - 320 horas efectivas por recurso
  - 640 horas efectivas totales

Si la estimación supera estos límites, debe proponerse:
- Reducción de alcance.
- División en fases.
- Entregas parciales.

---

# Criterios de Estimación

## Backend

Valorar:

### Análisis técnico

- Comprensión de requisitos.
- Diseño funcional.
- Diseño técnico.

### Base de datos

- Nuevas tablas.
- Modificaciones de tablas existentes.
- Índices.
- Migraciones.

### API

- Nuevos endpoints.
- Modificación de endpoints existentes.
- Integraciones externas.
- Seguridad y permisos.

### Lógica de negocio

- Validaciones.
- Procesos complejos.
- Cálculos.
- Automatizaciones.

### Testing

- Unit tests.
- Integration tests.
- Validación funcional.

---

## Frontend

Valorar:

### Análisis funcional

- Comprensión de requisitos.
- Diseño de experiencia de usuario.

### Desarrollo UI

- Pantallas nuevas.
- Formularios.
- Tablas.
- Modales.
- Dashboards.

### Integración

- Consumo de APIs.
- Gestión de estados.
- Validaciones.

### Testing

- Validaciones funcionales.
- Pruebas manuales.
- Correcciones.

---

# Actividades Transversales

Siempre incluir:

## Gestión

- Reuniones de seguimiento.
- Refinamiento.
- Planificación.
- Demo.

## QA

- Validación funcional.
- Corrección de incidencias.

## Despliegue

- Preparación de entorno.
- Configuración.
- Verificación post-despliegue.

---

# Niveles de Complejidad

## Baja

Características:

- CRUD simple.
- Hasta 3 pantallas.
- Hasta 5 endpoints.
- Sin integraciones externas.

Referencia:

- Backend: 16-32 horas
- Frontend: 16-32 horas

## Media

Características:

- Varias entidades relacionadas.
- Reglas de negocio moderadas.
- Entre 5 y 15 endpoints.
- Informes sencillos.

Referencia:

- Backend: 40-80 horas
- Frontend: 40-80 horas

## Alta

Características:

- Procesos complejos.
- Integraciones externas.
- Automatizaciones.
- Cálculos complejos.
- Roles y permisos avanzados.

Referencia:

- Backend: 80-160 horas
- Frontend: 80-160 horas

---

# Formato de Salida Esperado

## Resumen

- Nombre del proyecto
- Objetivo
- Complejidad global

## Desglose Backend

| Tarea | Horas |
|---------|---------|
| Análisis | X |
| Base de datos | X |
| APIs | X |
| Lógica de negocio | X |
| Testing | X |
| Total Backend | X |

## Desglose Frontend

| Tarea | Horas |
|---------|---------|
| Análisis | X |
| Pantallas | X |
| Integración APIs | X |
| Validaciones | X |
| Testing | X |
| Total Frontend | X |

## Actividades Transversales

| Tarea | Horas |
|---------|---------|
| Gestión | X |
| QA | X |
| Despliegue | X |
| Total | X |

## Resumen Final

| Concepto | Horas |
|-----------|-----------|
| Backend | X |
| Frontend | X |
| Transversal | X |
| Total Proyecto | X |

## Planificación

| Sprint | Actividades |
|----------|------------|
| Sprint 1 | ... |
| Sprint 2 | ... |
| Sprint 3 | ... |
| Sprint 4 | ... |

## Fecha estimada

- Duración total:
- Número de sprints:
- Riesgos identificados:
- Suposiciones realizadas: