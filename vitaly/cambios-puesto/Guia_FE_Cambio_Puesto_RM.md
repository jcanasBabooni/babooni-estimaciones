# Guía Frontend — Cambio de puesto RM (MINERVA)

> **Audiencia:** equipo `rrmm-frontend` (Angular) y agentes Cursor que implementen el modal.
> **Backend:** `rrmm-backend` rama `feature/Cambio-puesto-sprint-1` (BE listo para integración).
> **RF de referencia:** `funcional/RF_MINERVA_cambio_puesto_reconocimiento_y_protocolos_v6.md`
> **Checklist QA:** `QA_Checklist_Cambio_Puesto_RM_Frontend.html` — marcar ítems al implementar y probar.

---

## Instrucciones para Cursor

Al trabajar en este evolutivo en `rrmm-frontend`:

1. **Leer este documento** antes de tocar código. El backend ya expone el contrato; el FE debe consumirlo sin reinterpretar reglas de negocio.
2. **Seguir el checklist FE** (`FE-01` … `FE-15`) como lista de aceptación. Marcar ítems al completarlos.
3. **No bloquear por avisos informativos** (`avisos[]`, `warnings[]`). Solo `bloqueante=true` en SIMULAR detiene el flujo.
4. **Mapear códigos a i18n** — el backend envía claves, no textos (salvo `mensajeFuncional` y errores HTTP `customMessage`).
5. **Patrón modal existente:** reutilizar `NgbModal` como `modal-medicos-enfermeros`; registrar componentes en `modals.module.ts`.
6. **No activar este flujo desde Historial médico** (CA-16 / CU-09): solo desde ficha RM pendiente.
7. **Prerrequisito visual:** botón visible si `display-elements` devuelve `showCambiarPuestoRM=true` **y** el usuario tiene ACL `CAMBIAR_PUESTO_RM`.
8. **Aviso CU-11 persistente en ficha:** tras CONFIRMAR, el aviso junto a «Comunicar laboratorio» no depende solo de `warnings[]` (se pierde al recargar). Usar `showAnaliticaComunicadaNuevosParametros` de `get-elementos-ficha-mostrar` (ver § Displays ficha).

---

## API — Base y autenticación

| Concepto | Valor |
|----------|-------|
| Context path | `/rrmm-backend` |
| Prefijo RM | `/rm` |
| Auth | `Authorization: Bearer <jwt>` en todas las llamadas |
| Errores | JSON `RestApiError` → mostrar **`customMessage`** al usuario |

```json
{
  "timestamp": 1783428419169,
  "code": { "value": 1001, "message": "Revise los datos del usuario..." },
  "customMessage": "Mensaje útil para el usuario"
}
```

---

## Endpoints del modal

### Catálogo (modal principal)

| Método | Ruta | Uso FE |
|--------|------|--------|
| `GET` | `/rm/cambio-puesto/clientes?q={texto}` | Typeahead cliente (≥3 chars o CIF 8-12) |
| `GET` | `/rm/cambio-puesto/centros?clienteId={id}&nombre=&provincia=&localidad=` | Tabla centros tras elegir cliente |
| `GET` | `/rm/cambio-puesto/puestos/{clienteId}/{centroId}?rmId={rmId}` | Catálogo C / EC / E del centro |
| `GET` | `/rm/cambio-puesto/puestos/{clienteId}/{centroId}/estandar?rmId={rmId}&criterio={texto}` | Typeahead estándar (≥3 chars) |

### Acción principal

| Método | Ruta | Uso FE |
|--------|------|--------|
| `PUT` | `/rm/{rmId}/cambiar-puesto` | **SIMULAR** (Continuar) y **CONFIRMAR** |

### Displays ficha (CU-11 persistente)

| Método | Ruta | Uso FE |
|--------|------|--------|
| `POST` | `/displays/get-elementos-ficha-mostrar` | Flags de visibilidad de la ficha RM (incl. cambio puesto y aviso CU-11) |

