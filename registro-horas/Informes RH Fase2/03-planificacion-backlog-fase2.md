# 03 - Planificacion y backlog tecnico - Registro Horario Fase II

**Fecha:** 2026-06-23  
**Proyecto:** Registro Horario - Fase II  
**Audiencia:** jefe de proyecto, tech lead, backend, frontend, QA y Product Owner.  
**Objetivo:** transformar la informacion clave en un backlog estimable por bloques y sprints, indicando dependencias, riesgos y tareas no estimables todavia.

---

## 1. Principios de planificacion

1. No agrupar funcionalidades de negocio distintas si tienen reglas o pruebas diferentes.
2. Separar Backend, Frontend, QA, Infraestructura y Datos de prueba.
3. Toda tarea debe estar asociada a un caso de uso verificable.
4. Si falta decision funcional, la tarea queda como **No estimable todavia** o **Condicionada**.
5. Las tareas de API deben incluir DTO/request/response, mapper, modelo frontend y pruebas de contrato.
6. Las tareas de UI deben indicar el recorrido que negocio debe poder probar.
7. Los calculos, exportaciones, permisos y anonimato deben tener datos de prueba especificos.

---

## 2. Plan base recomendado

| Sprint | Objetivo | Resultado esperado |
|---|---|---|
| S1 | Cierre funcional/tecnico y arquitectura | Decisiones bloqueantes cerradas, matriz de permisos, contrato Informes, modelo accesos externos y dataset UAT. |
| S2 | Roles, permisos y accesos externos base | Roles nuevos, `/v1/me`, permisos, rutas, guards, CRUD acceso externo inicial y revocacion. |
| S3 | Modulo Informes Admin/RLPT | Pantalla Informes, filtros, tabla, backend agregado, XLSX tabla/simple/detallado y tests de contrato. |
| S4 | Perfil Inspector/a | Empresas por ambito, anonimato, KPIs, listado, ficha read-only y export anonimo. |
| S5 | RLPT, Superadmin y suplantacion | Rol RLPT segun decision, simulacion reforzada, suplantacion si entra en alcance, i18n y UX. |
| S6 | QA, rendimiento y cierre | E2E criticos, golden XLSX, pruebas de seguridad, performance y correcciones UAT. |

Este plan equivale al escenario probable condicionado: **6 sprints / 870 h**. Si las decisiones se cierran durante desarrollo, el cierre real debe gestionarse como **7-8 sprints**.

---

## 3. Backlog por sprint

