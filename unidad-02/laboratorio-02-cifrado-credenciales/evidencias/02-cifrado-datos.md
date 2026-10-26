# Actividad 2. Cifrado de información sensible

## Objetivo

Proteger información sensible almacenada en PostgreSQL
mediante cifrado simétrico y comprobar que únicamente
puede recuperarse utilizando la clave correcta.

## Procedimiento

Primero se creó la tabla `lab02.clientes_protegidos`
para almacenar el nombre de un cliente y su RFC cifrado.

Después se utilizó la función `pgp_sym_encrypt()`
para cifrar un RFC ficticio antes de almacenarlo.

Posteriormente se utilizó `pgp_sym_decrypt()` para
recuperar el dato original mediante la clave correcta.

Finalmente, se repitió la operación con una clave
incorrecta para observar el comportamiento de PostgreSQL.

Los comandos utilizados se encuentran en
`../sql/02-cifrado-datos.sql`.

## 8.1 Cifrado de datos

Se creó la tabla `lab02.clientes_protegidos` para almacenar el nombre y el RFC cifrado de un cliente.

Se utilizó la función `pgp_sym_encrypt()` con una clave ficticia para proteger el RFC.

**Resultado:** PostgreSQL confirmó la inserción con `INSERT 0 1`. Al consultar la tabla, el RFC se encontraba almacenado como información cifrada.

## 8.2 Recuperación del dato

Utilizamos `pgp_sym_decrypt()` con la clave correcta para recuperar el RFC original.

**Resultado:** PostgreSQL mostró el RFC `LOPA900101ABC`, correspondiente a Ana López.

También realizamos una prueba utilizando una clave incorrecta.

**Resultado:** PostgreSQL mostró un error porque no fue posible descifrar la información con esa clave.

## Preguntas

**1. ¿Qué diferencia existe entre `crypt()` y `pgp_sym_encrypt()`?**

`crypt()` genera un hash de contraseña que no está diseñado para revertirse. En cambio, `pgp_sym_encrypt()` cifra información que puede recuperarse posteriormente utilizando la clave correspondiente.

**2. ¿Cuál de los dos mecanismos permite recuperar el dato original?**

`pgp_sym_encrypt()`, porque permite recuperar el dato original mediante `pgp_sym_decrypt()` y la clave correcta.

**3. ¿Qué ocurre si se utiliza una clave incorrecta?**

PostgreSQL no puede descifrar correctamente la información y muestra un error. Lo comprobamos durante la práctica utilizando una clave diferente a la original.

**4. ¿Qué problema de seguridad representa colocar la clave directamente en una consulta?**

La clave podría quedar expuesta en el historial de comandos, registros del sistema o archivos compartidos. Si una persona obtiene la clave y los datos cifrados, podría recuperar la información original.

## Análisis

El cifrado simétrico permite proteger información que necesitamos recuperar posteriormente.

Sin embargo, su seguridad también depende de proteger adecuadamente las claves. En una aplicación real no deberíamos escribir claves secretas directamente en las consultas ni publicarlas en repositorios.

## Conclusión

Se comprobó que el cifrado simétrico permite proteger
información sensible y recuperarla cuando se dispone
de la clave correcta.

Durante la práctica logramos recuperar el RFC ficticio
que habíamos cifrado. También observamos que PostgreSQL
mostró un error cuando intentamos descifrarlo utilizando
una clave incorrecta.

Aprendimos que el cifrado no sustituye los controles
de acceso y que las claves criptográficas deben
protegerse adecuadamente.

En un entorno real utilizaríamos mecanismos seguros
para administrar las claves, evitando incluirlas
directamente en los scripts SQL.
