# Casos de uso y criterios de aceptación — Registro Horario Fase II

> **Fuente:** Anexo del funcional `Fase II - Funcional Rediseño Registro Horario.docx.md` (recibido jul 2026).  
> **Normalización:** formato Minerva (patrón Cambio de Puesto / Justificante).  
> **Formato exportación:** **CSV siempre** (decisión cerrada jun 2026; el anexo de negocio decía Excel — aquí unificado a CSV).  
> **Impacto estimación:** revisado a **480 h** (jul 2026); refuerza trazabilidad UAT.

---

## 6.1. Casos de uso principales

| ID | Caso de uso | Actor principal | Resultado esperado |
| :---- | :---- | :---- | :---- |
| CU-01 | Filtrar y consultar registros horarios (Informes) | Administrador/a, RLPT, Inspector/a | La tabla muestra la plantilla filtrada por periodo, puesto y centro, paginada y ordenable. |
| CU-02 | Exportar informes a CSV | Administrador/a, RLPT, Inspector/a | Se descarga un CSV según filtros activos y formato elegido (tabla / simple / detallado). |
| CU-03 | Gestión de acceso y selección de organización (Inspector) | Inspector/a | Accede solo a empresas autorizadas y desbloquea módulos en modo lectura al entrar en una empresa. |
| CU-04 | Auditoría y consulta de plantilla anonimizada | Inspector/a | Consulta fichajes y configuración sin exponer datos identificativos (nombre/apellidos difuminados). |
| CU-05 | Crear y revocar accesos externos (Inspector / RLPT) | Administrador/a | Da de alta o revoca inspectores y representantes legales desde Configuración. |
| CU-06 | Simulación y suplantación de identidad (Superadmin) | Superadmin | Navega en modo restringido y puede suplantar a un trabajador con su perfil real. |
| CU-07 | Perfil RLPT con Informes (complementario Babooni) | RLPT | Hereda pantallas de Usuario (Fase I) y accede al módulo Informes con **datos reales** de toda la plantilla. |

> **Nota CU-07:** No venía numerado en el anexo de negocio; se añade para cerrar trazabilidad RLPT (funcional §7 + decisión D11).

---

## 6.2. Criterios de aceptación (plan de pruebas)

Origen: «Caso de Aceptación X.Y» del anexo de negocio → renumerados **CA-01…CA-21**. Redacción adaptada a estilo Given/When/Then donde aplica.

| ID | Criterio de aceptación | Tipo de prueba | Prioridad | CU |
| :---- | :---- | :---- | :---- | :---- |
| CA-01 | Dado un usuario con acceso a Informes, cuando entra al módulo, entonces se muestra el periodo **Semana actual**, tabla ordenada por ID ascendente, título «Informes», subtítulo descriptivo y botón «Descargar informe». | Funcional / UX | Alta | CU-01 |
| CA-02 | Dado el selector de periodo, cuando el usuario elige Hoy, Semana actual, Mes actual o Personalizado, entonces el filtro se aplica; en Personalizado la modal exige fechas Desde/Hasta con validación Desde ≤ Hasta. | Funcional | Alta | CU-01 |
| CA-03 | Dado el módulo Informes, cuando se usan filtros, entonces Admin/RLPT pueden buscar por **nombre**; Inspector por **ID**; puesto y centro son multiselección (por defecto «Todos»); existe botón «Limpiar filtros». | Funcional | Alta | CU-01 |
| CA-04 | Dado un cambio en periodo o filtros, cuando se aplica, entonces la tabla se actualiza de inmediato, vuelve a página 1 y la paginación limita a **10 registros** por página. | Funcional | Alta | CU-01 |
| CA-05 | Dado la tabla de Informes, cuando se muestran resultados, entonces las columnas ID, Usuario (anonimizado solo Inspector), Centro, Puesto, Horas totales y Compensaciones son ordenables; Compensaciones usa verde (+), rojo (−) y gris (0). | Funcional / UX | Alta | CU-01 |
| CA-06 | Dado que no hay registros tras filtrar, cuando la tabla quedaría vacía, entonces se oculta la tabla, se muestra mensaje informativo y un botón para limpiar filtros. | Funcional | Alta | CU-01 |
| CA-07 | Dado el botón «Descargar informe», cuando se pulsa, entonces se abre modal con tres opciones excluyentes: **Informe tabla** (extracto pantalla; Inspector sin columna nombre), **Informe simple** (usuario+día+horas), **Informe detallado** (tramos/paradas). | Funcional | Alta | CU-02 |
| CA-08 | Dado 0 registros en pantalla, cuando el usuario pulsa «Exportar» en la modal, entonces **no** se genera CSV y se muestra **toast** de alerta. | Funcional | Crítica | CU-02 |
| CA-09 | Dado filtros y formato válidos, cuando se confirma exportación, entonces se descarga **CSV** (`.csv`) con nombre dinámico (tipo de informe + fecha de descarga). | Funcional | Crítica | CU-02 |
| CA-10 | Dado un Inspector autenticado, cuando accede a la aplicación, entonces en sidebar aparece badge amarillo «Inspector/a solo lectura · Datos anonimizados». | UX | Alta | CU-03 |
| CA-11 | Dado un Inspector recién autenticado, cuando aún no ha entrado en empresa, entonces solo ve módulo **Empresas**, cabecera «Sin empresa seleccionada» y resto de módulos ocultos. | Funcional | Crítica | CU-03 |
| CA-12 | Dado la tabla Empresas del Inspector, cuando pulsa «Acceder», entonces la cabecera muestra el nombre de la empresa y se desbloquean **Usuarios**, **Informes** y **Configuración** en solo lectura. | Funcional | Crítica | CU-03 |
| CA-13 | Dado Usuarios en perfil Inspector, cuando se listan trabajadores, entonces columnas ID Persona, Centro, Fechas alta/baja, Horas contrato y acción Ojo; **sin** nombre ni apellidos. | Funcional / Seguridad | Crítica | CU-04 |
| CA-14 | Dado la ficha vía icono Ojo, cuando se abre detalle, entonces campos en lectura (fondo gris), nombre/apellidos **difuminados** y aviso «Datos sensibles ocultos. Solo se muestra información no identificativa.» | Seguridad | Crítica | CU-04 |
| CA-15 | Dado compensaciones/calendario en ficha Inspector, cuando se visualizan, entonces todo es solo lectura y «Limpiar configuración» está deshabilitado. | Funcional | Alta | CU-04 |
| CA-16 | Dado el módulo Configuración del Inspector, cuando se accede, entonces las 5 pestañas (Empresa, Avisos, Parámetros, Centros, Festivos) están **congeladas** en lectura. | Funcional | Alta | CU-04 |
| CA-17 | Dado Configuración Admin, cuando se accede, entonces existe pestaña **Accesos externos** con buscador nombre/correo y botón «+ Añadir acceso». | Funcional | Alta | CU-05 |
| CA-18 | Dado «Añadir acceso», cuando se abre la modal, entonces tipo Inspector/RLPT (radio), nombre y email obligatorio con validación de formato; Guardar alta el registro. | Funcional | Alta | CU-05 |
| CA-19 | Dado un acceso en la lista, cuando se pulsa Eliminar, entonces aparece modal de confirmación con texto de revocación irreversible antes de borrar. | Funcional | Alta | CU-05 |
| CA-20 | Dado Superadmin en modo simulación (Usuarios), cuando navega ficha y listado, entonces «Importar/Crear usuarios», «Guardar datos» y «Nueva compensación» están deshabilitados. | Funcional / Regresión | Alta | CU-06 |
| CA-21 | Dado Superadmin en tabla Usuarios simulada, cuando pulsa «Suplantar usuario», entonces la sesión adopta rol, permisos y vista del trabajador seleccionado. | Funcional / Seguridad | Crítica | CU-06 |

