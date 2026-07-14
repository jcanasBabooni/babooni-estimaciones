# 02 - Decisiones y preguntas bloqueantes - Registro Horario Fase II

**Fecha:** 2026-06-23  
**Proyecto:** Registro Horario - Fase II  
**Audiencia:** negocio, Product Owner, arquitectura, seguridad, backend, frontend y QA.  
**Objetivo:** concentrar las decisiones que deben resolverse antes de estimar cerrado o desarrollar sin inventar reglas.

---

## 1. Criterio de clasificacion

| Prioridad | Significado |
|---|---|
| Bloqueante | Sin respuesta no se puede estimar, implementar o probar con seguridad. |
| Alta | Se puede avanzar parcialmente, pero con alto riesgo de retrabajo. |
| Media | Afecta UX, QA, mensajes, datos de prueba o casos secundarios. |
| Baja | Mejora definicion, pero no condiciona el nucleo. |

Regla de trabajo: si una decision afecta modelo de datos, permisos, API, calculos, exportaciones, tests E2E, datos existentes o seguridad, debe resolverse antes de cerrar el alcance.

---

## 2. Decisiones bloqueantes principales

| ID | Prioridad | Modulo | Decision necesaria | Pregunta exacta | Que desbloquea | Que se rompe si no se responde |
|---|---|---|---|---|---|---|
| D01 | Bloqueante | Roles y permisos | Matriz final de permisos por rol, modulo, accion, empresa activa, modo simulacion y URL directa. | Cual es la matriz final de permisos para Admin, Usuario, Referente, Superadmin, Inspector y RLPT? | Guards frontend, autorizacion backend, menus, rutas, datos UAT y tests negativos. | Rehacer permisos, pantallas, endpoints y E2E. |
| D02 | Bloqueante | Accesos externos | Modelo de identidad de Inspector/RLPT. | Inspector y RLPT son usuarios internos, accesos externos, roles Keycloak con ambito o una combinacion? | Modelo BD, Keycloak, `/v1/me`, selector de empresa y revocacion. | Rehacer migraciones, login, contratos API y pantallas. |
| D03 | Bloqueante | Inspector | Campos anonimizados. | Que campos exactos se ocultan, transforman o muestran para Inspector en API, pantalla, Excel, logs y auditoria? | DTOs, mappers, UI, XLSX, logs, auditoria y tests anti-fuga. | Fuga de datos o retrabajo transversal. |
| D04 | Bloqueante | Inspector | Identificador anonimo. | El identificador anonimo debe ser estable, reversible o distinto por empresa? | Listado, ficha, paginacion, export y trazabilidad anonima. | Pantalla y Excel no cuadran, o se rompe anonimato. |
| D05 | Bloqueante | Inspector | Textos libres y comentarios sensibles. | Que se hace con observaciones de fichajes, historicos y compensaciones: ocultar, vaciar, resumir o mostrar? | Sanitizacion, columnas Excel, ficha e historicos. | Fuga de PII por comentarios aunque el nombre este oculto. |
| D06 | Bloqueante | Accesos externos | Ciclo de vida del acceso. | Que estados existen: invitado, activo, caducado, revocado, bloqueado, reenviado? | Estados BD, acciones UI, mensajes, auditoria y E2E. | Revocacion, reenvio o caducidad implementados con reglas incorrectas. |
| D07 | Bloqueante | Accesos externos | Revocacion con sesion activa. | La revocacion corta inmediatamente sesiones y descargas en curso o solo bloquea nuevos logins? | Validacion por request, invalidacion de sesion, cancelacion de descarga y tests. | Usuario revocado puede seguir consultando o exportando. |
| D08 | Bloqueante | Accesos externos | Duplicados y multiempresa. | Un mismo email puede ser trabajador, Inspector/RLPT y/o estar vinculado a varias empresas? | Indices, validaciones, 409, reenvio y asignacion multiempresa. | Identidades ambiguas y permisos cruzados. |
| D09 | Bloqueante | Inspector | Estado sin empresa seleccionada. | Que ve un Inspector sin empresa seleccionada y que endpoints puede usar antes de elegir empresa? | `/v1/me`, selector, pantalla inicial, guards y routing. | Mezcla de datos o bloqueo antes de poder seleccionar empresa. |
| D10 | Bloqueante | Inspector | KPIs de control. | Que cuenta como registro correcto, incompleto, sin registro y dia computable? | Formulas, queries, fixtures, dataset UAT y assertions. | Indicadores no cuadran con Informes, Historial o Dashboard. |
| D11 | Bloqueante | RLPT | Naturaleza del rol. | El RLPT es trabajador que ficha, externo de consulta o perfil hibrido? | Login, dashboard, registro vivo/diferido, historial, permisos y rutas. | Implementar el rol opuesto al esperado por negocio. |
| D12 | Bloqueante | RLPT | Ambito y privacidad. | RLPT ve toda la plantilla o un ambito; datos reales o anonimizados? | Queries, filtros, exports, DTOs por rol y tests negativos. | Acceso a datos no permitidos o informes incompletos. |
| D13 | Bloqueante | Informes | Variantes por rol. | Admin, RLPT e Inspector comparten filtros, columnas y exports o hay variantes por rol? | Diseno UI, DTOs, endpoints, columnas y E2E. | Construir una pantalla unica y tener que partirla. |
| D14 | Bloqueante | Informes | Columnas finales XLSX. | Cuales son las columnas definitivas por tipo de informe y rol? | Tabla, Excel, contrato API, golden files y UAT. | Cambios tardios rompen exportaciones y tests. |
| D15 | Bloqueante | Informes | Reglas de fechas. | Rangos inclusivos? Zona horaria? Futuro? Fines de semana? Festivos? Cambio de mes/anio? | Datepickers, query params, backend date handling y tests limite. | Off-by-one, diferencias por zona horaria y calculos contradictorios. |
| D16 | Bloqueante | Informes | Dias sin registro y ausencias. | El informe simple incluye dias sin registro, festivos, vacaciones, bajas, fines de semana y futuro? | Algoritmo diario, volumen, XLSX y datos esperados. | Excel aparentemente incompleto o inflado. |
| D17 | Bloqueante | Informes | Tramos problematicos. | Como se exportan tramos abiertos, solapados, fin anterior a inicio y cruces de medianoche? | Validadores, fallback, incidencias, mensajes y tests legacy. | Exportaciones con 500 o evidencias incorrectas. |
| D18 | Bloqueante | Informes | Horas ordinarias/extra. | Debe separarse ordinaria y extraordinaria? Cual es la regla? | Calculo de jornada teorica, columnas, exports y dashboard relacionado. | Reabrir servicios de calculo durante UAT. |
| D19 | Bloqueante | Informes | Volumen y SLA. | Cual es el rango maximo exportable y tiempo maximo esperado? | Indices, streaming, jobs, timeouts, limites y mensajes. | Solucion funcionalmente correcta pero inviable en produccion. |
| D20 | Bloqueante | Datos historicos | Fallback legacy. | Como deben comportarse informes y anonimato con datos historicos anteriores a Fase II? | Migraciones, validadores, fallback y fixtures legacy. | Pasar en dev y fallar con datos reales. |
| D21 | Bloqueante | Exportaciones existentes | Alcance de anonimato en CSV actuales. | Inspector/RLPT pueden acceder a exports actuales de historial/compensaciones o solo al nuevo modulo Informes? | Bloqueo/anonimizacion de endpoints existentes y tests anti-fuga. | Proteger Informes nuevo pero filtrar datos por exports antiguos. |
| D22 | Bloqueante | Configuracion | Cambios pasados y sesiones abiertas. | Modificar festivos, planificacion o configuracion pasada recalcula informes o conserva historico? | Recalculo, cache, auditoria, validacion server-side y mensajes. | Informes antiguos y nuevos dan resultados distintos sin explicacion. |
| D23 | Bloqueante | Superadmin | Solo lectura backend en simulacion. | Todas las mutaciones quedan bloqueadas en backend cuando el superadmin simula? | Interceptor/anotaciones, tests API y regresion de mutaciones. | Cambios reales mediante llamada directa a API. |
| D24 | Bloqueante | Suplantacion | Alcance, duracion, salida y auditoria. | La suplantacion permite escritura? A que roles? Persiste tras refresh? Que audita? | Modelo de sesion, banner, salida segura, auditoria y permisos. | Operar como otro usuario sin trazabilidad o sin salida clara. |
| D25 | Bloqueante | Auditoria | Eventos nuevos. | Que eventos se auditan: login externo, consulta, apertura ficha, export XLSX, revocacion, suplantacion? | Tabla/eventos de auditoria, payloads, logs y pruebas. | Falta evidencia de accesos y descargas sensibles. |
| D26 | Bloqueante | Alcance | Exclusiones. | Confirmamos que app movil e IA quedan fuera de Fase II? | Alcance estimable y defensa ante cambios tardios. | La estimacion queda invalidada si entran durante desarrollo. |
| D27 | Bloqueante | Fuente de verdad | Documento vs prototipo. | Si prototipo y funcional contradicen columnas, textos o flujos, cual prevalece? | Criterios de aceptacion y resolucion de dudas. | UAT rechaza una implementacion tecnicamente correcta. |
| D28 | Bloqueante | QA/UAT | Dataset oficial. | Puede negocio aprobar dataset UAT con resultados esperados para permisos, calculos, anonimato y XLSX? | Seeds, Playwright, golden XLSX, tests backend y cierre UAT. | QA discute resultados caso por caso. |

