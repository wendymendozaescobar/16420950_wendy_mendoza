# Actividad 14 — Intentar manipular la auditoría

## Objetivo

Comprobar los controles de seguridad que protegen los registros de auditoría e identificar las limitaciones de un mecanismo basado en disparadores cuando un usuario con privilegios administrativos puede desactivarlo.

## Entorno de trabajo

- Sistema operativo: Ubuntu.
- PostgreSQL: 18.6.
- Puerto: `5433`.
- Base de datos: `comercial`.
- Usuario de aplicación: `app_ventas`.
- Usuario administrador: `postgres`.
- Tabla principal: `public.clientes`.
- Tabla de auditoría: `auditoria.cambios_clientes`.
- Disparador: `trg_auditoria_clientes`.

## 1. Intento de manipulación desde la aplicación

Se realizaron pruebas utilizando el usuario `app_ventas`.

Primero se intentó eliminar el historial de auditoría:

```sql
DELETE FROM auditoria.cambios_clientes;
```

La operación debía ser rechazada porque el usuario no tiene acceso autorizado al esquema `auditoria`.

Después se intentó desactivar el disparador:

```sql
ALTER TABLE clientes
DISABLE TRIGGER trg_auditoria_clientes;
```

La operación también debía ser rechazada porque `app_ventas` no es propietario de la tabla `clientes`.

La bitácora registró el intento de desactivación realizado por `app_ventas`.

Los resultados posteriores confirmaron que los tres eventos originales de auditoría continuaban almacenados.

## 2. Manipulación desde la cuenta administradora

Se estableció una conexión como `postgres`.

Antes de la modificación, el RFC de María García era:

`GAMA780912ZZZ`

Posteriormente, se realizaron las siguientes operaciones dentro de una transacción:

```sql
BEGIN;

ALTER TABLE clientes
DISABLE TRIGGER trg_auditoria_clientes;

UPDATE clientes
SET rfc = 'GAMA780912GHI'
WHERE id = 3;

ALTER TABLE clientes
ENABLE TRIGGER trg_auditoria_clientes;

COMMIT;
```

Las operaciones se ejecutaron correctamente.

El disparador fue desactivado temporalmente, se modificó el RFC y posteriormente se volvió a activar.

## 3. Verificación de la tabla de auditoría

Se consultó:

```sql
SELECT
    id_evento,
    operacion,
    id_cliente,
    valores_antes ->> 'rfc' AS rfc_antes,
    valores_despues ->> 'rfc' AS rfc_despues
FROM auditoria.cambios_clientes
ORDER BY id_evento;
```

Se obtuvieron tres eventos:

| Evento | Operación | Cliente | RFC anterior | RFC posterior |
|---|---|---|---|---|
| 1 | UPDATE | 3 | GAMA780912XYZ | GAMA780912ZZZ |
| 2 | INSERT | 6 | NULL | RUPE950101AAA |
| 3 | DELETE | 6 | RUPE950101AAA | NULL |

El conteo de eventos permaneció en tres.

No apareció un nuevo evento que registrara la modificación a `GAMA780912GHI`.

## 4. Verificación del dato actual

Se ejecutó:

```sql
SELECT nombre, rfc
FROM clientes
WHERE id = 3;
```

El resultado fue:

| Nombre | RFC |
|---|---|
| María García | GAMA780912GHI |

Esto confirmó que la modificación sí ocurrió en la tabla principal, aunque no quedó registrada en la tabla de auditoría.

## 5. Verificación del disparador

Se ejecutó:

```sql
SELECT
    tgname,
    tgenabled
FROM pg_trigger
WHERE tgname = 'trg_auditoria_clientes';
```

El resultado fue:

| Disparador | Estado |
|---|---|
| trg_auditoria_clientes | O |

La letra `O` confirmó que el disparador quedó habilitado nuevamente.

## 6. Investigación de la bitácora

Se consultaron los eventos relacionados con la desactivación y reactivación del disparador, así como con la modificación del RFC.

Se identificaron los siguientes registros:

