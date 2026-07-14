jun 4, 2026

## Proyecto gestiones sobre recos \- Reunión inicial

Invitado [LEONARDO BENÍTEZ NÚÑEZ](mailto:l.benitez@preving.com) [Alejandro Ballesteros](mailto:alejandro@babooni.com) [FELIX RIVAS TRILLO](mailto:f.rivas@preving.com) [Juan Nicolás Vargas Moreno](mailto:juannicolas.vargas@babooni.com) [Jordi Cañas Carril](mailto:jordi.canas@babooni.com) [Álvaro](mailto:alvaro@babooni.com) [ALEJANDRO TORRES VALENCIA](mailto:alejandro.torres@preving.com) [JAVIER SANTIAGO CORTÉS](mailto:jsantiagoc@cualtis.com)

Archivos adjuntos [Proyecto gestiones sobre recos - Reunión inicial](https://calendar.google.com/calendar/event?eid=M3Q1aG12MXZxbzBkYWNnc2t0ZmgxcDJvbDAgbC5iZW5pdGV6QHByZXZpbmcuY29t)

Registros de la reunión [Grabación](https://drive.google.com/file/d/1chFvxT055Z2ckmDVtHlSkpjkOp-YKcQ1/view?usp=drive_web) 

### Resumen

La reunión delimitó los requisitos funcionales para editar puestos de trabajo dentro de los reconocimientos médicos.

**Objetivo técnico del desarrollo**  
La nueva funcionalidad permite editar el puesto de trabajo en reconocimientos pendientes, actualizando protocolos y relaciones laborales mientras se conservan las pruebas ya ejecutadas.

**Lógica de gestión datos**  
El sistema realiza un cruce de datos para combinar configuraciones avanzadas, mostrando advertencias si los cambios afectan analíticas o pruebas que fueron comunicadas previamente.

**Flujo y acceso usuario**  
El acceso queda restringido al personal autorizado, presentando una pantalla de confirmación que detalla los cambios propuestos antes de aplicar modificaciones definitivas en el registro.

*Califica este resumen:* [Útil](https://google.qualtrics.com/jfe/form/SV_4YkxrBAaiTVqYCi?isGoogler=false&isHelpful=true) o [Poco útil](https://google.qualtrics.com/jfe/form/SV_4YkxrBAaiTVqYCi?isGoogler=false&isHelpful=false)

### Próximos pasos

- [ ] \[Alejandro Torres Valencia\] Documentar escenarios funcionales: Definir todas las casuísticas de cambio de relación laboral, centro, cliente y puesto de trabajo en el documento funcional. Asegurar que los procesos de alta, baja y actualización queden descritos para evitar dudas en el desarrollo.

- [ ] \[Felix Rivas Trillo\] Proveer fuente protocolos: Proporcionar el origen o el endpoint que contiene la información sobre la configuración de protocolos y ACP. Facilitar a los desarrolladores el acceso técnico a estas definiciones para el cálculo de pruebas.

- [ ] \[El grupo\] Coordinar soluciones UX: Revisar con el equipo de UX las soluciones para la gestión de múltiples relaciones laborales y cambios complejos de cliente. Alinear la implementación técnica con las guías de diseño antes de iniciar el desarrollo.

- [ ] \[Alejandro Torres Valencia\] Actualizar Funcional: Completar la actualizacion del documento funcional integrando detalles sobre cambios de puesto, protocolos y validaciones. Finalizar y entregar la version definitiva antes de dos dias.

- [ ] \[Felix Rivas Trillo\] Crear Carpeta Proyecto: Generar una nueva carpeta para el proyecto y subir la version 4 definitiva del documento funcional para el equipo.

- [ ] \[El grupo\] Registrar Dudas Tecnicas: Anotar todas las consultas sobre roles, tablas y esquemas en el documento funcional. Etiquetar a Felix Rivas Trillo para recibir las aclaraciones necesarias.

- [ ] \[Felix Rivas Trillo\] Documentar Datos Tecnicos: Recopilar informacion detallada sobre la ubicacion de datos de clientes, centros y puestos de trabajo. Preparar un documento resumen para facilitar la estimacion del desarrollo.

- [ ] \[Leonardo Benitez Nunez\] Reclamar Presupuesto: Contactar al cliente para obtener el presupuesto firmado de las flotas. Realizar este seguimiento de forma prioritaria tras la reunion.

### Detalles

* **Antecedentes y definiciones de puestos**: ALEJANDRO TORRES VALENCIA explica el funcionamiento actual de los reconocimientos médicos, diferenciando entre el puesto de trabajo principal y los puestos adicionales asociados a la relación laboral. LEONARDO BENÍTEZ NÚÑEZ sugiere que es necesario distinguir claramente entre los tipos de puestos (de centro, estándar) para evitar confusiones, proponiendo una explicación técnica detallada en futuras reuniones.

* **Gestión de la relación laboral**: ALEJANDRO TORRES VALENCIA y LEONARDO BENÍTEZ NÚÑEZ definen la relación laboral como la vinculación entre un trabajador, un cliente y un centro. Se establece que, si bien un trabajador puede tener múltiples relaciones laborales con distintos clientes, solo puede existir una relación laboral por centro de trabajo.

* **Automatización de protocolos**: ALEJANDRO TORRES VALENCIA describe cómo el sistema asigna automáticamente protocolos, que consisten en agrupaciones de pruebas, parámetros y perfiles, basándose en los puestos de trabajo configurados. LEONARDO BENÍTEZ NÚÑEZ subraya que estos protocolos son configurables mediante herramientas del sistema y que su correcta gestión es fundamental.

* **Objetivo del nuevo desarrollo**: El equipo busca implementar una funcionalidad que permita editar el puesto de trabajo directamente dentro del reconocimiento médico. Al cambiar el puesto, el sistema debe actualizar automáticamente los protocolos, parámetros y pruebas asociados en el apartado resumen para reflejar el nuevo rol.

* **Alcance de la modificación**: El equipo aclara que la nueva funcionalidad de edición operará únicamente dentro de la nueva modal del reconocimiento médico. Se decide no modificar la funcionalidad existente en la ficha del trabajador fuera del reconocimiento médico para evitar interferencias.

* **Gestión de pruebas ya realizadas**: ALEJANDRO TORRES VALENCIA y Juan Nicolás Vargas Moreno debaten sobre las pruebas que ya han sido realizadas y marcadas con un registro (check verde). Se acuerda que, aunque el cambio de puesto modifique los protocolos, las pruebas ya ejecutadas y documentadas no deben eliminarse del reconocimiento médico.

* **Integración de cambios en el resumen**: FELIX RIVAS TRILLO señala la importancia de realizar un cruce de datos al sustituir los protocolos para conservar los cuestionarios y pruebas ya informadas, evitando borrar datos esenciales del reconocimiento médico.

* **Consideraciones sobre pruebas no correspondientes**: Juan Nicolás Vargas Moreno sugiere añadir un indicador visual para las pruebas que ya no corresponden al nuevo puesto pero que se mantienen por haber sido ejecutadas. El grupo decide no complicar el desarrollo con esta medida específica por ahora y mantener el funcionamiento actual.

* **Actualización de la relación laboral**: Se acuerda que cualquier cambio de cliente, centro o puesto en la modal debe actualizar también la relación laboral del récord. Si el cambio implica un nuevo cliente, se deberá crear una nueva relación laboral; si es en el mismo centro, se actualizará la existente.

* **Casuísticas de relaciones laborales múltiples**: LEONARDO BENÍTEZ NÚÑEZ y FELIX RIVAS TRILLO discuten el riesgo de sobrescribir relaciones laborales cuando un trabajador tiene varias activas. Se requiere documentar en el funcional cómo manejar estos casos para evitar errores en la asignación.

* **Restricción de estado del reconocimiento**: La nueva funcionalidad de cambio de puesto solo estará disponible para reconocimientos médicos en estado "pendiente". Los registros validados o finalizados no permitirán esta edición sin ser reabiertos previamente por el usuario.

* **Configuración Avanzada (ACP)**: LEONARDO BENÍTEZ NÚÑEZ explica que las ACP (Configuraciones Avanzadas) permiten añadir pruebas específicas, como pruebas de esfuerzo, según el nivel del cliente, centro, puesto o trabajador. Este sistema debe integrarse al recalcular los protocolos tras un cambio de puesto.

* **Estrategia de fusión de datos**: FELIX RIVAS TRILLO propone que al cambiar el puesto, el sistema realice una llamada similar a la de creación del récord original, aplicando un "merge" de los datos existentes con las nuevas configuraciones, respetando lo ya realizado y eliminando solo lo que no corresponde.

* **Cálculo de periodicidad y fechas**: FELIX RIVAS TRILLO destaca la necesidad de recalcular la periodicidad y la fecha recomendada del próximo reconocimiento médico tras cambiar el puesto, ya que estos parámetros pueden variar dependiendo de la configuración.

* **Documentación funcional y versión 4**: ALEJANDRO TORRES VALENCIA se compromete a actualizar el documento funcional a la versión 4, incluyendo todos los casos de uso discutidos y la lógica de actualización, para que Jordi Cañas Carril y Juan Nicolás Vargas Moreno puedan proceder con el desarrollo.

* **Flujo del usuario en la nueva modal**: La funcionalidad incluirá un buscador de clientes que, al seleccionar uno, forzará la selección de un centro y luego del puesto. El sistema presentará una pantalla de resumen para confirmar los cambios antes de aplicarlos definitivamente al registro.

* **Permisos de acceso**: El cambio de puesto estará restringido al personal sanitario con acceso al reconocimiento médico y a usuarios con rol administrativo específico, manteniendo la coherencia con los permisos actuales del sistema.

* **Comunicación con laboratorio y advertencias**: Se discute la gestión de analíticas ya comunicadas al laboratorio. FELIX RIVAS TRILLO y ALEJANDRO TORRES VALENCIA acuerdan mostrar un aviso visual claro (warning) en el apartado resumen si el cambio de puesto afecta a parámetros ya enviados, evitando automatismos que generen costes innecesarios.

* **Propuesta de mejora en la confirmación**: Jordi Cañas Carril sugiere que la pantalla de confirmación sea informativa sobre lo que se añade, elimina y, idealmente, lo que se mantiene. El equipo evaluará incluir notas aclaratorias en la modal sobre las pruebas conservadas.

* **Reutilización de componentes existentes**: FELIX RIVAS TRILLO confirma que se utilizarán las consultas y ventanas de selección de clientes/centros ya existentes en el sistema para asegurar consistencia, evitando reconstruir lógicas complejas.

* **Cronograma y cierre de alcance**: LEONARDO BENÍTEZ NÚÑEZ solicita el funcional actualizado para generar las estimaciones de trabajo. Se recalca que una vez entregado el documento y aceptado el desarrollo, no se admitirán cambios adicionales sin una nueva estimación.

*Revisa las notas de Gemini para asegurarte de que sean precisas. [Obtén sugerencias y descubre cómo Gemini toma notas](https://support.google.com/meet/answer/14754931)*

*Cómo es la calidad de **estas notas específicas?** [Responde una breve encuesta](https://google.qualtrics.com/jfe/form/SV_9vK3UZEaIQKKE7A?confid=YC5K4vhk_vru3G6MJNw7DxIPOAIIigIgABgDCA&detailid=standard&screenshot=false) para darnos tu opinión; por ejemplo, cuán útiles te resultaron las notas.*