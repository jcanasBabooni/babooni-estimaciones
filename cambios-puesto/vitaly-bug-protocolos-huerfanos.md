# Bug: Protocolos huérfanos en el motor de ALTA

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

## Fix

En el método que gestiona la inserción de protocolos por tipo y configuración, alinear la condición de inserción de `INF3_RM_PROTOCOLOS` con la de `INF3_RM_PRUEBAS`:

```
// ANTES
if (tieneConfiguracionProtocolos) {
    insertarProtocolos(...)
}

if (tieneConfiguracionProtocolos || !protocolosCliente.isEmpty()) {
    insertarPruebas(...)
    insertarCuestionarios(...)
    ...
}

// DESPUÉS
if (tieneConfiguracionProtocolos || !protocolosCliente.isEmpty()) {
    insertarProtocolos(...)
}

if (tieneConfiguracionProtocolos || !protocolosCliente.isEmpty()) {
    insertarPruebas(...)
    insertarCuestionarios(...)
    ...
}
```

## Verificación en base de datos

Query para detectar RMs con pruebas huérfanas:

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

Si devuelve filas, son los RMs afectados. Ejecutar antes y después del fix para validar que el resultado queda vacío.

## Notas

- El fix afecta únicamente a la rama de **protocolos de cliente** (no RL/ESP).
- La rama RL/ESP no se ve afectada: los protocolos ESP se insertan mediante un flujo propio y ya están correctamente sincronizados.
- Afecta principalmente a **puestos de centro** (sin configuración propia de protocolos), que es el caso más común en clientes sin personalización.
