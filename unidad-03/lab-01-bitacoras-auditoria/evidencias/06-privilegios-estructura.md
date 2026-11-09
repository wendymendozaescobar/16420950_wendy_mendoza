# Actividad 6 — Cambios de privilegios y de estructura

## Objetivo

Comprobar cómo PostgreSQL registra las modificaciones de privilegios y estructura cuando está configurado `log_statement = 'ddl'`.

También se busca demostrar que las bitácoras pueden contener información sensible cuando se incluyen contraseñas directamente en las sentencias SQL.

## Entorno de trabajo

- Sistema operativo: Ubuntu.
- PostgreSQL: 18.6.
- Puerto: `5433`.
- Base de datos: `comercial`.
- Usuario administrador: `postgres`.
- Configuración de registro: `log_statement = 'ddl'`.

## 1. Cambios de privilegios

Se ejecutaron las siguientes instrucciones:

```sql
REVOKE UPDATE ON clientes FROM soporte_ana;

GRANT UPDATE ON clientes TO app_ventas;
```

Ambas se ejecutaron correctamente.

La primera realizó una revocación preventiva, porque `soporte_ana` no tenía concedido el privilegio de actualización.

La segunda confirmó que `app_ventas` dispone del privilegio `UPDATE`.

La consulta de permisos mostró que:

- `app_ventas` conserva los privilegios `SELECT` y `UPDATE`.
- `soporte_ana` conserva únicamente `SELECT`.

## 2. Cambio de estructura

Se ejecutó:

```sql
ALTER TABLE clientes
ADD COLUMN segmento VARCHAR(20);
```

PostgreSQL respondió:

`ALTER TABLE`

Posteriormente, mediante `\d clientes`, se comprobó que la columna `segmento` fue agregada correctamente.

La columna permite almacenar una clasificación comercial de los clientes.

## 3. Verificación de las sentencias en la bitácora

Se consultó la vista `dba.bitacora`.

La consulta permitió identificar tres eventos:

| Registro | Instrucción |
|---|---|
| 56 | `REVOKE UPDATE ON clientes FROM soporte_ana` |
| 57 | `GRANT UPDATE ON clientes TO app_ventas` |
| 58 | `ALTER TABLE clientes ADD COLUMN segmento VARCHAR(20)` |

Los eventos quedaron asociados con:

- Usuario: `postgres`.
- Base de datos: `comercial`.
- Aplicación: `psql`.
- Cliente: `[local]`.

Esto permitió confirmar que PostgreSQL registró las modificaciones administrativas con `log_statement = 'ddl'`.

## 4. Experimento: la bitácora también puede filtrar secretos

Se creó un rol temporal mediante una sentencia `CREATE ROLE` que incluía una contraseña ficticia.

Por seguridad, la contraseña se presenta redactada:

```sql
CREATE ROLE rol_temporal LOGIN PASSWORD '[REDACTADA]';
```

Después se ejecutó:

```sql
DROP ROLE rol_temporal;
```

PostgreSQL respondió correctamente a ambas instrucciones.

Al consultar `dba.bitacora`, se encontraron dos registros:

| Registro | Evento |
|---|---|
| 60 | Creación del rol temporal, incluyendo la contraseña en texto claro |
| 61 | Eliminación del rol temporal |

La consulta a `pg_roles` devolvió cero filas, confirmando que el rol fue eliminado.

Sin embargo, la sentencia de creación continuó apareciendo en la bitácora.

Esto demostró que eliminar un usuario no elimina automáticamente los registros históricos que contienen información sobre su creación.

## Preguntas de análisis

### 1. ¿Qué tipo de evento es cada una de las tres primeras sentencias: privilegio o estructura?

Las instrucciones `REVOKE` y `GRANT` corresponden a cambios de privilegios.

`REVOKE` permite retirar autorizaciones, mientras que `GRANT` permite concederlas.

En cambio, `ALTER TABLE` corresponde a un cambio de estructura, porque modifica la definición de una tabla de la base de datos.

En nuestra práctica, se utilizó `ALTER TABLE` para agregar la columna `segmento` a `clientes`.

### 2. ¿Por qué GRANT y REVOKE quedan registrados con log_statement = 'ddl'?

Porque PostgreSQL incluye determinadas instrucciones administrativas de autorización dentro de las sentencias registradas cuando `log_statement` tiene el valor `ddl`.

Aunque `GRANT` y `REVOKE` modifican permisos y no la estructura física de una tabla, ambos son relevantes para la seguridad y administración de los objetos.

Durante la actividad comprobamos que las dos instrucciones aparecieron en la bitácora, junto con `ALTER TABLE`.

Esto permite investigar cambios administrativos que podrían afectar el acceso a la información.

### 3. Si la bitácora contiene contraseñas, ¿quién debería poder leerla? Relaciónalo con la gestión de secretos de la Unidad II.

La bitácora debe estar disponible únicamente para administradores y personal de seguridad expresamente autorizado.

Los registros pueden contener información sensible, como nombres de usuarios, sentencias SQL, direcciones de conexión y contraseñas introducidas directamente en instrucciones.

En la Unidad II aprendimos la importancia de aplicar el principio de mínimo privilegio y proteger las credenciales.

Este experimento demuestra que dichas medidas también deben aplicarse a los archivos de registro.

Una contraseña puede quedar expuesta en una bitácora incluso cuando ya se eliminó el usuario correspondiente.

Por eso es recomendable evitar introducir contraseñas en texto claro dentro de sentencias SQL, utilizar mecanismos como `\password` cuando corresponda y controlar estrictamente el acceso a los registros.

También debemos revisar y redactar la información sensible antes de compartir o publicar evidencias.

## Análisis de seguridad

La actividad permitió identificar dos funciones diferentes de las bitácoras:

1. Registrar cambios administrativos para facilitar investigaciones posteriores.
2. Conservar información sobre operaciones que podrían incluir datos sensibles.

Aunque registrar las sentencias resulta útil para una auditoría, también puede introducir riesgos cuando se almacenan secretos sin protección.

Esto demuestra que una configuración de auditoría debe acompañarse de controles de acceso, procedimientos de conservación y mecanismos para evitar la exposición de credenciales.

## Conclusión

Se comprobó que PostgreSQL registra operaciones `GRANT`, `REVOKE` y `ALTER TABLE` cuando se utiliza `log_statement = 'ddl'`.

También se verificó que la columna `segmento` fue agregada correctamente y que los privilegios de los usuarios permanecieron conforme a lo esperado.

Finalmente, se demostró que una contraseña escrita directamente en una sentencia SQL puede permanecer en la bitácora después de eliminar el rol.

La principal enseñanza es que **las bitácoras son herramientas importantes para la auditoría, pero también deben protegerse como información sensible**.

## Archivo SQL

[03-privilegios-estructura.sql](../sql/03-privilegios-estructura.sql)
