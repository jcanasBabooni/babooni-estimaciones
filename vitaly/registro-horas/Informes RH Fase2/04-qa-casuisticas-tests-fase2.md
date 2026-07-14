# 04 - QA, casuisticas criticas y tests - Registro Horario Fase II

**Fecha:** 2026-06-23  
**Proyecto:** Registro Horario - Fase II  
**Audiencia:** QA funcional, QA automation, backend, frontend, Product Owner y negocio.  
**Objetivo:** conservar la casuistica critica detectada y convertirla en estrategia de prueba accionable para evitar fallos tardios en desarrollo, UAT o produccion.

---

## 1. Enfoque QA

La Fase II debe probarse como un cambio transversal de seguridad, privacidad, calculo y exportacion. No basta con probar caminos felices.

Prioridades:

1. Permisos y acceso directo por URL.
2. Roles nuevos: Inspector/a y RLPT.
3. Accesos externos: alta, caducidad, revocacion y duplicados.
4. Anonimizacion en API, UI, Excel, logs y auditoria.
5. Informes XLSX: filtros, columnas, calculos, datos vacios, rangos grandes y tramos problematicos.
6. Datos historicos y legacy.
7. Sesion expirada, logout, cambio de empresa y revocacion durante operaciones largas.
8. Concurrencia: doble click, doble edicion, exportaciones simultaneas y respuestas obsoletas.
9. Dataset UAT con resultados esperados.

---

## 2. Matriz de casuisticas criticas

