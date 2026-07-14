# Diseño técnico — BE-07: Aplicar cambio de puesto (materialización `INF3_*`)

**Proyecto:** MINERVA — Cambio de puesto en reconocimiento médico (RF v.6)
**Tarea:** BE-07 (Sprint 2) — Endpoint aplicar cambio, parte de materialización de protocolos
**Repos:** `rrmm-backend` (orquestación CONFIRMAR), `rrmm-utils` (motor de materialización), `puestos-back` (sin cambios en esta tarea)
**Fecha:** 24/06/2026
**Estado:** Propuesta de diseño — pendiente de aprobación antes de implementar

---

## 1. Objetivo

Completar el flujo `CONFIRMAR` del cambio de puesto para que, además de mutar la relación laboral, `INF_RM` y los puestos adicionales (ya implementado), **materialice de forma transaccional la nueva configuración de protocolos y dependientes** (`INF3_RM_PROTOCOLOS`, `INF3_RM_PRUEBAS`, `INF3_RM_PARAMETROS`, `INF3_RM_PERFILES`, `INF3_RM_CUESTIONARIOS`, `INF3_RM_IPROMES`, etc.) en el reconocimiento pendiente, **respetando las pruebas/resultados ya cumplimentados (CA-14)** y actualizando periodicidad/fecha recomendada (RF §7.5).

Sin esta pieza, tras `CONFIRMAR` el reconocimiento queda con los protocolos del puesto **anterior**, desincronizado respecto al preview que vio el usuario en la ventana resumen (CA-13).

---

## 2. Contexto y restricciones de diseño

### 2.1. Decisión arquitectónica

El motor que sabe materializar `INF3_*` "igual que la creación del reconocimiento" (RF §7.2) **ya existe en `rrmm-utils`**: `ConfiguracionProtocolosReconocimientoServiceImpl.cargarConfiguracionProtocolosReconocimiento(rmId, …)`. Ese método **no crea** el `INF_RM`; solo inserta los `INF3_*` para un `rmId` existente (en el alta, el `INF_RM` se crea antes, por separado).

> **Decisión:** la materialización se ejecuta en `rrmm-utils` reutilizando esa lógica. **NO** se porta la maquinaria de inserción a `rrmm-backend` (evita duplicar decenas de `INSERT ... SELECT` nativos y el riesgo de divergencia con el alta).

### 2.2. Restricción innegociable

**No modificar métodos ya existentes** de `rrmm-utils` (rama `feature/20260424_migracion_alta_reconocimiento`). Todo lo nuevo es **código nuevo** que **reutiliza** lo existente:

- Endpoint nuevo, método de servicio nuevo, métodos DAO nuevos (limpieza + CA-14).
- `cargarConfiguracionProtocolosReconocimiento` y los `insertar*PorConfigsIds` / `insertar*ProtocolosPorReconocimiento` se invocan **intactos**.

### 2.3. Hechos verificados en código que condicionan el diseño

1. Los `insertar*` son `INSERT ... SELECT` **puros, sin guard anti-duplicado** contra `INF3_RM_*`, y con **dependencias de orden interno** (p. ej. la rama de pruebas por plantilla joinea `INF3_RM_PROTOCOLOS` por `:rmId`). → **No** se puede "borrar parcial + reinvocar": duplicaría lo conservado y rompería el orden. Hay que ir a **rebuild completo** sobre RM vacío.
2. `INF3_RM_PRUEBAS` tiene columna `BORRADO` (soft-delete) y `MANUAL`.
3. Los **resultados** viven en `INF2_RM_VALORES`, con clave funcional **`RM_ID + PRUEBA_CODIGO`** (no por `inf3_rm_pruebas.ID`). El enlace de código es `INF3_PRUEBAS.CODIGO_PRUEBA`.
4. **Anular** una prueba no la borra: inserta en `INF_PRUEBAS_ANULADAS` (reversible vía `REACTIVADA`).

> **Corolario CA-14:** mientras **no se toquen** `INF2_RM_VALORES` ni `INF_PRUEBAS_ANULADAS`, los resultados y anulaciones **sobreviven** a un rebuild de `INF3_RM_*`.

---

## 3. Estrategia: rebuild con preservación CA-14

Operación nueva en `rrmm-utils`, transaccional, sobre un `rmId` pendiente:

