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
