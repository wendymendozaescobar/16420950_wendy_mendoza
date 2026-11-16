# Actividad 9 — Sesiones activas con pg_stat_activity

## Objetivo

Identificar las sesiones activas de PostgreSQL mediante `pg_stat_activity` y relacionarlas con los eventos registrados en la bitácora del servidor.

También se busca comprobar qué información permanece disponible después de que una sesión finaliza.

## Entorno de trabajo

- Sistema operativo: Ubuntu.
- PostgreSQL: 18.6.
- Puerto: `5433`.
- Base de datos: `comercial`.
- Usuario del reporte: `soporte_ana`.
- Usuario administrador: `postgres`.
- Aplicación del reporte: `reporte-mensual`.
- Dirección del cliente: `127.0.0.1`.

## 1. Simulación de un reporte de larga duración

Se utilizaron dos terminales para realizar la práctica.

En la primera terminal se estableció una conexión a PostgreSQL mediante el usuario `soporte_ana`.

Se ejecutó la siguiente consulta:

```sql
SELECT pg_sleep(90);
```

La función `pg_sleep(90)` mantiene una consulta en ejecución durante aproximadamente 90 segundos, sin modificar los datos de las tablas.

Se utilizó el nombre de aplicación `reporte-mensual` para facilitar la identificación de la sesión.

## 2. Identificación de la sesión activa

Mientras se ejecutaba el reporte, en la segunda terminal se consultó `pg_stat_activity` utilizando el usuario administrador `postgres`.

La consulta utilizada fue:

```sql
SELECT
    pid,
    usename,
    application_name,
    client_addr,
    state,
    LEFT(query, 50) AS consulta
FROM pg_stat_activity
WHERE usename = 'soporte_ana';
```

Se obtuvo el siguiente resultado:

| Campo | Resultado |
|---|---|
| `pid` | `6468` |
| `usename` | `soporte_ana` |
| `application_name` | `reporte-mensual` |
| `client_addr` | `127.0.0.1` |
| `state` | `active` |
| `consulta` | `SELECT pg_sleep(90);` |

Esto confirmó que PostgreSQL permitía identificar la consulta mientras permanecía en ejecución.

## 3. Relación entre la sesión y la bitácora

Se utilizó el PID `6468` para buscar los eventos correspondientes en la vista `dba.bitacora`.

La consulta fue:

```sql
SELECT
    num,
    LEFT(linea, 250) AS evento
FROM dba.bitacora
WHERE linea LIKE '%[6468]%'
ORDER BY num;
```

Durante la ejecución del reporte se encontraron tres eventos:

| Registro | Evento |
|---|---|
| 42 | Conexión recibida |
| 43 | Conexión autenticada |
| 44 | Conexión autorizada |

Los registros permitieron identificar al usuario `soporte_ana`, la base de datos `comercial` y la dirección `127.0.0.1`.

También se identificó el método de autenticación `scram-sha-256` y el uso de TLS 1.3.

## 4. Comprobación después de finalizar el reporte

Cuando terminó la ejecución de `pg_sleep(90)`, se consultó nuevamente `pg_stat_activity`.

```sql
SELECT
    pid,
    usename,
    application_name,
    client_addr,
    state,
    LEFT(query, 50) AS consulta
FROM pg_stat_activity
WHERE pid = 6468;
```

El resultado fue:

```text
(0 filas)
```

Esto confirmó que la sesión del proceso `6468` había finalizado y ya no aparecía en la vista de actividad.

## 5. Evidencia histórica de la sesión

Se volvió a consultar la bitácora utilizando el mismo PID.

En esta ocasión se encontraron cuatro registros:

| Registro | Evento |
|---|---|
| 42 | Conexión recibida |
| 43 | Conexión autenticada |
| 44 | Conexión autorizada |
| 45 | Desconexión |

El registro de desconexión mostró:

- Fecha: 16 de noviembre de 2026.
- Hora: 14:15:00.059 MST.
- PID: `6468`.
- Usuario: `soporte_ana`.
- Base de datos: `comercial`.
- Aplicación: `reporte-mensual`.
- Dirección del cliente: `127.0.0.1`.
- Duración de la sesión: `0:01:30.054`.

Esto confirmó que la bitácora conservaba evidencia de la sesión después de que desapareció de `pg_stat_activity`.

## Preguntas de análisis

### 1. ¿Qué columna permite relacionar una sesión con sus líneas de bitácora?

La columna `pid` de `pg_stat_activity` permite relacionar una sesión con los eventos registrados en la bitácora.

Cada sesión atendida por un proceso de PostgreSQL tiene un identificador de proceso.

En esta práctica identificamos el PID `6468` en `pg_stat_activity` y posteriormente utilizamos ese mismo número para localizar sus registros históricos.

Esto permitió relacionar los eventos de conexión, autenticación, autorización y desconexión con la sesión observada.

### 2. Después de que termina el reporte, ¿qué fuente conserva evidencia de que existió?

La bitácora del servidor conserva los eventos registrados durante la sesión.

En cambio, `pg_stat_activity` solamente muestra las sesiones que existen en ese momento.

Al finalizar el reporte comprobamos que el PID `6468` ya no aparecía en `pg_stat_activity`.

Sin embargo, al consultar `dba.bitacora`, encontramos los registros correspondientes a la conexión y desconexión del usuario.

Esto demuestra que la bitácora es una fuente útil de información histórica, siempre que los archivos correspondientes se conserven.

### 3. ¿Por qué client_addr aparece vacío en la sesión del administrador?

Porque el administrador `postgres` se conectó mediante un socket Unix local.

La conexión se realizó con:

```bash
sudo -u postgres psql -p 5433 -d comercial
```

En este caso, PostgreSQL no utiliza una conexión TCP con una dirección IP de cliente.

Por ello, `client_addr` aparece como `NULL` o vacío.

En cambio, `soporte_ana` se conectó mediante TCP utilizando `127.0.0.1`, por lo que esa dirección apareció en la columna `client_addr`.

Esto permite diferenciar una conexión local mediante socket Unix de una conexión TCP.

## Análisis

La actividad permitió comparar dos mecanismos de observación de PostgreSQL.

`pg_stat_activity` proporciona información sobre las sesiones existentes y las consultas que se están ejecutando.

Por otra parte, la bitácora permite consultar eventos históricos como conexiones, autenticaciones y desconexiones.

Durante la práctica se comprobó que ambos mecanismos pueden relacionarse mediante el PID de la sesión.

Sin embargo, debido a que `log_statement` estaba configurado como `mod`, la sentencia `SELECT pg_sleep(90)` no se registró como una sentencia SQL. Su ejecución pudo observarse directamente mediante `pg_stat_activity`.

## Conclusión

Se logró identificar una sesión activa de PostgreSQL correspondiente al usuario `soporte_ana`, que ejecutaba un reporte simulado mediante `pg_sleep(90)`.

Se utilizó el PID `6468` para relacionar la sesión con sus eventos de bitácora.

Después de finalizar el reporte, se confirmó que la sesión desapareció de `pg_stat_activity`, mientras que sus registros históricos continuaron disponibles.

La actividad permitió comprender que el monitoreo en tiempo real y la auditoría histórica son mecanismos complementarios para administrar e investigar el comportamiento de una base de datos.
