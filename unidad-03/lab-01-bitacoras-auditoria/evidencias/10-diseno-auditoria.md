# Actividad 10 — Diseñar y crear el registro de auditoría

## Objetivo

Diseñar e implementar una tabla de auditoría en PostgreSQL que permita conservar información sobre las modificaciones realizadas a los registros de clientes.

La estructura debe permitir identificar el usuario, la aplicación, la dirección IP, el momento de la operación y los valores anteriores y posteriores de los datos.

## Entorno de trabajo

- Sistema operativo: Ubuntu.
- PostgreSQL: 18.6.
- Puerto: `5433`.
- Base de datos: `comercial`.
- Usuario administrador: `postgres`.
- Esquema de auditoría: `auditoria`.
- Tabla: `auditoria.cambios_clientes`.

## 1. Diseño de los campos

Antes de crear la tabla se identificó la información necesaria para investigar las modificaciones de datos.

| Campo propuesto | Tipo | ¿Qué pregunta responde? | ¿Puede ser nulo? ¿Por qué? |
|---|---|---|---|
| `id_evento` | BIGSERIAL | ¿Cuál es el identificador único del evento? | No. Es la clave primaria. |
| `momento` | TIMESTAMPTZ | ¿Cuándo se registró el evento? | No. Tiene `NOT NULL` y un valor predeterminado. |
| `usuario_sesion` | TEXT | ¿Qué usuario inició la sesión? | No. Se obtiene mediante `session_user`. |
| `usuario_efectivo` | TEXT | ¿Con qué rol efectivo se ejecutó la operación? | No. Se obtiene mediante `current_user`. |
| `aplicacion` | TEXT | ¿Desde qué aplicación se realizó la operación? | Sí. La columna admite NULL, aunque normalmente se obtiene el nombre configurado en la sesión. |
| `ip_cliente` | INET | ¿Desde qué dirección IP se realizó la conexión? | Sí. Las conexiones mediante socket Unix pueden no tener una dirección IP de cliente. |
| `operacion` | TEXT | ¿Qué operación se realizó? | No. Debe identificarse el tipo de operación. |
| `id_cliente` | BIGINT | ¿Qué cliente fue afectado? | Sí. La definición permite NULL, aunque en la auditoría de clientes normalmente deberá identificarse el registro afectado. |
| `valores_antes` | JSONB | ¿Cómo estaban los datos antes de la modificación? | Sí. En una inserción no existe un registro anterior. |
| `valores_despues` | JSONB | ¿Cómo quedaron los datos después de la operación? | Sí. En una eliminación no existe un registro posterior. |

Esta estructura permitirá almacenar información sobre diferentes tipos de operaciones sin crear una columna de auditoría para cada campo de la tabla `clientes`.

## 2. Creación del esquema de auditoría

Se ejecutó:

```sql
CREATE SCHEMA auditoria;
```

PostgreSQL respondió:

`CREATE SCHEMA`

Posteriormente, se restringieron los privilegios otorgados a `PUBLIC`:

```sql
REVOKE ALL ON SCHEMA auditoria FROM PUBLIC;
```

PostgreSQL respondió:

`REVOKE`

Al consultar los esquemas mediante `\dn+ auditoria`, se confirmó que el esquema existe y que su propietario es `postgres`.

El objetivo de utilizar un esquema independiente es separar los registros de auditoría de los datos operativos de la empresa.

## 3. Creación de la tabla

Se creó la tabla `auditoria.cambios_clientes` con diez columnas.

La estructura incluye:

- Un identificador único para cada evento.
- La fecha y hora de registro.
- El usuario de sesión y el usuario efectivo.
- El nombre de la aplicación.
- La dirección IP del cliente.
- El tipo de operación.
- El identificador del cliente afectado.
- Los valores anteriores y posteriores en formato JSONB.

PostgreSQL respondió:

`CREATE TABLE`

Se comprobó la estructura mediante:

```sql
\d auditoria.cambios_clientes
```

La consulta confirmó que las diez columnas fueron creadas correctamente.

## 4. Verificación de permisos

Se ejecutaron:

```sql
\dn+ auditoria
```

```sql
\dp auditoria.cambios_clientes
```