Body: objeto `Reconocimiento` (mismo que ya usa la ficha). Respuesta: `Map<string, boolean>`.

| Clave | `true` cuando | Uso FE |
|-------|---------------|--------|
| `showCambiarPuestoRM` | RM pendiente + ACL `CAMBIAR_PUESTO_RM` | Icono modal cambio puesto (FE-02) |
| `showAnaliticaComunicadaNuevosParametros` | Lab comunicado activo **y** último cambio de puesto confirmado añadió parámetros/perfiles analíticos (CU-11) | Aviso junto a «Comunicar laboratorio» (FE-11) |

**Importante:** `showAnaliticaComunicadaNuevosParametros` replica la condición de CU-11 de `warnings[]`/`avisos[]`, pero **sobrevive a recargar la ficha**. El backend persiste el hecho en el log CA-17 (`aa=1` en `INF4_RM_LOG.COMENTARIO`) al CONFIRMAR.

Ejemplo de respuesta (fragmento):

```json
{
  "showCambiarPuestoRM": true,
  "showAnaliticaComunicadaNuevosParametros": true,
  "showValidarRM": false
}
```

Añadir `showAnaliticaComunicadaNuevosParametros?: boolean` al modelo `Displays` de ficha (junto a `showCambiarPuestoRM`, `showConfirmarRM`, etc.).

---

## Request unificado (`CambioPuestoRequest`)

Mismo body para SIMULAR y CONFIRMAR; solo cambia `accion`.

```json
{
  "accion": "SIMULAR",
  "clienteId": 234783,
  "centroId": 370960,
  "puestoId": 121937,
  "estandar": 1,
  "tipoPuesto": "E",
  "puestosAdicionales": [
    { "puestoId": 999, "estandar": 0 }
  ]
}
```

| Campo | Tipo | Obligatorio | Notas |
|-------|------|-------------|-------|
| `accion` | `"SIMULAR"` \| `"CONFIRMAR"` | Sí | |
| `clienteId` | int | Sí | > 0 |
| `centroId` | int | Sí | > 0 |
| `puestoId` | int | Sí | Puesto principal |
| `estandar` | int | Sí | `1` = estándar VS, `0` = puesto de centro |
| `tipoPuesto` | string | Recomendado | `E`, `C`, `EC` — coherente con catálogo |
| `puestosAdicionales` | array | No | `{ puestoId, estandar }` por chip |

---

## SIMULAR — `accion: "SIMULAR"` (botón «Continuar»)

- **No persiste** cambios en BD.
- **HTTP 200** en éxito (incluso si `bloqueante=true`).
- Abre ventana resumen solo si `bloqueante=false`.

### Respuesta (`CambioPuestoSimularResponse`)

```json
{
  "deltas": {
    "protocolos": { "anadidos": ["Protocolo X"], "eliminados": ["Protocolo Y"] },
    "pruebas": { "anadidos": [], "eliminados": ["Audiometría"] },
    "parametros": { "anadidos": ["Colesterol HDL"], "eliminados": [] },
    "perfiles": null,
    "cuestionarios": null,
    "periodicidad": { "anterior": "Anual", "nueva": "Bienal" },
    "fechaRecomendada": { "anterior": "01/07/2027", "nueva": "01/07/2028" }
  },
  "avisos": ["protocolosImpacto", "laboratorioComunicado"],
  "rlEscenario": "EDITAR",
  "bloqueante": false,
  "mensajeFuncional": null
}
```

| Campo | Regla UI |
|-------|----------|
| `bloqueante` | `true` → mostrar `mensajeFuncional`, **no** abrir resumen, **no** permitir confirmar |
| `rlEscenario` | Badge informativo en resumen (ver tabla escenarios) |
| `deltas` | `null` si no hay impacto visible. Solo pintar bloques presentes |
| `avisos` | Lista de **códigos** → traducir con i18n (ver § i18n) |
| `mensajeFuncional` | Texto literal del BE cuando `bloqueante=true` |

