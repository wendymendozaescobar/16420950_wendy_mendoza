# LAB-02 - Cifrado, credenciales y comunicaciones seguras

**Estudiante:** Wendy Guadalupe Mendoza Escobar
**Grado y grupo:** 4-4
**Docente:** Alexis Moises Montaño Araujo

## Objetivo

Aplicar mecanismos de protección de credenciales,
cifrado de datos y comunicaciones seguras en PostgreSQL.

## Desarrollo de actividades

### Actividad 1. Protección de credenciales

En esta actividad se analizaron los riesgos de almacenar
contraseñas en texto plano y se implementó un mecanismo
de hash mediante las funciones crypt() y gen_salt()
de PostgreSQL.

#### Resultados

Se comprobó que una contraseña almacenada en texto plano
puede visualizarse directamente al consultar la tabla.

Posteriormente, se generaron hashes con sales aleatorias
y se creó una tabla para almacenar credenciales protegidas.

Al verificar la contraseña correcta, PostgreSQL devolvió
`t` (verdadero), mientras que con una contraseña incorrecta
devolvió `f` (falso).

#### Consideraciones de seguridad

En aplicaciones reales deben utilizarse algoritmos
especializados y actualizados para proteger contraseñas.
No deben almacenarse en texto plano ni cifrarse con
una clave fija para recuperarlas posteriormente.

#### Evidencias

- [Comandos SQL](sql/01-credenciales.sql)
- [Resultados y preguntas](evidencias/01-credenciales.md)

### Actividad 2. Cifrado de información sensible

En esta actividad implementamos cifrado simétrico utilizando las funciones `pgp_sym_encrypt()` y `pgp_sym_decrypt()` de PostgreSQL.

Se creó una tabla llamada `clientes_protegidos`, donde almacenamos un RFC ficticio en formato cifrado mediante una clave de prueba.

#### Resultados

Al consultar la tabla, comprobamos que el RFC no aparecía directamente como texto legible.

Posteriormente, utilizamos la clave correcta para descifrarlo y PostgreSQL recuperó el valor original `LOPA900101ABC`.

También realizamos una prueba con una clave incorrecta y PostgreSQL mostró un error de descifrado.

#### Consideraciones de seguridad

El cifrado simétrico permite recuperar información protegida cuando se dispone de la clave correcta.

Sin embargo, la seguridad también depende de cómo se administran las claves. En aplicaciones reales, estas no deben almacenarse directamente en consultas SQL ni publicarse en repositorios.

#### Evidencias

- [Comandos SQL](sql/02-cifrado-datos.sql)
- [Resultados y preguntas](evidencias/02-cifrado-datos.md)

### Actividad 3. Gestión de claves

Se analizaron los riesgos de almacenar claves criptográficas
directamente en archivos SQL y repositorios Git.

#### Procedimiento y resultados

Se creó un archivo temporal que contenía una consulta
de descifrado con una clave ficticia.

Se identificó que publicar este tipo de archivos puede
exponer las claves utilizadas para proteger información.

Después del análisis se eliminó el archivo temporal,
siguiendo las instrucciones del laboratorio.

#### Conclusión

La seguridad de los datos cifrados depende también
de la protección de sus claves criptográficas.

Eliminar una clave expuesta del archivo no garantiza
su eliminación del historial de Git.

#### Evidencia

- [Gestión de claves](evidencias/03-gestion-claves.md)

### Actividad 4. Protección de datos durante la comunicación

Se analizó la importancia de proteger la información transmitida entre los clientes y PostgreSQL.

Se identificó que TLS proporciona mecanismos de confidencialidad, integridad y autenticación para las comunicaciones.

### Actividad 5. Verificación del estado de TLS

Se consultó la configuración SSL/TLS del servidor PostgreSQL y se verificó el estado de la conexión actual.

#### Resultados

PostgreSQL tenía SSL/TLS habilitado, con TLS 1.2 como versión mínima y el puerto 5433 configurado.

Sin embargo, la conexión actual no utilizaba TLS porque se estableció mediante un socket Unix local.

Esto permitió comprender la diferencia entre tener TLS habilitado en el servidor y utilizarlo realmente en una conexión.

#### Evidencias

- [Comandos de verificación TLS](sql/03-verificacion-tls.sql)
- [Resultados y análisis de TLS](evidencias/04-tls.md)

### Actividad 6. Conexión mediante psql

Se estableció una conexión TCP/IP a PostgreSQL utilizando el parámetro `sslmode=require`.

Para realizar la prueba se creó el rol `lab02_tls`, con permisos limitados y autenticación mediante contraseña.

#### Resultados

Se verificó que la conexión utilizaba TLS 1.3 y la suite criptográfica `TLS_AES_256_GCM_SHA384`.

A diferencia de la conexión mediante socket Unix utilizada anteriormente, esta sesión sí empleaba TLS.

#### Conclusión

Se comprobó que las conexiones TCP/IP pueden protegerse mediante TLS y que es necesario verificar el estado real de cada sesión.

También se identificó que solicitar TLS no equivale a validar completamente la identidad del servidor.

#### Evidencias

- [Consultas SQL](sql/03-verificacion-tls.sql)
- [Resultados de TLS](evidencias/04-tls.md)

### Actividad 7. Comparación de protección en reposo y en tránsito

Se analizaron diferentes situaciones que requieren mecanismos de seguridad específicos.

Se identificó que las contraseñas deben protegerse mediante funciones especializadas de hash, mientras que los datos sensibles recuperables pueden protegerse mediante cifrado.

También se determinó que TLS protege las comunicaciones, el cifrado de respaldos protege las copias de seguridad y la gestión de claves permite administrar adecuadamente los secretos criptográficos.

#### Conclusión

La protección de la información debe realizarse mediante diferentes mecanismos complementarios, dependiendo del tipo de dato y del riesgo identificado.

#### Evidencia

- [Comparación de mecanismos de protección](evidencias/07-comparacion.md)
