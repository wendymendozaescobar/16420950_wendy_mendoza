# LAB-03. Privacidad, cumplimiento y gobierno de los datos

## 1. Introducción

Este laboratorio aborda la importancia de administrar los datos personales conforme a finalidades definidas y necesidades justificadas.

Se utilizará PostgreSQL para analizar aspectos relacionados con privacidad, minimización, controles de acceso, derechos ARCO, retención y gobierno de datos.

El escenario corresponde a una empresa ficticia que administra información de clientes.

## 2. Inventario y finalidad de los datos

Se identificaron nueve campos de la tabla `public.clientes` y se analizaron sus finalidades, necesidades, niveles de acceso y criterios de retención.

Se determinó que no todas las áreas necesitan consultar todos los datos.

El área de atención al cliente requiere principalmente información de identificación y contacto, mientras que facturación necesita información fiscal y analítica puede trabajar con resultados agregados.

### Evidencia

- [Inventario y finalidad de los datos](evidencias/01-inventario-datos.md)

## 3. Principio de minimización de datos

### Objetivo

Aplicar el principio de minimización mediante una tabla que contenga únicamente la información necesaria para el departamento de atención al cliente.

### Procedimiento

Se creó el esquema `lab03` para mantener separados los objetos de este laboratorio.

Posteriormente, se creó la tabla `lab03.clientes_soporte`, que contiene únicamente las columnas `id`, `nombre`, `correo` y `telefono`.

Los registros se obtuvieron desde `public.clientes`, seleccionando solamente las columnas necesarias.

### Preguntas de análisis

**1. ¿Todos los campos son necesarios para atención al cliente?**

No. El escenario indica que atención al cliente necesita información para identificar y contactar a los clientes, por lo que no requiere automáticamente todos los campos de la tabla original.

**2. ¿Por qué soporte necesitaría conocer el RFC?**

En el escenario presentado no se identifica una necesidad que justifique que soporte consulte el RFC. Este dato corresponde principalmente a actividades fiscales, por lo que su acceso debería limitarse al personal autorizado de facturación.

**3. ¿Necesita conocer la edad?**

No para las funciones de atención descritas en el ejercicio. La edad podría utilizarse en otros procesos justificados, pero eso no significa que soporte deba consultarla.

**4. ¿Necesita conocer el código postal?**

No para la finalidad de soporte planteada. Si existiera un procedimiento que requiriera información geográfica, sería necesario justificarlo antes de otorgar acceso.

**5. ¿Qué principio de privacidad está relacionado con esta decisión?**

El principio de minimización de datos, que busca limitar la información tratada a aquella adecuada, relevante y necesaria para una finalidad específica.

### Resultados

Se creó una tabla de soporte con cuatro columnas, en lugar de las nueve disponibles en la tabla original.
Tuve 5 registros.
Los datos fueron seleccionados desde `public.clientes` y se comprobó su estructura mediante consultas SQL.

### Análisis

La tabla original contiene información para distintas finalidades, pero atención al cliente no necesita acceder a todos esos datos.

Separar únicamente la información necesaria permite reducir la exposición de datos personales.

En un sistema productivo también sería conveniente evaluar el uso de vistas y permisos para evitar copias innecesarias de información.

### Conclusión

La actividad permitió aplicar el principio de minimización de datos mediante una estructura que contiene solamente la información necesaria para una finalidad específica.

También permitió comprender que el diseño de tablas y los permisos de acceso deben relacionarse con las funciones de cada departamento.

### Archivo SQL

- [Minimización de datos](sql/01-minimizacion.sql)

## 4. Separación por finalidad

### Objetivo

Generar información estadística para el departamento de analítica sin proporcionar directamente los datos personales que identifican a los clientes.

### Procedimiento

Se realizaron consultas SQL sobre la tabla `public.clientes`, utilizando funciones de agrupación y conteo.

Primero se agruparon los clientes por ciudad mediante `COUNT()` y `GROUP BY`.

Posteriormente, se utilizó `CASE` para clasificar a los clientes por rangos de edad.

Como complemento, se agruparon los códigos postales utilizando sus dos primeros caracteres.

### Resultados

Las consultas permitieron obtener estadísticas agrupadas sin incluir nombres, correos electrónicos, teléfonos ni RFC en los resultados.

Se utilizaron las siguientes herramientas de SQL:

- `COUNT()` para contar registros.
- `GROUP BY` para agrupar información.
- `ORDER BY` para ordenar resultados.
- `CASE` para crear categorías de edad.
- `LEFT()` para obtener prefijos postales.

Los resultados corresponden a grupos de clientes y no a registros individuales completos.

