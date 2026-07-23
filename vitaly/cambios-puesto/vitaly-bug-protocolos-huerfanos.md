# Bug: Protocolos huérfanos en el motor de ALTA (BUG-02)

## Descripción

En el flujo de **alta de reconocimiento**, la lógica de inserción de protocolos es asimétrica:

- `INF3_RM_PROTOCOLOS` solo se inserta cuando el puesto tiene **configuración propia** (`tieneConfiguracionProtocolos = true`).
- `INF3_RM_PRUEBAS`, `INF3_RM_CUESTIONARIOS`, etc. se insertan también cuando hay **protocolos de cliente** (`protocolosCliente` no vacío), aunque el puesto no tenga configuración propia.

## Escenario que lo reproduce

Puesto de **centro** sin configuración propia pero con protocolos de cliente asignados:

| Tabla | Resultado |
|-------|-----------|
| `INF3_RM_PRUEBAS` | Filas insertadas con `PROTOCOLO_ID` apuntando al protocolo de cliente |
| `INF3_RM_PROTOCOLOS` | **Sin fila** para ese protocolo |

→ Las pruebas quedan **huérfanas**: referencias a un `PROTOCOLO_ID` que no existe en `INF3_RM_PROTOCOLOS`.

---

## Fix definitivo pendiente (Service — BUG-02)

En `ConfiguracionProtocolosReconocimientoServiceImpl.insertarProtocolosParaReconocimientoByTipoYConfigsIds`, alinear la condición de inserción de `INF3_RM_PROTOCOLOS` con la de `INF3_RM_PRUEBAS`:

```java
// ACTUAL (asimétrico — sigue en origin/master tras jul-2026)
if (tieneConfiguracionProtocolos) {
    insertarProtocolos(...);
}
if (tieneConfiguracionProtocolos || !protocolosCliente.isEmpty()) {
    insertarPruebas(...);
    ...
}

// OBJETIVO (simétrico)
if (tieneConfiguracionProtocolos || !protocolosCliente.isEmpty()) {
    insertarProtocolos(...);
}
if (tieneConfiguracionProtocolos || !protocolosCliente.isEmpty()) {
    insertarPruebas(...);
    ...
}
```

---

## Fix parcial en master (jul-2026) — MR !53

**Merge:** `fab5892c` — rama `fix/pruebas-sin-protocoloId` → `master` (22-jul-2026).

**Qué corrige:** queries en `ConfiguracionProtocolosDaoImpl` que asignaban **`protocolo_id` erróneo** a pruebas:

1. Excluye pruebas sueltas de configuración si ya pertenecen a un protocolo configurado para el cliente.
2. Elimina un `UNION` (`CONF_PRUEBAS` × `PRO_PROTOCOLOS_PRUEBAS` sin filtrar) que duplicaba filas y enlazaba pruebas a protocolos no configurados.

**Qué NO corrige:** la asimetría del **Service** anterior (protocolos vs pruebas cuando solo hay `protocolosCliente`). Por eso **siguen siendo necesarios** los workarounds de reconciliación.

---

## Workarounds actuales (cambio de puesto)

| Componente | Ubicación | Rol |
|------------|-----------|-----|
| `repararProtocolosHuerfanos` | rrmm-utils `/aplicar` | Inserta en `INF3_RM_PROTOCOLOS` los protocolos referenciados por pruebas sin fila padre |
| `incorporarProtocolosHuerfanosPreview` | rrmm-utils `/recalcular` | Espejo en memoria del anterior para el preview P1 |
| `CambioPuestoProtocolosMaterializablesAdjuster` | rrmm-backend SIMULAR/CONFIRMAR | Sustituye protocolos del preview UNION por los materializables (rama exclusiva del INSERT); huérfanos vía `protocoloId` de cada prueba del P1 |

**Decisión (jul-2026):** no retirar workarounds hasta que tecnología aplique el fix simétrico en el Service del alta.

---

## Validación funcional — RM 12359284

Cliente `690067` / centro `590340`. Puestos: `957146` (P3, SPM-01) ↔ `957137` (P18, P5 plantilla).

