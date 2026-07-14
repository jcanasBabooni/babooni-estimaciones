# 01 - Informe ejecutivo y estimacion - Registro Horario Fase II

**Fecha:** 2026-06-23  
**Proyecto:** Registro Horario - Fase II  
**Audiencia:** direccion, jefatura de proyecto, Product Owner, responsables de negocio y responsables tecnicos.  
**Objetivo:** resumir el estado real de Fase II, el riesgo de estimacion, el alcance principal y la recomendacion de planificacion.

---

## 1. Conclusion principal

La Fase II no debe firmarse como estimacion cerrada sin resolver antes varias decisiones funcionales y tecnicas. No es una ampliacion simple de pantallas de Fase I: introduce nuevas reglas de seguridad, nuevos roles, acceso externo, anonimato, informes Excel y suplantacion.

El sistema actual tiene una base tecnica aprovechable, pero los elementos nuevos de Fase II son transversales y afectan permisos, APIs, modelos frontend, calculos, historicos, exportaciones, auditoria, datos de prueba y tests E2E.

| Punto clave | Conclusion |
|---|---|
| Estado actual para estimacion cerrada | No firmable con seguridad. |
| Estimacion util para planificacion | 6 sprints / 870 h como escenario condicionado. |
| Escenario de gestion recomendado | 7-8 sprints / 1015-1160 h si se cierran reglas durante desarrollo. |
| Principal riesgo | Descubrir tarde reglas de negocio no escritas sobre permisos, anonimato, informes y datos historicos. |
| Recomendacion | Ejecutar primero un cierre funcional/tecnico corto y despues cerrar estimacion. |

---

## 2. Alcance principal de Fase II

| Bloque | Descripcion | Estado |
|---|---|---|
| Modulo de Informes | Nueva pantalla con filtros, tabla, paginacion y exportacion XLSX en formatos tabla, simple diario y detallado por tramos. | Bloqueante hasta cerrar reglas. |
| Inspector/a | Acceso externo, solo lectura, empresas autorizadas, usuarios anonimizados, KPIs, ficha de consulta e informes anonimos. | Bloqueante por modelo, privacidad y permisos. |
| RLPT | Perfil que hereda parte del usuario y accede a Informes. | Bloqueante por naturaleza del rol, ambito y privacidad. |
| Accesos externos | Alta, invitacion, caducidad, revocacion, duplicados, multiempresa e integracion con Keycloak/email. | Bloqueante por ciclo de vida no definido. |
| Superadmin | Modo simulacion reforzado y posible suplantacion de usuario. | Bloqueante por seguridad y auditoria. |
| Datos historicos | Informes y anonimato sobre registros ya existentes. | Bloqueante por datos incompletos o sensibles. |
| QA/UAT | Dataset oficial con resultados esperados. | Bloqueante para validar calculos y Excel. |

---

## 3. Estado real del sistema actual

### 3.1 Backend

| Area | Estado actual | Lectura para Fase II |
|---|---|---|
| Usuarios y empresas | Existe CRUD, listado, detalle, resumen e importacion CSV. | Reutilizable, pero requiere permisos nuevos y DTOs anonimos. |
| Fichajes e historial | Existen fichaje, historico mensual y export CSV. | Base para informes, pero falta XLSX y reglas de tramos problematicos. |
| Compensaciones | Existen movimientos, resumen, manuales y export CSV. | Riesgo por comentarios sensibles. |
| Planificacion/calendario | Existe configuracion y planificacion con auditoria. | Afecta calculos, festivos, ausencias e historicos. |
| Seguridad | Hay checks actuales y soporte tecnico para roles externos. | No hay matriz Inspector/RLPT ni bloqueo read-only global. |
| Auditoria | Hay infraestructura y eventos actuales. | Faltan eventos de Fase II: acceso externo, export XLSX, consulta anonima y suplantacion. |
| Exportaciones | Actualmente CSV. | Fase II requiere motor XLSX. |

### 3.2 Frontend

| Area | Estado actual | Lectura para Fase II |
|---|---|---|
| Roles | `superadmin`, `admin`, `usuario`. | Falta Inspector/RLPT. |
| Rutas | No existe ruta de Informes ni accesos externos. | Hay que crear modulo nuevo. |
| Permisos | Hay permisos para pantallas actuales. | Falta matriz multirol Fase II. |
| Simulacion | Muchas acciones ya se deshabilitan en frontend. | Falta defensa backend y aplicacion a pantallas nuevas. |
| Usuarios/ficha | Modulos reutilizables. | Necesitan anonimizacion y solo lectura real. |
| Exportaciones | CSV existentes. | Falta XLSX y contratos por rol. |

---

## 4. Lo que ya no debe tratarse como bloqueante

