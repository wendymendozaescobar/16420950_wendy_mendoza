# Actividad 17 — Reconstruir la cronología y responder a Dirección

## Objetivo

Reconstruir cronológicamente los acontecimientos relacionados con la seguridad y modificación de información en la base de datos `comercial`, utilizando las evidencias disponibles en la bitácora del servidor PostgreSQL y en la tabla `auditoria.cambios_clientes`.

El propósito es identificar quién realizó las operaciones, cuándo ocurrieron, desde qué aplicación o conexión se ejecutaron y cuáles son las limitaciones de los mecanismos de auditoría.

## 1. Entorno de investigación

- Sistema operativo: Ubuntu.
- PostgreSQL: 18.6.
- Puerto: `5433`.
- Base de datos: `comercial`.
- Tabla principal: `public.clientes`.
- Vista de bitácora: `dba.bitacora`.
- Tabla de auditoría: `auditoria.cambios_clientes`.
- Disparador: `trg_auditoria_clientes`.
- Archivo exportado: `evidencias/bitacora-lab01.log`.
- Archivo de integridad: `evidencias/bitacora-lab01.sha256`.

Se verificó la integridad del archivo exportado utilizando `sha256sum -c`, obteniendo un resultado correcto.

Las referencias de línea corresponden a los números observados en `dba.bitacora`. Las fechas del 16 de noviembre de 2026 se presentan en el horario UTC-07.

## 2. Cronología de acontecimientos

| # | Fecha y hora | Usuario | Cliente | Tipo de evento | Qué ocurrió | ¿Exitoso? | Fuente |
|---|---|---|---|---|---|---|---|
| 1 | 2026-11-16 13:49:36.511 | soporte_ana | No aplica | Acceso | Intento de autenticación con contraseña incorrecta desde 127.0.0.1. | No | Bitácora, línea 25 |
| 2 | 2026-11-16 13:52:06.744 | soporte_ana | No aplica | Error | Una consulta fue cancelada por solicitud del usuario. | No, cancelada | Bitácora, línea 31 |
| 3 | 2026-11-16 14:29:31.352 | postgres | No aplica | Privilegios | Se retiraron los privilegios públicos sobre el esquema `auditoria`. | Sí | Bitácora, línea 51 |
| 4 | 2026-11-16 14:29:45.043 | postgres | No aplica | Estructura | Se creó la tabla `auditoria.cambios_clientes`. | Sí | Bitácora, línea 52 |
| 5 | 2026-11-16 14:38:32.113 | postgres | No aplica | Privilegios | Se retiraron los permisos públicos de ejecución sobre la función de auditoría. | Sí | Bitácora, línea 125 |
| 6 | 2026-11-16 14:38:42.191 | postgres | No aplica | Estructura | Se creó el disparador `trg_auditoria_clientes`. | Sí | Bitácora, línea 127 |
| 7 | 2026-11-16 14:54:28.372 | app_ventas | María García, ID 3 | Datos | Se modificó su RFC de `GAMA780912XYZ` a `GAMA780912ZZZ`. | Sí | Bitácora, línea 137; auditoría, evento 1 |
| 8 | 2026-11-16 14:54:43.100 | app_ventas | No aplica | Error | Se rechazó el acceso al esquema `auditoria`. | No | Bitácora, línea 142 |
| 9 | 2026-11-16 14:54:53.671 | app_ventas | No aplica | Error | Se registró otro intento de acceso no autorizado al esquema `auditoria`. | No | Bitácora, línea 148 |
| 10 | 2026-11-16 14:59:34.610 | postgres | Pedro Ruiz, ID 6 | Datos | Se insertó el cliente Pedro Ruiz. | Sí | Auditoría, evento 2 |
| 11 | 2026-11-16 14:59:54.651 | postgres | Pedro Ruiz, ID 6 | Datos | Se eliminó el cliente Pedro Ruiz. | Sí | Auditoría, evento 3 |
| 12 | 2026-11-16 15:09:23.077 | app_ventas | No aplica | Error | Se rechazó un intento de acceso al esquema `auditoria`. | No | Bitácora, línea 174 |
| 13 | 2026-11-16 15:09:40.484 | app_ventas | No aplica | Privilegios | Se rechazó una operación por falta de propiedad sobre la tabla `clientes`. | No | Bitácora, línea 181 |
| 14 | 2026-11-16 15:12:04.363 | postgres | María García, ID 3 | Datos | Se ejecutó una modificación del RFC mientras el disparador estaba temporalmente desactivado. | Sí | Bitácora, líneas 188-189; verificación posterior |
| 15 | 2026-11-16 15:41:15.260 | postgres | Cinco clientes | Datos | Se ejecutó `UPDATE clientes SET segmento = 'regular'`, afectando cinco registros. | Sí | Bitácora, líneas 202-203; auditoría, eventos 4-8 |