| Sprint | Epica | ID tarea | Tipo | Tarea | Caso de uso asociado | Descripcion tecnica | Criterios de aceptacion | Estimacion h | Dependencias | Riesgos | Estado |
|---|---|---|---|---|---|---|---|---:|---|---|---|
| S1 | Cierre | F2-001 | Analisis | Cerrar matriz de permisos por rol. | Login, permisos, URL directa | Definir lectura/escritura/export/configuracion por Admin, Usuario, Referente, Superadmin, Inspector, RLPT. | Matriz aprobada y usable por BE/FE/QA. | 8 | D01 | Retrabajo transversal. | Bloqueante |
| S1 | Cierre | F2-002 | Analisis | Cerrar modelo de Inspector/RLPT/accesos externos. | Accesos externos | Decidir identidad, ambito, Keycloak, BD, multiempresa, duplicados y revocacion. | Modelo aprobado con estados y reglas. | 10 | D02,D06,D07,D08 | Migraciones rehechas. | Bloqueante |
| S1 | Cierre | F2-003 | Analisis | Cerrar anonimato y privacidad. | Inspector | Definir campos anonimos en API, UI, Excel, logs, auditoria y comentarios. | Lista de campos y reglas aprobada. | 10 | D03,D04,D05,D21 | Fuga de datos. | Bloqueante |
| S1 | Cierre | F2-004 | Analisis | Cerrar contrato de Informes XLSX. | Informes | Definir filtros, columnas, fechas, dias incluidos, tramos, formato XLSX y volumen. | Contrato funcional y tecnico aprobado. | 12 | D13-D19 | Rehacer exportaciones. | Bloqueante |
| S1 | Cierre | F2-005 | QA/Datos | Definir dataset UAT oficial. | QA/UAT | Dataset con usuarios, roles, fechas, historicos, anonimo, tramos, exports y resultados esperados. | Dataset aprobado por negocio. | 12 | D28 | QA no concluyente. | Bloqueante |
| S1 | Arquitectura | F2-006 | Backend | Diseno tecnico de permisos y accesos externos. | Roles/accesos | Definir entidades, migraciones, servicios, anotaciones/interceptores y contratos. | ADR o seccion tecnica aprobada. | 12 | F2-001,F2-002 | Modelo incorrecto. | Condicionado |
| S1 | Arquitectura | F2-007 | Frontend | Diseno tecnico de roles, rutas y permisos. | Roles/rutas | Definir `RolEnum`, `AppPermission`, menu, guards, empresa activa y estados sin empresa. | Mapa de rutas/permisos aprobado. | 8 | F2-001,F2-002 | Menus inconsistentes. | Condicionado |
| S2 | Seguridad | F2-008 | Backend | Implementar roles y permisos Fase II en backend. | Login/permisos | Ampliar resolucion de rol, checks por empresa/ambito, read-only y respuestas 403/404. | API bloquea accesos no permitidos y mutaciones read-only. | 35 | F2-006 | Brechas de seguridad. | Condicionado |
| S2 | Seguridad | F2-009 | Frontend | Implementar roles y permisos Fase II en frontend. | Login/permisos | Ampliar `RolEnum`, `AppPermission`, guards, menus, rutas y estados 403. | Cada rol ve solo lo permitido y maneja 403. | 25 | F2-007,F2-008 | UI/backend descuadrados. | Condicionado |
| S2 | Accesos externos | F2-010 | Backend | CRUD de accesos externos. | Accesos externos | Entidades/migraciones, DTOs, endpoints, estados, alta, revocacion, duplicados y auditoria. | Alta/revocacion/duplicado funcionan con errores controlados. | 45 | F2-002,F2-006 | Keycloak/email parcial. | Condicionado |
| S2 | Accesos externos | F2-011 | Frontend | Pantalla/modal de accesos externos. | Accesos externos | Listado, alta, estados, revocar, reenviar si aplica, mensajes y validaciones. | Admin gestiona accesos segun reglas aprobadas. | 30 | F2-010 | UX incompleta por estados no cerrados. | Condicionado |
| S2 | Accesos externos | F2-012 | QA | Tests de accesos externos. | Accesos externos | API/E2E de alta, duplicado, revocacion, caducidad, fallo Keycloak/email. | Casos criticos automatizados. | 18 | F2-010,F2-011 | Sin integracion externa mockeable. | Condicionado |
| S2 | Seguridad | F2-013 | Backend | Bloqueo read-only backend. | Inspector/simulacion | Garantizar 403 para POST/PUT/PATCH/DELETE en roles/modos solo lectura, salvo excepciones. | Mutaciones directas quedan bloqueadas. | 20 | D01,D23 | UI no es defensa suficiente. | Condicionado |
| S3 | Informes | F2-014 | Backend | Endpoint agregado de Informes. | Informes tabla | Query con filtros, paginacion, orden, totales y permisos por rol. | Devuelve datos correctos del dataset UAT. | 45 | F2-004,F2-008,F2-005 | Calculos ambiguos. | Condicionado |
| S3 | Informes | F2-015 | Backend | Motor XLSX de informe tabla. | Export tabla | Generar XLSX con columnas aprobadas, filtros activos y datos por rol. | Golden XLSX validado. | 25 | F2-014 | Columnas cambiantes. | Condicionado |
| S3 | Informes | F2-016 | Backend | Motor XLSX simple diario. | Export simple | Generar filas diarias segun reglas de dias, ausencias, festivos y bajas. | Golden XLSX simple validado. | 30 | F2-004,F2-005 | Dias sin registro/festivos no cerrados. | Condicionado |
| S3 | Informes | F2-017 | Backend | Motor XLSX detallado por tramos. | Export detallado | Tramos, incidencias, cruce medianoche, abiertos/corruptos y comentarios segun rol. | No hay 500 con datos legacy; golden validado. | 35 | F2-004,F2-005 | Datos corruptos. | Condicionado |
| S3 | Informes | F2-018 | Frontend | Pantalla Informes. | Informes | Ruta, filtros, tabla, paginacion, orden, estados vacios, descargas y permisos. | Negocio puede filtrar, consultar y exportar. | 50 | F2-014-F2-017,F2-009 | UI no refleja variantes por rol. | Condicionado |
| S3 | Informes | F2-019 | QA | Tests de contrato y XLSX. | Informes/export | Validar API, permisos, columnas, XLSX vacio/grande/filtrado y datos anonimos. | Tests pasan con dataset UAT. | 25 | F2-014-F2-018 | Golden files inestables. | Condicionado |
| S4 | Inspector | F2-020 | Backend | Endpoints anonimos de Inspector. | Inspector listado/ficha | DTOs anonimos, empresas por ambito, usuarios anonimos, ficha read-only y permisos. | API no devuelve PII no autorizada. | 55 | F2-003,F2-008,F2-010 | Anonimato incompleto. | Condicionado |
| S4 | Inspector | F2-021 | Backend | KPIs Inspector. | Inspector KPIs | Calcular correcto/incompleto/sin registro segun reglas aprobadas. | KPIs cuadran con dataset UAT. | 25 | D10,F2-005 | Reglas incompletas. | Condicionado |
| S4 | Inspector | F2-022 | Frontend | Experiencia Inspector. | Inspector | Selector empresas, listado anonimo, KPIs, ficha read-only, estados sin empresa/sin datos. | Inspector navega sin acciones de escritura ni PII. | 65 | F2-020,F2-021 | Reutilizacion filtra datos reales. | Condicionado |
| S4 | Inspector | F2-023 | QA | Tests anti-fuga Inspector. | Inspector privacidad | API/UI/XLSX sin nombre, NIF, email, telefono, comentarios sensibles si se ocultan. | No hay PII no autorizada. | 30 | F2-020-F2-022 | Fuga en campos anidados. | Condicionado |
| S5 | RLPT | F2-024 | Backend | Aplicar rol RLPT segun decision. | RLPT | Permisos, ambito, informes, herencia usuario, datos reales/anonimos. | RLPT solo ve/ejecuta lo aprobado. | 25 | D11,D12,F2-008 | Naturaleza ambigua. | No estimable todavia |
| S5 | RLPT | F2-025 | Frontend | Experiencia RLPT. | RLPT | Menu/rutas heredadas, Informes, dashboard/registro si aplica y errores. | Recorrido RLPT validado por negocio. | 20 | F2-024 | Herencia parcial no cerrada. | No estimable todavia |
| S5 | Superadmin | F2-026 | Backend | Suplantacion backend. | Suplantacion | Modelo sesion, actor real, usuario objetivo, permisos, duracion, auditoria. | Acciones auditadas con actor real y objetivo. | 35 | D24,D25 | Alto riesgo seguridad. | No estimable todavia |
| S5 | Superadmin | F2-027 | Frontend | Suplantacion frontend. | Suplantacion | Boton, seleccion usuario, banner, salida segura, refresh, permisos visibles. | Superadmin entra/sale sin confusion de identidad. | 25 | F2-026 | UX peligrosa. | No estimable todavia |
| S5 | UX/i18n | F2-028 | Frontend | Estados, mensajes y traducciones. | Transversal | Sin datos, sin permisos, revocado, sin empresa, timeout, error servicio, export sin datos. | Mensajes consistentes en idiomas soportados. | 35 | Decisiones UX | UAT por textos. | Condicionado |
| S6 | QA | F2-029 | QA | E2E smoke y regresion critica. | Transversal | Playwright de login, permisos, Informes, Inspector, RLPT, accesos externos, exports y sesion. | Suite estable cubre recorridos criticos. | 55 | Dataset UAT | Tests fragiles si datos no cerrados. | Condicionado |
| S6 | Rendimiento | F2-030 | Backend/QA | Validacion de volumen y limites. | Informes/rendimiento | Probar rango grande, muchas empresas, XLSX detallado, timeouts y limites. | Cumple SLA o muestra limite aprobado. | 25 | D19 | Fallo produccion. | Condicionado |
| S6 | Hardening | F2-031 | Full stack | Correcciones UAT y cierre. | Transversal | Correccion de defectos, ajuste mensajes, documentacion tecnica y cierre. | UAT aceptado sin cambios de alcance abiertos. | 50 | UAT | UAT se convierte en rediseño. | Condicionado |

