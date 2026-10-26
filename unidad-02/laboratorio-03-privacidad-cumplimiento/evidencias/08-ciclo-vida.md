# Actividad 8. Derecho de cancelación y ciclo de vida de los datos

## Objetivo

Analizar las implicaciones técnicas de una solicitud de cancelación de datos personales e identificar los lugares donde podría conservarse información relacionada con un titular.

## Procedimiento

Se analizó el escenario de una solicitud de cancelación previamente autorizada por el área responsable.

Antes de realizar cualquier eliminación, se identificaron las estructuras de datos relacionadas con los clientes y se consideraron otras posibles ubicaciones de la información, como respaldos, réplicas, reportes, exportaciones y sistemas externos.

También se relacionó el escenario con las tablas utilizadas durante los laboratorios anteriores.

No se ejecutaron instrucciones `DELETE` ni se eliminaron registros de PostgreSQL.

## Resultado obtenido

### Mapa del ciclo de vida de los datos

```text
                    public.clientes
                          |
          +---------------+----------------+
          |               |                |
          v               v                v
 lab03.clientes_soporte   LAB-01       Otros componentes
          |               |              posibles
          |               v                |
          |       analitica.clientes       +-- Respaldos
          |               |                +-- Réplicas
          |               v                +-- Reportes
          |        pii.mapa_cliente        +-- Exportaciones
          |                                +-- Auditoría
          |                                +-- Sistemas externos
          |
          v
   Datos de contacto
   utilizados por soporte
```

Las tablas `public.clientes`, `lab03.clientes_soporte`, `analitica.clientes` y `pii.mapa_cliente` corresponden a estructuras creadas durante los laboratorios.

Los respaldos, réplicas, reportes, exportaciones, registros de auditoría y sistemas externos representan ubicaciones adicionales que deberían investigarse. Su existencia no fue verificada en esta actividad.

### Análisis de los posibles lugares donde se conserva la información

| Elemento | Riesgo identificado | Consideración técnica |
|---|---|---|
| Tablas relacionadas | La información puede permanecer en otras tablas. | Identificar las relaciones y dependencias antes de eliminar registros. |
| Respaldos | Las copias antiguas pueden conservar datos eliminados de producción. | Revisar las políticas de retención y restauración de respaldos. |
| Réplicas | Pueden existir otras instancias que conserven información. | Comprobar los mecanismos de replicación y propagación de cambios. |
| Registros de auditoría | Pueden contener referencias a datos o modificaciones anteriores. | Evaluar su contenido y las obligaciones aplicables de conservación. |
| Copias de analítica | Pueden conservar atributos personales o seudonimizados. | Identificar los datos relacionados y evaluar su necesidad. |
| Exportaciones | Los datos pueden encontrarse en archivos fuera de PostgreSQL. | Localizar exportaciones y establecer procedimientos para su tratamiento. |
| Sistemas externos | Otras aplicaciones podrían conservar copias de los datos. | Identificar integraciones y coordinar las acciones correspondientes. |

### Pregunta de análisis

**¿Por qué eliminar un registro de una tabla no necesariamente significa que toda la información relacionada con esa persona haya desaparecido de la organización?**

Porque una organización puede almacenar o reproducir información en diferentes tablas, sistemas y archivos.

Por ejemplo, durante el LAB-03 se creó `lab03.clientes_soporte` utilizando información procedente de `public.clientes`.

Si se eliminara un registro únicamente de `public.clientes`, no se eliminaría automáticamente su copia en la tabla de soporte.

También podrían existir respaldos, réplicas, reportes o exportaciones que conservaran información relacionada con el titular.

La seudonimización tampoco garantiza que la información deje de ser personal cuando todavía existe un mecanismo para relacionarla con el cliente original.

Por esta razón, una solicitud de cancelación requiere identificar dónde se encuentran los datos, determinar qué acciones proceden y coordinar su ejecución.

La cancelación no siempre implica una eliminación física inmediata de toda la información. Dependiendo de las obligaciones aplicables, podrían requerirse otras medidas, como restricciones de tratamiento o conservación justificada.

## Análisis

La actividad permitió comprender que el ciclo de vida de los datos abarca diferentes etapas, desde su recopilación hasta su eliminación o conservación justificada.

La administración de bases de datos no debe limitarse a ejecutar instrucciones SQL.

Un DBA necesita conocer las dependencias entre tablas, las copias de información y los mecanismos de almacenamiento utilizados por la organización.

También debe coordinarse con las áreas responsables de privacidad y cumplimiento para determinar qué información debe eliminarse, restringirse o conservarse.

En nuestro laboratorio, las tablas `public.clientes` y `lab03.clientes_soporte` muestran cómo una misma información puede existir en diferentes estructuras.

Por ello, antes de ejecutar una operación de eliminación, resulta necesario analizar las consecuencias sobre los datos relacionados.

### Comprobación de consistencia entre tablas

Durante la revisión final del laboratorio se comprobó que el cliente con `id = 1` tiene el correo `nuevo-correo@example.com` en `public.clientes`, mientras que `lab03.clientes_soporte` conserva `ana.lopez@example.test`.

Esto ocurre porque la tabla de soporte se pobló mediante `INSERT ... SELECT` y no cuenta con un mecanismo de sincronización automática.

La comprobación demuestra que una modificación realizada sobre la tabla principal no necesariamente se refleja en otras copias de los datos.

Por lo tanto, antes de atender completamente una solicitud de rectificación o cancelación, deben identificarse las estructuras relacionadas y definirse las acciones correspondientes.

La comprobación se realizó mediante una consulta `SELECT` y no modificó los registros.

## Conclusión

Se identificó que eliminar un registro de una tabla no garantiza la eliminación de todas las copias relacionadas con una persona.

La atención de una solicitud de cancelación requiere conocer dónde se almacena la información y cómo circula entre los sistemas.

También se comprendió que el DBA debe implementar técnicamente las decisiones autorizadas, considerando las relaciones entre datos, los mecanismos de respaldo y las obligaciones de conservación.

Durante esta actividad no se modificó ni eliminó información de PostgreSQL.