| Paso | Resultado |
|------|-----------|
| SIMULAR 957146 → 957137 | Adjuster `3 ids=[21,67,106]`; delta +P18,+P5 / −P3,−SPM-01 |
| CONFIRMAR → 957137 | `/aplicar` protocolos=4 (CA-14=1; P18 duplicado en BD — pre-merge) |
| Merge `origin/master` en `feature/Cambio-puesto-sprint-1` | MR !53 integrado |
| SIMULAR 957137 → 957146 | Adjuster `3 ids=[21,122,761]`; delta simétrico |
| CONFIRMAR → 957146 | `/aplicar` **protocolos=3**, CA-14=0, alineado con preview |

Tras MR !53, el segundo CONFIRMAR dejó **exactamente 3 protocolos** (P0 + P3 + SPM-01), sin 4.º ni duplicado P18.

### Resultados BD (22-jul-2026, post-vuelta a 957146)

| Query | Resultado | Estado |
|-------|-----------|--------|
| 1. Huérfanos globales | RM **12359284 no aparece**. Sí hay huérfanos en otros RMs (ej. **1004101168**, 16+ pruebas con `PROTOCOLO_ID=21` sin fila en `INF3_RM_PROTOCOLOS`) | OK para RM prueba; deuda histórica en otros RMs |
| 2. Protocolos materializados | 3 filas: P0 (`21`), P3 (`122`), SPM-01 (`761`) | OK |
| 3. Duplicados | 0 filas | OK |
| 4. Conteo | protocolos=**3**, pruebas=**66**, cuestionarios=**2**, parametros=**5** | OK |
| 5. Contexto `INF_RM` | `puesto_id=957146`, `cliente=690067`, `centro=590340`, periodicidad=**BIENAL** (5), `fecha_proximo=2028-07-21`, `ACP_ID=null` | OK |
| 6. CA-14 (`PROTOCOLO_ID IS NULL`) | 0 filas | OK (`conservadasCa14=0`) |

**Nota query 6:** filtrar solo `MANUAL=1` devuelve 18 pruebas del protocolo SPM-01 (`761`, `ORIGEN_ID=3`) — son pruebas **manuales de configuración**, no conservaciones CA-14. CA-14 reinserta con `MANUAL=1` y **`PROTOCOLO_ID IS NULL`** (`reinsertarPruebaConservada`).

---

## Verificación en base de datos

### 1. Huérfanos globales (debe quedar vacío tras `/aplicar` correcto)

```sql
SELECT p.RM_ID, p.PRUEBA_ID, p.PROTOCOLO_ID
FROM VIG_SALUD.INF3_RM_PRUEBAS p
WHERE p.BORRADO IS NULL
  AND p.PROTOCOLO_ID IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 FROM VIG_SALUD.INF3_RM_PROTOCOLOS pr
      WHERE pr.RM_ID = p.RM_ID
        AND pr.PROTOCOLO_ID = p.PROTOCOLO_ID
        AND pr.BORRADO IS NULL
  )
ORDER BY p.RM_ID DESC;
```

Filtro solo para el RM de prueba (esperado: **0 filas**):

```sql
-- ... misma query anterior ...
  AND p.RM_ID = 12359284
ORDER BY p.PRUEBA_ID;
```

Ejecutado 22-jul-2026: **12359284 limpio**; persisten huérfanos en otros RMs (ej. `1004101168`).

### 2. RM de prueba — protocolos materializados (esperado: 3 filas)

```sql
SELECT
    irp.ID              AS inf3_rm_protocolo_id,
    irp.PROTOCOLO_ID,
    pro.CODIGO          AS codigo,
    pro.DENOMINACION    AS denominacion,
    TRIM(pro.CODIGO || ' — ' || pro.DENOMINACION) AS etiqueta,
    irp.MANUAL,
    irp.ORIGEN_ID,
    irp.CREADO
FROM VIG_SALUD.INF3_RM_PROTOCOLOS irp
INNER JOIN VIG_SALUD.PRO_PROTOCOLOS pro ON pro.ID = irp.PROTOCOLO_ID
WHERE irp.RM_ID = 12359284
  AND irp.BORRADO IS NULL
ORDER BY pro.CODIGO, pro.DENOMINACION;
```

Esperado tras vuelta a **957146**: P0 (`21`), P3 (`122`), SPM-01 (`761`).