| Registro | Evento |
|---|---|
| 180 | Intento de desactivación realizado por app_ventas |
| 182 | Sentencia de desactivación de app_ventas |
| 187 | Desactivación realizada por postgres |
| 189 | Línea de la modificación del RFC a GAMA780912GHI |
| 191 | Reactivación realizada por postgres |

La bitácora permitió identificar las operaciones relacionadas con la manipulación del mecanismo de auditoría.

Aunque la tabla de auditoría no conservó el nuevo cambio del RFC, el registro del servidor permitió detectar las instrucciones administrativas ejecutadas.

Esto demuestra que la auditoría mediante disparadores y la bitácora del servidor son mecanismos complementarios.

## Preguntas de análisis

### 1. ¿Qué evidencia permite detectar que hubo un cambio sin auditar?

La principal evidencia es la diferencia entre el estado actual del registro y el último valor conservado en la tabla de auditoría.

En la tabla `clientes`, María García tiene actualmente el RFC `GAMA780912GHI`.

Sin embargo, el último evento de auditoría conserva como valor posterior `GAMA780912ZZZ`.

Además, la cantidad de eventos permaneció en tres, lo que demuestra que no se generó un nuevo registro de auditoría para esta modificación.

La bitácora del servidor también contiene evidencia de las sentencias utilizadas para desactivar el disparador, modificar el RFC y volver a activarlo.

Por ello, la combinación de ambas fuentes permite identificar que se produjo una modificación que no quedó registrada mediante el disparador.

### 2. ¿Qué control administrativo, no técnico, reduciría este riesgo?

Un control administrativo adecuado sería establecer un procedimiento formal de autorización para los cambios que afecten los mecanismos de auditoría.

Por ejemplo, antes de desactivar un disparador, el administrador debería contar con una autorización documentada y una justificación del cambio.

También podría requerirse la revisión y aprobación de una segunda persona responsable de seguridad o auditoría.

De esta manera, las modificaciones sensibles no dependerían únicamente de la decisión de un administrador.

El procedimiento debería incluir la identificación del responsable, el motivo del cambio, la fecha, la autorización y la comprobación posterior de que el mecanismo de auditoría funciona correctamente.

### 3. Relaciona esta actividad con el principio de separación de funciones de la Unidad II.

El principio de separación de funciones establece que las responsabilidades críticas deben distribuirse entre diferentes personas o áreas para reducir el riesgo de abuso de privilegios.

En esta actividad comprobamos que `postgres`, como administrador, puede desactivar el disparador y modificar información sin generar un evento en la tabla de auditoría.

Esto demuestra que un administrador con privilegios elevados también puede afectar los mecanismos encargados de supervisar sus operaciones.

Para reducir este riesgo, la persona que administra la base de datos no debería tener control exclusivo sobre la custodia de las evidencias.

Una alternativa es separar la administración de PostgreSQL de la supervisión de seguridad y la conservación de los registros.

Por ejemplo, las bitácoras pueden enviarse a un sistema externo administrado por otra área, de manera que los administradores de la base de datos no puedan modificar libremente las copias de auditoría.

La separación de funciones mejora la supervisión, la rendición de cuentas y la confiabilidad de las evidencias.

## Análisis

La práctica permitió comprobar que un mecanismo de auditoría basado en disparadores tiene limitaciones frente a usuarios con privilegios administrativos elevados.

Aunque los usuarios de aplicación tienen restricciones para modificar la auditoría, un administrador puede desactivar temporalmente el disparador.

También se demostró que la bitácora del servidor puede conservar evidencia de las instrucciones utilizadas para modificar el mecanismo de auditoría.

Por ello, es importante utilizar controles complementarios y establecer procedimientos administrativos que reduzcan la posibilidad de manipulación.

## Conclusión

Se comprobó que el disparador de auditoría puede desactivarse temporalmente mediante una cuenta con privilegios administrativos.

Durante ese periodo se modificó el RFC de María García sin generar un nuevo registro en `auditoria.cambios_clientes`.

La bitácora del servidor permitió identificar las instrucciones relacionadas con la modificación.

Finalmente, se verificó que el disparador quedó habilitado nuevamente.

La actividad permitió comprender la importancia de la separación de funciones, la supervisión administrativa y la conservación independiente de evidencias para fortalecer la seguridad de una base de datos.