### Pregunta de análisis

**¿Por qué esta información puede ser más apropiada para analítica que entregar directamente la tabla completa de clientes?**

Porque el departamento de analítica necesita generar estadísticas y no identificar individualmente a cada cliente.

Las consultas agrupadas permiten conocer la distribución de los clientes por ciudad, edad y prefijo postal sin proporcionar directamente sus nombres, correos, teléfonos ni RFC.

Esto contribuye a reducir la exposición de datos personales y aplica los principios de minimización y limitación de finalidad.

Sin embargo, los resultados agregados también deben evaluarse, porque los grupos con muy pocos registros podrían facilitar la identificación de personas al combinarse con otra información.

### Análisis

La separación por finalidad permite proporcionar información diferente a cada departamento, dependiendo de sus funciones.

Atención al cliente necesita información para contactar personas, mientras que analítica requiere principalmente datos estadísticos.

Esto demuestra que no es necesario entregar acceso directo a toda la tabla para obtener resultados útiles.

### Conclusión

Se comprobó que las consultas de agrupación permiten generar información útil para analítica y disminuir la exposición de datos personales.

En un entorno productivo sería recomendable implementar vistas y controles de acceso que permitan consultar únicamente la información necesaria.

### Archivo SQL

- [Consultas de separación por finalidad](sql/02-finalidad.sql)

## 5. Control de acceso relacionado con la finalidad

### Objetivo

Aplicar controles de acceso en PostgreSQL para permitir que el departamento de analítica consulte únicamente la información necesaria para sus funciones.

### Procedimiento

Se comprobó que el rol `analista` ya existía porque había sido creado durante el LAB-01.

Para evitar modificar las actividades anteriores, se reutilizó el rol y se creó una nueva vista llamada `lab03.v_analitica_clientes`.

La vista contiene únicamente la ciudad y el rango de edad de los clientes.

Posteriormente, se otorgaron los permisos `USAGE` sobre el esquema `lab03` y `SELECT` sobre la vista.

Finalmente, se comprobaron los privilegios y se utilizó `SET ROLE analista` para verificar que el rol pudiera ejecutar la consulta.

### Resultados obtenidos

Al consultar los permisos asignados, PostgreSQL mostró que el rol `analista` tenía acceso de lectura a:

- `analitica.clientes`, correspondiente al LAB-01.
- `lab03.v_analitica_clientes`, correspondiente al LAB-03.

La consulta con `has_table_privilege()` devolvió los siguientes resultados:

| Verificación | Resultado |
|---|---|
| Consultar `lab03.v_analitica_clientes` | `t` |
| Consultar `public.clientes` | `f` |

También se ejecutó correctamente una consulta sobre la nueva vista utilizando el rol `analista`.

La consulta devolvió cinco registros que contenían únicamente las columnas `ciudad` y `rango_edad`.

### Preguntas de análisis

**1. ¿Qué información puede consultar el rol?**

En el LAB-03, el rol puede consultar la ciudad y el rango de edad mediante la vista `lab03.v_analitica_clientes`.

Además, conserva el acceso de lectura que recibió durante el LAB-01 sobre `analitica.clientes`, que contiene información preparada para análisis mediante tokens y otros atributos.

**2. ¿Puede consultar directamente `clientes`?**

No puede consultar directamente la tabla original `public.clientes`.

Esto se comprobó mediante `has_table_privilege()`, que devolvió `f` para el permiso `SELECT` sobre dicha tabla.

**3. ¿Puede obtener nombre, correo y RFC?**

No mediante los objetos a los que comprobamos que tiene acceso.

La vista creada para este laboratorio únicamente presenta ciudad y rango de edad.

La tabla `analitica.clientes` del LAB-01 tampoco contiene esas columnas identificadoras originales.

**4. ¿Qué principio de privacidad estás aplicando?**

El principio de minimización de datos, junto con la limitación de finalidad.

Se proporciona al departamento de analítica información relacionada con sus funciones, evitando entregarle automáticamente otros datos personales.

**5. ¿Qué principio de seguridad estás aplicando?**

El principio de mínimo privilegio.

Consiste en otorgar a un usuario o rol únicamente los permisos necesarios para realizar sus actividades.

### Análisis

Esta actividad permitió comprobar que una vista puede utilizarse para limitar las columnas disponibles para un departamento.

También se observó que los permisos deben configurarse tanto sobre el esquema como sobre los objetos que se desea consultar.

La reutilización del rol `analista` permitió conservar los permisos del LAB-01 y agregar únicamente el acceso necesario para este laboratorio.