---

## 4. Dependencias criticas

| Dependencia | Tareas afectadas | Impacto |
|---|---|---|
| Matriz de permisos | F2-008, F2-009, F2-013, F2-020, F2-024, E2E | Sin matriz no hay seguridad ni QA fiable. |
| Modelo accesos externos | F2-010, F2-011, F2-012, F2-020 | Cambia BD, Keycloak, UI y revocacion. |
| Contrato Informes | F2-014 a F2-019 | Cambiar columnas/reglas tarde reabre backend, frontend y golden XLSX. |
| Anonimizacion | F2-020, F2-022, F2-023, exports | Riesgo legal si se implementa solo en UI. |
| Dataset UAT | F2-019, F2-021, F2-023, F2-029, F2-030 | Sin datos esperados no se validan calculos. |
| Suplantacion | F2-026, F2-027 | No estimable con seguridad hasta cerrar alcance. |
| Volumen/SLA | F2-014-F2-017, F2-030 | Decide sync/async, streaming, limites e indices. |

---

## 5. Entregables tecnicos esperados

| Area | Entregable |
|---|---|
| Backend | Migraciones, entidades/accesos, servicios de permisos, endpoints, DTOs, mappers, motor XLSX, auditoria, tests de seguridad/integracion. |
| Frontend | Roles, permisos, rutas, menus, stores/modelos, pantalla Informes, accesos externos, Inspector, RLPT, suplantacion, traducciones y estados de error. |
| QA | Dataset UAT, fixtures, tests API, golden XLSX, E2E Playwright, regresion permisos y pruebas anti-fuga. |
| Infra/config | Configuracion Keycloak/email si aplica, limites exportacion, timeouts, flags de roles externos y trazabilidad. |
| Documentacion | Matriz permisos, contrato Informes, reglas anonimato, decisiones cerradas y criterios UAT. |

