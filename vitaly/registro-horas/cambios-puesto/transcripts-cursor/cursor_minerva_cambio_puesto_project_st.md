# Minerva cambio puesto project status
_Exported on 6/24/2026 at 19:13:31 GMT+2 from Cursor (3.8.23)_

---

**User**

No se que ha pasado pero hemos perdido la conversacion en el chat de todo el desarrollo que llevabamos para el proyecto de cambios de puesto@estimaciones/cambios-pueesto/funcional/RF_MINERVA_cambio_puesto_reconocimiento_y_protocolos_v6.md 

@estimaciones/cambios-pueesto/monday/Monday_MINERVA_Cambio_Puesto.csv @estimaciones/cambios-pueesto/Estimacion_Minerva_Cambio_Puesto.html @estimaciones/cambios-pueesto/funcional-tecnico/Funcional_Tecnico_Minerva_Cambio_Puesto.html 
Todo esto ya lo teniamos analizado, vas a tener que volver a hacerlo para ponerte en contexto. 

Luego mira las ramas feature/Cambio-puesto-sprint-1 de ambos proyectos (puestos-back y rrmm-backend) para saber el estado actual del desarrollo, decirte que vamos muy avanzados, cerca del cierre del sprint 2. Necesito que analices bien porque todavia nos faltan cosas por hacer y desgraciadamemnte hemos perdido el estado actual dado que no encuentro el chat de ayer

---

**Cursor**

Voy a ponerme en contexto. Primero crearé un plan y empezaré a recopilar toda la información: los documentos funcionales, el estado de las ramas y, si es posible, recuperaré la conversación perdida desde los transcripts de chats anteriores.

Empiezo leyendo los documentos y explorando el estado de los repos en paralelo.

El documento funcional es grande. Lo leo por partes y, en paralelo, reviso el estado de las ramas y los transcripts.

Estoy en PowerShell (no `head`). Hay 3 transcripts principales que pueden contener la conversación perdida. Voy a revisar el historial git de ambas ramas y el contenido de los transcripts. Primero, el estado git concreto y los tamaños de los transcripts.

Voy a identificar los commits específicos del feature (no los heredados de master) y ver los tamaños/fechas de los transcripts correctamente.

Hallazgos importantes: el transcript grande `9df29029` (2.1 MB, del 23-jun 16:38) es casi seguro la conversación de ayer perdida. Y el branch de puestos-back no tiene commits propios sobre master, así que el trabajo probablemente está sin commitear. Reviso el estado del working tree de ambos repos.

Excelente, ahora tengo el panorama. Hay mucho trabajo sin commitear en ambos repos, y el transcript grande `9df29029` (2.1 MB, de ayer 16:38) es la conversación perdida. Voy a leer las piezas clave: el CSV de Monday (que define las tareas tipo BE-01), los HTMLs y el documento funcional, mientras extraigo el contexto del transcript.

El CSV de Monday me da el desglose completo de tareas por sprint. Ahora leo la parte clave del funcional (reglas RL, criterios de aceptación CA-01..CA-17) y extraigo el estado del transcript perdido.

Usaré búsqueda específica para las secciones clave (criterios de aceptación y escenarios RL) ya que las tablas son muy anchas.

Ahora leo las reglas 7.3–7.7 (relación laboral, periodicidad, warnings, validaciones) que son clave para BE-08/BE-11.

Tengo el funcional y el desglose Monday claros. Ahora el paso decisivo: entender qué está realmente implementado vs. lo que sigue mockeado. Leo los archivos clave de ambos repos. La presencia de `CambioPuestoSimularMockProvider` es una señal de que la simulación (dry-run) podría seguir mockeada.

El lado rrmm-backend está muy maduro (simular real con motor P1, confirmar transaccional, orquestación RL, logs). El mock ya está detrás de un flag. Ahora reviso el lado puestos-back (menos desarrollado) y busco marcadores de trabajo pendiente (TODO/mock/NotImplemented) en ambos repos.

Sin marcadores de mock/TODO en el código de cambio-puesto: ambos repos están bastante completos. Reviso ahora los endpoints nuevos de puestos-back y la cadena del motor de impacto (P1) en rrmm-backend.

Veo que puestos-back expone `getCatalogoCambioRm` (BE-04/05) y `cambiarPuestoRl` (BE-08), y rrmm-backend tiene toda la cadena del motor de impacto vía rrmm-utils. Confirmo la implementación real de `cambiarPuestoRl` en puestos-back, el resolver P1, y los flags de configuración. También miro la cola del transcript de ayer para corroborar el "qué falta".

Clave: el motor P1 (dry-run) se delega a `rrmm-utils` vía `/rrmm/protocolos/recalcular` (flag `rrmm-utils-enabled: true`). Necesito verificar si ese endpoint existe en rrmm-utils — podría ser una pieza pendiente. Y leo la cola del transcript de ayer para corroborar.

rrmm-utils tiene un `ProtocolosReconocimientoController` y `RecalcularProtocolosRequest` — el motor P1 vive ahí. Verifico que el endpoint exista y el estado git de rrmm-utils (tercer repo implicado).

El motor P1 (`/rrmm/protocolos/recalcular`) está implementado en rrmm-utils. Toda la cadena de integración existe. Ahora recupero el contexto de la conversación de ayer leyendo la cola del transcript grande.

He recuperado el contexto completo. La cola del transcript de ayer contenía un documento de **handoff** detallado del cierre de la sesión del 23/06. Combinado con lo que he verificado en el código actual (que coincide con ese handoff, ya que el trabajo sigue sin commitear), tengo el estado exacto.

Buenas noticias: **he recuperado la conversación de ayer**. Estaba en los transcripts de chats anteriores y, además, la última sesión cerró con un documento de *handoff* muy completo. Lo he cruzado con el código real de las ramas (que sigue sin commitear, así que coincide exactamente con ese cierre). Aquí tienes el contexto reconstruido.

> Conversación recuperada: [Cambio puesto RM MINERVA](9df29029-2f0f-4c80-be50-b7f97da638bd)

## Qué es el evolutivo

Modal en la ficha de un **reconocimiento médico pendiente** para cambiar cliente/centro/puesto principal + adicionales, **SIMULAR** el impacto (deltas de protocolos/pruebas/parámetros/perfiles/cuestionarios) y **CONFIRMAR** de forma transaccional (actualiza `INF_RM`, protocolos `INF3_*`, relación laboral, log CA-17 y avisos). Solo aplica desde el reconocimiento pendiente; desde Historial Médico se mantiene el flujo legacy (CA-16).

## Arquitectura (3 repos implicados, no 2)

| Servicio | Repo | Puerto | Rol |
|---|---|---|---|
| BFF/API principal | `rrmm-backend` | 8825 | Modal, SIMULAR/CONFIRMAR, RL, lectura `INF3_*`, log |
| Catálogo puestos | `puestos-back` | 8080 | `GET /puestos/catalogo-cambio-rm/{cli}/{cen}` + `POST /puestos/{rlId}/cambiar-puesto` |
| Motor P1 dry-run | `rrmm-utils` | 8081 | `POST /rrmm/protocolos/recalcular` (rama `feature/20260424_migracion_alta_reconocimiento`) |
| Frontend | `rrmm-frontend` | — | **Sin código de cambio-puesto aún** |

**Decisión clave** que ya tomasteis: el motor P1 dry-run **ya NO va a puestos-back** (`PuestosBackClient.simularImpactoRm` quedó `@Deprecated`); el recálculo se delega a **rrmm-utils**. Flags en `application.yml`: `mock-enabled: false`, `rrmm-utils-enabled: true` en los tres perfiles.

## Estado de las ramas (verificado hoy)

Ambas ramas `feature/Cambio-puesto-sprint-1` tienen el trabajo **sin commitear** en el working tree:
- **rrmm-backend**: 1 commit (`feat: BE-01`) + **~2.267 líneas** sin commitear (37 ficheros). Toda la cadena cambio-puesto: controller, service, 14 clases de servicio, DAOs, dominio, excepciones y 13 clases de test.
- **puestos-back**: **sin commits propios** sobre master, ~181 líneas sin commitear: `getCatalogoCambioRm` (BE-04/05 lectura) y `cambiarPuestoRl` (wrapper RL para BE-08).

## Mapa de tareas — qué está hecho y qué falta

**Sprint 1 (Fundación) — BE casi cerrado:**
- BE-01 contratos, BE-02 clientes, BE-03 centros, BE-04 puestos (vía catálogo): **Hecho**
- BE-05 adicionales: **parcial** (lectura marca `adicionalSeleccionado`; escritura en CONFIRMAR vía `replacePuestosAdicionalesRm`)
- BE-20 (MR + DEMO) y **todo FE-01…FE-06/FE-18**: **pendiente**

**Sprint 2 (Flujo E2E) — en curso, aquí está el frente de trabajo:**
- BE-06 SIMULAR (P1 + deltas + fix `SOLO_ADICIONALES`): **Hecho y validado en demo** (RM `12341907`)
- BE-08 integración RL (orchestrator + executor, 5 escenarios): **mayormente hecho**
- ⚠️ **BE-07 CONFIRMAR: parcial (~40%)** — esqueleto transaccional OK (UPDATE `INF_RM`, mutación RL, adicionales, log), pero **falta la pieza crítica**: el *applier* que sincroniza `INF3_RM_PROTOCOLOS/PRUEBAS/PARAMETROS/PERFILES/CUESTIONARIOS` con el snapshot propuesto. Sin esto, tras confirmar el RM queda desincronizado del preview.
- BE-09 log CA-17: **parcial** (INSERT + GET implementados; falta verificar que el DDL `INF4_RM_LOG_CAMBIO_PUESTO` esté aplicado en DEMO)
- BE-10 (ACL `CAMBIAR_PUESTO_RM` / concurrencia), BE-11 (CA-15 lab + CU-11 warnings), BE-12/CA-14 (guardas no borrar pruebas con valores en `INF2_RM_VALORES`), periodicidad/fecha recomendada en `EDITAR`: **pendientes**
- BE-13/CA-16 (regresión Historial Médico): OK por no tocarse
- **FE-07…FE-12**: pendiente

**Cierre (BE-14…BE-22, FE-13…FE-20):** todo pendiente (tests, Jacoco/Pitest, plan a PRO, handover).

## Gaps críticos priorizados (del próximo día, según el handoff)

1. **BE-07 — applier `INF3_*`** (la pieza más crítica que bloquea CA-13/CA-14 y el E2E real)
2. **CA-14** — guardas para no borrar pruebas/resultados ya registrados
3. **Periodicidad / fecha recomendada** en escenario `EDITAR`
4. **ACL `CAMBIAR_PUESTO_RM`** (BE-10)
5. **CA-15 / CU-11** — avisos laboratorio y warnings analítica en CONFIRMAR
6. Verificar DDL del log en DEMO + MRs/despliegue

---

Ya estoy completamente en contexto. El siguiente bloque natural de trabajo es el **applier `INF3_*` de BE-07** (CONFIRMAR real). ¿Cómo quieres que sigamos?

> **¿Por dónde retomamos el desarrollo?**
> - BE-07: diseñar e implementar el applier INF3_* en CONFIRMAR (con guardas CA-14) (Recomendado) ✔
> - Primero verificar build/tests y estado en DEMO (DDL log, re-ejecutar suite cambiopuesto) antes de codificar
> - Hacer un análisis técnico más profundo de una pieza concreta (RL, resolver P1, deltas...) antes de decidir
> - Trabajar en otra tarea pendiente (BE-10 ACL, BE-11 warnings, periodicidad, etc.)

Entendido, vamos con **BE-07: el applier `INF3_*`**. Como es la pieza más crítica y transaccional (y por tu norma de no tocar archivos sin confirmar), primero voy a hacer el diseño técnico. Para eso necesito entender bien cómo se lee hoy el snapshot `INF3_*`, cómo se materializa en el alta de reconocimiento (la referencia "recálculo equivalente a creación") y dónde están las guardas CA-14. Voy a leer esas piezas.

El punto clave del diseño emerge ya: el snapshot que se usa para SIMULAR/diff está **normalizado a `id` + `etiqueta`**, pero materializar `INF3_*` requiere la configuración completa (FKs, obligatoriedad, periodicidad...). La lógica de materialización ya existe en rrmm-utils (alta de reconocimiento). Necesito ver cómo se materializa allí para decidir dónde vive el applier. Lo reviso.

Ya tengo la pieza decisiva del diseño. Esto confirma una **decisión de arquitectura importante** que conviene que valides antes de tocar código. Déjame verificar una última cosa: si rrmm-utils ya tiene capacidad de borrado/reconciliación de `INF3_*` y dónde se consultan los valores ya cumplimentados (`INF2_RM_VALORES`) para la guarda CA-14.

Análisis de diseño completo. He confirmado los dos hechos que condicionan todo BE-07:

1. **El snapshot que usa SIMULAR está normalizado a `id` + `etiqueta`** (`CambioPuestoImpactoItem`) — sirve para diff/preview, pero es **insuficiente para materializar** `INF3_*` (faltan FKs, obligatoriedad, orígenes, parámetros de perfil, etc.).
2. **rrmm-utils ya contiene la lógica real de materialización** del alta (`cargarConfiguracionProtocolosReconocimiento` → decenas de `insertar*PorConfigsIds` / `insertar*ProtocolosPorReconocimiento` en `INF3_RM_*`), y el dry-run preview vive justo al lado. **Pero NO existe lógica de borrado/reconciliación** de `INF3_*` (el alta solo inserta sobre un RM nuevo). La guarda CA-14 se apoyaría en `INF2_RM_VALORES` (valores ya cumplimentados).

Es decir: el applier de BE-07 es trabajo nuevo y sustancial (reconciliar = borrar lo obsoleto + insertar lo nuevo + respetar pruebas con resultados + actualizar periodicidad/fecha). La gran decisión de arquitectura es **dónde vive ese applier**, y como toca un tercer repo y afecta la atomicidad transaccional, prefiero que lo valides antes de escribir nada.

## Opción A — Applier en rrmm-utils (recomendada)

Nuevo endpoint transaccional (p.ej. `POST /rrmm/protocolos/aplicar`, o un modo `apply` del recalcular) que:
- Reutiliza `cargarConfiguracionProtocolosReconocimiento` (la **misma** lógica de inserción del alta) → cumple literalmente el RF §7.2 ("misma lógica funcional que la creación").
- Añade reconciliación: borra `INF3_*` obsoletos **excepto** pruebas/protocolos con valores en `INF2_RM_VALORES` (CA-14) e inserta lo nuevo evitando duplicar lo conservado.
- Actualiza periodicidad / fecha recomendada (RF §7.5).
- `rrmm-backend.confirmar()` lo invoca como paso del flujo.

**Pros:** una sola fuente de verdad, sin duplicar la lógica masiva de inserción, coherente con el dry-run. **Contras:** toca rrmm-utils (rama `feature/20260424_migracion_alta_reconocimiento`) y hay que gestionar la atomicidad entre repos (RL/`INF_RM` en rrmm-backend + `INF3_*` en rrmm-utils).

## Opción B — Applier en rrmm-backend

rrmm-backend pide a rrmm-utils la configuración propuesta **completa** (enriqueciendo el DTO de recalcular) y escribe `INF3_*` él mismo con DAOs nuevos.

**Pros:** transacción única local (atomicidad simple con `INF_RM`/RL). **Contras:** duplica toda la lógica de inserción del alta, alto riesgo de divergencia, y obliga a enriquecer el DTO con todos los metadatos de inserción.

Mi recomendación es la **Opción A**, alineada con el funcional y con la inversión ya hecha en rrmm-utils.

> **¿Qué arquitectura adoptamos para el applier INF3_* de BE-07?**
> - Opción A — Applier en rrmm-utils reutilizando la lógica del alta + reconciliación CA-14 (Recomendado)
> - Opción B — Applier en rrmm-backend escribiendo INF3_* directamente
> - Antes de decidir, quiero un documento de diseño detallado (secuencia, contratos, manejo transaccional) de ambas opciones
>
> Answer: creo que la B, porque la A si no me equivoco esta creando un nuevo reconocimiento desde cero, nosotros ya tenemos reconocimiento creado, estamos cambiando puestos y sus protocolos. Lo que si debemos fijarnos exacatamente como lo hace rrmm-utils para crear el resto de cosas que no sea el reconocimiento, lo que realmente necesitamos nosotros

> **Sobre la atomicidad entre repos (solo aplica a Opción A), ¿qué enfoque prefieres?**
> - Llamar a rrmm-utils (INF3_*) primero y luego mutar RL/INF_RM local; compensar si falla lo local
> - Mutar RL/INF_RM local primero y luego INF3_* remoto; rollback local si falla el remoto
> - Necesito que me expliques los trade-offs antes de elegir
>
> Answer: Other

Antes de arrancar con la Opción B quiero aclararte un matiz técnico importante, porque creo que la premisa para descartar la A no es del todo exacta y puede cambiar tu decisión.

Déjame confirmarlo con el código del alta para no afirmar nada de memoria.

Aclaración importante, porque cambia la premisa con la que descartaste la Opción A:

**`cargarConfiguracionProtocolosReconocimiento` NO crea el reconocimiento.** En el flujo de alta de rrmm-utils son dos pasos separados:

```7:9:c:\Repository\rrmm-utils\src\main\java\com\preving\restapi\rrmmutils\service\reconocimiento\alta\AltaReconocimientoCreacionServiceImpl.java
altaCreacionDao.insertarReconocimiento(...)   // línea 175 — crea INF_RM (el reconocimiento)
...
configuracionProtocolosService.cargarConfiguracionProtocolosReconocimiento(rmId, ...) // línea 220 — rellena INF3_* de ESE rmId
```

Es decir, ese método recibe un `rmId` ya existente y **solo inserta protocolos/pruebas/perfiles/cuestionarios/parámetros/anexos** — exactamente "el resto de cosas que no son el reconocimiento", que es justo lo que necesitamos. La creación del `INF_RM` ocurre antes y por separado.

Por tanto el matiz real, independientemente de A o B, es otro: ese método **solo INSERTA** (asume un RM recién creado y vacío de `INF3_*`). En nuestro caso el RM **ya tiene `INF3_*` materializados**, así que en cualquier opción hay que añadir **reconciliación nueva** (borrar lo obsoleto + insertar lo nuevo + guarda CA-14 sobre `INF2_RM_VALORES`). Eso no existe hoy en ningún sitio.

Con esa corrección, las opciones quedan así:

- **Opción A (refinada):** exponer en rrmm-utils la materialización (`cargarConfiguracion`, que ya hace "insertar todo lo que no es el RM") para un RM pendiente existente + añadir ahí la reconciliación CA-14. Reutiliza tal cual las decenas de `insertar*` que ya están probadas en el alta. Coste: tocar rrmm-utils y coordinar la transacción entre repos.

- **Opción B:** portar a rrmm-backend la lógica de inserción. El problema práctico es que esa lógica (`ConfiguracionProtocolosDao.insertar*`) son **muchísimos INSERT SQL nativos** encadenados (protocolos arrastran pruebas, perfiles, parámetros, cuestionarios, ipromes, parámetros-de-perfil...). Replicar "solo lo necesario" termina siendo casi todo, con alto riesgo de divergir del alta con el tiempo.

Mi recomendación sigue siendo la **A refinada**: no duplicamos la maquinaria de inserción y cumplimos al pie de la letra el RF §7.2 ("misma lógica funcional que la creación"). Pero la decisión es tuya y la respeto.

¿Cómo quieres proceder con esta información corregida?

> **Con la aclaración de que rrmm-utils ya 'inserta todo lo que no es el reconocimiento' (no lo crea), ¿qué opción adoptamos?**
> - Opción A refinada — reutilizar la materialización de rrmm-utils + reconciliación CA-14 (Recomendado)
> - Opción B — portar la inserción INF3_* a rrmm-backend de todas formas
> - Quiero ver primero en detalle qué hacen los insertar* de rrmm-utils antes de decidir
>
> Answer: vale la opcion A entonces seria la buena, pero si tocamos en rrmm-utils no quiero romper nada de esa rama y de ese desarrollo, si tocamos algo debe ser nuevo y reutilizar lo existente, pero no modificar metodos ya creados, es factible?

Sí, es **factible** y además es la forma correcta de hacerlo. El plan respeta tu restricción al 100%:

- **Nada de modificar métodos existentes** de la rama de alta. Reutilizamos `cargarConfiguracionProtocolosReconocimiento` y los `insertar*` **tal cual** (son `public`/invocables), sin tocarlos.
- Todo lo nuevo va en **código nuevo**: un endpoint nuevo (p.ej. `POST /rrmm/protocolos/aplicar`), un método de servicio nuevo, y métodos DAO nuevos solo para la **reconciliación** (lecturas + borrados con guarda CA-14). El alta sigue funcionando exactamente igual.

Hay **un único punto técnico delicado** que debo resolver bien en el diseño para que sea seguro: como `cargarConfiguracion` **solo inserta** (asume RM nuevo y vacío), y nuestro RM **ya tiene `INF3_*`**, hay que orquestar el orden borrar→insertar sin (a) duplicar filas que se conservan y (b) sin perder pruebas con resultados en `INF2_RM_VALORES` (CA-14). Eso depende de cómo estén exactamente los `INSERT` y de la relación `INF3_RM_PRUEBAS` ↔ `INF2_RM_VALORES`.

Para confirmar el diseño sin riesgo necesito estudiar (en solo-lectura) qué hacen exactamente los `insertar*` y esa relación de tablas. Lo hago ahora.

Dato clave: `INF3_RM_PRUEBAS` tiene columna **`BORRADO`** (soft-delete) y la lectura filtra `BORRADO IS NULL`. Eso encaja perfecto con CA-14: la reconciliación puede ser **soft-delete** (marcar `BORRADO`) en vez de borrado físico, preservando historial. Verifico cómo insertan los `insertar*` (si comprueban existencia o duplicarían) y el uso de `BORRADO`, que es el punto que determina todo el diseño de reconciliación.

Los `insertar*` son INSERT puros (los filtros `BORRADO IS NULL` son sobre las tablas de configuración maestra, no sobre las filas del RM). El punto decisivo es si esos INSERT llevan un guard anti-duplicado (`NOT EXISTS` contra `INF3_RM_*`) que evite duplicar al reinvocarlos sobre un RM ya poblado. Lo compruebo en el insert representativo de pruebas.

Ya tengo la respuesta técnica definitiva sobre la viabilidad y el contorno del diseño. Te resumo lo confirmado:

**Los `insertar*` son `INSERT ... SELECT` puros, sin guard anti-duplicado contra `INF3_RM_*`**, y además tienen **dependencia de orden interna** (p.ej. la rama de pruebas por plantilla hace join contra `INF3_RM_PROTOCOLOS` por `:rmId`, así que los protocolos deben existir antes). Conclusión:

- **No se puede** hacer "soft-delete de lo obsoleto + reinvocar `cargarConfiguracion`": duplicaría las filas que se conservan y rompería las dependencias de orden.
- La estrategia segura que **respeta tu restricción** (no tocar métodos existentes, solo añadir código nuevo y reutilizar) es un **rebuild completo**:
  1. Capturar lo protegido por CA-14 (pruebas con resultados en `INF2_RM_VALORES`).
  2. Limpiar **todos** los `INF3_RM_*` del `rmId` (dejar el RM "vacío", que es justo lo que `cargarConfiguracion` asume).
  3. Invocar `cargarConfiguracion` **tal cual** → regenera todo de forma consistente y ordenada.
  4. Re-aplicar CA-14: reincorporar las pruebas cumplimentadas que ya no estén en la nueva config (código nuevo).
  5. Actualizar periodicidad/fecha.

**Esto es 100% factible sin modificar nada existente.** El endpoint nuevo, el servicio nuevo y los DAO de limpieza/CA-14 son código nuevo; `cargarConfiguracion` y los `insertar*` se reutilizan intactos.

Queda **una incógnita de esquema crítica** para garantizar CA-14 sin perder resultados: cómo referencia `INF2_RM_VALORES` a las pruebas — si por `inf3_rm_pruebas.ID` (FK) o por `rm_id + código de prueba`. Vi un comentario en rrmm-utils que apunta a `inf2_rm_valores.prueba_codigo` (clave por código, no por ID), lo cual sería ideal porque los resultados sobrevivirían al rebuild. Necesito confirmarlo antes de dar el diseño por cerrado.

¿Cómo seguimos?

> **Tengo la viabilidad y la estrategia (rebuild + CA-14). ¿Qué hago ahora?**
> - Investigar la relación INF2_RM_VALORES ↔ INF3_RM_PRUEBAS y cerrar el diseño CA-14 (Recomendado) ✔
> - Escribir un documento de diseño técnico completo de BE-07 (endpoint, servicio, DAOs, secuencia, tests) para revisarlo antes de codificar
> - Empezar a implementar ya el endpoint nuevo + servicio + reconciliación (te iré pidiendo confirmación por archivo)
> - Parar aquí; con el contexto recuperado ya es suficiente por ahora

Investigo la relación `INF2_RM_VALORES` ↔ `INF3_RM_PRUEBAS` para cerrar el diseño de CA-14. Busco todos los usos de esa tabla y cómo se detecta una prueba "ya realizada".

Los `INF2_RM_VALORES` con `prueba_codigo` son los valores de formularios estructurados (anamnesis, hábitos, control visión), clave por `rm_id + código`. Para CA-14 necesito entender cómo se marca una prueba como "realizada/con resultado" y dónde se guardan esos resultados, para saber qué sobrevive a un rebuild. Reviso cómo se detecta una prueba realizada y el patrón de anulación (soft-delete) del alta.

Modelo de datos aclarado: las pruebas se configuran en `INF3_RM_PRUEBAS`; "anular" no borra, sino que inserta en `INF_PRUEBAS_ANULADAS` (reversible); y los resultados viven en tablas aparte (`INF2_RM_VALORES` por `rm_id + código`, más tablas de resultado por tipo). Como los resultados **no** se referencian por `inf3_rm_pruebas.ID`, sobreviven al rebuild. Falta la pieza canónica: cómo se detecta que una prueba está "realizada/con resultado". Busco si ya existe esa consulta para reutilizarla.

He cerrado el diseño de CA-14 a nivel estructural. Resumen de lo confirmado y la conclusión.

## Modelo de datos relevante (confirmado en código)

- **Configuración de pruebas del RM:** `INF3_RM_PRUEBAS (RM_ID, PRUEBA_ID, PROTOCOLO_ID, ORIGEN_ID, MANUAL, BORRADO, …)`. Es lo que regenera `cargarConfiguracion`.
- **Resultados/valores cumplimentados:** `INF2_RM_VALORES (RM_ID, PRUEBA_CODIGO, VALOR_ID, SUB_VALOR_ID, TEXTO, …)`. Clave funcional = **`RM_ID + PRUEBA_CODIGO`** (no por `inf3_rm_pruebas.ID`).
- **El código de prueba** que enlaza ambos mundos es `INF3_PRUEBAS.CODIGO_PRUEBA` (ya lo usa `getImpactoPruebasByRmId` en rrmm-backend).
- **Anulación** de prueba ≠ borrado: inserta en `INF_PRUEBAS_ANULADAS` (reversible vía `REACTIVADA`).

## Conclusión clave para CA-14

**Los resultados (`INF2_RM_VALORES`) NO dependen del `ID` de `INF3_RM_PRUEBAS`**, sino de `RM_ID + PRUEBA_CODIGO`. Por tanto, **un rebuild de `INF3_RM_*` NO destruye los resultados** mientras no se toque `INF2_RM_VALORES`. Esto valida la estrategia de rebuild:

1. **No tocar nunca** `INF2_RM_VALORES` ni `INF_PRUEBAS_ANULADAS` (ahí viven resultados y anulaciones → CA-14 garantizado a nivel de datos).
2. Calcular el conjunto de **"pruebas realizadas"** = pruebas del RM cuyo `CODIGO_PRUEBA` tiene filas en `INF2_RM_VALORES` (más, si aplica, resultados de analítica/exploración en sus tablas específicas).
3. Limpiar `INF3_RM_*`, invocar `cargarConfiguracion` (regenera la nueva config).
4. **Re-incorporar en `INF3_RM_PRUEBAS`** las pruebas realizadas que la nueva config ya no incluya (como `MANUAL=1`/origen conservación), para que sigan **visibles** en el reconocimiento junto con sus valores intactos.
5. Actualizar periodicidad/fecha.

## Definición canónica de "prueba realizada" (a precisar en implementación)

La definición principal es **"tiene valores en `INF2_RM_VALORES` por `CODIGO_PRUEBA`"**. El único fleco pendiente es **enumerar las tablas de resultado adicionales** (analítica, exploraciones específicas, espirometría, etc.) que también cuentan como "realizada" para no dejar fuera ningún tipo de prueba. Eso es trabajo de detalle de implementación, pero no cambia la arquitectura.

---

El diseño de BE-07 (Opción A refinada, rebuild + CA-14 por preservación de `INF2`) queda **cerrado y validado**, sin necesidad de modificar nada existente en rrmm-utils. ¿Siguiente paso?

> **Diseño de BE-07 cerrado. ¿Por dónde seguimos?**
> - Escribir el documento de diseño técnico de BE-07 (endpoint, servicio, DAOs nuevos, secuencia, tests, plan de pruebas DEMO) (Recomendado) ✔
> - Antes, enumerar todas las tablas de resultado para fijar la definición exacta de 'prueba realizada'
> - Empezar a implementar (endpoint + servicio + reconciliación), pidiendo confirmación por archivo
> - Parar aquí por ahora

Voy a escribir el documento de diseño técnico de BE-07. Primero miro la estructura de carpetas para ubicarlo según las convenciones existentes.

Lo ubico en `cambios-pueesto/entrega-cambio-puesto/` junto a los demás documentos técnicos. Escribo el documento de diseño de BE-07.

Documento de diseño creado en `cambios-pueesto/entrega-cambio-puesto/Diseno_Tecnico_BE-07_Applier_INF3.md`.

Resumen de lo que contiene:

- **Objetivo y contexto** de BE-07 (materializar `INF3_*` en CONFIRMAR, hoy ausente).
- **Decisión arquitectónica** (Opción A refinada) y la **restricción** de no tocar métodos existentes de rrmm-utils.
- **Hechos verificados en código** que condicionan el diseño (inserts sin guard anti-duplicado + dependencias de orden → rebuild completo; resultados en `INF2_RM_VALORES` por `RM_ID + CODIGO_PRUEBA` → sobreviven al rebuild).
- **Estrategia rebuild + preservación CA-14** paso a paso.
- **Contrato del endpoint nuevo** `POST /rrmm/protocolos/aplicar` (request/response/códigos).
- **Clases nuevas** en rrmm-utils y rrmm-backend (todo nuevo, reutilizando lo existente).
- **Definición de "prueba realizada"** con la query base por `CODIGO_PRUEBA`.
- **Secuencia en `confirmar()`** y un apartado crítico de **atomicidad entre repos** (§7.1) con 3 opciones.
- **Plan de pruebas** (unitarias + validación manual DEMO con los datos del handoff) y **riesgos**.

Quedan **dos decisiones abiertas** marcadas explícitamente en el documento, que conviene cerrar antes de implementar:

1. **Orden/compensación entre repos** (§7.1): remoto-primero vs local-primero vs idempotencia+reintento. Mi recomendación es apoyarse en que el rebuild es **idempotente** (Opción 3), que es la base más robusta.
2. **Enumerar las tablas de resultado** adicionales (analítica, espirometría, audiometría, exploraciones…) para fijar la definición fina de "prueba realizada" en CA-14.

¿Quieres que cerremos esas dos decisiones ahora, o prefieres revisar primero el documento y darme feedback antes de avanzar a implementación?

---

**User**

1. tu recomendacion de idempotente. 2. si procede

---

**Cursor**

Perfecto: 1) fijamos el enfoque **idempotente** y 2) procedo a enumerar las tablas de resultado. Primero investigo dónde se guardan los resultados de cada tipo de prueba para fijar la definición exacta de "prueba realizada".

`ResultadoDaoImpl` confirma que la mayoría de "tiene resultado" se chequea contra `inf2_rm_valores` por `prueba_codigo`. Falta la analítica (que suele ir en tabla aparte) y la lógica canónica del menú de pruebas (realizada/pendiente). Lo investigo.

Tengo el mapa de almacenes de resultado. Confirmo dos piezas: dónde están los **valores de analítica** (resultados de parámetros/perfiles) y las **respuestas de cuestionarios**, para enumerar todo con precisión.

Hallazgo clave: `ReconocimientoDaoImpl` tiene una rutina de borrado integral del RM que enumera **todas** las tablas (líneas 1222, 1583 `INF_RESULTADOS` por `RES_RM_ID`, 1687 `INF2_RM_VALORES`). Esa es la lista canónica que necesito tanto para la limpieza del rebuild como para identificar las tablas de resultado a proteger. La leo.

Esta es la lista canónica de borrado por tabla. Capturo el conjunto completo de métodos `borrar*` para enumerar con precisión las tablas de configuración (a limpiar) vs. las de resultado (a proteger en CA-14).

Ahora tengo el mapa completo y autoritativo de tablas. Esto me permite una distinción precisa entre **tablas de configuración** (que el rebuild limpia) y **tablas de resultado** (que CA-14 protege). Actualizo el documento de diseño: fijo el enfoque idempotente, refino la limpieza y completo la definición de "prueba realizada".

Ahora actualizo el documento. Primero la estrategia de limpieza (§3 paso 2) para listar exactamente las tablas de configuración:

Ahora reemplazo la §6 completa con la enumeración precisa y la definición fina:

Ahora fijo el enfoque idempotente en §7.1 (decisión tomada):

Actualizo la tabla de riesgos (§10) y el resumen ejecutivo (§11) para reflejar las decisiones cerradas:

Listo. Marco las tareas como completadas.

He cerrado las dos decisiones en el documento de diseño. Resumen de los cambios:

## 1. Atomicidad → applier idempotente (§7.1)

Decisión fijada: el applier de rrmm-utils se diseña **idempotente** (siempre limpia `INF3_RM_*` y regenera → N ejecuciones ≡ 1). Implicaciones que añadí:
- **Orden:** local primero (RL + `INF_RM` + adicionales) y remoto al final.
- **Fallo del remoto:** rollback local → no queda nada aplicado → reintento seguro.
- **Fallo posterior:** reintentar `CONFIRMAR` reaplica al mismo estado, sin duplicados.
- Se renuncia explícitamente a transacción distribuida: **consistencia eventual por reintento idempotente** + rollback local + el hecho de que las tablas de resultado nunca se tocan.

## 2. Tablas de resultado enumeradas (§6, reescrita)

Extraje el **mapa autoritativo** de la rutina de borrado integral del RM (`ReconocimientoDaoImpl.borrar*`) y lo clasifiqué:

- **§6.1 — Configuración (el rebuild limpia, 8 tablas):** `INF3_RM_PROTOCOLOS/PRUEBAS/PERFILES/PARAMETROS/CUESTIONARIOS/IPROMES/ANEXOS/PRODUCTOS_QUIMICOS`.
- **§6.2 — Resultado (CA-14, nunca se tocan, ~20 tablas):** `INF2_RM_VALORES`, `INF_RESULTADOS`, `INF_ESTUDIOS_ANALITICOS`, `CUES_RM_VALORES`, `INF_AUDIOMETRIA`, `INF_ESPIROMETRIA`, `INF_ELECTRO`, `INF_EXPLORACION`, `INF3_IRC`, `INF_AGUDEZAVISUAL`, `INF_ANAMNESIS`, `INF_HABITOS`, etc.
- **§6.3 — Anulaciones (no se tocan):** `INF_PRUEBAS_ANULADAS`, `INF_CUESTIONARIO_ANULADOS`.

**Conclusión clave (§6.4):** como el rebuild limpia **solo** las 8 tablas de configuración y **nunca** las de resultado, **ningún dato clínico se pierde por construcción**. La detección de "prueba realizada" (§6.5) ya no protege datos —que están a salvo—, sino que solo decide la **visibilidad** (re-añadir la fila de config si la nueva config la excluye). Esto desactiva el riesgo de la tarea.

También actualicé la estrategia (§3 paso 2), la tabla de riesgos (§10) y el resumen ejecutivo (§11).

El diseño de BE-07 queda **cerrado** y listo para implementar. El único fleco es de verificación, no de diseño: confirmar en DEMO el mapeo por tipo de los `EXISTS` de detección con un RM que tenga resultados de cada tipo de prueba.

¿Avanzamos a la **implementación** (empezando por el endpoint `/aplicar` + servicio de reconciliación en rrmm-utils, pidiéndote confirmación por archivo), o prefieres revisar antes el documento actualizado?

---

**User**

necesito que me expliques mejor lo del rebuild

---

**Cursor**

Te lo explico de forma clara y con un ejemplo concreto.

## El problema de partida

Cuando el usuario **confirma** un cambio de puesto, hay que recalcular los protocolos del reconocimiento. El problema es que ese reconocimiento (RM) **ya tiene datos del puesto anterior** en las tablas `INF3_RM_*`:

```
RM 12341907 (puesto ANTIGUO 116267) ya tiene en BD:
  INF3_RM_PROTOCOLOS  → 6 protocolos
  INF3_RM_PRUEBAS     → 52 pruebas
  INF3_RM_PARAMETROS  → 50 parámetros
  INF3_RM_PERFILES    → 2 perfiles
  INF3_RM_CUESTIONARIOS → 5 cuestionarios
```

Al cambiar al puesto nuevo, la configuración correcta podría ser, por ejemplo, 7 protocolos / 53 pruebas / etc. Hay que dejar la BD reflejando lo del puesto **nuevo**.

## Por qué NO hacemos un "diff incremental"

La forma intuitiva sería: *"calcula qué sobra y bórralo, calcula qué falta y añádelo"*. **No funciona** por dos razones que verifiqué en el código de rrmm-utils:

1. **Los `INSERT` no comprueban duplicados.** Los métodos `insertar*` del alta son `INSERT ... SELECT` puros. Si los lanzas sobre un RM que ya tiene filas, **duplican** lo que ya estaba (acabarías con la prueba X dos veces).
2. **Hay dependencias de orden internas.** Por ejemplo, el insert de pruebas-por-plantilla hace un `JOIN` contra `INF3_RM_PROTOCOLOS` por `rmId`: necesita que los protocolos ya estén insertados. Si borras protocolos a media reconciliación, rompes el cálculo de las pruebas.

En resumen: la maquinaria de inserción del alta **asume un RM vacío y limpio**. No está pensada para "parchear" un RM ya poblado.

## Qué es el rebuild

En vez de parchear, **reconstruimos desde cero** la configuración, exactamente como hace el alta. La secuencia es:

```
1. BORRAR  las 8 tablas de CONFIGURACIÓN del RM  → INF3_RM_* queda vacío
2. LLAMAR  cargarConfiguracionProtocolosReconocimiento(rmId, puesto NUEVO + adicionales)
           → reinserta TODO desde cero, consistente y en el orden correcto
3. (CA-14)  re-añadir visibilidad de pruebas realizadas que el puesto nuevo ya no incluya
4. Actualizar periodicidad / fecha recomendada
```

Es decir: **"borrón y cuenta nueva"** sobre las tablas de configuración, reutilizando intacta la lógica del alta (que ya sabe insertar todo bien). Por eso no duplicamos código ni tocamos métodos existentes de rrmm-utils.

## La clave: ¿no perdemos los resultados ya registrados? (CA-14)

Aquí está lo importante, y es lo que hace que el rebuild sea seguro. Las tablas de la BD se dividen en dos grupos:

| Grupo | Ejemplos | El rebuild... |
|-------|----------|---------------|
| **Configuración** (qué pruebas/protocolos *toca hacer*) | `INF3_RM_PROTOCOLOS`, `INF3_RM_PRUEBAS`, `INF3_RM_PARAMETROS`... | **borra y regenera** |
| **Resultado** (lo que el sanitario *ya rellenó*) | `INF2_RM_VALORES`, `INF_RESULTADOS`, `INF_AUDIOMETRIA`, `INF_ESPIROMETRIA`... | **NO se tocan jamás** |

Los resultados **no se referencian por el `ID` de la fila de configuración**, sino por `RM_ID + código de prueba`. Así que aunque borremos y recreemos la fila de configuración de una prueba, su resultado sigue intacto en su propia tabla y **vuelve a enlazar solo** por el código.

> Ejemplo: el sanitario ya hizo una audiometría (resultado en `INF_AUDIOMETRIA`). Cambiamos a un puesto que no requiere audiometría. El rebuild borra/regenera `INF3_RM_*`, pero **`INF_AUDIOMETRIA` ni se mira** → el resultado de la audiometría sigue ahí.

## El paso 3 (visibilidad)

Tras el rebuild, una prueba que el sanitario ya hizo pero que el puesto nuevo **ya no incluye** desaparecería de la lista de configuración (su `INF3_RM_PRUEBAS` se borró y no se regenera). El resultado no se pierde (está en su tabla), pero para que la prueba **siga apareciendo** en el reconocimiento, le volvemos a poner su fila en `INF3_RM_PRUEBAS` marcada como "conservada" (`MANUAL=1`). Eso es lo único que hace la detección de "prueba realizada": decidir **qué reaparece**, no proteger datos (los datos ya están a salvo).

## Por qué es idempotente

Como el rebuild **siempre empieza limpiando** y regenera desde cero, ejecutarlo 1 vez o 5 veces deja **exactamente el mismo resultado**. Eso es lo que nos permite reintentar `CONFIRMAR` con seguridad si algo falla a mitad, sin acumular duplicados ni dejar estados raros — y por eso no necesitamos una transacción distribuida entre rrmm-backend y rrmm-utils.

---

En una frase: **el rebuild tira la "lista de tareas" del puesto viejo y la regenera para el puesto nuevo usando el mismo motor que el alta, sin tocar nunca lo que el sanitario ya rellenó.**

¿Quieres que te enseñe el flujo con un diagrama, o que detalle alguna parte en concreto (p. ej. cómo se decide exactamente qué pruebas "reaparecen")?

---

**User**

no todo claro

---

**Cursor**

Perfecto. Entonces el diseño de BE-07 queda cerrado y entendido.

¿Cómo seguimos?

- **Implementar** ya BE-07, empezando por rrmm-utils (endpoint `/aplicar` + servicio de reconciliación + DAOs de limpieza/CA-14), pidiéndote confirmación por archivo.
- **Revisar** primero el documento de diseño actualizado y darme feedback antes de tocar código.
- **Pausar** aquí y retomar otra tarea pendiente del sprint (BE-10 ACL, BE-11 warnings, etc.).

Dime por dónde tiramos.

---

**User**

empecemos a implementar, buenas practicas, trazabilidad, clean code, robustez

---

**Cursor**

Vamos a implementar BE-07 con cuidado: clean code, trazabilidad y robustez. Empezaré por **rrmm-utils** (el productor: endpoint `/aplicar` + servicio de reconciliación), porque rrmm-backend depende de su contrato. Como toco un repo con la restricción de no romper nada existente, primero leo las estructuras que voy a reutilizar/imitar para encajar con el estilo del proyecto, y luego te presento el plan concreto de archivos antes de escribir.

Déjame localizar las rutas exactas (el glob no está indexando bien este repo).

Los archivos existen. Leo las estructuras clave que voy a reutilizar/imitar.

Ahora veo que el `recalcularConfiguracionProtocolos` (dry-run) reconstruye el `cmd` desde el contexto del RM sin escribir, mientras que el método de escritura `cargarConfiguracionProtocolosReconocimiento` necesita además `tipo` y `entidadId`. Necesito ver cómo el alta resuelve esos dos para replicarlo correctamente en el applier. Leo la cabecera del servicio de alta y la interfaz del DAO.

Descubrimiento importante: el alta no materializa solo con `cargarConfiguracion` — también inserta los elementos **ACP** y la **periodicidad** en pasos separados, y el dry-run (que el usuario ve en el resumen) **sí incluye ACP**. Para que el applier coincida con el preview, debo replicar la secuencia completa. Leo esa parte del alta para capturar el orden exacto (ACP + periodicidad) y ver qué métodos existentes reutilizar.

El alta materializa en 3 bloques reutilizables: (1) `cargarConfiguracionProtocolosReconocimiento`, (2) periodicidad, (3) `acpReconocimientoService.cargarElementosAcp(...)` para ACP. El dry-run que ve el usuario incluye ACP, así que el applier debe replicar esos 3 bloques. Necesito confirmar qué hace exactamente `cargarElementosAcp` (si solo inserta config ACP o también toca médico coordinador/MT), porque eso define el alcance y tiene implicaciones de negocio. Lo reviso.

Ya tengo el modelo completo de materialización del alta y confirmo que es **reutilizable sin modificar nada**:

- **Config por puesto** → `configuracionProtocolosService.cargarConfiguracionProtocolosReconocimiento(...)` (existente)
- **ACP** → `acpReconocimientoService.cargarElementosAcp(...)` (existente) — inserta los elementos ACP en `INF3_*` y devuelve metadatos. El update de médico coordinador es un método **aparte** (`actualizarReconocimientoConAcp`), así que puedo materializar ACP sin tocar médicos.
- **Periodicidad** → `tieneConfiguracionReconocimientosPeriodicidad` + `obtenerPeriodicidadProtocolos` + `actualizarPeriodicidadReconocimiento` (existentes)
- **Contexto del RM** → `getReconocimientoContextoByRmId`, `getCentroClienteMp2`, `getReconocimientoTipoById` (existentes, ya usados por el dry-run)

Antes de tocar archivos (regla: pregunto antes de modificar), te dejo el **plan concreto en rrmm-utils** y 3 decisiones de negocio que quiero cerrar contigo, porque afectan a datos clínicos.

## Archivos en rrmm-utils (4 nuevos + 1 método nuevo)

1. **NUEVO** `domain/rm/alta/AplicarProtocolosRequest.java` — espejo de `RecalcularProtocolosRequest` (`rmId`, `puestoId`, `tipoPuesto`, `puestosAdicionales`).
2. **NUEVO** `domain/rm/alta/AplicarProtocolosResponse.java` — resumen de la materialización (nº protocolos/pruebas/perfiles/parámetros/cuestionarios insertados, periodicidad aplicada, **pruebas realizadas preservadas** por CA-14).
3. **NUEVO** `dao/reconocimiento/reconciliacion/ReconciliacionProtocolosDao(+Impl)` — (a) limpieza SOLO de tablas de configuración `INF3_RM_*`, (b) detección de pruebas realizadas (CA-14), (c) reinserción de visibilidad de las realizadas que no estén en la nueva config. Estilo `NamedParameterJdbcTemplate` + `@Qualifier` igual que los DAOs existentes.
4. **NUEVO** `service/reconocimiento/reconciliacion/AplicarProtocolosReconocimientoService(+Impl)` — orquesta, `@Transactional`, idempotente. Reutiliza los métodos existentes citados arriba (no los modifica).
5. **MÉTODO NUEVO** en `web/ProtocolosReconocimientoController.java` — `POST /rrmm/protocolos/aplicar` (no toco el `/recalcular` existente).

## Secuencia del applier (transaccional)
`resolver contexto RM` → `capturar pruebas realizadas (CA-14)` → `limpiar INF3_* config` → `cargarConfiguracionProtocolosReconocimiento` → `cargarElementosAcp` (ACP) → `periodicidad` → `reinsertar visibilidad de realizadas faltantes` → `devolver resumen`.

## 3 decisiones a confirmar

**Decisiones de alcance del applier BE-07**

> **Médico coordinador / médico del trabajo: ¿el applier debe mantener los del RM (no re-resolver), igual que el dry-run que ya viste en el resumen?**
> - Mantener MC/MT del RM, no re-resolver (Recomendado: coincide con el preview y no altera asignaciones clínicas) ✔
> - Re-resolver MC/MT como en el alta (cambiaría médicos asignados al confirmar)

> **ACP: ¿materializar los elementos ACP (cargarElementosAcp) sin actualizar los metadatos de médico coordinador del RM?**
> - Sí, materializar elementos ACP sin tocar metadatos MC (Recomendado: coincide con el preview) ✔
> - No materializar ACP (solo protocolos por puesto)
> - Materializar ACP y además actualizar MC del RM con el del ACP

> **Versión de configuración a usar al reinsertar las filas INF3_*: ¿la versión del propio RM (ctx.version) para mantener consistencia, o la versión global de alta?**
> - Versión del RM existente (ctx.version) (Recomendado: consistencia con las filas del reconocimiento) ✔
> - Versión global de alta (versionReconocimientos)

Decisiones cerradas: mantener MC/MT, materializar ACP sin tocar MC, y usar `ctx.version`. 

Ahora, para escribir el DAO de limpieza y el servicio con precisión, necesito: (1) los nombres exactos de las tablas `INF3_RM_*` de configuración y sus columnas RM_ID, (2) cómo el dry-run construye el `cmd` desde el contexto (para imitarlo), (3) el estilo de un DAO existente, y (4) las firmas de `getReconocimientoContextoByRmId/getCentroClienteMp2/getReconocimientoTipoById`. Leo todo en paralelo, más el mapa CA-14 que ya dejé en el diseño.

Tablas de configuración identificadas. Verifico el set completo de tablas `INF3_RM_*` (incluyendo anexos si existe) en todo el repo y reviso cómo el dry-run construye el `cmd` desde el contexto, más el estilo de un DAO existente y las firmas de los getters de contexto.

---

**User**

Decisiones cerradas: mantener MC/MT, materializar ACP sin tocar MC, y usar ctx.version. De esto que pone en el funcional?

---

**Cursor**

Buena pregunta. Vamos a contrastar esas tres decisiones con lo que dice el funcional, en lugar de asumir. Busco en el RF las menciones a médico coordinador / médico del trabajo, ACP y versión.

Tengo lo que necesito. Leo el contexto exacto de las secciones del funcional relevantes (recálculo = creación, ACP y periodicidad) para citarlas con precisión.

Contrastado con el RF v6. Esto es lo que dice el funcional sobre cada decisión:

## 1. Mantener MC/MT (médico coordinador / médico del trabajo)
El funcional **no menciona en ningún punto** al médico coordinador ni al médico del trabajo. El alcance del recálculo está acotado en §7.2 a lo que debe recuperar "como mínimo":

> "Protocolos y pruebas que proceden de la configuración de puestos de trabajo. / Protocolos, pruebas, parámetros, perfiles, cuestionarios y observaciones que proceden de configuración ACP… / Periodicidad resultante y fecha recomendada… / Elementos que deben incorporarse, mantenerse o dejar de aplicar…" (líneas 232‑235)

No hay nada sobre reasignar médicos. → **Decisión "mantener MC/MT" es coherente con el funcional** (re-resolverlos sería ampliar alcance no pedido).

## 2. Materializar ACP sin tocar MC
ACP **sí es obligatorio** y está explícito en §7.2 (línea 233): hay que materializar protocolos, pruebas, parámetros, perfiles, cuestionarios **y observaciones** que proceden de ACP (cliente, centro, puesto o trabajador). Pero el funcional solo pide los **elementos de configuración** del ACP, no el médico que el ACP pudiera arrastrar. → **Materializar ACP sin actualizar metadatos MC es coherente.**

⚠️ Matiz a verificar: la línea 233 incluye **"observaciones"** como elemento ACP. Debo confirmar que `cargarElementosAcp` las inserta y en qué tabla, para incluirla en la limpieza del rebuild y no dejar observaciones obsoletas.

## 3. Usar ctx.version
El funcional **no dice nada** de versión de configuración (las únicas "versiones" del doc son las del propio documento). Es una decisión puramente técnica y **no contradice** nada. Además, §7.2 y §7.5 insisten en usar *"la misma lógica funcional que utiliza en la creación del reconocimiento"* — y usar la versión del propio RM es justo lo correcto para que las filas reconstruidas queden consistentes con el reconocimiento existente.

## Refuerzo clave del funcional a nuestra estrategia
La parte más importante (CA-14, base del rebuild + preservación):

> §7.1 (línea 225): "Las pruebas ya realizadas y resultados registrados **no se eliminan** aunque el protocolo que los originó deje de aplicar."
> §7.4 (líneas 254‑256): "Las pruebas ya cumplimentadas se mantienen **siempre** en el reconocimiento, aunque el nuevo puesto o la nueva configuración ya no las requiera."

Esto valida directamente nuestra estrategia de rebuild de `INF3_*` + reinserción de realizadas.

Y la frase que justifica todo el enfoque de reutilizar el alta — §7.2 (línea 231): *"MINERVA debe ejecutar la misma lógica funcional que utiliza en la creación del reconocimiento"* (y reforzado en el changelog v6, línea 29: *"la llamada funcional de recálculo equivalente a la creación del reconocimiento"*).

---

**Resumen:** las 3 decisiones son coherentes con el funcional; ninguna lo contradice. Solo queda el matiz de **"observaciones" del ACP** (línea 233) que conviene verificar antes de codificar la limpieza, para que el rebuild no deje observaciones huérfanas. ¿Quiero que verifique cómo `cargarElementosAcp` trata las "observaciones" y luego arrancamos con la creación de archivos (empezando por los DTOs `AplicarProtocolosRequest/Response`)?

---

**User**

si verifica

---

**Cursor**

Verifico cómo `cargarElementosAcp` trata las "observaciones" y en qué tabla las inserta, para incluirlas en la limpieza del rebuild si procede.

"Observaciones" del ACP aparecen como campos a nivel de `inf_rm` (`acp_obs_ia`, `observacion_acp`) en un UPDATE. Necesito ver si eso lo escribe `cargarElementosAcp` o el `actualizarReconocimientoConAcp` (que decidimos NO llamar), porque ahí puede haber un conflicto con el funcional. Leo el contexto del DAO y el servicio.

Verificado, y hay un hallazgo importante que **matiza la decisión 2**.

## Qué hace cada método con el ACP

`cargarElementosAcp` (el que íbamos a reutilizar) **solo inserta los elementos de configuración** del ACP en `INF3_*`:

```57:96:c:\Repository\rrmm-utils\src\main\java\com\preving\restapi\rrmmutils\service\reconocimiento\alta\AcpReconocimientoServiceImpl.java
    public Acp cargarElementosAcp(int rmId, CrearReconocimientoCommand cmd, int cliMp2Id,
                                  int clienteGcId, int centroGcId,
                                  int userVigId, int versionReconocimiento) {
        ...
            if (!protocolosIds.isEmpty()) {
                acpDao.insertarConfiguracionesAcpProtocolos(rmId, protocolosIds, userVigId, versionReconocimiento);
            }
            ... // cuestionarios, pruebas, perfiles, parámetros
        return acpMetadata;
    }
```

Las **"observaciones" del ACP** (que el funcional §7.2 línea 233 pide recuperar) **no** están aquí. Se escriben a nivel de `inf_rm` y **solo** las escribe `actualizarReconocimientoConAcp`, junto con MC y MT en el **mismo UPDATE**:

```364:378:c:\Repository\rrmm-utils\src\main\java\com\preving\restapi\rrmmutils\dao\reconocimiento\alta\AcpReconocimientoDaoImpl.java
    public void actualizarReconocimientoConAcp(int reconocimientoMedicoId, Acp acp, Integer mcVigId) {
        String sql = "UPDATE vig_salud.inf_rm SET " +
              "  mt_valida = :mtVigId, periodicidad_ver_ia = :periodicidadVerIa, mc_id = :mcVigId, " +
              "  acp_id = :acpId, acp_tipo_id = :acpTipoId, acp_obs_ia = :acpObsIa, observacion_acp = :observacion " +
              "WHERE rm_id = :reconocimientoMedicoId";
        ...
    }
```

## El conflicto
Ese UPDATE mete en una sola sentencia: **MC** (`mc_id`), **MT** (`mt_valida`) **y** las observaciones/referencia ACP (`acp_id`, `acp_tipo_id`, `acp_obs_ia`, `observacion_acp`).

- Si **lo llamamos** → recuperamos las observaciones ACP ✅ pero **sobrescribimos MC/MT** ❌ (rompe decisión 1).
- Si **NO lo llamamos** → respetamos MC/MT ✅ pero el RM se queda con el **ACP y observaciones antiguos** ❌ (incumple §7.2 línea 233 y "dejar de aplicar" de línea 235).

## Propuesta (coherente con el funcional y con la restricción de no modificar lo existente)
Crear un **método DAO nuevo** (no toco `actualizarReconocimientoConAcp`) que actualice **solo** los campos ACP, preservando `mc_id` y `mt_valida`:

- Si hay ACP aplicable: `SET acp_id, acp_tipo_id, acp_obs_ia, observacion_acp` (y `periodicidad_ver_ia` por ser display del ACP).
- Si **no** hay ACP aplicable tras el cambio: limpiar esos campos (`acp_id = NULL`, `observacion_acp = NULL`, etc.) → cumple "dejar de aplicar".
- **Nunca** toca `mc_id` ni `mt_valida`.

Esto cumple las 3 decisiones + el funcional completo (incluidas las observaciones).

¿Confirmas este ajuste (nuevo método DAO `actualizarAcpMetadataSinMedicos` que refresca/limpia solo los campos ACP del `inf_rm` sin tocar MC/MT) y arrancamos ya creando los archivos, empezando por los DTOs `AplicarProtocolosRequest`/`AplicarProtocolosResponse`?

---

**User**

pero si el update hace eso ya y el funcional nos ha dicho de seguir el proceso de alta, entiendo que deberiamos seguirlo no?

---

**Cursor**

Tienes razón en el principio —el funcional manda "seguir la lógica del alta"— pero conviene mirar **qué dice exactamente** y **qué implica técnicamente**, porque ahí está el matiz.

## Qué dice el funcional (alcance de "misma lógica")
§7.2 línea 231 acota la frase:

> "…la misma lógica funcional que utiliza en la creación del reconocimiento **para consultar la configuración aplicable** al cliente, centro, puesto principal y puestos adicionales…"

Y la lista "como mínimo" (líneas 232‑235) es: configuración de puestos, configuración ACP (protocolos/pruebas/parámetros/perfiles/cuestionarios/**observaciones**) y periodicidad/fecha. **MC y MT no aparecen** en ningún punto del documento. Es decir, el funcional ata "misma lógica" a **resolver la configuración**, no a reasignar médicos.

## Qué implica "seguir el alta" para MC/MT (el riesgo real)
En el alta, el `actualizarReconocimientoConAcp` no escribe un MC "neutro": el MC se resuelve **a partir del `auth` del usuario** que ejecuta la operación + centro, y solo se sobrescribe por ACP si aplica:

- línea 145: `puedeResolverMedicoCoordinador = !esExtraccionPrevia && !auth.isExterno()`
- línea 152: `medicoCoordinador = resolverMedicoCoordinador(auth, centroMp2, entidadId)`
- el MT (`mt_valida`) sale de `acp.getMedicoTrabajoVigId()`.

Esto significa que si replicamos el alta tal cual en el **CONFIRMAR**, el MC del reconocimiento existente se **recalcularía según quién confirma el cambio de puesto** (y su rol/centro). En un RM ya creado, eso puede **reasignar el coordinador/médico** a otra persona como efecto colateral no pedido por el funcional. Además, arrastra más lógica del alta (resolución de MC por ACP, gestión de config SPA, MT por provincia, productos químicos IA…), ampliando bastante la superficie y el riesgo.

## Mi lectura
- Lo que el funcional **sí** exige recuperar y que hoy va en ese UPDATE: `acp_id`, `acp_tipo_id`, `acp_obs_ia`, `observacion_acp` (las "observaciones" del ACP). Eso **debemos** refrescarlo.
- Lo que el funcional **no** pide y es clínicamente sensible: reasignar `mc_id`/`mt_valida` en función de quién confirma.

Por eso el método nuevo "solo campos ACP" no es saltarse el alta: es **seguir el alta en lo que el funcional pide** (observaciones/refrencia ACP) y **no introducir** un efecto (reasignación de médicos por el usuario que confirma) que el funcional nunca pidió.

Dicho esto, es una decisión de negocio. ¿Cómo lo quieres?

**MC/MT en el CONFIRMAR**

> **En el CONFIRMAR del cambio de puesto, ¿qué hacemos con MC (médico coordinador) y MT (médico del trabajo) al refrescar el ACP?**
> - Refrescar SOLO campos ACP (acp_id/tipo/obs/observacion) y preservar MC/MT (Recomendado: cumple el funcional íntegro sin reasignar médicos por el usuario que confirma)
> - Seguir el alta tal cual: re-resolver MC desde el auth del que confirma y MT desde ACP (más fiel al 'mismo proceso', pero puede reasignar médicos del RM y añade bastante lógica/riesgo)
> - Punto medio: preservar MC/MT salvo que el ACP aporte uno (si ACP trae MC/MT, aplicarlo; si no, mantener el del RM)
>
> Answer: creo qeu el A, pero seria en metodo nuevo no?

Perfecto: **opción A en método nuevo**. Cierro así las decisiones:

1. **MC/MT**: se preservan (no se tocan).
2. **ACP**: se materializan los elementos con `cargarElementosAcp` (existente) **+** un **método DAO nuevo** que refresca solo los campos ACP de `inf_rm` (`acp_id`, `acp_tipo_id`, `acp_obs_ia`, `observacion_acp`, `periodicidad_ver_ia`) y los limpia si ya no aplica ACP — **sin tocar** `mc_id`/`mt_valida`.
3. **Versión**: `ctx.version`.

Arranco creando los DTOs en rrmm-utils.

Para el DAO necesito reusar mi análisis de CA-14 (mapa de tablas de resultados) del diseño técnico y el estilo de inyección/datasource de un DAO existente. Los leo.

Tengo el diseño completo. Antes de escribir el DAO necesito confirmar dos cosas concretas en la BD/SQL existente: (1) si `INF3_RM_ANEXOS` realmente existe y se asocia por `RM_ID` (para no hacer un DELETE sobre una tabla inexistente), y (2) las columnas exactas de `INF3_RM_PRUEBAS` para la reinserción manual de las pruebas conservadas (CA-14).

Hallazgo crítico que **corrige el diseño**: `INF3_RM_PRUEBAS` tiene columnas `(id, prueba_id, protocolo_id, rm_id, manual, creado, creado_por, origen_id)` — justo lo que necesito para la reinserción CA-14. Pero **`INF3_RM_ANEXOS` no se inserta en ningún sitio del alta de rrmm-utils** (solo aparece en `ReconocimientosDaoImpl` como lectura y en rrmm-backend gestionado aparte). Si `cargarConfiguracion` no regenera anexos, **limpiarlos sería destructivo e irreversible**. Debo limpiar exactamente lo que el alta regenera, ni más ni menos. Verifico qué inserta realmente `cargarConfiguracionProtocolosReconocimiento`.

`cargarConfiguracion` **sí** inserta anexos (líneas 172/174 `insertarAnexosPorConfigsIds`). Mi grep anterior se cortó por el tamaño del fichero. Confirmo a qué tabla escribe ese método para decidir con certeza si entra en la limpieza.

Confirmado de forma definitiva:
- Los "anexos" del alta se insertan en **`inf3_rm_ipromes`** (línea 644), no en `inf3_rm_anexos`.
- `inf3_rm_anexos` (ID/RM_ID/ANEXO_ID) es un concepto **aparte** gestionado por rrmm-backend, que `cargarConfiguracion` **NO** regenera.

→ **Corrijo el diseño**: la limpieza NO debe tocar `inf3_rm_anexos` (sería destructivo e irreversible). Las 7 tablas a limpiar son: `protocolos, pruebas, perfiles, cuestionarios, parametros, ipromes, productos_quimicos`.

Reviso las constantes `RmCodes` (ORIGEN_*) para la reinserción CA-14 y el estado "pendiente".

Tengo las constantes (`ORIGEN_MANUAL=3`, `ESTADO_PENDIENTE=8`, `ITEM_TIPO_*`). Para el guard defensivo de "RM pendiente" en rrmm-utils, confirmo el nombre real de la columna de estado en `inf_rm`.

Decisión sobre el guard de "pendiente": `getReconocimientoContextoByRmId` no devuelve estado, y el estado real del RM se resuelve por `inf4_rm_log` (incierto). Como rrmm-backend **ya valida RM pendiente** aguas arriba (diseño §7), rrmm-utils solo validará existencia (404 si no existe) y no inventaré una query de estado dudosa. Documento esa frontera.

Ya tengo todo. Creo los DTOs internos de reconciliación.

Ahora la interfaz del DAO de reconciliación.

Antes del impl confirmo los getters de `Acp`.

Confirmo el patrón de bean datasource para los qualifiers (`jdbcTemplateVigSalud`/`namedTemplateVigSalud`) ya visto. Escribo el `ReconciliacionProtocolosDaoImpl`.

Para el servicio necesito ver exactamente cómo el dry-run (`recalcularConfiguracionProtocolos`) construye el `cmd` desde el contexto del RM, para imitarlo fielmente. Leo esa sección.

Excelente, el patrón de construcción del `cmd` está claro. Necesito 4 datos para el servicio: la constante `NIVEL_RIESGO_DEFECTO_PERIODICIDAD`, el qualifier del transaction manager de vig_salud (para `@Transactional`), y cómo se resuelve el usuario (authResolver + getUsuarioInfo). Los busco.

`NIVEL_RIESGO_DEFECTO_PERIODICIDAD = 2` (en `RmCodes`) y `manualTransactionManager` es el tx manager de `dataSourceVigSalud` → perfecto para `@Transactional("manualTransactionManager")`. Leo las declaraciones de campos/constructor del servicio de alta para imitar tipos e inyección exactos (altaDao, altaCreacionDao, authResolver, getUsuarioInfo, servicios).

Tengo los qualifiers. Confirmo los paths de import de `CustomRestApiException`, `RestApiErrorCode` y `EdadUtils` para que el servicio compile.

Confirmo la API de auth (resolver/context) y que `getUsuarioInfo` está en `AltaReconocimientoDao`, antes de escribir el servicio.

Tengo todo confirmado. `getUsuarioInfo` está en `AltaReconocimientoDao` y para resolver el usuario usaré `JwtService` directamente (más limpio, evita el lookup de "externo" que no necesito). Creo la interfaz y la implementación del servicio.

Reviso linStates de los archivos del servicio.

Servicio listo y sin errores. Ahora añado el endpoint `POST /rrmm/protocolos/aplicar` (método nuevo) al controlador existente, sin tocar `/recalcular`. Leo el controlador para imitar su estilo.

Añado el endpoint nuevo y la dependencia del nuevo servicio al controlador (cambio aditivo, dentro del plan aprobado; no toco `/recalcular`).

Marco el endpoint completado y verifico que rrmm-utils compila antes de seguir con los tests.

rrmm-utils compila (exit 0; solo un warning de deprecación preexistente ajeno a mi código). Ahora los tests. Reviso el estilo de tests existentes para imitarlo.

Estilo claro (JUnit 5 + Mockito + AssertJ). Confirmo setters de `CentroClienteDto` y `UsuarioInfoAltaReconocimientoDto` para construir mocks en el test.

Tengo todo para los tests. Escribo el test unitario del servicio (orquestación: orden CA-14, reincorporación, periodicidad, ACP, errores).

Ejecuto el test del servicio para verificarlo.

Mi cambio en el constructor del controlador rompió un test existente (`ProtocolosReconocimientoControllerTest`). Lo actualizo para inyectar el nuevo servicio mockeado.

Añado cobertura del nuevo endpoint `/aplicar` al test del controlador.

Tests en verde (exit 0; los "errores" del log son solo PowerShell tratando las notas de stderr). **El lado de rrmm-utils de BE-07 está completo y verificado.**

## Resumen del lado rrmm-utils (completado y verificado)

**Archivos nuevos:**
- `domain/rm/alta/AplicarProtocolosRequest.java` y `AplicarProtocolosResponse.java`
- `domain/rm/reconciliacion/PruebaRealizada.java` y `ConteoConfiguracionInf3.java`
- `dao/.../reconciliacion/ReconciliacionProtocolosDao(+Impl).java`
- `service/.../reconciliacion/AplicarProtocolosReconocimientoService(+Impl).java`
- Tests: `AplicarProtocolosReconocimientoServiceImplTest` (6 casos: orden, CA-14, periodicidad protocolos/ACP, 404, 400)

**Modificaciones aditivas:** endpoint `POST /rrmm/protocolos/aplicar` en `ProtocolosReconocimientoController` (+ test del endpoint). No se tocó ningún método existente del alta.

**Verificado:** `compileJava` OK y los tests del servicio + controlador en verde.

**Hallazgos importantes durante la implementación (corrigen el diseño):**
1. `INF3_RM_ANEXOS` **se excluye** de la limpieza: el alta no la regenera (sus "anexos" van a `inf3_rm_ipromes`), así que limpiarla habría sido destructivo. Limpiamos exactamente las **7 tablas** que el alta regenera.
2. Las "observaciones" del ACP se materializan vía un método DAO nuevo (`actualizarAcpMetadataSinMedicos`) que refresca `acp_id/tipo/obs/observacion/periodicidad_ver_ia` y **preserva MC/MT**, tal como cerramos.

---

## Siguiente paso: rrmm-backend (toca `confirmar()`)

Falta cablear el lado consumidor. Esto implica **modificar el método existente `CambioPuestoServiceImpl.confirmar()`**, que es lógica sensible, por eso confirmo antes el plan:

- **Nuevos:** `AplicarProtocolosBackRequest` / `AplicarProtocolosBackResponse` (DTOs en rrmm-backend).
- **Client:** nuevo método `aplicarConfiguracionProtocolos(req, jwt)` en `RrmmUtilsClient(+Impl)` (análogo a `recalcularConfiguracionProtocolos`).
- **Mapper:** nuevo método en `CambioPuestoRrmmUtilsRequestMapper` para construir la request de aplicar.
- **Wiring en `confirmar()`:** insertar la llamada al applier **al final** (tras RL + `INF_RM` + adicionales, antes del log CA-17), con `@Transactional` local → rollback si falla el remoto (idempotente, §7.1 del diseño).
- **`application.yml`:** flag opcional `cambio-puesto.aplicar.enabled` para rollout controlado.

¿Procedo con el lado rrmm-backend siguiendo este plan?

---

**User**

si procede por favor

---

**Cursor**

Procedo con rrmm-backend. Primero leo las estructuras existentes que voy a imitar: el client (`recalcular`), sus DTOs back, el mapper y el método `confirmar()` con su transaccionalidad.

Ahora leo el mapper, el `PuestoAdicionalBackDto`, y el `confirmar()` con su transaccionalidad y secuencia actual.

Ahora el `confirmar()` para ver la secuencia y transaccionalidad exactas donde insertar la llamada.

Tengo la imagen completa. Veo que `CambioPuestoServiceImpl` **no** inyecta hoy `RrmmUtilsClient` ni el mapper (los usa `impactoPropuestoResolver` internamente), así que tendré que añadirlos al constructor y actualizar su test. Reviso cómo el test construye el servicio.

El test usa `@InjectMocks`, así que añadir mocks nuevos es sencillo. Reviso los tests de CONFIRMAR para no romperlos con la nueva llamada al applier (verifyNoMoreInteractions, etc.).

Hay un test de CONFIRMAR (`confirmar_persisteLogCambioPuesto`). Con `@InjectMocks`, añadiré los mocks nuevos y stubs. Empiezo creando los DTOs back en rrmm-backend.

Ahora añado el método al client (interfaz + impl), imitando `recalcular` con manejo de errores adecuado para una operación de escritura.

Ahora añado el método de implementación del client tras `recalcular`.

Ahora el método del mapper para construir la request de aplicar.

Ahora cableo en `confirmar()`. Añado imports, dependencias al constructor, el flag y la llamada al applier tras `replacePuestosAdicionalesRm`.

Ahora la llamada en `confirmar()` tras `replacePuestosAdicionalesRm`, y el método privado que orquesta el applier.

Actualizo el test existente: añado los mocks nuevos (los inyecta `@InjectMocks`) y stubeo el applier en el test de CONFIRMAR, más dos tests nuevos (flag on/off).

En tests sin Spring, `@Value` no se procesa, así que `aplicarProtocolosEnabled` queda `false` por defecto y el test de CONFIRMAR existente sigue verde sin tocarlo. Añado imports y dos tests nuevos (flag on llama al applier; flag off lo omite).

Ahora añado los dos tests nuevos del applier tras `confirmar_persisteLogCambioPuesto`.

Falta el import de `anyInt`. Lo añado.

Verifico dónde está la config `cambio-puesto` en el `application.yml` para añadir el flag de forma coherente.

Añado el flag `aplicar.enabled: true` en los 3 perfiles del `application.yml`.

Cableado completo. Marco b1 y compilo rrmm-backend + ejecuto los tests de cambio-puesto.

Build y tests verdes (exit 0). Añado un test del mapper para `toAplicarRequest` para completar la cobertura. Reviso el test existente del mapper.

Ejecuto de nuevo los tests del servicio y mapper para confirmar todo verde con los casos nuevos.

Exit 0, sin fallos. La compilación completa de main+test del módulo ya se valida en cada `test` run, así que el build está verificado. Marco b2 como completado.

BE-07 completado en ambos lados. Resumen de lo implementado en `rrmm-backend`:

## Nuevos DTOs (contrato HTTP)
- `AplicarProtocolosBackRequest` — espejo de `RecalcularProtocolosBackRequest` (rmId, puestoId, tipoPuesto, adicionales).
- `AplicarProtocolosBackResponse` — resumen de materialización (contadores INF3_*, periodicidad, acpId, pruebas conservadas CA-14).

## Client
- `RrmmUtilsClient.aplicarConfiguracionProtocolos(req, jwt)` + impl en `RrmmUtilsClientImpl`, `POST /rrmm/protocolos/aplicar`. A diferencia del dry-run, **cualquier error HTTP/red se traduce a `CambioPuestoIntegrationException`** (no a "no implementado"), para que la transacción local revierta. Traza con clave `V07_APLICAR_HTTP`.

## Mapper
- `CambioPuestoRrmmUtilsRequestMapper.toAplicarRequest(rmId, destino, adicionales)`, reutilizando `mapAdicionales` existente.

## Wiring en `confirmar()`
- Llamada al applier **al final**, tras RL + `INF_RM` + adicionales y antes del log CA-17:

```242:299:c:\Repository\rrmm-backend\src\main\java\com\preving\restapi\rrmm\service\cambiopuesto\CambioPuestoServiceImpl.java
        actualizarInfRm(rm, request, editorId);
        replacePuestosAdicionalesRm(rmId, request.getPuestosAdicionales());

        // Materialización INF3_* (BE-07): ... Si falla, la transacción local revierte ...
        aplicarConfiguracionProtocolos(rmId, request, httpRequest);
```

- Como `confirmar()` ya es `@Transactional`, si el applier remoto falla → rollback local de RL/INF_RM/adicionales; el remoto es idempotente, así que reintentar es seguro (§7.1 del diseño).
- Flag `cambio-puesto.aplicar.enabled` (default `true`) para rollout controlado; añadido en los 3 perfiles de `application.yml`.

## Tests (todos verdes, build OK)
- `CambioPuestoServiceImplTest`: 2 tests nuevos (flag ON invoca al client; flag OFF lo omite) + mocks añadidos vía `@InjectMocks`. El test de CONFIRMAR existente sigue pasando (en unit test `@Value` no se procesa, el flag queda `false`).
- `CambioPuestoRrmmUtilsRequestMapperTest`: 2 tests nuevos para `toAplicarRequest`.

Decisión que tomé por defecto (avísame si prefieres otra): el flag `cambio-puesto.aplicar.enabled` queda **activado** en dev/demo/prod, ya que la rama está feature-gated y BE-07 completa el flujo E2E del sprint 2. Si quieres un rollout más conservador (p.ej. `false` en prod hasta validar), lo cambio en el `application.yml`.

¿Quieres que añada también el enriquecimiento del log CA-17 con los contadores reales del applier (territorio BE-09), o lo dejamos fuera de BE-07?

---

**User**

lo del log CA-17 ya lo teniamos hecho no?

---

**Cursor**

Sí, correcto. El log CA-17 **ya está implementado** en `confirmar()`. Lo hace `registrarLogCambioPuesto(...)`, que inserta en la tabla de log de cambio de puesto con:

- origen/destino (cliente, centro, puesto, tipo de puesto),
- `rlAfectadaId` y `rlAccion`,
- y los **protocolos añadidos/eliminados** en JSON, calculados por `resolverProtocolosLog(...)` a partir del delta:

```334:358:c:\Repository\rrmm-backend\src\main\java\com\preving\restapi\rrmm\service\cambiopuesto\CambioPuestoServiceImpl.java
    private Integer registrarLogCambioPuesto(
            Reconocimiento rm,
            CambioPuestoRequest request,
            int editorId,
            CambioPuestoRlMutationResult rlMutation,
            String rlAccion,
            ProtocolosLogDelta protocolosLog) {
        ...
        logEntry.setProtocolosAnadidosJson(CambioPuestoLogProtocolJson.toJson(protocolosLog.anadidos()));
        logEntry.setProtocolosEliminadosJson(CambioPuestoLogProtocolJson.toJson(protocolosLog.eliminados()));
        logEntry.setRlAfectadaId((int) rlMutation.getRlId());
        logEntry.setRlAccion(rlAccion);
        return cambioPuestoLogDao.insert(logEntry);
    }
```

Así que **no hay que crear nada nuevo** para CA-17.

La matización que planteaba antes era distinta: hoy los protocolos del log salen del **delta calculado en el dry-run** (P1 vía `resolverProtocolosLog`), no de los **contadores reales que devuelve el applier** (`AplicarProtocolosBackResponse`). Son dos fuentes:

- **CA-17 (ya hecho):** registra qué protocolos cambiaron (añadidos/eliminados) — funcional y suficiente.
- **Mejora opcional (BE-09):** reemplazar/complementar esa fuente con los contadores reales de materialización del applier, para que el log refleje exactamente lo que se escribió en `INF3_*`.

Dado que CA-17 ya cumple el criterio de aceptación, mi recomendación es **dejarlo como está** y abordar el enriquecimiento con datos del applier en BE-09, no en BE-07. ¿Lo dejamos así?

---

**User**

vale lo dejamos asi y lo abordamos en BE-09. Me gustaria probar el flujo nuevo, como lo hago? hay que cambiar collection o no es necesario? 

---

**Cursor**

Buena pregunta. Déjame confirmar la ruta exacta del endpoint de CONFIRMAR y los puertos para darte instrucciones precisas.

Reviso el puerto y context-path de rrmm-utils para precisar la URL del applier.

Ya tengo todo. Te resumo cómo probarlo.

## Respuesta directa: NO hace falta tocar la collection (para el flujo E2E)

El applier de BE-07 **no es un endpoint nuevo de cara al usuario**. Se invoca internamente desde `rrmm-backend` dentro del `confirmar()`. El endpoint que tú llamas sigue siendo el de siempre:

```
PUT {{rrmm-backend}}/rm/{rmId}/cambiar-puesto
Body: { "accion": "CONFIRMAR", "clienteId":..., "centroId":..., "puestoId":..., "estandar":..., "puestosAdicionales":[...] }
```

Esa request **ya existe en la collection**. No hay que añadir ni cambiar nada para probar el flujo completo: al confirmar, `rrmm-backend` llama solo a `rrmm-utils` `POST /rrmm/protocolos/aplicar`.

## Pasos para probar el flujo E2E

1. **Levantar `rrmm-utils`** (es quien tiene el endpoint nuevo `/rrmm/protocolos/aplicar`).
   - ⚠️ **Cuidado con el puerto**: `rrmm-utils` arranca por defecto en **8080**, pero `rrmm-backend` espera encontrarlo en **8081**:
   
```264:265:c:\Repository\rrmm-backend\src\main\resources\application.yml
api-rrmm-utils:
  url: http://localhost:8081/rrmm-utils
```
   - Arráncalo en 8081 (`--server.port=8081`) **o** ajusta esa URL al puerto donde lo levantes.

2. **Levantar `rrmm-backend`** (perfil dev) con la config ya correcta:
   - `cambio-puesto.simular.mock-enabled: false`
   - `cambio-puesto.aplicar.enabled: true` (ya es el default)
   - `api-rrmm-utils.url` apuntando a tu `rrmm-utils`.
   - **Importante**: ambos servicios contra la **misma BD/esquema**, porque `rrmm-backend` escribe `INF_RM` y `rrmm-utils` reconstruye los `INF3_RM_*` del mismo `rmId`.

3. **Lanzar la request de CONFIRMAR** existente sobre un `rmId` en estado **pendiente**.

4. **Verificar**:
   - Logs de `rrmm-backend`: `[cambio-puesto] rmId=... CONFIRMAR applier ok protocolos=... pruebas=... conservadasCa14=...`
   - En BD: los `INF3_RM_*` del `rmId` regenerados según el puesto destino, y las pruebas ya realizadas conservadas (CA-14).

## Si quieres probar el applier de rrmm-utils aislado (opcional)

Ahí **sí** tendrías que añadir una request nueva a la collection (o crearla a mano):

```
POST {{rrmm-utils}}/rrmm/protocolos/aplicar
Authorization: Bearer <jwt>
Body: { "rmId":..., "puestoId":..., "tipoPuesto": 1, "puestosAdicionales":[...] }
```

Útil para depurar la materialización sin pasar por todo el `confirmar()`, pero **no es necesario** para validar el flujo de usuario.

¿Quieres que te prepare el JSON de ejemplo de esa request del applier por si te sirve para depurar en rrmm-utils?

---

**User**

vale tengo dos de los 3 proyectos con puerto 8080, pudes cambiarlo momentaneamente para uno

---

**Cursor**

Perfecto. La solución más limpia es cambiar **`rrmm-utils` a 8081**, porque `rrmm-backend` ya lo espera ahí (`api-rrmm-utils.url: http://localhost:8081/rrmm-utils`) y deja `puestos-back` en 8080 (que también es donde `rrmm-backend` lo busca). Así solo toco un archivo y todo encaja sin más cambios.

Lo confirmo leyendo la cabecera del yml de rrmm-utils.

Cambio el puerto de rrmm-utils a 8081 (bloque `server` del perfil dev).

Hecho. Cambié **rrmm-utils** de `8080` → `8081`:

```1:8:c:\Repository\rrmm-utils\src\main\resources\application.yml
server:
  port: 8081
#  ssl:
#    key-store: classpath:ssl/tomcat.keystore
#    key-store-password: preving
#    key-password: preving
  servlet:
    context-path: /${NAME_CONTEXT:rrmm-utils}
```

Con esto los puertos quedan alineados sin tocar nada más:

| Proyecto | Puerto | Lo usa rrmm-backend en |
|---|---|---|
| `puestos-back` | 8080 | `http://localhost:8080/puestos-back` ✅ |
| `rrmm-utils` | **8081** | `http://localhost:8081/rrmm-utils` ✅ |
| `rrmm-backend` | 8825 | (es el que orquesta) |

Así que `rrmm-utils` quedará en `http://localhost:8081/rrmm-utils`, justo donde `rrmm-backend` ya lo busca. No hace falta cambiar `api-rrmm-utils.url`.

Recuerda: es un cambio **local/temporal**, no lo subas al commit. Cuando termines de probar, revierte el puerto a 8080 (o déjalo como prefieras en tu entorno). ¿Quieres que te lo deje anotado para revertirlo luego, o lo gestionas tú?

---

**User**

tenemos un error: 
2026-06-24 12:34:13.651  INFO 31520 --- [nio-8081-exec-1] o.s.web.servlet.DispatcherServlet        : Completed initialization in 3 ms
2026-06-24 12:36:44.796  INFO 31520 --- [nio-8081-exec-3] licarProtocolosReconocimientoServiceImpl : Aplicar config protocolos rmId=12341907 puestoId=73504 tipoPuesto=0 adicionales=0 userVigId=155527
org.springframework.jdbc.BadSqlGrammarException: PreparedStatementCallback; bad SQL grammar [SELECT DISTINCT ip.PRUEBA_ID, ip.CODIGO_PRUEBA FROM vig_salud.INF3_RM_PRUEBAS irp JOIN vig_salud.INF3_PRUEBAS ip ON irp.PRUEBA_ID = ip.ID WHERE irp.RM_ID = ?   AND irp.BORRADO IS NULL   AND ( EXISTS (SELECT 1 FROM vig_salud.INF2_RM_VALORES v                WHERE v.RM_ID = ? AND v.PRUEBA_CODIGO LIKE ip.CODIGO_PRUEBA || '%')      OR EXISTS (SELECT 1 FROM vig_salud.INF_RESULTADOS r                WHERE r.RES_RM_ID = ? AND r.PRUEBA_ID = ip.PRUEBA_ID) )]; nested exception is java.sql.SQLSyntaxErrorException: ORA-00904: "IP"."PRUEBA_ID": identificador no válido

	at org.springframework.jdbc.support.SQLErrorCodeSQLExceptionTranslator.doTranslate(SQLErrorCodeSQLExceptionTranslator.java:239)
	at org.springframework.jdbc.support.AbstractFallbackSQLExceptionTranslator.translate(AbstractFallbackSQLExceptionTranslator.java:70)
	at org.springframework.jdbc.core.JdbcTemplate.translateException(JdbcTemplate.java:1541)
	at org.springframework.jdbc.core.JdbcTemplate.execute(JdbcTemplate.java:667)
	at org.springframework.jdbc.core.JdbcTemplate.query(JdbcTemplate.java:713)
	at org.springframework.jdbc.core.JdbcTemplate.query(JdbcTemplate.java:738)
	at org.springframework.jdbc.core.JdbcTemplate.query(JdbcTemplate.java:794)
	at org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate.query(NamedParameterJdbcTemplate.java:209)
	at com.preving.restapi.rrmmutils.dao.reconocimiento.reconciliacion.ReconciliacionProtocolosDaoImpl.getPruebasRealizadasByRmId(ReconciliacionProtocolosDaoImpl.java:64)
	at com.preving.restapi.rrmmutils.dao.reconocimiento.reconciliacion.ReconciliacionProtocolosDaoImpl$$FastClassBySpringCGLIB$$eae23c3.invoke(<generated>)
	at org.springframework.cglib.proxy.MethodProxy.invoke(MethodProxy.java:218)
	at org.springframework.aop.framework.CglibAopProxy$CglibMethodInvocation.invokeJoinpoint(CglibAopProxy.java:793)
	at org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:163)
	at org.springframework.aop.framework.CglibAopProxy$CglibMethodInvocation.proceed(CglibAopProxy.java:763)
	at org.springframework.dao.support.PersistenceExceptionTranslationInterceptor.invoke(PersistenceExceptionTranslationInterceptor.java:137)
	at org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:186)
	at org.springframework.aop.framework.CglibAopProxy$CglibMethodInvocation.proceed(CglibAopProxy.java:763)
	at org.springframework.aop.framework.CglibAopProxy$DynamicAdvisedInterceptor.intercept(CglibAopProxy.java:708)
	at com.preving.restapi.rrmmutils.dao.reconocimiento.reconciliacion.ReconciliacionProtocolosDaoImpl$$EnhancerBySpringCGLIB$$d70b6308.getPruebasRealizadasByRmId(<generated>)
	at com.preving.restapi.rrmmutils.service.reconocimiento.reconciliacion.AplicarProtocolosReconocimientoServiceImpl.aplicarConfiguracionProtocolos(AplicarProtocolosReconocimientoServiceImpl.java:104)
	at com.preving.restapi.rrmmutils.service.reconocimiento.reconciliacion.AplicarProtocolosReconocimientoServiceImpl$$FastClassBySpringCGLIB$$61d587.invoke(<generated>)
	at org.springframework.cglib.proxy.MethodProxy.invoke(MethodProxy.java:218)
	at org.springframework.aop.framework.CglibAopProxy$CglibMethodInvocation.invokeJoinpoint(CglibAopProxy.java:793)
	at org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:163)
	at org.springframework.aop.framework.CglibAopProxy$CglibMethodInvocation.proceed(CglibAopProxy.java:763)
	at org.springframework.transaction.interceptor.TransactionInterceptor$1.proceedWithInvocation(TransactionInterceptor.java:123)
	at org.springframework.transaction.interceptor.TransactionAspectSupport.invokeWithinTransaction(TransactionAspectSupport.java:388)
	at org.springframework.transaction.interceptor.TransactionInterceptor.invoke(TransactionInterceptor.java:119)
	at org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:186)
	at org.springframework.aop.framework.CglibAopProxy$CglibMethodInvocation.proceed(CglibAopProxy.java:763)
	at org.springframework.aop.framework.CglibAopProxy$DynamicAdvisedInterceptor.intercept(CglibAopProxy.java:708)
	at com.preving.restapi.rrmmutils.service.reconocimiento.reconciliacion.AplicarProtocolosReconocimientoServiceImpl$$EnhancerBySpringCGLIB$$fb06cdd2.aplicarConfiguracionProtocolos(<generated>)
	at com.preving.restapi.rrmmutils.web.ProtocolosReconocimientoController.aplicarConfiguracionProtocolos(ProtocolosReconocimientoController.java:71)
	at java.base/jdk.internal.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
	at java.base/jdk.internal.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:77)
	at java.base/jdk.internal.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
	at java.base/java.lang.reflect.Method.invoke(Method.java:568)
	at org.springframework.web.method.support.InvocableHandlerMethod.doInvoke(InvocableHandlerMethod.java:205)
	at org.springframework.web.method.support.InvocableHandlerMethod.invokeForRequest(InvocableHandlerMethod.java:150)
	at org.springframework.web.servlet.mvc.method.annotation.ServletInvocableHandlerMethod.invokeAndHandle(ServletInvocableHandlerMethod.java:117)
	at org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter.invokeHandlerMethod(RequestMappingHandlerAdapter.java:895)
	at org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter.handleInternal(RequestMappingHandlerAdapter.java:808)
	at org.springframework.web.servlet.mvc.method.AbstractHandlerMethodAdapter.handle(AbstractHandlerMethodAdapter.java:87)
	at org.springframework.web.servlet.DispatcherServlet.doDispatch(DispatcherServlet.java:1067)
	at org.springframework.web.servlet.DispatcherServlet.doService(DispatcherServlet.java:963)
	at org.springframework.web.servlet.FrameworkServlet.processRequest(FrameworkServlet.java:1006)
	at org.springframework.web.servlet.FrameworkServlet.doPost(FrameworkServlet.java:909)
	at javax.servlet.http.HttpServlet.service(HttpServlet.java:681)
	at org.springframework.web.servlet.FrameworkServlet.service(FrameworkServlet.java:883)
	at javax.servlet.http.HttpServlet.service(HttpServlet.java:764)
	at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:227)
	at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:162)
	at org.apache.tomcat.websocket.server.WsFilter.doFilter(WsFilter.java:53)
	at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:189)
	at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:162)
	at org.springframework.web.filter.OncePerRequestFilter.doFilter(OncePerRequestFilter.java:111)
	at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:189)
	at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:162)
	at org.springframework.security.web.FilterChainProxy$VirtualFilterChain.doFilter(FilterChainProxy.java:327)
	at org.springframework.security.web.access.intercept.FilterSecurityInterceptor.invoke(FilterSecurityInterceptor.java:115)
	at org.springframework.security.web.access.intercept.FilterSecurityInterceptor.doFilter(FilterSecurityInterceptor.java:81)
	at org.springframework.security.web.FilterChainProxy$VirtualFilterChain.doFilter(FilterChainProxy.java:336)
	at org.springframework.security.web.access.ExceptionTranslationFilter.doFilter(ExceptionTranslationFilter.java:122)
	at org.springframework.security.web.access.ExceptionTranslationFilter.doFilter(ExceptionTranslationFilter.java:116)
	at org.springframework.security.web.FilterChainProxy$VirtualFilterChain.doFilter(FilterChainProxy.java:336)
	at org.springframework.security.web.session.SessionManagementFilter.doFilter(SessionManagementFilter.java:126)
	at org.springframework.security.web.session.SessionManagementFilter.doFilter(SessionManagementFilter.java:81)
	at org.springframework.security.web.FilterChainProxy$VirtualFilterChain.doFilter(FilterChainProxy.java:336)
	at org.springframework.security.web.authentication.AnonymousAuthenticationFilter.doFilter(AnonymousAuthenticationFilter.java:109)
	at org.springframework.security.web.FilterChainProxy$VirtualFilterChain.doFilter(FilterChainProxy.java:336)
	at org.springframework.security.web.servletapi.SecurityContextHolderAwareRequestFilter.doFilter(SecurityContextHolderAwareRequestFilter.java:149)
	at org.springframework.security.web.FilterChainProxy$VirtualFilterChain.doFilter(FilterChainProxy.java:336)
	at org.springframework.security.web.savedrequest.RequestCacheAwareFilter.doFilter(RequestCacheAwareFilter.java:63)
	at org.springframework.security.web.FilterChainProxy$VirtualFilterChain.doFilter(FilterChainProxy.java:336)
	at com.preving.security.JwtAuthenticationTokenFilter.doFilterInternal(JwtAuthenticationTokenFilter.java:122)
	at org.springframework.web.filter.OncePerRequestFilter.doFilter(OncePerRequestFilter.java:117)
	at org.springframework.security.web.FilterChainProxy$VirtualFilterChain.doFilter(FilterChainProxy.java:336)
	at org.springframework.security.web.authentication.logout.LogoutFilter.doFilter(LogoutFilter.java:103)
	at org.springframework.security.web.authentication.logout.LogoutFilter.doFilter(LogoutFilter.java:89)
	at org.springframework.security.web.FilterChainProxy$VirtualFilterChain.doFilter(FilterChainProxy.java:336)
	at org.springframework.security.web.header.HeaderWriterFilter.doHeadersAfter(HeaderWriterFilter.java:90)
	at org.springframework.security.web.header.HeaderWriterFilter.doFilterInternal(HeaderWriterFilter.java:75)
	at org.springframework.web.filter.OncePerRequestFilter.doFilter(OncePerRequestFilter.java:117)
	at org.springframework.security.web.FilterChainProxy$VirtualFilterChain.doFilter(FilterChainProxy.java:336)
	at org.springframework.security.web.context.SecurityContextPersistenceFilter.doFilter(SecurityContextPersistenceFilter.java:112)
	at org.springframework.security.web.context.SecurityContextPersistenceFilter.doFilter(SecurityContextPersistenceFilter.java:82)
	at org.springframework.security.web.FilterChainProxy$VirtualFilterChain.doFilter(FilterChainProxy.java:336)
	at org.springframework.security.web.context.request.async.WebAsyncManagerIntegrationFilter.doFilterInternal(WebAsyncManagerIntegrationFilter.java:55)
	at org.springframework.web.filter.OncePerRequestFilter.doFilter(OncePerRequestFilter.java:117)
	at org.springframework.security.web.FilterChainProxy$VirtualFilterChain.doFilter(FilterChainProxy.java:336)
	at org.springframework.security.web.session.DisableEncodeUrlFilter.doFilterInternal(DisableEncodeUrlFilter.java:42)
	at org.springframework.web.filter.OncePerRequestFilter.doFilter(OncePerRequestFilter.java:117)
	at org.springframework.security.web.FilterChainProxy$VirtualFilterChain.doFilter(FilterChainProxy.java:336)
	at org.springframework.security.web.FilterChainProxy.doFilterInternal(FilterChainProxy.java:211)
	at org.springframework.security.web.FilterChainProxy.doFilter(FilterChainProxy.java:183)
	at org.springframework.web.filter.DelegatingFilterProxy.invokeDelegate(DelegatingFilterProxy.java:354)
	at org.springframework.web.filter.DelegatingFilterProxy.doFilter(DelegatingFilterProxy.java:267)
	at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:189)
	at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:162)
	at org.springframework.web.filter.RequestContextFilter.doFilterInternal(RequestContextFilter.java:100)
	at org.springframework.web.filter.OncePerRequestFilter.doFilter(OncePerRequestFilter.java:117)
	at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:189)
	at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:162)
	at org.springframework.web.filter.FormContentFilter.doFilterInternal(FormContentFilter.java:93)
	at org.springframework.web.filter.OncePerRequestFilter.doFilter(OncePerRequestFilter.java:117)
	at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:189)
	at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:162)
	at org.springframework.boot.actuate.metrics.web.servlet.WebMvcMetricsFilter.doFilterInternal(WebMvcMetricsFilter.java:96)
	at org.springframework.web.filter.OncePerRequestFilter.doFilter(OncePerRequestFilter.java:117)
	at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:189)
	at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:162)
	at org.springframework.web.filter.CharacterEncodingFilter.doFilterInternal(CharacterEncodingFilter.java:201)
	at org.springframework.web.filter.OncePerRequestFilter.doFilter(OncePerRequestFilter.java:117)
	at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:189)
	at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:162)
	at org.apache.catalina.core.StandardWrapperValve.invoke(StandardWrapperValve.java:197)
	at org.apache.catalina.core.StandardContextValve.invoke(StandardContextValve.java:97)
	at org.apache.catalina.authenticator.AuthenticatorBase.invoke(AuthenticatorBase.java:541)
	at org.apache.catalina.core.StandardHostValve.invoke(StandardHostValve.java:135)
	at org.apache.catalina.valves.ErrorReportValve.invoke(ErrorReportValve.java:92)
	at org.apache.catalina.core.StandardEngineValve.invoke(StandardEngineValve.java:78)
	at org.apache.catalina.connector.CoyoteAdapter.service(CoyoteAdapter.java:360)
	at org.apache.coyote.http11.Http11Processor.service(Http11Processor.java:399)
	at org.apache.coyote.AbstractProcessorLight.process(AbstractProcessorLight.java:65)
	at org.apache.coyote.AbstractProtocol$ConnectionHandler.process(AbstractProtocol.java:890)
	at org.apache.tomcat.util.net.NioEndpoint$SocketProcessor.doRun(NioEndpoint.java:1787)
	at org.apache.tomcat.util.net.SocketProcessorBase.run(SocketProcessorBase.java:49)
	at org.apache.tomcat.util.threads.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1191)
	at org.apache.tomcat.util.threads.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:659)
	at org.apache.tomcat.util.threads.TaskThread$WrappingRunnable.run(TaskThread.java:61)
	at java.base/java.lang.Thread.run(Thread.java:842)
Caused by: java.sql.SQLSyntaxErrorException: ORA-00904: "IP"."PRUEBA_ID": identificador no válido

	at oracle.jdbc.driver.T4CTTIoer11.processError(T4CTTIoer11.java:629)
	at oracle.jdbc.driver.T4CTTIoer11.processError(T4CTTIoer11.java:563)
	at oracle.jdbc.driver.T4C8Oall.processError(T4C8Oall.java:1230)
	at oracle.jdbc.driver.T4CTTIfun.receive(T4CTTIfun.java:771)
	at oracle.jdbc.driver.T4CTTIfun.doRPC(T4CTTIfun.java:298)
	at oracle.jdbc.driver.T4C8Oall.doOALL(T4C8Oall.java:511)
	at oracle.jdbc.driver.T4CPreparedStatement.doOall8(T4CPreparedStatement.java:162)
	at oracle.jdbc.driver.T4CPreparedStatement.executeForDescribe(T4CPreparedStatement.java:1009)
	at oracle.jdbc.driver.OracleStatement.prepareDefineBufferAndExecute(OracleStatement.java:1270)
	at oracle.jdbc.driver.OracleStatement.executeMaybeDescribe(OracleStatement.java:1148)
	at oracle.jdbc.driver.OracleStatement.executeSQLSelect(OracleStatement.java:1660)
	at oracle.jdbc.driver.OracleStatement.doExecuteWithTimeout(OracleStatement.java:1469)
	at oracle.jdbc.driver.OraclePreparedStatement.executeInternal(OraclePreparedStatement.java:3760)
	at oracle.jdbc.driver.OraclePreparedStatement.executeQuery(OraclePreparedStatement.java:3935)
	at oracle.jdbc.driver.OraclePreparedStatementWrapper.executeQuery(OraclePreparedStatementWrapper.java:1101)
	at com.zaxxer.hikari.pool.ProxyPreparedStatement.executeQuery(ProxyPreparedStatement.java:52)
	at com.zaxxer.hikari.pool.HikariProxyPreparedStatement.executeQuery(HikariProxyPreparedStatement.java)
	at org.springframework.jdbc.core.JdbcTemplate$1.doInPreparedStatement(JdbcTemplate.java:722)
	at org.springframework.jdbc.core.JdbcTemplate.execute(JdbcTemplate.java:651)
	... 127 more
Caused by: Error : 904, Position : 16, Sql = SELECT DISTINCT ip.PRUEBA_ID, ip.CODIGO_PRUEBA FROM vig_salud.INF3_RM_PRUEBAS irp JOIN vig_salud.INF3_PRUEBAS ip ON irp.PRUEBA_ID = ip.ID WHERE irp.RM_ID = :1    AND irp.BORRADO IS NULL   AND ( EXISTS (SELECT 1 FROM vig_salud.INF2_RM_VALORES v                WHERE v.RM_ID = :2  AND v.PRUEBA_CODIGO LIKE ip.CODIGO_PRUEBA || '%')      OR EXISTS (SELECT 1 FROM vig_salud.INF_RESULTADOS r                WHERE r.RES_RM_ID = :3  AND r.PRUEBA_ID = ip.PRUEBA_ID) ), OriginalSql = SELECT DISTINCT ip.PRUEBA_ID, ip.CODIGO_PRUEBA FROM vig_salud.INF3_RM_PRUEBAS irp JOIN vig_salud.INF3_PRUEBAS ip ON irp.PRUEBA_ID = ip.ID WHERE irp.RM_ID = ?   AND irp.BORRADO IS NULL   AND ( EXISTS (SELECT 1 FROM vig_salud.INF2_RM_VALORES v                WHERE v.RM_ID = ? AND v.PRUEBA_CODIGO LIKE ip.CODIGO_PRUEBA || '%')      OR EXISTS (SELECT 1 FROM vig_salud.INF_RESULTADOS r                WHERE r.RES_RM_ID = ? AND r.PRUEBA_ID = ip.PRUEBA_ID) ), Error Msg = ORA-00904: "IP"."PRUEBA_ID": identificador no válido

	at oracle.jdbc.driver.T4CTTIoer11.processError(T4CTTIoer11.java:636)
	... 145 more

---

**Cursor**

El error es claro: en `INF3_PRUEBAS` (alias `ip`) la columna se llama `ID`, no `PRUEBA_ID` (de hecho el propio JOIN usa `irp.PRUEBA_ID = ip.ID`). El `prueba_id` que queremos es el de `INF3_RM_PRUEBAS` (alias `irp`). Reviso el DAO y verifico los nombres reales de columna contra otras queries del proyecto.

Confirmo el esquema real de `INF3_PRUEBAS` e `INF3_RM_PRUEBAS` buscando otras queries del proyecto.

Necesito el nombre real de la columna de código en `INF3_PRUEBAS`. Busco cómo el resto del proyecto consulta ese catálogo (joins/selects con su código).

Dato clave: `INF3_PRUEBAS` tiene `ID`, `NOMBRE`, `ACTIVO`, `DISPONIBLE_APP`, `ACTIVIDAD_MT`… pero **no tiene `CODIGO_PRUEBA`**. El código string vive en `INF2_RM_VALORES.PRUEBA_CODIGO`. Mi query asumió un modelo equivocado. Antes de parchear, necesito entender el modelo real de resultados. Reviso el service que consume esto y las columnas reales de las tablas implicadas.

El `codigoPrueba` no se usa en la lógica (solo `pruebaId` numérico para reinsertar); va únicamente en la respuesta/log. Lo importante es detectar bien qué `prueba_id` configurado tiene resultados. Investigo las columnas reales de `INF2_RM_VALORES` e `INF_RESULTADOS` y cómo enlazan con las pruebas.

Necesito ver las columnas reales de `INF_RESULTADOS` y si existe algún mapeo código↔id, porque `INF2_RM_VALORES` usa `PRUEBA_CODIGO` (string) sin `PRUEBA_ID`, y `INF3_PRUEBAS` no tiene código string.

`INF_RESULTADOS` solo aparece como `SELECT res_resultados FROM inf_resultados WHERE res_rm_id = :rmId` — parece almacenar el **texto de analítica** (un registro por RM), no resultados por `PRUEBA_ID`. Verifico la columna `BORRADO` de `INF3_RM_PRUEBAS` (que también uso) y si hay mapeo código↔prueba_id.

Diagnóstico claro. El problema no es un simple typo: la query de detección **CA-14** (`getPruebasRealizadasByRmId`) la diseñé asumiendo un esquema que **no coincide con la BD real**. Lo confirmé contra otras queries del proyecto:

**Lo que asumí vs. lo que hay:**
| Asunción en mi query | Realidad en la BD |
|---|---|
| `INF3_PRUEBAS.PRUEBA_ID` | La PK es `INF3_PRUEBAS.ID` (no existe `PRUEBA_ID`) → **causa del ORA-00904** |
| `INF3_PRUEBAS.CODIGO_PRUEBA` (código string) | `INF3_PRUEBAS` **no tiene código string**; solo `ID, NOMBRE, ACTIVO, DISPONIBLE_APP, ACTIVIDAD_MT…` |
| `INF2_RM_VALORES` enlaza por código con el catálogo | `INF2_RM_VALORES` tiene `PRUEBA_CODIGO` (string tipo `'HAB_TABACO'`) y **no hay relación directa** con `INF3_PRUEBAS.ID` |
| `INF_RESULTADOS.PRUEBA_ID` | En el proyecto `INF_RESULTADOS` se usa como `res_rm_id, res_resultados` (**texto de analítica por RM**), no parece tener resultado por `PRUEBA_ID` |

El resto del DAO sí está bien (`BORRADO` y `PRUEBA_ID` existen en `INF3_RM_PRUEBAS`; `getPruebaIdsConfigurados`, `contarConfiguracionInf3`, `limpiarConfiguracionInf3` y `actualizarAcpMetadataSinMedicos` son correctos). **El único método roto es la detección CA-14.**

Como CA-14 toca lógica clínicamente sensible (no perder visibilidad de pruebas con resultados), no quiero parchearlo a ciegas. Necesito el modelo real de "prueba realizada". Por eso te pregunto cómo prefieres avanzar:

> **La detección CA-14 (getPruebasRealizadasByRmId) está mal modelada y rompe todo el applier. ¿Cómo procedemos?**
> - (Recomendada) Desbloqueo temporal: dejar la detección CA-14 devolviendo vacío (con TODO bien marcado) para que puedas probar YA el resto del flujo (rebuild INF3 + ACP + periodicidad). CA-14 se reimplementa después con el esquema real. En dev es seguro.
> - Rediseñar CA-14 ahora: me pasas la estructura real de las tablas de resultados (DESC de INF3_PRUEBAS, INF3_RM_PRUEBAS, INF2_RM_VALORES, INF_RESULTADOS y la(s) tabla(s) de resultados por prueba) o cómo marca el legacy que una prueba está 'realizada', y lo implemento correcto. ✔
> - Que yo siga investigando el esquema/legacy por mi cuenta (más lento) hasta deducir la relación correcta y lo implemente sin pedirte datos.

Has elegido rediseñarlo bien. Antes de pedirte nada, investigo a fondo el modelo en el propio código para acotar al máximo lo que necesito confirmar. Reviso cómo el legacy relaciona pruebas con sus resultados/niveles.

Veo en `getIndiceByRmId` que `INF3_PRUEBAS` (alias t4) tiene una columna `EXISTE`, y hay tablas de niveles (`inf3_niveles`, `inf3_tipos_rm_x_niveles`). Reviso `pruebasBorradas` y su entorno, que cuenta por `PRUEBA_ID`, por si revela cómo se vinculan resultados a prueba.

He investigado el modelo a fondo y el panorama es claro: en este dominio **no hay un almacén único de "resultados por prueba"**. Es heterogéneo:

- **Anamnesis / exploraciones / hábitos** → `INF2_RM_VALORES` por `PRUEBA_CODIGO` (string, p.ej. `'HAB_TABACO'`).
- **Pruebas con id numérico** (analíticas/parámetros) → tablas dinámicas vía `sql_especifico`/`sql_general` de `inf3_cf_rmversion_x_pruebas`.
- **`INF_RESULTADOS`** → parece texto de analítica por RM (`res_rm_id`, `res_resultados`), no resultado por prueba.
- **Anulaciones** → `INF_PRUEBAS_ANULADAS.PRUEBA_ID` (= `INF3_PRUEBAS.ID`), `INF_CUESTIONARIO_ANULADOS`, etc.

El obstáculo central para una detección genérica: las pruebas configuradas se identifican por `PRUEBA_ID` numérico (`INF3_PRUEBAS.ID`), pero los datos clínicos de anamnesis/exploración se guardan por `PRUEBA_CODIGO` string, y **no he encontrado en el código el mapeo `prueba_id ↔ prueba_codigo`**.

Para implementarlo bien (sin adivinar sobre datos médicos) necesito que me confirmes el esquema real. Si puedes lanzar esto en la BD (dev) y pegarme la salida:

```sql
-- 1) Columnas del catálogo de pruebas y si tiene un código string
SELECT column_name, data_type FROM all_tab_columns
WHERE owner='VIG_SALUD' AND table_name='INF3_PRUEBAS' ORDER BY column_id;

-- 2) Columnas de INF_RESULTADOS (¿tiene PRUEBA_ID?)
SELECT column_name, data_type FROM all_tab_columns
WHERE owner='VIG_SALUD' AND table_name='INF_RESULTADOS' ORDER BY column_id;

-- 3) ¿Existe tabla de resultados/parámetros por prueba con PRUEBA_ID numérico ligada al RM?
SELECT table_name FROM all_tab_columns
WHERE owner='VIG_SALUD' AND column_name='PRUEBA_ID'
  AND table_name LIKE 'INF%RESULT%';

-- 4) ¿Dónde está el mapeo prueba_codigo (string) ↔ prueba_id (INF3_PRUEBAS.ID)?
--    (p.ej. una columna CODIGO en INF3_PRUEBAS o tabla puente)
SELECT column_name, data_type FROM all_tab_columns
WHERE owner='VIG_SALUD' AND column_name LIKE '%CODIGO%'
  AND table_name LIKE 'INF3%PRUEBA%';
```

Con esas 4 respuestas defino la query CA-14 correcta. 

Mi **hipótesis de trabajo** (para que la confirmes o corrijas), por si te resulta más rápido que pegar DESCs: una prueba configurada se considera *realizada* si
1. su `PRUEBA_ID` aparece en la(s) tabla(s) de resultados por prueba del RM (la que exista con `PRUEBA_ID` numérico), **o**
2. su código asociado tiene filas en `INF2_RM_VALORES` (con `modificado IS NULL`, como hace el resto del proyecto) — **siempre que exista** una forma de obtener el código a partir del `prueba_id`.

¿Me confirmas el esquema (las 4 consultas) o me describes cómo determina el legacy que una prueba "tiene resultados"? Con eso lo dejo correcto y reactivamos el applier.

¡Esto lo cambia todo! Tus capturas corrigen mi diagnóstico anterior:

**1) `INF3_PRUEBAS` SÍ tiene `CODIGO_PRUEBA` (VARCHAR2).** Mi suposición sobre el código era correcta; lo que estaba mal era **solo `ip.PRUEBA_ID`** (esa columna no existe; la PK es `ip.ID`, y el `prueba_id` está en `irp`).

**2) `INF_RESULTADOS`** tiene `RES_RM_ID, RES_RESULTADOS, RES_OBSERVACIONES, RES_FCH_ALTA…` → **no tiene `PRUEBA_ID`**. Es la analítica/observaciones **global por RM**, no por prueba. Mi segundo `EXISTS` era inválido.

**3)** No existe ninguna tabla `INF%RESULT%` con `PRUEBA_ID` → confirmado: no hay almacén de resultados por prueba con id numérico.

**4)** El mapeo código↔prueba es directo: `INF3_PRUEBAS.CODIGO_PRUEBA`.

### Corrección concreta

La detección CA-14 viable y autoritativa es **por `INF2_RM_VALORES` vía `CODIGO_PRUEBA`** (cuestionarios/anamnesis/exploraciones). Hay que: (a) cambiar `ip.PRUEBA_ID` → `irp.PRUEBA_ID`, y (b) **eliminar el `EXISTS` de `INF_RESULTADOS`** (no aplica por prueba). Queda así:

```sql
SELECT DISTINCT irp.PRUEBA_ID, ip.CODIGO_PRUEBA
FROM vig_salud.INF3_RM_PRUEBAS irp
JOIN vig_salud.INF3_PRUEBAS ip ON irp.PRUEBA_ID = ip.ID
WHERE irp.RM_ID = :rmId
  AND irp.BORRADO IS NULL
  AND ip.CODIGO_PRUEBA IS NOT NULL
  AND EXISTS (SELECT 1 FROM vig_salud.INF2_RM_VALORES v
              WHERE v.RM_ID = :rmId
                AND v.PRUEBA_CODIGO LIKE ip.CODIGO_PRUEBA || '%')
```

Detalle de diseño: uso `LIKE CODIGO_PRUEBA || '%'` (match por prefijo) en lugar de igualdad, porque es **conservador** — para CA-14 es preferible conservar visibilidad de más (una prueba aparecería como `MANUAL=1` y el médico puede quitarla) que perder una prueba con datos. 

**Limitación conocida (la documento con TODO):** las pruebas cuyos resultados no estén en `INF2_RM_VALORES` (p.ej. analíticas de laboratorio en tablas dinámicas por prueba) no se detectan, porque no existe un almacén genérico por `PRUEBA_ID`. Para BE-07 esto cubre el caso principal; lo demás quedaría para una iteración posterior si el negocio lo exige.

¿Aplico esta corrección en `getPruebasRealizadasByRmId` (y ajusto los comentarios de método/interfaz para reflejar que la detección es por `INF2_RM_VALORES`)?

---

**User**

si

---

**Cursor**

Aplico la corrección en `getPruebasRealizadasByRmId` y actualizo los comentarios del método y de la interfaz.

Ahora actualizo el comentario de la interfaz para reflejar que la detección es por `INF2_RM_VALORES`.

Verifico lints y compilo rrmm-utils para confirmar que todo queda correcto.

Compila correctamente (exit 0). Corrección aplicada.

## Resumen del fix

El error `ORA-00904: "IP"."PRUEBA_ID"` estaba **solo** en `getPruebasRealizadasByRmId`. Con el esquema real que me pasaste, corregí dos cosas:

1. **`ip.PRUEBA_ID` → `irp.PRUEBA_ID`**: el `prueba_id` está en `INF3_RM_PRUEBAS` (alias `irp`); la PK del catálogo es `INF3_PRUEBAS.ID`. El `CODIGO_PRUEBA` sí existe en `INF3_PRUEBAS`, así que ese enlace se mantiene.
2. **Eliminado el `EXISTS` sobre `INF_RESULTADOS`**: esa tabla guarda analítica/observaciones global por RM (`RES_RM_ID, RES_RESULTADOS, RES_OBSERVACIONES…`) y **no tiene `PRUEBA_ID`**, por lo que no sirve para detección por prueba.

Query final (detección CA-14 por `INF2_RM_VALORES` vía código de prueba, match por prefijo conservador):

```50:66:c:\Repository\rrmm-utils\src\main\java\com\preving\restapi\rrmmutils\dao\reconocimiento\reconciliacion\ReconciliacionProtocolosDaoImpl.java
        String sql = "SELECT DISTINCT irp.PRUEBA_ID, ip.CODIGO_PRUEBA "
                + "FROM vig_salud.INF3_RM_PRUEBAS irp "
                + "JOIN vig_salud.INF3_PRUEBAS ip ON irp.PRUEBA_ID = ip.ID "
                + "WHERE irp.RM_ID = :rmId "
                + "  AND irp.BORRADO IS NULL "
                + "  AND ip.CODIGO_PRUEBA IS NOT NULL "
                + "  AND EXISTS (SELECT 1 FROM vig_salud.INF2_RM_VALORES v "
                + "              WHERE v.RM_ID = :rmId AND v.PRUEBA_CODIGO LIKE ip.CODIGO_PRUEBA || '%')";
```

También actualicé los comentarios del método y de la interfaz, dejando documentada la limitación conocida (pruebas con resultados en tablas dinámicas por tipo no se detectan, al no haber almacén genérico por `PRUEBA_ID`) con un `TODO` post-BE-07.

Ya puedes volver a lanzar el `CONFIRMAR` para probar el flujo completo. Si quieres, cuando lo pruebes me pasas el log del applier (`CONFIRMAR applier ok protocolos=… pruebas=… conservadasCa14=…`) y validamos juntos el resultado en BD.

---

**User**

el todo este lo comentare con negocio o mirare si es que tienen aun pendiente algun desarrollo en la rama del alta de reonocimiento...de momento continuamos con las pruebas

---

**Cursor**

Perfecto, me parece bien dejar el TODO pendiente de validar con negocio o con la rama del alta.

Solo un recordatorio para que la prueba funcione: el fix está compilado pero necesitas **reiniciar `rrmm-utils`** (el proceso en el puerto 8081) para que cargue la query corregida. Una vez reiniciado, relanza el `CONFIRMAR` y debería pasar el applier sin el `ORA-00904`.

Aquí sigo. Cuando lo pruebes, pásame el log del applier (`CONFIRMAR applier ok protocolos=… pruebas=… conservadasCa14=…`) o cualquier error nuevo y lo revisamos.

---

**User**

que raro, para el reco 12341907 no me ha cargado pruebas en este metodo, ahora no ha dado error pero da vacio. Puedes hacerme un sql para mirar en bd si tiene pruebas 

---

**Cursor**

Claro. Te dejo una batería de SQL de diagnóstico incremental para ver exactamente en qué punto se queda vacío. Ejecútalas en orden:

```sql
-- 1) ¿Tiene pruebas configuradas (no borradas)?
SELECT COUNT(*) AS total_pruebas
FROM vig_salud.INF3_RM_PRUEBAS
WHERE rm_id = 12341907 AND borrado IS NULL;

-- 2) Pruebas configuradas + su código de catálogo (¿hay CODIGO_PRUEBA o están NULL?)
SELECT irp.prueba_id, ip.codigo_prueba, ip.nombre, irp.manual, irp.borrado
FROM vig_salud.INF3_RM_PRUEBAS irp
JOIN vig_salud.INF3_PRUEBAS ip ON irp.prueba_id = ip.id
WHERE irp.rm_id = 12341907
ORDER BY ip.codigo_prueba;

-- 3) ¿Qué hay realmente en INF2_RM_VALORES para ese RM? (códigos string)
SELECT DISTINCT prueba_codigo
FROM vig_salud.INF2_RM_VALORES
WHERE rm_id = 12341907
ORDER BY prueba_codigo;

-- 4) La query EXACTA de detección CA-14 (debe devolver lo mismo que el método)
SELECT DISTINCT irp.PRUEBA_ID, ip.CODIGO_PRUEBA
FROM vig_salud.INF3_RM_PRUEBAS irp
JOIN vig_salud.INF3_PRUEBAS ip ON irp.PRUEBA_ID = ip.ID
WHERE irp.RM_ID = 12341907
  AND irp.BORRADO IS NULL
  AND ip.CODIGO_PRUEBA IS NOT NULL
  AND EXISTS (SELECT 1 FROM vig_salud.INF2_RM_VALORES v
              WHERE v.RM_ID = 12341907
                AND v.PRUEBA_CODIGO LIKE ip.CODIGO_PRUEBA || '%');

-- 5) Cruce directo para ver coincidencias código catálogo ↔ valores (sin EXISTS)
SELECT ip.codigo_prueba AS cod_catalogo, v.prueba_codigo AS cod_valor, COUNT(*) AS valores
FROM vig_salud.INF3_RM_PRUEBAS irp
JOIN vig_salud.INF3_PRUEBAS ip ON irp.prueba_id = ip.id
JOIN vig_salud.INF2_RM_VALORES v ON v.rm_id = irp.rm_id
WHERE irp.rm_id = 12341907
  AND irp.borrado IS NULL
GROUP BY ip.codigo_prueba, v.prueba_codigo
ORDER BY ip.codigo_prueba, v.prueba_codigo;
```

Cómo interpretar el resultado:

- **(1) = 0** → el RM no tiene pruebas configuradas (raro tras el rebuild; mira si el applier limpió y no regeneró). 
- **(2) con `codigo_prueba` todo NULL** → el filtro `CODIGO_PRUEBA IS NOT NULL` las descarta todas → vacío esperado. Sería la causa más probable.
- **(3) vacío** → ese RM no tiene datos en `INF2_RM_VALORES` (sus resultados están en otro almacén, p.ej. analítica/parámetros), así que CA-14 por esta vía no detecta nada → **vacío es correcto** y no hay nada que conservar por aquí.
- **(5)** te muestra si los códigos de catálogo y los de los valores **coinciden por prefijo** o si la convención es distinta (p.ej. catálogo `HABITOS` vs valor `HAB_TABACO`), lo que explicaría por qué el `LIKE` no casa.

Pásame las salidas (sobre todo la 2, 3 y 5) y te digo si el vacío es correcto o si hay que ajustar el criterio de match.

---

**User**

la 2,3 y 5 devuelven resultados

---

**Cursor**

Necesito ver los **datos concretos**, no solo que "devuelven resultados". El punto clave es la query 5: si la 2 y la 3 tienen datos pero la 4 (con el `EXISTS ... LIKE`) da vacío, significa que **los códigos no casan en la dirección que asumí** (`v.PRUEBA_CODIGO LIKE ip.CODIGO_PRUEBA || '%'`).

Pégame por favor la salida de:

- **Query 2** (columna `codigo_prueba` del catálogo), y
- **Query 5** (el cruce `cod_catalogo` vs `cod_valor`).

Con la query 5 veré la relación real entre ambos códigos. Las posibilidades típicas son:

1. **Catálogo más específico que el valor** (p.ej. `cod_catalogo = 'HAB_TABACO'`, `cod_valor = 'HAB'`) → habría que invertir el `LIKE`: `ip.CODIGO_PRUEBA LIKE v.PRUEBA_CODIGO || '%'`.
2. **Coinciden exactos** (`'HAB_TABACO'` = `'HAB_TABACO'`) → bastaría igualdad `=`.
3. **Prefijo compartido pero con separador** (`'CONTROL_VI'` vs `'CONTROL_VI_CROM'`) → mi `LIKE` actual debería casar… salvo mayúsculas/espacios.
4. **Convención totalmente distinta** (catálogo numérico-textual vs valores con otro prefijo) → habría que mapear de otra forma.

Para descartar temas de mayúsculas/espacios, ejecuta también esta variante normalizada y dime si **ahora sí** devuelve filas:

```sql
SELECT DISTINCT irp.PRUEBA_ID, ip.CODIGO_PRUEBA
FROM vig_salud.INF3_RM_PRUEBAS irp
JOIN vig_salud.INF3_PRUEBAS ip ON irp.PRUEBA_ID = ip.ID
WHERE irp.RM_ID = 12341907
  AND irp.BORRADO IS NULL
  AND ip.CODIGO_PRUEBA IS NOT NULL
  AND EXISTS (
        SELECT 1 FROM vig_salud.INF2_RM_VALORES v
        WHERE v.RM_ID = 12341907
          AND ( UPPER(TRIM(v.PRUEBA_CODIGO)) LIKE UPPER(TRIM(ip.CODIGO_PRUEBA)) || '%'
             OR UPPER(TRIM(ip.CODIGO_PRUEBA)) LIKE UPPER(TRIM(v.PRUEBA_CODIGO)) || '%' )
      );
```

Pégame las salidas de la 2, la 5 y esta última, y con eso fijo el criterio de match correcto.

Ahora veo el problema de raíz, y es importante. Las dos columnas **no son la misma codificación**:

- **`INF3_PRUEBAS.CODIGO_PRUEBA`** (catálogo) → códigos tipo **`A-VS-01`, `A-VS-02`, `A-VS-04`** ("Antecedentes personales", "Antecedentes familiares", "Hábitos y costumbres"…).
- **`INF2_RM_VALORES.PRUEBA_CODIGO`** (datos) → códigos tipo **`ANT_PERSONALES`, `ANAM_VAC`, `HAB_TABACO`, `EXPLO_CARD`…**

La query 5 lo confirma: `A-VS-01` aparece cruzado con *todos* los códigos de valores (es un producto cartesiano), porque el JOIN de esa query no relaciona por código. Es decir, **`'ANT_PERSONALES' LIKE 'A-VS-01%'` es siempre falso** → por eso mi `EXISTS` da vacío.

Conclusión: existen **dos granularidades distintas** de "prueba". La de `INF3_RM_PRUEBAS` (formulario/sección, `A-VS-01`) y la de los campos en `INF2_RM_VALORES` (`ANT_PERSONALES`). No hay relación textual entre ambas; el vínculo está en una **tabla puente de configuración**, no en el código.

Necesito localizar esa tabla puente para enlazar `prueba_id` ↔ códigos de campo. Déjame buscarla en el código antes de pedirte nada.

Confirmado el modelo de raíz: la herencia y la lectura de datos trabajan a nivel de **`prueba_codigo` de campo** (`ANT_PERSONALES`…) enlazando por `valor_id → inf3_cf_listas_x_valores → inf3_cf_rmversion_x_listas → versión`, mientras que `INF3_RM_PRUEBAS` trabaja a nivel de **`prueba_id`/`A-VS-01`** (formulario). Además, cada prueba lee sus datos vía **SQL dinámico** (`sql_especifico`/`sql_general` de `INF3_CF_RMVERSION_X_PRUEBAS`), no por una columna.

Es decir: **no existe un enlace textual `A-VS-01 ↔ ANT_PERSONALES`**, y por eso mi `LIKE` da vacío (correctamente, dentro de su lógica equivocada). Necesitamos la **tabla puente declarativa** `prueba_id ↔ prueba_codigo (campo)` si existe. Esta consulta la encuentra:

```sql
-- Tablas que tienen A LA VEZ PRUEBA_ID y PRUEBA_CODIGO → candidata a tabla puente
SELECT table_name
FROM all_tab_columns
WHERE owner = 'VIG_SALUD' AND column_name = 'PRUEBA_ID'
INTERSECT
SELECT table_name
FROM all_tab_columns
WHERE owner = 'VIG_SALUD' AND column_name = 'PRUEBA_CODIGO'
ORDER BY 1;
```

Y, por si el puente está en la config de versión/formulario, mira también qué columnas tiene esa tabla:

```sql
SELECT column_name, data_type
FROM all_tab_columns
WHERE owner = 'VIG_SALUD' AND table_name = 'INF3_CF_RMVERSION_X_PRUEBAS'
ORDER BY column_id;
```

Según el resultado:

- **Si aparece una tabla puente** (con `PRUEBA_ID` + `PRUEBA_CODIGO`) → reescribo la detección CA-14 uniendo `INF3_RM_PRUEBAS.prueba_id → puente → INF2_RM_VALORES.prueba_codigo`. Limpio y correcto.
- **Si no existe puente declarativo** (todo va por SQL dinámico) → la detección automática por SQL estático **no es viable**, y entonces sí toca definir el criterio con negocio (como ya tenías pensado).

Importante para que sigas probando: la detección **actual devuelve vacío sin error**, así que **no bloquea el flujo**. Puedes seguir validando el rebuild de `INF3_*` + ACP + periodicidad con normalidad; CA-14 simplemente no reincorpora nada de momento. Cuando me pases el resultado de la primera consulta (la del `INTERSECT`), decido si reactivo CA-14 con el puente o lo dejamos pendiente de negocio.

¿Me pasas la salida del `INTERSECT`?

El `INTERSECT` vacío es la respuesta definitiva: **no existe ninguna tabla en `VIG_SALUD` que tenga a la vez `PRUEBA_ID` y `PRUEBA_CODIGO`**. Es decir, **no hay tabla puente** entre el `prueba_id` (formulario `A-VS-01`) y los `prueba_codigo` de campo (`ANT_PERSONALES`).

Conclusión firme:

- La detección automática de "prueba realizada" por **SQL estático no es viable** con este modelo. El vínculo prueba→datos se resuelve por **SQL dinámico** (`sql_especifico`/`sql_general` por prueba), que no se puede generalizar en una sola consulta.
- Esto cae justo en lo que ibas a **consultar con negocio / la rama del alta**: hay que definir cuál es el criterio real de "prueba realizada" (o si CA-14 debe basarse en otra señal, p.ej. anulaciones, `MANUAL`, herencia, etc.).

Mi recomendación para no dejar código engañoso mientras tanto: como la query actual está conceptualmente mal (enlaza dos codificaciones que no casan) aunque sea inofensiva, dejar el método **devolviendo lista vacía de forma explícita** con un comentario que documente este hallazgo (no hay puente `prueba_id↔prueba_codigo`, pendiente de criterio de negocio). Así:

- El applier sigue funcionando (rebuild + ACP + periodicidad) y puedes seguir probando.
- CA-14 queda claramente marcado como "pendiente de definición", sin una query que aparenta hacer algo que no hace.
- Cuando negocio confirme el criterio, se implementa limpio.

¿Quieres que deje `getPruebasRealizadasByRmId` devolviendo vacío explícito con esa conclusión documentada (y un `TODO` claro), o prefieres mantener la query tal cual hasta hablar con negocio?

Esto cierra el análisis. `INF3_CF_RMVERSION_X_PRUEBAS` tiene `ID, RM_VERSION, PRUEBA_ID, FORM_VERSION, SQL_ESPECIFICO, SQL_GENERAL` — relaciona la prueba con su **versión y su SQL de lectura**, pero **no tiene `PRUEBA_CODIGO`**. El código de campo (`ANT_PERSONALES`…) va **embebido dentro del texto** de `SQL_ESPECIFICO`/`SQL_GENERAL`, no en una columna consultable.

Conclusión definitiva:

- **No hay forma estática/declarativa** de saber, dado un `prueba_id`, qué datos tiene en `INF2_RM_VALORES`. El mapeo solo existe dentro del SQL dinámico de cada prueba.
- Por tanto, **la detección automática de "prueba realizada" para CA-14 no es implementable de forma genérica** ahora. Es, como anticipabas, una decisión de **negocio** (definir el criterio real) o algo a alinear con la **rama del alta**.

Mi recomendación se mantiene: dejar `getPruebasRealizadasByRmId` **devolviendo vacío de forma explícita** con la conclusión documentada (no hay puente `prueba_id ↔ prueba_codigo`; pendiente de criterio de negocio), en lugar de mantener una query que aparenta detectar y no puede. El flujo (rebuild + ACP + periodicidad) sigue funcionando y puedes seguir probando.

¿Lo dejo así (vacío explícito + `TODO`/comentario con esta conclusión) o prefieres mantener la query actual hasta que hables con negocio?

---

**User**

pero me surge una duda ahora, si lo del CA-14 esos datos que no tenemos que eliminar estan en otras tablas que no son las de config, porque tenemos que recuperarlos antes del rebuild? es necesario?

---

**Cursor**

Muy buena duda, y vas bien encaminado. Separemos **datos** de **visibilidad**, porque ahí está la clave.

## Lo que el rebuild toca y lo que no

- El rebuild solo limpia/regenera las **7 tablas de configuración** `INF3_RM_*` (qué protocolos/pruebas/perfiles… están *asignados* al reco).
- Los **resultados clínicos** viven en otras tablas (`INF2_RM_VALORES`, `INF_RESULTADOS`, etc.) y **nunca se tocan**. Eso es correcto: **los datos no se pierden** con el rebuild.

Así que tienes razón: **no hay que "recuperar datos"**, porque no se borran.

## Entonces, ¿para qué sirve CA-14?

No es para recuperar datos, sino para **preservar la visibilidad** de la prueba en el reconocimiento. Y esto sí depende de `INF3_RM_PRUEBAS`. Lo confirma cómo el propio proyecto construye el índice de pruebas del reco:

```1507:1539:c:\Repository\rrmm-utils\src\main\java\com\preving\restapi\rrmmutils\dao\reconocimiento\ReconocimientosDaoImpl.java
    public List getIndiceByRmId(int rmId, String idiomaCod) {
        String sql ="SELECT ... " +
                "FROM " +
                "  ( SELECT DISTINCT prueba_id, rm_id, borrado FROM VIG_SALUD.inf3_rm_pruebas" +
                "  ) t, " +
                ...
                "AND t.borrado is null " +
                "ORDER BY t1.nivel_orden, t1.item_orden ";
```

El índice de pruebas del reco **se construye desde `INF3_RM_PRUEBAS`**. Por tanto:

- Si el nuevo puesto **incluye** la prueba → se regenera su fila de config, sigue visible y sus datos en `INF2` re-enlazan solos por `rm_id + prueba_codigo`. Perfecto.
- Si el nuevo puesto **NO incluye** una prueba que tenía datos → su fila de config no se regenera → **desaparece del índice**, y aunque sus datos sigan en `INF2`, quedarían **"huérfanos" e inaccesibles** desde la pantalla del reco.

CA-14 reinserta esa fila como `MANUAL=1` *solo* para que la prueba **siga apareciendo** y el médico vea/acceda a sus datos ya registrados.

## Sobre "¿antes del rebuild?"

La detección se hace **antes** solo para capturar el estado previo; la reincorporación es **después** de regenerar (comparando contra lo que la nueva config ya trae). Pero como `INF2` no se toca, el momento de detección es indiferente; podría hacerse después igual.

## La pregunta de fondo (que es la de negocio)

Tu intuición apunta a lo correcto: **¿realmente importa esa pérdida de visibilidad?** Eso es exactamente lo que conviene confirmar con negocio. Posibles posturas:

1. **Sí importa** (lo que asume CA-14): no se debe ocultar una prueba ya realizada → hay que reincorporarla. Riesgo adicional: datos "huérfanos" podrían afectar a la finalización/validación o a informes.
2. **No importa en la práctica**: si el cambio de puesto implica una nueva configuración, quizá el negocio acepte que pruebas no aplicables al nuevo puesto dejen de mostrarse (sus datos siguen en BD para auditoría).

Si negocio dice que **no** es necesario preservar esa visibilidad, entonces **CA-14 sobra** y podemos eliminar toda la maquinaria de detección/reincorporación (más simple y robusto). Si dice que **sí**, necesitamos que definan el criterio de "prueba realizada" (que, como vimos, no es deducible por SQL estático).

Mi sugerencia: deja la pregunta planteada a negocio en esos términos exactos (visibilidad, no datos), y mientras tanto seguimos probando con la detección en vacío. ¿Quieres que lo dejemos así y lo documente como decisión pendiente?

---

**User**

es necesario el CA-14 preservar datos antigups de pruebas....y si recuperamos por tema visibilidad, debemoso encontrar la manera de recuperarlos de forma correcta

---

**Cursor**

Conclusión clara: **mantenemos CA-14 (visibilidad)** y hay que recuperar correctamente. Como el modelo no permite detección estática por SQL, la vía correcta y más segura es **reutilizar el mecanismo que ya existe en el flujo de alta con herencia** — ese flujo ya resuelve un problema análogo: "traer al reco nuevo las pruebas/datos del reco anterior". Si entiendo cómo el alta decide *qué pruebas con datos* heredar y cómo las mapea, replico ese criterio (en línea con tu preferencia de basarnos en lo existente).

Déjame investigar ese mecanismo de herencia en el código.

Esto es muy esclarecedor. El mecanismo de herencia del alta **no es genérico**: trata explícitamente **solo 3 pruebas** (anamnesis, hábitos y costumbres, control visión) con lógica *hardcodeada por versión* y **prefijos de código fijos** (`PREFIJO_ANAM`, `PREFIJO_ANT`, `PREFIJO_HAB`…). Es decir, el mapeo `prueba_id ↔ prueba_codigo` **vive hardcodeado en el código**, no en BD. Veo además un método decisor `seDebenCopiarDatosPruebaAnterior(rmId, PRUEBA_X)`. Lo reviso para confirmar qué evalúa.

Confirmado del todo. Mira qué hace el decisor del alta:

```61:78:c:\Repository\rrmm-utils\src\main\java\com\preving\restapi\rrmmutils\dao\reconocimiento\alta\HerenciaReconocimientoAnteriorDaoImpl.java
    public boolean seDebenCopiarDatosPruebaAnterior(int reconocimientoMedicoActualId, int tipoPrueba) {
        List<Integer> pruebaiIds;
        if (tipoPrueba == PRUEBA_ANAMNESIS) {
            pruebaiIds = anamnesisPruebasIds;
        } else if (tipoPrueba == PRUEBA_HABITOS_Y_COSTUMBRES) {
            pruebaiIds = habitosYCostumbresPruebasIds;
        } else if (tipoPrueba == PRUEBA_CONTROL_VISION) {
            pruebaiIds = controlVisionIds;
        } else {
            return false;
        }
        String sql = "SELECT COUNT(ID) FROM vig_salud.inf3_rm_pruebas WHERE rm_id = :reconocimientoMedicoId AND prueba_id IN (:pruebaiIds)";
        ...
    }
```

## Qué nos dice esto

El legacy **no tiene un mecanismo genérico** de "pruebas con datos". Lo resuelve de forma totalmente ad-hoc:

- El mapeo `prueba_id ↔ prueba_codigo` está **hardcodeado** (constantes `PREFIJO_ANAM`, `PREFIJO_HAB`, listas `anamnesisPruebasIds`…), y **solo** para 3 pruebas: anamnesis, hábitos y costumbres, control visión.
- La lectura de datos de cada prueba se hace por **SQL dinámico** (`sql_especifico`/`sql_general`), no por una relación consultable.

Por tanto, "recuperar de forma correcta" en CA-14 tiene **dos caminos reales**, y ninguno es trivial:

**Opción A — Genérica por SQL dinámico**
Para cada prueba configurada, ejecutar su `sql_especifico`/`sql_general` (de `INF3_CF_RMVERSION_X_PRUEBAS`) y ver si devuelve datos.
- ✅ Cubre todas las pruebas.
- ❌ Costoso (N consultas dinámicas por reco), frágil (SQL embebido en BD), y mete ejecución de SQL dinámico en el applier.

**Opción B — Acotada a pruebas conocidas (reutilizando lo existente)**
Limitar CA-14 a las pruebas que el sistema ya sabe mapear (anamnesis, hábitos, control visión…) usando esas constantes/listas.
- ✅ Simple, reutiliza el mecanismo del alta, robusto.
- ❌ Parcial: no cubre pruebas fuera de ese set.

## Mi lectura (importante para la decisión)

El cambio de puesto opera sobre un reco **PENDIENTE**. En un pendiente, los datos que existen suelen venir de la **herencia del alta** → precisamente anamnesis, hábitos y control visión. Es decir, la **Opción B cubriría el caso real más habitual** reutilizando exactamente la maquinaria existente, sin SQL dinámico.

## Recomendación

Esto ya es claramente **decisión de negocio + alcance**:

1. ¿CA-14 debe cubrir **todas** las pruebas (→ Opción A, asumiendo su coste) o basta con las **heredables/conocidas** (→ Opción B)?
2. ¿O negocio acepta que, al cambiar de puesto, las pruebas no aplicables al nuevo puesto dejen de mostrarse (sus datos quedan en BD para auditoría) y **CA-14 se reduce/elimina**?

Yo llevaría a negocio esta foto concreta. Mientras tanto, la detección sigue en vacío (no bloquea) y puedes probar el resto.

¿Quieres que prepare una **nota de decisión** (resumen técnico para negocio con estas 2 opciones y el coste de cada una), o exploramos ya la **Opción B** dejándola lista a la espera de su confirmación?

---

**User**

dime que necesitas de bd y te paso

---

**Cursor**

Perfecto. Necesito **dos consultas** que me den el mapa real de dónde viven los datos clínicos y cómo se identifican. Con eso decido el enfoque correcto de CA-14 con fundamento.

### Consulta 1 — Inventario de almacenes ligados al RM (la más importante)

Lista todas las tablas de `VIG_SALUD` que cuelgan de un reconocimiento y si identifican la prueba por **id** o por **código**:

```sql
SELECT c.table_name,
       MAX(CASE WHEN c.column_name IN ('RM_ID','RES_RM_ID') THEN c.column_name END) AS col_rm,
       MAX(CASE WHEN c.column_name = 'PRUEBA_ID'      THEN 'SI' END) AS tiene_prueba_id,
       MAX(CASE WHEN c.column_name = 'PRUEBA_CODIGO'  THEN 'SI' END) AS tiene_prueba_codigo
FROM all_tab_columns c
WHERE c.owner = 'VIG_SALUD'
  AND c.column_name IN ('RM_ID','RES_RM_ID','PRUEBA_ID','PRUEBA_CODIGO')
GROUP BY c.table_name
HAVING MAX(CASE WHEN c.column_name IN ('RM_ID','RES_RM_ID') THEN 1 ELSE 0 END) = 1
ORDER BY c.table_name;
```

Esto me dice **cuántos almacenes de datos hay**, cuáles se enlazan por `PRUEBA_ID` (detectables fácil) y cuáles por `PRUEBA_CODIGO` (los problemáticos como `INF2`).

### Consulta 2 — Ejemplos del SQL dinámico de lectura

Para ver si la lectura por prueba es **uniforme** (siempre sobre `INF2_RM_VALORES` filtrando un `prueba_codigo`) o **heterogénea** (cada prueba lee de su propia tabla):

```sql
SELECT prueba_id, sql_especifico, sql_general
FROM vig_salud.inf3_cf_rmversion_x_pruebas
WHERE rm_version = (SELECT version FROM vig_salud.inf_rm WHERE rm_id = 12341907)
  AND ROWNUM <= 8;
```

### Qué decidiré con cada una

- **Si la Consulta 1** muestra que casi todos los datos cuelgan por `PRUEBA_ID` (y solo `INF2` por código) → CA-14 se puede hacer **genérico y limpio**: detectar `prueba_id` con filas en esos almacenes + tratar `INF2` con el set conocido. Sería la solución correcta sin SQL dinámico.
- **Si la Consulta 2** muestra que el `sql_especifico` es uniforme (p.ej. siempre `... FROM inf2_rm_valores WHERE rm_id=? AND prueba_codigo LIKE '<código>%'`) → ahí está, embebido, el **mapeo `prueba_id → prueba_codigo`** que buscábamos, y podríamos extraerlo de forma controlada.

Pásame las salidas de las dos (la 1 entera, y de la 2 con 4-5 ejemplos me vale) y te digo el enfoque definitivo.

---

**User**

consulta 1:
AFFECTED_RM_X_CFG	RM_ID		
BK_INF_RM	RM_ID		
CUES_RM_VALORES	RM_ID		
DATOS_ULTIMO_RESULTADO	RM_ID		
DATOS_ULTIMO_RM	RM_ID		
EPID_DATOS_TRABAJADORES	RM_ID		
EPID_DATOS_TRABAJADORES_CA	RM_ID		
EPID_DATOS_TRAB_ALL_APT	RM_ID		
INF_CUESTIONARIO_ANULADOS	RM_ID		
INF_CUESTIONARIOS	RM_ID		
INF_ESTUDIOS_ANALITICOS	RM_ID		
INF_PRUEBAS_ANULADAS	RM_ID	SI	
INF_RESULTADOS	RES_RM_ID		
INF_RM	RM_ID		
INF_RM_CAE_LOG	RM_ID		
INF_RM_CF	RM_ID		
INF_RM_DATOS_ENVIOS	RM_ID		
INF_RM_DATOS_ENVIOS_LOG	RM_ID		
INF_RM_EN_PROCESO	RM_ID		
INF_RM_IDEMIO	RM_ID		
INF_RM_LOG	RM_ID		
INF_RM_PTOS_ADICIONALES	RM_ID		
INF_RM_TMP_X_CLECE	RM_ID		
INF_RM_USERS	RM_ID		
INF2_ANT_LABORALES	RM_ID		
INF2_OTRAS_EXP	RM_ID		
INF2_RM_RECOMENDACIONES_VLR	RM_ID		
INF2_RM_VALORES	RM_ID		SI
INF2_RM_X_ENFERMEROS	RM_ID		
INF2_RM_X_ENFERMEROS_LOGS	RM_ID		
INF3_ESPIROMETRIA_POST	RM_ID		
INF3_IRC	RM_ID		
INF3_RM_ANEXOS	RM_ID		
INF3_RM_CUESTIONARIOS	RM_ID		
INF3_RM_IPROMES	RM_ID		
INF3_RM_PARAMETROS	RM_ID		
INF3_RM_PERFILES	RM_ID		
INF3_RM_PRODUCTOS_QUIMICOS	RM_ID		
INF3_RM_PROTOCOLOS	RM_ID		
INF3_RM_PRUEBAS	RM_ID	SI	
INF3_RUFFIER	RM_ID		
INF4_RM_APTOS_PROV_X_VALORES	RM_ID		
INF4_RM_LOG	RM_ID		
INF4_RM_LOG_CAMBIO_PUESTO	RM_ID		
MUESTRA_EPID_TEMP	RM_ID		
MUESTRA_ESTUDIO_EPIDEMIOLOGICO	RM_ID		
SMARTOSH_X_RMS	RM_ID		
VIG_INF_PRUEBAS	RM_ID		
VS_01_01	RM_ID		
VS_01_02	RM_ID		
VS_01_03	RM_ID		
VS_02_01	RM_ID		
VS_02_02	RM_ID		
VS_02_03	RM_ID		
VS_02_04	RM_ID		
VS_03_01	RM_ID		
VS_03_02	RM_ID		
VS_03_03	RM_ID		
VS_04_01	RM_ID		
VS_04_02	RM_ID		
VS_05_01	RM_ID		
VS_05_02	RM_ID		
VS_05_03	RM_ID		
VS_06_01	RM_ID		
VS_06_02	RM_ID		
VS_06_03	RM_ID		
VS_07_01	RM_ID		
VS_07_02	RM_ID		
VS_09_01	RM_ID		
VS_09_02	RM_ID		
VS_09_03	RM_ID		
VS_09_04	RM_ID		
VS_09_05	RM_ID		
VS_09_06	RM_ID		
VS_10_01	RM_ID		
VS_10_02	RM_ID		
VS_10_03	RM_ID		
VS_10_04	RM_ID		
VS_11_01	RM_ID		
VS_11_02	RM_ID		
VS_12_01	RM_ID		
VS_12_01_PUESTOS_PREVIOS	RM_ID		
VS_12_02	RM_ID		
VS_12_03	RM_ID		
VS_13_01	RM_ID		
VS_13_01_VIAJES_EXTRANJERO	RM_ID		
VS_13_02	RM_ID		
VS_13_02_PROFILAXIS	RM_ID		
VS_13_03	RM_ID		
VS_14_01	RM_ID		
VS_14_02	RM_ID		
VS_15_01	RM_ID		
VS_15_02	RM_ID		
VS_16_01	RM_ID		

consulta 2:
2		
3		
1		
4		
6		
7		
8		
9		

---

**Cursor**

Excelente, la Consulta 1 es muy informativa. Vamos a leerla bien:

## Lo que revela el inventario

- **Solo 3 tablas** usan identificador de prueba: `INF3_RM_PRUEBAS` (config) y `INF_PRUEBAS_ANULADAS` por `PRUEBA_ID`; `INF2_RM_VALORES` por `PRUEBA_CODIGO`.
- **Todo el resto de datos clínicos cuelga solo de `RM_ID`**, repartido en decenas de tablas:
  - La familia **`VS_01_01` … `VS_16_01`** (≈70 tablas). Esto encaja con los códigos de catálogo `A-VS-NN`: **`CODIGO_PRUEBA = 'A-VS-01'` ↔ tablas `VS_01_*`**, `'A-VS-02'` ↔ `VS_02_*`, etc.
  - Pruebas específicas: `INF3_ESPIROMETRIA_POST`, `INF3_IRC`, `INF3_RUFFIER`, `INF_ESTUDIOS_ANALITICOS`, `INF2_ANT_LABORALES`, `INF2_OTRAS_EXP`, cuestionarios (`INF_CUESTIONARIOS`, `CUES_RM_VALORES`)…

## La conclusión técnica

No hay un identificador de prueba común. El conocimiento de "dónde están los datos de la prueba X" está **encapsulado en el `sql_especifico`/`sql_general`** de cada prueba (que sabe leer de `VS_NN_*`, `INF2`, `INF3_IRC`, etc.). 

Por eso el **único camino genérico correcto es la Opción A** (ejecutar ese SQL por prueba) — y por eso es costosa. La pista buena es que `CODIGO_PRUEBA = 'A-VS-NN'` mapea por convención a las tablas `VS_NN_*`, pero explotarlo sigue implicando SQL dinámico por nombre de tabla.

## Lo que me falta para cerrar la recomendación

La Consulta 2 solo te trajo la columna `prueba_id` (el texto de `SQL_ESPECIFICO`/`SQL_GENERAL` no se copió). Necesito **ver ese texto** para confirmar el patrón. Pásame:

```sql
SELECT prueba_id, sql_especifico, sql_general
FROM vig_salud.inf3_cf_rmversion_x_pruebas
WHERE rm_version = (SELECT version FROM vig_salud.inf_rm WHERE rm_id = 12341907)
  AND prueba_id IN (1, 4);
```

…y cópiame el **contenido de las columnas `sql_especifico` y `sql_general`** (no solo el id).

Con eso confirmo:

- Si el SQL es uniforme y predecible (p.ej. `SELECT ... FROM VS_01_01 WHERE rm_id = ?`) → CA-14 genérico por Opción A/convención `VS_NN` es factible aunque dinámico.
- Si es heterogéneo/complejo → confirmaría que CA-14 genérico no compensa y que la vía sensata es **Opción B acotada** (anamnesis/hábitos/visión) o **diferir** la decisión a negocio.

Mi recomendación preliminar, a falta de ese texto: dado el nivel de dispersión (≈90 almacenes con convenciones distintas), **CA-14 genérico es caro y frágil**; lo razonable es acotarlo (Opción B) o diferirlo con negocio. Pásame el SQL de las pruebas 1 y 4 y lo confirmamos.

Esto cierra la investigación de forma concluyente: `SQL_ESPECIFICO` y `SQL_GENERAL` están **NULL** para todas las pruebas de la versión de este reco. Es decir, **ni siquiera existe SQL dinámico** que indique dónde están los datos de cada prueba en esta versión.

## Conclusión definitiva del modelo

El "dónde viven los datos de cada prueba" **no es deducible automáticamente** por ningún medio consultable:

- No hay identificador de prueba común (solo `INF2` por código e `INF_PRUEBAS_ANULADAS`/`INF3_RM_PRUEBAS` por id).
- No hay tabla puente `prueba_id ↔ prueba_codigo`.
- El SQL dinámico de lectura está **NULL**.
- El conocimiento real está **hardcodeado en la aplicación** (convención `A-VS-NN` → tablas `VS_NN_*`, y mapeos fijos tipo anamnesis→`ANAM`/`ANT`, hábitos→`HAB`…).

→ **CA-14 con detección automática genérica no es viable de forma limpia ni mantenible.** Cualquier intento sería una colección frágil de reglas hardcodeadas replicando lógica dispersa del legacy.

## Resumen ejecutivo para negocio (listo para trasladar)

> **Contexto:** Al confirmar un cambio de puesto, se regenera la configuración de pruebas del reconocimiento (`INF3_RM_*`). Los **datos clínicos no se borran** (viven en otras ~90 tablas y permanecen intactos).
>
> **Riesgo (CA-14):** Una prueba que tenía datos y que el nuevo puesto no incluye dejaría de **mostrarse** en el reconocimiento (sus datos siguen en BD, pero no visibles desde la pantalla).
>
> **Hallazgo técnico:** No existe forma fiable/automática de saber qué pruebas "tienen datos": el conocimiento está disperso y hardcodeado, sin identificador común ni SQL declarativo.
>
> **Decisiones a tomar por negocio:**
> 1. ¿Es aceptable que, al cambiar de puesto, las pruebas no aplicables al nuevo puesto **dejen de mostrarse** (datos conservados en BD para auditoría)? → CA-14 se **elimina/reduce**, solución simple y robusta.
> 2. Si **debe** preservarse la visibilidad: ¿para **todas** las pruebas (coste alto, frágil) o basta con las **principales** (anamnesis, hábitos, control visión…)? → Opción acotada reutilizando lo existente.

## Mientras tanto

La detección sigue **en vacío** (no bloquea); el rebuild + ACP + periodicidad funcionan y puedes seguir probando el flujo.

¿Cómo quieres que proceda?

> **Confirmado que CA-14 genérico no es viable de forma limpia. ¿Cómo seguimos?**
> - (Recomendada) Dejar CA-14 en vacío y esperar decisión de negocio. Documento el método con la conclusión y un TODO, y seguimos probando el resto del flujo.
> - Implementar ya la Opción B acotada (preservar solo anamnesis, hábitos y control visión reutilizando los mapeos/listas hardcodeadas existentes), a la espera de validación de negocio.
> - Eliminar la maquinaria CA-14 (detección/reincorporación) y dejar el applier más simple, asumiendo que los datos quedan en BD para auditoría.
>
> Answer: vamos con la b pero con un TODO de investigar con negocio el resto de pruebas

Vamos con la Opción B + TODO para negocio. Primero leo las definiciones reales que voy a reutilizar: las listas de `prueba_id` conocidas y los prefijos de código en `INF2`.

Las listas son configurables (`rrmm.herencia.*` con defaults `1,2,3` anamnesis, `4` hábitos, `22` control visión). Ahora leo los prefijos `INF2` y constantes en `RmCodes`.

Tengo el mapeo. Las constantes `PRUEBA_*` (1,2,22) son tipos legacy; las listas reales de catálogo son las `@Value` (`1,2,3` / `4` / `22`) y los prefijos `INF2` son `ANAM`/`ANT`/`HAB`/`CONTROL_VI`. Leo el estado actual del DAO impl para implementar la Opción B encima.

El usuario eligió Opción B con TODO para negocio. Implemento la detección acotada (anamnesis, hábitos, control visión) reutilizando las mismas properties `rrmm.herencia.*` y los prefijos `INF2`.

Ahora reescribo `getPruebasRealizadasByRmId` con la detección acotada por grupos y su helper.

Importé `Map` pero no lo uso. Lo elimino.

Ahora actualizo el Javadoc de la interfaz del DAO para reflejar el alcance acotado de CA-14, y reviso si hay tests del DAO que dependan del comportamiento anterior.

Reviso si existe un test del DAO que dependa del comportamiento anterior.

Solo hay test del servicio (que mockea el DAO), no del DAO impl, así que el cambio interno no rompe tests existentes. Verifico lints y compilo `rrmm-utils`.

Compila correctamente. Ejecuto el test del servicio de reconciliación para confirmar que sigue verde.

Listo (exit 0; el mensaje es solo un warning de la JVM, no un fallo).

## Resumen — CA-14 Opción B implementada

He cambiado la detección de pruebas "realizadas" de un intento genérico (que daba vacío/erróneo) a una **detección acotada y fiable** por bloques conocidos, reutilizando exactamente las convenciones de la herencia de RM anterior.

**Qué hace ahora `getPruebasRealizadasByRmId` (en `ReconciliacionProtocolosDaoImpl`):**
- Detecta, entre las pruebas configuradas antes del rebuild, las de tres bloques cuyo modelo de datos sí conocemos:
  - **Anamnesis/antecedentes** (`prueba_id` `1,2,3`) → datos `INF2` con prefijo `ANAM`/`ANT`
  - **Hábitos y costumbres** (`prueba_id` `4`) → prefijo `HAB`
  - **Control de visión** (`prueba_id` `22`) → prefijo `CONTROL_VI`
- Las listas de `prueba_id` se leen de las **mismas properties** que ya usa la herencia (`rrmm.herencia.*`, con sus defaults), así que no se duplican valores hardcodeados y son configurables por entorno.
- Criterio conservador (match por prefijo y por grupo): solo gobierna **visibilidad**, nunca borra datos.

**TODO de negocio** documentado en el método y en la interfaz: confirmar si la visibilidad debe preservarse para **todas** las pruebas con datos (requeriría inventariar el almacén real disperso entre `VS_NN_*`, lógica hardcoded y SQL dinámico) o si basta con estos bloques principales; según esa decisión, se amplían los grupos.

**Verificación:**
- `compileJava` → OK
- Test `AplicarProtocolosReconocimientoServiceImplTest` → verde (el servicio mockea el DAO, no se ve afectado; no existe test del DAO impl que dependiera del SQL anterior).

Con esto el applier ya preserva la visibilidad de los bloques clínicos principales tras el cambio de puesto, y puedes seguir probando el flujo E2E. ¿Quieres que probemos ahora el flujo completo contra el reco `12341907`?

---

**User**

vale antes hazme un mini resumen de que pedir a negocio y equipo tecnico

---

**Cursor**

Aquí tienes el guion para llevar a las dos reuniones.

## Para NEGOCIO (decisión funcional de CA-14)

**Contexto en una frase:** al confirmar un cambio de puesto se regenera la configuración de pruebas del reconocimiento; los datos clínicos no se borran, pero una prueba que ya no aplique al nuevo puesto podría dejar de **mostrarse** aunque tenga datos.

**Lo que hay que decidir:**
1. ¿Es aceptable que las pruebas no aplicables al puesto nuevo **dejen de verse** (datos conservados en BD para auditoría)? → CA-14 mínimo, solución simple.
2. Si **debe** preservarse la visibilidad: ¿para **todas** las pruebas con datos, o basta con los **bloques principales** (anamnesis/antecedentes, hábitos, control de visión) que ya cubrimos?
3. Definición de "prueba realizada" a efectos de visibilidad: ¿basta con que tenga *algún* dato registrado, o solo si está validada/finalizada?
4. ¿Qué experiencia se espera en pantalla para una prueba conservada que ya no pertenece al puesto? (¿aparece marcada/heredada, editable o solo lectura?)

## Para EQUIPO TÉCNICO (cierre del modelo de datos)

**Problema:** no hay enlace declarativo y genérico `PRUEBA_ID` (catálogo `INF3_PRUEBAS`, p.ej. `A-VS-01`) ↔ `PRUEBA_CODIGO` (`INF2_RM_VALORES`, p.ej. `ANT_PERSONALES`). El SQL dinámico de `INF3_CF_RMVERSION_X_PRUEBAS` viene **NULL** para estas versiones.

**Lo que hay que confirmar:**
1. ¿Existe en algún sitio un **mapa autoritativo** prueba ↔ almacén de datos (tabla, vista, configuración), o realmente está disperso entre convención de nombres `VS_NN_*` + código hardcoded?
2. Si es genérico lo que se quiere: ¿cómo determina **el resto del sistema** (pantalla del RM, informes) que una prueba "tiene datos"? Reutilizar ese mismo mecanismo en lugar de reinventarlo.
3. ¿Hay desarrollo pendiente o previsto en la rama de **alta de reconocimiento** que normalice este mapeo? (evitar duplicar esfuerzo).
4. Validar que el alcance acotado actual (3 bloques, reusando las properties `rrmm.herencia.*`) es la convención correcta y estable.

## Estado actual (para ambas)
- Ya implementado: preservación de visibilidad para **anamnesis/antecedentes, hábitos y control de visión** (reutilizando las listas/prefijos de la herencia de RM anterior).
- El resto queda fuera, con `TODO` documentado, a la espera de estas decisiones.

¿Quieres que lo deje como nota breve en un documento del proyecto (p.ej. en `estimaciones/cambios-pueesto/`) para adjuntarlo a las reuniones, o lo dejamos solo aquí en el chat?

---

**User**

me han pasado el archivo que gemini transcrivio en la reunion de este proyecto, por si te vale, aunque no es nada tecnico, revisar lo de las pruebas a mantener: @estimaciones/cambios-pueesto/Cambio de puestos - Notas de Gemini.md 

---

**Cursor**

Muy útil. Esto cambia el enfoque de CA-14. Déjame contrastar con lo implementado: hay tres apuntes clave en las notas.

- **Línea 56 (Gestión de pruebas ya realizadas):** define funcionalmente qué hay que conservar → *"las pruebas ya han sido realizadas y marcadas con un registro (**check verde**)... las pruebas ya ejecutadas y documentadas no deben eliminarse"*.
- **Línea 60 (pruebas no correspondientes):** *"El grupo decide **no complicar** el desarrollo con [un indicador visual] por ahora y mantener el funcionamiento actual"*.
- **Líneas 58/70 (merge):** confirman la estrategia de rebuild+merge "respetando lo ya realizado y eliminando solo lo que no corresponde".

Esto me dice que la señal autoritativa **no es "tiene datos en `INF2` por prefijo"** (mi heurística acotada actual), sino **"prueba marcada como realizada = check verde"**. Voy a verificar si ese check verde es un dato directo y consultable en el modelo (mucho más robusto que los prefijos).

El grep no encuentra un campo literal tipo "realizada/check", lo que confirma que el "check verde" es **derivado**, no un flag directo. Reviso cómo el sistema construye el índice de pruebas visible (que es lo que pinta ese check) en `getIndiceByRmId`.

Revisado. Las notas aportan tres aclaraciones importantes sobre "las pruebas a mantener" que afinan (y en parte simplifican) lo que tenemos.

## Qué confirman las notas

1. **CA-14 es requisito firme y con definición funcional clara** (línea 56): se conservan *"las pruebas ya realizadas y marcadas con un registro (**check verde**)... ya ejecutadas y documentadas"*. → La señal funcional no es "tiene cualquier dato", sino **prueba marcada como realizada (check verde)**.
2. **Sin indicador visual** (línea 60): el grupo decidió *no* marcar de forma especial las pruebas que se mantienen pero ya no corresponden al puesto → *"mantener el funcionamiento actual"*. Esto **valida nuestra reinserción `MANUAL=1`**: la prueba reaparece como una más, sin tratamiento visual extra. Menos trabajo.
3. **Estrategia merge** (líneas 58/70): "respetando lo ya realizado y eliminando solo lo que no corresponde". Nuestro rebuild + reincorporación de conservadas produce ese mismo resultado neto.

## Lo que esto implica para nuestro código

Mi heurística actual (datos en `INF2` por prefijo, 3 bloques) es una **aproximación segura pero no idéntica** a la fuente real del "check verde". Investigando `getIndiceByRmId` confirmo que **no existe un flag único "realizada"**: el índice de pruebas se arma desde `inf3_rm_pruebas` + `inf3_pruebas.EXISTE`, y el check verde se calcula por prueba de forma derivada/dispersa. Por eso una solución genérica sigue sin ser viable, pero ahora sabemos **exactamente qué pedir**.

## Guion revisado para las reuniones

**NEGOCIO** (ya casi resuelto por las notas, solo confirmar):
- Confirmar que "mantener" = pruebas con **check verde** (realizadas/documentadas), no cualquier prueba con algún dato suelto.
- Confirmar que **no** hay que distinguir visualmente las conservadas (las notas dicen que no, pero la línea 82 deja la puerta abierta a "notas aclaratorias"; cerrar si aplica o no).

**EQUIPO TÉCNICO (Felix — ya tiene asignado "proveer fuente de protocolos" y "documentar datos técnicos", líneas 30 y 40):**
- **Pregunta central:** ¿cuál es la **lógica/fuente exacta que determina el "check verde"** de cada prueba en la pantalla del reconocimiento? (endpoint, vista, columna o regla). Esa es la señal que CA-14 debe reutilizar para ser fiel a lo que ve el usuario.
- ¿Es esa lógica reutilizable desde `rrmm-utils`, o conviene exponer un método común?
- Confirmar si nuestro alcance acotado (anamnesis/antecedentes, hábitos, control de visión) cubre los casos reales frecuentes mientras se decide el resto.

## Estado
Lo implementado es coherente con lo acordado (conservar realizadas sin marca especial). Solo queda **sustituir la heurística por la fuente real del check verde** cuando el técnico la facilite.

¿Quieres que actualice el `TODO` del código para fijar esta definición ("check verde" + referencia a `getIndiceByRmId`/fuente a confirmar), de modo que quede anclado para cuando retomemos? Lo dejo solo si me das luz verde.

---

**User**

si actualiza por favor y haz un resumen de por donde vamos. De mientras yo probare en local el flujo del confirmar

---

**Cursor**

Voy con la actualización del `TODO` para anclar la definición "check verde" y la fuente real a confirmar.

Ahora actualizo el Javadoc de la interfaz para que quede coherente con la definición "check verde".

Cambios solo en comentarios/Javadoc. Verifico lints y compilo para asegurar.

`TODO` actualizado y compilando (exit 0). Aquí tienes el resumen de estado mientras pruebas el `confirmar` en local.

## Por dónde vamos — BE-07 (materialización de protocolos en cambio de puesto)

### Completado y compilando

**`rrmm-utils` (motor de materialización):**
- DTOs `AplicarProtocolosRequest/Response` + internos (`PruebaRealizada`, `ConteoConfiguracionInf3`).
- `ReconciliacionProtocolosDao(+Impl)`: limpieza de las 7 tablas `INF3_RM_*` (excluye `INF3_RM_ANEXOS`), detección CA-14, reinserción de conservadas (`MANUAL=1`), conteo y refresco de metadatos ACP **sin tocar MC/MT**.
- `AplicarProtocolosReconocimientoService(+Impl)`: transaccional e idempotente; orquesta rebuild → CA-14 → ACP → periodicidad.
- Endpoint nuevo `POST /rrmm/protocolos/aplicar`.
- Tests del servicio en verde.

**`rrmm-backend` (orquestador):**
- DTOs `AplicarProtocolosBackRequest/Response`, cliente `aplicarConfiguracionProtocolos`, mapper `toAplicarRequest`.
- Cableado en `confirmar()` tras consolidar `INF_RM` + adicionales, con flag `cambio-puesto.aplicar.enabled` (true en todos los perfiles).
- Tests de servicio y mapper en verde.

### CA-14 — estado actual (acotado, con plan de cierre)
- **Decisión validada por las notas de la reunión:** conservar pruebas con **check verde** (realizadas/documentadas) y **sin** indicador visual especial → encaja con nuestra reinserción `MANUAL=1`.
- **Implementación actual:** heurística acotada por datos en `INF2_RM_VALORES` para 3 bloques conocidos (anamnesis/antecedentes, hábitos, control de visión), reutilizando las properties `rrmm.herencia.*`.
- **`TODO` anclado en código** (DAO + interfaz): sustituir la heurística por la **fuente real del check verde** que usa la pantalla del RM, pendiente de que Felix/equipo técnico la exponga.

### Pendiente / siguientes pasos
1. **Tu prueba en local del `confirmar`** (en curso).
2. Llevar a reunión las preguntas: a negocio (confirmar definición check verde / sin indicador) y a técnico (fuente real del check verde).
3. Ampliar CA-14 cuando llegue esa fuente.

### Recordatorio para tu prueba local
- `rrmm-utils` está en **puerto 8081** (cambio temporal para evitar choque con `puestos-back` en 8080); `rrmm-backend` ya apunta ahí. Si reinicias servicios, verifica que `api.rrmm-utils.url` del backend apunte al `8081`.
- Con `cambio-puesto.aplicar.enabled=true`, al confirmar deberías ver en logs la traza `CONFIRMAR applier ok protocolos=... pruebas=... conservadasCa14=...`.

Voy quedando a la espera de cómo te va la prueba; si sale algún error de la llamada `aplicar`, pásame la traza y lo miramos.

---

**User**

se ha quedado el proceso enganchado en esta linea reconciliacionDao.actualizarAcpMetadataSinMedicos(rmId, acp);

---

**Cursor**

El síntoma —se "engancha" (no error, sino bloqueo) justo en un `UPDATE` de `INF_RM`— apunta a un **interbloqueo distribuido por lock de fila**, no a un bug de SQL. Déjame confirmarlo leyendo el orden real en `confirmar()` (backend) y en el servicio de utils.

Confirmado el orden en backend (líneas 252‑292): `confirmar()` es `@Transactional`, hace `updateInfRmCambioPuesto` (UPDATE de `INF_RM`, línea 498) y **sin cerrar la transacción** llama por HTTP al applier, que en utils vuelve a hacer `UPDATE INF_RM` (`actualizarAcpMetadataSinMedicos`). Veamos qué escribe utils en `INF_RM` dentro del applier para dimensionar la solución.

Diagnóstico confirmado. No es un fallo de SQL: es un **interbloqueo distribuido por lock de fila sobre `INF_RM`**.

Qué ocurre exactamente:

1. `confirmar()` (backend) está `@Transactional` y en la línea 498 hace `updateInfRmCambioPuesto` → bloquea la fila `INF_RM` del `rmId` y **no hace commit** (la transacción sigue abierta).
2. Sin cerrarla, llama por HTTP al applier de utils.
3. El applier de utils, en **otra** transacción/conexión, intenta `UPDATE INF_RM` en esa misma fila —y lo hace en **dos** puntos: `actualizarAcpMetadataSinMedicos` (línea 118) y `actualizarPeriodicidadReconocimiento` (líneas 175/184).
4. utils queda esperando el lock que backend tiene tomado; backend queda esperando la respuesta HTTP de utils → **espera infinita**. Oracle no lo detecta como deadlock (son dos sesiones, una espera lock y otra espera red), por eso "se engancha" sin error.

Las tablas `INF3_*` no causan el problema (backend no las toca); el único choque es `INF_RM`.

**Para desbloquear tu prueba ahora:** reinicia el `rrmm-backend` (al cortar, su transacción hace rollback y libera el lock); reinicia también utils si quedó colgado. Con eso vuelves a tener la fila libre.

Esto es una decisión de diseño (afecta a la atomicidad y al contrato entre servicios), así que prefiero que elijas antes de tocar nada:

> **Cómo resolvemos el interbloqueo distribuido sobre INF_RM entre backend (confirmar) y utils (applier)?**
> - (Recomendada) utils NO escribe INF_RM: calcula ACP + periodicidad y los DEVUELVE; backend persiste esos campos en INF_RM dentro de su propia transacción (junto al UPDATE del puesto). Elimina el lock de raíz y mantiene INF_RM 100% transaccional en backend, sin tocar MC/MT. Coste medio: ampliar el DTO de respuesta + método DAO en backend. ✔
> - Liberar el lock antes de llamar al applier: backend hace commit de su parte (RL/INF_RM/adicionales) y DESPUÉS invoca el applier fuera de la transacción. Rápido, pero pierde el rollback automático de lo local si el applier falla (se apoya en la idempotencia para reintentar).
> - Antes de decidir, qué escribe exactamente cada UPDATE en INF_RM (campos) y revisar si hay más puntos de escritura, para dimensionar mejor.

Perfecto, Opción A. Es un refactor que toca ambos proyectos; lo planifico y empiezo. Primero necesito ver qué columnas de `INF_RM` escribe la periodicidad en utils, para replicarlas en backend.

Ya tengo las columnas: periodicidad → `periodicidad_id`, `periodicidad_valor`; ACP → `acp_id`, `acp_tipo_id`, `acp_obs_ia`, `observacion_acp`, `periodicidad_ver_ia`. Leo el DTO de respuesta de utils, el objeto `Acp` y el test del servicio.

Tengo todo el contexto. Empiezo por `rrmm-utils`. Amplío el DTO de respuesta con los campos ACP que backend debe persistir.

Ahora el servicio applier: dejar de escribir `INF_RM` (ACP + periodicidad), manteniendo el cálculo, y rellenar el response.

Ahora `construirRespuesta` para rellenar los metadatos ACP.

Ahora elimino el método muerto `actualizarAcpMetadataSinMedicos` del DAO. Verifico que no se use en otro lugar.

Solo en el DAO y el test. Lo elimino de la interfaz (y su import de `Acp`).

Actualizo la cabecera de la interfaz para quitar la mención al refresco ACP (ya no es responsabilidad de este DAO).

Ahora elimino la implementación del método y su import `Acp` en el `DaoImpl`.

Ahora ajusto el test del servicio: ya no se escribe `INF_RM`, así que cambio los `verify` de escritura por aserciones sobre el response y verificación de no-escritura.

Quito el import `isNull` que ya no se usa.

Compilo `rrmm-utils` y corro los tests del servicio para validar el lado utils antes de pasar a backend.

utils en verde. Actualizo progreso y paso a `rrmm-backend`. Leo el DTO de respuesta del backend, el DAO de cambio de puesto y cómo se invoca el applier en `confirmar()`.

Amplío el DTO de respuesta del backend.

Ahora el DAO de backend. Reviso `updateInfRmCambioPuesto` y `CambioPuestoRmUpdate` para seguir el patrón existente.

Veo el patrón (text blocks, `namedTemplateVs`, NVL para opcionales). Localizo el DTO `CambioPuestoRmUpdate` para crear uno análogo y ver la interfaz del DAO.

Creo el DTO de actualización siguiendo el patrón de `CambioPuestoRmUpdate`.

Ahora la implementación del DAO, justo tras `updateInfRmCambioPuesto`.

Ahora actualizo `aplicarConfiguracionProtocolos` en el servicio para persistir los metadatos en la misma transacción.

Añado el import de `CambioPuestoConfigProtocolosUpdate` en el servicio.

Actualizo progreso y compilo `rrmm-backend`.

Compilo backend y corro los tests de cambio de puesto.

Backend en verde. Reviso el test del flujo `confirmar` para reforzarlo verificando la persistencia de los metadatos.

El test ya pasa, pero lo refuerzo para verificar que los metadatos se persisten en `INF_RM`.

Verifico lints de los archivos backend editados y vuelvo a correr el test reforzado.

Opción A implementada y verde en ambos proyectos. Resumen del cambio que elimina el interbloqueo:

## Qué se ha hecho — eliminar el lock distribuido sobre `INF_RM`

**Causa raíz:** el applier de utils hacía `UPDATE INF_RM` mientras la transacción de `confirmar()` (backend) mantenía esa fila bloqueada → espera infinita. La solución: **utils ya no escribe `INF_RM`; lo persiste backend en su propia transacción.**

### `rrmm-utils` (motor)
- `AplicarProtocolosResponse`: ahora devuelve los metadatos ACP a persistir (`acpId`, `acpTipoId`, `acpObsIa`, `observacionAcp`, `periodicidadVerIa`) además de la periodicidad.
- Applier (`AplicarProtocolosReconocimientoServiceImpl`): **dejó de escribir `INF_RM`** — quité la llamada a `actualizarAcpMetadataSinMedicos` y los `UPDATE` de periodicidad; ahora `calcularPeriodicidad` solo calcula y devuelve. Sigue reconstruyendo `INF3_*` y CA-14 (tablas que backend no toca).
- Eliminé el método muerto `actualizarAcpMetadataSinMedicos` del DAO (interfaz + impl) y limpié imports/Javadoc.
- Tests del servicio ajustados: verifican que **no** se escribe `INF_RM` y que el response transporta ACP + periodicidad. Verde.

### `rrmm-backend` (orquestador)
- `AplicarProtocolosBackResponse`: ampliado con los mismos campos ACP.
- Nuevo `CambioPuestoConfigProtocolosUpdate` + `updateInfRmConfiguracionProtocolos` en el DAO: un único `UPDATE INF_RM` que escribe ACP (siempre) y periodicidad (solo si llega `id`), **sin tocar `MC_ID` ni `MT_VALIDA`**.
- `confirmar()`: tras recibir la respuesta del applier, persiste esos metadatos **en la misma transacción** (misma conexión que ya tiene el lock → sin segundo locker).
- Tests reforzados: se verifica que los metadatos devueltos se persisten. Verde.

## Para volver a probar
1. **Recompila/reinicia** `rrmm-utils` (8081) y `rrmm-backend`.
2. Si quedó alguna sesión Oracle colgada de la prueba anterior, asegúrate de que se liberó (al reiniciar backend, su transacción hace rollback).
3. Lanza `confirmar`: ya no debe engancharse. En logs verás `dao updateInfRmConfigProtocolos rmId=... acpId=... periodicidadId=...` seguido de `CONFIRMAR applier ok ...`.

Quedo atento al resultado de la prueba; si surge cualquier cosa con el `UPDATE` de ACP/periodicidad o con los datos materializados, pásame la traza.

---

**User**

en lo que hemos creado nosotros en rrmm-utils no se si hemos puesto trazabilidad? puedes revisar por favor

---

**Cursor**

Reviso la trazabilidad en los tres componentes que creamos/tocamos en `rrmm-utils`: el servicio, el DAO y el endpoint del controller.

Ahora reviso el endpoint del controller y el resto del servicio para tener la foto completa.

He revisado los tres componentes que creamos/tocamos en `rrmm-utils`. Aquí está la foto de la trazabilidad actual:

## Estado actual

**Servicio `AplicarProtocolosReconocimientoServiceImpl`** — tiene trazas, pero parciales:
- `log.info` de **entrada** con contexto: `Aplicar config protocolos rmId=... puestoId=... tipoPuesto=... adicionales=... userVigId=...`
- `log.warn` si el RM no tiene versión.
- `log.debug` de filas eliminadas en la limpieza `INF3_*`.
- `log.info` de CA-14 cuando reincorpora pruebas conservadas.
- **Falta:** una traza de **cierre/resultado** (conteos materializados, periodicidad, acpId) y trazas de **error**. El resumen se devuelve al controller pero en utils no queda constancia del resultado ni de un fallo.

**DAO `ReconciliacionProtocolosDaoImpl`** — **sin logger**. Es lo habitual en DAOs, pero aquí hay dos operaciones sensibles (el `DELETE` masivo de las 7 tablas `INF3_*` y la reinserción CA-14) cuya traza vive solo en el service.

**Controller (endpoint `/aplicar`)** — **sin logging**, igual que el `/recalcular` ya existente (patrón fino del proyecto; aceptable).

## Diagnóstico
Hay trazabilidad de **inicio e hitos**, pero **no de resultado ni de error**, que son las más útiles para auditar un cambio de puesto en producción. Además, las trazas no llevan un prefijo común para filtrar fácilmente (en `rrmm-backend` sí existe `CambioPuestoTrace`/`TRACE_PREFIX`; en utils no hay equivalente).

## Propuesta (si te parece, la aplico)
1. **Servicio:** añadir un `log.info` de **resumen final** antes de devolver (protocolos/pruebas/perfiles/parámetros/cuestionarios, periodicidadId, acpId y nº conservadas CA-14) y envolver el flujo con un log de **error** (`rmId` + causa) que re-lance, para no perder el contexto si algo falla a mitad del rebuild.
2. **Prefijo de traza coherente** (p.ej. `[CP-APLICAR] rmId=...`) en las líneas del servicio, para poder filtrar el flujo completo.
3. **DAO (opcional, nivel `debug`):** una línea en `limpiarConfiguracionInf3` y en `reinsertarPruebaConservada` para trazar las escrituras sensibles a bajo nivel.

¿Quiero que aplique las tres, o solo la 1 y 2 (las de mayor valor)? Dejo la decisión en tus manos antes de tocar nada.

---

**User**

las 3

---

**Cursor**

Vamos con las tres. Primero reviso el estilo de logger del servicio para alinearme, y aplico los cambios en el servicio.

Ahora reescribo el método principal con prefijo de traza, resumen final y manejo de error.

Ahora añado el prefijo en el log de CA-14 del helper.

Ahora el DAO: añado logger y trazas `debug` en las dos escrituras sensibles.

Las tres aplicadas (el controller queda fino, como el resto del proyecto). Verifico lints y compilo + test en `rrmm-utils`.

Trazabilidad añadida y verde (exit 0). Resumen de lo que hemos reforzado en `rrmm-utils`:

## Trazabilidad añadida (las 3)

**1. Servicio `AplicarProtocolosReconocimientoServiceImpl` — resumen final + errores**
- `log.info` de **cierre** antes de devolver, con el resumen completo: `protocolos`, `pruebas`, `perfiles`, `parametros`, `cuestionarios`, `ipromes`, `productosQuimicos`, `periodicidadId`, `acpId` y `conservadasCa14`.
- Flujo envuelto en try/catch: `log.warn` para fallos controlados (`CustomRestApiException`, p.ej. 404/400) y `log.error` con stack trace para fallos inesperados; ambos re-lanzan (no se traga ninguna excepción).

**2. Prefijo de traza coherente `[CP-APLICAR]`**
- Aplicado a todas las líneas del servicio (inicio, warn de versión, limpieza, CA-14, resumen, errores) y compartido por el DAO, de modo que puedes filtrar el flujo completo de un cambio de puesto por ese prefijo + `rmId`.

**3. DAO `ReconciliacionProtocolosDaoImpl` — escrituras sensibles a `debug`**
- `limpiarConfiguracionInf3`: traza por tabla con filas eliminadas (desglose fino del rebuild).
- `reinsertarPruebaConservada`: traza de cada prueba CA-14 reinsertada (`pruebaId`, `origenId`).

El controller se deja fino (sin logging), igual que el `/recalcular` existente.

## Cómo se verá en logs
En un cambio de puesto verás algo como:
```
[CP-APLICAR] rmId=12341907 INICIO puestoId=... tipoPuesto=... adicionales=... userVigId=...
[CP-APLICAR] rmId=12341907 OK protocolos=7 pruebas=53 perfiles=3 ... periodicidadId=12 acpId=99 conservadasCa14=2
```
y, a nivel `debug`, el desglose de limpieza por tabla y las reinserciones CA-14.

Build y tests del servicio en verde. ¿Seguimos con tu prueba del `confirmar`, o quieres que revise también la trazabilidad del lado `rrmm-backend` para que ambos extremos queden homogéneos?

---

**User**

List<Integer> conservadas = reincorporarPruebasRealizadas(rmId, realizadas, userVigId); esto parece que no esta funcionando, tenemos 5 realizadas, que ha pasado aqui?

---

**Cursor**

Mirando la lógica, `conservadas = 0` con `realizadas = 5` **no es un fallo: es el comportamiento correcto** en este caso.

## Qué hace `reincorporarPruebasRealizadas`

```197:217:c:\Repository\rrmm-utils\src\main\java\com\preving\restapi\rrmmutils\service\reconocimiento\reconciliacion\AplicarProtocolosReconocimientoServiceImpl.java
    private List<Integer> reincorporarPruebasRealizadas(int rmId, List<PruebaRealizada> realizadas, int userVigId) {
        List<Integer> conservadas = new ArrayList<>();
        if (realizadas == null || realizadas.isEmpty()) {
            return conservadas;
        }
        Set<Integer> configurados = new HashSet<>(reconciliacionDao.getPruebaIdsConfigurados(rmId));
        for (PruebaRealizada realizada : realizadas) {
            Integer pruebaId = realizada.getPruebaId();
            if (pruebaId == null || configurados.contains(pruebaId)) {
                continue;
            }
            ...
        }
```

CA-14 **solo reincorpora las pruebas realizadas que la nueva configuración YA NO incluye** (las que quedarían "huérfanas" y perderían visibilidad). Si una prueba realizada sigue estando en la configuración regenerada del nuevo puesto, no hay nada que reincorporar: ya es visible por sí misma.

## Por qué aquí da 0

Tus 5 realizadas son anamnesis/antecedentes, hábitos y control de visión (los `prueba_id` 1,2,3,4,22 de los bloques acotados). Son pruebas **básicas que casi todos los protocolos incluyen**, así que tras el rebuild el nuevo puesto **también las trae** → están en `getPruebaIdsConfigurados(rmId)` → el `continue` las salta → `conservadas = 0`.

Es decir: las 5 siguen visibles, pero porque la nueva config las incluye de forma natural, no porque haya habido que "rescatarlas". CA-14 no tenía que actuar.

## Cómo confirmarlo (rápido)
En el debugger, en ese mismo punto inspecciona la variable `configurados` (el `Set<Integer>`): deberías ver que contiene los `prueba_id` de las 5 realizadas. O por SQL tras el applier:

```sql
SELECT DISTINCT prueba_id
FROM vig_salud.inf3_rm_pruebas
WHERE rm_id = 12341907 AND borrado IS NULL
ORDER BY prueba_id;
```

Si en ese resultado aparecen los 5 `prueba_id` de `realizadas`, está todo correcto.

## Cuándo verías `conservadas > 0`
Cambiando a un puesto cuyo protocolo **no** incluya alguno de esos bloques (p.ej. uno sin control de visión) teniendo el reco datos de visión: esa prueba sí quedaría fuera de la nueva config y se reincorporaría como `MANUAL=1`. Si quieres, preparamos un caso de prueba así para verlo actuar de verdad.

¿Quieres que validemos con la query que las 5 quedaron configuradas, o montamos el escenario donde CA-14 sí reincorpora?

---

**User**

log rrmm-utils:
14:47:46: Executing ':com.preving.restapi.rrmmutils.RestApiRrmmUtilsApplication.main()'…

Console output is saving to: C:\Repository\rrmm-utils\rrmm-utils.log
> Task :compileJava UP-TO-DATE
> Task :generateGitProperties
> Task :processResources UP-TO-DATE
> Task :classes
Connected to the target VM, address: 'localhost:50653', transport: 'socket'

> Task :com.preving.restapi.rrmmutils.RestApiRrmmUtilsApplication.main()

  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::                (v2.7.1)

2026-06-24 14:47:54.313  INFO 36984 --- [           main] c.p.r.r.RestApiRrmmUtilsApplication      : Starting RestApiRrmmUtilsApplication using Java 17.0.12 on GP82502 with PID 36984 (C:\Repository\rrmm-utils\build\classes\java\main started by jcanasc in C:\Repository\rrmm-utils)
2026-06-24 14:47:54.317 DEBUG 36984 --- [           main] c.p.r.r.RestApiRrmmUtilsApplication      : Running with Spring Boot v2.7.1, Spring v5.3.21
2026-06-24 14:47:54.317  INFO 36984 --- [           main] c.p.r.r.RestApiRrmmUtilsApplication      : The following 1 profile is active: "dev"
2026-06-24 14:47:56.187  INFO 36984 --- [           main] .s.d.r.c.RepositoryConfigurationDelegate : Bootstrapping Spring Data JPA repositories in DEFAULT mode.
2026-06-24 14:47:56.203  INFO 36984 --- [           main] .s.d.r.c.RepositoryConfigurationDelegate : Finished Spring Data repository scanning in 12 ms. Found 0 JPA repository interfaces.
2026-06-24 14:47:57.313  INFO 36984 --- [           main] faultConfiguringBeanFactoryPostProcessor : No bean named 'errorChannel' has been explicitly defined. Therefore, a default PublishSubscribeChannel will be created.
2026-06-24 14:47:57.352  INFO 36984 --- [           main] faultConfiguringBeanFactoryPostProcessor : No bean named 'integrationHeaderChannelRegistry' has been explicitly defined. Therefore, a default DefaultHeaderChannelRegistry will be created.
2026-06-24 14:47:58.506  INFO 36984 --- [           main] trationDelegate$BeanPostProcessorChecker : Bean 'org.springframework.integration.config.IntegrationManagementConfiguration' of type [org.springframework.integration.config.IntegrationManagementConfiguration] is not eligible for getting processed by all BeanPostProcessors (for example: not eligible for auto-proxying)
2026-06-24 14:47:58.529  INFO 36984 --- [           main] trationDelegate$BeanPostProcessorChecker : Bean 'integrationChannelResolver' of type [org.springframework.integration.support.channel.BeanFactoryChannelResolver] is not eligible for getting processed by all BeanPostProcessors (for example: not eligible for auto-proxying)
2026-06-24 14:48:00.200  INFO 36984 --- [           main] o.s.b.w.embedded.tomcat.TomcatWebServer  : Tomcat initialized with port(s): 8081 (http)
2026-06-24 14:48:00.248  INFO 36984 --- [           main] o.apache.catalina.core.StandardService   : Starting service [Tomcat]
2026-06-24 14:48:00.248  INFO 36984 --- [           main] org.apache.catalina.core.StandardEngine  : Starting Servlet engine: [Apache Tomcat/9.0.64]
2026-06-24 14:48:00.645  INFO 36984 --- [           main] o.a.c.c.C.[.[localhost].[/rrmm-utils]    : Initializing Spring embedded WebApplicationContext
2026-06-24 14:48:00.647  INFO 36984 --- [           main] w.s.c.ServletWebServerApplicationContext : Root WebApplicationContext: initialization completed in 6262 ms
2026-06-24 14:48:04.535  INFO 36984 --- [           main] o.hibernate.jpa.internal.util.LogHelper  : HHH000204: Processing PersistenceUnitInfo [name: default]
2026-06-24 14:48:04.676  INFO 36984 --- [           main] org.hibernate.Version                    : HHH000412: Hibernate ORM core version 5.6.9.Final
2026-06-24 14:48:05.064  INFO 36984 --- [           main] o.hibernate.annotations.common.Version   : HCANN000001: Hibernate Commons Annotations {5.1.2.Final}
2026-06-24 14:48:05.799  INFO 36984 --- [           main] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Starting...
2026-06-24 14:48:06.633  INFO 36984 --- [           main] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Start completed.
2026-06-24 14:48:06.658  INFO 36984 --- [           main] org.hibernate.dialect.Dialect            : HHH000400: Using dialect: org.hibernate.dialect.Oracle10gDialect
2026-06-24 14:48:06.865  INFO 36984 --- [           main] org.hibernate.orm.beans                  : HHH10005002: No explicit CDI BeanManager reference was passed to Hibernate, but CDI is available on the Hibernate ClassLoader.
2026-06-24 14:48:07.106  INFO 36984 --- [           main] o.h.e.t.j.p.i.JtaPlatformInitiator       : HHH000490: Using JtaPlatform implementation: [org.hibernate.engine.transaction.jta.platform.internal.NoJtaPlatform]
2026-06-24 14:48:07.117  INFO 36984 --- [           main] j.LocalContainerEntityManagerFactoryBean : Initialized JPA EntityManagerFactory for persistence unit 'default'
2026-06-24 14:48:07.649  INFO 36984 --- [           main] o.s.c.g.a.c.GcpContextAutoConfiguration  : The default project ID is erp-microservicios
2026-06-24 14:48:07.742  INFO 36984 --- [           main] o.s.c.g.core.DefaultCredentialsProvider  : Default credentials provider for service account pub-sub-csv@erp-microservicios.iam.gserviceaccount.com
2026-06-24 14:48:07.742  INFO 36984 --- [           main] o.s.c.g.core.DefaultCredentialsProvider  : Scopes in use by default credentials: [https://www.googleapis.com/auth/pubsub, https://www.googleapis.com/auth/spanner.admin, https://www.googleapis.com/auth/spanner.data, https://www.googleapis.com/auth/datastore, https://www.googleapis.com/auth/sqlservice.admin, https://www.googleapis.com/auth/devstorage.read_only, https://www.googleapis.com/auth/devstorage.read_write, https://www.googleapis.com/auth/cloudruntimeconfig, https://www.googleapis.com/auth/trace.append, https://www.googleapis.com/auth/cloud-platform, https://www.googleapis.com/auth/cloud-vision, https://www.googleapis.com/auth/bigquery, https://www.googleapis.com/auth/monitoring.write]
2026-06-24 14:48:09.856  INFO 36984 --- [           main] o.s.s.web.DefaultSecurityFilterChain     : Will secure any request with [org.springframework.security.web.session.DisableEncodeUrlFilter@24697504, org.springframework.security.web.context.request.async.WebAsyncManagerIntegrationFilter@6a4484e6, org.springframework.security.web.context.SecurityContextPersistenceFilter@127abbbe, org.springframework.security.web.header.HeaderWriterFilter@1b10963a, org.springframework.security.web.authentication.logout.LogoutFilter@60ba61e4, com.preving.security.JwtAuthenticationTokenFilter@3e5cbcfe, org.springframework.security.web.savedrequest.RequestCacheAwareFilter@57bbf4e5, org.springframework.security.web.servletapi.SecurityContextHolderAwareRequestFilter@6a938034, org.springframework.security.web.authentication.AnonymousAuthenticationFilter@6c67a17d, org.springframework.security.web.session.SessionManagementFilter@5a4e810e, org.springframework.security.web.access.ExceptionTranslationFilter@1c1082d9, org.springframework.security.web.access.intercept.FilterSecurityInterceptor@1ca0546a]
2026-06-24 14:48:15.811  INFO 36984 --- [           main] o.s.b.a.e.web.EndpointLinksResolver      : Exposing 1 endpoint(s) beneath base path '/actuator'
2026-06-24 14:48:16.245  INFO 36984 --- [           main] o.s.i.endpoint.EventDrivenConsumer       : Adding {logging-channel-adapter:_org.springframework.integration.errorLogger} as a subscriber to the 'errorChannel' channel
2026-06-24 14:48:16.245  INFO 36984 --- [           main] o.s.i.channel.PublishSubscribeChannel    : Channel 'rrmm-utils.errorChannel' has 1 subscriber(s).
2026-06-24 14:48:16.246  INFO 36984 --- [           main] o.s.i.endpoint.EventDrivenConsumer       : started bean '_org.springframework.integration.errorLogger'
2026-06-24 14:48:16.295  INFO 36984 --- [           main] o.s.b.w.embedded.tomcat.TomcatWebServer  : Tomcat started on port(s): 8081 (http) with context path '/rrmm-utils'
2026-06-24 14:48:16.336  INFO 36984 --- [           main] c.p.r.r.RestApiRrmmUtilsApplication      : Started RestApiRrmmUtilsApplication in 23.941 seconds (JVM running for 26.144)
2026-06-24 14:48:16.369  INFO 36984 --- [           main] .p.r.r.p.c.ReconocimientosIdemioConsumer : INACTIVE Subscription: projects/erp-microservicios/subscriptions/recos.events.notifications.recosValidados-sub-idemio
2026-06-24 14:48:16.371  INFO 36984 --- [           main] .r.r.p.c.ReconocimientosInformesConsumer : INACTIVE Subscription: projects/erp-microservicios/subscriptions/recos.events.notifications.recosValidados-sub-informes
2026-06-24 14:48:29.923  INFO 36984 --- [nio-8081-exec-1] o.a.c.c.C.[.[localhost].[/rrmm-utils]    : Initializing Spring DispatcherServlet 'dispatcherServlet'
2026-06-24 14:48:29.924  INFO 36984 --- [nio-8081-exec-1] o.s.web.servlet.DispatcherServlet        : Initializing Servlet 'dispatcherServlet'
2026-06-24 14:48:29.925  INFO 36984 --- [nio-8081-exec-1] o.s.web.servlet.DispatcherServlet        : Completed initialization in 1 ms
2026-06-24 14:48:34.950  INFO 36984 --- [nio-8081-exec-2] licarProtocolosReconocimientoServiceImpl : [CP-APLICAR] rmId=12341907 INICIO puestoId=73504 tipoPuesto=0 adicionales=0 userVigId=155527
2026-06-24 14:48:35.015 DEBUG 36984 --- [nio-8081-exec-2] .r.d.r.r.ReconciliacionProtocolosDaoImpl : [CP-APLICAR] rmId=12341907 limpieza vig_salud.inf3_rm_protocolos filas=6
2026-06-24 14:48:35.047 DEBUG 36984 --- [nio-8081-exec-2] .r.d.r.r.ReconciliacionProtocolosDaoImpl : [CP-APLICAR] rmId=12341907 limpieza vig_salud.inf3_rm_pruebas filas=107
2026-06-24 14:48:35.062 DEBUG 36984 --- [nio-8081-exec-2] .r.d.r.r.ReconciliacionProtocolosDaoImpl : [CP-APLICAR] rmId=12341907 limpieza vig_salud.inf3_rm_perfiles filas=3
2026-06-24 14:48:35.079 DEBUG 36984 --- [nio-8081-exec-2] .r.d.r.r.ReconciliacionProtocolosDaoImpl : [CP-APLICAR] rmId=12341907 limpieza vig_salud.inf3_rm_parametros filas=101
2026-06-24 14:48:35.095 DEBUG 36984 --- [nio-8081-exec-2] .r.d.r.r.ReconciliacionProtocolosDaoImpl : [CP-APLICAR] rmId=12341907 limpieza vig_salud.inf3_rm_cuestionarios filas=6
2026-06-24 14:48:35.119 DEBUG 36984 --- [nio-8081-exec-2] .r.d.r.r.ReconciliacionProtocolosDaoImpl : [CP-APLICAR] rmId=12341907 limpieza vig_salud.inf3_rm_ipromes filas=0
2026-06-24 14:48:35.133 DEBUG 36984 --- [nio-8081-exec-2] .r.d.r.r.ReconciliacionProtocolosDaoImpl : [CP-APLICAR] rmId=12341907 limpieza vig_salud.inf3_rm_productos_quimicos filas=0
2026-06-24 14:48:35.134 DEBUG 36984 --- [nio-8081-exec-2] licarProtocolosReconocimientoServiceImpl : [CP-APLICAR] rmId=12341907 limpieza INF3_RM_* filas eliminadas=223
2026-06-24 14:48:35.674  INFO 36984 --- [nio-8081-exec-2] licarProtocolosReconocimientoServiceImpl : [CP-APLICAR] rmId=12341907 OK protocolos=0 pruebas=27 perfiles=0 parametros=0 cuestionarios=2 ipromes=0 productosQuimicos=0 periodicidadId=6 acpId=51514 conservadasCa14=0


Log rrmm-backend:
2026-06-24 14:48:26.017  INFO 5324 --- [nio-8825-exec-5] c.p.r.r.w.c.CambioPuestoController       : [cambio-puesto] PUT rmId=12341907 accion=CONFIRMAR destino cli/cen/puesto=234783/598076/73504
2026-06-24 14:48:26.033  INFO 5324 --- [nio-8825-exec-5] c.p.r.r.s.c.CambioPuestoServiceImpl      : [cambio-puesto] rmId=12341907 validacion=V01_REQUEST_BASICO OK accion=CONFIRMAR destino=cli/cen/puesto=234783/598076/73504 estandar=0
2026-06-24 14:48:29.550  INFO 5324 --- [nio-8825-exec-5] c.p.r.r.s.c.CambioPuestoServiceImpl      : [cambio-puesto] rmId=12341907 CONFIRMAR inicio origen=cli/cen/puesto=234783/598076/116267 destino=cli/cen/puesto=234783/598076/73504 estandar=0 adicionales=0
2026-06-24 14:48:29.565  INFO 5324 --- [nio-8825-exec-5] c.p.r.r.s.c.CambioPuestoServiceImpl      : [cambio-puesto] rmId=12341907 validacion=V02_RM_PENDIENTE OK estadoLog=8
2026-06-24 14:48:29.580  INFO 5324 --- [nio-8825-exec-5] c.p.r.r.s.c.CambioPuestoServiceImpl      : [cambio-puesto] rmId=12341907 validacion=V03_DESTINO_PVS OK cli/cen=234783/598076
2026-06-24 14:48:29.580  INFO 5324 --- [nio-8825-exec-5] c.p.r.r.s.c.CambioPuestoRlOrchestrator   : [cambio-puesto] rmId=12341907 resolverRl origen=234783/598076/116267 destino=234783/598076/73504 trabajadorId=1396951
2026-06-24 14:48:29.595  INFO 5324 --- [nio-8825-exec-5] c.p.r.r.s.c.CambioPuestoRlOrchestrator   : [cambio-puesto] rmId=12341907 validacion=V05_RL_ORIGEN OK rlId=4782137 cli/cen=234783/598076
2026-06-24 14:48:29.609  INFO 5324 --- [nio-8825-exec-5] c.p.r.r.s.c.CambioPuestoRlOrchestrator   : [cambio-puesto] rmId=12341907 validacion=V06_RL_DESTINO OK rlId=4782137 cli/cen=234783/598076
2026-06-24 14:48:29.609  INFO 5324 --- [nio-8825-exec-5] c.p.r.r.s.c.CambioPuestoRlOrchestrator   : [cambio-puesto] rmId=12341907 validacion=V07_RL_DECISION OK EDITAR rlOrigen=4782137 rlDestino=4782137
2026-06-24 14:48:29.609  INFO 5324 --- [nio-8825-exec-5] c.p.r.r.s.c.CambioPuestoRlOrchestrator   : [cambio-puesto] rmId=12341907 rlEscenario=EDITAR rlAfectadaId=4782137 rlAccion=EDITADA rlOrigen=4782137 rlDestino=4782137
2026-06-24 14:48:29.609  INFO 5324 --- [nio-8825-exec-5] c.p.r.r.s.c.CambioPuestoServiceImpl      : [cambio-puesto] rmId=12341907 validacion=V04_RL_RESOLUCION OK escenario=EDITAR rlAfectadaId=4782137
2026-06-24 14:48:29.612  INFO 5324 --- [nio-8825-exec-5] c.p.r.r.s.c.CambioPuestoServiceImpl      : [cambio-puesto] rmId=12341907 validacion=V11_EDITOR OK editorId=155527
2026-06-24 14:48:29.843  INFO 5324 --- [nio-8825-exec-5] .p.r.r.s.c.CambioPuestoImpactoReaderImpl : [cambio-puesto] snapshot rmId=12341907 protocolos=6 pruebas=52 parametros=50 perfiles=2 cuestionarios=5
2026-06-24 14:48:29.843  INFO 5324 --- [nio-8825-exec-5] c.p.r.r.s.c.CambioPuestoServiceImpl      : [cambio-puesto] rmId=12341907 validacion=V05_JWT OK token presente
2026-06-24 14:48:29.857  INFO 5324 --- [nio-8825-exec-5] .r.s.c.RrmmUtilsImpactoPropuestoResolver : [cambio-puesto] rmId=12341907 P1 rrmm-utils inicio destino=cli/cen/puesto=234783/598076/73504 estandar=0 adicionales=0 tipoPuesto=C puestoPrincipal=73504 adicionales=0
2026-06-24 14:48:31.191  INFO 5324 --- [nio-8825-exec-5] c.p.r.r.s.c.RrmmUtilsClientImpl          : [cambio-puesto] rmId=12341907 validacion=V06_P1_HTTP OK protocolos=1 pruebas=27 cuestionarios=2
2026-06-24 14:48:31.191  INFO 5324 --- [nio-8825-exec-5] .r.s.c.RrmmUtilsImpactoPropuestoResolver : [cambio-puesto] rmId=12341907 validacion=V06_P1 OK propuesto protocolos=1 pruebas=26 cuestionarios=2 perfiles=0 parametros=0 periodicidad=-
2026-06-24 14:48:31.192  INFO 5324 --- [nio-8825-exec-5] c.p.r.r.s.c.CambioPuestoServiceImpl      : [cambio-puesto] rmId=12341907 validacion=V12_PROTOCOLOS_LOG OK anadidos=0 eliminados=5
2026-06-24 14:48:31.192  INFO 5324 --- [nio-8825-exec-5] c.p.r.r.s.c.CambioPuestoServiceImpl      : [cambio-puesto] rmId=12341907 CONFIRMAR protocolosLog anadidos=0 eliminados=5
2026-06-24 14:48:31.192  INFO 5324 --- [nio-8825-exec-5] c.p.r.r.s.c.CambioPuestoServiceImpl      : [cambio-puesto] rmId=12341907 CONFIRMAR mutando rl escenario=EDITAR rlAfectadaId=4782137 rlAccion=EDITADA
2026-06-24 14:48:31.192  INFO 5324 --- [nio-8825-exec-5] c.p.r.r.s.c.CambioPuestoRlExecutor       : [cambio-puesto] rmId=12341907 rlEjecutar inicio escenario=EDITAR rlAfectadaId=4782137 rmClienteId=234783 destino=234783/598076/73504
2026-06-24 14:48:31.208  INFO 5324 --- [nio-8825-exec-5] c.p.r.r.s.c.CambioPuestoRlExecutor       : [cambio-puesto] rmId=12341907 validacion=V07_RL_ACTIVA OK rlId=4782137
2026-06-24 14:48:31.223  INFO 5324 --- [nio-8825-exec-5] c.p.r.r.s.c.CambioPuestoRlExecutor       : [cambio-puesto] rmId=12341907 validacion=V06_OK_TECNICO OK rlPuestoId=null clienteValidacion=234783 ptContratada=SI
2026-06-24 14:48:31.224  INFO 5324 --- [nio-8825-exec-5] c.p.r.r.s.c.CambioPuestoRlExecutor       : [cambio-puesto] rlEjecutar baja rlId=4782137 trabajadorId=1396951 clienteOverride=null
2026-06-24 14:48:31.239  INFO 5324 --- [nio-8825-exec-5] c.p.r.r.d.c.CambioPuestoDaoImpl          : [cambio-puesto] dao puestoTrabajoBaja id=4782137 principal=true fechaBaja=2026-06-23
2026-06-24 14:48:31.270  INFO 5324 --- [nio-8825-exec-5] c.p.r.r.d.c.CambioPuestoDaoImpl          : [cambio-puesto] dao puestoTrabajoAlta origenId=4782137 nuevoId=4782157 principal=true puesto=73504 estandar=false
2026-06-24 14:48:31.285  INFO 5324 --- [nio-8825-exec-5] c.p.r.r.d.c.CambioPuestoDaoImpl          : [cambio-puesto] dao syncAdicionalesRl rlId=4782157 bajas=0 altas=0
2026-06-24 14:48:31.285  INFO 5324 --- [nio-8825-exec-5] c.p.r.r.s.c.CambioPuestoRlExecutor       : [cambio-puesto] rlMutada escenario=EDITAR rlOrigen=4782137 rlNueva=4782157 rlAccion=EDITADA destino cli/cen/puesto=234783/598076/73504
2026-06-24 14:48:31.302  INFO 5324 --- [nio-8825-exec-5] c.p.r.r.d.c.CambioPuestoDaoImpl          : [cambio-puesto] dao updateInfRm rmId=12341907 puesto=73504 infPtrTipo=2 cli/cen=234783/598076
2026-06-24 14:48:31.302  INFO 5324 --- [nio-8825-exec-5] c.p.r.r.s.c.CambioPuestoServiceImpl      : [cambio-puesto] rmId=12341907 infRm actualizado puesto=73504 tipo=2 cli/cen=234783/598076 rmMovido=NO
2026-06-24 14:48:31.302  INFO 5324 --- [nio-8825-exec-5] c.p.r.r.s.c.CambioPuestoServiceImpl      : [cambio-puesto] rmId=12341907 validacion=V13_ADICIONALES_RM OK count=0
2026-06-24 14:48:31.317  INFO 5324 --- [nio-8825-exec-5] c.p.r.r.s.c.CambioPuestoServiceImpl      : [cambio-puesto] rmId=12341907 adicionalesRm actualizados count=0
2026-06-24 14:48:31.318  INFO 5324 --- [nio-8825-exec-5] c.p.r.r.s.c.CambioPuestoServiceImpl      : [cambio-puesto] rmId=12341907 validacion=V05_JWT OK token presente
2026-06-24 14:48:35.695  INFO 5324 --- [nio-8825-exec-5] c.p.r.r.s.c.RrmmUtilsClientImpl          : [cambio-puesto] rmId=12341907 validacion=V07_APLICAR_HTTP OK protocolos=0 pruebas=27 conservadasCa14=0
2026-06-24 14:48:35.738  INFO 5324 --- [nio-8825-exec-5] c.p.r.r.d.c.CambioPuestoDaoImpl          : [cambio-puesto] dao updateInfRmConfigProtocolos rmId=12341907 acpId=51514 periodicidadId=6
2026-06-24 14:48:35.738  INFO 5324 --- [nio-8825-exec-5] c.p.r.r.s.c.CambioPuestoServiceImpl      : [cambio-puesto] rmId=12341907 CONFIRMAR applier ok protocolos=0 pruebas=27 perfiles=0 parametros=0 cuestionarios=2 conservadasCa14=0 periodicidadId=6
2026-06-24 14:48:35.778  INFO 5324 --- [nio-8825-exec-5] c.p.r.r.d.c.CambioPuestoLogDaoImpl       : [cambio-puesto] log CA-17 insertado id=3 rmId=12341907 origen=234783/116267 destino=234783/73504 rlAfectadaId=4782157 rlAccion=EDITADA protocolos +/-=0/5
2026-06-24 14:48:35.779  INFO 5324 --- [nio-8825-exec-5] c.p.r.r.s.c.CambioPuestoServiceImpl      : [cambio-puesto] rmId=12341907 CONFIRMAR ok logId=3 rlAfectadaId=4782157 rlAccion=EDITADA destino cli/cen/puesto=234783/598076/73504 editorId=155527


---

**Cursor**

Buenas noticias primero: el flujo ya corre **end‑to‑end sin cuelgue** y el `updateInfRmConfigProtocolos` se aplica bien. Pero en el resumen de `rrmm-utils` veo algo que no cuadra:

```
[CP-APLICAR] rmId=12341907 OK protocolos=0 pruebas=27 perfiles=0 parametros=0 cuestionarios=2 ...
```

Tras limpiar `protocolos=6, pruebas=107, perfiles=3, parametros=101, cuestionarios=6`, la regeneración solo ha materializado **pruebas y cuestionarios**: `protocolos=0`, `perfiles=0`, `parametros=0`. Y el dry-run (P1) proponía `protocolos=1`. Eso apunta a que al motor le llega un **tipo de puesto incorrecto**.

En el log de utils: `INICIO ... tipoPuesto=0`, mientras el dry-run usó `tipoPuesto=C`. Voy a revisar el mapeo en el mapper para confirmarlo.

El flujo ya funciona completo (sin cuelgue, `updateInfRmConfigProtocolos` aplicado, log CA‑17 OK). Pero ese `protocolos=0 perfiles=0 parametros=0` materializados me preocupa frente al `protocolos=1` del dry‑run. El mapeo de `tipoPuesto` es idéntico en ambos requests (`0` para centro), así que la diferencia está en el motor. Investigo cómo se usa `tipoPuesto` y qué puebla `inf3_rm_protocolos`.

Dato clave: en el motor (`ConfiguracionProtocolosReconocimientoServiceImpl:103`) `tipoPuesto` solo se compara con `PUESTO_ESTANDAR`; `0` se interpreta como "no estándar = centro", así que el `0` no es el problema (dry‑run y aplicar lo tratan igual). La inconsistencia real es **27 pruebas con 0 protocolos**. Voy a leer cómo `cargarConfiguracionProtocolosReconocimiento` inserta los protocolos.

El resultado E2E es bueno (sin cuelgue, `INF_RM` actualizado, log CA‑17 OK), pero confirmo que hay una **inconsistencia a investigar**: el applier materializó `pruebas=27` pero `protocolos=0`, cuando el dry‑run del mismo puesto destino esperaba `protocolos=1`. Como las pruebas cuelgan de un protocolo (`inf3_rm_pruebas.protocolo_id`), 27 pruebas con 0 protocolos puede dejar pruebas "huérfanas".

He verificado que el `tipoPuesto=0` **no** es la causa (el motor solo distingue `== PUESTO_ESTANDAR`; `0` = centro, igual que el dry‑run). El método `cargarConfiguracionProtocolosReconocimiento` sí inserta protocolos internamente (`insertarProtocolosParaReconocimientoByTipoYConfigsIds`), así que el `0` resultante es anómalo.

Antes de tocar nada, necesito ver el estado real en BD tras el applier. ¿Me ejecutas estas consultas para el `rm 12341907`?

```sql
-- 1. ¿Cuántos protocolos quedaron materializados?
SELECT COUNT(*) AS protocolos
FROM vig_salud.inf3_rm_protocolos
WHERE rm_id = 12341907;

-- 2. ¿Qué protocolo_id tienen las 27 pruebas?
SELECT protocolo_id, COUNT(*) AS n
FROM vig_salud.inf3_rm_pruebas
WHERE rm_id = 12341907 AND borrado IS NULL
GROUP BY protocolo_id
ORDER BY protocolo_id;

-- 3. Pruebas "huérfanas": protocolo_id que NO existe en inf3_rm_protocolos del reco
SELECT DISTINCT p.protocolo_id
FROM vig_salud.inf3_rm_pruebas p
WHERE p.rm_id = 12341907 AND p.borrado IS NULL AND p.protocolo_id IS NOT NULL
  AND NOT EXISTS (
        SELECT 1 FROM vig_salud.inf3_rm_protocolos pr
        WHERE pr.rm_id = 12341907 AND pr.protocolo_id = p.protocolo_id);
```

Mi hipótesis principal: en el motor del alta, la inserción de protocolos puede **depender del orden** o de que existan filas previas en `INF3_RM_PROTOCOLOS`. Como en el rebuild limpiamos esa tabla **antes** de regenerar, la inserción de protocolos podría estar quedando a 0 mientras las pruebas (que se insertan antes, en el bloque 168‑172) sí entran.

Para contrastarlo del todo, si tienes a mano un reconocimiento **creado por alta normal** con ese mismo puesto `73504`, una cuarta consulta ayuda:

```sql
-- 4. Referencia: ¿cuántos protocolos/pruebas tiene un alta normal de ese puesto?
SELECT
  (SELECT COUNT(*) FROM vig_salud.inf3_rm_protocolos WHERE rm_id = :rmAltaNormal) protocolos,
  (SELECT COUNT(*) FROM vig_salud.inf3_rm_pruebas WHERE rm_id = :rmAltaNormal AND borrado IS NULL) pruebas
FROM dual;
```

Con el resultado de 1‑3 (y 4 si lo tienes) confirmo si es un problema de orden en el rebuild y lo corregimos (p.ej. ajustando la secuencia de limpieza/regeneración de `INF3_RM_PROTOCOLOS`). ¿Me los pasas?

---

**User**

no tengo referencia de alta

---

**Cursor**

Las consultas **confirman el bug**:
- `inf3_rm_protocolos` = **0** filas.
- 27 pruebas: **23 con `protocolo_id=21`** y 4 con `protocolo_id=NULL`.
- La consulta 3 confirma que **el protocolo `21` referenciado por 23 pruebas NO existe** en `inf3_rm_protocolos` → 23 pruebas huérfanas.

Es decir: las pruebas se insertaron apuntando al protocolo 21, pero ese protocolo no se materializó. Voy a leer cómo el motor inserta los protocolos para entender por qué quedó a 0.

El servicio revela el patrón. En la línea 231 los **protocolos solo se insertan si `isTieneConfiguracionProtocolos()`**, pero en la línea 240 las **pruebas/cuestionarios de protocolo se insertan también si hay `protocolosCliente`** (aunque no haya config). Las 23 pruebas con `protocolo_id=21` apuntan a un protocolo de cliente que no se insertó. Confirmo leyendo la query de inserción de protocolos y cómo el dry‑run cuenta.

Necesito ver cómo se añaden los `protocolosAdicionales` (protocolosCliente) a la subquery.

Ahora veo que la subquery **sí inserta los `protocolosAdicionales` (protocolosCliente)** en `inf3_rm_protocolos` (líneas 152‑157). El problema es que esa inserción **solo se ejecuta cuando `isTieneConfiguracionProtocolos()` es true** (línea 231), mientras que las pruebas de protocolo se insertan también con solo `protocolosCliente` (línea 240). Veo cómo se construye el contexto justo antes de la línea 189.

Con esto el diagnóstico queda **cerrado y confirmado**. Te resumo la causa raíz exacta.

## Causa raíz: condición asimétrica en el motor del alta

Para el puesto destino `73504` (centro, `estandar=false`), en la línea 128 se resuelve:

```java
configsIds = informesDao.getConfiguracionesProtocolosByPuestosCentrosIds(puestoId, false);
```

Ese puesto **no tiene configuración de protocolos propia** → `configsIds` vacío, sin plantilla, sin `puestoIdPlantilla`. Por tanto:

```190:191:c:\Repository\rrmm-utils\src\main\java\com\preving\restapi\rrmmutils\service\reconocimiento\alta\ConfiguracionProtocolosReconocimientoServiceImpl.java
hayConfiguracionParaInsertarProtocolos = false   // configsIds/plantilla todo vacío
tieneConfiguracionProtocolos = false
```

Pero sí existen **protocolos de cliente** (`getProtocolosParaReconocimientoPorClienteId` → `protocolosCliente = [21]`). Y aquí está el fallo, en `insertarProtocolosParaReconocimientoByTipoYConfigsIds`:

```231:243:c:\Repository\rrmm-utils\src\main\java\com\preving\restapi\rrmmutils\service\reconocimiento\alta\ConfiguracionProtocolosReconocimientoServiceImpl.java
            if (contexto.isTieneConfiguracionProtocolos()) {                 // <-- FALSE: NO inserta el protocolo 21
                configuracionProtocolosDao.insertarProtocolosPorTipoYConfigsIds(...protocolosCliente);
            }
        }

        if (contexto.isTieneConfiguracionProtocolos() || !protocolosCliente.isEmpty()) {   // <-- TRUE: SÍ inserta las pruebas del protocolo 21
            configuracionProtocolosDao.insertarPruebasProtocolosPorReconocimiento(...protocolosCliente);
            ...
```

La condición es **asimétrica**:
- Los **protocolos** (`inf3_rm_protocolos`) solo se insertan si `tieneConfiguracionProtocolos` → en este caso `false` → **0 protocolos**.
- Las **pruebas/cuestionarios de protocolo** se insertan también si hay `protocolosCliente` → **23 pruebas con `protocolo_id=21`** huérfanas.

Y confirmé en el DAO (líneas 152‑157) que `insertarProtocolosPorTipoYConfigsIds` **sí sabe insertar los `protocolosAdicionales`** (el `UNION` con `pro_protocolos WHERE id IN (:protocolosAdicionales)`), simplemente nunca se le llama porque la condición de la línea 231 lo bloquea.

Por eso el **dry‑run cuenta 1** (cuenta el protocolo de cliente vía la misma subquery) y el **apply materializa 0** (salta el INSERT por la condición). No es un problema del rebuild ni del orden de limpieza: es esta condición.

## Propuesta de corrección

**Opción A (recomendada)** — hacer la condición de la línea 231 simétrica con la 240:

```java
if (contexto.isTieneConfiguracionProtocolos() || !protocolosCliente.isEmpty()) {
    configuracionProtocolosDao.insertarProtocolosPorTipoYConfigsIds(...protocolosCliente);
}
```

Es el mínimo cambio, ataca la causa raíz y es coherente: si vamos a insertar las pruebas de unos protocolos, debemos insertar también esos protocolos. Beneficia igualmente al alta (donde es un bug latente para puestos con protocolos de cliente sin config).

**Opción B** — no tocar el motor del alta; en nuestro applier, tras `cargarConfiguracion`, reparar insertando en `inf3_rm_protocolos` los `protocolo_id` referenciados por pruebas que no existan en la tabla. Más aislado pero más artificial.

Como el cambio toca código del motor del alta (compartido), no lo aplico sin tu visto bueno.

¿Quieres que aplique la **Opción A**, o prefieres la **B** para no tocar el alta?

---

**User**

no podemos tocar codigo del alta, asi que debemos ir por otra via, dejando comentario de lo que sucede y que hay bug en proceso alta, pero en nuestro lado los comentarios, nada en proceso de alta

---

**Cursor**

Entendido: Opción B, sin tocar el alta. Repararé los protocolos huérfanos en nuestro lado (capa de reconciliación) con comentarios que documenten el bug del alta. Primero leo los archivos donde lo voy a implementar.

Ahora leo la interfaz del DAO y el service para ubicar dónde encajar la reparación.

Ahora leo el service para ubicar el punto exacto tras `cargarConfiguracion` donde insertar la reparación.

Tengo todo el contexto. Implemento la reparación en nuestro lado (capa de reconciliación), sin tocar el alta, documentando el bug. Añado el método al DAO, su interfaz y la llamada en el service.

Primero, el método en la implementación del DAO.

Ahora la interfaz.

Ahora la llamada en el service, justo tras regenerar la configuración (paso 3).

Hecho. Implementé la **Opción B** sin tocar el motor del alta. Resumen de los cambios (todos en `rrmm-utils`, capa de reconciliación):

**1. `ReconciliacionProtocolosDaoImpl.repararProtocolosHuerfanos(rmId, userVigId)`** — nuevo método que inserta en `INF3_RM_PROTOCOLOS` los `protocolo_id` referenciados por pruebas no borradas que no tengan fila padre, replicando exactamente la forma en que el alta inserta los protocolos de cliente (`MANUAL=0, ORIGEN_ID=0, NIVEL_VALORACION=0, SUSTANCIA_ID=NULL`). Es literalmente tu consulta 3 convertida en `INSERT ... SELECT`. Loguea con `WARN` cuándo y cuántos repara.

```java
INSERT INTO vig_salud.inf3_rm_protocolos (...)
SELECT seq.nextval, h.protocolo_id, :rmId, 0, SYSDATE, :userId, 0, 0, NULL
FROM (SELECT DISTINCT p.protocolo_id
      FROM vig_salud.inf3_rm_pruebas p
      WHERE p.rm_id = :rmId AND p.borrado IS NULL AND p.protocolo_id IS NOT NULL
        AND NOT EXISTS (SELECT 1 FROM vig_salud.inf3_rm_protocolos pr
                        WHERE pr.rm_id = :rmId AND pr.protocolo_id = p.protocolo_id)) h
```

**2. Interfaz `ReconciliacionProtocolosDao`** — firma + Javadoc documentando el bug del alta y el alcance del workaround.

**3. `AplicarProtocolosReconocimientoServiceImpl`** — paso `3.b`, llamada a `repararProtocolosHuerfanos` justo después de `cargarConfiguracionProtocolosReconocimiento`.

Puntos clave del enfoque:
- **Nada se toca en el proceso de alta**; todo el comentario sobre el bug queda en nuestros archivos (DAO impl, interfaz y service), con un `TODO` para retirar el workaround si el alta corrige la asimetría.
- Es **idempotente**: el `NOT EXISTS` evita duplicar protocolos en reintentos.
- Las pruebas conservadas por CA-14 (con `protocolo_id = NULL`) no se ven afectadas, porque el filtro exige `protocolo_id IS NOT NULL`.

Sin errores de linter. Para tu caso `12341907`, tras volver a ejecutar el `confirmar()` deberías ver `protocolos=1` en el resumen `[CP-APLICAR]` y las 23 pruebas dejarán de ser huérfanas.

¿Quieres que compile `rrmm-utils` para confirmar que todo queda correcto antes de que pruebes en local?

---

**User**

log rrmm-utils:
15:05:14: Executing ':com.preving.restapi.rrmmutils.RestApiRrmmUtilsApplication.main()'…

Console output is saving to: C:\Repository\rrmm-utils\rrmm-utils.log
> Task :compileJava
> Task :generateGitProperties UP-TO-DATE
> Task :processResources UP-TO-DATE
> Task :classes
Connected to the target VM, address: 'localhost:62970', transport: 'socket'

> Task :com.preving.restapi.rrmmutils.RestApiRrmmUtilsApplication.main()

  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::                (v2.7.1)

2026-06-24 15:05:27.594  INFO 11440 --- [           main] c.p.r.r.RestApiRrmmUtilsApplication      : Starting RestApiRrmmUtilsApplication using Java 17.0.12 on GP82502 with PID 11440 (C:\Repository\rrmm-utils\build\classes\java\main started by jcanasc in C:\Repository\rrmm-utils)
2026-06-24 15:05:27.600 DEBUG 11440 --- [           main] c.p.r.r.RestApiRrmmUtilsApplication      : Running with Spring Boot v2.7.1, Spring v5.3.21
2026-06-24 15:05:27.601  INFO 11440 --- [           main] c.p.r.r.RestApiRrmmUtilsApplication      : The following 1 profile is active: "dev"
2026-06-24 15:05:30.366  INFO 11440 --- [           main] .s.d.r.c.RepositoryConfigurationDelegate : Bootstrapping Spring Data JPA repositories in DEFAULT mode.
2026-06-24 15:05:30.415  INFO 11440 --- [           main] .s.d.r.c.RepositoryConfigurationDelegate : Finished Spring Data repository scanning in 16 ms. Found 0 JPA repository interfaces.
2026-06-24 15:05:31.580  INFO 11440 --- [           main] faultConfiguringBeanFactoryPostProcessor : No bean named 'errorChannel' has been explicitly defined. Therefore, a default PublishSubscribeChannel will be created.
2026-06-24 15:05:31.611  INFO 11440 --- [           main] faultConfiguringBeanFactoryPostProcessor : No bean named 'integrationHeaderChannelRegistry' has been explicitly defined. Therefore, a default DefaultHeaderChannelRegistry will be created.
2026-06-24 15:05:33.236  INFO 11440 --- [           main] trationDelegate$BeanPostProcessorChecker : Bean 'org.springframework.integration.config.IntegrationManagementConfiguration' of type [org.springframework.integration.config.IntegrationManagementConfiguration] is not eligible for getting processed by all BeanPostProcessors (for example: not eligible for auto-proxying)
2026-06-24 15:05:33.260  INFO 11440 --- [           main] trationDelegate$BeanPostProcessorChecker : Bean 'integrationChannelResolver' of type [org.springframework.integration.support.channel.BeanFactoryChannelResolver] is not eligible for getting processed by all BeanPostProcessors (for example: not eligible for auto-proxying)
2026-06-24 15:05:35.031  INFO 11440 --- [           main] o.s.b.w.embedded.tomcat.TomcatWebServer  : Tomcat initialized with port(s): 8081 (http)
2026-06-24 15:05:35.073  INFO 11440 --- [           main] o.apache.catalina.core.StandardService   : Starting service [Tomcat]
2026-06-24 15:05:35.074  INFO 11440 --- [           main] org.apache.catalina.core.StandardEngine  : Starting Servlet engine: [Apache Tomcat/9.0.64]
2026-06-24 15:05:35.483  INFO 11440 --- [           main] o.a.c.c.C.[.[localhost].[/rrmm-utils]    : Initializing Spring embedded WebApplicationContext
2026-06-24 15:05:35.483  INFO 11440 --- [           main] w.s.c.ServletWebServerApplicationContext : Root WebApplicationContext: initialization completed in 7760 ms
2026-06-24 15:05:41.430  INFO 11440 --- [           main] o.hibernate.jpa.internal.util.LogHelper  : HHH000204: Processing PersistenceUnitInfo [name: default]
2026-06-24 15:05:41.671  INFO 11440 --- [           main] org.hibernate.Version                    : HHH000412: Hibernate ORM core version 5.6.9.Final
2026-06-24 15:05:42.312  INFO 11440 --- [           main] o.hibernate.annotations.common.Version   : HCANN000001: Hibernate Commons Annotations {5.1.2.Final}
2026-06-24 15:05:43.174  INFO 11440 --- [           main] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Starting...
2026-06-24 15:05:44.101  INFO 11440 --- [           main] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Start completed.
2026-06-24 15:05:44.131  INFO 11440 --- [           main] org.hibernate.dialect.Dialect            : HHH000400: Using dialect: org.hibernate.dialect.Oracle10gDialect
2026-06-24 15:05:44.376  INFO 11440 --- [           main] org.hibernate.orm.beans                  : HHH10005002: No explicit CDI BeanManager reference was passed to Hibernate, but CDI is available on the Hibernate ClassLoader.
2026-06-24 15:05:44.710  INFO 11440 --- [           main] o.h.e.t.j.p.i.JtaPlatformInitiator       : HHH000490: Using JtaPlatform implementation: [org.hibernate.engine.transaction.jta.platform.internal.NoJtaPlatform]
2026-06-24 15:05:44.729  INFO 11440 --- [           main] j.LocalContainerEntityManagerFactoryBean : Initialized JPA EntityManagerFactory for persistence unit 'default'
2026-06-24 15:05:45.574  INFO 11440 --- [           main] o.s.c.g.a.c.GcpContextAutoConfiguration  : The default project ID is erp-microservicios
2026-06-24 15:05:45.679  INFO 11440 --- [           main] o.s.c.g.core.DefaultCredentialsProvider  : Default credentials provider for service account pub-sub-csv@erp-microservicios.iam.gserviceaccount.com
2026-06-24 15:05:45.679  INFO 11440 --- [           main] o.s.c.g.core.DefaultCredentialsProvider  : Scopes in use by default credentials: [https://www.googleapis.com/auth/pubsub, https://www.googleapis.com/auth/spanner.admin, https://www.googleapis.com/auth/spanner.data, https://www.googleapis.com/auth/datastore, https://www.googleapis.com/auth/sqlservice.admin, https://www.googleapis.com/auth/devstorage.read_only, https://www.googleapis.com/auth/devstorage.read_write, https://www.googleapis.com/auth/cloudruntimeconfig, https://www.googleapis.com/auth/trace.append, https://www.googleapis.com/auth/cloud-platform, https://www.googleapis.com/auth/cloud-vision, https://www.googleapis.com/auth/bigquery, https://www.googleapis.com/auth/monitoring.write]
2026-06-24 15:05:48.377  INFO 11440 --- [           main] o.s.s.web.DefaultSecurityFilterChain     : Will secure any request with [org.springframework.security.web.session.DisableEncodeUrlFilter@662b17b3, org.springframework.security.web.context.request.async.WebAsyncManagerIntegrationFilter@6a7b523b, org.springframework.security.web.context.SecurityContextPersistenceFilter@6137a032, org.springframework.security.web.header.HeaderWriterFilter@775b908f, org.springframework.security.web.authentication.logout.LogoutFilter@9c53820, com.preving.security.JwtAuthenticationTokenFilter@4d2950ed, org.springframework.security.web.savedrequest.RequestCacheAwareFilter@48187168, org.springframework.security.web.servletapi.SecurityContextHolderAwareRequestFilter@1b10963a, org.springframework.security.web.authentication.AnonymousAuthenticationFilter@41c77861, org.springframework.security.web.session.SessionManagementFilter@310cd0d2, org.springframework.security.web.access.ExceptionTranslationFilter@510d6e38, org.springframework.security.web.access.intercept.FilterSecurityInterceptor@745690d7]
2026-06-24 15:05:55.294  INFO 11440 --- [           main] o.s.b.a.e.web.EndpointLinksResolver      : Exposing 1 endpoint(s) beneath base path '/actuator'
2026-06-24 15:05:55.832  INFO 11440 --- [           main] o.s.i.endpoint.EventDrivenConsumer       : Adding {logging-channel-adapter:_org.springframework.integration.errorLogger} as a subscriber to the 'errorChannel' channel
2026-06-24 15:05:55.832  INFO 11440 --- [           main] o.s.i.channel.PublishSubscribeChannel    : Channel 'rrmm-utils.errorChannel' has 1 subscriber(s).
2026-06-24 15:05:55.834  INFO 11440 --- [           main] o.s.i.endpoint.EventDrivenConsumer       : started bean '_org.springframework.integration.errorLogger'
2026-06-24 15:05:55.883  INFO 11440 --- [           main] o.s.b.w.embedded.tomcat.TomcatWebServer  : Tomcat started on port(s): 8081 (http) with context path '/rrmm-utils'
2026-06-24 15:05:55.928  INFO 11440 --- [           main] c.p.r.r.RestApiRrmmUtilsApplication      : Started RestApiRrmmUtilsApplication in 30.498 seconds (JVM running for 31.758)
2026-06-24 15:05:55.948  INFO 11440 --- [           main] .p.r.r.p.c.ReconocimientosIdemioConsumer : INACTIVE Subscription: projects/erp-microservicios/subscriptions/recos.events.notifications.recosValidados-sub-idemio
2026-06-24 15:05:55.949  INFO 11440 --- [           main] .r.r.p.c.ReconocimientosInformesConsumer : INACTIVE Subscription: projects/erp-microservicios/subscriptions/recos.events.notifications.recosValidados-sub-informes
2026-06-24 15:06:01.350  INFO 11440 --- [nio-8081-exec-1] o.a.c.c.C.[.[localhost].[/rrmm-utils]    : Initializing Spring DispatcherServlet 'dispatcherServlet'
2026-06-24 15:06:01.351  INFO 11440 --- [nio-8081-exec-1] o.s.web.servlet.DispatcherServlet        : Initializing Servlet 'dispatcherServlet'
2026-06-24 15:06:01.352  INFO 11440 --- [nio-8081-exec-1] o.s.web.servlet.DispatcherServlet        : Completed initialization in 1 ms
2026-06-24 15:06:03.480  INFO 11440 --- [nio-8081-exec-1] licarProtocolosReconocimientoServiceImpl : [CP-APLICAR] rmId=12341907 INICIO puestoId=73504 tipoPuesto=0 adicionales=0 userVigId=155527
2026-06-24 15:06:03.559 DEBUG 11440 --- [nio-8081-exec-1] .r.d.r.r.ReconciliacionProtocolosDaoImpl : [CP-APLICAR] rmId=12341907 limpieza vig_salud.inf3_rm_protocolos filas=0
2026-06-24 15:06:03.584 DEBUG 11440 --- [nio-8081-exec-1] .r.d.r.r.ReconciliacionProtocolosDaoImpl : [CP-APLICAR] rmId=12341907 limpieza vig_salud.inf3_rm_pruebas filas=27
2026-06-24 15:06:03.599 DEBUG 11440 --- [nio-8081-exec-1] .r.d.r.r.ReconciliacionProtocolosDaoImpl : [CP-APLICAR] rmId=12341907 limpieza vig_salud.inf3_rm_perfiles filas=0
2026-06-24 15:06:03.614 DEBUG 11440 --- [nio-8081-exec-1] .r.d.r.r.ReconciliacionProtocolosDaoImpl : [CP-APLICAR] rmId=12341907 limpieza vig_salud.inf3_rm_parametros filas=0
2026-06-24 15:06:03.628 DEBUG 11440 --- [nio-8081-exec-1] .r.d.r.r.ReconciliacionProtocolosDaoImpl : [CP-APLICAR] rmId=12341907 limpieza vig_salud.inf3_rm_cuestionarios filas=2
2026-06-24 15:06:03.643 DEBUG 11440 --- [nio-8081-exec-1] .r.d.r.r.ReconciliacionProtocolosDaoImpl : [CP-APLICAR] rmId=12341907 limpieza vig_salud.inf3_rm_ipromes filas=0
2026-06-24 15:06:03.658 DEBUG 11440 --- [nio-8081-exec-1] .r.d.r.r.ReconciliacionProtocolosDaoImpl : [CP-APLICAR] rmId=12341907 limpieza vig_salud.inf3_rm_productos_quimicos filas=0
2026-06-24 15:06:03.658 DEBUG 11440 --- [nio-8081-exec-1] licarProtocolosReconocimientoServiceImpl : [CP-APLICAR] rmId=12341907 limpieza INF3_RM_* filas eliminadas=29
2026-06-24 15:06:03.961  WARN 11440 --- [nio-8081-exec-1] .r.d.r.r.ReconciliacionProtocolosDaoImpl : [CP-APLICAR] rmId=12341907 reparados 1 protocolo(s) huérfano(s) (bug asimetría alta: pruebas con protocolo de cliente sin fila en INF3_RM_PROTOCOLOS)
2026-06-24 15:06:04.319  INFO 11440 --- [nio-8081-exec-1] licarProtocolosReconocimientoServiceImpl : [CP-APLICAR] rmId=12341907 OK protocolos=1 pruebas=27 perfiles=0 parametros=0 cuestionarios=2 ipromes=0 productosQuimicos=0 periodicidadId=6 acpId=51514 conservadasCa14=0


Log rrmm-backend:
2026-06-24 15:05:57.571  INFO 5324 --- [nio-8825-exec-8] c.p.r.r.w.c.CambioPuestoController       : [cambio-puesto] PUT rmId=12341907 accion=CONFIRMAR destino cli/cen/puesto=234783/598076/73504
2026-06-24 15:05:57.589  INFO 5324 --- [nio-8825-exec-8] c.p.r.r.s.c.CambioPuestoServiceImpl      : [cambio-puesto] rmId=12341907 validacion=V01_REQUEST_BASICO OK accion=CONFIRMAR destino=cli/cen/puesto=234783/598076/73504 estandar=0
2026-06-24 15:06:01.002  INFO 5324 --- [nio-8825-exec-8] c.p.r.r.s.c.CambioPuestoServiceImpl      : [cambio-puesto] rmId=12341907 CONFIRMAR inicio origen=cli/cen/puesto=234783/598076/73504 destino=cli/cen/puesto=234783/598076/73504 estandar=0 adicionales=0
2026-06-24 15:06:01.017  INFO 5324 --- [nio-8825-exec-8] c.p.r.r.s.c.CambioPuestoServiceImpl      : [cambio-puesto] rmId=12341907 validacion=V02_RM_PENDIENTE OK estadoLog=8
2026-06-24 15:06:01.032  INFO 5324 --- [nio-8825-exec-8] c.p.r.r.s.c.CambioPuestoServiceImpl      : [cambio-puesto] rmId=12341907 validacion=V03_DESTINO_PVS OK cli/cen=234783/598076
2026-06-24 15:06:01.032  INFO 5324 --- [nio-8825-exec-8] c.p.r.r.s.c.CambioPuestoRlOrchestrator   : [cambio-puesto] rmId=12341907 resolverRl origen=234783/598076/73504 destino=234783/598076/73504 trabajadorId=1396951
2026-06-24 15:06:01.046  INFO 5324 --- [nio-8825-exec-8] c.p.r.r.s.c.CambioPuestoRlOrchestrator   : [cambio-puesto] rmId=12341907 validacion=V05_RL_ORIGEN OK rlId=4782157 cli/cen=234783/598076
2026-06-24 15:06:01.061  INFO 5324 --- [nio-8825-exec-8] c.p.r.r.s.c.CambioPuestoRlOrchestrator   : [cambio-puesto] rmId=12341907 validacion=V06_RL_DESTINO OK rlId=4782157 cli/cen=234783/598076
2026-06-24 15:06:01.061  INFO 5324 --- [nio-8825-exec-8] c.p.r.r.s.c.CambioPuestoRlOrchestrator   : [cambio-puesto] rmId=12341907 validacion=V07_RL_DECISION OK SOLO_ADICIONALES mismo puesto principal
2026-06-24 15:06:01.061  INFO 5324 --- [nio-8825-exec-8] c.p.r.r.s.c.CambioPuestoRlOrchestrator   : [cambio-puesto] rmId=12341907 rlEscenario=SOLO_ADICIONALES rlAfectadaId=4782157 rlAccion=EDITADA rlOrigen=4782157 rlDestino=4782157
2026-06-24 15:06:01.061  INFO 5324 --- [nio-8825-exec-8] c.p.r.r.s.c.CambioPuestoServiceImpl      : [cambio-puesto] rmId=12341907 validacion=V04_RL_RESOLUCION OK escenario=SOLO_ADICIONALES rlAfectadaId=4782157
2026-06-24 15:06:01.064  INFO 5324 --- [nio-8825-exec-8] c.p.r.r.s.c.CambioPuestoServiceImpl      : [cambio-puesto] rmId=12341907 validacion=V11_EDITOR OK editorId=155527
2026-06-24 15:06:01.199  INFO 5324 --- [nio-8825-exec-8] .p.r.r.s.c.CambioPuestoImpactoReaderImpl : [cambio-puesto] snapshot rmId=12341907 protocolos=0 pruebas=26 parametros=0 perfiles=0 cuestionarios=2
2026-06-24 15:06:01.199  INFO 5324 --- [nio-8825-exec-8] c.p.r.r.s.c.CambioPuestoServiceImpl      : [cambio-puesto] rmId=12341907 validacion=V05_JWT OK token presente
2026-06-24 15:06:01.216  INFO 5324 --- [nio-8825-exec-8] .r.s.c.RrmmUtilsImpactoPropuestoResolver : [cambio-puesto] rmId=12341907 validacion=V06_P1_SOLO_ADIC OK sin cambio adicionales propuesto=actual
2026-06-24 15:06:01.217  INFO 5324 --- [nio-8825-exec-8] c.p.r.r.s.c.CambioPuestoServiceImpl      : [cambio-puesto] rmId=12341907 validacion=V12_PROTOCOLOS_LOG OK sin delta protocolos
2026-06-24 15:06:01.217  INFO 5324 --- [nio-8825-exec-8] c.p.r.r.s.c.CambioPuestoServiceImpl      : [cambio-puesto] rmId=12341907 CONFIRMAR protocolosLog anadidos=0 eliminados=0
2026-06-24 15:06:01.217  INFO 5324 --- [nio-8825-exec-8] c.p.r.r.s.c.CambioPuestoServiceImpl      : [cambio-puesto] rmId=12341907 CONFIRMAR mutando rl escenario=SOLO_ADICIONALES rlAfectadaId=4782157 rlAccion=EDITADA
2026-06-24 15:06:01.217  INFO 5324 --- [nio-8825-exec-8] c.p.r.r.s.c.CambioPuestoRlExecutor       : [cambio-puesto] rmId=12341907 rlEjecutar inicio escenario=SOLO_ADICIONALES rlAfectadaId=4782157 rmClienteId=234783 destino=234783/598076/73504
2026-06-24 15:06:01.217  INFO 5324 --- [nio-8825-exec-8] c.p.r.r.s.c.CambioPuestoRlExecutor       : [cambio-puesto] rmId=12341907 validacion=V06_OK_TECNICO OK omitida escenario SOLO_ADICIONALES
2026-06-24 15:06:01.231  INFO 5324 --- [nio-8825-exec-8] c.p.r.r.d.c.CambioPuestoDaoImpl          : [cambio-puesto] dao syncAdicionalesRl rlId=4782157 bajas=0 altas=0
2026-06-24 15:06:01.232  INFO 5324 --- [nio-8825-exec-8] c.p.r.r.s.c.CambioPuestoRlExecutor       : [cambio-puesto] rlMutada escenario=SOLO_ADICIONALES rlId=4782157 rlAccion=EDITADA (solo adicionales)
2026-06-24 15:06:01.250  INFO 5324 --- [nio-8825-exec-8] c.p.r.r.d.c.CambioPuestoDaoImpl          : [cambio-puesto] dao updateInfRm rmId=12341907 puesto=73504 infPtrTipo=2 cli/cen=234783/598076
2026-06-24 15:06:01.250  INFO 5324 --- [nio-8825-exec-8] c.p.r.r.s.c.CambioPuestoServiceImpl      : [cambio-puesto] rmId=12341907 infRm actualizado puesto=73504 tipo=2 cli/cen=234783/598076 rmMovido=NO
2026-06-24 15:06:01.250  INFO 5324 --- [nio-8825-exec-8] c.p.r.r.s.c.CambioPuestoServiceImpl      : [cambio-puesto] rmId=12341907 validacion=V13_ADICIONALES_RM OK count=0
2026-06-24 15:06:01.264  INFO 5324 --- [nio-8825-exec-8] c.p.r.r.s.c.CambioPuestoServiceImpl      : [cambio-puesto] rmId=12341907 adicionalesRm actualizados count=0
2026-06-24 15:06:01.264  INFO 5324 --- [nio-8825-exec-8] c.p.r.r.s.c.CambioPuestoServiceImpl      : [cambio-puesto] rmId=12341907 validacion=V05_JWT OK token presente
2026-06-24 15:06:04.393  INFO 5324 --- [nio-8825-exec-8] c.p.r.r.s.c.RrmmUtilsClientImpl          : [cambio-puesto] rmId=12341907 validacion=V07_APLICAR_HTTP OK protocolos=1 pruebas=27 conservadasCa14=0
2026-06-24 15:06:04.408  INFO 5324 --- [nio-8825-exec-8] c.p.r.r.d.c.CambioPuestoDaoImpl          : [cambio-puesto] dao updateInfRmConfigProtocolos rmId=12341907 acpId=51514 periodicidadId=6
2026-06-24 15:06:04.408  INFO 5324 --- [nio-8825-exec-8] c.p.r.r.s.c.CambioPuestoServiceImpl      : [cambio-puesto] rmId=12341907 CONFIRMAR applier ok protocolos=1 pruebas=27 perfiles=0 parametros=0 cuestionarios=2 conservadasCa14=0 periodicidadId=6
2026-06-24 15:06:04.440  INFO 5324 --- [nio-8825-exec-8] c.p.r.r.d.c.CambioPuestoLogDaoImpl       : [cambio-puesto] log CA-17 insertado id=4 rmId=12341907 origen=234783/73504 destino=234783/73504 rlAfectadaId=4782157 rlAccion=EDITADA protocolos +/-=0/0
2026-06-24 15:06:04.441  INFO 5324 --- [nio-8825-exec-8] c.p.r.r.s.c.CambioPuestoServiceImpl      : [cambio-puesto] rmId=12341907 CONFIRMAR ok logId=4 rlAfectadaId=4782157 rlAccion=EDITADA destino cli/cen/puesto=234783/598076/73504 editorId=155527


---

**Cursor**

El flujo ya funciona de extremo a extremo. Lo confirman ambos logs:

**rrmm-utils**
```
[CP-APLICAR] rmId=12341907 reparados 1 protocolo(s) huérfano(s) (bug asimetría alta...)
[CP-APLICAR] rmId=12341907 OK protocolos=1 pruebas=27 ... periodicidadId=6 acpId=51514 conservadasCa14=0
```
El workaround detectó el protocolo 21 huérfano y lo reincorporó → `protocolos=1` (antes `0`). Las 27 pruebas ya tienen padre.

**rrmm-backend**
```
V07_APLICAR_HTTP OK protocolos=1 pruebas=27 conservadasCa14=0
dao updateInfRmConfigProtocolos rmId=12341907 acpId=51514 periodicidadId=6
CONFIRMAR applier ok protocolos=1 ... periodicidadId=6
CONFIRMAR ok logId=4 ...
```
El orquestador recibe `protocolos=1`, persiste ACP + periodicidad en `INF_RM` en su propia transacción (sin lock distribuido) e inserta el log CA-17. Confirmar termina OK.

Para cerrar la verificación en BD, vuelve a lanzar tus consultas sobre `12341907`:
- **Consulta 1** (`COUNT inf3_rm_protocolos`) ahora debe dar **1**.
- **Consulta 3** (huérfanos: pruebas con `protocolo_id` sin fila padre) debe dar **0 filas**.

Notas menores que vi en los logs, por si quieres revisarlas (no bloquean):
- El snapshot previo del backend marcaba `pruebas=26` y la limpieza eliminó `27`. Es esperable (el snapshot es del estado anterior y puede contar con filtros distintos a la limpieza), pero conviene tenerlo presente si más adelante cuadras conteos exactos.
- `perfiles=0 parametros=0`: coherente con que el puesto destino no tiene configuración propia y solo hereda protocolos de cliente.

Con esto BE-07 queda funcionando: rebuild + CA-14 + reparación de protocolos huérfanos + persistencia de ACP/periodicidad en el orquestador. ¿Quieres que compile y ejecute los tests de `rrmm-utils` para dejar la suite verde con el nuevo método, o lo dejamos aquí?

---

**User**

necesito que me digas cuales son las dudas que tenemos actualemtne

---

**Cursor**

Estas son las dudas/puntos abiertos que tenemos ahora mismo en BE-07 (cambio de puesto), agrupadas por a quién corresponde resolverlas.

## 1. Para negocio

- **Alcance real de CA-14 ("check verde").** Hoy conservamos la visibilidad solo de **3 bloques conocidos** (anamnesis/antecedentes, hábitos, control de visión). Falta confirmar con negocio si el requisito es preservar **todas** las pruebas realizadas o si estos 3 bloques cubren el caso de uso real.
- **Pruebas realizadas que desaparecen en el puesto destino y NO están en esos 3 bloques.** ¿Qué espera ver el usuario? ¿Se mantienen visibles aunque la nueva configuración ya no las incluya, o pueden desaparecer del índice? (los datos clínicos no se borran nunca, la duda es solo de visibilidad).

## 2. Para el equipo técnico / del alta

- **Fuente real del "check verde".** Necesitamos la misma lógica/endpoint que usa la pantalla del RM para marcar una prueba como "realizada". Sin eso, la detección de CA-14 sigue siendo heurística (por prefijos de `INF2_RM_VALORES`) y acotada. Es el `TODO (técnico - Felix)` que dejamos en `ReconciliacionProtocolosDaoImpl` / la interfaz.
- **Bug de asimetría del alta.** En `insertarProtocolosParaReconocimientoByTipoYConfigsIds`, los protocolos solo se insertan si hay configuración, pero las pruebas de protocolo se insertan también con solo protocolos de cliente → pruebas huérfanas. Lo estamos **parcheando en nuestro lado** (`repararProtocolosHuerfanos`). Duda: ¿el equipo del alta corrige la condición en origen? Si lo hacen, podemos **retirar nuestro workaround**.

## 3. Verificaciones técnicas pendientes (nuestras)

- **Descuadre de conteo 26 vs 27.** El snapshot previo del backend marcó `pruebas=26` y la limpieza eliminó `27`. Hay que confirmar que la diferencia es solo por filtros/estado del snapshot y no un conteo real distinto.
- **`perfiles=0`, `parametros=0`, `productosQuimicos=0`.** Coherente con que el puesto destino no tiene configuración propia (solo hereda protocolos de cliente), pero conviene validarlo con un caso de puesto **con** configuración propia para asegurar que esas ramas también materializan bien.
- **Tests automáticos.** La suite de `rrmm-utils` aún no cubre el nuevo `repararProtocolosHuerfanos` ni se ha vuelto a ejecutar tras los últimos cambios.

¿Quieres que prepare un mini-documento/resumen con estas dudas para enviar a negocio y al equipo técnico, o que avancemos con alguna de las verificaciones técnicas (por ejemplo, dejar la suite de tests verde)?

---

**User**

vale necesito que cubras la suite de test y ademas repases todo lo de cambios de puestos a ver si nos quedan test por cubrir, no hace falta que me preguntes por los tests, ves creando y hazme resumen al final

---

**Cursor**

Voy a crear un plan, explorar todo el código de cambios de puesto (en `rrmm-utils` y `rrmm-backend`), ver qué tests existen y cuáles faltan, y empezar a cubrirlos. Primero mapeo el terreno.

Mapeo en paralelo el código y los tests de cambio de puesto en ambos repos.

Hay buena cobertura ya. Veo que faltan claramente tests para `ReconciliacionProtocolosDaoImpl` (el DAO nuevo con `repararProtocolosHuerfanos`). Reviso el test del applier existente y patrones de test de DAO para seguir el estilo del proyecto.

Tengo los patrones (mock de `NamedParameterJdbcTemplate` con captura de SQL/params, y mock del service). Reviso el DAO de backend y el test de servicio para cubrir también lo que tocamos allí.

Veo el constructor/inyección del DAO de backend y reviso el test de servicio existente para no duplicar.

El service de backend ya cubre la persistencia de ACP/periodicidad (`updateInfRmConfiguracionProtocolos`) y los flags del applier. Lo que falta cubrir:
1. `ReconciliacionProtocolosDaoImpl` (DAO nuevo, incluido `repararProtocolosHuerfanos`) — sin test.
2. La llamada a `repararProtocolosHuerfanos` en el orden del applier.
3. `CambioPuestoDaoImpl.updateInfRmConfiguracionProtocolos` a nivel de DAO (SQL/params) — sin test.

Empiezo creando el test del DAO de reconciliación en `rrmm-utils`.

Marco progreso y actualizo el test del applier para verificar la reparación en el orden correcto.

Marco t3 y creo el test del DAO de backend para `updateInfRmConfiguracionProtocolos`.

Sin errores de linter. Ahora compilo y ejecuto los tests afectados en ambos proyectos. Empiezo por `rrmm-utils`.

`rrmm-utils` verde. Ahora `rrmm-backend`.

Ambas suites en verde. Cierro los todos y resumo.

Listo. Resumen del trabajo de tests de cambios de puesto.

## Tests creados / ampliados

**`rrmm-utils`**
- **Nuevo `ReconciliacionProtocolosDaoImplTest`** (cubre el DAO nuevo que no tenía tests):
  - `repararProtocolosHuerfanos`: verifica el `INSERT` sobre `INF3_RM_PROTOCOLOS`, que replica la forma del alta (`MANUAL=0, ORIGEN_ID=0, NIVEL=0, SUSTANCIA NULL`), los params `rmId/userId`, y la idempotencia (devuelve 0 sin huérfanos).
  - `limpiarConfiguracionInf3`: borra las **7** tablas de configuración, suma filas y **no toca `INF3_RM_ANEXOS`**.
  - `reinsertarPruebaConservada` (CA-14): inserta como `MANUAL=1` y `protocolo_id NULL` con los params correctos.
  - `getPruebaIdsConfigurados`, `getPruebasRealizadasByRmId` (consulta los 3 bloques conocidos y salta el que no tiene IDs) y `contarConfiguracionInf3`.
- **Ampliado `AplicarProtocolosReconocimientoServiceImplTest`**: el camino feliz ahora verifica que `repararProtocolosHuerfanos` se invoca **en orden**, justo tras regenerar la configuración y antes de contar.

**`rrmm-backend`**
- **Nuevo `CambioPuestoDaoImplTest`** (foco en lo que añadimos):
  - `updateInfRmConfiguracionProtocolos`: persiste ACP + periodicidad **sin tocar `MC_ID`/`MT_VALIDA`**, mapea los flags booleanos a `1/0`, y con `periodicidadId=null` mantiene la periodicidad previa (`CASE WHEN ... ELSE`).

## Resultado de ejecución
- `rrmm-utils`: **BUILD SUCCESSFUL** (DAO + applier).
- `rrmm-backend`: **BUILD SUCCESSFUL** (DAO + service, este último ya cubría el applier y la persistencia ACP).

## Repaso de cobertura: qué queda sin test (no crítico para BE-07)
Estas clases de `cambiopuesto` en `rrmm-backend` siguen sin test unitario propio, pero son envoltorios finos (clientes HTTP / DAOs / rowmapper) y no se tocaron en este trabajo:
- `RrmmUtilsClientImpl` y `PuestosBackClientImpl` (clientes HTTP a microservicios).
- `CambioPuestoLogDaoImpl` (DAO de log CA-17).
- `CambioPuestoImpactoPropuestoResolver` (el resolver "RrmmUtils" sí tiene test; este no).
- `CambioPuestoImpactoItemRowMapper` y `CambioPuestoTrace` (utilitarios).

El resto del flujo de cambio de puesto (service, orquestador RL, executor RL, matcher, snapshot composer, delta calculator, reader, mapper request/impacto, controller, simular-mock y log-json) ya tenía cobertura previa, que sigue en verde.

¿Quieres que cubra también los clientes HTTP (`RrmmUtilsClientImpl`/`PuestosBackClientImpl`) y el `CambioPuestoLogDaoImpl`, o lo dejamos aquí dado que quedan fuera del alcance de BE-07?

---

**User**

cubre todo lo posbile y el maximo de flujo posible

---

**Cursor**

Voy a cubrir el máximo de flujo posible de cambios de puesto. Primero leo todas las clases que aún no tienen test para diseñar la cobertura.

Los clients instancian un `RestTemplate` a partir del `getRequestFactory()` del inyectado, así que puedo cubrir el flujo HTTP completo con `MockRestServiceServer`. Leo el resto de clases para diseñar los tests.

El resolver (`CambioPuestoImpactoPropuestoResolver`) es una interfaz cuya impl `RrmmUtilsImpactoPropuestoResolver` ya tiene test, y `CambioPuestoTrace` es logging trivial package-private (se ejercita vía los clients). Leo los DTOs de respuesta para construir los tests de los clients y del log DAO.

Ahora leo el resto de `CambioPuestoDaoImpl` para ampliar su test con más métodos.

Tengo suficiente. Leo `CambioPuestoRmUpdate` para el test de `updateInfRmCambioPuesto` y empiezo a escribir los tests.

Ahora amplío el test del DAO de backend con más métodos.

Marco progreso y creo el test del log DAO y del rowmapper.

Ahora el test del rowmapper (mock de `ResultSet`).

Ahora los tests de los clients HTTP con `MockRestServiceServer`, que sí intercepta el `RestTemplate` creado internamente desde el `getRequestFactory()`.

Compilo y ejecuto las nuevas suites de backend.

Todo verde. Ahora ejecuto las suites completas de ambos proyectos en paralelo para confirmar que no se rompió nada.

Ambas suites completas **BUILD SUCCESSFUL**. Cierro los todos y resumo.

Cobertura ampliada al máximo posible del flujo de cambios de puesto. Resumen final.

## Tests nuevos creados

**`rrmm-backend`**
- **`RrmmUtilsClientImplTest`** (cliente HTTP P1/applier): cubre el **flujo HTTP real** con `MockRestServiceServer` (aprovechando que el client crea su `RestTemplate` desde el `getRequestFactory()` inyectado):
  - `recalcular` y `aplicar` OK (200 → cuerpo mapeado).
  - 404 → `CambioPuestoNotImplementedException`; 500 → `CambioPuestoIntegrationException`.
  - URL no configurada → `NotImplemented`; request inválido (sin `rmId`/`puestoId`) → `IllegalArgumentException`.
- **`PuestosBackClientImplTest`** (cliente HTTP catálogo/RL):
  - `obtenerCatalogoCambioRm` OK, cuerpo vacío (devuelve no-nulo), error HTTP → `IntegrationException`.
  - `cambiarPuestoRl` OK y error HTTP → `IntegrationException`.
- **`CambioPuestoLogDaoImplTest`** (log CA-17): `insert` (obtiene id de secuencia, inserta con params correctos, devuelve id) y `findByRmId` (SQL del histórico ordenado, delega en RowMapper).
- **`CambioPuestoImpactoItemRowMapperTest`** (mock `ResultSet`): item válido (id + etiqueta con `trim`), `ITEM_ID<=0` y SQL `NULL` → `null`, etiqueta en blanco → `null`.
- **`CambioPuestoDaoImplTest` ampliado**: además de `updateInfRmConfiguracionProtocolos`, ahora cubre:
  - `updateInfRmCambioPuesto` (actualiza puesto/cliente/centro, preserva `MC_ID`/`MT_VALIDA` vía `NVL`, `RM_ENVIADO='N'`).
  - `findRlActivaId` (id, `EmptyResult`→null, múltiples→error).
  - `centroTieneContratoPvs` (count>0 / 0 / null).
  - `getNombreCliente`/`getNombreCentro` (nombre o fallback al id).

**`rrmm-utils`** (de la ronda anterior, sigue verde)
- `ReconciliacionProtocolosDaoImplTest` (incl. `repararProtocolosHuerfanos`) y `AplicarProtocolosReconocimientoServiceImplTest` ampliado.

## Resultado
- `rrmm-utils`: **BUILD SUCCESSFUL** (suite completa).
- `rrmm-backend`: **BUILD SUCCESSFUL** (suite completa).

## Estado de cobertura del módulo cambio de puesto
Ya tienen test todas las clases con lógica significativa: `CambioPuestoServiceImpl`, `CambioPuestoDaoImpl`, `CambioPuestoLogDaoImpl`, `RrmmUtilsClientImpl`, `PuestosBackClientImpl`, `RrmmUtilsImpactoPropuestoResolver`, mappers (request/impacto), `CambioPuestoRlOrchestrator`, `CambioPuestoRlExecutor`, `CambioPuestoAdicionalesMatcher`, `CambioPuestoImpactoSnapshotComposer`, `CambioPuestoImpactoDeltaCalculator`, `CambioPuestoImpactoReaderImpl`, `CambioPuestoController`, `CambioPuestoSimularMockProvider`, `CambioPuestoLogProtocolJson`, `CambioPuestoImpactoItemRowMapper`, y en `rrmm-utils` el applier + DAO de reconciliación.

Quedan sin test propio solo elementos sin lógica testable de forma unitaria:
- `CambioPuestoTrace`: helper de logging package-private (se ejercita indirectamente por los clients).
- DTOs/POJOs (`*Request`/`*Response`/`*Update`/`*Item`) y enums (`RlEscenario`): solo getters/setters Lombok.
- `PuestosBackClientImpl.simularImpactoRm`: método `@Deprecated`; cubiertos los métodos vivos del client.

Si quieres, puedo añadir también tests del `simularImpactoRm` deprecado o del `CambioPuestoControllerTest` para escenarios HTTP adicionales, pero con esto el flujo funcional de cambios de puesto queda cubierto de extremo a extremo.

---

**User**

vale siguiente paso, ver que nos queda por hacer de tareas, revisa por donde ibamos y que toca abordar ahora

---

**Cursor**

Voy a revisar el estado del proyecto: el documento de requisitos y el listado de tareas BE para ubicar qué está hecho y qué toca ahora.

Hay un tablero de Monday con las tareas. Lo leo junto con la estimación para ver el desglose BE y su estado.

El CSV está todo en "Pending" pero gran parte de BE ya está implementado. Verifico el estado real revisando el controller y buscando las funcionalidades clave (logs CA-17, avisos CA-15/CU-11) para darte un estado fiable.

El controller expone BE-02→BE-07. No veo endpoint GET de logs ni nada de CA-15/CU-11. Verifico la parte GET de logs (BE-09) y el estado de BE-08/RL.

Confirmo la parte GET de logs (BE-09) y busco BE-11 (CA-15 laboratorio / CU-11) de forma más amplia.

Veo que BE-09 (GET `/logs/cambio-puesto`) está hecho, y que hay "avisos/warnings" en el service. Confirmo qué cubre exactamente para precisar BE-11.

He revisado el tablero de Monday y contrastado con el código real. El CSV está todo en "Pending", pero la realidad del repo es muy distinta. Este es el estado real del backend de cambio de puesto.

## Estado real (BE)

**Sprint 1 — Fundación: COMPLETO**
- BE-01 análisis/contratos, BE-02 clientes, BE-03 centros, BE-04 puestos, BE-05 adicionales → implementados en `CambioPuestoController` + service + `puestos-back` client.

**Sprint 2 — Flujo E2E: casi completo**
- **BE-06** dry-run / impacto (deltas + ACP + periodicidad) → ✅ hecho.
- **BE-07** aplicar cambio (PUT transaccional, applier INF3, persistencia ACP/periodicidad, reparación de huérfanos) → ✅ hecho (lo cerramos hoy + tests).
- **BE-08** integración RL 7 escenarios (`RlOrchestrator`/`RlExecutor`, `cambiar-puesto`, adicionales) → ✅ hecho.
- **BE-09** logs CA-17 → ✅ hecho (insert `INF4_RM_LOG_CAMBIO_PUESTO` + GET `/logs/cambio-puesto`).
- **BE-10** validaciones estado/concurrencia (V01..Vxx, estado Pendiente, ACL) → ✅ hecho.
- **BE-11** avisos laboratorio CA-15 + warnings analítica CU-11 → ⚠️ **PENDIENTE**. En SIMULAR hay avisos de impacto (`protocolosImpacto`/`analiticaImpacto`/`periodicidadImpacto`), pero en **CONFIRMAR los `warnings` se devuelven vacíos** (`Collections.emptyList()`) y **no existe la lógica de aviso de laboratorio (CA-15)**.
- **BE-12** CA-14 no borrar pruebas → ⚠️ **PARCIAL**. Implementado con alcance acotado (anamnesis/hábitos/control visión) + `TODO` pendiente de que el equipo técnico (Felix) exponga la fuente real del "check verde".
- **BE-13** regresión CA-16 legacy (`cambiarRl.do`/`cambiarRm.do`) → ❓ **sin verificar**.

**Cierre — Calidad y PRO**
- **BE-14** tests unit/integración → 🟢 muy avanzado (hoy ampliamos cobertura de todo el módulo).
- **BE-16** Jacoco → ✅ configurado y corriendo (`jacocoTestReport`).
- **BE-17** Pitest → ⚙️ configurado, pendiente ejecutar/revisar mutación.
- **BE-15** soporte plan de pruebas CA-01..CA-17, **BE-18** doc/handover, **BE-22** plan a PRO → ⏳ pendientes (fases finales).

## Qué toca ahora
El único bloque **funcional** que queda en el flujo principal es **BE-11**. Después, lo razonable sería BE-13 (regresión) y cerrar BE-12 cuando llegue la info de Felix; el resto es cierre/calidad/PRO.

¿Por dónde seguimos?

> **¿Qué abordamos ahora?**
> - BE-11: avisos laboratorio (CA-15) + warnings analítica (CU-11) en CONFIRMAR (Recomendado: es el único bloque funcional pendiente) ✔
> - BE-13: verificar regresión del flujo legacy CA-16 (cambiarRl.do/cambiarRm.do)
> - BE-12/CA-14: revisar si ya hay info de Felix para ampliar la detección del 'check verde'
> - Cierre/calidad: ejecutar Pitest (BE-17), documentación (BE-18) o plan a PRO (BE-22)
> - Solo quería el estado; reviso yo y decido luego

Bien, vamos con **BE-11**. Antes de tocar nada necesito entender bien el requisito funcional de CA-15 (aviso laboratorio) y CU-11 (warnings analítica). Reviso el RF y las notas.

Ahora tengo el detalle funcional de BE-11. Resumo lo que exige el RF:

- **CA-15 (§7.7)** — si el reconocimiento **ya tiene comunicación a laboratorio**, aviso obligatorio "El reconocimiento ya tiene comunicación a laboratorio. Revise el impacto antes de continuar." Bloqueo "pendiente de decisión de negocio" (por defecto **no bloqueante**, solo aviso). No se redefine la comunicación.
- **CU-11 / §7.6** — si el cambio **añade nuevos parámetros/perfiles analíticos** y la analítica **ya fue comunicada**, mostrar warning (en Resumen y junto a "Comunicar laboratorio"), mensaje "Nuevos parámetros añadidos. Revise si requiere nueva comunicación." Nunca lanza comunicación automática.

Necesito localizar cómo se detecta en BD que un reconocimiento ya tiene la analítica/laboratorio **comunicado**. Investigo el modelo de analítica/laboratorio.

BE-11 tiene dos decisiones de diseño no triviales que conviene cerrar antes de tocar código:

1. **Fuente de "laboratorio/analítica comunicado"**: no hay un flag directo evidente. `AnaliticaService` solo expone `getLaboratorios` y `existRMsByAnaliticaCodAndLabIdEnCatorceDias`; falta localizar cómo se marca que un RM ya tiene la analítica comunicada (probablemente en `VS_2007`/estudios analíticos). Hay que investigar el modelo.
2. **Decisión funcional pendiente**: el RF marca CA-15 como bloqueo "pendiente de decisión de negocio". Y el contrato de `avisos`/`warnings` que devolvamos lo consume el FE (FE-11), así que conviene fijar las claves.

Dado que esto requiere exploración del modelo de datos de laboratorio y acordar el contrato/comportamiento antes de implementar, propongo pasar a modo Plan para diseñarlo bien y que lo validemos, en vez de empezar a modificar a ciegas.

Entendido, seguimos en modo Agent. Investigo cómo se detecta que un RM ya tiene la analítica comunicada al laboratorio para poder implementar BE-11.

Busco en el DAO de estudios analíticos el concepto de "comunicado/enviado al laboratorio".

Encontré la fuente real: la comunicación al laboratorio se registra en `VS_2007.EA_LAB_COM` (vía `marcarComunicacionEA`, `tipo='EA'`, `item_id`=id del estudio analítico). Veo el resto del DAO por si ya hay una consulta de comunicación por RM reutilizable.

Ya tengo la pieza que faltaba. Te resumo el hallazgo y el plan antes de tocar nada.

## Hallazgo (fuente real de "comunicado a laboratorio")
La comunicación al laboratorio se registra en `VS_2007.EA_LAB_COM` (método `marcarComunicacionEA`: `tipo='EA'`, `item_id` = id de `VIG_SALUD.INF_ESTUDIOS_ANALITICOS`). No existe un flag directo "RM comunicado", pero se deduce cruzando ambas tablas por `rm_id`. No hay aún ninguna consulta reutilizable de "¿este RM ya está comunicado?".

## Plan BE-11
1. **DAO** (`CambioPuestoDao`/`Impl`): nuevo método `tieneAnaliticaComunicada(int rmId)` →
```sql
SELECT COUNT(*) FROM VS_2007.EA_LAB_COM c
JOIN VIG_SALUD.INF_ESTUDIOS_ANALITICOS iea
  ON c.tipo = 'EA' AND c.item_id = iea.id
WHERE iea.rm_id = :rmId AND iea.borrado IS NULL
```
2. **Service** (`CambioPuestoServiceImpl`):
   - **SIMULAR** (`resolverAvisos`): si `tieneAnaliticaComunicada(rmId)` → añadir aviso `laboratorioComunicado` (CA-15). Y si además hay impacto en analítica (parámetros/perfiles añadidos en deltas) → añadir `analiticaComunicadaNuevosParametros` (CU-11 / §7.6).
   - **CONFIRMAR**: poblar `response.setWarnings(...)` (hoy `emptyList()`) con esas mismas claves cuando apliquen.
3. **Tests**: ampliar `CambioPuestoServiceImplTest` y `CambioPuestoDaoImplTest`.

## Decisiones de diseño a confirmar
El RF marca CA-15 con bloqueo "pendiente de decisión de negocio". Y el FE (FE-11) consumirá las claves que devolvamos. Necesito tu visto bueno en dos puntos.

> **CA-15 (laboratorio ya comunicado): ¿cómo lo tratamos al confirmar?**
> - Solo aviso, NO bloquea el cambio (Recomendado: el RF lo deja 'pendiente de decisión' y el alcance dice 'mostrar aviso, no resolver')
> - Bloquear la confirmación si hay laboratorio comunicado

> **¿Qué devolvemos en avisos/warnings para que lo consuma el FE?**
> - Claves código como ahora (laboratorioComunicado, analiticaComunicadaNuevosParametros) y el FE pone el texto i18n (Recomendado: coherente con avisos actuales)
> - Texto completo del mensaje funcional del RF directamente en backend

> **¿Dónde ubico la consulta de detección?**
> - Nuevo método en CambioPuestoDao (cohesión del módulo cambio-puesto) (Recomendado)
> - Reutilizar/ampliar EstudioAnaliticoDao o AnaliticaDao

---

**User**

MINERVA_RF_v6_Entrega_Babooni.html mirate si no lo hiciste este doc primero que nos indican cosas del laboratorio

---

**Cursor**

Tienes razón, reviso ese documento de entrega antes de seguir. Busco lo relativo a laboratorio.

Muy buen apunte — ese documento corrige mi planteamiento. La detección correcta de CA-15 no es la que deduje (cruce con estudios analíticos), sino a nivel de reconocimiento:

**§3.6 del doc de entrega:**
```sql
SELECT COUNT(*) FROM VS_2007.EA_LAB_COM
WHERE TIPO = 'R' AND ITEM_ID = :rmId AND ANULADO IS NULL
```
Es decir: `TIPO='R'` (Reconocimiento), `ITEM_ID = rmId` directamente, y `ANULADO IS NULL` (comunicación **activa**, no anulada). Mucho más simple y fiable que mi versión. Corrijo el plan con esta consulta.

Además el doc confirma:
- `planning-vs` es quien gestiona la comunicación a laboratorio (`EA_LAB_COM`); **no se toca, solo se consulta** → nuestra parte es solo lectura/aviso. ✅ coherente.
- **N1 (pregunta abierta a negocio)**: si CA-15 debe ser **bloqueante o informativo** sigue "pendiente de decisión". El RF §7.7 lo deja igual.

## Plan BE-11 corregido
1. **DAO** `CambioPuestoDao.tieneComunicacionLabActiva(int rmId)` con la consulta del doc (`TIPO='R'`, `ANULADO IS NULL`).
2. **Service**:
   - **SIMULAR** (`resolverAvisos`): si hay comunicación activa → aviso `laboratorioComunicado` (CA-15); y si además los deltas añaden parámetros/perfiles → `analiticaComunicadaNuevosParametros` (CU-11 / §7.6).
   - **CONFIRMAR**: poblar `warnings` (hoy vacío) con esas claves cuando apliquen.
3. **Tests** de DAO y service.

Sobre **N1**, como sigue pendiente de negocio, mi recomendación es implementarlo **no bloqueante (solo aviso)** y dejar el comportamiento centralizado en un punto para poder cambiarlo a bloqueante con una línea si negocio lo decide. Las claves para el FE las dejo como código (`laboratorioComunicado`, `analiticaComunicadaNuevosParametros`), coherente con los avisos actuales.

¿Te encaja arrancar así (no bloqueante + claves código), o prefieres que CA-15 bloquee la confirmación?

---

**User**

el CA-15 no dice nada de bloqueante, asi que para adelante

---

**Cursor**

Perfecto, CA-15 no bloqueante. Adelante. Voy a crear el todo y leer los archivos que necesito tocar.

Necesito ver la estructura de los deltas (parámetros/perfiles añadidos) para CU-11.

Veo la estructura de la respuesta de confirmar y simular. Reviso el patrón de consultas COUNT en `CambioPuestoDaoImpl` para seguir el estilo existente.

Tengo todo lo necesario. Implemento. Empiezo por la interfaz y la implementación del DAO.

Ahora el service. Añado constantes y el helper de avisos de laboratorio.

Ahora actualizo SIMULAR para pasar el flag de laboratorio a los avisos.

Ahora refactorizo CONFIRMAR para calcular los deltas una sola vez y reutilizarlos en el log de protocolos y en los warnings.

Ahora refactorizo `resolverProtocolosLog` para que reciba los deltas ya calculados y añado `calcularDeltasParaConfirmar`.

Reviso lints en los archivos modificados.

Marco el avance y actualizo los tests. Leo el test del service y del DAO.

Los tests existentes siguen valiendo (Mockito devuelve `false` por defecto para el nuevo método). Añado tests específicos de BE-11 en el service.

Ahora el test del DAO. Reviso el patrón existente para consultas COUNT.

I'll add a nested test block for `tieneComunicacionLabActiva` after the `CentroTieneContratoPvs` block.

Compilo y ejecuto las suites relevantes de cambio de puesto en `rrmm-backend`.

Ambas suites en verde. Marco las tareas como completadas.

**BE-11 implementado y en verde.** Resumen de lo hecho:

## Cambios

**1. DAO — detección de comunicación a laboratorio (CA-15)**
- `CambioPuestoDao.tieneComunicacionLabActiva(int rmId)` + implementación con la consulta del doc de entrega (§3.6):

```sql
SELECT COUNT(*) FROM VS_2007.EA_LAB_COM
WHERE TIPO = 'R' AND ITEM_ID = :rmId AND ANULADO IS NULL
```

Solo lectura — la comunicación la gestiona `planning-vs`, no se toca.

**2. Service `CambioPuestoServiceImpl`**
- Constantes de contrato para el FE: `laboratorioComunicado` (CA-15) y `analiticaComunicadaNuevosParametros` (CU-11).
- Helper `avisosLaboratorio(deltas, labComunicado)`: añade `laboratorioComunicado` si hay comunicación activa, y `analiticaComunicadaNuevosParametros` si además los deltas añaden parámetros/perfiles (§7.6). **No bloquea ni lanza comunicación**.
- **SIMULAR**: `resolverAvisos` ahora incorpora estos avisos (se muestran en el Resumen).
- **CONFIRMAR**: refactoricé el cálculo de deltas a `calcularDeltasParaConfirmar` (se computa **una sola vez** y se reutiliza para el log CA-17 y los warnings); `response.setWarnings(...)` ya no es `emptyList()`, se rellena con CA-15/CU-11 cuando aplica.

**3. Tests (todos verdes)**
- `CambioPuestoDaoImplTest`: 3 tests del nuevo método (SQL/params correctos, count 0, count null).
- `CambioPuestoServiceImplTest`: 4 tests nuevos — SIMULAR con/sin lab comunicado, CONFIRMAR con warnings y sin warnings. Los tests previos siguen pasando.

## Notas
- **N1 (bloqueante/informativo)** queda como **informativo/no bloqueante**, según tu confirmación y el RF. Si negocio decide bloquear, el cambio está centralizado en `avisosLaboratorio` + el flujo de CONFIRMAR.
- El contrato son **claves código**; el FE (FE-11) las mapea a los textos del RF ("El reconocimiento ya tiene comunicación a laboratorio…" y "Nuevos parámetros añadidos. Revise si requiere nueva comunicación.").

Con esto, BE-11 cierra el último bloque funcional pendiente del Sprint 2. Quedarían BE-13 (regresión legacy CA-16) y el cierre de BE-12/CA-14 (a la espera del equipo técnico), más las tareas de cierre/calidad.

¿Sigo con BE-13 (verificación de regresión del flujo legacy) o prefieres otra?

---

**User**

cual es el cierre de BE-12

---

**Cursor**

Reviso el estado actual de la implementación de CA-14 para responderte con precisión sobre qué falta para cerrar BE-12.

Aquí tienes el estado de cierre de **BE-12 (CA-14 — "las pruebas/resultados ya realizados no se eliminan")**, según lo que hay hoy en `ReconciliacionProtocolosDaoImpl`.

## Lo que YA está implementado y cierra la parte crítica

La garantía **estricta** de CA-14 (seguridad clínica: no perder datos/resultados ya registrados) **está cubierta**, y no por la heurística sino por diseño del rebuild:

- El rebuild solo borra **tablas de configuración** `INF3_RM_*` (`limpiarConfiguracionInf3`, las 7 de `TABLAS_CONFIG_INF3`). **Nunca** toca las tablas de datos/resultados (`INF2_RM_VALORES`, `INF_RESULTADOS`, etc.). → Los datos ya realizados **no se borran jamás**.
- Excluye deliberadamente `INF3_RM_ANEXOS` (limpiarla sería destructivo).
- Además, para no perder la **visibilidad** de pruebas realizadas cuyo protocolo deja de aplicar, se reincorporan como manuales (`reinsertarPruebaConservada`: `MANUAL=1`, `protocolo_id=NULL`) solo si no están ya en la config nueva.
- Cubierto por tests (`ReconciliacionProtocolosDaoImplTest`).

En términos de **plan de pruebas**, el criterio literal de CA-14 ("cuando el nuevo puesto elimina un protocolo, las pruebas y resultados ya registrados se mantienen") se cumple.

## Lo que falta para el cierre COMPLETO (los 2 TODO)

La limitación está en la **detección** de "prueba realizada" (`getPruebasRealizadasByRmId`), que hoy es una **heurística de alcance acotado** a 3 bloques conocidos (anamnesis/antecedentes, hábitos, control de visión), aproximando "realizada" = hay datos en `INF2_RM_VALORES` con prefijos conocidos. Para darlo por cerrado del todo faltan dos cosas, ambas **dependencias externas**, no código nuestro:

1. **Técnico (Felix)** — fuente real del "check verde": el endpoint/lógica que usa la pantalla del RM para marcar una prueba como realizada, y así cubrir **todas** las pruebas en lugar de solo esos 3 bloques. Mientras no la expongan, la heurística se queda.
2. **Negocio** — alcance: confirmar si basta con preservar la visibilidad de esos bloques o hay que preservar **todas** las pruebas realizadas, y qué debe pasar con una prueba realizada que no esté ni en los bloques conocidos ni en la config nueva (¿se conserva o desaparece?).

## Resumen

- **Cierre crítico (seguridad clínica): hecho.** No se pierden datos ni resultados.
- **Cierre completo (visibilidad de todas las pruebas): bloqueado** a la espera de Felix (fuente del check verde) + decisión de negocio sobre alcance. El código ya deja el `TODO` marcado y el punto de extensión aislado en `getPruebasRealizadasByRmId` para ampliarlo en cuanto llegue esa info.

En la práctica, BE-12 puede darse por **entregado con salvedad documentada**: funciona y es seguro, con una ampliación pendiente de terceros. Si quieres, puedo redactar esa salvedad como nota para Monday/handover, o preparar el esqueleto del método alternativo (lectura de la fuente real) para enchufarlo cuando Felix responda.

---

**User**

no vamos a hacer otra cosa antes, vamos a hacer javadoc bueno, he visto muchas clases sin ello, sobretodo los contratos de las interfaces, revisemos en los 3 proyectos lo que hayamos creado nosotros e infromemos adecuadamente el javadoc

---

**Cursor**

Buen momento para dejar el Javadoc fino, sobre todo en los contratos (interfaces). Antes de editar nada, voy a inventariar qué clases/interfaces de "cambio de puesto" hemos creado en los 3 proyectos y cuáles tienen Javadoc pobre o ausente. Lanzo la exploración en paralelo.

Inventario completo de los 3 proyectos. Resumen del estado de los **contratos (interfaces)** que es lo que más te interesa:

**rrmm-backend** (interfaces flojas):
- `CambioPuestoService` (tipo: no, métodos 0/6), `CambioPuestoDao` (no, 4/20), `CambioPuestoLogDao` (no, 0/2), `CambioPuestoImpactoReader` (falta tipo), `PuestosBackClient` (no, 1/3), `RrmmUtilsClient` (tipo sí, 1/2), `CambioPuestoImpactoPropuestoResolver` (tipo sí, 0/2). Más el método `obtenerLogsCambioPuesto` de `LogService`.

**rrmm-utils** (ya bien): `ReconciliacionProtocolosDao` (6/6) y `AplicarProtocolosReconocimientoService` (1/1) están documentadas; solo mejoras menores (`getPruebaIdsConfigurados`, `contarConfiguracionInf3` sin `@param/@return`).

**puestos-back**: `CambioRmCatalogoDao` (no, 0/5) es la principal sin documentar. `PuestoService`/`PuestoDao` ya tienen doc en los métodos nuevos nuestros (son interfaces compartidas con código histórico).

Además hay muchas clases (impls, controllers, DTOs, excepciones) con Javadoc de tipo ausente — los DTOs hoy se documentan vía `@Schema` OpenAPI.

El volumen total es grande (~88 ficheros). Para no pasarme de alcance, ¿hasta dónde llego?

> **¿Qué alcance de Javadoc aplico sobre lo que creamos en los 3 proyectos?**
> - Contratos (todas las interfaces, tipo + cada método) + Javadoc de TIPO en clases nuestras sin él (controllers, impls, DTOs, excepciones). Sin documentar getters/setters Lombok ni tests (Recomendado)
> - Solo los contratos: interfaces (tipo + métodos). No tocar clases ni DTOs
> - Todo a fondo: interfaces + tipo + descripción método a método también en impls y mappers
>
> Answer: espera antes de esto creo que seria mejor hacer una pasada global en los 3 proyectos y ver que no estamos utilizando, clases, metodos, etc antes de nutrir de javadoc los 3 proyectos

Muy buena decisión — tiene todo el sentido detectar primero código muerto (clases/métodos/DTOs que ya no usamos tras los refactors) y no documentar algo que vamos a borrar. Lanzo un análisis de uso en paralelo por proyecto, sobre el inventario que ya tenemos.

Excelente decisión: el análisis ha sacado a la luz dead code real y, más importante, una posible **incoherencia arquitectónica**. Antes de consolidar, verifico el punto más sensible: si la mutación de RL se hace en local en `rrmm-backend` (y por tanto el endpoint `cambiar-puesto` de `puestos-back` quedó sin consumidor).

Confirmado el punto clave. `cambiarPuestoRl` y `simularImpactoRm` solo aparecen en su propia declaración (interfaz + impl), sin un solo llamador. Y `RlExecutor` muta la relación laboral **en local** escribiendo directamente vía `cambioPuestoDao.puestoTrabajoBaja/Alta` (sobre `PPT_CEN_TRA`).

Aquí está el informe consolidado de los 3 proyectos.

## A. Dead code claro — borrado seguro

**rrmm-backend**
- `PuestosBackClient.simularImpactoRm` (interfaz + impl, `@Deprecated`, 0 usos) — sustituido por `RrmmUtilsImpactoPropuestoResolver`.
- `CambioPuestoImpactoPropuestoResolver.resolver(int, CambioPuestoRequest, String)` — el overload de 3 args no se usa (todo va por el de 4 con `PropuestoImpactoResolveContext`).

**rrmm-utils**
- `PruebaRealizada.codigoPrueba` — se rellena en el SELECT pero **nunca se lee** (CA-14 opera solo por `pruebaId`). Implica simplificar el constructor, quitar `CODIGO_PRUEBA` del SQL y ajustar tests.
- Bug de doc: `AplicarProtocolosResponse.pruebasRealizadasPreservadas` dice "códigos de prueba" pero son **IDs** (`List<Integer>`).

## B. Incoherencia arquitectónica (decisión tuya) — el camino "cambiar RL vía puestos-back"

Tenemos **dos implementaciones** de la mutación de RL y solo usamos una:
- **En uso**: `rrmm-backend` muta la RL en local (`CambioPuestoRlExecutor` → `CambioPuestoDao.puestoTrabajo{Baja,Alta}` sobre `PPT_CEN_TRA`).
- **Sin consumidor**: el camino remoto BE-08 → en `rrmm-backend` `PuestosBackClient.cambiarPuestoRl` + DTOs `CambiarPuestoRlBackRequest/Response`; y en `puestos-back` el endpoint `POST /puestos/{rlId}/cambiar-puesto` + `PuestoManager.cambiarPuestoRl` + DTOs `CambiarPuestoRlRequest/Response`.

Esto contradice el diseño BE-08 ("puestos-back implementa el endpoint de RL; rrmm-backend hace de wrapper"). Hay que decidir qué versión es la buena.

## C. Limpieza menor / opcional (campos de contrato)
- **rrmm-backend**: `PuestoAdicionalItem.nombre`; `CambioPuestoRmUpdate.{rmCfAnioId, mtValida, mcId}` (nunca se setean; el SQL los preserva vía `NVL`); en `AplicarProtocolosBackResponse` los campos `rmId/ipromesInsertados/productosQuimicosInsertados`; `ItemConfiguracionBackDto.protocoloId`; `PeriodicidadBackDto.{id, totalMeses}`.
- **puestos-back**: `CambiarPuestoRlRequest.clienteId` (0 lecturas: se usa el `COD_CLI` de la RL); Javadoc de `rlAccion` menciona un valor `"ASOCIADA"` que nunca se produce (solo `EDITADA`/`CREADA`).
- Ojo: varios de estos son **simetría de contrato HTTP entre repos**; borrarlos obliga a tocar los dos lados.

No he tocado nada todavía. ¿Cómo procedemos?

> **B) El camino 'cambiar RL vía puestos-back' (endpoint + manager + DTOs en ambos repos) está sin consumidor porque rrmm-backend muta la RL en local. ¿Qué hacemos?**
> - Eliminar el camino remoto en ambos repos y quedarnos con la mutación local (confirmamos que la decisión final fue local)
> - Mantenerlo por ahora (no borrar): es una decisión de diseño BE-08 que quiero revisar/consultar antes
> - Reconectar rrmm-backend para usar el endpoint de puestos-back (volver al diseño BE-08; es cambio mayor)
>
> Answer: que dice en el funcional y documentacion al respecto

> **A) Dead code claro (simularImpactoRm, overload resolver 3 args, PruebaRealizada.codigoPrueba + corrección de Javadoc IDs)**
> - Borrar todo el dead code claro y ajustar sus tests (Recomendado) ✔
> - Muéstrame cada uno antes de borrar
> - No borrar de momento

> **C) Campos DTO opcionales (huérfanos / contrato HTTP)**
> - Limpiar solo los internos que NO afectan al contrato HTTP entre repos; conservar el resto (Recomendado) ✔
> - Limpiar todo, tocando ambos repos para mantener simetría
> - No tocar campos; solo corregir los Javadoc engañosos

Para B, reviso qué dice el funcional y la documentación de entrega sobre cómo debe actualizarse la relación laboral. Mientras, A y C quedan aprobados (borrar dead code claro; limpiar solo internos).

La documentación es contundente y revela la discrepancia con claridad. Lo dejo anotado para B y, como A y C ya están aprobados, voy ejecutándolos. Primero leo los ficheros implicados.

Antes de borrar el overload de 3 argumentos, confirmo que no se usa en ningún sitio (main ni tests).

Confirmado: el overload de 3 args solo lo usan 2 tests; `simularImpactoRm` no tiene llamadas; `PruebaRealizada.codigoPrueba` nunca se lee (los `getCodigoPrueba` que aparecen son de otras clases). Preparo el plan y leo los ficheros restantes.

`PuestosBackClientImplTest` no tiene tests de `simularImpactoRm` (solo catálogo y `cambiarPuestoRl`, este último de B), así que A1 no rompe tests. Aplico A1.

Limpio imports que quedaron sin uso en el impl.

A1 listo. Ahora A2: elimino el overload de 3 args.

Ahora actualizo el test que usaba el overload de 3 args.

A2 listo. Ahora A3 en rrmm-utils. Leo el DAO para ajustar el SELECT y el RowMapper.

Modifico el SQL y el RowMapper para no usar `CODIGO_PRUEBA` (la JOIN a `INF3_PRUEBAS` solo servía para esa columna; `PRUEBA_ID` es FK, así que el resultado es idéntico).

Ahora actualizo el DTO `PruebaRealizada`.

Ahora los tests de rrmm-utils que construyen `PruebaRealizada` con 2 args. Leo las zonas concretas.

Ahora corrijo el Javadoc engañoso de `AplicarProtocolosResponse.pruebasRealizadasPreservadas`.

A3 listo. Ahora C: leo el `updateInfRmCambioPuesto` del DAO y el test de preservación MC/MT.

Leo el método `updateInfRmCambioPuesto` y su test.

Leo el test de `updateInfRmCambioPuesto` para reescribir las aserciones.

Ahora aplico C: elimino las 3 columnas del UPDATE y los `addValue`, los campos del DTO, y reescribo la aserción del test (la preservación de MC/MT pasa a ser por omisión).

Reviso lints de los ficheros editados antes de compilar.

Sin errores de lint. Compilo y ejecuto los tests afectados en ambos repos.

Ambos compilan. Ahora ejecuto los tests de cambio de puesto/reconciliación.

Tests en verde en los dos repos (el aviso de `Java HotSpot` en rrmm-utils es cosmético; exit code 0). Actualizo el estado y paso a B.

Hecho A y C, con tests verdes en ambos repos. Ahora B, que es lo que querías contrastar con el funcional.

## Qué dice el funcional/documentación sobre actualizar la RL

El documento de entrega `MINERVA_RF_v6_Entrega_Babooni.md` es explícito en que **`rrmm-backend` debe LLAMAR a `puestos-back`**:

- §2.1 (tabla de repos): *"`puestos-back` … Babooni implementa aquí **el nuevo endpoint de actualización de RL**."*
- §4.1: *"`puestos-back` — Cambiar puesto de una relación laboral concreta → `POST /puestos/{rlId}/cambiar-puesto`"* con el flujo `puestoTrabajoBaja` → `puestoTrabajoAlta` → sincronizar adicionales.
- §4.2 (Orquestación RL): *"**rrmm-backend llama a puestos-back**: a. RL en destino ya existe → `POST /puestos/{rlId}/cambiar-puesto`; b. No existe → crear RL nueva."*

## Qué hace el código realmente

`rrmm-backend` **no llama a `puestos-back`**: `CambioPuestoRlExecutor` muta la RL **en local**, escribiendo directamente en `PPT_CEN_TRA` vía `CambioPuestoDao.puestoTrabajoBaja/Alta` (confirmado en logs `[cambio-puesto] dao puestoTrabajoBaja/Alta`). Es la **misma lógica** que el §4.1, pero reimplementada dentro de `rrmm-backend`.

## Lectura

- **Técnicamente**, mutar la RL en local dentro de la transacción de `CONFIRMAR` es coherente con lo que ya decidimos en BE-07 con `INF_RM`: garantiza atomicidad y evita el lock distribuido entre servicios que ya sufrimos. Funciona y los logs lo confirman.
- **Pero contradice el diseño entregado a Preving** (BE-08) y rompe la "propiedad" de la tabla: `PPT_CEN_TRA` es de `puestos-back` y la estaríamos escribiendo desde dos servicios.

Por eso no lo borro por mi cuenta: es una decisión de arquitectura/propiedad de datos que conviene cerrar (idealmente validándola con Preving/Felix), no solo dead code.

> **Dado que el funcional (BE-08) dice 'rrmm-backend llama a puestos-back' pero el código muta la RL en local (PPT_CEN_TRA), ¿qué hacemos con el camino remoto sin usar?**
> - Mantenerlo (no borrar) y marcarlo como punto a validar con Preving/Felix: confirmar si la mutación local es aceptable o hay que volver al diseño BE-08 (Recomendado)
> - Borrar ya el camino remoto en ambos repos (asumimos que la mutación local es la decisión final) y actualizar el doc de entrega
> - Reconectar rrmm-backend para llamar al endpoint de puestos-back (volver al diseño BE-08; cambio mayor y reintroduce el lock distribuido)

Entendido, lo dejo como recomendaba por defecto: **no borro el camino remoto**; queda intacto y anotado como punto a validar con Preving/Felix (decidir si la mutación local de RL es definitiva o hay que volver al diseño BE-08). No toco `PuestosBackClient.cambiarPuestoRl`, ni los DTOs `CambiarPuestoRl*`, ni el endpoint de `puestos-back`.

## Resumen de la pasada de limpieza (previa al Javadoc)

**Borrado (dead code real, tests verdes en ambos repos):**
- `rrmm-backend`: eliminado `PuestosBackClient.simularImpactoRm` (interfaz + impl + imports muertos) y el overload `resolver(int, CambioPuestoRequest, String)` de `CambioPuestoImpactoPropuestoResolver`; ajustado `RrmmUtilsImpactoPropuestoResolverTest`.
- `rrmm-backend` (campos internos): quitados `CambioPuestoRmUpdate.{rmCfAnioId, mtValida, mcId}` y sus columnas del `UPDATE` (la preservación de `MC_ID/MT_VALIDA` ahora es por omisión); test reescrito.
- `rrmm-utils`: eliminado `PruebaRealizada.codigoPrueba` (campo, JOIN y columna del SELECT, RowMapper, constructor, 2 tests) y corregido el Javadoc de `AplicarProtocolosResponse.pruebasRealizadasPreservadas` (son IDs, no códigos).

**Conservado a propósito (afecta contrato HTTP entre repos):** `PuestoAdicionalItem.nombre`, `AplicarProtocolosBackResponse.{rmId, ipromesInsertados, productosQuimicosInsertados}`, `ItemConfiguracionBackDto.protocoloId`, `PeriodicidadBackDto.{id, totalMeses}`, `CambiarPuestoRlRequest.clienteId`.

**Pendiente de decisión (B):** el camino "cambiar RL vía puestos-back" se mantiene intacto; hay que validar con Preving/Felix si la mutación local de `PPT_CEN_TRA` es definitiva o se vuelve al diseño BE-08.

Con el código ya depurado, podemos pasar al **Javadoc**. Como dijiste "sobre todo los contratos de las interfaces", propongo empezar por ahí (es lo más valioso y de alcance acotado):

**Interfaces a documentar (tipo + cada método):**
- `rrmm-backend`: `CambioPuestoService`, `CambioPuestoDao`, `CambioPuestoLogDao`, `CambioPuestoImpactoReader`, `PuestosBackClient`, `RrmmUtilsClient`, `CambioPuestoImpactoPropuestoResolver` (+ método `obtenerLogsCambioPuesto` de `LogService`).
- `puestos-back`: `CambioRmCatalogoDao`.
- `rrmm-utils`: ya están bien (`ReconciliacionProtocolosDao` 6/6, `AplicarProtocolosReconocimientoService` 1/1); solo retoques menores de `@param/@return`.

¿Arranco con las interfaces (contratos) y luego, si quieres, extiendo el Javadoc de tipo a impls/controllers/DTOs? ¿O prefieres que incluya ya el Javadoc de tipo en esas clases en la misma pasada?

---

**User**

respondi a tu pregunta porque no haces nada

---

**Cursor**

Tienes razón, dejo de preguntar y ejecuto. Empiezo por los contratos (interfaces), que es lo que pediste priorizar, y añado Javadoc de tipo a nuestras clases. Voy repo por repo. Primero leo los contratos de `rrmm-backend`.

---

**User**

me refiero a esta pregunta

---

**Cursor**

Te refieres a la decisión sobre la RL. Tu intuición (llevarlo a `puestos-back` por buenas prácticas y porque la RL pertenece a su contexto) es razonable y encaja con el funcional. Pero tu pregunta clave es muy buena: **¿evitaríamos el error de antes?** Déjame verificarlo mirando exactamente qué toca `puestos-back` al cambiar la RL, porque la respuesta depende de si accede o no a `INF_RM`.

Verificado. `puestos-back.cambiarPuestoRl` (en `PuestoManager`, líneas 587-627) solo toca `PPT_CEN_TRA` y `PPT_CEN_TRA_ADICIONAL` (vía `getRlPrincipalActivaById` + `puestoTrabajoBaja/Alta`). **No lee ni escribe `INF_RM`.**

## Respuesta a tu pregunta: ¿evitaríamos el error de antes?

**Sí, ese error en concreto no se reproduce.** El bloqueo de antes era un deadlock `INF_RM ↔ INF_RM`: `rrmm-backend` tenía `INF_RM` bloqueada dentro de la transacción de CONFIRMAR mientras llamaba a `rrmm-utils`, que a su vez intentaba `UPDATE INF_RM` → se quedaban esperándose. Como la RL vive en `PPT_CEN_TRA` (tabla distinta) y `puestos-back` no toca `INF_RM`, **no hay colisión de locks** aunque la transacción de CONFIRMAR siga abierta.

## El verdadero trade-off: atomicidad

El precio de llevarlo a `puestos-back` no es el lock, es la **atomicidad transaccional**:

- **Local (lo que hay hoy):** todo en una sola transacción de `rrmm-backend`. Si algo falla, *todo* hace rollback. Cumple a rajatabla el CA "no aplicar cambios parciales". Pero escribe `PPT_CEN_TRA`, que es de `puestos-back` (rompe la propiedad del dato y contradice BE-08).
- **Remoto (BE-08, lo que indica el doc):** `puestos-back` confirma la RL en *su propia* transacción. Si luego falla un paso posterior de CONFIRMAR (INF3, log…), **la RL ya está commiteada y no revierte** → riesgo de cambio parcial. Respeta la propiedad del dato y las buenas prácticas, que es justo tu argumento.

## Cómo mitigarlo si vamos por BE-08

Llamar a `puestos-back` como **último paso** de CONFIRMAR, cuando todo lo demás (validaciones, `INF_RM`, materialización `INF3`, periodicidad) ya ha ido bien. Así la ventana de "RL aplicada pero el resto falla" es mínima. Para cierre total habría que añadir compensación (saga), pero como primer paso pragmático, ordenar la RL al final cubre el 99%.

## Mi recomendación

Tu instinto es correcto: por **propiedad del dato + buenas prácticas + alineación con el funcional (BE-08)**, lo suyo es delegar en `puestos-back`, y el deadlock anterior **no** vuelve. El único punto a aceptar conscientemente es la atomicidad (mitigable ordenando la RL al final).

Es un cambio mayor: reconectar `CambioPuestoRlExecutor`/`confirmar` para usar `PuestosBackClient.cambiarPuestoRl` (que ya existe y dejamos sin borrar), mapear DTOs, mover la llamada al final del flujo, y ajustar tests. Antes de meterme con ello, confírmame el enfoque.

> **¿Implemento la reconexión de la RL a puestos-back (diseño BE-08)?**
> - Sí: delegar la RL en puestos-back vía PuestosBackClient.cambiarPuestoRl, llamándolo como último paso de CONFIRMAR para minimizar el riesgo de cambio parcial (Recomendado) ✔
> - Sí, pero además quiero compensación/rollback explícito si falla un paso posterior (saga completa)
> - No: mantener la mutación local actual (atomicidad total) y dejar BE-08 documentado como excepción acordada
> - Esperar: lo valido con Preving/Felix antes de tocar nada

Hecho. Implemento la reconexión: la RL pasará a delegarse en `puestos-back` como último paso de CONFIRMAR. Primero necesito entender el flujo actual completo (executor local, orquestador, contrato remoto y endpoint de puestos-back).

El executor local hace baja+alta+adicionales, pero también una validación (`validarOkTecnico`) y un `clienteOverride` que el endpoint de `puestos-back` quizá no soporta. Leo el lado de `puestos-back` y los DTOs/flujo de `confirmar()` para alinear el contrato.

Esto es clave: el endpoint de `puestos-back` (`cambiarPuestoRl`, líneas 585-621) está **incompleto** frente al executor local. Le faltan: sincronizar adicionales, el `clienteOverride` para CREAR cross-cliente, el escenario SOLO_ADICIONALES y la acción ASOCIADA. Para reconectar fielmente hay que completarlo. Leo el `confirmar()` para ver cómo se usa el resultado de la RL antes de diseñar el cambio.

Necesito ver el cuerpo principal de `confirmar()` y dónde se invoca el executor.

Ahora tengo el flujo completo. La reconexión implica **migrar a `puestos-back` la lógica RL que hoy vive en `rrmm-backend`** (alta con override de cliente, sincronización de adicionales y el caso SOLO_ADICIONALES), porque el endpoint actual es un stub parcial. Para portarlo fielmente, leo las implementaciones SQL de ambos lados.

Esto requiere portar lógica SQL no trivial a `puestos-back`. Leo el resto del DAO de referencia (`rrmm-backend`) y el DAO actual de `puestos-back` para portarlo fielmente y sin tocar lo que ya usa `moverTrabajadores`.

`puestos-back` ya tiene un `puestoTrabajoAlta` robusto. Leo su implementación completa para decidir qué falta (override de cliente y sync de adicionales).

Ya tengo el panorama completo y, siendo honesto, esto es más grande que un simple "rewire". Te lo resumo antes de tocar producción, porque cambia el contrato y migra SQL de escritura a `puestos-back`.

## Lo que he descubierto

El endpoint `cambiarPuestoRl` de `puestos-back` es un **stub parcial**: hace baja+alta del principal y valida OK técnico, pero **le falta** lo que sí hace hoy el executor local de `rrmm-backend`:
- **Override de cliente** en el alta (caso CREAR cuando cambia el cliente).
- **Sincronización de puestos adicionales** (`PPT_CEN_TRA_ADICIONAL`).
- **Escenario SOLO_ADICIONALES** (editar solo adicionales, sin baja/alta del principal).

Además, `puestos-back` no tiene un `insertPuestoAdicionalRl` equivalente (el suyo copia una fila existente; el de `rrmm-backend` inserta desde `DUAL` con `NOT EXISTS`).

## Plan para hacerlo bien (aditivo, sin romper `moverTrabajadores`)

**En `puestos-back`** (portando el SQL ya probado de `rrmm-backend`):
1. Ampliar `CambiarPuestoRlRequest`: añadir `soloAdicionales` + lista de adicionales.
2. Portar a su `PuestoDao(Impl)`: alta de principal **con override de cliente**, `getPuestosAdicionalesActivos`, `insertPuestoAdicionalRl` (DUAL/NOT EXISTS) y `syncPuestosAdicionalesRl`.
3. Reescribir `PuestoManager.cambiarPuestoRl` para cubrir SOLO_ADICIONALES / EDITAR / CREAR / ASOCIAR.

**En `rrmm-backend`:**
4. `CambioPuestoRlExecutor`: dejar de escribir en `PPT_CEN_TRA`; mantener solo la lectura de la RL y `validarOkTecnico` (para conservar el error 422 correcto), y delegar la mutación en `PuestosBackClient.cambiarPuestoRl`.
5. `confirmar()`: mover la mutación de RL **al final** (tras `INF_RM`/`INF3`), para minimizar el cambio parcial.
6. Ajustar DTOs `CambiarPuestoRlBack*`, tests del executor y del service.

## Riesgos que asumimos
- **`puestos-back` no tiene tests** de este flujo y migramos SQL de escritura real sobre `PPT_CEN_TRA`/`_ADICIONAL`. Lo dejo aditivo y compilando, pero el riesgo de regresión solo se cierra con prueba en entorno.
- La RL se confirma en su propia transacción (consistencia eventual; ya acordado).

Es bastante código en los dos repos. Antes de meterle mano a `puestos-back`, ¿te encaja este plan tal cual o prefieres ajustarlo?

---

**User**

me encaja el plan, ves con maxima cautela, buenas practicas, clean code y robustez

---

**Cursor**

Perfecto. Voy con máxima cautela, aditivo y limpio. Empiezo por `puestos-back`. Necesito ver las cabeceras del DAO (secuencias, `namedTemplate`), el interface `PuestoDao`, el controller y el `PuestoManager` para encajar todo con su estilo.

Reutilizaré `getPuestosAdicionales(rlId)` que ya existe. Veo el interface `PuestoDao`, el controller y el `PuestoManager` (cabecera + firmas) para encajar las nuevas piezas.

Tengo todo lo necesario. `puestos-back` ya tiene `getPuestosAdicionales(rlId)`, secuencias y validación OK técnico. Empiezo creando el DTO de adicionales y ampliando el request.

DTOs listos. Ahora porto la lógica SQL desde `rrmm-backend`. Leo las implementaciones de referencia (`altaPuestoPrincipalCopiado`, `insertPuestoAdicionalRl`) para portarlas con fidelidad.

Tengo la referencia. Para garantizar paridad exacta con el código probado, replico el patrón `nextSequenceValue` vía SQL. Añado las firmas al interface `PuestoDao`.

Ahora la implementación. Veo el `puestoTrabajoAlta` existente para colocar los métodos nuevos cerca y con su estilo.

Perfecto, los beans de secuencia ya apuntan a esas tablas. Inserto los dos métodos nuevos tras `puestoTrabajoAlta`, usando las secuencias de `puestos-back`.

Ahora reescribo `PuestoManager.cambiarPuestoRl`. Leo la implementación actual completa y sus helpers.

`domain.*` ya está importado. Reescribo `cambiarPuestoRl` con escenarios SOLO_ADICIONALES/EDITAR/CREAR y sincronización de adicionales, con trazas.

Verifico linter en los archivos de `puestos-back` y compilo.

Solo warnings preexistentes, ningún error. Compilo `puestos-back`.

`puestos-back` compila correctamente. Ahora `rrmm-backend`. Actualizo todos y reviso el contrato cliente y el executor actuales.

Necesito el contrato cliente y el executor de `rrmm-backend`. Leo el cliente, los DTOs back y el executor.

Veo el `confirmar()` y cómo se usa `ejecutar(...)` y `rlMutation`. También el plan RL (`CambioPuestoRlResult`) y el request de adicionales.

Entendido el flujo completo. Creo el DTO de adicional para el contrato back y amplío el request.

Confirmo los getters de `PuestoAdicionalItem` y leo el orchestrator (`CambioPuestoRlResult`) para asegurar el mapeo.

Ahora reescribo el executor para delegar en `PuestosBackClient` (lectura + validación local temprana, sin escribir en `PPT_CEN_TRA`).

Verifico el valor de `PUESTO_ESTANDAR` en `RmCodes` para no cambiar la semántica.

`PUESTO_ESTANDAR = 1`, semántica preservada. Ahora reordeno `confirmar()` para que la mutación RL sea el último paso y propago el token.

Verifico `extractJwtToken` para asegurar que sirve fuera de `aplicarConfiguracionProtocolos`.

`extractJwtToken` valida y ya se invoca antes en `confirmar()`, así que el token está garantizado. Reviso los tests del executor y del service.

Ajusto el branch SOLO_ADICIONALES del executor para conservar la acción "EDITADA" explícita (igual que antes), independiente del plan.

Ahora reescribo el test del executor para el nuevo contrato delegado.

Ahora reviso los usos de `ejecutar(` en el test del service para añadir el parámetro token.

Actualizo los 4 stubs del service test al nuevo `ejecutar` con token. Verifico imports de matchers.

`anyString` no está importado. Lo añado y actualizo los 4 stubs.

Reviso linter de los archivos modificados en `rrmm-backend` antes de compilar.

Sin errores de linter. Compilo `rrmm-backend` y ejecuto los tests de cambio de puesto.

Tests verdes en `rrmm-backend` (compilación completa + suite cambio-puesto OK). Actualizo el estado.

Migración RL completada. Resumen de lo implementado con máxima cautela (todo aditivo, compilando y con tests verdes en ambos proyectos):

## puestos-back (ahora hace la escritura de `PPT_CEN_TRA`)
- **`CambiarPuestoRlRequest`**: ampliado con `soloAdicionales` y `List<CambiarPuestoRlAdicional> puestosAdicionales`. Nuevo DTO `CambiarPuestoRlAdicional` (`puestoId` + `estandar`).
- **`PuestoDao(Impl)`**: portados desde `rrmm-backend` con fidelidad:
  - `puestoTrabajoAltaPrincipal(...)` — alta del principal copiando la RL origen, con override opcional de `COD_CLI` (usa la secuencia existente `puestosTrabajoSeq`).
  - `insertPuestoAdicionalRl(...)` — alta idempotente en `PPT_CEN_TRA_ADICIONAL` (patrón `DUAL` + `NOT EXISTS`).
  - Reutilizo el ya existente `getPuestosAdicionales(rlId)` para la sincronización.
- **`PuestoManager.cambiarPuestoRl`**: reescrito con escenarios `SOLO_ADICIONALES` / `EDITAR` / `CREAR`, validación OK técnico extraída a `validarPuestoSinOkTecnico`, y `sincronizarPuestosAdicionales` (baja activos + alta solicitados). Con trazas.

## rrmm-backend (delega, ya no escribe `PPT_CEN_TRA`)
- **`CambiarPuestoRlBackRequest`**: ampliado igual (+ nuevo DTO `CambiarPuestoRlBackAdicional`). El cliente HTTP ya existía.
- **`CambioPuestoRlExecutor`**: ahora inyecta `PuestosBackClient`. Mantiene **lectura + validación OK técnico en local** (aborta pronto sin round-trip) pero **delega la escritura** en `puestos-back`. La acción (`EDITAR/CREAR/ASOCIAR`) la sigue dictando el plan local (autoritativo).
- **`CambioPuestoServiceImpl.confirmar()`**: la mutación RL pasa a ser el **último paso** (tras `actualizarInfRm`, `replacePuestosAdicionalesRm` y `aplicarConfiguracionProtocolos`), con el token JWT propagado. Documentado el trade-off de atomicidad.
- **Tests**: actualizados `CambioPuestoRlExecutorTest` (mock del cliente, captura del request enviado, validación previa a la llamada) y los 5 stubs de `CambioPuestoServiceImplTest`.

Una consideración antes de seguir con el Javadoc (`r6`):

Tras esta migración, en `rrmm-backend` quedan **métodos de mutación RL local que ya nadie usa** (`puestoTrabajoAlta`, `puestoTrabajoBaja`, `syncPuestosAdicionalesRl`, `getPuestosAdicionalesActivos`, `insertPuestoAdicionalRl`, `altaPuestoPrincipalCopiado`, `altaPuestoAdicionalCopiado`, `nextSequenceValue` en `CambioPuestoDaoImpl`), junto con sus tests en `CambioPuestoDaoImplTest`. Son código muerto y, además, escriben sobre `PPT_CEN_TRA` (tabla que ya no debemos mutar desde aquí).

¿Cómo quieres que proceda?

> **Métodos de mutación RL local ahora muertos en rrmm-backend (CambioPuestoDaoImpl + sus tests). ¿Qué hago?**
> - Eliminarlos ahora (DAO + interface + tests), con cautela (Recomendado) ✔
> - Dejarlos por ahora y seguir con el Javadoc (r6)
> - Mantenerlos definitivamente como fallback

Voy a eliminarlos con cautela. Primero verifico que ninguno se use fuera del DAO impl y sus tests (producción).

Confirmado: solo se usan en el propio DAO, su interface y un `verify(...never())` del test del executor (que ya no aplica). Leo las regiones exactas del DAO impl y su interface para recortar limpio.

Procedo a eliminar el código muerto. Quito los 4 métodos públicos de mutación (`puestoTrabajoBaja`, `puestoTrabajoAlta`, `getPuestosAdicionalesActivos`, `insertPuestoAdicionalRl`) conservando `getPuestosAdicionalesRmByRmId`.

Ahora elimino `syncPuestosAdicionalesRl`, `altaPuestoPrincipalCopiado`, `altaPuestoAdicionalCopiado` y `nextSequenceValue`.

Ahora limpio las firmas del interface `CambioPuestoDao`.

Quito el `verify(...never()).puestoTrabajoBaja(...)` del test del executor, que referencia un método ya eliminado.

Ahora reviso `CambioPuestoDaoImplTest` para quitar las pruebas de los métodos eliminados.

`CambioPuestoDaoImplTest` no referencia esos métodos. Verifico imports que pudieran quedar sin uso (`Date`, `SimpleDateFormat`) en el DAO impl.

Esos imports quedan sin uso. Los elimino.

Verifico linter y recompilo/testeo `rrmm-backend`.

Migración y limpieza completadas. Ambos proyectos compilan y la suite de cambio-puesto pasa en verde.

## Limpieza de código muerto (rrmm-backend)
Eliminado todo el camino de mutación RL local que ya nadie usaba y que escribía sobre `PPT_CEN_TRA` (tabla que ahora gestiona `puestos-back`):
- `CambioPuestoDaoImpl`: `puestoTrabajoBaja`, `puestoTrabajoAlta`, `getPuestosAdicionalesActivos`, `insertPuestoAdicionalRl`, `syncPuestosAdicionalesRl`, y los privados `altaPuestoPrincipalCopiado`, `altaPuestoAdicionalCopiado`, `nextSequenceValue`.
- `CambioPuestoDao`: firmas correspondientes.
- Imports huérfanos (`Date`, `SimpleDateFormat`) y un `verify(...never())` obsoleto en el test del executor.
- Se conservan `getRlPrincipalActivaById` y `tieneClientePtContratada` (siguen usándose para lectura/validación local).

Verifiqué por búsqueda que esos métodos no se referenciaban en ningún otro punto de producción ni de tests. `CambioPuestoDaoImplTest` no los probaba.

## Estado del flujo resultante
`confirmar()` queda así: validaciones → plan RL → deltas/log de protocolos → `actualizarInfRm` → `replacePuestosAdicionalesRm` → `aplicarConfiguracionProtocolos` (INF3_*) → **mutación RL remota en `puestos-back` (último paso)** → log + respuesta. La validación OK técnico se mantiene local para abortar pronto sin round-trip.

Nota de robustez (ya conversada): al delegar la RL, deja de ser atómica con el resto de `CONFIRMAR`; por eso va al final, y el applier de protocolos es idempotente para que reintentar sea seguro. Queda una ventana residual mínima (RL remota OK + fallo local posterior al insertar el log) inherente a cualquier escritura dual; lo dejé documentado en el código.

Queda pendiente la tarea `r6` (Javadoc de contratos/interfaces y tipos creados en los 3 proyectos). ¿Arranco con ese repaso de Javadoc o prefieres validar antes el flujo en local con esta nueva arquitectura?

---

**User**

y sobre esto que decir, al final hemos sido nosotros quienes hemos creado el dry run verdad? donde lo hemos creado? la verdad es que pensando un poco, el proceso de alta de reconocimientos esta en rrmm-utils, siguiendo de nuevo el contexto, creo que esta bien donde lo hemos creado

---

**Cursor**

Buena pregunta. Déjame localizar exactamente dónde quedó el dry-run para responderte con precisión y no de memoria.

Voy a confirmar el endpoint y el flujo exacto del dry-run en `rrmm-utils` y cómo lo consume `rrmm-backend`.

Confirmado, y tu intuición es correcta. El dry-run lo creamos **nosotros**, y está en **`rrmm-utils`**, no en `puestos-back`.

## Dónde está exactamente
En `rrmm-utils`:
- **Endpoint**: `POST rrmm/protocolos/recalcular` en `ProtocolosReconocimientoController.recalcularConfiguracionProtocolos`

```44:52:c:\Repository\rrmm-utils\src\main\java\com\preving\restapi\rrmmutils\web\ProtocolosReconocimientoController.java
    @PostMapping(value = "/recalcular", consumes = MediaType.APPLICATION_JSON_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<ConfiguracionProtocolosPorPuesto> recalcularConfiguracionProtocolos(
            @RequestBody @Valid RecalcularProtocolosRequest req,
            HttpServletRequest request) {
        ConfiguracionProtocolosPorPuesto resultado =
                configuracionProtocolosService.recalcularConfiguracionProtocolos(req, request);
        return ResponseEntity.ok(resultado);
    }
```

- **Servicio**: `ConfiguracionProtocolosReconocimientoServiceImpl.recalcularConfiguracionProtocolos` — y fíjate que vive en el paquete `service/reconocimiento/**alta**/`, es decir, **reutiliza el mismo motor que la creación del RM** (protocolos por puesto + ACP contrato/centro/puesto/trabajador + periodicidad resultante), pero en modo solo-lectura, sin materializar `INF3_RM_*`.
- **Request/DTO**: `RecalcularProtocolosRequest` / `ConfiguracionProtocolosPorPuesto`.

Y en `rrmm-backend` lo consumimos desde `RrmmUtilsClient.recalcularConfiguracionProtocolos` (para el SIMULAR / preview de impacto del cambio de puesto).

## Por qué está bien ahí
La imagen es de la **estimación inicial**, donde se asumía que el motor de recálculo lo entregaría Preving como endpoint en `puestos-back`. Pero el motor de alta de reconocimientos (la lógica de "protocolos por puesto + ACP + periodicidad") vive en `rrmm-utils`. Ponerlo en `puestos-back` habría obligado a **duplicar** esa lógica o a que `puestos-back` invadiera el dominio de vigilancia de la salud.

Al implementarlo en `rrmm-utils` conseguimos:
- **Reutilizar** el motor de alta existente (una sola fuente de verdad → dry-run y materialización dan exactamente lo mismo).
- Respetar la **propiedad del dominio**: el cálculo de protocolos/ACP es de vigilancia de la salud (`vig_salud`), territorio de `rrmm-utils`.
- Coherencia con la arquitectura que ya montamos: el `recalcular` (dry-run) y el `aplicar` (BE-07) son los dos endpoints hermanos del mismo controller `rrmm/protocolos`.

Así que sí: está donde debe estar. Lo único desactualizado es **ese texto de la estimación** (sigue diciendo "Endpoint en puestos-back pendiente de pruebas / Preving lo entregará"). Si quieres, te lo actualizo en el doc para reflejar que ya está entregado y ubicado en `rrmm-utils`.

---

**User**

vale estoy revisando y no veo que hayas eliminado el ultimo codigo muerto analizado, podrias comprobar por favor

---

**Cursor**

Voy a comprobarlo. Reviso el archivo que tienes abierto y busco qué quedó identificado como muerto. Primero leo el DAO de reconciliación y su interfaz.

Este archivo está todo en uso. El "último código muerto analizado" debe ser otra cosa. Voy a revisar el transcript para recuperar qué se identificó como muerto y no se eliminó.

Encontré el resumen de la pasada de limpieza (línea 479). Lo leo completo para ver qué quedó identificado pero no borrado.

Veo el resumen, pero quiero el inventario completo del análisis original para no dejarme nada. Reviso las menciones anteriores (líneas 265, 272, 305).

Confirmo primero que la limpieza del RL realmente persistió, y reviso el inventario detallado del análisis original (línea 438) por si quedó algún ítem sin accionar.

La limpieza del RL sí persistió (cero referencias). Hago un escaneo real de uso en el paquete `cambiopuesto` para detectar lo que pueda haber quedado muerto, empezando por sospechosos.

El script tuvo ruido, pero `CambioPuestoSimularMockProvider` solo tiene 1 referencia externa: sospechoso. Lo verifico.

`SimularMockProvider` se usa (toggle de simulación). Voy a verificar que TODO lo que se reportó como borrado en la pasada previa al Javadoc realmente desapareció. Compruebo los 4 ítems.

Todo lo reportado como borrado está efectivamente fuera. Déjame verificar el uso real de los métodos de este DAO de reconciliación (el archivo que tienes abierto), por si alguno quedó sin consumidor tras los cambios de CA-14.

Todos los métodos de reconciliación están en uso. Reviso el `simular()` y el uso del mock provider, que es el único punto reachable que podría ser andamiaje sobrante.

`simularMockEnabled` es un flag intencional. Verifico algo importante: tras mi cambio en `puestos-back`, el antiguo `puestoTrabajoAlta` podría haber quedado sin uso si solo lo llamaba `cambiarPuestoRl`.

He comprobado a fondo y quiero darte evidencia concreta, porque lo que se reportó como eliminado **sí está fuera del código**. Esto es lo que verifiqué (búsqueda en los 3 repos):

## Confirmado eliminado (0 referencias en producción)
- **Mutación RL local en `rrmm-backend`** (`CambioPuestoDaoImpl` + interfaz): `puestoTrabajoBaja`, `puestoTrabajoAlta`, `getPuestosAdicionalesActivos`, `insertPuestoAdicionalRl`, `syncPuestosAdicionalesRl`, `altaPuestoPrincipalCopiado`, `altaPuestoAdicionalCopiado`, `nextSequenceValue` → **0 coincidencias**.
- Pasada previa (grupo A): `simularImpactoRm`, el overload de 3 args de `resolver`, los campos `CambioPuestoRmUpdate.{rmCfAnioId, mtValida, mcId}` y `PruebaRealizada.codigoPrueba` → **0 coincidencias** (las apariciones de `codigoPrueba`/`mcId`/`rmCfAnioId` que quedan son de otras clases distintas: `PruebaBBDD`, `LogReaperturaDefinition`, `Reconocimiento`, `Sanitario…`, no del cambio de puesto).

## El archivo que tienes abierto está 100% en uso
`ReconciliacionProtocolosDaoImpl` (rrmm-utils): sus 6 métodos (`limpiarConfiguracionInf3`, `getPruebasRealizadasByRmId`, `getPruebaIdsConfigurados`, `reinsertarPruebaConservada`, `repararProtocolosHuerfanos`, `contarConfiguracionInf3`) se invocan todos desde `AplicarProtocolosReconocimientoServiceImpl`. No hay nada muerto ahí.

## Lo único "analizado pero NO eliminado" (a propósito)
En la pasada previa al Javadoc dejé conscientemente este grupo sin tocar, **porque forma parte del contrato HTTP entre repos** (borrarlos cambia el JSON que se serializa entre servicios):
- `PuestoAdicionalItem.nombre`
- `AplicarProtocolosBackResponse.{rmId, ipromesInsertados, productosQuimicosInsertados}`
- `ItemConfiguracionBackDto.protocoloId`
- `PeriodicidadBackDto.{id, totalMeses}`
- `CambiarPuestoRlRequest.clienteId` → **ojo: este ya NO es dead code**; tras la migración RL, `puestos-back` lo lee para calcular el `clienteOverride`.

Para no borrar algo que en realidad se use por reflexión/serialización, dime cuál es el que ves: ¿te refieres a alguno de esa lista de "conservados", o estás viendo un método/clase concreto que no aparece en mi verificación?

> **¿A qué código muerto te refieres para que lo elimine?**
> - Los campos 'conservados a propósito' (PuestoAdicionalItem.nombre, AplicarProtocolosBackResponse.*, ItemConfiguracionBackDto.protocoloId, PeriodicidadBackDto.*)
> - Otro método/clase concreto (te indico cuál y dónde)
> - Está en el archivo que tengo abierto / en uno concreto: lo señalo

Entendido, continúo con criterio. Antes de tocar nada, verifico cuáles de esos campos "conservados" están realmente sin leer en ningún punto (para borrar solo los 100% muertos y de forma segura).

Como confirmaste que continúe, verifico el alcance completo (todo `rrmm-backend`, no solo el paquete) de esos campos antes de decidir, para borrar solo lo que esté 100% sin leer y sea seguro.

He terminado la comprobación a fondo. Te confirmo el estado real con evidencia:

**Lo aprobado para borrar está borrado** (0 referencias): la mutación RL local (`puestoTrabajoBaja/Alta`, `syncPuestosAdicionalesRl`, `getPuestosAdicionalesActivos`, `insertPuestoAdicionalRl`, `altaPuestoPrincipalCopiado/AdicionalCopiado`, `nextSequenceValue`), más lo de la pasada previa (`simularImpactoRm`, overload de `resolver`, campos de `CambioPuestoRmUpdate`, `PruebaRealizada.codigoPrueba`).

**El único "analizado pero NO eliminado"** es el grupo que en su día conservé *por contrato HTTP*. Acabo de verificar campo por campo en todo `rrmm-backend` y, salvo `nombre`, **ninguno se lee en producción**:

| Campo | ¿Se lee? | Seguro de borrar |
|---|---|---|
| `AplicarProtocolosBackResponse.rmId` | no | sí (DTO de respuesta, Jackson ignora props ausentes) |
| `AplicarProtocolosBackResponse.ipromesInsertados` | no | sí |
| `AplicarProtocolosBackResponse.productosQuimicosInsertados` | no | sí |
| `ItemConfiguracionBackDto.protocoloId` | solo lo set-ea 1 test | sí (ajusto el test) |
| `PeriodicidadBackDto.id` / `totalMeses` | no | sí |
| `PuestoAdicionalItem.nombre` | **sí** (chips del modal, contrato con el front) | **no — lo dejo** |

Son DTOs de integración que creamos nosotros en BE-07; quitar campos de un DTO de *respuesta* es seguro (no rompe la deserialización). Pero como tocan el contrato documentado entre servicios y tu regla es no modificar sin preguntar, no los borro a ciegas.

¿Te refieres a estos? Si me dices que sí, los elimino todos (menos `PuestoAdicionalItem.nombre`), ajusto el test de `protocoloId`, compilo y paso tests. Si era otro punto concreto, señálame el fichero/línea y voy directo.

---

**User**

no esos lo dejamos, ahora haz lo del javadoc

---

**Cursor**

Perfecto, dejo esos campos. Arranco con el Javadoc, priorizando los **contratos (interfaces)** como acordamos. Primero leo las interfaces que faltan por documentar para ver su estado actual.

Leo las restantes (DAO log, PuestosBackClient, CambioPuestoDao actual) y localizo `obtenerLogsCambioPuesto`.

Leo el `CambioPuestoDao` actualizado y el contexto de `LogService` para documentar con precisión.

Tengo todo el material de `rrmm-backend`. Empiezo a documentar. `CambioPuestoService` (tipo + cada método):

`CambioPuestoImpactoReader` y `CambioPuestoImpactoPropuestoResolver`:

Ahora `CambioPuestoLogDao` y `PuestosBackClient`:

`CambioPuestoDao` — añado Javadoc de tipo y completo los métodos sin documentar:

Y el método `obtenerLogsCambioPuesto` en `LogService`:

rrmm-backend interfaces listas. Ahora puestos-back: localizo y documento `CambioRmCatalogoDao`.

Reviso si `PuestoService.cambiarPuestoRl` (contrato que creamos) tiene Javadoc.

Actualizo el Javadoc de `cambiarPuestoRl` para reflejar el comportamiento nuevo (escenarios + adicionales + override + validación):

Ahora rrmm-utils: reviso las interfaces de servicio/DAO que creamos para retoques de `@param/@return`.

Las interfaces de rrmm-utils están bien redactadas; solo les faltan algunos `@param/@return`. Los completo en `ReconciliacionProtocolosDao`.

Y completo los `@param/@return` de los métodos dry-run que añadimos en `ConfiguracionProtocolosReconocimientoService`:

Marco progreso y verifico lints en los archivos editados.

Sin errores de lint. Ahora compilo los 3 proyectos (solo `compileJava`, ya que Javadoc no afecta al bytecode pero quiero validar que no rompí nada).

Los tres proyectos compilan correctamente (`EXIT=0` en los tres; los "Note: deprecated API" son avisos preexistentes ajenos al Javadoc).

Listo. He documentado los **contratos (interfaces)** de la funcionalidad de cambio de puesto en los tres proyectos y validado que todo compila.

## Resumen de Javadoc añadido

**rrmm-backend**
- `CambioPuestoService` — Javadoc de tipo + todos los métodos (`buscarClientes`, `listarCentros`, `listarPuestos`, `simular`, `confirmar`, `replacePuestosAdicionalesRm`) con `@param`/`@return`.
- `CambioPuestoDao` — Javadoc de tipo (incluida la nota de la migración BE-08) + completados los métodos que estaban sin documentar (`findRlActivaId`, `centroTieneContratoPvs`, `updateInfRmCambioPuesto`, nombres, `getRlPrincipalActivaById`, `tieneClientePtContratada`, adicionales y los 5 `getImpacto*`).
- `CambioPuestoLogDao`, `PuestosBackClient`, `RrmmUtilsClient`, `CambioPuestoImpactoReader`, `CambioPuestoImpactoPropuestoResolver` — tipo + métodos.
- `LogService.obtenerLogsCambioPuesto` — Javadoc del método.

**puestos-back**
- `CambioRmCatalogoDao` — tipo + los 5 métodos.
- `PuestoService.cambiarPuestoRl` — Javadoc actualizado para reflejar el comportamiento nuevo (escenarios solo-adicionales/cambio de principal, override de cliente, validación de OK técnico, `@throws`).

**rrmm-utils**
- `ReconciliacionProtocolosDao` y `ConfiguracionProtocolosReconocimientoService` — completados los `@param`/`@return` que faltaban (la prosa ya estaba bien).

## Verificación
- Sin errores de lint en los archivos editados.
- `compileJava` con `EXIT=0` en `rrmm-backend`, `puestos-back` y `rrmm-utils`.

Nota: solo toqué Javadoc (comentarios), no hay cambios funcionales. Quedan documentadas las interfaces creadas/modificadas en BE-08/cambio de puesto; las clases de implementación ya tenían su Javadoc previo. ¿Quieres que extienda el Javadoc también a las clases `*Impl` o a los DTOs del contrato HTTP, o lo dejamos en las interfaces?

---

**User**

extiende

---

**Cursor**

Entendido, extiendo el Javadoc a las clases `*Impl` y a los DTOs del contrato. Primero localizo el conjunto exacto de archivos de la funcionalidad para no dejarme ninguno.

Es un conjunto amplio (~75 archivos). Para mantener calidad y no duplicar lo ya documentado, voy leyendo por bloques y añado Javadoc donde falte. Empiezo por las clases `*Impl`/helpers de rrmm-backend para ver su estado actual.

Veo que `CambioPuestoRlExecutor` ya tiene Javadoc de clase, pero `CambioPuestoServiceImpl`, `PuestosBackClientImpl` y `RrmmUtilsClientImpl` no. Los añado.

Reviso los demás helpers/Impl de rrmm-backend para ver cuáles ya tienen Javadoc de clase.

Añado Javadoc de clase a `CambioPuestoDaoImpl`, `CambioPuestoLogDaoImpl` y `CambioPuestoImpactoReaderImpl`.

Reviso el resto de helpers de rrmm-backend.

`CambioPuestoRlOrchestrator` no tiene Javadoc. Lo añado y reviso los últimos (Trace, MockProvider, ResolveContext, RowMapper, Controller).

Añado Javadoc a `CambioPuestoImpactoItemRowMapper` y al `CambioPuestoController` (a nivel de clase).

Ahora los DTOs del contrato. Empiezo por los de rrmm-backend (los `*Back*` y los de `integration.rrmmutils`).

`CambiarPuestoRlBackResponse` y `CambioRmCatalogoBackResponse` no tienen Javadoc. Los documento.

Ahora los DTOs de `integration.rrmmutils`:

Estos ya tienen Javadoc de clase; completo los `@field` que faltan en los request/response.

Estos cuatro DTOs pequeños no tienen Javadoc. Los documento.

He cubierto los Impl/helpers y los DTOs del contrato cross-service de rrmm-backend. Ahora paso a puestos-back (Impl + DTOs del contrato) y rrmm-utils.

`CambiarPuestoRlResponse` y `CambioRmCatalogoResponse` necesitan Javadoc de clase.

Reviso el Javadoc de los métodos nuevos en `PuestoManager` (cambiarPuestoRl y helpers) y en `PuestoDaoImpl`.

puestos-back listo. Ahora rrmm-utils: `ReconciliacionProtocolosDaoImpl`, `AplicarProtocolosReconocimientoServiceImpl` y los DTOs `PruebaRealizada`/`ConteoConfiguracionInf3`.

Añado Javadoc de clase a los dos `*Impl` de rrmm-utils (los DTOs ya están documentados).

Reviso los DTOs del contrato de rrmm-utils (`AplicarProtocolosRequest/Response`, `RecalcularProtocolosRequest`) y el controller de protocolos.

Reviso el `ProtocolosReconocimientoController` de rrmm-utils.

Añado Javadoc de clase al `ProtocolosReconocimientoController`.

He cubierto Impl, controllers y DTOs cross-service. Para cerrar los **contratos públicos** de rrmm-backend, reviso los request/response del controller.

Estos tienen `@Schema` (OpenAPI) pero no Javadoc. Añado una línea de Javadoc de clase a cada uno por coherencia al leer el código.

Quedan DTOs internos del flujo. Reviso los más relevantes (update DAO, resultados RL, log, enums) para documentar los que falten.

He hecho una pasada amplia. Para no dejar DTOs internos del flujo sin revisar, listo el resto del paquete domain y verifico su estado.

Quedan los DTOs de impacto y catálogo. Los reviso.

Añado Javadoc de clase a los DTOs de deltas/catálogo que solo tienen `@Schema`.

He completado la documentación de Impl, controllers, enums y DTOs del flujo en los 3 proyectos. Compilo para verificar que nada se ha roto.

Los tres proyectos compilan (`EXIT=0`; los "Note: deprecated API" son avisos preexistentes ajenos al Javadoc).

Listo. He extendido el Javadoc a las clases `*Impl`, controllers y DTOs del flujo de cambio de puesto en los tres proyectos, y todo compila.

## Resumen de lo añadido

**rrmm-backend**
- Clases `*Impl`/orquestadores que no tenían Javadoc de clase: `CambioPuestoServiceImpl`, `PuestosBackClientImpl`, `RrmmUtilsClientImpl`, `CambioPuestoDaoImpl`, `CambioPuestoLogDaoImpl`, `CambioPuestoImpactoReaderImpl`, `CambioPuestoRlOrchestrator`, `CambioPuestoImpactoItemRowMapper`.
- `CambioPuestoController` (Javadoc de clase; los endpoints ya tenían `@Operation` de Swagger).
- DTOs del contrato cross-service: `CambiarPuestoRlBackResponse`, `CambioRmCatalogoBackResponse`, y los de `integration.rrmmutils` (`ConfiguracionProtocolosBackResponse`, `AplicarProtocolosBackRequest`, `RecalcularProtocolosBackRequest`, `PeriodicidadBackDto`, `ItemConfiguracionBackDto`, `ProtocoloBackDto`, `PuestoAdicionalBackDto`).
- DTOs públicos del controller: `CambioPuestoRequest`, `CambioPuestoSimularResponse`, `CambioPuestoConfirmarResponse`, `CambioPuestoPuestosResponse`.
- DTOs internos/enums: `CambioPuestoRmUpdate`, `CambioPuestoRlResult`, `CambioPuestoRlMutationResult`, `CambioPuestoLog`, `CambioPuestoLogInsert`, `CambioPuestoLogProtocolJson`, `RlEscenario`, `CambioPuestoAccion`, `PuestoAdicionalItem`, `CambioPuestoImpactoDeltas`, `DeltaCategoriaItem`, `ValorAnteriorNuevoItem`, `CentroModalItem`, `CambioPuestoCatalogo`.

**puestos-back**
- `CambioRmCatalogoDaoImpl`, `CambioRmCatalogoMapper` (Javadoc de clase).
- DTOs: `CambiarPuestoRlResponse`, `CambioRmCatalogoResponse`.
- (Los DTOs `CambiarPuestoRlRequest`/`CambiarPuestoRlAdicional` y los métodos nuevos de `PuestoDao`/`PuestoManager` ya estaban documentados.)

**rrmm-utils**
- `ReconciliacionProtocolosDaoImpl`, `AplicarProtocolosReconocimientoServiceImpl` (Javadoc de clase).
- `ProtocolosReconocimientoController` (Javadoc de clase).
- (Los DTOs `AplicarProtocolosRequest/Response`, `RecalcularProtocolosRequest`, `PruebaRealizada`, `ConteoConfiguracionInf3` ya tenían Javadoc.)

## Criterio aplicado
- No dupliqué Javadoc en clases que ya lo tenían (p. ej. `CambioPuestoRlExecutor`, varios helpers y DTOs).
- En los métodos de las `*Impl` no repetí la documentación de la interfaz: con `@Override` el Javadoc se hereda del contrato. Documenté los helpers privados no triviales y el comportamiento a nivel de clase.
- Solo comentarios; sin cambios funcionales.

## Verificación
- Sin errores de lint en los archivos editados.
- `compileJava` con `EXIT=0` en `rrmm-backend`, `puestos-back` y `rrmm-utils`.

---

**User**

vale resumen de lo siguiente a abordar que lo dejamos ya por hoy

---

**Cursor**

Buen punto para cerrar. Aquí el resumen de lo pendiente para retomar mañana.

## Hecho hoy
- **Migración RL (BE-08)**: mutación de `PPT_CEN_TRA` movida de rrmm-backend a puestos-back (delegación vía `cambiarPuestoRl`, como último paso de `confirmar()`).
- **Limpieza de código muerto** aprobado (métodos locales de mutación RL, etc.).
- **Javadoc completo**: interfaces, `*Impl`, controllers, enums y DTOs del flujo de cambio de puesto en los 3 proyectos. Los 3 compilan (`EXIT=0`).

## Pendiente de abordar
1. **BE-11** — la implementación original que quedó aparcada antes del análisis de código muerto. Es el siguiente bloque funcional grande a retomar.

2. **Verificación de la migración RL en runtime** — la lógica está migrada y compila, pero falta validación end-to-end:
   - Probar `confirmar()` real contra puestos-back (alta/baja principal + adicionales + override de cliente).
   - Confirmar el comportamiento transaccional ante fallo remoto (puestos-back escribe y un paso local posterior falla → no hay rollback distribuido; está documentado como trade-off, pero conviene validarlo).

3. **Tests** — actualizamos los unit tests de `CambioPuestoRlExecutor` y `CambioPuestoServiceImpl` con mocks, pero faltaría:
   - Test de integración del nuevo endpoint `cambiarPuestoRl` en puestos-back (escenarios `SOLO_ADICIONALES`, `EDITADA`, `CREADA`, validación OK técnico).

4. **Decisión consciente ya tomada (no tocar)**: los campos de DTO no leídos en producción (`AplicarProtocolosBackResponse.rmId`, `ipromesInsertados`, `productosQuimicosInsertados`, `ItemConfiguracionBackDto.protocoloId`, `PeriodicidadBackDto.id`/`totalMeses`) **se quedan** por contrato HTTP. Lo dejo anotado por si reaparece la duda.

## Sugerencia para mañana
Empezar por **BE-11** (bloque funcional) y, en paralelo o después, la **verificación runtime de la migración RL** con un test de integración en puestos-back.

¿Quieres que mañana arranque por BE-11 o por los tests de integración de la migración RL? Lo dejamos aquí por hoy.

---

**User**

que queda de BE-11

---

**Cursor**

Déjame buscar qué es BE-11 exactamente y su estado, porque en esta sesión no tengo el detalle. Reviso documentación y código.

BE-11 = **CA-15** (aviso "laboratorio ya comunicado" antes de aplicar) + **CU-11 / regla §7.6** (warnings post-cambio por nuevos parámetros/perfiles analíticos). Veo qué hay ya implementado en el código.

Reviso la implementación en `CambioPuestoServiceImpl` (zona simular/confirmar) para ver qué cubre y qué falta de BE-11.

Revisado. **BE-11 ya está implementado en el backend.** Esto es lo que hay y lo que realmente queda:

## Ya implementado (rrmm-backend)
- **CA-15 — aviso "laboratorio ya comunicado"**: `CambioPuestoDaoImpl.tieneComunicacionLabActiva()` consulta real sobre `VS_2007.EA_LAB_COM` (`TIPO='R'`, `ITEM_ID=rmId`, `ANULADO IS NULL`). Solo lectura, nunca modifica la comunicación.
- **Aviso en SIMULAR**: se emite `laboratorioComunicado` cuando el RM ya tiene comunicación activa.
- **CU-11 / §7.6 — warnings post-cambio**: se emite `analiticaComunicadaNuevosParametros` cuando, además, el cambio añade nuevos parámetros/perfiles analíticos. Está tanto en `SIMULAR` (`avisos`) como en `CONFIRMAR` (`warnings`, vía `avisosLaboratorio(...)`).
- **No bloquean** el cambio (negocio cerró el riesgo N1/N3/CU-11 como no bloqueante) y **no lanzan ninguna comunicación**: solo informan.

## Lo que queda de BE-11
1. **Tests** de la lógica de avisos/warnings: con/sin comunicación activa, con/sin parámetros-perfiles añadidos, en SIMULAR y CONFIRMAR. (Parte solapa con BE-14 testing.)
2. **Contrato de códigos con FE-11**: confirmar que el frontend espera exactamente estos strings — `laboratorioComunicado`, `analiticaComunicadaNuevosParametros` (y los de impacto: `protocolosImpacto`, `analiticaImpacto`, `periodicidadImpacto`). Es lo único de "integración" que podría requerir ajuste.
3. **Validación funcional** del aviso en un RM real con comunicación al laboratorio activa.

## Conclusión
De BE-11 **no queda desarrollo backend pendiente**; queda **testing + alinear el contrato de avisos con FE + verificación funcional**. La nota de la estimación ("revisar BE-06, BE-10, BE-11") apuntaba a que dependían del motor dry-run **P1**, que ya creamos en rrmm-utils (`/rrmm/protocolos/recalcular`), así que esa dependencia está cubierta.

Lo dejamos aquí por hoy. Mañana, si quieres, arrancamos por los tests de BE-11 o por BE-14 (testing cross-repo), que es donde está el grueso de lo que falta.

---

**User**

pues como frontend no tocamos nosotros vayamos por lo que queda pendiente de BE-11 que dices que son los test?

---

**Cursor**

Vamos con los tests de BE-11. Primero miro cómo están montados los tests existentes de cambio de puesto para seguir el mismo patrón, y así propongo un plan concreto antes de escribir.

Reviso el `CambioPuestoServiceImplTest` actual para ver qué cobertura de avisos/warnings (BE-11) ya existe y seguir su patrón.

Sorpresa útil: los tests de servicio de BE-11 **ya existen** en `CambioPuestoServiceImplTest` (SIMULAR avisos CA-15/CU-11, con y sin comunicación; CONFIRMAR warnings). Veo si falta la cobertura del DAO `tieneComunicacionLabActiva`.

Resulta que BE-11 **ya tiene tests** en dos niveles. Leo el detalle para confirmar qué escenarios cubren y si hay algún hueco.

Aquí hay una novedad importante: **BE-11 ya está cubierto por tests** en dos niveles. Lo confirmo ejecutándolos antes de proponer nada.

Cobertura existente que he encontrado:
- **Servicio** (`CambioPuestoServiceImplTest`): SIMULAR con avisos CA-15+CU-11, SIMULAR sin comunicación, CONFIRMAR con warnings, CONFIRMAR sin comunicación.
- **DAO** (`CambioPuestoDaoImplTest`): `tieneComunicacionLabActiva` (forma de la query, count 0, edge).

Ejecuto esos dos para verificar que están en verde.

`BUILD SUCCESSFUL` — los 7 tests de BE-11 pasan en verde.

## Estado real de BE-11
- **Implementación**: completa.
- **Tests**: ya existen y pasan. 4 de servicio + 3 de DAO cubren:
  - SIMULAR/CONFIRMAR con comunicación activa + analítica añadida → emite `laboratorioComunicado` **y** `analiticaComunicadaNuevosParametros`.
  - SIMULAR/CONFIRMAR sin comunicación → no emite nada.
  - DAO `tieneComunicacionLabActiva` (forma de la query, count 0, valor nulo).

Es decir, lo que ayer marqué como "pendiente: tests" **estaba en su mayoría ya hecho**.

## Único hueco que veo
Falta el **caso límite de CU-11**: comunicación al laboratorio **activa pero SIN** nuevos parámetros/perfiles. El comportamiento esperado es emitir **solo** `laboratorioComunicado` y **no** `analiticaComunicadaNuevosParametros`. Esto valida que CU-11 es condicional a que haya analítica añadida (hoy se prueba el "ambos sí" y el "ambos no", pero no el intermedio).

Propongo añadir 2 tests pequeños a `CambioPuestoServiceImplTest` (mismo patrón que los existentes):
1. `simular_soloLaboratorioComunicado_sinAnaliticaAnadida` → contiene `laboratorioComunicado`, no contiene `analiticaComunicadaNuevosParametros`.
2. `confirmar_soloLaboratorioComunicado_sinAnaliticaAnadida` → idem en `warnings`.

¿Te creo estos 2 tests del caso límite? Es lo único que le falta a BE-11 en cobertura; con eso lo damos por cerrado de verdad.

---

**User**

añade

---

**Cursor**

I'll add the two boundary-case tests. First I need to see the exact imports, helpers (`buildSimularRequest`, `buildConfirmarRequest`) and structure to match the existing pattern precisely.

Ahora veo los helpers `buildSimularRequest`/`buildConfirmarRequest` para reutilizarlos.

Tengo todo lo necesario. Añado los dos tests del caso límite justo después del último test de warnings, reutilizando los helpers existentes.

Sin errores de lint. Ejecuto la clase de test para confirmar que los dos nuevos casos pasan (junto con los existentes).

`BUILD SUCCESSFUL` — la clase completa pasa, incluidos los dos nuevos casos límite.

## Hecho
Añadí a `CambioPuestoServiceImplTest` los 2 tests que faltaban del caso límite de CU-11:

- `simular_soloLaboratorioComunicado_sinAnaliticaAnadida` — comunicación al laboratorio activa + impacto solo en protocolos (sin parámetros/perfiles) → emite `laboratorioComunicado` y **no** `analiticaComunicadaNuevosParametros`.
- `confirmar_soloLaboratorioComunicado_sinAnaliticaAnadida` — mismo escenario en CONFIRMAR, verificado sobre `warnings`.

Ambos siguen el patrón de los tests existentes (mocks, helpers `buildSimularRequest`/`buildConfirmarRequest`) y pasan en verde. Sin errores de lint, solo cambio en el fichero de test.

## Estado de BE-11
Con esto, **BE-11 queda cerrado** en backend:
- Implementación: completa (CA-15 + CU-11, en SIMULAR y CONFIRMAR).
- Cobertura de tests: servicio (6 casos: ambos sí / ambos no / solo CA-15, en SIMULAR y CONFIRMAR) + DAO (`tieneComunicacionLabActiva`). Todo verde.

Lo único que queda fuera de nuestro alcance es **FE-11** (consumo de los códigos de aviso en frontend), que no tocamos nosotros.

Lo dejamos aquí. Mañana, si quieres, el siguiente bloque natural es **BE-14** (tests de integración cross-repo) o la verificación runtime de la migración RL.