| Area | Caso borde/extremo | Datos necesarios | Resultado esperado | Definido | Riesgo | Test recomendado |
|---|---|---|---|---|---|---|
| Login | Rol Keycloak desconocido. | Token con claim no mapeado. | No asignar rol por defecto ni mostrar datos. | No | Alta | Integracion seguridad. |
| Login | Inspector externo sin acceso activo en BD. | Keycloak valido, BD sin acceso. | Acceso denegado sin crear perfil implicito. | Parcial | Alta | E2E seguridad. |
| Sesion | Token caduca cargando `/v1/me`. | Token expira durante bootstrap. | Redireccion/mensaje sin pintar menu previo. | Inferido | Alta | E2E mock 401. |
| Sesion | Logout durante export XLSX largo. | Export con latencia. | No descargar archivo tras logout. | Inferido | Alta | E2E latencia. |
| URL directa | Usuario abre ruta no permitida. | Usuario normal a Informes/Configuracion. | 403/redireccion sin datos sensibles. | Parcial | Alta | E2E permisos. |
| Empresa | Cambio rapido de empresa con peticiones pendientes. | Dos empresas y latencia. | Respuesta obsoleta no pinta datos. | Inferido | Alta | E2E concurrencia. |
| Empresa | Empresa revocada mientras esta seleccionada. | Revocacion en otra sesion. | Siguiente request bloquea y limpia contexto. | Inferido | Alta | E2E permisos. |
| Inspector | Acceso vigente sin empresas. | Inspector sin ambito. | Estado vacio, sin usuarios ni informes. | Parcial | Alta | E2E. |
| Inspector | Busca empresa no autorizada. | Nombre exacto de empresa ajena. | No revelar existencia por contador ni error. | Inferido | Alta | Seguridad API. |
| Inspector | Busca por apellido real oculto. | Usuarios anonimos con apellidos reales. | No permitir filtro que revele identidad. | No | Alta | Seguridad API. |
| Inspector | Centro/puesto identifica persona unica. | Centro con un solo usuario. | Aplicar regla de anonimato aprobada. | Inferido | Alta | Seguridad funcional. |
| Inspector | Ficha contiene subobjetos con PII. | Auditoria, creado por, comentarios, enlaces. | Ningun campo sensible no autorizado en response. | No | Alta | Contrato API. |
| Inspector | Export anonimo contiene PII en comentario. | Comentario con nombre, DNI o salud. | No aparece PII si debe ocultarse. | No | Alta | Seguridad XLSX. |
| Inspector | Pseudonimo cambia entre pantalla y Excel. | ID anonimo dinamico. | Identificador estable segun regla. | No | Alta | Integracion. |
| RLPT | RLPT sin fichajes propios. | RLPT externo o sin jornada. | Dashboard/registro oculto o estado definido. | No | Alta | E2E. |
| RLPT | Manipula query params de centro/usuario. | Centro o usuario fuera de ambito. | Backend rechaza o ignora filtro no autorizado. | Inferido | Alta | Seguridad API. |
| Accesos externos | Alta sin empresa asociada. | Form incompleto. | Bloquear o vincular a empresa segun regla. | No | Alta | E2E/API. |
| Accesos externos | Email ya existe como trabajador. | Mismo email interno y externo. | Rechazar o permitir multirol segun regla. | No | Alta | Integracion API. |
| Accesos externos | Revocacion con sesion activa. | Inspector activo y admin revoca. | Cortar o mantener hasta expiracion segun decision. | No | Alta | E2E seguridad. |
| Accesos externos | Keycloak/email falla tras guardar BD. | Fallo parcial. | Rollback o estado pendiente reintentable. | No | Alta | Integracion externa. |
| Accesos externos | Doble click en guardar. | Latencia. | Un solo acceso creado o idempotencia. | Inferido | Alta | E2E concurrencia. |
| Configuracion | Dos admins guardan lo mismo. | Dos sesiones. | Conflicto o ultima escritura definida. | Inferido | Media | Integracion API. |
| Configuracion | Cambia parametro con pantalla abierta. | Usuario en formulario y admin cambia regla. | Backend revalida al guardar. | Inferido | Alta | E2E concurrencia. |
| Centros | Baja centro con historico. | Centro usado por usuarios/registros. | Historicos e informes no rompen. | Parcial | Alta | Integracion. |
| Festivos | Festivo nacional/local mismo dia. | Solape por fecha. | Computar una vez o segun regla. | Parcial | Alta | Unit calculo. |
| Festivos | Borrar festivo historico. | Festivo con registros ya exportados. | Recalcular o conservar segun decision. | Inferido | Alta | Integracion calculo. |
| Planificacion | Turnos solapados. | Dos turnos mismo dia. | Bloquear o priorizar segun regla. | Parcial | Alta | Unit/integracion. |
| Planificacion | Cambiar planificacion pasada. | Fichajes ya registrados. | Recalculo/congelacion definida. | Inferido | Alta | Integracion calculo. |
| Dashboard | Semana cruza anio. | 2026-12-31 a 2027-01-01. | Totales semanales/mensuales correctos. | Inferido | Alta | Integracion calculo. |
| Fichaje vivo | Doble click entrada. | Latencia y doble click. | Un solo evento. | Inferido | Alta | E2E/API concurrencia. |
| Fichaje vivo | Salida sin entrada. | Payload directo. | Error controlado sin dato corrupto. | Parcial | Alta | API. |
| Fichaje vivo | Fichaje futuro por reloj cliente. | Payload fecha futura. | Usar hora servidor o rechazar. | No | Alta | API. |
| Fichaje vivo | Cruce medianoche. | Entrada 23:59, salida 00:10. | Dia y duracion segun regla. | Inferido | Alta | Integracion calculo. |
| Registro diferido | Fecha futura. | Fecha posterior a hoy. | Bloqueo UI y backend. | Parcial | Alta | E2E/API. |
| Registro diferido | Tramos solapados o fin antes de inicio. | Tramos invalidos. | Bloqueo con mensaje. | Si/parcial | Alta | Unit/API. |
| Historial | Usuario dado de baja con historico. | Baja mitad de anio. | Consulta historica segun regla. | Parcial | Alta | E2E. |
| Historial | Dos admins editan mismo dia. | Sesiones concurrentes. | Conflicto o regla definida. | Inferido | Alta | E2E/API 409. |
| Historial | Comentario sensible. | Texto con nombre o salud. | Oculto/anonimizado segun rol. | No | Alta | Seguridad. |
| CSV | Cabecera invalida o columnas extra. | CSV mal formado. | Error claro o ignorar extra segun contrato. | Si | Alta | E2E/API. |
| CSV | Duplicados en fichero. | NIF/email repetidos. | Reportar y no duplicar. | Si | Alta | Integracion. |
| CSV | Doble importacion. | Mismo fichero dos veces. | Sin duplicar usuarios. | Inferido | Alta | Concurrencia. |
| CSV Fase II | CSV con rol Inspector/RLPT. | Campo rol externo. | Rechazar o crear segun decision. | No | Alta | QA funcional. |
| Compensaciones | Movimiento negativo. | Horas negativas. | Saldo y validacion correctos. | Parcial | Media | Unit/API. |
| Compensaciones | Comentario sensible. | Texto con PII. | Oculto/anonimizado segun rol. | No | Alta | Seguridad. |
| Informes | Fecha desde mayor que hasta. | Rango invertido. | Bloqueo UI y backend. | Si | Media | E2E/API. |
| Informes | Centro inactivo con historico. | Centro dado de baja. | Visible si hay historico o regla definida. | Parcial | Alta | E2E. |
| Informes | Ordenar horas nulas. | Usuarios sin registro. | Orden estable sin error. | No | Media | E2E. |
| Informes | Fichaje concurrente al paginar. | Datos cambian entre paginas. | Sin duplicados/perdidas incoherentes. | Inferido | Media | Integracion. |
| Export tabla | Filtro activo y paginacion. | Varias paginas filtradas. | Export pagina o consulta completa segun decision. | Parcial | Alta | E2E XLSX. |
| Export tabla | Sin datos. | Rango futuro. | No descargar o Excel vacio segun decision. | Parcial | Media | E2E. |
| Export simple | Dia sin registro. | Usuario obligado sin fichaje. | Incluir/excluir segun regla. | No | Alta | Integracion XLSX. |
| Export simple | Festivo/fin de semana. | Rango con festivo y domingo. | Computo segun regla. | No | Alta | Unit/integracion. |
| Export simple | Alta/baja en periodo. | Usuario baja a mitad. | Filas solo aplicables segun regla. | No | Alta | Integracion XLSX. |
| Export detallado | Tramo abierto. | Sin hora fin. | Marcar incidencia/excluir sin romper. | Parcial | Alta | Integracion XLSX. |
| Export detallado | Tramo fin antes de inicio. | Dato corrupto legacy. | Error controlado o incidencia. | No | Alta | Unit/API. |
| Export detallado | Comentarios en tramo. | Texto sensible. | Ocultar/anonimizar/mostrar segun rol. | No | Alta | Seguridad XLSX. |
| Exportaciones | Rango de varios anios. | 500 usuarios x 3 anios. | Limitar, asincronizar o mensaje controlado. | No | Alta | Performance. |
| Exportaciones | Dos exports simultaneos. | Export A lento, B rapido. | Archivos asociados a filtros correctos. | Inferido | Alta | E2E concurrencia. |
| Superadmin | Simulacion guarda por API. | Token superadmin simulado. | 403 si read-only real. | Parcial | Alta | Seguridad API. |
| Superadmin | Modal abierto antes de simulacion. | Modal editar abierto. | Guardado bloqueado. | Inferido | Alta | E2E. |
| Suplantacion | Suplantar usuario dado de baja. | Objetivo inactivo. | Bloquear o consulta segun regla. | No | Alta | E2E. |
| Suplantacion | Suplantar admin/RLPT. | Objetivo con permisos altos. | Sin elevacion no permitida. | No | Alta | Seguridad. |
| Suplantacion | Refresh durante suplantacion. | Navegador refrescado. | Banner/salida segura o cierre. | No | Alta | E2E. |
| Auditoria | Accion suplantada. | Actor real y objetivo. | Auditoria doble correcta. | Parcial | Alta | Integracion. |
| Transversal | Page size 0/9999/negativo. | Query manual. | Limitar o rechazar. | Inferido | Media | API. |
| Transversal | Backend 500 guardando. | Formulario relleno. | Conservar datos y permitir reintento. | Inferido | Alta | E2E mock. |
| Transversal | Respuesta parcial API. | Bloque faltante. | Error coherente o degradacion definida. | Inferido | Media | Contrato API. |
| Integraciones | Keycloak OK, API falla. | Login correcto, `/v1/me` 500. | Servicio no disponible sin estado corrupto. | Inferido | Alta | E2E mock. |
| Historicos | Registros sin campos nuevos. | Datos previos a Fase II. | Fallback/migracion sin romper informes. | No | Alta | Migracion/integracion. |
| Rendimiento | Inspector con muchas empresas. | 50 empresas, muchos usuarios. | Respuesta dentro de SLA o limite aprobado. | No | Alta | Performance. |

