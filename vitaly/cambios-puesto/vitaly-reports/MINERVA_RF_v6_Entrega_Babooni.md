# MINERVA RF v.6 — Cambio de puesto en reconocimiento médico
## Documento técnico de entrega — Babooni

| Campo | Valor |
|-------|-------|
| Versión doc funcional | v.6 · 04/06/2026 |
| Versión entrega técnica | 1.0 · 10/06/2026 |
| Responsable técnico Preving | f.rivas@preving.com |
| Figma | https://www.figma.com/proto/7fgbmsibGtXYTtv3XtpLSa/Minerva---Puestos?node-id=3216-2155 |
| Vídeo simulación | https://www.awesomescreenshot.com/video/53206525?key=261c1d4f7bde05571135037e679c9732 |

---

## 1. Arquitectura y repositorios

### 1.1 Repositorios backend

| Repositorio | Stack | Puerto / Contexto | Rol en el evolutivo |
|-------------|-------|-------------------|---------------------|
| `rrmm-backend` | Spring Boot 2.5.6 / Java 17 | 8825 · `/rrmm-backend` | **BE principal.** Aquí vive la ficha del RM. Babooni implementa aquí el nuevo endpoint de cambio de puesto. |
| `puestos-back` | Spring Boot 3.2.0 / Java 17 | — | Gestión de puestos y relaciones laborales (PPT_CEN_TRA). Babooni implementa aquí el nuevo endpoint de actualización de RL. |
| `prevencion` (legacy) | Spring 3.2.2 / Java 7 | — | **Solo consulta.** Contiene la lógica de referencia (`cambiarRm.do`, `cambiarRl.do`). No se toca. |
| `planning-vs` | Spring 3.2.18 / Java 7 | — | Comunicación con laboratorio (EA_LAB_COM). No se modifica; solo se consultan sus endpoints. |

### 1.2 Repositorios frontend

| Repositorio | Framework | Rol en el evolutivo |
|-------------|-----------|---------------------|
| `rrmm-frontend` | Angular 13.2.0 | **FE principal.** Recibe el modal de cambio de puesto y la ventana resumen de impacto. |

### 1.3 Entornos

| Entorno | URL |
|---------|-----|
| DEMO | `demointranet.vitaly.es` |
| PROD | `intranet.preving.com` |

**Infraestructura:** Kubernetes (GKE). Configuración de servicios y BD mediante variables de entorno por entorno.

### 1.4 Autenticación

JWT + Vitaly Gateway (`preving-security-1.2.jar`). El token lleva userId y grupos/roles del usuario. El control de acceso en rrmm-backend se gestiona mediante un sistema ACL propio en `Security.java` — no usa `@PreAuthorize` estándar de Spring.

---

## 2. Base de datos

**Motor:** Oracle. Esquema principal: `VIG_SALUD`. Sin Liquibase/Flyway — scripts SQL manuales.

Otros esquemas accesibles: `VS_2007`, `GC2006_RELEASE`, `PREVENCION`, `OPTEC`, `RRHH`.

### 2.1 Tablas maestras de clientes y centros

| Tabla | Esquema | PK |
|-------|---------|-----|
| `PC_CLIENTES` | `GC2006_RELEASE` | `ID` NUMBER(10) |
| `PC_CENTROS` | `GC2006_RELEASE` | `ID` NUMBER(10) |

**PC_CLIENTES** — campos relevantes para búsqueda:
- Por nombre: `NOMBRE`, `RAZONSOCIAL`, `NOMBRE_COMERCIAL`
- Por CIF: `NIF` VARCHAR2(12), `CIF` VARCHAR2(17), `CIFNIF` VARCHAR2(20)

**PC_CENTROS** — campos relevantes:
- FK cliente: `CLIENTE_ID` → `PC_CLIENTES.ID`
- Nombre: `NOMBRE` VARCHAR2(250), Código: `CODIGO` VARCHAR2(20)
- Localidad/provincia: vía join sobre `LOCALIDAD_ID`

### 2.2 Tablas de puestos de trabajo

Existen dos tipos de puestos: **estándar** (catálogo global, personalizable por cliente/centro) y **de centro** (propios de un centro concreto).