---

## 3. Decisiones de prioridad alta

| ID | Modulo | Pregunta | Por que importa | Riesgo |
|---|---|---|---|---|
| A01 | Inspector | Debe ver trabajadores dados de baja, sin registros, sin planificacion o sin compensaciones? | Afecta totales, listados, fichas y exports. | KPIs no coinciden con expectativas. |
| A02 | Informes | Que filtros exactos existen, periodo por defecto, orden inicial, tamanio pagina y comportamiento al cambiar filtros? | Necesario para UX y E2E estables. | Paginacion incoherente y pruebas fragiles. |
| A03 | Informes | Cuando no hay datos, se impide generar archivo y que mensaje se muestra? | Afecta UI, backend y tests negativos. | Exceles vacios o comportamientos distintos por rol. |
| A04 | Informes | Nombre del archivo, formato de fecha/hora/duracion, idioma, pestanias y metadatos XLSX? | Detalles de aceptacion del entregable. | Rehacer exports por formato al final. |
| A05 | Informes | Se cancelan exports en curso al cambiar filtros, lanzar otro export o cerrar sesion? | Evita descargas obsoletas. | Descargar datos que no corresponden a la pantalla actual. |
| A06 | Configuracion | Centro y puesto son visibles para Inspector aunque puedan identificar indirectamente? | Riesgo de reidentificacion por baja cardinalidad. | Anonimato insuficiente. |
| A07 | Configuracion | Cambios de parametros se aplican al abrir pantalla o al guardar? | Define validacion backend. | Usuarios guardan acciones ya prohibidas. |
| A08 | Usuarios/CSV | CSV puede crear RLPT/Inspector/accesos externos o solo trabajadores? | Afecta flujo existente y duplicados. | Crear roles externos por un canal no previsto. |
| A09 | Sesion | Que ocurre si caduca sesion durante consulta, guardado, cambio empresa o descarga? | Seguridad y UX transversal. | Datos sensibles visibles o descargas tras logout. |
| A10 | Concurrencia | Se requiere idempotencia/bloqueo para altas, fichajes, exports y cambio de empresa? | Evita duplicados y mezcla de contexto. | Doble fichaje, doble acceso o datos de otra empresa. |
| A11 | UX | Textos para sin datos, sin permisos, revocado, sin empresa, timeout y error servicio? | Forma parte de la prueba funcional. | UAT falla por mensajes ambiguos. |
| A12 | Logs | Que datos personales pueden aparecer en logs, auditoria y errores tecnicos? | Privacidad fuera de UI. | Fuga por trazas tecnicas. |