---

## 3. Dataset UAT minimo

| Grupo | Datos necesarios |
|---|---|
| Empresas | Empresa normal, empresa sin usuarios, empresa inactiva, dos empresas para Inspector multiempresa. |
| Roles | Admin, usuario, referente si aplica, superadmin, Inspector, RLPT. |
| Usuarios | Activo, dado de baja, sin planificacion, sin registros, con centro/puesto unico, fuera de ambito. |
| Ambitos | RLPT limitado, Inspector sin empresas, Inspector con una empresa, Inspector con varias empresas. |
| Fichajes | Dia completo, entrada sin salida, salida sin entrada legacy, pausa, solapes, cruce medianoche, fecha futura rechazada. |
| Fechas | Hoy, pasado, futuro, fin de semana, festivo local/regional/nacional, cambio de mes, cambio de anio, zona Atlantic/Canary. |
| Planificacion | Jornada completa, parcial, sin planificacion, vacaciones, ausencia, planificacion pasada modificada. |
| Compensaciones | Saldo positivo, negativo, movimiento manual, comentario sensible. |
| Informes | Rango sin datos, rango grande, filtros por centro/puesto/usuario, centro inactivo con historico. |
| Privacidad | Nombre, apellidos, NIF, email, telefono, comentario con PII, centro/puesto reidentificable. |
| Integraciones | Keycloak OK/KO, email KO, token caducado, acceso revocado con sesion activa. |