### 3. Duplicados por protocolo (debe quedar vacío)

```sql
SELECT
    irp.RM_ID,
    irp.PROTOCOLO_ID,
    pro.CODIGO,
    COUNT(*) AS num_filas
FROM VIG_SALUD.INF3_RM_PROTOCOLOS irp
INNER JOIN VIG_SALUD.PRO_PROTOCOLOS pro ON pro.ID = irp.PROTOCOLO_ID
WHERE irp.RM_ID = 12359284
  AND irp.BORRADO IS NULL
GROUP BY irp.RM_ID, irp.PROTOCOLO_ID, pro.CODIGO
HAVING COUNT(*) > 1;
```

### 4. Conteo rápido post-`/aplicar`

```sql
SELECT
    (SELECT COUNT(*) FROM VIG_SALUD.INF3_RM_PROTOCOLOS
     WHERE RM_ID = 12359284 AND BORRADO IS NULL) AS protocolos,
    (SELECT COUNT(*) FROM VIG_SALUD.INF3_RM_PRUEBAS
     WHERE RM_ID = 12359284 AND BORRADO IS NULL) AS pruebas,
    (SELECT COUNT(*) FROM VIG_SALUD.INF3_RM_CUESTIONARIOS
     WHERE RM_ID = 12359284 AND BORRADO IS NULL) AS cuestionarios,
    (SELECT COUNT(*) FROM VIG_SALUD.INF3_RM_PARAMETROS
     WHERE RM_ID = 12359284 AND BORRADO IS NULL) AS parametros
FROM DUAL;
```

Esperado (CONFIRMAR 957146, jul-2026): protocolos=**3**, pruebas=**66**, cuestionarios=**2**, parametros=**5**.

### 5. Contexto del RM

```sql
SELECT
    rm.RM_ID,
    rm.RM_PTR_ID              AS puesto_id,
    rm.INF_PTR_TIPO           AS tipo_puesto,
    rm.RM_CLI_ID              AS cliente_id,
    rm.RM_CEN_ID              AS centro_id,
    rm.PERIODICIDAD_ID,
    per.NOMBRE                AS periodicidad,
    rm.FECHA_PROXIMO_RECONOCIMIENTO,
    rm.ACP_ID
FROM VIG_SALUD.INF_RM rm
LEFT JOIN VIG_SALUD.INF_RM_PERIODICIDADES per ON per.ID = rm.PERIODICIDAD_ID
WHERE rm.RM_ID = 12359284;
```

Esperado: `puesto_id=957146`, `periodicidad=BIENAL` (id=5), `fecha_proximo=2028-07-21`.

### 6. CA-14 — pruebas reincorporadas por conservación (check verde)

Las pruebas conservadas por CA-14 se reinsertan con `MANUAL=1` y **`PROTOCOLO_ID IS NULL`** (sin protocolo padre). No confundir con pruebas `MANUAL=1` del catálogo SPM-01 (`ORIGEN_ID=3`, `PROTOCOLO_ID` informado).

```sql
SELECT
    irp.PRUEBA_ID,
    ip.CODIGO_PRUEBA,
    ip.NOMBRE,
    irp.PROTOCOLO_ID,
    irp.MANUAL,
    irp.ORIGEN_ID
FROM VIG_SALUD.INF3_RM_PRUEBAS irp
INNER JOIN VIG_SALUD.INF3_PRUEBAS ip ON ip.ID = irp.PRUEBA_ID
WHERE irp.RM_ID = 12359284
  AND irp.BORRADO IS NULL
  AND irp.MANUAL = 1
  AND irp.PROTOCOLO_ID IS NULL
ORDER BY irp.PRUEBA_ID;
```

Esperado tras último CONFIRMAR: **0 filas** (`conservadasCa14=0`).

---

## Notas

- El fix del Service afecta únicamente a la rama de **protocolos de cliente** (no RL/ESP).
- La rama RL/ESP no se ve afectada: los protocolos ESP se insertan mediante un flujo propio.
- Afecta principalmente a **puestos de centro** (sin configuración propia de protocolos).
- Pregunta abierta a tecnología: ¿MR !53 cierra BUG-02 por completo o solo la asignación incorrecta de `protocolo_id` en pruebas?
