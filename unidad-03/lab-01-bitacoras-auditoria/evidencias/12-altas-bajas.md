# Actividad 13 — Altas y bajas

## Objetivo

Comprobar que el disparador de auditoría de PostgreSQL registra automáticamente las operaciones `INSERT` y `DELETE` realizadas sobre la tabla `clientes`.

También se busca demostrar que el historial de auditoría puede conservar información de un registro después de que este haya sido eliminado de la tabla original.

## Entorno de trabajo

- Sistema operativo: Ubuntu.
- PostgreSQL: 18.6.
- Puerto: `5433`.
- Base de datos: `comercial`.
- Usuario administrador: `postgres`.
- Tabla principal: `public.clientes`.
- Tabla de auditoría: `auditoria.cambios_clientes`.
- Disparador: `trg_auditoria_clientes`.

## 1. Inserción de un cliente

Se ejecutó la siguiente instrucción:

```sql
INSERT INTO clientes (nombre, correo, rfc, edad, ciudad, codigo_postal)
VALUES (
    'Pedro Ruiz',
    'pedro.ruiz@example.test',
    'RUPE950101AAA',
    30,
    'Guasave',
    '81000'
);
```

PostgreSQL respondió:

```text
INSERT 0 1
```

Esto confirmó que se insertó un registro.

Posteriormente, se ejecutó:

```sql
SELECT id, nombre, rfc
FROM clientes
WHERE nombre = 'Pedro Ruiz';
```

El resultado fue:

| ID | Nombre | RFC |
|---|---|---|
| 6 | Pedro Ruiz | RUPE950101AAA |

La consulta confirmó que el registro se había creado correctamente y que PostgreSQL le asignó el identificador 6.

## 2. Eliminación del cliente

Después se ejecutó:

```sql
DELETE FROM clientes
WHERE nombre = 'Pedro Ruiz';
```

PostgreSQL respondió:

```text
DELETE 1
```

Esto confirmó que se eliminó una fila de la tabla `clientes`.

Como el disparador `trg_auditoria_clientes` está configurado para ejecutarse después de las operaciones `INSERT`, `UPDATE` y `DELETE`, ambas operaciones generaron registros automáticos en la tabla de auditoría.

## 3. Verificación de los eventos de auditoría

Se ejecutó:

```sql
SELECT
    id_evento,
    usuario_sesion,
    aplicacion,
    ip_cliente,
    operacion,
    id_cliente,
    valores_antes ->> 'rfc' AS rfc_antes,
    valores_despues ->> 'rfc' AS rfc_despues
FROM auditoria.cambios_clientes
ORDER BY id_evento;
```

Se obtuvieron tres eventos:

| id_evento | usuario_sesion | aplicacion | ip_cliente | operacion | id_cliente | rfc_antes | rfc_despues |
|---|---|---|---|---|---|---|---|
| 1 | app_ventas | app-ventas-web | 127.0.0.1 | UPDATE | 3 | GAMA780912XYZ | GAMA780912ZZZ |
| 2 | postgres | psql | NULL | INSERT | 6 | NULL | RUPE950101AAA |
| 3 | postgres | psql | NULL | DELETE | 6 | RUPE950101AAA | NULL |

Los resultados confirmaron que el sistema conserva el historial de las tres operaciones realizadas durante las actividades.

### Interpretación del evento 2

El evento 2 corresponde a la inserción de Pedro Ruiz.

El campo `valores_antes` es nulo porque el registro no existía antes de la operación.

El campo `valores_despues` contiene los datos del cliente después de su creación.

### Interpretación del evento 3

El evento 3 corresponde a la eliminación de Pedro Ruiz.

El campo `valores_antes` conserva la información que tenía el cliente antes de eliminarlo.

El campo `valores_despues` es nulo porque, después de la eliminación, ya no existe un registro posterior.

### Diferencia entre el evento 1 y los eventos 2 y 3

El primer evento fue realizado por `app_ventas` mediante una conexión TCP desde `127.0.0.1`.

