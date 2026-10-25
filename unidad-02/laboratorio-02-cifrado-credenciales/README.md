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
