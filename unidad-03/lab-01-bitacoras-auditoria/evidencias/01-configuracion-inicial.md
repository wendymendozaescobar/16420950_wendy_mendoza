# Actividad 1 — Revisar la configuración de registro por defecto

## Objetivo

Identificar los parámetros de registro de PostgreSQL y analizar qué información se almacena en las bitácoras con la configuración inicial del servidor.

## Entorno

- Sistema operativo: Ubuntu.
- PostgreSQL: 18.6.
- Puerto: `5433`.
- Base de datos: `comercial`.
- Tipo de sesión: administrador (`postgres`).

## Comando utilizado

```sql
SELECT
    name,
    setting,
    source
FROM pg_settings
WHERE name IN (
    'log_destination',
    'logging_collector',
    'log_directory',
    'log_filename',
    'log_connections',
    'log_disconnections',
    'log_line_prefix',
    'log_statement',
    'log_min_error_statement',
    'log_timezone'
)
ORDER BY name;
```

## Resultados obtenidos

| Parámetro | Valor | Origen |
|---|---|---|
| `log_connections` | Cadena vacía | `default` |
| `log_destination` | `stderr` | `default` |
| `log_directory` | `log` | `default` |
| `log_disconnections` | `off` | `default` |
| `log_filename` | `postgresql-%Y-%m-%d_%H%M%S.log` | `default` |
| `logging_collector` | `off` | `default` |
| `log_line_prefix` | `%m [%p] %q%u@%d` | `configuration file` |
| `log_min_error_statement` | `error` | `default` |
| `log_statement` | `none` | `default` |
| `log_timezone` | `America/Denver` | `configuration file` |

## Preguntas de análisis

### 1. Con esta configuración, ¿se registra quién se conecta?

No se encuentra habilitado el registro habitual de conexiones exitosas, porque `log_connections` tiene una cadena vacía como valor.

En PostgreSQL 18, este valor desactiva las opciones de registro de conexiones, aunque los fallos de autenticación siguen registrándose.

Por lo tanto, la configuración inicial no proporciona un historial completo de conexiones exitosas.

### 2. ¿Se registran las sentencias UPDATE?

Las sentencias `UPDATE` ejecutadas correctamente no se registran automáticamente mediante `log_statement`, porque este parámetro tiene el valor `none`.

Sin embargo, las sentencias que producen determinados errores pueden aparecer en la bitácora debido a la configuración de `log_min_error_statement = error`.

Para registrar las modificaciones de datos de manera sistemática será necesario configurar mecanismos adicionales de registro o auditoría.

### 3. ¿La línea de bitácora incluye el usuario o la dirección IP del cliente?

El parámetro `log_line_prefix` tiene el valor `%m [%p] %q%u@%d`.

En este formato:

- `%m` representa la marca de tiempo.
- `%p` representa el identificador del proceso.
- `%q` controla el procesamiento del resto del prefijo en procesos que no pertenecen a una sesión.
- `%u` representa el usuario.
- `%d` representa la base de datos.

Por lo tanto, el prefijo permite identificar el usuario y la base de datos cuando esa información está disponible.

Sin embargo, no incluye explícitamente la dirección IP del cliente, ya que no utiliza identificadores como `%h` o `%r`.

### 4. ¿En qué zona horaria se registran los eventos? ¿Por qué importa al reconstruir una cronología?

El parámetro `log_timezone` tiene configurado `America/Denver`.

Esto significa que PostgreSQL utiliza esa zona horaria para las marcas de tiempo de sus registros.

La zona horaria es importante porque permite ordenar correctamente los eventos e identificar cuándo ocurrió una conexión, una modificación o un error.

Al investigar un incidente, pueden existir registros provenientes de sistemas con zonas horarias diferentes.

Por esta razón, es necesario conocer las zonas horarias y considerar sus diferencias para reconstruir una cronología confiable.

### 5. Con `logging_collector = off`, ¿quién decide dónde termina la bitácora: PostgreSQL o el mecanismo con que se desplegó el servidor?

Cuando `logging_collector` está desactivado y `log_destination` utiliza `stderr`, PostgreSQL envía los mensajes a su salida estándar de errores.

En estas condiciones, el mecanismo que inicia y administra el servicio puede encargarse de redirigir o conservar esos mensajes.

En nuestro entorno Ubuntu, es necesario identificar cómo está configurado el servicio para conocer el destino efectivo de los registros.

Por lo tanto, el destino final no lo determina el colector interno de PostgreSQL.

## Interpretación

La configuración inicial permite registrar errores del servidor, pero presenta limitaciones para reconstruir completamente la actividad de los usuarios.

No está habilitado el registro habitual de conexiones exitosas y tampoco se registran sistemáticamente las sentencias SQL mediante `log_statement`.

El prefijo identifica el usuario y la base de datos, pero no incluye explícitamente la dirección IP del cliente.

Además, el colector de PostgreSQL está desactivado, por lo que debemos investigar cómo se conservan actualmente los registros.

Estos resultados justifican las siguientes actividades, en las que configuraremos la bitácora para obtener información más útil durante una auditoría.

## Conclusión

Se identificaron diez parámetros de registro y se analizaron sus valores iniciales.

La actividad permitió comprender que PostgreSQL no registra automáticamente todos los eventos necesarios para investigar un incidente.

También se identificaron diferencias entre PostgreSQL 16 y PostgreSQL 18 relacionadas con el parámetro `log_connections`.

No se modificó la configuración del servidor durante esta actividad.