1. **Capturar conjunto protegido (CA-14):** pruebas del RM con resultados (ver §6 para la definición de "prueba realizada"). Se guardan sus `PRUEBA_ID` + `CODIGO_PRUEBA` + metadatos mínimos.
2. **Limpiar SOLO las tablas de configuración `INF3_RM_*`** del `rmId` (lista exacta en §6.1): `INF3_RM_PROTOCOLOS`, `INF3_RM_PRUEBAS`, `INF3_RM_PERFILES`, `INF3_RM_PARAMETROS`, `INF3_RM_CUESTIONARIOS`, `INF3_RM_IPROMES`, `INF3_RM_ANEXOS`, `INF3_RM_PRODUCTOS_QUIMICOS`. **Nunca** se tocan las tablas de resultado ni de anulaciones (§6.2) — esto garantiza CA-14 a nivel de datos por construcción.
3. **Regenerar:** invocar `cargarConfiguracionProtocolosReconocimiento(rmId, cmd, …)` con el puesto principal + adicionales del destino → reinserta toda la config nueva de forma consistente y ordenada (idéntico al alta).
4. **Re-incorporar protegidas (CA-14):** las pruebas realizadas que la nueva config **ya no** incluya se reinsertan en `INF3_RM_PRUEBAS` como `MANUAL=1` (origen "conservación"), para que sigan visibles. Sus valores en `INF2_RM_VALORES` re-enlazan solos por `RM_ID + CODIGO_PRUEBA`.
5. **Periodicidad / fecha recomendada:** recalcular con la misma lógica que el alta (gate por configuración de periodicidad del cliente) y actualizar en `INF_RM` (RF §7.5).

Todo dentro de **una transacción** en `rrmm-utils`.

---

## 4. Contrato del nuevo endpoint (`rrmm-utils`)

Nuevo método en `ProtocolosReconocimientoController` (mismo controlador, **método nuevo**; no se toca `/recalcular`):

```
POST /rrmm/protocolos/aplicar
Authorization: Bearer <jwt>
Content-Type: application/json
```

**Request** (DTO nuevo, p. ej. `AplicarProtocolosRequest`, espejo de `RecalcularProtocolosRequest`):

```json
{
  "rmId": 12341907,
  "puestoId": 116267,
  "tipoPuesto": 0,
  "puestosAdicionales": [ { "puestoId": 998877, "estandar": true } ],
  "usuarioVigId": 4521
}
```

**Response** (DTO nuevo, p. ej. `AplicarProtocolosResponse`):

```json
{
  "rmId": 12341907,
  "protocolosResultantes": 7,
  "pruebasResultantes": 53,
  "pruebasConservadasCa14": 2,
  "periodicidadId": 12,
  "periodicidadMeses": 12,
  "fechaRecomendada": "2027-06-24"
}
```

**Códigos:** `200` OK · `400` parámetros · `401` no autenticado · `404` RM no encontrado · `409` RM no pendiente.

> El cuerpo de la respuesta alimenta el log CA-17 y permite a `rrmm-backend` confirmar contadores.

---

## 5. Clases nuevas (sin tocar las existentes)

### 5.1. `rrmm-utils`

| Tipo | Clase nueva | Responsabilidad |
|------|-------------|-----------------|
| Controller (método) | `ProtocolosReconocimientoController#aplicarConfiguracionProtocolos` | Nuevo `@PostMapping("/aplicar")` |
| DTO | `AplicarProtocolosRequest` / `AplicarProtocolosResponse` | Contrato del endpoint |
| Service | `AplicarProtocolosReconocimientoService` (+ `Impl`) **o** método nuevo en el service existente **sin modificar los actuales** | Orquesta rebuild + CA-14 + periodicidad (transaccional) |
| DAO | `ReconciliacionProtocolosDao` (+ `Impl`) | `limpiarInf3RmByRmId(rmId)`, `getPruebasRealizadasByRmId(rmId)`, `reinsertarPruebaConservada(...)` |

> Se **reutilizan** `ConfiguracionProtocolosReconocimientoService.cargarConfiguracionProtocolosReconocimiento`, `obtenerPeriodicidadProtocolos`, y los DAO de alta existentes (solo lectura/invocación).

### 5.2. `rrmm-backend`

| Tipo | Clase | Cambio |
|------|-------|--------|
| Client | `RrmmUtilsClient` / `RrmmUtilsClientImpl` | **Nuevo** método `aplicarConfiguracionProtocolos(req, jwt)` (análogo a `recalcularConfiguracionProtocolos`) |
| Mapper | `CambioPuestoRrmmUtilsRequestMapper` | **Nuevo** método para construir `AplicarProtocolosRequest` (o clase nueva) |
| Service | `CambioPuestoServiceImpl#confirmar` | Insertar la llamada al applier en la secuencia (§7) |
| Config | `application.yml` | Reusa `api-rrmm-utils.url`; flag opcional `cambio-puesto.aplicar.enabled` para rollout |