| Tabla | Esquema | Propósito |
|-------|---------|-----------|
| `ER_PUESTOS_TRABAJO` | `PREVENCION` | Catálogo maestro de puestos **estándar**. PK: `ID` |
| `ER_PUESTOS_TRABAJO_I18N` | `PREVENCION` | Nombres multiidioma del puesto estándar |
| `PPT_CEN_CLI_PERSONALIZADO` | `VIG_SALUD` | Nombre personalizado de un puesto estándar para un cliente/centro. FK: `PTO_STD_ID` → `ER_PUESTOS_TRABAJO.ID`. Nombre en columna `PUESTO` |
| `ER_CENTRO_PUESTOS` | `PREVENCION` | Puestos **de centro** (propios de un centro concreto). PK: `ID` |
| `CONF_PUESTOS` | `VIG_SALUD` | Configuración puesto × cliente × centro |
| `CONF_PUESTOS_ITEMS` | `VIG_SALUD` | Ítems/protocolos de cada configuración |
| `CEN_INFPUESTOS_RELACION` | `VIG_SALUD` | Puesto × centro con condiciones, riesgos y protocolos |
| `PUESTOS_X_PROTOCOLOS` | `VIG_SALUD` | Protocolo maestro asignado al puesto estándar |

**Resolución del nombre de un puesto estándar (prioridad):**
```sql
COALESCE(
  ppt_cen_cli_personalizado.puesto,      -- nombre personalizado para ese cliente/centro
  er_puestos_trabajo_i18n.denominacion,  -- nombre i18n
  er_puestos_trabajo.denominacion        -- nombre base
)
```

**Endpoint existente de listado de puestos (puestos-back):**
```
GET /puestos/listadoPuestos/{clienteId}/{centroId}
GET /puestos/listadoPuestos/{clienteId}/{centroId}/basico
GET /puestos/listadoPuestos/{clienteId}/{centroId}/periodicidad
```
Response incluye: código puesto, nombre puesto, personas/centro, personas/cliente.
El conteo personas/centro y personas/cliente es **online** (CTE con UNION ALL, no vista materializada).

### 2.3 Puestos adicionales — sin límite máximo

Hay **dos tablas distintas** según el ámbito:

| Ámbito | Tabla | FK |
|--------|-------|----|
| Adicionales del **trabajador** (RL) | `VIG_SALUD.PPT_CEN_TRA_ADICIONAL` | `RELACION_LABORAL_ID` → `PPT_CEN_TRA.ID` |
| Adicionales del **reconocimiento** | `VIG_SALUD.INF_RM_PTOS_ADICIONALES` | `RM_ID` → `INF_RM.RM_ID` |

`INF_RM_PTOS_ADICIONALES` columnas: `ID`, `RM_ID`, `PUESTO_ID`, `ESTANDAR` (0=Centro, 1=Estándar), `NOMBRE_PTO_INTEGRACION`.

### 2.4 Reconocimiento médico — `VIG_SALUD.INF_RM` (81 columnas)

Columnas críticas para el evolutivo:

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `RM_ID` | NUMBER(10) PK | ID del reconocimiento |
| `RM_TRA_ID` | NUMBER(10) NOT NULL | Trabajador |
| `RM_CLI_ID` | NUMBER(10) | Cliente |
| `RM_CEN_ID` | NUMBER(10) NOT NULL | Centro |
| `RM_PTR_ID` | NUMBER(10) NOT NULL | **Puesto principal** → `ER_PUESTOS_TRABAJO.ID` (tipo 1) o `ER_CENTRO_PUESTOS.ID` (tipo 2) |
| `INF_PTR_TIPO` | NUMBER(1) | Tipo puesto: **0=obsoleto (no usar)** · **1=estándar** → `ER_PUESTOS_TRABAJO` · **2=de centro** → `ER_CENTRO_PUESTOS` |
| `ACP_ID` | NUMBER(10) | ACP vinculado → `VS_2007.ACP_RM.ID` |
| `PERIODICIDAD_ID` | NUMBER(3) | Periodicidad resultante |
| `PERIODICIDAD_VALOR` | NUMBER(2) | Valor numérico de periodicidad |
| `FECHA_PROXIMO_RECONOCIMIENTO` | DATE | Fecha recomendada próximo RM |
| `LABORATORIO_ID` | NUMBER(10) | Laboratorio asignado |
| `RM_VALIDADO` | NUMBER(1) | 0=No validado, 1=Validado |
| `RM_FCH_CIERRE` | DATE | Fecha de cierre (NULL = pendiente) |
| `RM_MOVIDO` | VARCHAR2(2000) | Audit trail de cambios cliente/centro |
| `FCH_SEG_CONTABILIZADO` | DATE | Fecha contabilización seguimiento |
| `RM_ENVIADO` | VARCHAR2(1) | 'S'/'N' — enviado a lab |
| `ENVIO_ID` | NUMBER(10) | ID del envío al laboratorio |
| `MT_VALIDA` | NUMBER(10) | Médico del trabajo validador |
| `MC_ID` | NUMBER(10) | Médico coordinador |
| `RM_CF_ANIO_ID` | NUMBER(10) | Año de facturación |