| Area | Decision ya detectada | Como tratarlo |
|---|---|---|
| CSV actual | El comportamiento de importacion parcial/atomica del CSV actual ya esta implementado y probado. | No mantenerlo como duda bloqueante; si como regresion QA. |
| UX de simulacion existente | El frontend actual ya deshabilita muchas acciones en modo simulacion. | No mantenerlo como bloqueante para pantallas existentes; si exigir consistencia en pantallas nuevas. |
| Roles externos tecnicos | Existe infraestructura tecnica de roles externos. | No preguntar si hay base tecnica; preguntar si se adopta como modelo oficial para Inspector/RLPT. |

---

## 5. Riesgos ejecutivos

| Riesgo | Probabilidad | Impacto | Consecuencia si aparece tarde |
|---|---|---|---|
| Matriz de permisos no cerrada | Alta | Alto | Rehacer guards, endpoints, menus, tests y UAT. |
| Anonimizacion insuficiente | Alta | Alto | Fuga de datos en API, UI, Excel o logs. |
| Informes XLSX mal definidos | Alta | Alto | Rehacer columnas, calculos, exports y pruebas golden. |
| RLPT ambiguo | Alta | Alto | Rehacer rol, rutas y permisos si era trabajador/externo distinto a lo implementado. |
| Accesos externos sin ciclo de vida | Alta | Alto | Rehacer modelo de datos, estados, revocacion y Keycloak/email. |
| Datos historicos incompletos | Media | Alto | Fallos en produccion aunque dev/UAT pase con datos limpios. |
| Suplantacion mal acotada | Media | Alto | Riesgo de seguridad y auditoria insuficiente. |
| Volumen de exportacion no definido | Media | Alto | Timeouts o consumo excesivo en produccion. |
| Dataset UAT ausente | Alta | Alto | Discusiones de aceptacion caso por caso. |

---

## 6. Estimacion consolidada

| Escenario | Duracion | Horas aprox. | Condicion |
|---|---:|---:|---|
| Optimista condicionado | 5 sprints | 725 h | Solo si todas las decisiones se cierran antes de desarrollo y no cambia alcance. No recomendable como compromiso actual. |
| Probable condicionado | 6 sprints | 870 h | Escenario base si las decisiones se cierran al inicio y UAT no introduce reglas nuevas. |
| Conservador | 7-8 sprints | 1015-1160 h | Escenario realista si las decisiones se cierran durante desarrollo o aparecen ajustes de privacidad, rendimiento o historicos. |
| No cerrable | No aplica | No aplica | Situacion actual si se exige compromiso cerrado sin resolver bloqueantes. |

Distribucion probable por bloques:

| Bloque | Horas probables | Comentario |
|---|---:|---|
| Cierre funcional/tecnico | 40 | Necesario antes de codificar. |
| Roles, permisos y acceso externo | 105 | Transversal backend/frontend. |
| Gestion de accesos externos | 65 | Alta, estados, revocacion e integraciones. |
| Informes Admin/RLPT | 135 | Filtros, calculos, tabla y XLSX. |
| Inspector/a | 165 | Ambito, anonimato, KPIs, ficha y exports. |
| RLPT | 45 | Bajo solo si se confirma herencia simple. |
| Superadmin/suplantacion | 70 | Suplantacion es el mayor riesgo del bloque. |
| i18n/UX | 55 | Mensajes, estados vacios, errores y 5 idiomas. |
| Tests/regresion | 105 | Backend, frontend, E2E y golden XLSX. |
| Hardening/rendimiento/UAT | 85 | Correcciones, limites y datos reales. |
| **Total probable** | **870 h** | Aproximadamente 6 sprints de 145 h comprometidas. |

---

## 7. Recomendacion de planificacion

1. No cerrar fecha contractual sin resolver decisiones bloqueantes.
2. Usar 6 sprints como hipotesis condicionada, no como compromiso firme.
3. Mantener 7-8 sprints como escenario de gestion.
4. Hacer una fase corta de cierre funcional/tecnico centrada en permisos, Inspector/RLPT, Informes, anonimato, datos historicos, suplantacion y dataset UAT.
5. Convertir cada decision en criterio verificable antes de pasarla a backlog.

---

## 8. Entregables finales recomendados

Este documento debe convivir con estos tres informes:

| Informe | Uso |
|---|---|
| `02-decisiones-preguntas-bloqueantes-fase2.md` | Reuniones de cierre con negocio y equipo tecnico. |
| `03-planificacion-backlog-fase2.md` | Preparacion de sprints, epicas y tareas estimables. |
| `04-qa-casuisticas-tests-fase2.md` | QA, dataset UAT, Playwright, unitarios e integracion. |