---

## 6. Mapa de tablas y definición de "prueba realizada" (CA-14)

Mapa autoritativo extraído de la rutina de borrado integral del RM (`ReconocimientoDaoImpl`, métodos `borrar*`), que es el inventario completo de tablas asociadas a un `rmId`.

### 6.1. Tablas de CONFIGURACIÓN (las que regenera `cargarConfiguracion`; el rebuild las limpia)

| Tabla | Clave |
|-------|-------|
| `INF3_RM_PROTOCOLOS` | `RM_ID` |
| `INF3_RM_PRUEBAS` | `RM_ID` |
| `INF3_RM_PERFILES` | `RM_ID` |
| `INF3_RM_PARAMETROS` | `RM_ID` |
| `INF3_RM_CUESTIONARIOS` | `RM_ID` |
| `INF3_RM_IPROMES` | `RM_ID` |
| `INF3_RM_ANEXOS` | `RM_ID` |
| `INF3_RM_PRODUCTOS_QUIMICOS` | `RM_ID` |

### 6.2. Tablas de RESULTADO / contenido cumplimentado (CA-14: NUNCA se tocan)

Estas tablas contienen los datos clínicos registrados y son las que se consultan para decidir si una prueba está "realizada". El rebuild **no las modifica jamás**.

| Tabla | Clave RM | Contenido |
|-------|----------|-----------|
| `INF2_RM_VALORES` | `RM_ID` + `PRUEBA_CODIGO` | Formularios estructurados, exploraciones, anamnesis, hábitos, control visión |
| `INF_RESULTADOS` | `RES_RM_ID` | Resultados genéricos de pruebas |
| `INF_ESTUDIOS_ANALITICOS` | `RM_ID` + `PERFIL_ID` | Analítica / perfiles (`ESTADO_ID`, `CHECKED`, `BORRADO`) |
| `CUES_RM_VALORES` (+ `INF3_CUESTIONARIOS_EXTERNO.FECHA_CUMPLIMENTACION`) | `RM_ID`/`CUES_EXTERNO_ID` + `CUES_CODIGO` | Respuestas y cumplimentación de cuestionarios |
| `INF_AGUDEZAVISUAL` | `AGV_RM_ID` | Agudeza visual |
| `INF_AUDIOMETRIA` | `AUD_RM_ID` | Audiometría |
| `INF_ESPIROMETRIA` (+ `INF3_ESPIROMETRIA_POST`) | `ESP_RM_ID`/`RM_ID` | Espirometría |
| `INF_ELECTRO` | `ELE_RM_ID` | Electrocardiograma |
| `INF_EXPLORACION` | `EXP_RM_ID` | Exploración |
| `INF3_IRC` | `RM_ID` | IRC |
| `INF_ANAMNESIS` | `ANA_RM_ID` | Anamnesis |
| `INF_HABITOS` | `HAB_RM_ID` | Hábitos |
| `INF_COMPLEMENTARIAS` | `COMP_RM_ID` | Complementarias |
| `INF_BIOIMPEDANCIA_ELECTRICA` | `BIO_RM_ID` | Bioimpedancia |
| `INF3_RUFFIER` | `RM_ID` | Ruffier |
| `INF2_ANT_LABORALES` | `RM_ID` | Antecedentes laborales |
| `INF2_OTRAS_EXP` | `RM_ID` | Otras exploraciones |
| `INF2_RM_RECOMENDACIONES_VLR` | `RM_ID` | Recomendaciones |
| `INF_APTITUD_LABORAL` | `APL_RM_ID` | Valoración/aptitud (fuera de alcance modificar) |
| `INF_CONCLUSIONES` | `CON_RM_ID` | Conclusiones |

### 6.3. Tablas de ANULACIÓN (NUNCA se tocan)

`INF_PRUEBAS_ANULADAS`, `INF_CUESTIONARIO_ANULADOS`.

### 6.4. Conclusión sobre CA-14 (refinada)

> **Como el rebuild limpia EXCLUSIVAMENTE las tablas de configuración `INF3_RM_*` (§6.1) y NUNCA las de resultado (§6.2), los resultados clínicos no se pierden bajo ninguna circunstancia.** El cálculo de "prueba realizada" no protege datos (que ya están a salvo por construcción), sino que decide únicamente la **visibilidad**: re-añadir la fila de config en `INF3_RM_PRUEBAS` para una prueba que tenga resultados pero que la nueva configuración ya no incluya, de modo que siga apareciendo en el reconocimiento.

### 6.5. Detección de "prueba realizada" (para la re-incorporación de visibilidad)