### 2.5 Estados del reconocimiento

El estado actual es el **último registro** en `VIG_SALUD.INF4_RM_LOG` para ese `RM_ID`.

| Estado ID | Nombre | Observación |
|-----------|--------|-------------|
| **8** | **Pendiente** | Único estado que permite el nuevo circuito |
| 1 | Creado | |
| 4 | Preapto | |
| 6 | Finalizado | |
| 7 | Validado | |
| 30 | Admisión | |

### 2.6 Relación laboral — `VIG_SALUD.PPT_CEN_TRA` (34 columnas)

| Columna | Descripción |
|---------|-------------|
| `ID` NUMBER(10) PK | |
| `N_CEN` NOT NULL | Centro |
| `COD_CLI` NOT NULL | Cliente |
| `TRABAJADOR_ID` NOT NULL | Trabajador |
| `PUESTO_ID` | → `PREVENCION.ER_PUESTOS` (puesto OK Técnico) |
| `VS_PTST_ID` | → `PREVENCION.ER_PUESTOS_TRABAJO` (puesto VS estándar) |
| `VS_PTCE_ID` | → `PREVENCION.ER_CENTRO_PUESTOS` (puesto de centro, creado por el técnico de PRL) |
| `FCH_ALTA` NOT NULL | Inicio RL |
| `FCH_BAJA` | Fin RL — NULL = activa |

**Regla crítica:** Los tres campos de puesto son prácticamente excluyentes. Al actualizar, solo se rellena el campo correspondiente al tipo de puesto destino; los otros dos quedan a NULL.

Distribución real (9,7M registros): `PUESTO_ID` 46% · `VS_PTST_ID` 51% · `VS_PTCE_ID` 2,4%.

### 2.7 Comunicación laboratorio — `VS_2007.EA_LAB_COM`

| Columna | Descripción |
|---------|-------------|
| `TIPO` | 'R'=Reconocimiento / 'EA'=Estudio Analítico |
| `ITEM_ID` | RM_ID cuando TIPO='R' |
| `LABORATORIO_ID` | viene de `INF_RM.LABORATORIO_ID` |
| `MARCADO` | fecha marcado |
| `ANULADO` | fecha anulación (NULL = activa) |
| `ENVIADO` | fecha envío real a lab |
| `INTEGRADO` | fecha integración |

Tablas hijas: `EA_LAB_COM_X_PERFILES`, `EA_LAB_COM_X_PARAMETROS`, `EA_LAB_COM_X_MUESTRAS`, `EA_LAB_COM_X_ERRORES`.

---

## 3. Endpoints existentes reutilizables

### 3.1 Búsqueda de clientes
```
POST /trabajadores/clientes.do
Body: criterioCliente (string, mín. 3 chars o CIF)
Response: List<Cliente> — id, nombre, nif
Repo: prevencion (legacy)
```
> Babooni debe portar esta búsqueda a rrmm-backend o llamar al servicio equivalente disponible.

### 3.2 Centros por cliente
```
POST /trabajadores/centros.do
Body: clienteId, rm (bool)
Response: List<Centro> — id, nombre, provincia, localidad
Repo: prevencion (legacy)
```

### 3.3 Listado y conteo de puestos
```
GET /puestos/listadoPuestos/{clienteId}/{centroId}
GET /puestos/listadoPuestos/{clienteId}/{centroId}/basico
Response: código, nombre, personas/centro, personas/cliente
Repo: puestos-back ✅ (stack nuevo)
```

### 3.4 Tipo de centro (qué tipo de puestos maneja)
```
Lógica en: TrabajadoresEdicionController.getTipoCentroTrabajo(clienteId, centroId)
Devuelve: "C" (puestos de centro) / "E" (estándar) / "EC" (estándar particular cliente)
```

### 3.5 Motor de recálculo de protocolos (dry-run)
> Endpoint pendiente de pruebas en puestos-back. Preving lo entregará a Babooni una vez validado.
> Ejecuta la misma lógica que la creación del RM: protocolos por puesto + ACP (contrato/centro/puesto/trabajador) + periodicidad resultante.