Sin embargo, una vista que muestra ciudad y rango de edad por cada cliente no garantiza anonimato. En un entorno productivo también sería necesario evaluar el riesgo de identificación indirecta y considerar resultados agregados.

### Conclusión

Se comprobó que PostgreSQL permite relacionar los permisos con las responsabilidades de cada departamento.

El rol `analista` pudo consultar la vista autorizada, pero no tenía permiso de lectura sobre la tabla original `public.clientes`.

Esta práctica permitió aplicar los principios de minimización de datos, limitación de finalidad y mínimo privilegio.

### Archivo SQL

- [Control de acceso relacionado con la finalidad](sql/03-control-acceso.sql)

## 6. Análisis de una finalidad secundaria

### Objetivo

Evaluar los riesgos relacionados con el uso de información personal para una finalidad distinta de aquella para la que fue recopilada.

### Procedimiento

Se analizó la propuesta de utilizar edad, ciudad y comportamiento de compra para enviar promociones personalizadas.

Se identificaron las condiciones que deberían revisarse antes de autorizar este tratamiento, así como los datos necesarios y los controles técnicos que podrían implementarse.

### Resultados

Se determinó que la organización no puede asumir que cualquier uso de los datos es válido simplemente porque ya dispone de ellos.

También se identificó que marketing no necesita acceso directo a toda la tabla `public.clientes`.

Se propusieron mecanismos como vistas, roles, permisos, agregación de información y controles para respetar las preferencias de los titulares.

### Análisis

Esta actividad permitió comprender que la seguridad técnica y la autorización para tratar datos personales son cuestiones diferentes.

Los controles implementados por el DBA deben responder a finalidades previamente definidas y autorizadas por las áreas responsables.

### Conclusión

La utilización de datos para finalidades secundarias requiere analizar su justificación, necesidad y condiciones aplicables.

La información entregada a cada departamento debe limitarse a lo necesario para cumplir sus funciones autorizadas.

### Evidencia

- [Análisis de finalidad secundaria](evidencias/05-finalidad-secundaria.md)

## 7. Derecho ARCO de acceso

### Objetivo

Identificar las implicaciones técnicas que tiene una solicitud de acceso a datos personales y comprender cómo PostgreSQL puede utilizarse para localizar la información de un titular.

### Procedimiento

Se analizó el caso de un cliente que solicita conocer los datos personales que la organización tiene registrados.

Se utilizó una consulta SQL sobre la tabla `public.clientes`, aplicando una condición `WHERE` para localizar la información asociada con un correo electrónico específico.

La consulta utilizada fue:

```sql
SELECT
    id,
    nombre,
    correo,
    telefono,
    rfc,
    edad,
    ciudad,
    codigo_postal,
    fecha_alta
FROM public.clientes
WHERE correo = 'ana@example.com';
```

### Resultado obtenido

Se ejecutó una consulta SQL sobre la tabla `public.clientes` para localizar la información personal asociada con el correo electrónico ficticio `ana@example.com`.

PostgreSQL ejecutó correctamente la consulta y devolvió el siguiente resultado:

```text
(0 filas)
```

Esto indica que no se encontraron registros asociados con el correo electrónico utilizado en el ejemplo del profesor.

La ausencia de resultados no representa un error en la consulta, sino que el valor buscado no coincide con ningún registro de la tabla.

No fue necesario insertar, modificar ni eliminar información para realizar esta comprobación.

La práctica permitió demostrar cómo utilizar la cláusula `WHERE` para buscar información de un titular específico, evitando consultar indiscriminadamente todos los registros de clientes.

### Pregunta de análisis

**¿Qué información adicional debería proporcionar la organización además del resultado de esta consulta?**

La organización debería proporcionar la información relacionada con el tratamiento de los datos personales que corresponda conforme a las condiciones aplicables.

Entre los aspectos relevantes se encuentran las finalidades del tratamiento, el origen de la información, las transferencias realizadas cuando corresponda, los criterios de conservación y los mecanismos para ejercer otros derechos relacionados con los datos personales.

También es importante comprobar que la solicitud proviene del titular o de una persona autorizada para actuar en su representación.

### Análisis

La consulta permite localizar información asociada con un cliente dentro de PostgreSQL.

Sin embargo, los datos podrían encontrarse también en otras tablas, respaldos, exportaciones o sistemas relacionados.

Por esta razón, atender técnicamente una solicitud de acceso requiere conocer dónde se encuentra la información personal y cómo se relaciona entre los diferentes sistemas.

El DBA puede colaborar mediante consultas, inventarios de información y controles de acceso, pero la decisión sobre el alcance de la respuesta corresponde a las áreas responsables de privacidad y cumplimiento.

### Conclusión