---

## 6. Reglas para convertir tareas en estimables

Una tarea se considera estimable solo si tiene:

| Requisito | Ejemplo |
|---|---|
| Caso de uso asociado | Inspector consulta ficha anonima. |
| Actor y permisos definidos | Inspector solo lectura con empresa seleccionada. |
| Datos de prueba | Usuario con fichajes, comentarios y compensaciones sensibles. |
| Contrato API/UI | DTO sin PII y modelo frontend asociado. |
| Criterio de aceptacion | No aparece nombre/NIF/email en API, UI ni XLSX. |
| Tests recomendados | API contract, E2E privacidad, golden XLSX. |

Si falta alguno de estos puntos por decision de negocio, la tarea debe permanecer como **No estimable todavia**.

---

## 7. Resumen de horas

| Bloque | Horas probables |
|---|---:|
| Cierre funcional/tecnico | 40 |
| Roles, permisos y acceso externo | 105 |
| Gestion de accesos externos | 65 |
| Informes Admin/RLPT | 135 |
| Inspector/a | 165 |
| RLPT | 45 |
| Superadmin/suplantacion | 70 |
| i18n/UX | 55 |
| Tests/regresion | 105 |
| Hardening/rendimiento/UAT | 85 |
| **Total probable** | **870 h** |

---

## 8. Recomendacion de seguimiento

Usar este informe como backlog base, pero no crear sprint cerrado hasta que el informe `02-decisiones-preguntas-bloqueantes-fase2.md` tenga respuesta para las decisiones que afectan al sprint correspondiente.