### 3.6 Detección comunicación activa al laboratorio (CA-15)
```sql
SELECT COUNT(*) FROM VS_2007.EA_LAB_COM
WHERE TIPO = 'R' AND ITEM_ID = :rmId AND ANULADO IS NULL
```
Si COUNT > 0 → hay comunicación activa. **¿Bloqueante o informativo? Pendiente de decisión de negocio (ver sección 5).**

### 3.7 Endpoints laboratorio (planning-vs)
```
POST /configuracionRM/marcarComunicacionRM.do    — marcar RM para comunicar
PUT  /configuracionRM/{rmId}/anularComunicacionRM.do  — anular comunicación
```

### 3.8 Datos de la RL activa del trabajador
```
GET /rm/get-datos-rl/{trabajadorId}/{centroId}/{clienteId}
Repo: rrmm-backend ✅
```

---

## 4. Nuevos endpoints a implementar

### 4.1 puestos-back — Cambiar puesto de una relación laboral concreta

**Endpoint nuevo:**
```
POST /puestos/{rlId}/cambiar-puesto
Body: { clienteId, centroId, puestoNuevoId, estandar }
Header: Authorization: Bearer {jwt}
Response: { newRlId: number }
```

**Patrón de implementación:** idéntico a `moverTrabajadores` (PuestoManager.java:445).
Los métodos del DAO ya existen — solo hay que crear el endpoint y orquestador.

**Flujo:**
1. `puestoTrabajoBaja(rlId, trabajadorId, userId, fechaAlta)` → FCH_BAJA en PPT_CEN_TRA
2. `puestoTrabajoAlta(rlId, trabajadorId, rlId, centroId, puestoNuevoId, estandar, userId)` → retorna `newRlId`
3. Para cada registro activo en PPT_CEN_TRA_ADICIONAL del `rlId`:
   - `puestoTrabajoBaja(adicId, null, userId, fechaAlta)`
   - `puestoTrabajoAlta(adicId, null, newRlId, centroId, null, estandar, userId)`

**Métodos DAO reutilizables (PuestoDaoImpl.java):**
- `puestoTrabajoAlta()` — INSERT SELECT desde el registro anterior
- `puestoTrabajoBaja()` — UPDATE FCH_BAJA
- `getPuestosAdicionalesBatch()` — SELECT adicionales activos por rlId

---

### 4.2 rrmm-backend — Cambiar puesto de un reconocimiento médico

**Endpoint nuevo:**
```
PUT /rrmm/{rmId}/cambiar-puesto
Body: {
  clienteId:   number,
  centroId:    number,
  puestoId:    number,
  tipoPuesto:  string,   // "C" | "E" | "EC"
  estandar:    number    // 0=Centro, 1=Estándar
}
Header: Authorization: Bearer {jwt}
```

**Validaciones previas antes de ejecutar:**
1. RM en estado Pendiente (ESTADO_ID = 8 en INF4_RM_LOG)
2. Usuario tiene permiso ACL `CAMBIAR_PUESTO_RM` (nuevo, ver sección 5)
3. Centro destino tiene VS (PVS) contratada
4. Trabajador tiene RL activa en centro destino (`PPT_CEN_TRA.FCH_BAJA IS NULL`)
5. Centro destino no está en Versión 1

**SQL UPDATE sobre INF_RM:**
```sql
UPDATE vig_salud.inf_rm SET
  rm_ptr_id             = :puestoId,
  inf_ptr_tipo          = :tipoPuesto,        -- 'C'=centro / 'E'=estándar
  rm_cli_id             = :clienteId,
  rm_cen_id             = :centroId,
  rm_fch_edicion        = sysdate,
  rm_editor_id          = :userId,
  FCH_SEG_CONTABILIZADO = null,               -- si estaba contabilizado
  RM_ENVIADO            = 'N',                -- si estaba enviado a lab
  ENVIO_ID              = null,               -- si estaba enviado a lab
  rm_movido             = :clienteAnteriorNombre||';'||:centroAnteriorNombre,
  RM_CF_ANIO_ID         = :nuevoAnioId,       -- si cambia cliente (null si no aplica)
  MT_VALIDA             = :nuevoMtId,         -- si cambia SPA
  MC_ID                 = :nuevoMcId,         -- si cambia cliente
  RM_NOMBRE_PTO_INTEGRACION = null            -- si no es puesto de integración
WHERE rm_id = :rmId
```