La actividad permitió comprender que el derecho de acceso tiene implicaciones técnicas en la administración de bases de datos.

PostgreSQL facilita la localización de registros mediante consultas SQL, pero atender una solicitud de acceso requiere procedimientos adicionales para verificar la identidad del titular, identificar la información correspondiente y protegerla durante su entrega.

## 8. Derecho ARCO de rectificación

### Objetivo

Aplicar el derecho de rectificación mediante una actualización controlada de información personal en PostgreSQL y comprender la importancia de la autorización y trazabilidad de los cambios.

### Procedimiento

Se consultó inicialmente la tabla `public.clientes` para identificar al cliente con `id = 1`.

PostgreSQL mostró que el registro pertenecía a Ana López y que su correo electrónico era `ana.lopez@example.test`.

Después se comprobó que el correo `nuevo-correo@example.com` no estuviera registrado en otro cliente. La consulta devolvió cero filas.

Para realizar la rectificación, se inició una transacción con `BEGIN` y se ejecutó:

```sql
UPDATE public.clientes
SET correo = 'nuevo-correo@example.com'
WHERE id = 1
  AND correo = 'ana.lopez@example.test'
RETURNING id, nombre, correo;
```

Posteriormente, se verificó la información mediante una consulta `SELECT`.

Finalmente, se confirmó la transacción utilizando `COMMIT`.

### Resultado obtenido

PostgreSQL devolvió `UPDATE 1`, lo que confirma que se modificó exactamente un registro.

Los resultados fueron:

| Campo | Resultado |
|---|---|
| ID del cliente | `1` |
| Nombre | Ana López |
| Correo anterior | `ana.lopez@example.test` |
| Correo nuevo | `nuevo-correo@example.com` |
| Registros actualizados | `1` |
| Transacción | Confirmada mediante `COMMIT` |

La consulta de verificación mostró que el cliente tenía registrado el nuevo correo electrónico.

No se modificaron otros campos durante esta operación.

### Preguntas de análisis

**1. ¿Cómo podría comprobarse que el cambio fue autorizado?**

La organización debería verificar la identidad del titular o de su representante autorizado y conservar evidencia de la solicitud de rectificación.

También debería existir un procedimiento para registrar la autorización correspondiente antes de realizar el cambio.

En este laboratorio, la actualización se efectuó como parte de un escenario académico con datos ficticios. No se implementó un procedimiento real de autorización.

**2. ¿Debería registrarse quién realizó el cambio?**

Sí. Es recomendable registrar la identidad del usuario o proceso que realizó la modificación, la fecha, el momento de ejecución y el registro afectado.

Esta información permite identificar quién realizó una operación y facilita la investigación de modificaciones indebidas.

Durante la práctica se comprobó la ejecución de la actualización, pero no se implementó un sistema de auditoría persistente.

**3. ¿Por qué es importante la trazabilidad?**

Porque permite reconstruir las operaciones realizadas sobre la información.

En el caso de una rectificación, ayuda a identificar cuándo se modificó un dato, quién ejecutó el cambio y qué solicitud lo justificó.

También facilita la detección de errores, la investigación de incidentes y la demostración de que se siguieron los procedimientos establecidos.

### Análisis

La actividad permitió comprobar que `UPDATE` puede utilizarse para corregir información personal almacenada en PostgreSQL.

Se utilizó una transacción para controlar la operación y se agregaron condiciones específicas para evitar modificar registros distintos del cliente seleccionado.

Sin embargo, una rectificación no siempre termina al actualizar una sola tabla.

Durante la Actividad 2 se creó `lab03.clientes_soporte`, que contiene una copia de determinados datos de `public.clientes`.

Esta copia no se actualiza automáticamente cuando cambia el correo en la tabla original. Por ello, en un entorno productivo sería necesario identificar las copias y sistemas relacionados, y establecer mecanismos para mantener la consistencia de los datos.

También sería necesario implementar controles de autorización y auditoría.

### Conclusión

Se realizó correctamente la rectificación del correo electrónico de un cliente ficticio mediante PostgreSQL.

Se comprobó que la instrucción modificó un único registro y que la transacción quedó confirmada.

La actividad permitió comprender la importancia de verificar los datos antes de modificarlos y mantener mecanismos que permitan autorizar, registrar y rastrear las operaciones realizadas sobre información personal.

## 9. Derecho ARCO de cancelación y ciclo de vida

### Objetivo

Analizar las implicaciones técnicas de una solicitud de cancelación de datos personales y comprender por qué la eliminación de un registro no garantiza la desaparición de todas sus copias.

### Procedimiento