---

## 4. Preguntas eliminadas o reformuladas tras revisar codigo

| Area | Decision actual | Tratamiento recomendado |
|---|---|---|
| CSV parcial/atomico | El comportamiento del CSV actual ya esta implementado y probado. | Eliminar como bloqueante. Convertir en regresion QA. |
| UX simulacion actual | El frontend ya deshabilita muchas acciones en pantallas existentes. | No usar como bloqueante general. Mantener criterio de consistencia para pantallas nuevas. |
| Roles externos | Hay infraestructura tecnica, pero no modelo funcional Inspector/RLPT. | Reformular: negocio debe confirmar si se adopta esa infraestructura y con que alcance. |
| Exportaciones CSV actuales | Existen exports CSV, pero no son XLSX ni anonimos. | Reformular: decidir si los nuevos roles pueden acceder o si se bloquean. |
| Auditoria | Hay framework actual. | Reformular: definir eventos Fase II concretos. |
| Password externos | Existe cambio de password de usuario autenticado. | Reformular: externos cambian password en app o proveedor identidad? |

---

## 5. Agrupacion para reuniones de cierre

### Reunion 1: negocio y seguridad

| Tema | Decisiones |
|---|---|
| Matriz de permisos | D01, D23 |
| Inspector | D03, D04, D05, D09, D10 |
| RLPT | D11, D12 |
| Privacidad | D03, D05, D21, D25 |
| Suplantacion | D24 |

### Reunion 2: producto e informes

| Tema | Decisiones |
|---|---|
| Alcance Informes | D13, D14 |
| Fechas y calculos | D15, D16, D17, D18 |
| Exportaciones | D19, D21 |
| Fuente de verdad | D27 |

### Reunion 3: arquitectura e integraciones

| Tema | Decisiones |
|---|---|
| Accesos externos | D02, D06, D07, D08 |
| Keycloak/email | D06, D07, D08 |
| Datos historicos | D20, D22 |
| Rendimiento | D19 |

### Reunion 4: QA/UAT

| Tema | Decisiones |
|---|---|
| Dataset oficial | D28 |
| Criterios de aceptacion | D10, D14, D15, D16, D17 |
| Clasificacion de hallazgos | Defecto vs aclaracion vs cambio de alcance. |

---

## 6. Criterio para cerrar una decision

Una decision se considera cerrada solo si deja definidos estos puntos:

| Punto | Necesario |
|---|---|
| Regla funcional | Que debe pasar desde el punto de vista de negocio. |
| Alcance tecnico | Que modulos, APIs, pantallas, exports o datos afecta. |
| Caso negativo | Que debe pasar si el usuario no tiene permiso, no hay datos o hay datos invalidos. |
| Datos de prueba | Que dataset permite comprobarlo. |
| Test recomendado | E2E, integracion, unitario, contrato o performance. |
| Criterio de aceptacion | Como sabremos que esta bien implementado. |

---

## 7. Resultado esperado de este informe

Este documento debe usarse para reducir incertidumbre antes de estimar cerrado. Si una decision sigue sin respuesta, la tarea asociada debe quedar como **No estimable todavia** o estimarse con contingencia explicita.
