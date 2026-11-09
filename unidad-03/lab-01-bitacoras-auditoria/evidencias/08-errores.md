
# Actividad 8 — Errores y operaciones rechazadas

## Objetivo

Comprobar cómo PostgreSQL registra las operaciones rechazadas por falta de privilegios y los errores producidos por dependencias entre objetos de la base de datos.

También se busca distinguir los errores de autenticación de los errores de autorización.

## Entorno de trabajo

- Sistema operativo: Ubuntu.
- PostgreSQL: 18.6.
- Puerto: `5433`.
- Base de datos: `comercial`.
- Usuario administrador: `postgres`.
- Usuario de soporte: `soporte_ana`.
- Configuración: `log_statement = 'mod'`.
- Registro de sentencias con errores: `log_min_error_statement = 'error'`.

## 1. Intento de eliminación sin autorización

Se estableció una conexión a PostgreSQL utilizando el usuario `soporte_ana`.

Posteriormente, se intentó ejecutar:

```sql
DELETE FROM clientes WHERE id = 5;
```

PostgreSQL devolvió el siguiente mensaje:

```text
ERROR: permiso denegado a la tabla clientes
```

La operación fue rechazada porque `soporte_ana` dispone del privilegio `SELECT`, pero no tiene concedido `DELETE` sobre la tabla `clientes`.

Durante las pruebas se realizaron varios intentos, todos rechazados por falta de permisos.

También se produjo un intento fallido de autenticación al introducir una contraseña incorrecta.

## 2. Verificación de la integridad de los datos

Para comprobar que el intento de eliminación no afectó la información, se ejecutó:

```sql
SELECT
    id,
    nombre
FROM clientes
WHERE id = 5;
```

El resultado fue:

| ID | Nombre |
|---|---|
| 5 | Laura Sánchez |

Esto confirmó que PostgreSQL impidió la eliminación y que el registro seguía existiendo.

## 3. Intento de eliminar un rol con dependencias

Utilizando la cuenta administradora `postgres`, se ejecutó:

```sql
DROP ROLE soporte_ana;
```

PostgreSQL respondió:

```text
ERROR: no se puede eliminar el rol «soporte_ana»
porque otros objetos dependen de él

DETALLE: privilegios para tabla clientes
```

El error se produjo porque el rol todavía tenía privilegios asociados con la tabla `clientes`.

Posteriormente, se repitió la prueba dentro de una transacción:

```sql
BEGIN;

DROP ROLE soporte_ana;

ROLLBACK;
```

La operación `DROP ROLE` volvió a ser rechazada.

Después del error se ejecutó `ROLLBACK`, finalizando la transacción sin confirmar cambios.

## 4. Verificación de la existencia del rol

Se ejecutó:

```sql
SELECT
    rolname,
    rolcanlogin
FROM pg_roles
WHERE rolname = 'soporte_ana';
```

El resultado fue:

| Rol | Puede iniciar sesión |
|---|---|
| `soporte_ana` | `true` |

Esto confirmó que el usuario no había sido eliminado.

## 5. Investigación de los errores en la bitácora

Se utilizó la vista administrativa `dba.bitacora` para localizar las operaciones rechazadas.

La consulta utilizada fue:

```sql
SELECT
    num,
    LEFT(linea, 250) AS evento
FROM dba.bitacora
WHERE linea ILIKE '%soporte_ana%'
   OR linea ILIKE '%DELETE FROM clientes%'
   OR linea ILIKE '%privilegios para la tabla%'
   OR linea ILIKE '%privileges for table%'
ORDER BY num DESC
LIMIT 25;
```

La consulta devolvió 25 líneas, debido al límite establecido.

Entre los eventos encontrados se identificaron:

- Intentos de eliminación de clientes realizados por `soporte_ana`.
- Mensajes `ERROR` indicando falta de permisos.
- Sentencias `DELETE` asociadas con los errores.
- Un intento fallido de autenticación de `soporte_ana`.
- Intentos de eliminación del rol `soporte_ana`.
- Mensajes `ERROR` indicando dependencias que impedían eliminar el rol.
- Sentencias `DROP ROLE` asociadas con dichos errores.

Los registros permitieron identificar los usuarios, las operaciones solicitadas y los motivos de rechazo.

## Preguntas de análisis

### 1. ¿El intento de soporte_ana causó algún daño? ¿Por qué debe auditarse de todos modos?

No se produjo la eliminación del registro, porque PostgreSQL rechazó la operación al comprobar que `soporte_ana` no tenía el privilegio `DELETE`.

Durante la práctica verificamos que Laura Sánchez continuaba en la tabla `clientes`.

Sin embargo, el intento debe auditarse porque representa una operación no autorizada.

Aunque no haya modificado datos, puede indicar un error de una aplicación, una configuración incorrecta o un comportamiento sospechoso.

Registrar estas operaciones permite investigar incidentes, detectar patrones y comprobar que los controles de acceso funcionan correctamente.

### 2. ¿Qué diferencia hay entre un error de autorización y uno de autenticación?

La autenticación consiste en comprobar la identidad del usuario que intenta conectarse.

Por ejemplo, durante la práctica se produjo un error de autenticación cuando se introdujo una contraseña incorrecta para `soporte_ana`.

En cambio, la autorización determina qué operaciones puede realizar un usuario después de autenticarse.

Cuando `soporte_ana` intentó ejecutar `DELETE`, PostgreSQL aceptó sus credenciales, pero rechazó la operación porque no tenía el privilegio necesario.

Por lo tanto:

- Un error de autenticación impide establecer la sesión.
- Un error de autorización impide realizar una operación para la cual el usuario no tiene permisos.

Ambos tipos de errores son relevantes para una auditoría de seguridad.

### 3. ¿Qué indica el error de DROP ROLE sobre el orden correcto para dar de baja a un usuario?

El error demuestra que no siempre es posible eliminar un rol inmediatamente, porque puede tener privilegios o dependencias asociadas con objetos de la base de datos.

Antes de eliminar una cuenta, es necesario revisar sus permisos, pertenencias y dependencias.

Un procedimiento adecuado consiste en identificar los objetos relacionados, determinar qué privilegios deben revocarse y transferir las responsabilidades necesarias antes de eliminar definitivamente el rol.

En el laboratorio, PostgreSQL impidió eliminar `soporte_ana` porque todavía tenía privilegios sobre la tabla `clientes`.

Esta protección evita que se eliminen roles sin considerar sus relaciones con otros objetos de la base de datos.

## Análisis

La actividad permitió comprobar que PostgreSQL aplica controles de autorización y conserva registros de las operaciones rechazadas.

También se identificó que los errores de sentencias pueden registrarse mediante `log_min_error_statement`, independientemente del nivel configurado en `log_statement`.

Los mensajes de la bitácora permiten relacionar el usuario, la operación y el error producido.

Sin embargo, los eventos deben interpretarse según su contexto, porque una autenticación fallida, una operación sin autorización y un error por dependencias representan situaciones diferentes.

## Conclusión

Se comprobó que PostgreSQL impide la eliminación de registros cuando un usuario no dispone de los permisos necesarios.

También se verificó que el servidor protege las dependencias entre roles y objetos, evitando eliminar usuarios que todavía tienen privilegios asociados.

La bitácora permitió identificar los errores y las sentencias relacionadas con las operaciones rechazadas.

La principal enseñanza es que **los eventos fallidos también deben auditarse**, porque proporcionan información importante para investigar problemas de seguridad y comprobar el funcionamiento de los controles de acceso.