Se identificaron las estructuras de datos utilizadas durante los laboratorios y se analizaron otras posibles ubicaciones de información personal.

Se construyó un mapa que contempla tablas relacionadas, respaldos, réplicas, reportes, exportaciones, registros de auditoría y sistemas externos.

No se ejecutaron instrucciones de eliminación.

### Resultados

Se identificó que durante los laboratorios se crearon diferentes estructuras que contienen o relacionan información de clientes.

Entre ellas se encuentran `public.clientes`, `lab03.clientes_soporte`, `analitica.clientes` y `pii.mapa_cliente`.

También se identificaron otros componentes que deberían investigarse antes de atender técnicamente una solicitud de cancelación.

### Análisis

Eliminar un registro de una tabla no garantiza que desaparezcan las copias almacenadas en otras estructuras o sistemas.

Por ello, es necesario identificar las ubicaciones de la información y determinar qué operaciones deben realizarse conforme a las decisiones autorizadas.

Los periodos de conservación y las obligaciones aplicables también deben considerarse antes de eliminar información.

### Conclusión

La cancelación de datos personales requiere analizar su ciclo de vida completo.

El DBA debe identificar dependencias y copias de información, colaborar con las áreas responsables e implementar los controles técnicos correspondientes.

### Evidencia

- [Derecho de cancelación y ciclo de vida](evidencias/08-ciclo-vida.md)

## 10. Derecho ARCO de oposición

### Objetivo

Analizar las implicaciones de una solicitud de oposición al tratamiento de datos personales y comprender cómo pueden limitarse determinadas finalidades sin eliminar necesariamente toda la información del titular.

### Procedimiento

Se analizó el escenario de un cliente que solicita que sus datos personales dejen de utilizarse para una finalidad secundaria.

Se identificó qué información podría necesitar conservarse, qué tratamientos deberían restringirse y qué mecanismos técnicos podrían utilizarse para separar las finalidades.

### Resultados obtenidos

**¿Es necesario eliminar inmediatamente todos los datos del cliente?**

No necesariamente.

El derecho de oposición puede implicar que la organización deje de utilizar determinados datos para una finalidad específica, sin que esto signifique eliminar automáticamente toda la información que conserva.

Por ejemplo, si un cliente se opone al uso de su correo electrónico para publicidad, la empresa podría necesitar conservar ese correo para comunicaciones operativas justificadas.

La procedencia y el alcance de la solicitud deben ser evaluados por las áreas responsables conforme a las condiciones legales aplicables.

### Preguntas de análisis

**1. ¿Qué información podría necesitar mantenerse?**

Podrían conservarse los datos necesarios para administrar la relación comercial, atender solicitudes del cliente, realizar operaciones autorizadas y cumplir obligaciones legales aplicables.

Por ejemplo, la organización podría necesitar mantener el identificador del cliente, determinada información de contacto y los datos fiscales correspondientes.

Sin embargo, la conservación debe estar justificada y respetar los periodos de retención establecidos.

**2. ¿Qué información podría dejar de utilizarse para determinada finalidad?**

Si procede la oposición al tratamiento con fines publicitarios, la organización debería dejar de utilizar para esa finalidad los datos correspondientes.

Por ejemplo:

- Correo electrónico para campañas promocionales.
- Ciudad para segmentación publicitaria.
- Rangos de edad utilizados para personalizar promociones.
- Información sobre comportamiento de compra utilizada para marketing, si existiera y estuviera comprendida en la solicitud.

Estos datos podrían mantenerse para otras finalidades legítimas cuando corresponda, pero no deberían seguir utilizándose para la finalidad respecto de la cual procedió la oposición.

**3. ¿Qué mecanismos técnicos podrían separar finalidades?**

En PostgreSQL podrían implementarse diferentes controles:

1. **Roles y permisos:** limitar el acceso de cada departamento a los datos necesarios.
2. **Vistas:** presentar únicamente las columnas autorizadas para cada finalidad.
3. **Separación de esquemas:** organizar los objetos de acuerdo con sus funciones.
4. **Registro de preferencias:** mantener información sobre las finalidades para las que un cliente ha ejercido su oposición.
5. **Filtros en consultas:** excluir de las campañas a los clientes cuya oposición haya sido aceptada.
6. **Auditoría:** registrar las modificaciones de preferencias y los accesos relevantes.

Estos mecanismos deben diseñarse de manera que los distintos sistemas respeten las restricciones correspondientes.

**4. ¿Por qué la decisión final no debe ser tomada únicamente por el DBA?**

Porque determinar si procede una solicitud de oposición requiere analizar las finalidades del tratamiento, las obligaciones de la organización y el marco jurídico aplicable.

