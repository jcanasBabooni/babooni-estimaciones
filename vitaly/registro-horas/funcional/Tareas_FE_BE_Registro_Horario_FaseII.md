# Tareas FE / BE — Registro Horario Fase II

> Desglose de tareas para la estimación de Fase II.
> **Estado (jul 2026):** estimacion revisada tras funcional nuevo + validacion repos + prototipo Vitaly + ajuste equipo Fase I. **Compromiso: 480 h = 3 sprints** (160 h capacidad/sprint, 2 sem).
>
> **Leyenda:**
> - `[NUEVO]` desarrollo nuevo de extremo a extremo.
> - `[REUTILIZA]` se apoya en una pieza ya construida en Fase I (a confirmar con acceso a repos).
> - `[AMPLÍA]` modifica/extiende una pantalla o componente existente de Fase I.
> - `Depende de:` decisión de negocio (D#) o validación técnica (T#) pendiente (ver HTML de dudas).

---

## Alcance de la Fase II (resumen)

1. **Módulo de Informes** parametrizable por rol (Administrador/a, Inspector/a, RLPT).
2. **Rol Inspector/a** — acceso externo, solo lectura, datos anonimizados, navegación multi-empresa.
3. **Accesos externos** — nueva pestaña en Configuración del Administrador/a.
4. **Rol RLPT** — hereda Perfil Usuario (Fase I) + Módulo de Informes.

Fuera de alcance Fase II (confirmado D26): Ayuda avanzada en nuevos roles → Fase III. App móvil e IA **no entran en alcance de estimación Fase II**, aunque negocio señala interés estratégico a corto plazo.

> **Reparto con Vitaly (diseño UX/UI):** el **diseño UX/UI lo aporta el equipo técnico de Vitaly** (flujos, prototipos y design system; prototipos de referencia ya disponibles). Por tanto, las tareas `FE-*` de este documento **NO incluyen diseño** (wireframes, prototipado ni decisiones de UI): cubren solo la **implementación frontend** (maquetación e integración de APIs) a partir del diseño entregado por Vitaly. El desarrollo de **frontend y backend permanece en Babooni**.

---

## Decisiones cerradas — respuestas cliente (informes Vitaly)

Fuentes: `Informacion_a_solicitar_negocio_Registro_Horario_FaseII_mejorado (2)_report.html` y `Informacion_a_solicitar_equipo_tecnico_Registro_Horario_FaseII_mejorado (1)_report.html`. El cuestionario ampliado usa IDs **D01–D26** (negocio) y **T1–T9** (técnico); abajo se mapean a las dudas originales **D1–D10 / T1–T4** de este documento.

### Resumen ejecutivo

| Área | Decisión | Impacto en estimación |
|------|----------|------------------------|
| **Permisos (D01)** | Matriz por rol cerrada: Admin (+ Informes Fase II), Usuario, Superadmin simulación lectura + **suplantación**, Inspector solo lectura anonimizado, RLPT usuario + Informes datos reales | Confirma BE-0.1/0.2, FE-0.1/0.2; **añade suplantación** (no estaba desglosada) |
| **Accesos externos (D02, D06)** | Inspector/RLPT = accesos externos; alta/revocación en Config > Accesos externos; estados Activo / No activo; revocación inmediata; Inspector multiempresa con un email | Confirma BE-3.*, BE-0.4/0.5; modelo técnico concreto pendiente acuerdo interno (T2) |
| **Anonimización (D03)** | Difuminar nombre/apellidos; **ID Persona visible** (ej. PT-0005); descripciones/comentarios de compensaciones **visibles** en lectura | Confirma BE-0.3/T3 en backend; **reduce** alcance vs. ocultar textos sensibles (antigua D9) |
| **KPIs Inspector (D09)** | Reglas: Sin registro (según teóricas/planificación; no festivos/vacaciones salvo param.), Correcto, Incompleto (jornada no cerrada); estado sin empresa = módulo Empresas | Confirma BE-2.3, FE-2.2; validar alineación con `CompanyUserRegistroResumenService` |
| **RLPT (D11)** | **Híbrido:** ficha/trabajador normal + módulo Informes sobre **toda la plantilla, datos reales** | Confirma BE-4.1 REUTILIZA + BE-4.2/FE-4.2; no es “solo consulta externa” |
| **Informes (D13, D15, D18)** | Módulo unificado; columnas por formato definidas; **exportación CSV** (confirmado equipo técnico, jun 2026); periodo filtrado; duraciones HH:MM; **sin** desglose ordinarias/extra (solo horas totales + balance compensaciones); toast si no hay datos | Confirma BE-1.*, FE-1.*; **BE-1.8 fuera de alcance**; **CSV reutiliza motor Fase I** (no xlsx) |
| **Históricos (D20)** | Informes nuevos sobre BD central; exports Fase I en ficha de perfil se mantienen | Sin migración masiva; atención anti-fuga en CSV legacy para Inspector |
| **Superadmin (D23, T7)** | Simulación lectura estricta FE+BE; suplantación vía **Keycloak impersonate** (POC Vitaly) | Refuerza BE-0.2; **nuevas tareas** suplantación FE/BE + auditoría |
| **UAT (D26, T9)** | Dataset UAT **obligatorio** antes del cierre; funcional prevalece sobre prototipo | Confirma QA-5.*; bloqueante hasta que negocio entregue dataset |
| **Casos de uso y criterios de aceptación** | **Recibidos** (anexo funcional jul 2026); normalizados en `CU_CA_Registro_Horario_FaseII.md` (CU-01…07, CA-01…25; **CSV**) | Trazabilidad CU/CA → BE/FE/QA incorporada; **480 h** |

### Mapeo dudas originales → respuestas nuevas

| Original | Nueva(s) | Cierre |
|----------|----------|--------|
| D1 Anonimización | D03 | **Cerrada** (nombre/apellidos; ID visible; comentarios visibles) |
| D2 Acceso Inspector | D02, D06 | **Cerrada** (externo; admin gestiona; revocación inmediata) |
| D3 KPIs | D09 | **Cerrada** (reglas principales; detalle fino en implementación/UAT) |
| D4 RLPT Informes | D11 | **Cerrada** (usuario + informes reales plantilla completa) |
| D5 Formatos Informes | D13, D15 | **Cerrada** (columnas por formato; exportación **CSV**) |
| D6 App/IA | D26 | **Cerrada** Fase II excluye; App/IA mencionadas como evolutivo |
| D7 Columnas | D13 | **Cerrada** |
| D8 Ordinarias/extra | D18 | **Cerrada: NO** en Fase II (solo totales + balance) |
| D9 Textos sensibles | D03 | **Parcial:** negocio mantiene descripciones visibles; riesgo legal anotado |
| D10 Vínculo multiempresa | D02, D06 | **Cerrada** (Inspector multiempresa; email único) |
| T1 Roles/permisos | D01, T1 | **Cerrada** funcional; diseño técnico A/B/C a decidir internamente |
| T2 Anonimización capa | D03, T3 | **Cerrada:** backend acordado |
| T3 Multiempresa Inspector | D09, T4 | **Cerrada** funcional; endpoint ámbito = BE-2.1 |
| T4 Acceso externo | D02, D06, T2 | **Parcial:** negocio cerrado; modelo BD/Keycloak en T2 incompleto |

### Puntos abiertos / contradicciones (antes de horas)

| # | Tema | Detalle | Acción |
|---|------|---------|--------|
| 1 | ~~XLSX vs CSV~~ | **RESUELTO (jun 2026): CSV** — confirmado por equipo técnico y validado con negocio | Reutiliza exportación CSV de Fase I; **BE-1.9 baja de esfuerzo** (no motor xlsx nuevo) |
| 2 | **Modelo accesos externos** | T2 describe ecosistema Liferay/Keycloak; no elige tabla `acceso_externo` vs extensión | Decisión técnica Babooni (recomendación previa: opción B) |
| 3 | **Dataset UAT** | Obligatorio pero **no adjunto** | Solicitar a negocio; bloquea QA-5.4 y golden CSV |
| 4 | ~~Casos de uso y criterios de aceptación~~ | **CERRADO (jul 2026)** — ver `CU_CA_Registro_Horario_FaseII.md` | Matriz Minerva + trazabilidad; CSV unificado |
| 5 | **Suplantación** | Nuevo alcance explícito (D23, T7) | Añadir tareas BE/FE + QA (ver informe 03: F2-026/F2-027) |
| 6 | **Comentarios visibles al Inspector** | Contradice cautela D9 original | Documentar en QA-5.1; no ampliar anonimización salvo nuevo acuerdo |
| 7 | **SLA/volumen export** | D18 no fija límites de rango ni timeout | Valorar buffer en informe conservador (+6–7 sprints) o preguntar |

### Ajustes al backlog de tareas (tras respuestas)

| Tarea | Ajuste |
|-------|--------|
| BE-1.8 | **Fuera de alcance** (D18: no ordinarias/extra) |
| BE-1.4/1.5/1.6 | **Exportación CSV** (no Excel) — formatos tabla / simple / detallado |
| BE-1.9 | **Reclasificada a `[AMPLÍA]`**: reutiliza motor CSV de Fase I + nombre dinámico; ya no es motor xlsx nuevo |
| BE-2.5, BE-2.6 | Exportación **CSV** (anonimizado / movimientos del año) |
| BE-0.3, BE-2.2, BE-2.4 | Mantener; reglas anonimización más acotadas (ID visible, textos visibles) |
| BE-3.*, FE-3.* | Sin cambio de alcance |
| BE-4.2, FE-4.2 | RLPT con datos **reales** toda plantilla — sin capa anonimizada |
| **BE-0.6 / FE-0.4 / QA-5.5** | **Añadidas:** suplantación Keycloak impersonate + auditoría (D23, T7) |
| QA-5.1 | Enfocar en nombre/apellidos + exports; no exigir ocultar comentarios si negocio no lo pide |
| QA-5.3 | Pruebas de **3 formatos CSV** (no Excel) |

---

## Casos de uso y criterios de aceptación

**Estado:** recibidos en anexo del funcional (jul 2026). Documento normalizado: **`CU_CA_Registro_Horario_FaseII.md`**.

| ID | Caso de uso | Actor | CA |
| :---- | :---- | :---- | :---- |
| CU-01 | Filtrar y consultar Informes | Admin, RLPT, Inspector | CA-01…CA-06 |
| CU-02 | Exportar informes **CSV** | Admin, RLPT, Inspector | CA-07…CA-09 |
| CU-03 | Acceso Inspector multi-empresa | Inspector | CA-10…CA-12 |
| CU-04 | Plantilla anonimizada | Inspector | CA-13…CA-16, CA-23, CA-25 |
| CU-05 | Accesos externos | Administrador | CA-17…CA-19 |
| CU-06 | Simulación y suplantación | Superadmin | CA-20…CA-21, CA-24 |
| CU-07 | RLPT + Informes datos reales | RLPT | CA-22 *(complementario)* |

**Notas de normalización:**
- Anexo negocio usaba «Caso de Aceptación X.Y» y formato narrativo → renumerado **CA-01…CA-21** en formato tabla Minerva.
- Exportación unificada a **CSV** (anexo decía Excel; decisión técnica/negocio cerrada).
- **CA-22…CA-25** complementarios Babooni (RLPT, export ficha Inspector, auditoría suplantación, KPIs) — cubren huecos del anexo sin ampliar horas.

**Trazabilidad resumida:**

| Bloque QA | Criterios |
| :---- | :---- |
| QA-5.1 | CA-13, CA-14, CA-23 |
| QA-5.2 | CA-10…CA-12, CA-17…CA-19, CA-22 |
| QA-5.3 | CA-07…CA-09 |
| QA-5.4 | CA-25 |
| QA-5.5 | CA-21, CA-24 |

> **480 h** tras revision CU/CA y ajuste jul 2026 (−48 h vs. 528 h en Transversal/Inspector). Pendiente bloqueante UAT: **dataset oficial** (D26/T9).

---

## Validación repos (jul 2026 — ramas actualizadas)

Repos analizados: `registro-horario-frontend` (Angular 20) y `registrohorario-backend` (Spring Boot 3.2). Funcional de referencia: **`Fase II - Funcional Rediseño Registro Horario.md`** (versión enriquecida, ~46 % más corta que `docx_old.md`; hereda KPIs, filtros, usuarios y RLPT de Fase I).

### Hallazgos clave

| Área | Rama | Estado Fase II |
|------|------|----------------|
| **Backend** | `feature/b-dev-sprint7` / `sprint8` | **0 %** — sin Inspector, RLPT, Informes, anonimización ni suplantación en código |
| **Frontend productivo** | `feature/sprint7` / `sprint8` | **0 %** — sin módulo Informes ni roles nuevos |
| **Prototipo UX Vitaly** | `origin/feature/fase_II_ux` | **Shell FE con MSW** — Informes, Accesos externos, permisos Inspector/RLPT, i18n; **sin integración API real** |
| **Diseño UX/UI** | Vitaly (Lovable + rama `fase_II_ux`) | **Fuera de horas FE Babooni** — las tareas FE son portar/implementar e integrar, no diseñar |

### Impacto en estimación (vs. 800 h jun 2026)

- **BE:** esfuerzo casi íntegro (capa roles, solo lectura, anonimización, Informes agregado, accesos externos).
- **FE:** recorte relevante — Vitaly entrega maquetación de referencia; Babooni integra stores/API, multiselect puesto, anonimización UI y merge con sprint8.
- **Inspector FE:** funcional nuevo delega módulo Usuarios/KPIs/ficha a Fase I → tareas FE-2.4/2.6 reclasificadas de NUEVO a AMPLÍA.
- **Deduplicación:** FE-2.5 absorbida en FE-1.8 (variante Inspector); i18n base en prototipo Vitaly.
- **Resultado:** compromiso **480 h = 3 sprints × 160 h**. S1–S2 solo desarrollo; todo QA/cierre en S3.

**La mayoría de dudas D1–D10 / T1–T4 están cerradas** tras respuestas cliente (ver sección anterior); lo siguiente documenta el punto de partida técnico.

### Reutilizable (alto)
- `CompensacionService` → BE-1.3
- Perfil RLPT (rutas FE + endpoints BE) → BE-4.1, FE-4.1
- Config 5 pestañas, i18n 5 idiomas → FE-2.6 (patrón), FE-0.3
- KPIs agregados `CompanyUserRegistroResumenService` → BE-2.3 (ampliar/validar reglas D3)
- Patrón multi-empresa `EmpresaContextSwitchService` / `empresas/` → FE-2.2/2.3 (parcial)
- Keycloak invitaciones, auditoría `*AuditRecorder`

### Parcial / extensión
- Roles en `CurrentUserAccessService` / `AppPermission` → BE-0.1, FE-0.1 (sin matriz RBAC; cambio arquitectónico moderado — ver análisis T1)
- `modoSimulacion` en FE → FE-0.2 (patrón solo lectura parcial; generalizar a `modoSoloLectura`)
- Ficha usuario + exports CSV → BE-2.4, BE-2.6 (requieren capa anonimización D1/D9)
- Módulo Informes Inspector → FE-2.5 (núcleo FE-1 nuevo; variante parametrizada)

### Ausente / nuevo
- Módulo Informes completo (FE-1.*, BE-1.1–1.7; ~~BE-1.8~~ excluida)
- Anonimización, CRUD accesos externos, roles Inspector/RLPT en modelo
- Suplantación (impersonate) → BE-0.6, FE-0.4
- ~~Desglose horas ordinarias/extra~~ (D8/D18: **descartado** en Fase II)
- ~~Motor xlsx~~ (jun 2026: exportación **CSV** confirmada → BE-1.9 reutiliza Fase I)

### Deuda detectada (no bloquea etiquetas, sí esfuerzo)
- FE llama `GET .../resumen-registros/detalle` — BE no implementado
- `codigoEmpleado` en BE, no en dominio `Usuario` FE (candidato ID anonimizado — T2)
- `requireAnyActiveCompanyMembership` bloquea Inspector «sin empresa» (T4)
- CSV exporta observaciones/descripciones/comentarios (refuerza D9)

### Tabla de reclasificación tras repos

| Tarea | Antes | Tras repos | Nota |
| :-- | :-- | :-- | :-- |
| BE-1.3 | REUTILIZA | **REUTILIZA** ✓ | `CompensacionService` confirmado |
| BE-1.9 | NUEVO (xlsx) | **AMPLÍA** | Confirmado **CSV**: reutiliza export Fase I + nombre dinámico |
| BE-2.3 | NUEVO | **AMPLÍA** | KPIs base existen; validar reglas D3 |
| BE-2.4 | REUTILIZA | **AMPLÍA** | Ficha existe; falta anonimización |
| BE-2.6 | REUTILIZA | **AMPLÍA** | Export CSV existe; filtrar campos D9 |
| BE-4.1 | REUTILIZA | **REUTILIZA** ✓ | Perfil RLPT ya en Fase I |
| BE-4.2 | REUTILIZA | **NUEVO** | Módulo Informes no existe |
| FE-0.3 | REUTILIZA | **REUTILIZA** ✓ | ngx-translate 5 idiomas |
| FE-2.5 | REUTILIZA | **AMPLÍA** | Variante sobre módulo nuevo FE-1 |
| FE-2.6 | REUTILIZA/AMPLÍA | **AMPLÍA** | 5 pestañas existen; modo lectura nuevo |
| FE-4.1 | REUTILIZA | **REUTILIZA** ✓ | Pantallas usuario RLPT |
| FE-4.2 | REUTILIZA | **NUEVO** | Informes aún no implementado |
| FE-0.2 | NUEVO | **AMPLÍA** | `modoSimulacion` ya deshabilita UI; falta centralizar y cubrir Inspector |

> Etiquetas actualizadas en el desglose según esta tabla. Tareas no listadas mantienen su etiqueta original (mayoría `[NUEVO]` por ausencia en Fase I).

### Análisis detallado T1 — Roles y permisos (jun 2026)

**No existe matriz RBAC única.** El perfil efectivo combina dimensiones independientes:

| Dimensión | Dónde vive | Qué controla |
| :-- | :-- | :-- |
| Superadmin | Config `LIFERAY_SUPERADMINS` | `/empresas`, lectura cualquier empresa |
| Administrador | `appuser_empresa.is_admin` + caché Liferay | Escritura empresa, Configuración, CRUD usuarios |
| Usuario | Implícito si no es admin | Inicio, registro jornada, mi perfil |
| Referente | `appuser_empresa_persona_referencia` | Gestión parcial de usuarios asignados |

**Backend** — `CurrentUserAccessService` con lógica imperativa; solo 4 `@PreAuthorize`. Sin bloqueo global de escritura por rol. `requireAnyActiveCompanyMembership` bloquea Inspector «sin empresa».

**Frontend** — 12 `AppPermission` en `buildAppPermissions`; rutas en `routeRequiredPermission` (4 reglas). `modoSimulacion` deshabilita UI en ~15+ componentes pero **el BE no lo conoce**.

**Tres «externos» distintos:** (1) `esAdministradorExterno` Liferay, (2) interceptor Keycloak `external-roles-enabled: false`, (3) Inspector/RLPT Fase II — ausente.

**Opciones de diseño (pendiente equipo):**
- **A** — `tipo_acceso` en `appuser_empresa`
- **B** — Tabla `acceso_externo` + vínculo N empresas _(recomendada técnicamente para Inspector)_
- **C** — Roles Keycloak + tabla ámbito empresa

**Solo lectura:** interceptor BE (denegar mutaciones por rol) + `modoSoloLectura` centralizado en FE (generalizar `modoSimulacion`).

**Riesgo estimación:** T1 es **cambio arquitectónico moderado** — el caso Inspector (solo lectura + anonimización + multi-empresa) es el de mayor impacto; RLPT es más cercano a usuario + Informes.

---

## 0. Transversal / Base técnica

### Backend
- **BE-0.1** `[AMPLÍA]` Ampliar sistema de roles/permisos para **Inspector/a** y **RLPT**. _Repos: sin matriz RBAC; extensión de `CurrentUserAccessService` + modelo de acceso (opción A/B/C T1)._ _Depende de: T1, T4, D10_
  - Definir tipo de acceso externo (enum o tabla `acceso_externo`) y exponerlo en `/v1/me`
  - Nuevos métodos de contexto: `requireInspectorReadContext`, `requireRlptContext`
  - Excepción condicional a `requireAnyActiveCompanyMembership` para Inspector «sin empresa»
  - Ampliar `UserAuthorization` / beans `@PreAuthorize` si aplica
- **BE-0.2** `[NUEVO]` **Modo solo lectura** transversal en backend. _Repos: no existe; `modoSimulacion` es solo FE._ _Depende de: T1_
  - Opción preferida: interceptor/filtro que deniegue PUT/PATCH/POST/DELETE a roles Inspector (y otros solo lectura)
  - Alternativa: `denyIfReadOnlyRole()` invocado en cada servicio mutante (~30 puntos de escritura)
  - Validar que superadmin en simulación y Inspector quedan cubiertos sin regresiones
- **BE-0.3** `[NUEVO]` Servicio de **anonimización / disociación** de datos de personas trabajadoras (nombre, apellidos y campos sensibles) aplicable a vistas y exportaciones. _Depende de: D1, D9, T2_
- **BE-0.4** `[NUEVO]` **Autenticación de accesos externos** (alta sin contraseña → invitación/credencial, caducidad, revocación). _Depende de: D2_
- **BE-0.5** `[NUEVO]` **Control de acceso multi-empresa** para externos (vínculo usuario externo ↔ empresa(s) y filtrado por ámbito). _Depende de: D10, T4_
- **BE-0.6** `[NUEVO]` **Suplantación de usuario (impersonate)** para superadmin vía Keycloak. _Cerrado D23/T7 (POC Vitaly): obtener token/sesión del usuario suplantado, marcar la sesión como suplantada y registrar evento de auditoría (quién suplanta a quién, inicio/fin)._ _Depende de: T7_
  - Endpoint de inicio/fin de suplantación + propagación del contexto suplantado
  - Auditoría obligatoria (`*AuditRecorder`) de toda la sesión suplantada
  - Salvaguardas: la suplantación no escala privilegios por encima del usuario destino

### Frontend
- **FE-0.1** `[AMPLÍA]` Registrar roles **Inspector/a** y **RLPT** en enrutado, guards y menús. _Repos: `RolEnum` solo tiene 3 valores; `routeRequiredPermission` tiene 4 reglas._ _Depende de: T1_
  - Ampliar `RolEnum`, `buildAppPermissions` (nuevos permisos: Informes, etc.)
  - Nuevas rutas: `/informes`, variante `/empresas` Inspector
  - Ajustar `sidebar`, `rutaInicial`, `canAccessRoute` por rol
  - Menú Inspector: Empresas, Usuarios, Informes, Configuración (lectura)
  - Menú RLPT: hereda usuario + Informes
- **FE-0.2** `[AMPLÍA]` Patrón **solo lectura** transversal en UI. _Repos: `modoSimulacion` ya deshabilita acciones en lista usuarios, ficha (4 tabs) y config (5 tabs)._ _Depende de: T1_
  - Generalizar `modoSimulacion` → `modoSoloLectura` en `AppContextService` (Inspector + simulación superadmin)
  - Centralizar `accionesDeshabilitadas` para no duplicar lógica en ~15+ componentes
  - Aviso visual distintivo Inspector («solo lectura · anonimizado»)
- **FE-0.3** `[REUTILIZA]` Internacionalización de los nuevos textos (ES, EN, GL, EU, CA).
- **FE-0.4** `[NUEVO]` UI de **suplantación de usuario** para superadmin: acción de iniciar suplantación, **banner persistente** «Estás suplantando a …» y botón de salir/volver a tu sesión. _Depende de: T7, BE-0.6_
- **FE-0.5** `[AMPLÍA]` **Integración rama Vitaly** (`fase_II_ux` → sprint8 productivo): merge, eliminar MSW/mocks, alinear con stores y patrones Fase I. _Repos: prototipo en `origin/feature/fase_II_ux`._

---

## 1. Módulo de Informes (parametrizable por rol)

> Mismo módulo servido a 3 roles con reglas distintas (búsqueda, formatos y anonimización).
> Variante Administrador/a = base; Inspector/a y RLPT reutilizan el núcleo.

### Backend
- **BE-1.1** `[NUEVO]` Endpoint de **listado de registros agregados** por persona (horas totales + compensaciones) con filtros: periodo (Hoy/Semana/Mes/Personalizado), texto, puesto, centro. Orden y paginación (10/pág). _Depende de: D7_
- **BE-1.2** `[NUEVO]` Cálculo de **horas totales** del periodo por persona. _Depende de: D8_
- **BE-1.3** `[REUTILIZA]` Cálculo de **balance de compensaciones** del periodo (motor de Fase I).
- **BE-1.4** `[NUEVO]` Generación de CSV **Informe de tabla** (formato A). _Depende de: D7_
- **BE-1.5** `[NUEVO]` Generación de CSV **Informe simple** (una fila por usuario y día). _Depende de: D7_
- **BE-1.6** `[NUEVO]` Generación de CSV **Informe detallado** (una fila por tramo: tipo, inicio, fin, duración). _Depende de: D7_
- **BE-1.7** `[NUEVO]` **Regla de no-generación**: si no hay datos, no se crea archivo (respuesta para toast).
- **BE-1.8** ~~Desglose horas ordinarias/extra~~ — **Fuera de alcance Fase II** (cerrado D18: solo horas totales + balance compensaciones).
- **BE-1.9** `[AMPLÍA]` Exportación a **CSV** (confirmado jun 2026) reutilizando el motor de Fase I + **nombre de archivo dinámico** (tipo + fecha). _Repos: Fase I ya exporta CSV; se amplía con las columnas/formatos del módulo Informes._

### Frontend
> _Prototipo Vitaly en `fase_II_ux` (MOCK). Tareas FE = portar diseño + store/API real._

- **FE-1.1** `[AMPLÍA]` Pantalla **Informes**: cabecera, subtítulo y botón "Descargar informe" (port desde Vitaly).
- **FE-1.2** `[AMPLÍA]` **Selector de periodo** — reutiliza `ModalPeriodoComponent` Fase I + wiring API.
- **FE-1.3** `[AMPLÍA]` **Zona de filtros** (buscar, puesto y centro **multiselección** según funcional §3.1.2; corregir mock Vitaly single-select).
- **FE-1.4** `[AMPLÍA]` **Tabla de resultados** ordenable, colores compensación, KPI "Mostrando X de Y" + store paginado.
- **FE-1.5** `[AMPLÍA]` **Estado vacío** (port Vitaly + lógica real sin datos).
- **FE-1.6** `[REUTILIZA]` **Paginación** — reutiliza `paginacion.utils` Fase I.
- **FE-1.7** `[AMPLÍA]` **Modal de descarga** (port Vitaly) + descarga CSV real + toast sin datos.
- **FE-1.8** `[AMPLÍA]` Parametrización por rol (Admin/RLPT: 3 formatos; Inspector: anonimizado único). _Incluye variante FE-2.5._

---

## 2. Rol Inspector/a (solo lectura · anonimizado)

### Backend
- **BE-2.1** `[NUEVO]` Endpoint **listado de empresas accesibles** por el Inspector/a (filtros CIF/nombre, fechas alta). _Depende de: D10, T4_
- **BE-2.2** `[NUEVO]` Endpoint **Usuarios anonimizados** de la empresa seleccionada (datos disociados). _Depende de: D1, D9, T2_
- **BE-2.3** `[AMPLÍA]` Cálculo de **KPIs**: Personas trabajadoras, Registro correcto, Sin registro, Registro incompleto (según periodo). _Repos: `CompanyUserRegistroResumenService` existe; validar reglas vs funcional._ _Depende de: D3_
- **BE-2.4** `[AMPLÍA]` Ficha de usuario (datos personales, compensaciones, planificación) servida en lectura/anonimizada. _Repos: ficha existe; capa anonimización nueva._ _Depende de: D9, T2_
- **BE-2.5** `[NUEVO]` CSV **Informe anonimizado** (único formato bloqueado para Inspector/a). _Depende de: D8_
- **BE-2.6** `[AMPLÍA]` Exportación de **movimientos del año** de la ficha (CSV). _Repos: export CSV existe; filtrar descripciones/comentarios según D9._ _Depende de: D9_

### Frontend
> _Funcional §4.3 hereda KPIs, filtros, tabla y ficha del módulo Usuarios Admin Fase I._

- **FE-2.1** `[AMPLÍA]` **Estructura transversal** Inspector: sidebar/nav (parcial en Vitaly) + distintivo "solo lectura · anonimizado".
- **FE-2.2** `[AMPLÍA]` **Máquina de estados** Caso A/B (sin empresa → Empresas; con empresa → Usuarios + Informes + Config).
- **FE-2.3** `[AMPLÍA]` **Módulo Empresas** — extiende listado multi-empresa Fase I (filtros, "Acceder >"). _Depende de: D10_
- **FE-2.4** `[AMPLÍA]` **Usuarios + ficha** — reutiliza pantallas Fase I; añade difuminado nombre/apellidos, búsqueda por ID y bloqueo edición.
- **FE-2.5** ~~Módulo Informes Inspector~~ — **incluido en FE-1.8** (formato anonimizado único).
- **FE-2.6** `[AMPLÍA]` **Configuración lectura** — 5 pestañas Fase I + tab Accesos oculta para Inspector; `modoSoloLectura` en formularios.

---

## 3. Accesos externos (Configuración del Administrador/a)

### Backend
- **BE-3.1** `[NUEVO]` CRUD de **accesos externos** (alta tipo Inspector/RLPT, nombre, correo; listado; eliminación con revocación). _Depende de: D2, D10_
- **BE-3.2** `[NUEVO]` Registro de **creado por / fecha alta** y disparo de invitación/credencial al externo. _Depende de: D2_

### Frontend
- **FE-3.1** `[AMPLÍA]` Nueva pestaña **"Accesos externos"** al final de Configuración (buscador + botón "Añadir acceso").
- **FE-3.2** `[NUEVO]` Modal **Añadir acceso externo** (tipo, nombre, correo; validaciones).
- **FE-3.3** `[NUEVO]` **Tabla de externos** (nombre, tipo, correo, creado por, alta) + modal de **confirmación de eliminación**.

---

## 4. Rol RLPT

### Backend
- **BE-4.1** `[REUTILIZA]` Reutilizar endpoints del **Perfil Usuario** (Fase I) para el RLPT.
- **BE-4.2** `[NUEVO]` Dar acceso al **Módulo de Informes** (variante datos reales) al RLPT. _Repos: módulo Informes ausente en Fase I._ _Depende de: D4, D9_

### Frontend
- **FE-4.1** `[REUTILIZA]` Reutilizar pantallas del **Perfil Usuario** (Inicio, Registro jornada, Mi perfil, Ayuda).
- **FE-4.2** `[NUEVO]` Integrar el **Módulo de Informes** (FE-1) en el menú del RLPT. _Repos: módulo Informes ausente en Fase I._ _Depende de: D4_

---

## 5. Calidad / Cierre

- **QA-5.1** `[NUEVO]` Suite de pruebas de la anonimización (no fuga de datos en vistas ni en exportaciones CSV). _Depende de: D1, D9_
- **QA-5.2** `[NUEVO]` Pruebas de control de acceso por rol y por empresa (externos). Incluye verificar que rol solo lectura no puede mutar vía API directa (T1/BE-0.2). _Depende de: D10, T1, T4_
- **QA-5.3** `[NUEVO]` Pruebas de los **3 formatos CSV** (tabla / simple / detallado) y de la regla de no-generación sin datos. _Requiere dataset UAT con resultados esperados (golden CSV)._
- **QA-5.4** `[NUEVO]` Pruebas de KPIs del Inspector/a frente a planificación/festivos/vacaciones. _Depende de: D3_
- **QA-5.5** `[NUEVO]` Pruebas de **suplantación**: contexto correcto del usuario suplantado, no escalado de privilegios y trazabilidad completa en auditoría. _Depende de: BE-0.6, FE-0.4, T7_

---

## 6. Cierre operativo / Calidad técnica

> IDs **BE-C\*** / **FE-C\*** para no colisionar con BE-1.6, BE-1.7, etc. Alineado con el bloque de cierre del template Minerva (Cambio de Puesto: BE-14…22, FE-13…20). Parte del esfuerzo puede solaparse con TR-2/TR-3; pendiente de ajuste fino de horas.

### Backend

- **BE-C1** `[NUEVO]` Pruebas unitarias e integración del código nuevo (roles, anonimización, Informes CSV, accesos externos, suplantación). _Ref. Cambio de Puesto BE-14._
- **BE-C2** `[NUEVO]` Soporte al plan de pruebas y corrección de defectos backend. _Ref. BE-15._
- **BE-C3** `[NUEVO]` Reporte **Jacoco** sobre código nuevo (validar configuración en `build.gradle` Fase I).
- **BE-C4** `[NUEVO]` Ejecución **Pitest** sobre servicios nuevos (validar configuración en `build.gradle` Fase I).
- **BE-C5** `[NUEVO]` Documentación técnica y handover (servicios, contratos API, configuración, suplantación).
- **BE-C6** `[NUEVO]` Creación de MR + despliegue a entorno **DEMO** y verificación.
- **BE-C7** `[NUEVO]` **Plan de acción a Producción + implementación** (parte BE: pasos, ventana, rollback, MR a master, despliegue PRO, verificación). _Ref. BE-22._

### Frontend

- **FE-C1** `[NUEVO]` Accesibilidad, responsive y pruebas E2E de los flujos Fase II (Informes, Inspector/a, accesos externos, suplantación). _Ref. FE-13._
- **FE-C2** `[NUEVO]` Soporte al plan de pruebas y corrección de defectos frontend. _Ref. FE-14._
- **FE-C3** `[NUEVO]` **Karma + Jasmine**: arranque de suite + tests de Informes, Inspector/a, suplantación y validaciones (validar cobertura existente en Fase I). _Ref. FE-15._
- **FE-C4** `[NUEVO]` Pulido final y revisión de detalles antes de pase a PRO. _Ref. FE-16._
- **FE-C5** `[NUEVO]` Creación de MR + despliegue a entorno **DEMO** y verificación. _Ref. FE-18._
- **FE-C6** `[NUEVO]` **Plan de acción a Producción + implementación** (parte FE: pasos, ventana, rollback, MR a master, despliegue PRO, verificación). _Ref. FE-20._

---

## Dependencias críticas — estado tras respuestas cliente

| Ref | Estado | Bloquea |
| :-- | :-- | :-- |
| D03 / T3 — Anonimización (nombre/apellidos; ID visible; comentarios visibles) | **Cerrada** | BE-0.3, BE-2.2, BE-2.4, QA-5.1 |
| D02 / D06 — Accesos externos | **Cerrada** funcional | BE-0.4, BE-3.1, BE-3.2, FE-3.* |
| D09 — KPIs Inspector | **Cerrada** | BE-2.3, QA-5.4 |
| D11 — RLPT (usuario + Informes reales) | **Cerrada** | BE-4.2, FE-4.2 |
| D13 / D15 — Columnas y formatos (CSV) | **Cerrada** | BE-1.4–1.7, FE-1.7–1.8 |
| D18 — Ordinarias/extra | **Cerrada (NO)** | BE-1.8 excluida |
| D02 / D06 / T2 — Multiempresa Inspector | **Parcial** | BE-0.5, BE-2.1, FE-2.3 |
| D01 / T1 — Roles, permisos, solo lectura | **Cerrada** funcional | BE-0.1, BE-0.2, FE-0.1, FE-0.2, QA-5.2 |
| D23 / T7 — Suplantación | **Cerrada** enfoque | BE-0.6, FE-0.4, QA-5.5 |
| D26 / T9 — Dataset UAT | **Abierta** (obligatorio, no entregado) | QA-5.*, golden CSV |
| **Casos de uso / criterios de aceptación** | **Cerrada** (jul 2026) — `CU_CA_Registro_Horario_FaseII.md` | Trazabilidad CU/CA → BE/FE/QA; **480 h** |
| T5 — Formato exportación | **Cerrada: CSV** (jun 2026) | BE-1.4–1.9, BE-2.5, BE-2.6 |

> Con las decisiones cerradas (incluido **CSV** como formato y **CU/CA** jul 2026), la mayoría de `[AMPLÍA]`/`[NUEVO]` pasan a **estimables**. Bloqueantes restantes: **dataset UAT** (D26/T9) y **modelo técnico de accesos externos (T2, opción A/B/C)**. La validación de repos (jul 2026) sigue acotando reutilización.

---

## Estimación en horas (escenario revisado — funcional nuevo + repos jul 2026)

> **Base anterior:** 800 h / 5 sprints (jun 2026, post-respuestas Vitaly). **Revisión jul 2026:** funcional enriquecido («hereda Fase I»), validación repos (`fase_II_ux` = prototipo Vitaly, BE sin Fase II), deduplicación FE y ajuste realista.
> **Calendario:** sprint = **2 semanas**, capacidad **160 h/sprint**. **480 h ÷ 160 h = 3 sprints** exactos. **S1 y S2 = solo desarrollo**; **todo QA (QA-5.*, BE-C*, FE-C*) + TR-3 en Sprint 3**.

### Reparto equilibrado por sprint (~160 h cada uno)

| Sprint | Horas tareas | Contenido principal |
| :-- | --: | :-- |
| **Sprint 1** | **~161 h** | TR-1, FE-0.5, BE-0.1/0.2/0.3, FE-0.1/0.2, BE-0.4/0.5, BE-3.*, FE-3.*, FE-0.3, TR-2, BE-2.1 |
| **Sprint 2** | **~166 h** | BE-0.6, FE-0.4, BE-2.2–2.4, FE-2.1–2.3, BE-1.1–1.7, FE-1.1–1.6 |
| **Sprint 3** | **~153 h** | BE-1.9, FE-1.7/1.8, BE-2.5/2.6, FE-2.4/2.6, BE-4.*, FE-4.*, **QA-5.1–5.5**, **BE-C1–C7**, **FE-C1–C6**, TR-3 |

> Criterio: **Sprints 1–2 sin QA**. Sprint 3 concentra validación funcional, cierre técnico, UAT y PRO.

### 0. Transversal / Base técnica

| Tarea | Etiqueta | h | Sprint | Nota |
| :-- | :-- | --: | :-- | :-- |
| BE-0.1 Roles/permisos Inspector + RLPT | AMPLÍA | 18 | S1 | |
| BE-0.2 Modo solo lectura backend | NUEVO | 12 | S1 | |
| BE-0.3 Servicio anonimización/disociación | NUEVO | 11 | S1 | Solo nombre/apellidos (D03) |
| BE-0.4 Autenticación accesos externos | NUEVO | 8 | S1 | |
| BE-0.5 Control multi-empresa externos | NUEVO | 7 | S1 | |
| BE-0.6 Suplantación (impersonate) + auditoría | NUEVO | 24 | S2 | POC Vitaly |
| FE-0.1 Roles/rutas/guards/menús | AMPLÍA | 11 | S1 | Parcial en `fase_II_ux` |
| FE-0.2 Patrón solo lectura UI | AMPLÍA | 8 | S1 | Generaliza `modoSimulacion` |
| FE-0.3 i18n nuevos textos | REUTILIZA | 4 | S1 | Base en prototipo Vitaly |
| FE-0.4 UI suplantación (banner + salida) | NUEVO | 14 | S2 | |
| FE-0.5 Integración rama Vitaly → productivo | AMPLÍA | 11 | S1 | Merge `fase_II_ux`, quitar MSW |
| **Subtotal** | | **128** | | BE 80 + FE 48 |

### 1. Módulo de Informes (CSV)

| Tarea | Etiqueta | h | Sprint | Nota |
| :-- | :-- | --: | :-- | :-- |
| BE-1.1 Endpoint listado agregado + filtros | NUEVO | 21 | S2 | |
| BE-1.2 Cálculo horas totales | NUEVO | 4 | S2 | Reutiliza motor jornada |
| BE-1.3 Balance compensaciones | REUTILIZA | 4 | S2 | |
| BE-1.4 CSV informe tabla | NUEVO | 6 | S2 | |
| BE-1.5 CSV informe simple diario | NUEVO | 8 | S2 | |
| BE-1.6 CSV informe detallado tramos | NUEVO | 12 | S2 | |
| BE-1.7 Regla no-generación sin datos | NUEVO | 3 | S2 | |
| BE-1.8 ~~Ordinarias/extra~~ | excluida | 0 | — | — |
| BE-1.9 Export CSV + nombre dinámico | AMPLÍA | 8 | S3 | Motor Fase I |
| FE-1.1 Pantalla Informes (cabecera) | AMPLÍA | 2 | S2 | Port Vitaly |
| FE-1.2 Selector periodo + modal rango | AMPLÍA | 4 | S2 | Reutiliza modal Fase I |
| FE-1.3 Zona de filtros (multiselect) | AMPLÍA | 6 | S2 | Corregir mock Vitaly |
| FE-1.4 Tabla + store/API | AMPLÍA | 8 | S2 | |
| FE-1.5 Estado vacío | AMPLÍA | 2 | S2 | |
| FE-1.6 Paginación | REUTILIZA | 3 | S2 | Utils Fase I |
| FE-1.7 Modal descarga + toast | AMPLÍA | 4 | S3 | Port Vitaly + CSV real |
| FE-1.8 Parametrización por rol (+ Inspector) | AMPLÍA | 6 | S3 | Incl. ex-FE-2.5 |
| **Subtotal** | | **101** | | BE 66 + FE 35 |

### 2. Rol Inspector/a

| Tarea | Etiqueta | h | Sprint | Nota |
| :-- | :-- | --: | :-- | :-- |
| BE-2.1 Listado empresas accesibles | NUEVO | 10 | S1 | |
| BE-2.2 Usuarios anonimizados | NUEVO | 13 | S2 | DTO sobre listado existente |
| BE-2.3 KPIs Inspector | AMPLÍA | 7 | S2 | `CompanyUserRegistroResumenService` |
| BE-2.4 Ficha lectura/anonimizada | AMPLÍA | 9 | S2 | Hereda ficha Fase I |
| BE-2.5 CSV informe anonimizado | NUEVO | 5 | S3 | Variante BE-1.4 |
| BE-2.6 Export CSV movimientos del año | AMPLÍA | 4 | S3 | |
| FE-2.1 Estructura transversal Inspector | AMPLÍA | 4 | S2 | Nav en Vitaly |
| FE-2.2 Máquina estados Caso A/B | AMPLÍA | 6 | S2 | |
| FE-2.3 Módulo Empresas | AMPLÍA | 6 | S2 | Extiende Fase I |
| FE-2.4 Usuarios + ficha (herencia + blur) | AMPLÍA | 10 | S3 | Funcional §4.3 hereda Admin |
| FE-2.5 ~~Informes Inspector~~ | — | 0 | — | Ver FE-1.8 |
| FE-2.6 Configuración modo lectura | AMPLÍA | 5 | S3 | 5 tabs Fase I |
| **Subtotal** | | **79** | | BE 48 + FE 31 |

### 3. Accesos externos

| Tarea | Etiqueta | h | Sprint | Nota |
| :-- | :-- | --: | :-- | :-- |
| BE-3.1 CRUD accesos externos | NUEVO | 15 | S1 | Modelo A preferido |
| BE-3.2 Creado por/fecha + invitación | NUEVO | 10 | S1 | |
| FE-3.1 Pestaña Accesos externos | AMPLÍA | 4 | S1 | Tab en Vitaly (mock) |
| FE-3.2 Modal añadir acceso | AMPLÍA | 6 | S1 | Port + API |
| FE-3.3 Tabla externos + confirmación | AMPLÍA | 6 | S1 | Port + API |
| **Subtotal** | | **41** | | |

### 4. Rol RLPT

| Tarea | Etiqueta | h | Sprint | Nota |
| :-- | :-- | --: | :-- | :-- |
| BE-4.1 Reutilizar endpoints Perfil Usuario | REUTILIZA | 4 | S3 | |
| BE-4.2 Acceso Informes (datos reales) | NUEVO | 8 | S3 | Permisos + scope |
| FE-4.1 Reutilizar pantallas usuario | REUTILIZA | 3 | S3 | |
| FE-4.2 Integrar Informes en menú RLPT | AMPLÍA | 6 | S3 | Permisos + ruta |
| **Subtotal** | | **21** | | |

### 5. Calidad / Cierre

| Tarea | Etiqueta | h | Sprint | Nota |
| :-- | :-- | --: | :-- | :-- |
| QA-5.1 Anti-fuga anonimización | NUEVO | 10 | S3 | |
| QA-5.2 Control acceso por rol/empresa | NUEVO | 10 | S3 | |
| QA-5.3 3 formatos CSV + no-generación | NUEVO | 10 | S3 | Golden CSV |
| QA-5.4 KPIs Inspector vs planificación | NUEVO | 6 | S3 | Smoke + dataset UAT |
| QA-5.5 Suplantación (contexto + auditoría) | NUEVO | 8 | S3 | |
| **Subtotal QA** | | **44** | | |

### 6. Cierre operativo / Calidad técnica

| Tarea | Etiqueta | h | Sprint | Ref. Minerva |
| :-- | :-- | --: | :-- | :-- |
| BE-C1 Pruebas unitarias e integración | NUEVO | 4 | S3 | BE-14 |
| BE-C2 Soporte plan de pruebas BE | NUEVO | 3 | S3 | BE-15 |
| BE-C3 Reporte Jacoco | NUEVO | 2 | S3 | BE-16 |
| BE-C4 Ejecución Pitest | NUEVO | 2 | S3 | BE-17 |
| BE-C5 Documentación y handover | NUEVO | 2 | S3 | BE-18 |
| BE-C6 MR + despliegue DEMO | NUEVO | 2 | S3 | BE-20 |
| BE-C7 Plan PRO + implementación BE | NUEVO | 2 | S3 | BE-22 |
| **Subtotal BE cierre** | | **17** | | |
| FE-C1 a11y / responsive / E2E | NUEVO | 3 | S3 | FE-13 |
| FE-C2 Soporte plan de pruebas FE | NUEVO | 3 | S3 | FE-14 |
| FE-C3 Karma + Jasmine | NUEVO | 4 | S3 | FE-15 |
| FE-C4 Pulido final pre-PRO | NUEVO | 2 | S3 | FE-16 |
| FE-C5 MR + despliegue DEMO | NUEVO | 2 | S3 | FE-18 |
| FE-C6 Plan PRO + implementación FE | NUEVO | 2 | S3 | FE-20 |
| **Subtotal FE cierre** | | **15** | | |

### Bloques transversales

| Bloque | h | Sprint | Detalle |
| :-- | --: | :-- | :-- |
| TR-1 Cierre funcional/técnico | 14 | S1 | ADR accesos externos, contrato Informes CSV |
| TR-2 i18n / UX gaps | 6 | S1 | Solo huecos vs. prototipo Vitaly |
| TR-3 Hardening / UAT | 14 | S3 | Correcciones UAT; buffer acotado |
| **Subtotal** | **34** | | |

### Consolidación

| Bloque | h |
| :-- | --: |
| 0. Transversal / Base técnica | 128 |
| 1. Módulo de Informes (CSV) | 101 |
| 2. Rol Inspector/a | 79 |
| 3. Accesos externos | 41 |
| 4. Rol RLPT | 21 |
| 5. Calidad funcional (QA) | 44 |
| 6. Cierre operativo BE | 17 |
| 6. Cierre operativo FE | 15 |
| Transversales (TR-1/2/3) | 34 |
| **Total compromiso Babooni** | **480 h** |

Desglose por capa: **Backend 248 h** + **Frontend 154 h** + **QA + transversales 78 h** = **480 h**.

**Suplantación incluida (46 h):** BE-0.6 (24) + FE-0.4 (14) + QA-5.5 (8). Desarrollo S2; QA-5.5 en S3.

### Escenarios

| Escenario | Horas | Sprints | Condición |
| :-- | --: | :-- | :-- |
| Optimista | **440** | 2,75 | Recorte adicional; suplantación diferida |
| **Compromiso (recomendado)** | **480** | **3** | 3×160 h; equipo Fase I + herencia Inspector |
| Referencia jul (anterior) | 528 | 3,3 | Antes ajuste Transversal/Inspector |
| Referencia jun 2026 | 800 | 5 | Pre-funcional nuevo |
| Conservador | **560** | 3,5 | UAT tardío o merge Vitaly complejo |

> **Ajuste jul 2026 (revisión equipo):** **480 h** (−48 h vs. 528 h). Recorte en Transversal (−22 h), Inspector (−21 h) y QA/TR (−5 h). Motivo: propietarios Fase I, herencia pantallas Admin en Inspector, prototipo Vitaly y reglas anonimización acotadas (D03). Suplantación sin recorte (BE-0.6 24 h).