### Criterios complementarios (funcional / QA — no en anexo negocio)

| ID | Criterio de aceptación | Tipo de prueba | Prioridad | CU | Notas |
| :---- | :---- | :---- | :---- | :---- | :---- |
| CA-22 | Dado RLPT autenticado, cuando accede a Informes, entonces ve **datos reales** (nombre visible) de toda la plantilla de la empresa, no anonimizados. | Funcional | Alta | CU-07 | D11 |
| CA-23 | Dado export movimientos compensaciones en ficha Inspector, cuando se exporta, entonces CSV anonimizado sin columnas identificativas prohibidas (funcional §4.3.4). | Seguridad | Alta | CU-04 | BE-2.6 |
| CA-24 | Dado suplantación activa, cuando Superadmin finaliza suplantación, entonces vuelve al contexto Superadmin y queda **registro de auditoría** (usuario origen, suplantado, timestamps). | Trazabilidad | Crítica | CU-06 | BE-0.6, QA-5.5 |
| CA-25 | Dado KPIs en Usuarios Inspector, cuando se aplican reglas D09, entonces estados Sin registro / Correcto / Incompleto coinciden con dataset UAT (hereda Fase I + BE-2.3). | Funcional | Alta | CU-04 | QA-5.4 |

---

## 6.3. Trazabilidad CU/CA → tareas Babooni

| CU / CA | Backend | Frontend | QA |
| :---- | :---- | :---- | :---- |
| **CU-01** CA-01…CA-06 | BE-1.1, BE-1.2, BE-1.3 | FE-1.1…FE-1.6, FE-1.8 | QA-5.3 (parcial) |
| **CU-02** CA-07…CA-09 | BE-1.4…BE-1.7, BE-1.9, BE-2.5 | FE-1.7, FE-1.8 | QA-5.3 |
| **CU-03** CA-10…CA-12 | BE-2.1, BE-0.1, BE-0.5 | FE-2.1, FE-2.2, FE-2.3 | QA-5.2 |
| **CU-04** CA-13…CA-16, CA-23, CA-25 | BE-2.2…BE-2.4, BE-2.6, BE-2.3 | FE-2.4, FE-2.6, FE-1.8 | QA-5.1, QA-5.4 |
| **CU-05** CA-17…CA-19 | BE-3.*, BE-0.4 | FE-3.* | QA-5.2 |
| **CU-06** CA-20…CA-21, CA-24 | BE-0.6, BE-0.2 | FE-0.4, FE-0.2 | QA-5.5 |
| **CU-07** CA-22 | BE-4.1, BE-4.2 | FE-4.1, FE-4.2 | QA-5.2, QA-5.3 |

---

## 6.4. Conclusión de revisión (jul 2026)

| Aspecto | Resultado |
| :---- | :---- |
| Cobertura vs. funcional Fase II | **Adecuada** para bloques principales; CA-22…CA-25 cubren huecos del anexo (RLPT, export ficha, auditoría suplantación, KPIs). |
| Cobertura vs. backlog 480 h | **Completa** — no se identifican tareas nuevas fuera de BE/FE/QA ya estimadas. |
| Excel vs CSV | Anexo negocio decía `.xlsx`; **normalizado a CSV** (alineado D13/D15 y BE-1.4…1.9). |
| Formato Minerva | **Normalizado** en este documento; anexo original permanece narrativo en el funcional. |
| Pendiente UAT | **Dataset UAT** (D26/T9) sigue bloqueante para QA-5.3, QA-5.4 y golden CSV. |