El DBA tiene conocimientos técnicos para implementar restricciones, permisos, consultas y controles de seguridad, pero no debería decidir por sí solo si una organización está jurídicamente obligada a dejar de tratar determinada información.

Esa decisión debe involucrar a las áreas responsables de privacidad, cumplimiento y, cuando corresponda, al área jurídica y al propietario de los datos.

### Análisis

La actividad permitió identificar que los derechos de cancelación y oposición tienen implicaciones diferentes.

La cancelación puede requerir acciones relacionadas con la eliminación o el tratamiento de determinados datos, cuando proceda.

La oposición se relaciona con impedir o detener un tratamiento específico bajo las condiciones aplicables.

Desde el punto de vista técnico, PostgreSQL puede contribuir mediante vistas, roles, permisos y mecanismos para registrar y aplicar las preferencias de los titulares.

Sin embargo, los controles técnicos deben responder a decisiones organizacionales y jurídicas previamente establecidas.

### Conclusión

Se comprendió que ejercer el derecho de oposición no implica necesariamente eliminar toda la información personal de una base de datos.

La organización debe identificar qué finalidad está involucrada y determinar qué tratamiento corresponde restringir.

El DBA debe implementar los mecanismos técnicos necesarios para respetar esas decisiones, sin asumir responsabilidades jurídicas que corresponden a otras áreas.

## 11. Política de retención de datos

### Objetivo

Analizar los riesgos de conservar información personal indefinidamente y comprender cómo deben establecerse políticas de retención.

### Procedimiento

Se analizó la propuesta de conservar todos los datos de clientes sin establecer un límite de tiempo.

Se identificaron los riesgos relacionados con esta práctica y los elementos necesarios para determinar periodos de conservación adecuados.

### Resultados

Se concluyó que conservar información indefinidamente únicamente porque podría utilizarse en el futuro no es compatible con el principio de minimización.

También se identificaron riesgos relacionados con exposición de datos, incumplimiento de obligaciones, información desactualizada y dificultades para atender derechos ARCO.

Se determinó que una política de retención debería documentar las categorías de datos, sus finalidades, periodos de conservación, justificaciones, responsables y procedimientos para finalizar el tratamiento.

### Análisis

Los periodos de conservación pueden variar según la finalidad y las obligaciones relacionadas con cada tipo de información.

No es adecuado asignar automáticamente el mismo periodo a todos los campos de una base de datos.

El DBA puede implementar mecanismos técnicos para apoyar el cumplimiento de estas políticas, pero no debe determinar por sí solo los plazos legales aplicables.

### Conclusión

La retención debe considerarse durante todo el ciclo de vida de los datos.

Una política documentada permite justificar la conservación de información y establecer procedimientos para tratar los datos cuando dejan de ser necesarios.

### Evidencia

- [Política de retención de datos](evidencias/10-retencion.md)

## 12. Matriz de gobierno de datos

### Objetivo

Relacionar los principales datos personales de la organización con sus finalidades, responsables y usuarios autorizados.

### Procedimiento

Se elaboró una matriz de gobierno de datos para los campos nombre, correo, teléfono, RFC, edad, ciudad y código postal.

Se identificaron las necesidades funcionales de atención al cliente, facturación y analítica.

Posteriormente, se propusieron responsables y permisos de acceso de acuerdo con las finalidades de cada departamento.

### Resultados

Se determinó que atención al cliente requiere principalmente información de identificación y contacto.

Facturación necesita acceder a los datos fiscales correspondientes.

Analítica puede utilizar información agrupada por ciudad, edad y región sin recibir automáticamente identificadores personales.

También se identificó que el DBA debe implementar los controles técnicos autorizados, pero no decidir por sí solo las finalidades del tratamiento.

### Análisis

La matriz permite relacionar las responsabilidades organizacionales con los permisos que posteriormente pueden implementarse en PostgreSQL.

El gobierno de datos ayuda a evitar que todos los departamentos reciban acceso a toda la información.

Las responsabilidades propuestas deben validarse formalmente antes de aplicarse en un entorno productivo.

### Conclusión

El gobierno de datos permite establecer responsabilidades claras sobre la utilización y protección de información.

Una matriz de responsabilidades ayuda a aplicar los principios de minimización, limitación de finalidad y mínimo privilegio.

### Evidencia

- [Matriz de gobierno de datos](evidencias/11-gobierno-datos.md)

## 13. Privacidad por diseño

### Objetivo

Analizar una propuesta de base de datos para identificar los riesgos de recopilar información personal sin una finalidad previamente definida.

### Procedimiento

Se evaluó una tabla propuesta para registrar clientes que incluía información de identificación, contacto, situación personal y datos financieros.