Los eventos 2 y 3 fueron realizados por `postgres` mediante una conexión local por socket Unix.

Por esta razón, los eventos 2 y 3 no muestran una dirección IP de cliente.

## Preguntas de análisis

### 1. El cliente Pedro Ruiz ya no existe en clientes. ¿Dónde queda evidencia de que existió y de sus datos?

La evidencia permanece en la tabla `auditoria.cambios_clientes`.

En esta práctica, los eventos 2 y 3 conservaron información sobre la creación y eliminación de Pedro Ruiz.

El evento 2 permite identificar los datos que se insertaron mediante `valores_despues`.

El evento 3 conserva los datos anteriores a la eliminación mediante `valores_antes`.

Esto demuestra que la auditoría puede conservar un historial independiente de la tabla principal.

Aunque el cliente haya sido eliminado de `public.clientes`, sus datos continúan presentes en los registros de auditoría.

### 2. ¿Por qué ip_cliente está vacía en los eventos 2 y 3?

Porque las operaciones de inserción y eliminación fueron realizadas por el administrador `postgres` mediante una conexión local por socket Unix.

Al utilizar una conexión de este tipo, PostgreSQL no dispone de una dirección IP de cliente asociada a la sesión.

Por ello, la función `inet_client_addr()` devuelve `NULL`.

En cambio, el evento 1 sí muestra la dirección `127.0.0.1`, porque `app_ventas` realizó su conexión mediante TCP.

Esto demuestra que una dirección IP vacía no significa necesariamente que falte información por un error, sino que puede corresponder al tipo de conexión utilizado.

### 3. La política de retención de la Unidad II pedía eliminar datos cuando ya no fueran necesarios. ¿Qué conflicto aparece? ¿Quién debe resolverlo?

El conflicto consiste en que la auditoría conserva información histórica, incluso después de eliminar los datos de la tabla principal.

Esto es útil para investigar incidentes, identificar responsabilidades y reconstruir modificaciones.

Sin embargo, también puede entrar en conflicto con las políticas de retención y eliminación de datos personales.

En nuestro ejemplo, Pedro Ruiz fue eliminado de `clientes`, pero su nombre, RFC y otros datos continúan almacenados en los documentos JSONB de la tabla de auditoría.

Por lo tanto, eliminar un registro de la tabla principal no garantiza que todos sus datos personales hayan sido eliminados del sistema.

Este conflicto debe resolverse mediante una política de conservación de registros que considere tanto las necesidades de auditoría como las obligaciones de protección de datos.

La decisión corresponde a los responsables del tratamiento de datos, en coordinación con las áreas de seguridad, cumplimiento normativo y administración de bases de datos.

Deben establecerse periodos de conservación, restricciones de acceso y procedimientos autorizados de eliminación o anonimización cuando corresponda.

El administrador de la base de datos debe implementar técnicamente las medidas aprobadas, pero no decidir por sí solo cuánto tiempo deben conservarse los datos personales.

## Análisis

La actividad permitió comprobar que el disparador registra automáticamente los eventos de inserción y eliminación.

También se demostró que la auditoría conserva información independiente de los registros actuales de la tabla principal.

El uso de `valores_antes` y `valores_despues` permite interpretar el estado de los datos según el tipo de operación realizada.

Sin embargo, esta capacidad también introduce responsabilidades relacionadas con la privacidad y conservación de información personal.

Por ello, los registros de auditoría deben protegerse mediante controles de acceso y políticas de retención adecuadas.

## Conclusión

Se insertó y eliminó correctamente el cliente ficticio Pedro Ruiz.

El disparador generó automáticamente dos eventos de auditoría, correspondientes a las operaciones `INSERT` y `DELETE`.

Se comprobó que los registros conservaron el RFC del cliente y la información necesaria para identificar ambas operaciones.

La actividad permitió comprender que un sistema de auditoría puede conservar evidencia histórica incluso después de eliminar información de la tabla principal.

También se identificó la importancia de equilibrar las necesidades de trazabilidad con las políticas de protección y retención de datos personales.
