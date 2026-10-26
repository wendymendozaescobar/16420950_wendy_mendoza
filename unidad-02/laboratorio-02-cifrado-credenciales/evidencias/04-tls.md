# Actividades 4 y 5. Protección de comunicaciones y verificación de TLS

## Objetivo

Comprender la importancia de proteger la información durante su transmisión y verificar si PostgreSQL tiene habilitado TLS y si la conexión actual lo utiliza.

## Actividad 4. Protección de datos durante la comunicación

Cuando un cliente realiza una consulta a PostgreSQL, la información se transmite entre el cliente y el servidor.

Si se utiliza una conexión de red sin protección, una persona con acceso al tráfico podría intentar observar la información transmitida.

TLS permite proteger las comunicaciones mediante mecanismos de confidencialidad, integridad y autenticación.

## Actividad 5. Verificación del estado de TLS

### Procedimiento

Se ejecutaron consultas para comprobar la configuración SSL/TLS del servidor PostgreSQL y verificar el estado de la conexión actual.

Los comandos utilizados se encuentran en `../sql/03-verificacion-tls.sql`.

También se utilizó el metacomando `\conninfo` para consultar la información de la conexión.

### Resultados obtenidos

| Comprobación | Resultado |
|---|---|
| Estado de SSL/TLS del servidor | `on` |
| Versión mínima de TLS | `TLSv1.2` |
| Puerto de PostgreSQL | `5433` |
| Direcciones de escucha | `localhost` |
| Dirección IP del cliente | `NULL` |
| Puerto del cliente | `NULL` |
| Directorio del socket | `/var/run/postgresql` |
| TLS en la conexión actual | `f` |
| Versión TLS de la conexión | `NULL` |
| Algoritmo de cifrado de la conexión | `NULL` |

### Preguntas del profesor

**1. ¿La conexión actual utiliza TLS?**

No. La consulta a `pg_stat_ssl` devolvió `f`, porque la sesión actual utiliza un socket Unix local.

**2. ¿Qué versión de TLS se está utilizando?**

La conexión actual no utiliza ninguna versión de TLS. Sin embargo, el servidor tiene configurada TLS 1.2 como versión mínima aceptada.

**3. ¿Qué algoritmo de cifrado aparece?**

No aparece ningún algoritmo de cifrado TLS porque la sesión actual no utiliza TLS.

**4. ¿Qué diferencia existe entre una conexión protegida con TLS y una conexión sin TLS?**

TLS permite cifrar la información transmitida y proporciona mecanismos de integridad. También permite verificar la identidad del servidor cuando se configura correctamente la validación de certificados.

Una conexión TCP sin TLS no cuenta con esas protecciones criptográficas.

## Análisis

Se identificó que tener TLS habilitado en PostgreSQL no significa que todas las conexiones lo utilicen.

En esta práctica, el servidor tenía SSL/TLS habilitado, pero la conexión se realizó mediante un socket Unix local.

Por eso `pg_stat_ssl` devolvió `f`, sin una versión TLS ni un algoritmo de cifrado negociado.

Una conexión local mediante socket Unix no equivale a una conexión TCP sin protección, porque utiliza un mecanismo de comunicación diferente.

## Conclusión

La protección de datos durante su transmisión es diferente de la protección de los datos almacenados.

Comprobamos que PostgreSQL puede tener TLS habilitado sin que una sesión determinada lo esté utilizando.

Por ello, no basta con revisar la configuración general del servidor: también es necesario verificar las características de cada conexión.

## Actividad 6. Conexión mediante psql

### Objetivo

Establecer una conexión TCP/IP protegida mediante TLS y comprobar las características de seguridad de la sesión.

### Procedimiento

Primero se revisaron las reglas de autenticación de PostgreSQL. Se identificó que las conexiones TCP/IP locales utilizan `scram-sha-256`.

Se creó el rol `lab02_tls` con permiso de inicio de sesión y se configuró una contraseña de prueba mediante `\password`, sin incluirla en los archivos del laboratorio.

Posteriormente se estableció una conexión utilizando:

```bash
psql "host=127.0.0.1 port=5433 dbname=laboratorios_unidad2 user=lab02_tls sslmode=require"
```

Se verificó la conexión mediante `\conninfo` y consultas a `pg_stat_ssl`.

### Resultados obtenidos

| Parámetro | Resultado |
|---|---|
| Usuario | `lab02_tls` |
| Dirección del servidor | `127.0.0.1` |
| Puerto del servidor | `5433` |
| TLS habilitado en la sesión | `t` |
| Versión TLS | `TLSv1.3` |
| Algoritmo negociado | `TLS_AES_256_GCM_SHA384` |
| Superusuario | No |

### Análisis

En la Actividad 5, la conexión mediante socket Unix no utilizaba TLS.

En esta actividad se estableció una conexión TCP/IP solicitando TLS mediante `sslmode=require`.

La consulta a `pg_stat_ssl` confirmó que la nueva conexión estaba cifrada mediante TLS 1.3.

También se comprobó que `sslmode=require` exige cifrado, pero no proporciona la validación completa de identidad del servidor que ofrece `verify-full`.

### Conclusión

Se consiguió establecer y verificar una conexión TCP/IP protegida mediante TLS.

La práctica permitió comprender que la configuración general de PostgreSQL y el estado de seguridad de una sesión son cuestiones diferentes.

También se comprobó la importancia de utilizar roles con permisos limitados para las conexiones de prueba.