Se analizaron los principios de minimización, finalidad, privacidad por diseño y privacidad por defecto.

### Resultados

Se identificó que varios campos propuestos requerían una justificación adicional antes de incorporarse a la base de datos.

Se propuso una estructura inicial con información mínima para el registro y atención básica de clientes.

También se identificaron mecanismos para reducir la exposición de información mediante controles de acceso, vistas, separación de finalidades y políticas de retención.

### Análisis

Almacenar información únicamente porque podría resultar útil en el futuro puede generar riesgos de privacidad.

El diseño de una base de datos debe partir de las finalidades del sistema y determinar qué información necesita realmente cada proceso.

### Conclusión

La privacidad por diseño permite identificar necesidades y riesgos antes de implementar una base de datos.

La privacidad por defecto contribuye a que el sistema comience con configuraciones que limiten la recopilación, utilización y exposición de datos personales.

### Evidencia

- [Análisis de privacidad por diseño](evidencias/12-privacidad-diseno.md)

## 14. Controles técnicos y administrativos

### Objetivo

Diferenciar los controles técnicos de los administrativos relacionados con la privacidad y seguridad de la información, identificando cómo se complementan dentro de una organización.

### Procedimiento

Se analizaron las ocho medidas de seguridad presentadas en el escenario del laboratorio.

Cada medida se clasificó de acuerdo con su función principal y se identificaron aquellas que pueden involucrar tanto controles técnicos como administrativos.

### Resultado obtenido

| Medida | Técnico | Administrativo |
|---|:---:|:---:|
| Crear roles de PostgreSQL | Sí | No |
| Política de retención | No | Sí |
| Cifrado de datos | Sí | No |
| Procedimiento para solicitudes ARCO | No | Sí |
| Vista con información limitada | Sí | No |
| Clasificación de información | No | Sí |
| Registro de auditoría | Sí | Sí |
| Política de control de acceso | No | Sí |

### Justificación de las decisiones

**1. Crear roles de PostgreSQL — Control técnico**

La creación de roles se realiza mediante mecanismos del sistema gestor de bases de datos.

Por ejemplo, PostgreSQL permite utilizar `CREATE ROLE` y `GRANT` para administrar usuarios y privilegios.

Aunque los permisos deben responder a políticas organizacionales, crear el rol constituye una implementación técnica.

**2. Política de retención — Control administrativo**

Establece las reglas sobre cuánto tiempo deben conservarse los datos y qué debe ocurrir cuando termina su periodo de conservación.

La política es administrativa porque define obligaciones y procedimientos.

Su aplicación puede apoyarse en mecanismos técnicos de eliminación, anonimización o revisión de registros.

**3. Cifrado de datos — Control técnico**

El cifrado utiliza mecanismos criptográficos para proteger la información.

Durante el LAB-02 utilizamos funciones de PostgreSQL para cifrar un RFC ficticio.

La implementación del cifrado es técnica, aunque su utilización debe estar respaldada por decisiones y políticas de seguridad.

**4. Procedimiento para solicitudes ARCO — Control administrativo**

Establece cómo debe recibir, revisar, autorizar y atender la organización las solicitudes relacionadas con los derechos de acceso, rectificación, cancelación y oposición.

Se considera administrativo porque define responsabilidades y pasos organizacionales.

Su ejecución puede necesitar consultas SQL, modificaciones de registros y otros mecanismos técnicos.

**5. Vista con información limitada — Control técnico**

Las vistas de PostgreSQL permiten presentar únicamente determinados campos o registros.

Durante la Actividad 4 creamos `lab03.v_analitica_clientes` para proporcionar información limitada al rol `analista`.

Esta medida es técnica porque se implementa directamente en la base de datos.

**6. Clasificación de información — Control administrativo**

Consiste en establecer categorías para determinar qué información necesita protección y qué condiciones deben aplicarse a su tratamiento.

Es principalmente administrativa porque requiere criterios, responsabilidades y políticas de clasificación.

También puede apoyarse en herramientas técnicas que identifiquen o etiqueten los datos según su clasificación.

**7. Registro de auditoría — Control técnico y administrativo**

Es técnico porque requiere mecanismos que registren las operaciones realizadas sobre los sistemas y los datos.

También es administrativo porque la organización debe establecer qué actividades se registrarán, quién revisará los registros y cuánto tiempo deberán conservarse.

Ambos componentes son necesarios para que la auditoría resulte útil.

**8. Política de control de acceso — Control administrativo**

Define las reglas que determinan quién puede acceder a determinada información y bajo qué condiciones.