La verificación mostró que el esquema pertenece a `postgres`.

En la tabla no aparecieron concesiones explícitas de privilegios a otros usuarios.

Esto es importante porque los registros de auditoría pueden contener información personal y deben mantenerse protegidos.

## 5. Verificación inicial de registros

Se ejecutó:

```sql
SELECT COUNT(*)
FROM auditoria.cambios_clientes;
```

El resultado fue:

```text
count
-----
0
```

La tabla se encuentra vacía porque todavía no se ha implementado el disparador encargado de registrar automáticamente las operaciones sobre `clientes`.

La implementación de la función y el disparador corresponde a la siguiente actividad.

## Preguntas de análisis

### 1. ¿Por qué momento usa TIMESTAMPTZ y no TIMESTAMP?

Se utiliza `TIMESTAMPTZ` porque permite representar un instante de tiempo teniendo en cuenta la zona horaria.

Esto es importante para una auditoría, ya que los eventos pueden originarse desde diferentes ubicaciones o sistemas con distintas configuraciones horarias.

PostgreSQL almacena el instante de manera normalizada y lo presenta de acuerdo con la zona horaria de la sesión.

En cambio, `TIMESTAMP` no incorpora información de zona horaria para interpretar el valor.

Por ello, `TIMESTAMPTZ` facilita la comparación cronológica de los eventos registrados.

### 2. ¿Por qué se guarda el registro completo en JSONB y no solo la columna que cambió?

Se utiliza `JSONB` porque permite conservar el estado completo del registro antes y después de una operación.

Si solamente almacenáramos la columna modificada, podríamos perder información relevante para reconstruir el contexto de un incidente.

Por ejemplo, al investigar una modificación del RFC de María García, sería útil conocer también los demás datos que tenía el registro en ese momento.

Otra ventaja es que `JSONB` permite almacenar documentos con diferentes conjuntos de campos.

Por lo tanto, si posteriormente agregamos una nueva columna a `clientes`, podremos continuar almacenando los registros completos sin modificar necesariamente la estructura de la tabla de auditoría.

Además, los documentos JSONB pueden consultarse mediante operadores y funciones de PostgreSQL.

### 3. La tabla de auditoría también contendrá RFC. ¿Qué implica eso para su clasificación y su control de acceso?

El RFC es información que puede identificar a una persona y debe protegerse conforme a los controles aplicables a los datos personales.

Aunque los datos se almacenen dentro de una tabla de auditoría, no dejan de ser información sensible desde el punto de vista de su confidencialidad.

Por ello, los registros de auditoría deben clasificarse y protegerse de acuerdo con la información que contienen.

Es necesario aplicar el principio de mínimo privilegio, restringiendo la lectura y modificación de la tabla únicamente a los roles autorizados.

También es importante evitar que los usuarios de las aplicaciones puedan alterar o eliminar el historial de auditoría.

Finalmente, las evidencias compartidas o publicadas en GitHub deben revisarse para evitar exponer datos personales, contraseñas u otra información confidencial.

## Análisis

La actividad permitió comprender que un sistema de auditoría requiere diseñar previamente qué información debe conservar.

Se identificó la importancia de registrar tanto los usuarios como el contexto de las operaciones.

También se comprendió la diferencia entre los datos operativos y los registros históricos de auditoría.

La utilización de `JSONB` permitirá conservar los valores anteriores y posteriores de cada registro cuando implementemos el disparador correspondiente.

Sin embargo, la tabla creada todavía no registra modificaciones automáticamente.

## Conclusión

Se diseñó y creó correctamente la tabla `auditoria.cambios_clientes`, utilizando un esquema independiente dentro de la base de datos `comercial`.

La tabla contiene diez campos que permitirán identificar los eventos de auditoría y conservar el estado anterior y posterior de los registros modificados.

Se verificó su estructura, sus privilegios y que inicialmente contiene cero registros.

La actividad permitió comprender la importancia de diseñar mecanismos de auditoría que no solamente registren las operaciones realizadas, sino que también permitan reconstruir los cambios de información.

La siguiente etapa consistirá en crear una función y un disparador que automaticen este proceso.

## Archivo SQL

[04-esquema-auditoria.sql](../sql/04-esquema-auditoria.sql)
