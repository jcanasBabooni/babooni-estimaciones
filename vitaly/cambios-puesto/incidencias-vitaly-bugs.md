# Incidencias rrmm-utils — Motor de alta / protocolos

**Ámbito:** `rrmm-utils` — alta de reconocimiento, configuración de protocolos (`recalcular` / `aplicar`)  
**Responsable del fix:** Equipo Vitaly (motor de alta)  
**Última actualización:** Jul 2026 — BUG-01 reclasificado tras feedback Vitaly

---

## Resumen

| ID | Título | Estado | Notas |
|:---:|--------|--------|-------|
| **BUG-01** | `getCentroClienteMp2` — duplicado por contratación | **PENDIENTE** | Vitaly: no es multi-contrato válido → **error de contratación** |
| **BUG-02** | Protocolos huérfanos en inserción de alta | **PENDIENTE** (fix en origen) | Workaround temporal en reconciliación |
| **BUG-03** | Cliente sin ACP → NPE en recalcular/aplicar | **PENDIENTE** | Falta null-safe + regla de negocio |

---

## BUG-01 — `getCentroClienteMp2` (error de contratación)

### Qué vimos

| Campo | Detalle |
|-------|---------|
| **Síntoma** | **502** / `IncorrectResultSizeDataAccessException` (*expected 1, actual 2*) |
| **Origen técnico** | `AltaReconocimientoDaoImpl.getCentroClienteMp2` — `queryForObject` sobre SQL con `distinct(t.centro_id)` que puede devolver **2 filas** si hay 2 `ENTIDAD_ID` / `contrato_id` distintos para el mismo cli/cen PVS |
| **Dónde se usa** | `recalcularConfiguracionProtocolos` y `aplicarConfiguracionProtocolos` |
| **Repro** | **cli 280 / cen 1** — 2 contratos PVS en BD. RM: `12341907` (escenario ASOCIAR) |
| **Impacto en pruebas** | CONFIRMAR ASOCIAR E2E bloqueado hacia ese destino; SIMULAR del mismo caso pasó (RL OK, fallo en protocolos) |

### Posición Vitaly (reunión Jul 2026)

> Un cliente **no puede** tener más de un contrato activo de VS (PVS).  
> Si se da → **error de contratación** (dato maestro incorrecto), no un caso que el código deba resolver eligiendo entre N contratos.

**Reclasificación:** no es bug de “selección multi-PVS”, sino **dato de contratación inválido** en el entorno de prueba (cli 280 / cen 1).

### Acciones acordadas / propuestas

| Responsable | Acción |
|-------------|--------|
| **Contratación / datos** | Revisar y regularizar cli 280 / cen 1 en `CT_CONTRATOLD` / `CT_VIGOR_X_CENTROS` (dejar 1 solo PVS activo) |
| **Vitaly (opcional)** | Sustituir `queryForObject` por detección explícita: si `rows.size() > 1` → error de negocio *"Error de contratación: múltiples contratos PVS activos"* (no elegir uno al azar) |
| **QA Babooni** | No usar cli/cen con contratación dudosa; repetir ASOCIAR E2E con destino de contratación limpia |

### Pregunta abierta para Vitaly

¿Quién regulariza cli 280 / cen 1 en demo? ¿Qué cli/cen alternativo recomendáis para cerrar pruebas ASOCIAR?

---

## BUG-02 — Protocolos huérfanos (asimetría en inserción)

| Campo | Detalle |
|-------|---------|
| **Síntoma** | Pruebas en `INF3_RM_PRUEBAS` con `PROTOCOLO_ID` **sin fila padre** en `INF3_RM_PROTOCOLOS` (ej. `protocolos=0` pero `pruebas=27`) |
| **Origen** | Asimetría en el alta al insertar protocolos por tipo y configuración: |
| | • `INF3_RM_PROTOCOLOS` solo se inserta si el puesto tiene **configuración propia** |
| | • `INF3_RM_PRUEBAS` / cuestionarios se insertan también con **protocolos de cliente**, aunque no haya config propia |
| **Repro** | Puesto de **centro** sin configuración propia de protocolos, pero con protocolos de cliente asignados |
| **Impacto** | Pruebas huérfanas, conteos incoherentes, protocolos no visibles en pantalla del reconocimiento |
| **Workaround Babooni** | `repararProtocolosHuerfanos` en `/aplicar` + espejo en `/recalcular` (temporal, no sustituye fix en alta) |
| **Fix esperado** | Alinear la condición de inserción de `INF3_RM_PROTOCOLOS` con la de pruebas/cuestionarios cuando hay `protocolosCliente` |

### Fix propuesto (en el método de inserción por tipo y config)

```java
// ANTES
if (tieneConfiguracionProtocolos) {
    insertarProtocolos(...);
}
if (tieneConfiguracionProtocolos || !protocolosCliente.isEmpty()) {
    insertarPruebas(...);
    insertarCuestionarios(...);
}

// DESPUÉS
if (tieneConfiguracionProtocolos || !protocolosCliente.isEmpty()) {
    insertarProtocolos(...);
}
if (tieneConfiguracionProtocolos || !protocolosCliente.isEmpty()) {
    insertarPruebas(...);
    insertarCuestionarios(...);
}
```

### SQL de verificación

```sql
SELECT p.RM_ID, p.PRUEBA_ID, p.PROTOCOLO_ID
FROM VIG_SALUD.INF3_RM_PRUEBAS p
WHERE p.BORRADO IS NULL
  AND p.PROTOCOLO_ID IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 FROM VIG_SALUD.INF3_RM_PROTOCOLOS pr
      WHERE pr.RM_ID = p.RM_ID
        AND pr.PROTOCOLO_ID = p.PROTOCOLO_ID
  )
ORDER BY p.RM_ID DESC;
```

Doc detallada: `vitaly-bug-protocolos-huerfanos.md`

---

## BUG-03 — Cliente sin ACP

| Campo | Detalle |
|-------|---------|
| **Síntoma** | **502** / **NPE**: `Cannot invoke Acp.getPeriodicidad() because "acp" is null` |
| **Origen** | Flujo de `/recalcular` y `/aplicar` — ramas de periodicidad/ACP asumen que `resolverElementosAcp` devuelve ACP no nulo |
| **Repro** | `rmId=12348014` — cliente **sin ACP** configurado |
| **Impacto** | No se puede calcular impacto (SIMULAR) ni aplicar protocolos (CONFIRMAR) para RMs de esos clientes |
| **Fix esperado** | Null-safe como en `calcularPeriodicidad` del applier + regla de negocio explícita (¿periodicidad null? ¿error 4xx controlado?) |

### Fix propuesto (patrón ya existente en applier)

```java
if (acp != null && acp.getPeriodicidad() != null && acp.getPeriodicidad().getId() != 0) {
    // usar periodicidad del ACP
}
// si no: null o error de negocio controlado — nunca NPE
```

---

## Datos de prueba

| Condición | Bug | Acción |
|-----------|-----|--------|
| cli/cen con **>1 contrato PVS** en BD (ej. 280/1) | BUG-01 | Error de contratación — regularizar dato o evitar en QA |
| Cliente **sin ACP** (ej. rm 12348014) | BUG-03 | Evitar en QA hasta fix |
| Puesto centro sin config propia + protocolos de cliente | BUG-02 | Caso válido para validar fix en alta |

---

## Guion reunión Vitaly (BUG-02 y BUG-03)

Ver resumen en conversación / notas de reunión. BUG-01 cerrado como tema de contratación + mensaje explícito opcional en código.