### Estructura `deltas`

Categorías posibles (solo las que cambian):

| Bloque | Formato |
|--------|---------|
| `protocolos`, `pruebas`, `parametros`, `perfiles`, `cuestionarios` | `{ anadidos: string[], eliminados: string[] }` |
| `periodicidad`, `fechaRecomendada` | `{ anterior: string, nueva: string }` |

**Nota fija en resumen (RF §7.4, no viene del BE):**

> *Las pruebas ya cumplimentadas se mantienen en el reconocimiento.*

Clave i18n: `cambioPuesto.resumen.pruebasCumplimentadas`

---

## Escenarios RL (`rlEscenario`)

| Valor | Cuándo | `bloqueante` | Acción en CONFIRMAR (`rlAccion`) |
|-------|--------|--------------|----------------------------------|
| `EDITAR` | Mismo cli/cen, cambia puesto principal | `false` | `EDITADA` |
| `SOLO_ADICIONALES` | Mismo cli/cen y mismo puesto principal | `false` | `EDITADA` |
| `CREAR` | Cambio cli/cen sin RL en destino | `false` | `CREADA` |
| `ASOCIAR` | RL distinta en destino | `false` | `ASOCIADA` |
| `BLOQUEAR` | RL no resoluble | **`true`** | — (CONFIRMAR → 409) |

### Mensajes `mensajeFuncional` (BLOQUEAR)

El backend envía el texto ya en español:

| Situación | Texto |
|-----------|-------|
| Sin RL origen | No se puede resolver la relación laboral del trabajador. |
| Varias RL en origen | No se puede resolver la relación laboral: existen varias RL activas en origen. |
| Varias RL en destino | No se puede resolver la relación laboral: existen varias RL activas en destino. |
| Genérico | No se puede resolver la relación laboral de forma segura. |

---

## CONFIRMAR — `accion: "CONFIRMAR"` (botón «Confirmar cambios»)

- **HTTP 200** si el flujo termina correctamente.
- Tras éxito: cerrar modal, refrescar ficha RM, toast de éxito.

### Respuesta (`CambioPuestoConfirmarResponse`)

```json
{
  "rmId": 12341907,
  "rlAfectadaId": 4782422,
  "rlAccion": "EDITADA",
  "logId": 34589899,
  "warnings": ["laboratorioComunicado", "analiticaComunicadaNuevosParametros"]
}
```

| Campo | UI |
|-------|-----|
| `rmId` | ID actualizado — refrescar datos de ficha |
| `rlAfectadaId` | Opcional en detalle técnico |
| `rlAccion` | Mensaje de éxito según escenario (`EDITADA` / `CREADA` / `ASOCIADA`) |
| `logId` | Trazabilidad CA-17 (opcional) |
| `warnings` | Mismos códigos que `avisos` de laboratorio — **informativos**, no error |

`warnings: []` es respuesta válida y frecuente.

---

## Códigos de aviso — contrato i18n

El backend **no envía textos** en `avisos[]` ni `warnings[]`. El FE debe mapear cada código.

### Claves y textos propuestos (español)

