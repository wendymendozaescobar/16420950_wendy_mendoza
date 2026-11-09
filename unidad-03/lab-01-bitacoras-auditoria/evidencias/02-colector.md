# Actividad 2 — Que el servidor administre su propia bitácora

## Objetivo

Activar el colector de bitácoras de PostgreSQL y consultar los registros del servidor mediante SQL, implementando una vista administrativa de acceso restringido.

## Entorno

- Sistema operativo: Ubuntu.
- PostgreSQL: 18.6.
- Puerto: `5433`.
- Base de datos: `comercial`.
- Usuario administrador: `postgres`.

## Procedimiento

### 1. Respaldo de la configuración

Antes de modificar el servidor, se respaldaron los archivos:

- `postgresql.conf`
- `pg_hba.conf`
- `pg_ident.conf`
- `postgresql.auto.conf`

Los respaldos se conservaron fuera del repositorio, en `/var/backups/postgresql18-lab01/`.

### 2. Activación del colector

Se ejecutó:

`ALTER SYSTEM SET logging_collector = on;`

Posteriormente, se recargó la configuración mediante `pg_reload_conf()`.

La consulta a `pg_settings` mostró que el parámetro conservaba temporalmente el valor `off` y presentaba `pending_restart = true`.

Esto confirmó que el cambio requería reiniciar PostgreSQL.

### 3. Reinicio y verificación

Se reinició únicamente el servicio `postgresql@18-main`.

Después del reinicio se obtuvieron los siguientes resultados:

| Parámetro | Resultado |
|---|---|
| Servicio PostgreSQL 18 | `active` |
| Puerto | `5433` |
| `logging_collector` | `on` |
| `source` | `configuration file` |
| `pending_restart` | `false` |

Se comprobó que el servidor volvió a funcionar correctamente.

### 4. Identificación del archivo de bitácora

Se utilizó la función `pg_current_logfile()`.

El resultado fue:

`log/postgresql-2026-11-08_213800.log`

El archivo se encuentra dentro del directorio de datos del servidor PostgreSQL 18.

### 5. Lectura de la bitácora mediante SQL

Se utilizaron las funciones `pg_read_file()` y `regexp_split_to_table()` para consultar el contenido del archivo.

Entre los eventos identificados aparecieron:

- Inicio de PostgreSQL 18.6.
- Escucha en `127.0.0.1:5433`.
- Escucha mediante socket Unix.
- Confirmación de que el servidor estaba listo para aceptar conexiones.
- Eventos posteriores relacionados con checkpoints.

Esto confirmó que el colector estaba registrando eventos del servidor.

### 6. Creación de la vista administrativa

Se creó el esquema `dba` y se restringieron los privilegios de acceso otorgados a `PUBLIC`.

Posteriormente, se creó la vista `dba.bitacora`, que permite consultar las líneas del archivo vigente mediante SQL.

La vista utiliza `WITH ORDINALITY` para identificar el número de cada línea.

Se comprobó que la vista funciona correctamente.

### 7. Verificación de permisos

Se comprobaron los permisos de los usuarios `app_ventas` y `soporte_ana`.

| Usuario | Acceso al esquema | Permiso SELECT |
|---|---|---|
| `app_ventas` | `false` | `false` |
| `soporte_ana` | `false` | `false` |

Los resultados confirmaron que ninguno de los dos roles dispone de acceso a la vista administrativa.

### 8. Búsqueda de eventos

Se realizaron consultas para buscar operaciones `UPDATE` y mensajes de error.

La búsqueda de `UPDATE` devolvió cero filas.

La búsqueda de `FATAL` o `ERROR` devolvió dos líneas: un mensaje relacionado con un error de sintaxis y una línea de contexto de la sentencia SQL.

El error se había generado al ejecutar incorrectamente el operador `ILIKE` como una instrucción independiente.

Esta comprobación permitió demostrar que PostgreSQL registra errores y que la vista administrativa permite localizarlos.

## Preguntas de análisis

### 1. ¿Por qué `logging_collector` requiere reinicio y `log_statement` solo recarga?

Porque `logging_collector` controla el proceso encargado de recopilar y escribir los registros del servidor.

PostgreSQL necesita iniciar este proceso al arrancar, por lo que modificar ese parámetro requiere reiniciar el servicio.

En cambio, `log_statement` determina qué sentencias SQL se registran. Su valor puede actualizarse mediante una recarga de configuración, sin necesidad de reiniciar todo el servidor.

Esto demuestra que no todos los parámetros de PostgreSQL tienen los mismos requisitos de aplicación.

### 2. ¿Qué ventaja tiene que la bitácora se lea con SQL y no con una herramienta del sistema operativo o del contenedor? ¿Qué riesgo introduce?

La principal ventaja es que podemos utilizar SQL para consultar, filtrar y analizar los eventos registrados.

Por ejemplo, podemos buscar errores, identificar operaciones específicas y ordenar los resultados sin utilizar directamente herramientas del sistema operativo.

Esto facilita la investigación de incidentes desde PostgreSQL.

Sin embargo, también introduce un riesgo de seguridad.

La función `pg_read_file()` permite leer archivos del servidor y puede exponer información sensible si se utiliza sin restricciones.

Además, leer archivos muy grandes directamente mediante SQL puede consumir recursos del servidor.

Por ello, la vista debe mantenerse restringida a usuarios administrativos autorizados.

### 3. ¿Quién debería poder consultar `dba.bitacora`?

Considero que solamente los administradores de bases de datos y el personal expresamente autorizado para realizar auditorías deberían consultar esta vista.

Las bitácoras pueden contener nombres de usuarios, sentencias SQL, errores y otra información relacionada con el funcionamiento interno del servidor.

No es necesario que una aplicación de ventas o un usuario de soporte tenga acceso a esos registros para realizar sus actividades habituales.

Durante la práctica comprobamos que `app_ventas` y `soporte_ana` no disponen de privilegios para acceder a la vista.

Esto corresponde al principio de mínimo privilegio.

## Conclusión

La actividad permitió activar correctamente el colector de bitácoras de PostgreSQL y comprobar su funcionamiento después de reiniciar el servicio.

También se identificó el archivo de registro vigente y se consultó su contenido mediante SQL.

Se creó la vista `dba.bitacora`, que facilita las consultas administrativas, y se verificó que los usuarios normales no tienen permisos de acceso.

Finalmente, se comprobó que PostgreSQL registra errores de sintaxis y que estos pueden identificarse en los registros del servidor.

La práctica permitió comprender la utilidad de las bitácoras para investigar eventos y la importancia de proteger su acceso.

## Archivo SQL

[01-colector-y-vista.sql](../sql/01-colector-y-vista.sql)