**Efectos colaterales dentro de la misma transacción:**
- Actualizar analíticas asociadas si las hay (cliente/centro)
- `insertLogRm()` si cambia cliente
- Posible generación de edición si el RM está validado (`validacionRMS`)
- Recálculo año facturación si cambia cliente

**Post-transacción (no bloquea el commit):**
- `reasignarRMCita()` si cambia centro

**Orquestación RL (rrmm-backend llama a puestos-back):**
```
1. Resolver rlId: SELECT id FROM ppt_cen_tra
                  WHERE trabajador_id=:traId AND n_cen=:cenId AND cod_cli=:cliId
                  AND fch_baja IS NULL
2. Según escenario (ver sección 4.3):
   a. RL en destino ya existe → POST /puestos/{rlId}/cambiar-puesto
   b. No existe RL en destino → crear RL nueva (alta desde cero)
   c. No resoluble → bloquear, no aplicar cambios parciales
3. Escribir log CA-17 → INF4_RM_LOG_CAMBIO_PUESTO
```

---

### 4.3 Escenarios de relación laboral (reglas de negocio)

| Escenario | Comportamiento | Condición |
|-----------|---------------|-----------|
| Mismo cliente/centro, cambia puesto (RL existente) | Editar RL existente: baja+alta en PPT_CEN_TRA | No crear nueva RL |
| Añadir/eliminar/modificar puestos adicionales en misma RL | Editar RL existente | No duplicar RL |
| Cambia centro, mismo cliente, sin RL en destino | Crear nueva RL para ese cliente+centro | Solo al confirmar |
| Cambia cliente/centro/puesto, sin RL en destino | Crear nueva RL | Quedar trazado como origen "cambio puesto RM" |
| Trabajador con 2+ RL, destino con RL ya existente | Actualizar/asociar RL de destino | No crear duplicado |
| RM creado desde RL origen, usuario cambia a RL existente | Asociar reconocimiento a RL destino, actualizar si procede | RL origen no se toca salvo que sea la misma |
| No puede resolverse de forma segura | **Bloquear confirmación**, mostrar mensaje funcional | No aplicar cambios parciales |

---

### 4.4 rrmm-backend — Consulta de log de cambio de puesto

```
GET /logs/cambio-puesto?idReconocimiento={rmId}
Response: List<CambioPuestoLog>
```

---

## 5. Nueva tabla de trazabilidad (CA-17)

`INF4_RM_LOG` (tabla existente) solo tiene 3 columnas (RM_ID, ESTADO_ID, CREADO) y no puede acoger los campos requeridos por CA-17. **Se necesita una tabla nueva:**

```sql
CREATE TABLE VIG_SALUD.INF4_RM_LOG_CAMBIO_PUESTO (
    ID                      NUMBER(10)    PRIMARY KEY,
    RM_ID                   NUMBER(10)    NOT NULL,    -- → INF_RM.RM_ID
    USUARIO_ID              NUMBER(10)    NOT NULL,
    FECHA_CAMBIO            DATE          NOT NULL,
    ORIGEN_ACCION           VARCHAR2(30),              -- 'RECONOCIMIENTO' / 'HISTORIAL_MEDICO'
    -- Origen
    ORIGEN_CLI_ID           NUMBER(10),
    ORIGEN_CEN_ID           NUMBER(10),
    ORIGEN_PUESTO_ID        NUMBER(10),
    ORIGEN_TIPO_PUESTO      VARCHAR2(5),               -- 'C' / 'E' / 'EC'
    -- Destino
    DESTINO_CLI_ID          NUMBER(10),
    DESTINO_CEN_ID          NUMBER(10),
    DESTINO_PUESTO_ID       NUMBER(10),
    DESTINO_TIPO_PUESTO     VARCHAR2(5),
    -- Impacto en protocolos
    PROTOCOLOS_ANADIDOS     CLOB,                      -- JSON array de IDs/nombres
    PROTOCOLOS_ELIMINADOS   CLOB,                      -- JSON array de IDs/nombres
    -- Relación laboral
    RL_AFECTADA_ID          NUMBER(10),                -- PPT_CEN_TRA.ID
    RL_ACCION               VARCHAR2(20)               -- 'EDITADA' / 'CREADA' / 'ASOCIADA'
);
```

Esta tabla se escribe **dentro de la transacción de confirmación** en rrmm-backend.

---

## 6. Control de acceso — nuevo ACL