La tabla muestra acontecimientos respaldados por los registros disponibles.

Los eventos de la tabla de auditoría tienen mayor detalle sobre los valores anteriores y posteriores a las modificaciones.

La bitácora del servidor permite identificar instrucciones administrativas y operaciones rechazadas que no aparecen en la auditoría mediante disparadores.

## 3. Análisis del incidente de María García

### 3.1. ¿Quién cambió el RFC por primera vez, durante la Actividad 3?

La Actividad 3 simuló el primer cambio del RFC cuando todavía no se contaba con los mecanismos de registro necesarios.

**No hay evidencia suficiente en la bitácora que permita demostrar de manera independiente quién ejecutó esa modificación ni su hora exacta.**

En el procedimiento del laboratorio se utilizó el usuario `app_ventas`, pero esa información corresponde a la ejecución de la práctica, no a un evento recuperado de la bitácora.

Esto demuestra que la auditoría no puede reconstruir automáticamente acontecimientos que no fueron registrados cuando ocurrieron.

### 3.2. ¿Quién cambió el RFC durante la Actividad 7?

Durante la Actividad 7 se trabajó con el usuario `app_ventas` y el nivel de registro `log_statement = 'ddl'`.

Con esa configuración podían registrarse conexiones, pero no necesariamente las instrucciones `UPDATE` ejecutadas.

Por lo tanto, **no hay evidencia de la sentencia de actualización del RFC en la bitácora de ese momento**.

La conexión de un usuario no demuestra por sí sola qué modificación realizó.

### 3.3. ¿Quién cambió el RFC durante la Actividad 12?

La modificación fue realizada por `app_ventas`.

La auditoría registró:

- Evento: `1`.
- Fecha: `2026-11-16`.
- Hora: `14:54:28.372`.
- Usuario de sesión: `app_ventas`.
- Usuario efectivo: `postgres`.
- Aplicación: `app-ventas-web`.
- Dirección IP: `127.0.0.1`.
- Operación: `UPDATE`.
- Cliente: María García, ID 3.
- RFC anterior: `GAMA780912XYZ`.
- RFC posterior: `GAMA780912ZZZ`.

Esta modificación cuenta con evidencia tanto en la bitácora del servidor como en la tabla de auditoría.

La dirección `127.0.0.1` corresponde a una conexión local mediante TCP y no identifica un equipo remoto diferente.

### 3.4. ¿Quién cambió el RFC durante la Actividad 14?

La modificación fue realizada por `postgres`.

Se ejecutó una transacción que desactivó temporalmente el disparador, modificó el RFC y volvió a habilitarlo.

El valor posterior comprobado fue:

`GAMA780912GHI`

La bitácora conserva evidencia de las instrucciones ejecutadas por el administrador.

Sin embargo, la modificación no generó un evento en `auditoria.cambios_clientes`.

El último RFC registrado por el disparador antes de esta operación era `GAMA780912ZZZ`.

Por lo tanto, conocemos el último valor auditado, pero no contamos con una captura automática de `OLD` y `NEW` para esta modificación.

## 4. ¿Quién cambió el teléfono?

