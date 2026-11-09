# Actividad 4 — Configurar la bitácora

## Objetivo

Configurar PostgreSQL para registrar información relacionada con las conexiones, desconexiones y sentencias DDL, utilizando un formato que facilite la identificación de los eventos.

## Entorno de trabajo

- Sistema operativo: Ubuntu.
- PostgreSQL: 18.6.
- Puerto: `5433`.
- Base de datos: `comercial`.
- Usuario administrador: `postgres`.

## 1. Configuración de la bitácora

Se utilizaron instrucciones `ALTER SYSTEM` para modificar los siguientes parámetros:

| Parámetro | Valor configurado |
|---|---|
| `log_connections` | `on` |
| `log_disconnections` | `on` |
| `log_line_prefix` | `%m [%p] user=%u db=%d app=%a client=%h ` |
| `log_statement` | `ddl` |

Los cambios quedaron almacenados en:

`/var/lib/postgresql/18/main/postgresql.auto.conf`

Posteriormente, se ejecutó `SELECT pg_reload_conf();` para solicitar la recarga de configuración.

El resultado fue `true`.

## 2. Verificación de los parámetros

Durante la primera consulta, `log_connections` y `log_disconnections` todavía mostraban sus valores anteriores.

Al revisar la columna `context`, se identificó que ambos parámetros tienen el contexto `superuser-backend`.

Por ello, se cerró la sesión y se estableció una nueva conexión con PostgreSQL.

La segunda verificación mostró:

| Parámetro | Resultado | Reinicio pendiente |
|---|---|---|
| `log_connections` | `on` | No |
| `log_disconnections` | `on` | No |
| `log_line_prefix` | Nuevo formato | No |
| `log_statement` | `ddl` | No |

Todos los parámetros tenían como origen `configuration file`.

No fue necesario reiniciar el servicio PostgreSQL.

## 3. Comprobación de conexiones

Se consultaron los eventos recientes mediante la vista `dba.bitacora`.

Se encontraron registros de:

- Conexión recibida.
- Autenticación exitosa.
- Conexión autorizada.

Las líneas permitieron identificar el usuario `postgres`, la base de datos `comercial` y el origen local de la conexión.

Se comprobó que el nuevo formato incorpora información útil para relacionar eventos y sesiones.

## 4. Comprobación de desconexiones

Para comprobar el funcionamiento de `log_disconnections`, se cerró una sesión de PostgreSQL y posteriormente se consultó la bitácora.

Se encontró un evento con los siguientes datos:

| Campo | Resultado |
|---|---|
| Fecha | 2026-11-08 |
| Hora registrada | 22:32:09.223 MST |
| Proceso | `9072` |
| Usuario | `postgres` |
| Base de datos | `comercial` |
| Aplicación | `psql` |
| Cliente | `[local]` |
| Duración | `0:03:42.958` |

Esto confirmó que PostgreSQL registró la finalización de la sesión y su duración.

## Preguntas de análisis

### 1. ¿Por qué el proceso que registra el cambio es el principal y no tu sesión?

Al ejecutar `ALTER SYSTEM`, la sesión administrativa solicita una modificación de los parámetros del servidor.

La recarga posterior es procesada por PostgreSQL, y el proceso principal puede registrar los cambios de configuración que afectan al funcionamiento general de la instancia.

En nuestra bitácora se observaron mensajes de cambios de parámetros emitidos por un proceso diferente del utilizado por nuestra sesión.

Esto ocurre porque determinadas tareas de administración de la configuración corresponden al servidor y no únicamente a la sesión que solicitó el cambio.

### 2. ¿Qué pasaría si alguien ejecutara `ALTER SYSTEM SET log_statement = 'none'`? ¿Quedaría rastro?

El parámetro `log_statement` dejaría de registrar las sentencias SQL según las categorías que estuvieran habilitadas anteriormente.

Si el cambio se realiza mientras `log_statement = 'ddl'`, la propia instrucción `ALTER SYSTEM` puede quedar registrada antes de que el nuevo valor entre en vigor.

También puede aparecer un mensaje del servidor indicando el cambio del parámetro durante la recarga.

Sin embargo, esto no garantiza que exista un historial completo e inalterable.

Un administrador con privilegios suficientes podría modificar la configuración o afectar la conservación de los registros.

Por eso es importante proteger las bitácoras, restringir el acceso administrativo y mantener mecanismos de conservación independientes cuando se necesite una auditoría confiable.

### 3. ¿Por qué no se recomienda editar `postgresql.auto.conf` a mano?

Porque `postgresql.auto.conf` es el archivo que PostgreSQL utiliza para almacenar los cambios realizados mediante `ALTER SYSTEM`.

Editar este archivo manualmente puede provocar errores de sintaxis, configuraciones inconsistentes o conflictos con cambios posteriores.

Además, podríamos modificar un parámetro sin seguir un procedimiento controlado de verificación.

La alternativa recomendada es utilizar los mecanismos de configuración de PostgreSQL y comprobar el resultado mediante `pg_settings`.

También es importante conservar respaldos antes de realizar modificaciones.

## Análisis

La actividad permitió comprobar que los parámetros de registro tienen diferentes contextos de aplicación.

Los parámetros `log_connections` y `log_disconnections` se aplicaron a las nuevas sesiones, mientras que otros cambios pudieron observarse después de recargar la configuración.

También se comprobó la importancia de utilizar un prefijo que identifique usuarios, bases de datos, aplicaciones y clientes.

La bitácora comenzó a registrar conexiones autorizadas y desconexiones con información suficiente para relacionar determinados eventos.

Sin embargo, `log_statement = 'ddl'` todavía no permite registrar sistemáticamente las modificaciones de datos realizadas mediante `UPDATE`.

## Conclusión

Se configuraron correctamente los cuatro parámetros de registro solicitados.

Se comprobó que PostgreSQL registra conexiones, autenticaciones y desconexiones, incluyendo información sobre los usuarios y la duración de las sesiones.

Además, se identificó que los cambios de configuración deben aplicarse según el contexto de cada parámetro.

La actividad permitió comprender que una bitácora útil requiere una configuración adecuada y mecanismos para proteger su contenido.

## Archivo SQL

[02-configuracion-bitacora.sql](../sql/02-configuracion-bitacora.sql)