Una prueba configurada se considera realizada si tiene contenido en cualquiera de sus almacenes de resultado. Detección principal (cubre el grueso de tipos):

```sql
SELECT DISTINCT ip.PRUEBA_ID, ip.CODIGO_PRUEBA
FROM   VIG_SALUD.INF3_RM_PRUEBAS irp
JOIN   VIG_SALUD.INF3_PRUEBAS ip ON irp.PRUEBA_ID = ip.ID
WHERE  irp.RM_ID = :rmId
  AND  irp.BORRADO IS NULL
  AND  ( EXISTS (SELECT 1 FROM VIG_SALUD.INF2_RM_VALORES v
                 WHERE v.RM_ID = :rmId AND v.PRUEBA_CODIGO LIKE ip.CODIGO_PRUEBA || '%')
      OR EXISTS (SELECT 1 FROM VIG_SALUD.INF_RESULTADOS r
                 WHERE r.RES_RM_ID = :rmId AND r.PRUEBA_ID = ip.PRUEBA_ID) )
```

Para tipos con tabla propia (audiometría, espirometría, electro, exploración, agudeza visual, IRC, bioimpedancia, Ruffier), se añade un `EXISTS` por tabla mapeando el `CODIGO_PRUEBA`/`PRUEBA_ID` al `*_RM_ID` correspondiente. La analítica (parámetros/perfiles) se protege vía `INF_ESTUDIOS_ANALITICOS` (perfil con `ESTADO_ID`/valores) y los cuestionarios vía `CUES_RM_VALORES`/`FECHA_CUMPLIMENTACION`.

> **Criterio conservador:** la detección solo gobierna visibilidad; aunque fuera incompleta, **ningún dato se pierde** (§6.4). Aun así, ante duda se conserva la prueba. La verificación final del mapeo por tipo se cierra en pruebas DEMO con un RM que tenga resultados de cada tipo (§8.3).

---

## 7. Secuencia en `CONFIRMAR` (`rrmm-backend`)

Orden propuesto dentro de `@Transactional` de `confirmar()`:

1. Validaciones V01–V05 + RM pendiente + destino PVS (ya existe).
2. Resolver escenario RL (`CambioPuestoRlOrchestrator`) — si `BLOQUEAR` → `409` (ya existe).
3. Resolver editor (`jwtService`) (ya existe).
4. Calcular delta de protocolos para el log (preview vía resolver) (ya existe).
5. **`rlExecutor.ejecutar(...)`** — mutación RL (ya existe).
6. **`actualizarInfRm(...)`** — UPDATE `INF_RM` puesto/tipo/cli/cen (ya existe).
7. **`replacePuestosAdicionalesRm(...)`** — `INF_RM_PTOS_ADICIONALES` (ya existe).
8. **🆕 `rrmmUtilsClient.aplicarConfiguracionProtocolos(...)`** — materializa `INF3_*` (rebuild + CA-14 + periodicidad).
9. **`registrarLogCambioPuesto(...)`** — log CA-17, ahora con contadores reales del paso 8 (ya existe, se enriquece).
10. Respuesta `CambioPuestoConfirmarResponse` con `warnings` (BE-11, fuera de BE-07).

### 7.1. Atomicidad entre repos — DECISIÓN: applier idempotente

El paso 8 es una llamada HTTP a `rrmm-utils` con **su propia transacción**. Los pasos 5–7 (locales en `rrmm-backend`) y el 8 (remoto) **no comparten transacción distribuida**.

> **Decisión adoptada:** el applier de `rrmm-utils` se diseña **idempotente** — reaplicarlo sobre el mismo `rmId` y mismo destino deja **exactamente el mismo estado** (el rebuild parte siempre de limpiar `INF3_RM_*` y regenerar). Esto convierte el paso 8 en una operación **segura de reintentar** y elimina la necesidad de transacción distribuida o de un endpoint de compensación dedicado.

**Implicaciones de diseño derivadas de la idempotencia:**

1. **Orden:** local primero (pasos 5–7: RL + `INF_RM` + adicionales) y remoto al final (paso 8). El paso 8 lee el estado destino ya consolidado en `INF_RM`/adicionales, lo que mantiene una única fuente de verdad del "qué aplicar".
2. **Fallo del paso 8 (remoto):** la transacción local de `rrmm-backend` hace **rollback** de los pasos 5–7 → no queda nada aplicado, se devuelve `502`/`409` y el usuario puede reintentar `CONFIRMAR` sin efectos colaterales (el applier es idempotente, no acumula).
3. **Fallo posterior al paso 8 (p. ej. paso 9 log):** dado que el applier es idempotente y el flujo se puede reintentar, un reintento completo de `CONFIRMAR` reaplica `INF3_*` al mismo estado y reescribe RL/`INF_RM`. No se generan duplicados ni estados intermedios divergentes.
4. **Garantía de idempotencia en el applier:** la limpieza total de `INF3_RM_*` antes de regenerar (§3, §6.1) es lo que asegura que N ejecuciones ≡ 1 ejecución. **No** debe introducirse ninguna inserción incremental que dependa del estado previo.

