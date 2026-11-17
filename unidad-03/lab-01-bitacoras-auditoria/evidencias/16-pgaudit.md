# Actividad 19 — Auditoría de objeto sobre columnas sensibles

## Objetivo

Configurar pgAudit para registrar operaciones sobre columnas sensibles de la tabla `clientes` y comprobar la diferencia entre auditoría de sesión y auditoría de objeto.

## 1. Entorno de trabajo

- Sistema operativo: Ubuntu.
- PostgreSQL: 18.6.
- Puerto: `5433`.
- Base de datos: `comercial`.
- Extensión: pgAudit 18.0.
- Tabla auditada: `public.clientes`.
- Rol auditor: `auditor_datos`.
- Columnas sensibles: `rfc` y `telefono`.

## 2. Configuración del rol auditor

Se creó un rol sin capacidad de iniciar sesión:

```sql
CREATE ROLE auditor_datos NOLOGIN;
```

Posteriormente, se concedieron privilegios específicos sobre las columnas sensibles:

```sql
GRANT SELECT (rfc, telefono),
      UPDATE (rfc, telefono)
ON clientes
TO auditor_datos;
```

Se verificó que el rol tuviera permisos para consultar y modificar `rfc` y `telefono`, pero no para modificar `ciudad`.

Los resultados de la comprobación fueron:

| Privilegio | Resultado |
|---|---|
| SELECT sobre RFC | true |
| SELECT sobre teléfono | true |
| UPDATE sobre RFC | true |
| UPDATE sobre teléfono | true |
| UPDATE sobre ciudad | false |

Estos privilegios se utilizaron como filtro para la auditoría de objeto.

## 3. Configuración de pgAudit

Se ejecutaron las siguientes instrucciones:

```sql
ALTER SYSTEM SET pgaudit.log = 'role, ddl';

ALTER SYSTEM SET pgaudit.role = 'auditor_datos';

ALTER SYSTEM SET pgaudit.log_relation = on;

SELECT pg_reload_conf();
```

La recarga de configuración devolvió `t`.

Se verificaron los siguientes valores:

| Parámetro | Valor |
|---|---|
| pgaudit.log | role, ddl |
| pgaudit.role | auditor_datos |
| pgaudit.log_relation | on |

Los tres parámetros mostraron `pending_restart = f`.

## 4. Pruebas de auditoría de objeto

Las pruebas se ejecutaron con el usuario `app_ventas`, utilizando la aplicación `app-ventas-web` y una conexión local mediante `127.0.0.1`.

### Prueba 1. Consulta de columnas no sensibles

```sql
SELECT nombre, ciudad
FROM clientes
WHERE id = 2;
```

La consulta se ejecutó correctamente.

No se identificó un evento `AUDIT: OBJECT` correspondiente a esta operación.

### Prueba 2. Consulta del RFC

```sql
SELECT nombre, rfc
FROM clientes
WHERE id = 3;
```

La consulta se ejecutó correctamente.

pgAudit generó un evento de auditoría de objeto:

- Tipo: `OBJECT`.
- Clase: `READ`.
- Comando: `SELECT`.
- Objeto: `public.clientes`.
- Línea de bitácora: 41.

### Prueba 3. Consulta de todas las columnas

```sql
SELECT *
FROM clientes
WHERE id = 4;
```

La consulta se ejecutó correctamente.

pgAudit generó un evento de auditoría de objeto:

- Tipo: `OBJECT`.
- Clase: `READ`.
- Comando: `SELECT`.
- Objeto: `public.clientes`.
- Línea de bitácora: 42.

### Prueba 4. Modificación del RFC

Se modificó el RFC del cliente con ID 1.

PostgreSQL respondió:

```text
UPDATE 1
```

pgAudit generó un evento:

- Tipo: `OBJECT`.
- Clase: `WRITE`.
- Comando: `UPDATE`.
- Objeto: `public.clientes`.
- Línea de bitácora: 44.

### Prueba 5. Modificación de ciudad

Se ejecutó:

```sql
UPDATE clientes
SET ciudad = 'Navolato'
WHERE id = 2;
```

PostgreSQL respondió:

```text
UPDATE 1
```

No se identificó un evento `AUDIT: OBJECT` correspondiente a esta operación.

Sin embargo, la modificación puede quedar registrada por los mecanismos de bitácora y auditoría mediante disparadores que ya estaban configurados.

## 5. Prueba de auditoría de sesión

Se verificó el permiso de consulta del usuario `soporte_ana`.

La función `has_table_privilege` devolvió `true`.

