# Actividad 7 — Modificaciones de datos: DDL frente a MOD

## Objetivo

Comparar el comportamiento de los niveles `ddl` y `mod` del parámetro `log_statement` de PostgreSQL, identificando qué operaciones se registran en la bitácora y qué información puede utilizarse para investigar modificaciones de datos.

## Entorno de trabajo

- Sistema operativo: Ubuntu.
- PostgreSQL: 18.6.
- Puerto: `5433`.
- Base de datos: `comercial`.
- Usuario administrador: `postgres`.
- Usuario de aplicación: `app_ventas`.
- Aplicación: `app-ventas-web`.
- Dirección del cliente: `127.0.0.1`.

## 1. Prueba con log_statement = 'ddl'

Inicialmente, PostgreSQL tenía configurado:

```sql
log_statement = 'ddl'
```

Se realizó una conexión como `app_ventas` y se ejecutó:

```sql
UPDATE clientes
SET rfc = 'GAMA780912XYZ'
WHERE id = 3;
```

PostgreSQL respondió:

```text
UPDATE 1
```

Posteriormente, se consultó el registro de María García.

| Campo | Resultado |
|---|---|
| ID | 3 |
| Nombre | María García |
| RFC anterior | `GAMA780912XXX` |
| RFC nuevo | `GAMA780912XYZ` |

### Verificación de la bitácora

Se consultaron los registros correspondientes al usuario `app_ventas` mediante la vista `dba.bitacora`.

Se identificaron eventos de:

- Autenticación.
- Autorización de la conexión.
- Desconexión.

Sin embargo, no se encontró la sentencia `UPDATE` exitosa.

Esto permitió comprobar que `log_statement = 'ddl'` registra operaciones de definición y administración, pero no registra automáticamente las modificaciones de datos mediante `UPDATE`.

## 2. Cambio de log_statement a 'mod'

Se ejecutó:

```sql
ALTER SYSTEM SET log_statement = 'mod';
```

Posteriormente, se recargó la configuración:

```sql
SELECT pg_reload_conf();
```

La función devolvió `true`.

Al consultar `pg_settings`, se obtuvieron los siguientes resultados:

| Parámetro | Resultado |
|---|---|
| `name` | `log_statement` |
| `setting` | `mod` |
| `source` | `configuration file` |
| `pending_restart` | `false` |

El cambio quedó aplicado sin necesidad de reiniciar PostgreSQL.

## 3. Modificación de datos con log_statement = 'mod'

Se estableció una conexión utilizando `app_ventas`.

Se ejecutó:

```sql
UPDATE clientes
SET telefono = '6679990000'
WHERE id = 3;
```

El resultado fue:

```text
UPDATE 1
```

Después se ejecutó:

```sql
SELECT nombre, rfc
FROM clientes
WHERE id = 3;
```

La consulta devolvió:

| Nombre | RFC |
|---|---|
| María García | `GAMA780912XYZ` |

Esto confirmó que la modificación del teléfono se realizó correctamente y que el RFC conservó su valor.

## 4. Investigación de la bitácora

Se consultó la vista `dba.bitacora` para localizar cambios de configuración y sentencias ejecutadas por `app_ventas`.

Se identificaron los siguientes registros:

| Registro | Evento |
|---|---|
| 29 | Cambio anterior de `log_statement` a `ddl` |
| 72 | Ejecución de `ALTER SYSTEM SET log_statement = 'mod'` |
| 74 | Confirmación del cambio a `mod` |
| 79 | Sentencia `UPDATE` ejecutada por `app_ventas` |

### Registro de modificación

El registro 79 contenía la siguiente información:

| Campo | Valor |
|---|---|
| Fecha | 2026-11-08 |
| Hora | 23:01:54.670 MST |
| Proceso | `10092` |
| Usuario | `app_ventas` |
| Base de datos | `comercial` |
| Aplicación | `app-ventas-web` |
| Cliente | `127.0.0.1` |
| Operación | `UPDATE` |
| Campo modificado | `telefono` |
| Nuevo valor | `6679990000` |
| Registro afectado | `id = 3` |

La bitácora permitió identificar la sentencia que modificó el teléfono de María García.

Sin embargo, no conservó automáticamente el valor anterior de dicho campo.

También se observó que la sentencia `SELECT` no apareció como una operación registrada, porque el nivel `mod` no incluye las consultas de solo lectura.

## 5. Comparación de los resultados

| Característica | DDL | MOD |
|---|---|---|
| Registra CREATE y ALTER TABLE | Sí | Sí |
| Registra GRANT y REVOKE | Sí | Sí |
| Registra INSERT | No | Sí |
| Registra UPDATE | No | Sí |
| Registra DELETE | No | Sí |
| Registra SELECT | No | No |
| Conserva automáticamente valores anteriores | No | No |

La comparación demuestra que `mod` ofrece mayor visibilidad sobre las modificaciones de datos.

Sin embargo, registrar una sentencia SQL no equivale a conservar un historial completo de los valores modificados.

## Preguntas de análisis

### 1. ¿Qué nivel habría registrado la lectura del RFC? ¿Qué costo tendría en un servidor con miles de consultas por minuto?

El nivel `all` de `log_statement` habría permitido registrar la consulta `SELECT` utilizada para leer el RFC de María García.

Esto se debe a que `all` registra las sentencias SQL, incluidas las consultas de lectura.

Sin embargo, utilizar esta configuración en un servidor que procesa miles de consultas por minuto podría generar una cantidad considerable de registros.

Entre sus posibles consecuencias se encuentran:

- Mayor utilización de almacenamiento.
- Incremento de operaciones de escritura.
- Costos adicionales de procesamiento y administración de bitácoras.
- Mayor dificultad para localizar eventos relevantes entre grandes cantidades de información.
- Posible exposición de información sensible incluida en las sentencias.

Por ello, es importante seleccionar el nivel de registro considerando las necesidades de auditoría y el impacto sobre el rendimiento.

### 2. ¿Qué le falta a esta bitácora para revertir el cambio con certeza?

La bitácora registra la sentencia ejecutada, el usuario, el momento y la información de la conexión.

Sin embargo, no conserva automáticamente el valor anterior de la columna `telefono`.

Aunque sabemos que se ejecutó una modificación para establecer el teléfono `6679990000`, la bitácora no proporciona por sí sola todos los datos necesarios para reconstruir el estado anterior con certeza.

Para resolverlo, sería necesario implementar un mecanismo de auditoría de datos que registre:

- La tabla modificada.
- El registro afectado.
- El usuario responsable.
- La fecha y hora.
- El valor anterior.
- El valor nuevo.
- El tipo de operación realizada.

Una alternativa es utilizar disparadores y tablas de auditoría para conservar los cambios de manera estructurada.

Esta necesidad se abordará en la Parte B del laboratorio.

## Conclusión

La actividad permitió comprobar las diferencias entre `log_statement = 'ddl'` y `log_statement = 'mod'`.

Con `ddl`, PostgreSQL registró las conexiones y desconexiones de `app_ventas`, pero no la modificación del RFC.

Al utilizar `mod`, el servidor registró la sentencia `UPDATE` que modificó el teléfono de María García.

También se identificó que las consultas `SELECT` no se registraron con este nivel.

Finalmente, se comprendió que una bitácora de sentencias permite identificar operaciones, pero no garantiza recuperar los valores anteriores de los datos modificados.

Por ello, los mecanismos de auditoría de sentencias deben complementarse con procedimientos que conserven el historial de cambios cuando sea necesario.