> Con esto, el punto de atomicidad queda cerrado: no se persigue atomicidad distribuida estricta, sino **consistencia eventual mediante reintento idempotente**, apoyada en el rollback local y en que las tablas de resultado (§6.2) nunca se tocan.

---

## 8. Plan de pruebas

### 8.1. Unitarias (`rrmm-utils`)

- `ReconciliacionProtocolosDao`: limpieza por `rmId` (no toca `INF2`/anuladas), detección de realizadas, reinserción conservada.
- Service applier: orden rebuild → cargarConfiguracion → re-incorporación CA-14 → periodicidad (mocks de DAO).

### 8.2. Unitarias (`rrmm-backend`)

- `RrmmUtilsClientImpl.aplicarConfiguracionProtocolos`: 200, 404, 409, 5xx, cuerpo vacío.
- `CambioPuestoServiceImpl.confirmar`: secuencia con applier mockeado; verificación de orden y manejo de error (según opción de §7.1).

### 8.3. Validación manual DEMO (datos del handoff)

`rmId=12341907`, cliente/centro `234783/598076`, puesto `116267`, RL `4782137`.

1. SIMULAR adicional Plomo → CONFIRMAR → releer `INF3_RM_PROTOCOLOS` y comprobar P1 Plomo presente.
2. Cumplimentar una prueba (escribir en `INF2_RM_VALORES`) → cambiar a puesto que **no** la incluya → CONFIRMAR → la prueba debe **seguir visible** y sus valores intactos (**CA-14**).
3. Verificar periodicidad/fecha recomendada actualizadas en escenario `EDITAR`.
4. GET logs cambio-puesto (CA-17) con contadores reales.

---

## 9. Fuera de alcance de BE-07 (otras tareas)

- **BE-10** ACL `CAMBIAR_PUESTO_RM` / concurrencia.
- **BE-11** warnings CA-15 (laboratorio comunicado) / CU-11 en la respuesta CONFIRMAR.
- **BE-09** verificación del DDL `INF4_RM_LOG_CAMBIO_PUESTO` en DEMO.
- Colaterales legacy (MT/MC, reasignar cita) si negocio los exige; evaluar aparte.

---

## 10. Riesgos y mitigaciones

| Riesgo | Mitigación |
|--------|------------|
| Incoherencia entre `INF_RM` (local) e `INF3_*` (remoto) por fallo parcial | **Applier idempotente** + rollback local + reintento (§7.1); las tablas de resultado nunca se tocan (§6.4) |
| Definición incompleta de "prueba realizada" | Solo afecta a **visibilidad**, no a datos (§6.4); criterio conservador (ante duda, conservar); cierre en DEMO (§8.3) |
| `cargarConfiguracion` asume RM vacío | Limpieza total de las tablas de config `INF3_RM_*` (§6.1) antes de invocarla; garantiza también la idempotencia |
| Regresión en el alta por reutilización | No se modifica ningún método existente; solo se invoca |
| Reaplicaciones acumulan filas | El applier limpia `INF3_RM_*` antes de regenerar → N ejecuciones ≡ 1 (§7.1) |

---

## 11. Resumen ejecutivo

BE-07 se cierra materializando `INF3_*` en `rrmm-utils` mediante un **endpoint nuevo `/aplicar`** que reutiliza, **sin modificarla**, la lógica de carga del alta, con una estrategia de **rebuild idempotente + preservación CA-14**. El rebuild limpia exclusivamente las tablas de configuración `INF3_RM_*` (§6.1) y **nunca** las de resultado (§6.2), por lo que **ningún dato clínico se pierde por construcción**; la detección de "prueba realizada" solo gobierna la visibilidad de la prueba (§6.4–6.5). `rrmm-backend.confirmar()` invoca el endpoint al final de su flujo (local primero, remoto al final), y la **idempotencia** del applier garantiza consistencia mediante rollback local + reintento, sin transacción distribuida (§7.1).

**Decisiones cerradas:** (1) atomicidad → applier idempotente; (2) tablas de resultado enumeradas (§6.2). Fleco menor: confirmar en DEMO el mapeo por tipo de los `EXISTS` de detección (§6.5/§8.3).