```json
{
  "cambioPuesto": {
    "aviso": {
      "protocolosImpacto": "El cambio modifica protocolos, pruebas o cuestionarios. Revise el resumen antes de confirmar.",
      "analiticaImpacto": "El cambio modifica parámetros o perfiles analíticos. Revise el resumen antes de confirmar.",
      "periodicidadImpacto": "El cambio modifica la periodicidad o la fecha recomendada del reconocimiento. Revise el resumen antes de confirmar.",
      "laboratorioComunicado": "El reconocimiento ya tiene comunicación a laboratorio. Revise el impacto antes de continuar.",
      "analiticaComunicadaNuevosParametros": "Nuevos parámetros añadidos. Revise si requiere nueva comunicación."
    },
    "resumen": {
      "pruebasCumplimentadas": "Las pruebas ya cumplimentadas se mantienen en el reconocimiento."
    },
    "rl": {
      "editar": "Se actualizará el puesto en la relación laboral actual.",
      "soloAdicionales": "Se actualizarán los puestos adicionales; el puesto principal no cambia.",
      "crear": "Se creará una nueva relación laboral en el centro destino.",
      "asociar": "Se asociará el trabajador a la relación laboral existente en el centro destino."
    },
    "confirmar": {
      "exito": {
        "editada": "Puesto actualizado correctamente.",
        "creada": "Puesto actualizado. Se ha creado una nueva relación laboral.",
        "asociada": "Puesto actualizado. Se ha asociado a la relación laboral del centro destino."
      }
    }
  }
}
```

### Tabla de códigos

| Código BE | Cuándo aparece | ¿Bloquea? | Origen RF |
|-----------|----------------|-----------|-----------|
| `protocolosImpacto` | Cambian protocolos, pruebas o cuestionarios | No | §7.7 |
| `analiticaImpacto` | Cambian parámetros o perfiles | No | §7.7 |
| `periodicidadImpacto` | Cambia periodicidad o fecha recomendada | No | §7.5 / §7.7 |
| `laboratorioComunicado` | RM con comunicación activa al lab (CA-15) | No | §7.7 |
| `analiticaComunicadaNuevosParametros` | Lab comunicado + nuevos parámetros/perfiles (CU-11) | No | §7.6 |

### Reglas CA-15 / CU-11 (FE-11)

- **CA-15** (`laboratorioComunicado`): aviso informativo. **No bloquea** Continuar ni Confirmar (N1 cerrado).
- **CU-11** (`analiticaComunicadaNuevosParametros`): solo si además hay parámetros/perfiles **añadidos** en deltas.
- Mostrar CU-11 en **dos sitios** (RF §7.6):
  1. **Modal** — ventana resumen (SIMULAR): mapear código `analiticaComunicadaNuevosParametros` de `avisos[]`.
  2. **Ficha RM** — junto a «Comunicar laboratorio»: usar `displays.showAnaliticaComunicadaNuevosParametros === true` de `POST /displays/get-elementos-ficha-mostrar`.

#### Estrategia recomendada para la ficha (post-CONFIRMAR)

| Momento | Fuente del aviso CU-11 |
|---------|------------------------|
| Justo tras CONFIRMAR 200 (sin recargar) | Opcional: `warnings[]` **o** refrescar displays y usar el flag |
| Tras recargar / reentrar en ficha | **`showAnaliticaComunicadaNuevosParametros`** (única fuente fiable) |

Mismo texto i18n en ambos sitios: clave `cambioPuesto.aviso.analiticaComunicadaNuevosParametros`.

#### Limitaciones (no son bugs FE)

| Caso | Comportamiento |
|------|----------------|
| Cambios de puesto confirmados **antes** del despliegue con flag `aa` | `showAnaliticaComunicadaNuevosParametros=false` (sin dato histórico en log) |
| Nuevo cambio de puesto **sin** analítica añadida | El último log CA-17 no tiene `aa=1` → el aviso desaparece |
| Usuario re-comunica al laboratorio | El aviso puede seguir visible mientras lab activo + último log con `aa=1` |

---

## Errores HTTP — qué esperar