Cada grupo debe tener resultado esperado: filas, totales, columnas, mensajes, permisos y contenido exacto de XLSX cuando aplique.

---

## 4. Tests E2E Playwright recomendados

| Spec | Rol | Recorrido | Datos iniciales | Assertions | Prioridad | Motivo |
|---|---|---|---|---|---|---|
| `auth-permisos.spec.ts` | Usuario/Admin/Superadmin/Inspector/RLPT | Login, menu, URL directa, refresh, 403. | Usuarios por rol. | Solo ve rutas permitidas; backend 403 no deja datos antiguos. | Smoke/critica | Seguridad transversal. |
| `empresa-contexto.spec.ts` | Multiempresa/Inspector | Seleccion empresa, refresh, cambio rapido, revocacion. | Dos empresas con datos distintos. | No mezcla datos y limpia contexto revocado. | Critica | Evita fuga multiempresa. |
| `accesos-externos.spec.ts` | Admin | Alta, duplicado, revocacion, caducidad, fallo Keycloak/email. | Emails nuevos/duplicados. | Estados, mensajes y auditoria correctos. | Critica | Ciclo de vida externo. |
| `informes-tabla.spec.ts` | Admin/RLPT/Inspector | Filtros, paginacion, ordenar, export tabla. | Dataset con centros, puestos y usuarios sin datos. | Totales, filtros y XLSX correctos por rol. | Critica | Modulo nuevo central. |
| `informes-simple.spec.ts` | Admin/RLPT/Inspector | Export simple con dias sin registro, festivo, vacaciones y baja. | Dataset UAT oficial. | Filas incluidas/excluidas segun reglas. | Critica | Calculo diario sensible. |
| `informes-detallado.spec.ts` | Admin/RLPT/Inspector | Export tramos con abierto, cruce medianoche y solape legacy. | Tramos problematicos. | Sin 500; incidencias o calculo correcto. | Critica | Datos reales imperfectos. |
| `inspector-privacidad.spec.ts` | Inspector | Empresas, listado anonimo, ficha y export. | Datos reales con PII y comentarios. | No aparece PII no autorizada. | Critica | Privacidad. |
| `rlpt-ambito.spec.ts` | RLPT | Menu, informes y rutas heredadas. | RLPT con ambito limitado. | No ve fuera de ambito; menu correcto. | Critica | Autorizacion por ambito. |
| `superadmin-simulacion.spec.ts` | Superadmin | Simular empresa, intentar mutar UI/API, salir. | Empresa con datos editables. | Acciones bloqueadas y contexto limpio. | Critica | Seguridad de simulacion. |
| `suplantacion.spec.ts` | Superadmin | Suplantar, refresh, salir y auditar. | Usuario objetivo activo/inactivo. | Banner, permisos objetivo y auditoria actor real+objetivo. | Critica si entra alcance | Funcionalidad de alto riesgo. |
| `sesion-export.spec.ts` | Admin/Inspector | Export largo, logout, caducidad y revocacion. | Export con latencia. | No descarga tras perder permiso/sesion. | Critica | Seguridad en operaciones largas. |
| `csv-usuarios.spec.ts` | Admin | Import valido, cabecera invalida, duplicados, fallo Keycloak parcial. | CSVs preparados. | Resultado parcial/errores segun implementacion actual. | Regresion | Evita romper Fase I. |

