# Actividad 5 — Accesos exitosos y fallidos

## Objetivo

Generar intentos de conexión exitosos y fallidos en PostgreSQL para comprobar qué información se registra en la bitácora del servidor y cómo puede utilizarse para investigar posibles incidentes de seguridad.

## Entorno de trabajo

| Elemento | Configuración |
|---|---|
| Sistema operativo | Ubuntu |
| PostgreSQL | 18.6 |
| Puerto | `5433` |
| Base de datos | `comercial` |
| Dirección del cliente | `127.0.0.1` |
| Método de autenticación | `scram-sha-256` |

## 1. Pruebas realizadas

Se realizaron tres intentos de conexión mediante TCP.

### Prueba 1. Contraseña incorrecta

Se intentó establecer una conexión utilizando el usuario `app_ventas` y una contraseña incorrecta.

PostgreSQL rechazó la conexión y devolvió un error de autenticación.

La bitácora registró un evento `FATAL` asociado con el usuario `app_ventas`.

### Prueba 2. Usuario inexistente

Se intentó establecer una conexión utilizando el nombre `usuario_inexistente`.

La conexión fue rechazada.

En la bitácora se encontraron dos mensajes importantes:

- `FATAL`: la autenticación por contraseña falló.
- `DETALLE`: el rol `usuario_inexistente` no existe.

Esto permitió comprobar que PostgreSQL conserva información adicional sobre el motivo del rechazo.

### Prueba 3. Conexión exitosa

Se realizó una conexión utilizando las credenciales correctas de `app_ventas`.

La consulta ejecutada fue:

```sql
SELECT count(*) FROM clientes;
```

El resultado fue:

```text
count
-----
5
```

La bitácora registró la recepción de la conexión, la autenticación, la autorización y la desconexión.

También se identificó el nombre de la aplicación `app-ventas-web`.

## 2. Consulta de la bitácora

Se utilizó la vista administrativa `dba.bitacora` para localizar las conexiones realizadas desde `127.0.0.1`.

```sql
SELECT
    num,
    LEFT(linea, 220) AS evento
FROM dba.bitacora
WHERE linea LIKE '%client=127.0.0.1%'
ORDER BY num DESC
LIMIT 30;
```

La consulta permitió identificar los eventos relacionados con las tres pruebas.

## 3. Interpretación de los registros

En la conexión fallida del usuario `app_ventas` se observó la siguiente información:

| Campo | Valor observado | Significado |
|---|---|---|
| Fecha | 2026-11-08 | Día del intento |
| Hora | 22:39:17.496 MST | Momento registrado |
| PID | `9375` | Identificador del proceso |
| Usuario | `app_ventas` | Nombre de usuario solicitado |
| Base de datos | `comercial` | Base de datos solicitada |
| Aplicación | `[desconocido]` | Aplicación no identificada |
| Cliente | `127.0.0.1` | Dirección de origen |
| Severidad | `FATAL` | Error que impidió establecer la sesión |
| Mensaje | Autenticación fallida | Motivo del rechazo |

La bitácora también identificó la regla de `pg_hba.conf` utilizada para comprobar la autenticación.

En la conexión exitosa se observó que el método de autenticación fue `scram-sha-256` y que la aplicación utilizada se identificó como `app-ventas-web`.

## 4. Conteo de intentos fallidos

Se ejecutó la siguiente consulta:

```sql
SELECT
    split_part(
        split_part(linea, 'user=', 2),
        ' ',
        1
    ) AS usuario,
    COUNT(*) AS intentos_fallidos
FROM dba.bitacora
WHERE linea LIKE '%FATAL:%'
  AND linea LIKE '%client=127.0.0.1%'
GROUP BY usuario
ORDER BY intentos_fallidos DESC;
```

### Resultado

| Usuario | Eventos FATAL |
|---|---:|
| `app_ventas` | 1 |
| `usuario_inexistente` | 1 |
| **Total** | **2** |

En esta prueba, ambos eventos `FATAL` correspondieron a intentos de autenticación fallidos.