Es administrativa porque establece los criterios de autorización.

Su implementación puede realizarse mediante controles técnicos como roles, permisos y vistas.

### Análisis

Los controles técnicos y administrativos cumplen funciones diferentes, pero se complementan.

Las políticas permiten establecer qué debe protegerse, quién es responsable y cuáles son las condiciones de acceso.

Los mecanismos técnicos permiten aplicar determinadas restricciones dentro de los sistemas.

Por ejemplo, una política de mínimo privilegio establece que cada departamento debe consultar únicamente la información necesaria para sus funciones.

Posteriormente, el DBA puede implementar esa política mediante roles, vistas y permisos en PostgreSQL.

También se identificó que ciertas medidas, como el registro de auditoría, necesitan tanto herramientas tecnológicas como procedimientos organizacionales.

### Conclusión

Se comprendió que la protección de datos personales no depende únicamente de configuraciones técnicas.

Una organización necesita establecer políticas y responsabilidades claras, además de implementar los mecanismos tecnológicos correspondientes.

El DBA participa principalmente en la implementación y mantenimiento de los controles técnicos, pero debe trabajar de manera coordinada con las áreas responsables de privacidad, seguridad y cumplimiento.

## 15. Evaluación integral de privacidad

### Objetivo

Identificar los principales riesgos de privacidad y gobierno de datos en una organización que administra información de 50,000 clientes.

### Procedimiento

Se analizó el escenario presentado en el laboratorio y se elaboró una matriz de doce problemas o riesgos.

Para cada situación se identificó el principio de privacidad afectado, las posibles consecuencias y los controles propuestos.

### Resultados

Se identificaron riesgos relacionados con:

- Acceso excesivo a información personal.
- Falta de minimización para actividades de analítica.
- Consulta innecesaria de identificadores personales.
- Conservación de información sin una política documentada.
- Uso de datos reales en ambientes de desarrollo.
- Tratamientos secundarios que requieren evaluación.
- Falta de documentación sobre las finalidades de los datos.

Se propusieron controles como vistas, roles, permisos, estadísticas agregadas, bases de prueba con datos sintéticos y políticas de retención.

### Análisis

Los riesgos encontrados muestran que proteger una base de datos requiere algo más que implementar mecanismos técnicos.

También deben existir políticas que determinen qué información puede utilizar cada departamento y bajo qué condiciones.

La ausencia de documentación sobre finalidades y retención dificulta justificar el tratamiento de los datos personales.

### Conclusión

Se comprendió que la privacidad debe abordarse de manera integral, considerando los accesos, las finalidades, los ambientes de desarrollo y el ciclo de vida de la información.

El DBA debe colaborar en la identificación de riesgos y en la implementación de controles técnicos, trabajando con las áreas responsables de privacidad y cumplimiento.

### Evidencia

- [Matriz de evaluación integral de privacidad](evidencias/14-evaluacion-integral.md)

## 16. Propuesta de arquitectura de datos protegidos

### Objetivo

Diseñar una arquitectura conceptual que permita separar la información de una organización según su finalidad e incorporar mecanismos de privacidad, seguridad y gobierno de datos.

### Procedimiento

Se analizaron los requisitos de operación, analítica y auditoría presentados en el escenario del laboratorio.

Se propuso una arquitectura que distingue estas tres áreas y establece controles para acceso, minimización, protección de información sensible, retención, trazabilidad, eliminación y atención de solicitudes.

La propuesta tomó como referencia los mecanismos estudiados durante los tres laboratorios.

### Resultados

Se elaboró una arquitectura conceptual organizada en tres áreas principales:

- Operación, destinada a los procesos de atención al cliente y facturación.
- Analítica, orientada a estadísticas y resultados agregados.
- Auditoría, propuesta para registrar y revisar operaciones relevantes.

También se identificaron controles técnicos y administrativos necesarios para proteger la información durante su ciclo de vida.

### Análisis

La separación de datos por finalidad permite reducir la exposición innecesaria y relacionar los permisos con las funciones de cada departamento.

Los controles técnicos de PostgreSQL deben complementarse con políticas de retención, procedimientos para derechos ARCO y responsabilidades organizacionales.

La arquitectura presentada es conceptual. No todos sus componentes fueron implementados físicamente durante el laboratorio.

### Conclusión

La actividad permitió integrar los conocimientos adquiridos sobre privacidad, seguridad y gobierno de datos.

Se comprendió que una arquitectura protegida requiere considerar tanto los mecanismos técnicos como las finalidades y responsabilidades relacionadas con la información.

### Evidencia

- [Propuesta de arquitectura de datos protegidos](evidencias/15-arquitectura.md)
