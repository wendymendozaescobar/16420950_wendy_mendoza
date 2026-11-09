# Actividad 3 — El incidente sin bitácora

## Objetivo

Simular una modificación de datos realizada por un usuario autorizado y comprobar si la configuración actual de PostgreSQL permite identificar al responsable mediante sus bitácoras.

## Escenario

La empresa ficticia Comercializadora Norte S.A. de C.V. detectó que el RFC de María García fue modificado.

Se requiere determinar quién realizó la modificación y comprobar si el servidor conserva evidencia suficiente para reconstruir el incidente.

## Procedimiento

### 1. Consultar la información original

Se consultó el registro correspondiente a María García en la tabla `clientes`.

```sql
SELECT id, nombre, rfc
FROM clientes
WHERE id = 3;
```

**Resultado:**

| ID | Nombre | RFC original |
|---|---|---|
| 3 | María García | `GAMA780912GHI` |

### 2. Simular una modificación

Se intentó establecer una conexión TCP utilizando el usuario `app_ventas`.

El primer intento falló por una contraseña incorrecta.

Posteriormente, se realizó una conexión exitosa y se ejecutó:

```sql
UPDATE clientes
SET rfc = 'GAMA780912XXX'
WHERE id = 3;
```

PostgreSQL devolvió:

```text
UPDATE 1
```

Este resultado confirmó que se modificó un registro.

### 3. Comprobar el nuevo RFC

Se consultó nuevamente la tabla `clientes`.

| ID | Nombre | RFC después del cambio |
|---|---|---|
| 3 | María García | `GAMA780912XXX` |

La modificación se realizó correctamente.

Sin embargo, la tabla no conserva por sí sola el usuario responsable, la fecha exacta de modificación ni el historial de valores anteriores.

### 4. Investigar la bitácora

Se ejecutó:

```sql
SELECT linea
FROM dba.bitacora
WHERE linea ILIKE '%update%'
   OR linea ILIKE '%app_ventas%';
```

La consulta devolvió tres líneas.

Se identificaron mensajes relacionados con:

- Una sentencia SQL anterior que contenía la palabra `update`.
- Un intento fallido de autenticación del usuario `app_ventas`.
- Información adicional sobre la regla de `pg_hba.conf` que correspondía a ese intento.

No se encontró una línea que registrara la sentencia `UPDATE` exitosa sobre el RFC de María García.

Esto coincide con la configuración `log_statement = none`, identificada durante la Actividad 1.

El registro del intento fallido de autenticación demuestra que se intentó utilizar la cuenta `app_ventas`, pero no demuestra quién realizó la modificación posterior.

## Preguntas de análisis

### 1. ¿Puedes demostrar quién modificó el RFC?

No podemos demostrarlo únicamente con la bitácora disponible.

Durante la simulación observamos que la operación fue ejecutada mediante la cuenta `app_ventas`, pero PostgreSQL no conservó un registro de la sentencia `UPDATE` exitosa.

Por lo tanto, aunque conocemos al usuario utilizado en nuestra prueba, no contamos con evidencia de auditoría suficiente para demostrar posteriormente qué sesión realizó la modificación.

Además, identificar una cuenta no equivale necesariamente a identificar a la persona que utilizó sus credenciales.

### 2. ¿Puedes demostrar que el cambio no lo hizo `soporte_ana`?

La configuración de privilegios indica que `soporte_ana` tiene permiso `SELECT`, pero no `UPDATE` sobre la tabla `clientes`.

Por lo tanto, con los permisos que comprobamos, ese usuario no debería poder ejecutar directamente la modificación.

Sin embargo, conocer los privilegios actuales no equivale a disponer de un historial completo del incidente.

No contamos con una auditoría que permita demostrar de manera concluyente quién realizó el cambio ni reconstruir todas las circunstancias en las que ocurrió.

### 3. Los privilegios de la Unidad II, ¿impidieron el cambio? ¿Debían impedirlo?

No impidieron el cambio porque la cuenta `app_ventas` tiene autorizado el privilegio `UPDATE` sobre la tabla `clientes`.

La operación era válida desde el punto de vista de la autorización de PostgreSQL.

Los privilegios no tenían por qué impedir una modificación que estaba permitida para esa cuenta.

Sin embargo, que un usuario esté autorizado para modificar datos no significa que sus operaciones deban quedar sin seguimiento.

Por eso es necesario complementar la autorización con mecanismos de auditoría.

### 4. ¿Qué tendría que haber estado configurado antes del incidente?

Antes del incidente debería haberse configurado un mecanismo de auditoría capaz de registrar las modificaciones realizadas sobre los datos sensibles.

Por ejemplo, una bitácora de sentencias podría haber registrado la operación SQL, el usuario y el momento de su ejecución.

Sin embargo, registrar una sentencia no garantiza conservar automáticamente el valor anterior del campo modificado.

Para almacenar el valor anterior y el nuevo valor de manera estructurada, sería conveniente implementar una tabla de auditoría y un disparador que registre los cambios.

Estos mecanismos deben encontrarse activos antes de que ocurra el incidente, porque no pueden reconstruir automáticamente información que nunca fue registrada.

## Análisis

La actividad permitió comprobar que los permisos de PostgreSQL y sus mecanismos de auditoría cumplen funciones diferentes.

El usuario `app_ventas` estaba autorizado para modificar los registros, por lo que PostgreSQL permitió la operación.

Sin embargo, la configuración inicial no registraba las sentencias SQL exitosas.

También se comprobó que un error de autenticación puede aparecer en la bitácora aunque no esté habilitado el registro habitual de conexiones exitosas.

Esto demuestra que la presencia de algunos eventos en una bitácora no significa que exista un registro completo de las operaciones realizadas.

## Conclusión

Se simuló correctamente una modificación del RFC de María García mediante el usuario `app_ventas`.

El RFC cambió de `GAMA780912GHI` a `GAMA780912XXX`.

La investigación permitió identificar un intento fallido de autenticación, pero no encontró un registro de la modificación exitosa.

Se comprendió que los privilegios controlan qué operaciones están permitidas, mientras que la auditoría proporciona evidencia sobre las operaciones que ocurrieron.

La principal enseñanza es que **la auditoría debe configurarse antes del incidente**, ya que la información que no se registró no puede recuperarse automáticamente después.