| HTTP | Cuándo | `customMessage` típico | Acción FE |
|------|--------|------------------------|-----------|
| **422** | Validación negocio | Ver tabla abajo | Toast/modal; corregir selección |
| **403** | Sin permiso o RM no pendiente | Ver tabla abajo | Cerrar modal / ocultar acción |
| **409** | RL BLOQUEAR en CONFIRMAR | Mensaje RL del BE | Error; no reintentar a ciegas |
| **502** | Fallo puestos-back / rrmm-utils | Mensaje integración | Error técnico |
| **500** | Error JDBC no traducido (BUG-05) | Ver § Errores 500 enmascarados | Leer `details` en body; no confundir con cita |
| **501** | P1 no disponible (solo dev) | Motor dry-run no disponible | Solo entornos sin P1 |
| **401** | JWT inválido/ausente | — | Renovar sesión |
| **400** | Body mal formado | — | Revisar payload |

### Mensajes 422 frecuentes

| `customMessage` | Causa |
|-----------------|-------|
| Debe indicar cliente, centro y puesto principal. | IDs inválidos |
| Debe indicar la acción SIMULAR o CONFIRMAR. | `accion` ausente |
| El centro destino no tiene contrato PVS activo. | Centro sin PVS |
| El centro destino se encuentra en Versión 1. | Centro legacy |
| El puesto de trabajo destino se encuentra en Versión 1. Defina un puesto estándar o de centro actualizado. | Puesto centro id < 300000 |
| Token de autenticación no presente. | Sin JWT (catálogo) |
| Reconocimiento no encontrado: {rmId} | RM inexistente |
| Puesto con OK técnico; no se puede cambiar la relación laboral. | OK técnico + PT contratada |

### Mensajes 403

| `customMessage` | Causa |
|-----------------|-------|
| No tiene permiso para editar el puesto de reconocimientos. | Sin `CAMBIAR_PUESTO_RM` |
| El reconocimiento ya no está pendiente; no se puede confirmar el cambio de puesto. | RM ya no en estado 8 |

### Mensajes 409

| `customMessage` | Causa |
|-----------------|-------|
| No se puede resolver la relación laboral… | Mismo texto que `mensajeFuncional` BLOQUEAR |
| Relación laboral no encontrada o no activa. | ASOCIAR fallido en ejecución |

### Mensajes 502

| `customMessage` | Causa |
|-----------------|-------|
| No se ha podido calcular el impacto propuesto del cambio de puesto. | SIMULAR — fallo rrmm-utils |
| No se ha podido aplicar la nueva configuración de protocolos del cambio de puesto. | CONFIRMAR — fallo applier |
| No se ha podido consultar el catálogo de puestos. | Fallo puestos-back |

### Errores 500 enmascarados (BUG-05 dev)

Algunos fallos JDBC en rrmm-backend devuelven **500** con cuerpo distinto de `RestApiError`:

```json
{
  "message": "Error al acceder a las observaciones de la cita",
  "details": "Incorrect result size: expected 1, actual 5288"
}
```

| Campo | Uso FE / QA |
|-------|-------------|
| `message` | **Ignorar** para diagnóstico — texto fijo incorrecto (handler global de citas) |
| `details` | **Pista real** del error (SQL, ORA-*, IncorrectResultSize…) |

El modal actual (`mostrarErrorApi`) solo muestra `customMessage` → cae al texto genérico *No se han podido aplicar los cambios de puesto*. **Mejora pendiente FE:** mostrar `details` o `message` cuando no haya `customMessage`.

Caso conocido **corregido en BE (14-jul-2026):** CONFIRMAR con cambio de cliente/centro y centro origen con `RM_CEN_ID` ambiguo (ej. **1** repetido en miles de filas GC). Fix: `getNombreCentro(clienteMp2, centroMp2)` al construir `RM_MOVIDO`. E2E: rmId **2980099**, cli **9422**, cen **1**.

---

## Flujo UI (diagrama)