Durante la Actividad 7 se realizó una modificación del teléfono de María García utilizando `app_ventas`.

En una evidencia anterior del laboratorio se identificó una sentencia `UPDATE` ejecutada desde `app-ventas-web`, con dirección `127.0.0.1`.

El valor asignado fue:

`6679990000`

La bitácora conservó la instrucción ejecutada, pero no el valor anterior del teléfono.

**No hay evidencia del valor anterior del teléfono en el registro de la sentencia.**

El evento pertenece a una etapa anterior del laboratorio y no debe confundirse con las líneas de la bitácora exportada el 16 de noviembre.

## 5. ¿Hubo intentos de acceso fallidos?

Sí.

En la bitácora consultada se identificó un intento de autenticación fallido:

| Fecha y hora | Usuario | Origen | Resultado | Fuente |
|---|---|---|---|---|
| 2026-11-16 13:49:36.511 | soporte_ana | 127.0.0.1 | Autenticación fallida | Línea 25 |

Durante actividades anteriores también se realizaron pruebas de autenticación con credenciales incorrectas y usuarios inexistentes, utilizadas para comprobar el registro de fallos.

Estos intentos deben distinguirse de las modificaciones exitosas de datos.

La existencia de un intento fallido antes de una modificación no demuestra por sí sola que ambos acontecimientos estén relacionados.

## 6. ¿Qué valor tenía el RFC antes de cada cambio?

| Actividad | Valor anterior comprobable | Valor nuevo | Evidencia |
|---|---|---|---|
| Actividad 3 | No hay evidencia en la bitácora del valor inmediatamente anterior | GAMA780912XXX, según el procedimiento de práctica | Operación no registrada |
| Actividad 7 | No hay evidencia auditada del valor inmediatamente anterior | GAMA780912XYZ, según el procedimiento de práctica | No se registró el UPDATE con nivel `ddl` |
| Actividad 12 | GAMA780912XYZ | GAMA780912ZZZ | Auditoría, evento 1 |
| Actividad 14 | Último valor auditado: GAMA780912ZZZ | GAMA780912GHI | Bitácora del servidor y consulta posterior |

En la Actividad 14, el valor anterior presentado corresponde al último estado conocido mediante auditoría, no a una captura automática realizada durante el cambio.

No deben asignarse fechas exactas a los cambios de las Actividades 3 y 7 cuando no exista evidencia temporal que las sustente.

## 7. Limitaciones encontradas

Durante la investigación se identificaron las siguientes limitaciones:

1. Los acontecimientos ocurridos antes de habilitar la auditoría no pueden reconstruirse completamente.
2. La bitácora del servidor registra sentencias, pero no necesariamente los valores anteriores de los datos.
3. Los disparadores registran cambios de filas, pero no consultas `SELECT`.
4. Un administrador con privilegios elevados puede desactivar temporalmente un disparador.
5. La bitácora y la auditoría mediante disparadores ofrecen información complementaria.
6. Las conexiones locales por socket Unix pueden aparecer sin dirección IP de cliente.
7. La conservación de evidencias requiere mecanismos de integridad, protección de acceso y almacenamiento independiente.

## 8. Conclusión

Se reconstruyó una cronología de 15 acontecimientos utilizando las evidencias registradas por PostgreSQL.

La investigación permitió identificar modificaciones de datos, operaciones de administración, cambios de privilegios, errores e intentos fallidos de acceso.

Se comprobó que la tabla de auditoría conserva los valores anteriores y posteriores de las modificaciones realizadas mientras el disparador está habilitado.

También se identificó una modificación efectuada por un administrador mientras el disparador estaba desactivado. Aunque el cambio no generó un evento de auditoría de datos, la bitácora del servidor conservó evidencia de las instrucciones ejecutadas.

Finalmente, se reconoció que no es posible atribuir con certeza todos los acontecimientos históricos cuando los mecanismos de registro no estaban habilitados.

La actividad demuestra la importancia de implementar la auditoría antes de que ocurran incidentes y de utilizar controles complementarios para proteger las evidencias.