Posteriormente, se ejecutó:

```sql
GRANT SELECT ON clientes TO soporte_ana;
```

La instrucción se completó correctamente.

pgAudit generó el siguiente registro:

- Fecha: 16 de noviembre de 2026.
- Hora: 17:08:48.752 (UTC-07).
- Usuario: `postgres`.
- Tipo: `SESSION`.
- Clase: `ROLE`.
- Comando: `GRANT`.
- Línea de bitácora: 53.

Este evento demuestra que pgAudit registró una operación administrativa relacionada con privilegios.

El usuario `soporte_ana` ya tenía permiso de lectura antes de ejecutar el comando.

## 6. Resultados generales

| Operación | AUDIT: OBJECT | AUDIT: SESSION |
|---|---|---|
| SELECT nombre, ciudad | No | No |
| SELECT nombre, rfc | Sí | No |
| SELECT * | Sí | No |
| UPDATE rfc | Sí | No |
| UPDATE ciudad | No | No |
| GRANT SELECT | No | Sí |

Se identificaron tres eventos de auditoría de objeto y un evento de auditoría de sesión asociados a las pruebas.

## 7. Preguntas de análisis

### 1. ¿Por qué no apareció SELECT nombre, ciudad y por qué sí apareció SELECT *?

La consulta `SELECT nombre, ciudad` no generó un evento de auditoría de objeto porque esas columnas no forman parte de los privilegios seleccionados para el rol `auditor_datos`.

En cambio, `SELECT *` consulta todas las columnas de la tabla, incluyendo `rfc` y `telefono`.

Como estas columnas están incluidas en la configuración de auditoría de objeto, pgAudit registró la operación.

Esto demuestra que es posible seleccionar las columnas que requieren una supervisión especial.

### 2. ¿Por qué no apareció UPDATE ciudad?

Porque el rol `auditor_datos` no tiene privilegios de actualización sobre la columna `ciudad`.

La auditoría de objeto utiliza los permisos concedidos a ese rol para determinar qué operaciones deben registrarse.

Por lo tanto, actualizar una columna no incluida en el filtro no generó un evento `AUDIT: OBJECT`.

Esto no significa que la operación fuera invisible para todos los mecanismos de auditoría, ya que PostgreSQL también tiene configurado `log_statement = 'mod'` y un disparador que registra modificaciones de filas.

### 3. ¿Qué diferencia de volumen esperarías frente a log_statement = 'all'?

La configuración `log_statement = 'all'` registra todas las sentencias SQL procesadas por PostgreSQL, lo que puede generar una gran cantidad de información.

En cambio, la auditoría de objeto con pgAudit permite seleccionar operaciones sobre objetos y columnas que requieren especial supervisión.

En esta práctica, las consultas y modificaciones sobre `rfc` generaron registros de auditoría de objeto, mientras que las operaciones realizadas exclusivamente sobre `ciudad` no los generaron.

Esto puede reducir el volumen de información de auditoría de objeto y facilitar la identificación de acontecimientos relevantes.

Sin embargo, el volumen total depende también de las clases de auditoría de sesión habilitadas y de los demás mecanismos de registro del servidor.

### 4. ¿Qué implica que pgAudit no pueda auditar de forma confiable a los superusuarios?

Implica que no debemos depender exclusivamente de pgAudit para supervisar a los administradores con privilegios elevados.

Un superusuario tiene capacidades que pueden permitirle modificar parámetros de configuración, desactivar mecanismos de auditoría o intervenir sobre los registros del servidor.

Por lo tanto, la organización debe aplicar separación de funciones.

El personal encargado de administrar PostgreSQL no debería tener control exclusivo sobre las evidencias de auditoría.

Es recomendable conservar los registros en sistemas independientes, restringir el acceso a ellos y asignar su revisión a personal de seguridad o auditoría.

## 8. Conclusión

La actividad permitió implementar y comprobar la auditoría selectiva con pgAudit.

Se configuró un rol auditor sin acceso de conexión, cuyos privilegios se limitaron a las columnas sensibles `rfc` y `telefono`.

Las pruebas demostraron que pgAudit registró las consultas y modificaciones relacionadas con dichas columnas y omitió los eventos de auditoría de objeto correspondientes a operaciones sobre columnas no seleccionadas.

También se comprobó que el mecanismo de auditoría de sesión registró un cambio de privilegios mediante `GRANT`.

Finalmente, se comprendió la importancia de combinar la auditoría de objeto, la auditoría de sesión y otros controles de seguridad para obtener una supervisión más completa de las actividades realizadas en PostgreSQL.