```
[Ficha RM pendiente]
       │
       ▼
[Icono «Cambiar puesto»]  ← showCambiarPuestoRM + ACL
       │
       ▼
[Modal: cliente → centro → puesto principal → adicionales]
       │
       │  Cancelar → cierra sin cambios (CU-08)
       │
       ▼
[Continuar] → PUT accion=SIMULAR
       │
       ├─ bloqueante=true → mensajeFuncional, STOP
       ├─ 4xx/5xx → error HTTP (customMessage)
       │
       └─ bloqueante=false → [Ventana resumen]
                │  deltas + avisos + rlEscenario + nota pruebas cumplimentadas
                │
                ├─ Cancelar → cierra sin CONFIRMAR
                │
                └─ Confirmar → PUT accion=CONFIRMAR
                       ├─ 200 → toast éxito + refrescar ficha + displays (showAnaliticaComunicadaNuevosParametros)
                       ├─ 403 → RM dejó de estar pendiente
                       ├─ 409 → RL bloqueada
                       └─ 502 → error integración
```

---

## Tareas de implementación (mapa FE → Cursor)

### FE-01 — Smoke / módulo
- [ ] Crear servicio `CambioPuestoService` (o equivalente) con métodos para los 5 endpoints.
- [ ] Registrar modales en `modals.module.ts`: modal principal + ventana resumen.
- [ ] Build demo sin errores al abrir ficha RM.

### FE-02 — Acceso y permisos
- [ ] Mostrar icono solo si `showCambiarPuestoRM=true` en displays.
- [ ] Ocultar si RM no pendiente o sin ACL (no depender solo del 403).
- [ ] CA-16: no mostrar en Historial médico.

### FE-03 — Modal principal
- [ ] `NgbModal` al pulsar icono.
- [ ] Cabecera con nombre persona (CA-03).
- [ ] Footer: Cancelar + Continuar (Continuar deshabilitado hasta selección válida).
- [ ] Precargar cli/cen/puesto actual del RM (CA-07).

### FE-04 — Cliente
- [ ] Typeahead ≥3 chars o CIF; mensaje si <3 (CA-04).
- [ ] GET `/cambio-puesto/clientes?q=`.
- [ ] Al cambiar cliente: reset centro + recargar puestos.

### FE-05 — Centros
- [ ] Tabla centros tras elegir cliente (CA-06).
- [ ] Filtros locales o query params.
- [ ] Selección recarga catálogo puestos.

### FE-06 — Puesto principal
- [ ] GET catálogo con `rmId`.
- [ ] Radio único C / EC / E (CA-08).
- [ ] Typeahead estándar ≥3 chars.
- [ ] Columnas código / denominación / nº trabajadores.

### FE-07 — Adicionales
- [ ] Chips eliminables, bloque plegado (CA-09).
- [ ] Checkbox múltiple + Añadir (CA-10).
- [ ] N3: no promover adicional a principal sin quitar chip.
- [ ] Payload `puestosAdicionales[]`.

### FE-08 — Estados y errores
- [ ] Spinners en catálogo, SIMULAR, CONFIRMAR.
- [ ] `bloqueante=true` → `mensajeFuncional`, sin resumen.
- [ ] Errores 403/409/422/502 con `customMessage`.

### FE-09 — Ventana resumen (SIMULAR)
- [ ] CA-11: abrir solo tras SIMULAR OK y `bloqueante=false`.
- [ ] Pintar deltas por categoría (añadidos/eliminados).
- [ ] Badge `rlEscenario` + avisos i18n.
- [ ] Nota fija pruebas cumplimentadas.
- [ ] CA-12: Cancelar en resumen no llama CONFIRMAR.

### FE-10 — CONFIRMAR
- [ ] PUT con mismo body + `accion: "CONFIRMAR"`.
- [ ] Toast éxito según `rlAccion`.
- [ ] Refrescar ficha RM tras 200.
- [ ] 409/502: modal error, ficha coherente (no UI de éxito).