Sin embargo, la consulta cuenta todos los eventos `FATAL` que coinciden con el origen indicado. En un entorno real sería necesario filtrar específicamente los errores de autenticación y establecer un intervalo de tiempo.

## Preguntas de análisis

### 1. La bitácora registra el usuario `app_ventas` en el intento fallido. ¿Eso prueba que la aplicación de ventas intentó entrar? ¿Qué prueba realmente?

No demuestra necesariamente que la aplicación de ventas haya intentado conectarse.

Lo que realmente demuestra es que se recibió un intento de autenticación utilizando el nombre de usuario `app_ventas`.

Cualquier persona que conozca ese nombre podría intentar utilizarlo.

Por lo tanto, el registro permite identificar la cuenta solicitada, pero no demuestra por sí solo la identidad de la persona o aplicación que originó el intento.

### 2. ¿Qué información adicional registra PostgreSQL cuando el rol no existe? ¿Por qué aparece en la bitácora y no en el mensaje que recibe el cliente?

PostgreSQL registra información adicional indicando que el rol solicitado no existe.

En nuestra prueba apareció el mensaje:

`DETALLE: No existe el rol «usuario_inexistente».`

Esta información resulta útil para los administradores, porque permite distinguir entre una contraseña incorrecta y un intento de utilizar un usuario inexistente.

Sin embargo, PostgreSQL no revela necesariamente ese detalle al cliente.

Esto evita facilitar información sobre qué usuarios existen en el sistema, reduciendo las posibilidades de enumeración de cuentas por parte de un atacante.

### 3. ¿Por qué aparece `app=[unknown]` en el intento fallido, pero `app=app-ventas-web` en la desconexión?

Durante un intento fallido de autenticación, la conexión puede terminar antes de que PostgreSQL reciba o establezca el nombre de la aplicación.

Por ello, el registro puede mostrar el valor `[unknown]` o `[desconocido]`.

En cambio, cuando la autenticación se completa correctamente, PostgreSQL puede identificar la aplicación indicada por el cliente mediante el parámetro `application_name`.

En nuestra prueba exitosa se utilizó `app-ventas-web`, y ese nombre apareció en el registro de desconexión.

Es importante recordar que `application_name` es un dato proporcionado por el cliente y no constituye una prueba de identidad por sí mismo.

### 4. ¿Qué patrón de varias líneas te haría sospechar de un ataque de fuerza bruta? Escribe la consulta que contaría los intentos fallidos por usuario.

Un patrón sospechoso sería encontrar numerosos eventos de autenticación fallida asociados con una misma cuenta, una misma dirección IP o varias cuentas durante un intervalo corto.

Por ejemplo, cien intentos fallidos en un minuto podrían justificar una investigación.

Para contar los eventos `FATAL` por usuario desde nuestra dirección de prueba, se utilizó:

```sql
SELECT
    split_part(
        split_part(linea, 'user=', 2),
        ' ',
        1
    ) AS usuario,
    COUNT(*) AS intentos_fallidos
FROM dba.bitacora
WHERE linea LIKE '%FATAL:%'
  AND linea LIKE '%client=127.0.0.1%'
GROUP BY usuario
ORDER BY intentos_fallidos DESC;
```

La consulta identificó dos eventos, uno correspondiente a `app_ventas` y otro a `usuario_inexistente`.

Para utilizarla como mecanismo de detección real, sería necesario limitar los resultados por tiempo y distinguir los fallos de autenticación de otros errores graves.

## Conclusión

La actividad permitió comprobar que PostgreSQL registra los intentos de autenticación fallidos, los accesos exitosos y las desconexiones.

También se identificó que la bitácora conserva información más detallada que la presentada al cliente, como la inexistencia de un rol.

Se utilizaron consultas SQL para identificar y contar los intentos fallidos por usuario.

Finalmente, se comprendió que los registros permiten investigar patrones sospechosos, pero deben interpretarse cuidadosamente para no atribuir una acción a una persona únicamente por el nombre de usuario registrado.