---

## 5. Tests que no conviene hacer solo con E2E

| Area | Tipo recomendado | Justificacion |
|---|---|---|
| Calculo de horas diarias/semanales/mensuales | Unit/integration backend | Demasiadas combinaciones para E2E; se necesita precision. |
| Festivos, vacaciones, planificacion y cruce de anio | Unit/integration backend | Casuistica matematica y de calendario. |
| Anonimizacion de DTOs | API contract/integration | Hay que probar que la API no devuelve PII, no solo que UI no la pinta. |
| XLSX | Integration con lectura de XLSX/golden files | Validar columnas, formatos, filtros, datos y ausencia de PII. |
| Permisos backend por endpoint | Security integration | E2E no cubre todos los endpoints mutantes. |
| Concurrencia/idempotencia | API/integration | Mas fiable simular doble request, locks y fallos parciales. |
| Logs/auditoria | Unit/integration | No es estable ni suficiente comprobarlo por UI. |
| Performance XLSX | Performance/integration | Necesita volumen y medicion de memoria/tiempo. |

---

## 6. Criterios de aceptacion QA

| Area | Criterio minimo |
|---|---|
| Permisos | Cada rol tiene tests positivos y negativos, incluyendo URL directa. |
| Anonimato | API, UI, XLSX, logs y auditoria no exponen PII no autorizada. |
| Informes | Tabla, simple y detallado cuadran con dataset UAT. |
| Exportaciones | Rango vacio, grande, filtrado, paginado y concurrente tienen comportamiento definido. |
| Fechas | Hoy, futuro, pasado, fin de semana, festivo, cambio de mes/anio y zona horaria probados. |
| Historicos | Datos legacy incompletos no generan 500 ni totales incoherentes sin control. |
| Accesos externos | Alta, duplicado, revocacion, caducidad y fallo externo probados. |
| Sesion | Logout/caducidad/revocacion durante operaciones largas no filtran datos. |
| Concurrencia | Doble click y peticiones obsoletas no duplican ni mezclan datos. |
| UAT | Negocio valida dataset y resultados esperados antes del cierre. |

---

## 7. Recomendacion QA final

No iniciar automatizacion E2E masiva hasta cerrar las decisiones bloqueantes. Primero deben cerrarse reglas y dataset. Despues conviene automatizar pocos recorridos criticos y reforzar calculos, permisos, anonimato y XLSX con tests de backend/integracion.