### FE-11 — Avisos CA-15 / CU-11
- [ ] Mapear los 5 códigos de aviso a i18n.
- [ ] Mostrar `avisos[]` en ventana resumen (SIMULAR) y `warnings[]` tras CONFIRMAR (toast/modal opcional).
- [ ] CU-11 en ficha: leer `showAnaliticaComunicadaNuevosParametros` de `get-elementos-ficha-mostrar` y mostrar aviso junto a «Comunicar laboratorio».
- [ ] Tras CONFIRMAR 200: refrescar displays de ficha (además de datos RM) para que el flag CU-11 quede activo sin depender de `warnings[]`.

### FE-13 — i18n
- [ ] Añadir bloque `cambioPuesto` en ficheros i18n (es mínimo; ca/en si aplica proyecto).

---

## Datos de prueba (referencia backend)

| Caso | rmId | Notas |
|------|------|-------|
| EDITAR OK | 12341907 | cli 234783, cen 370960 — **agotado** tras E2E |
| BLOQUEAR | 12351907 | cli 355360, cen 242280 |
| CA-15 + CU-11 | 12339235 | cli 444064, cen 349303 — lab comunicado + param nuevo |
| CREAR OK | (logId=10 en pruebas BE) | Cambio cli/cen sin RL destino |
| ASOCIAR CONFIRMAR | — | Bloqueado por BUG-01 Vitaly (multi-PVS) en algunos cli/cen |

**Estado RM pendiente:** último log `ESTADO_ID = 8`. Estado 6 = finalizado → 403 en SIMULAR/CONFIRMAR.

**Evitar en pruebas E2E:** clientes con >1 contrato PVS (BUG-01) y clientes sin ACP/periodicidad (BUG-03 Vitaly → 502 en applier).

---

## Limitaciones conocidas (no son bugs FE)

| ID | Impacto en FE |
|----|---------------|
| BUG-01 Vitaly | CONFIRMAR puede devolver 502 tras actualizar parcialmente — mostrar error, refrescar ficha |
| BUG-03 Vitaly | 502 en algunos clientes sin ACP — error integración |
| BUG-05 dev | HTTP 500 con `message` fijo *observaciones de la cita* — leer **`details`** en Network; no es fallo de cita ni del modal |
| RM_MOVIDO lookup | CONFIRMAR al cambiar cli/cen: corregido en BE 14-jul-2026 (`getNombreCentro` con cliente+centro MP2) |

---

## Ejemplos JSON por escenario

### EDITAR — SIMULAR OK
```json
{
  "bloqueante": false,
  "rlEscenario": "EDITAR",
  "deltas": { "protocolos": { "anadidos": ["X"], "eliminados": [] } },
  "avisos": ["protocolosImpacto"]
}
```

### BLOQUEAR — SIMULAR (200 con bloqueo)
```json
{
  "bloqueante": true,
  "rlEscenario": "BLOQUEAR",
  "mensajeFuncional": "No se puede resolver la relación laboral del trabajador.",
  "deltas": null,
  "avisos": []
}
```

### CONFIRMAR OK con warnings
```json
{
  "rmId": 12339235,
  "rlAccion": "EDITADA",
  "rlAfectadaId": 2726353,
  "logId": 34589999,
  "warnings": ["laboratorioComunicado", "analiticaComunicadaNuevosParametros"]
}
```

---

## Referencias cruzadas

| Documento | Contenido |
|-----------|-----------|
| `QA_Checklist_Cambio_Puesto_RM_Frontend.html` | Checklist detallado FE-01…FE-15 |
| `QA_Checklist_Cambio_Puesto_RM_Backend.html` | Casos API ya probados en BE |
| `funcional/RF_MINERVA_cambio_puesto_reconocimiento_y_protocolos_v6.md` | Reglas de negocio y mensajes oficiales |
| Swagger | `{base}/rrmm-backend/swagger-ui.html` → tag «Cambio de puesto RM» |

---

*Última actualización: 2026-07-14 — Errores 500 BUG-05 (`details` vs `customMessage`); fix `RM_MOVIDO` / getNombreCentro (rmId 2980099).*