El sistema de permisos de rrmm-backend usa un ACL propio en `Security.java` (no `@PreAuthorize`). Cada acción tiene un objeto `RolAcl` con listas de userId y groupId autorizados.

**Acción análoga más cercana:** `GUARDAR_DATOS_ENVIO` — controla quién puede guardar datos de un RM pendiente.

**Babooni debe crear una nueva constante:**

```java
RolAcl CAMBIAR_PUESTO_RM = new RolAcl("CAMBIAR_PUESTO_RM", usuarios, grupos);
```

Donde `usuarios` y `grupos` serán definidos por negocio de Preving (ver sección 7).

**Grupos (roles) existentes relevantes:**

| Group ID | Descripción |
|----------|-------------|
| `+31225` | ROL_VALIDADOR — médico validador |
| `+31700` / `+31725` | Healthcare Org — gestión médicos |
| `+31960` | Healthcare Org — médico validador |

---

## 7. Pendientes de decisión de negocio

| # | Pregunta | Impacto |
|---|----------|---------|
| **N1** | CA-15 — ¿El aviso de comunicación activa al laboratorio es **bloqueante** o **informativo**? El documento funcional v.6 sección 7.7 lo deja explícitamente como "Pendiente de decisión". | Determina si el modal permite o bloquea el botón "Continuar" cuando hay comunicación activa. |
| **N3** | ¿Existen reglas de compatibilidad entre puesto adicional y puesto principal? ¿Puede cualquier puesto ser adicional de cualquier otro? | Validación en el modal al añadir adicionales. |
| **N4** | ¿Qué perfiles exactos mapean a qué group IDs JWT para el nuevo ACL `CAMBIAR_PUESTO_RM`? — Personal sanitario / Personal administrativo autorizado / Rol administrador. ¿La visibilidad del icono y la capacidad de confirmar usan el mismo ACL o dos distintos? | Babooni necesita estos valores para implementar `Security.java`. |

---

## 8. Comportamiento CA-16 — sin cambios en historial médico

> **El flujo de cambio de puesto desde Historial Médico de la ficha del trabajador NO se modifica.**

Cuando el cambio se inicia desde Historial Médico (`cambiarRl.do` y `cambiarRm.do` legacy):
- No se activa el nuevo modal UX/UI
- No se muestra la ventana resumen de impacto
- No se actualiza automáticamente la RL con el nuevo circuito
- El comportamiento es exactamente el actual

El nuevo circuito (modal + resumen + recálculo + RL automática) **solo se activa** cuando la acción parte de la ficha del reconocimiento pendiente en MINERVA.

---

## 9. Reglas de negocio clave (resumen)

- El nuevo circuito solo funciona con reconocimientos en **estado Pendiente**.
- El botón "Continuar" **no aplica cambios** — solo calcula el impacto y abre la ventana resumen.
- **"Confirmar cambios"** es el único botón que ejecuta la modificación.
- Las pruebas ya realizadas y resultados registrados **no se eliminan** aunque el protocolo deje de aplicar.
- La ventana resumen muestra **solo los bloques con cambios** (no fotografía completa del RM).
- La nota fija en la ventana resumen: *"Las pruebas ya cumplimentadas se mantienen en el reconocimiento."*
- La actualización de la RL se resuelve automáticamente — el usuario no selecciona manualmente la RL.
- Si la RL no puede resolverse de forma segura → **bloquear sin aplicar cambios parciales**.

---

## 10. Criterios de aceptación (referencia)

| ID | Criterio | Tipo | Prioridad |
|----|----------|------|-----------|
| CA-01 | RM pendiente + usuario autorizado → icono visible junto al puesto | Funcional | Alta |
| CA-02 | RM finalizado/validado → no se permite nuevo circuito | Funcional | Crítica |
| CA-11 | Pulsar Continuar → no se aplican cambios, se muestra resumen | Funcional | Crítica |
| CA-12 | Cancelar en resumen → no se modifica nada | Funcional | Alta |
| CA-13 | Confirmar → resumen actualizado + RL actualizada + log | Funcional | Crítica |
| CA-14 | Pruebas ya realizadas se mantienen aunque el protocolo deje de aplicar | Seguridad clínica | Crítica |
| CA-15 | RM comunicado a lab → alerta obligatoria | Funcional | Alta |
| CA-16 | Cambio desde Historial Médico → comportamiento actual sin cambios | Regresión | Crítica |
| CA-17 | Log registra: usuario, fecha, origen, destino, protocolos +/-, RL afectada | Trazabilidad | Alta |
