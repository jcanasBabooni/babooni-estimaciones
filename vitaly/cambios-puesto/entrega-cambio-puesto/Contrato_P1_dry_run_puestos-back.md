# P1 — Dry-run impacto RM (puestos-back)

**Evolutivo:** MINERVA Cambio de Puesto · BE-06  
**Consumidor:** solo `rrmm-backend` (el front no llama a este endpoint).

**Regla:** misma lógica que **crear RM** con la configuración indicada, **sin persistir nada**. Devuelve el snapshot **propuesto**; rrmm calcula el diff con el estado actual del RM en Oracle.

---

## Endpoint sugerido

```http
POST /puestos-back/puestos/reconocimientos/{rmId}/simular-impacto
Authorization: Bearer {jwt}
Content-Type: application/json
```

---

## Request

**Path:** `rmId` (int) — reconocimiento pendiente (contexto trabajador, ACP, etc.).

**Body:**

```json
{
  "clienteId": 234783,
  "centroId": 598076,
  "puestoId": 10027,
  "estandar": 1,
  "tipoPuesto": "E",
  "puestosAdicionales": [
    {
      "puestoId": 10028,
      "estandar": 1,
      "nombrePtoIntegracion": null
    }
  ]
}
```

| Campo | Obligatorio | Notas |
|-------|-------------|-------|
| `clienteId` | Sí | Cliente MP2 |
| `centroId` | Sí | Centro MP2 |
| `puestoId` | Sí | Puesto principal destino |
| `estandar` | Sí | `1` = estándar VS, `0` = puesto de centro |
| `tipoPuesto` | Recomendado | `C` / `E` / `EC` |
| `puestosAdicionales` | No | Selección del modal; **no** leer de `INF_RM_PTOS_ADICIONALES` |

---

## Response

```json
{
  "rmId": 12350580,
  "protocolos": [{ "id": 101, "etiqueta": "P01 — Audiometría" }],
  "pruebas": [{ "id": 502, "etiqueta": "RX-VS-001 — Radiografía" }],
  "parametros": [{ "id": 30, "etiqueta": "GLU — Glucosa" }],
  "perfiles": [{ "id": 12, "etiqueta": "PER-01 — Perfil básico" }],
  "cuestionarios": [{ "id": 7, "etiqueta": "CUES-AMIANTO — Amianto" }],
  "periodicidad": "Semestral",
  "fechaRecomendada": "2026-12-01"
}
```

| Campo | Notas |
|-------|--------|
| `protocolos`, `pruebas`, `parametros`, `perfiles`, `cuestionarios` | Lista de `{ id, etiqueta }`. Ids de catálogo (`PRO_PROTOCOLOS`, `INF3_PRUEBAS`, `EA_PARAMETROS`, `EA_PERFILES`, `PRO_CUESTIONARIOS`). Sin duplicados por `id`. |
| `etiqueta` | Texto legible para UI, p. ej. `CODIGO — NOMBRE` |
| `periodicidad` | Nombre legible (misma lógica que creación RM) |
| `fechaRecomendada` | Formato `YYYY-MM-DD` |

Listas vacías → `[]`. Escalares no aplicables → `null`.

---

## Fuera de alcance P1

- No devolver deltas (los calcula rrmm).
- No leer ni mutar el RM actual en BD.
- No resolver ni modificar relación laboral.

---

## Resumen para implementación

Con el destino del modal, calcular qué protocolos, pruebas, parámetros, perfiles, cuestionarios, periodicidad y fecha recomendada tendría el RM si se creara con esa configuración; devolver esa lista normalizada; **cero escritura en BD**.
