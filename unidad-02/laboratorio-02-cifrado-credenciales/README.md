# LAB-02. Cifrado, credenciales y comunicaciones seguras

**Estudiante:** Wendy Guadalupe Mendoza Escobar  
**Grado y grupo:** 4-4  
**Docente:** Alexis Moises Montaño Araujo

## 1. Introducción

La seguridad de una base de datos no depende únicamente de los usuarios y permisos configurados. También es necesario proteger las credenciales, la información sensible, las comunicaciones y las claves criptográficas.

En este laboratorio se utilizaron PostgreSQL y la extensión `pgcrypto` para analizar diferentes mecanismos de protección.

Se realizaron prácticas de almacenamiento de contraseñas, generación y verificación de hashes, cifrado de información sensible y comprobación de conexiones mediante TLS.

También se analizaron los riesgos de exponer claves criptográficas en archivos SQL y repositorios Git.

## 2. Protección de credenciales

Se compararon tres conceptos relacionados con la protección de contraseñas:

- **Texto claro:** permite visualizar directamente la contraseña almacenada.
- **Hash de contraseñas:** genera una representación que permite verificar una contraseña sin recuperar su valor original.
- **Cifrado:** transforma información para que pueda recuperarse mediante una clave autorizada.

Para demostrar los riesgos del texto claro, se creó la tabla `lab02.usuarios_insegura` y se almacenó una contraseña ficticia.

Posteriormente, se utilizaron `crypt()` y `gen_salt('bf')` para generar hashes de contraseñas con bcrypt.

También se creó la tabla `lab02.usuarios_segura`, destinada a almacenar las credenciales protegidas.

Las pruebas de verificación devolvieron `t` para la contraseña correcta y `f` para una contraseña incorrecta.

Esto permitió comprobar que no es necesario recuperar la contraseña original para verificarla.

**Archivos relacionados:**

- [Script de credenciales](sql/01-credenciales.sql)
- [Evidencia de credenciales](evidencias/01-credenciales.md)

## 3. Protección de datos sensibles

Se protegió un RFC ficticio mediante cifrado simétrico utilizando las funciones `pgp_sym_encrypt()` y `pgp_sym_decrypt()` de PostgreSQL.

Se creó la tabla `lab02.clientes_protegidos`, que almacena el nombre del cliente y su RFC cifrado.

El RFC es información personal que requiere protección porque puede utilizarse para identificar a una persona.

Durante la práctica, se comprobó que el dato cifrado no se mostraba directamente como texto legible.

Al utilizar la clave correcta, PostgreSQL recuperó el RFC ficticio `LOPA900101ABC`.

Cuando se intentó utilizar una clave incorrecta, PostgreSQL devolvió un error de descifrado.

Esto demostró que el cifrado permite proteger información recuperable, pero su seguridad también depende de la protección de las claves y del control de acceso.

**Archivos relacionados:**

- [Script de cifrado](sql/02-cifrado-datos.sql)
- [Evidencia de cifrado](evidencias/02-cifrado-datos.md)

## 4. TLS

TLS es un protocolo que permite proteger las comunicaciones entre un cliente y un servidor mediante mecanismos de confidencialidad e integridad.

En PostgreSQL se verificó que SSL/TLS estaba habilitado, que la versión mínima configurada era TLS 1.2 y que el servidor utilizaba el puerto `5433`.

Primero se comprobó una conexión mediante socket Unix local.

La consulta a `pg_stat_ssl` devolvió `f`, indicando que esa sesión no utilizaba TLS.

Posteriormente, se creó el rol `lab02_tls` y se realizó una conexión TCP/IP mediante `psql` con el parámetro `sslmode=require`.

La nueva conexión devolvió los siguientes resultados:

| Parámetro | Resultado |
|---|---|
| Usuario | `lab02_tls` |
| Dirección | `127.0.0.1` |
| Puerto del servidor | `5433` |
| TLS utilizado | `t` |
| Versión TLS | `TLSv1.3` |
| Cifrado negociado | `TLS_AES_256_GCM_SHA384` |

Se comprobó que tener TLS habilitado en el servidor no significa que todas las sesiones lo utilicen.

También se identificó que `sslmode=require` exige cifrado, pero no realiza la validación completa de identidad del servidor que proporciona `verify-full`.

**Archivos relacionados:**

- [Consultas de verificación TLS](sql/03-verificacion-tls.sql)
- [Evidencia de TLS](evidencias/04-tls.md)

## 5. Gestión de claves

Se analizaron los riesgos de escribir claves criptográficas directamente en archivos SQL.

Una clave almacenada junto con un script puede quedar expuesta si el archivo se comparte o publica en un repositorio.

Además, eliminar una clave de la versión actual de un archivo no garantiza su eliminación del historial de Git.

Durante el laboratorio se creó un archivo temporal con una clave ficticia para analizar esta mala práctica. Después se eliminó, conforme a las instrucciones de la actividad.

También se elaboró una política de ocho reglas que contempla la generación, almacenamiento, acceso, rotación, respaldo, revocación, exposición accidental y eliminación de claves criptográficas.

En un entorno productivo, las claves deberían administrarse mediante mecanismos seguros de gestión de claves o secretos, separados de los scripts y repositorios.

**Archivos relacionados:**

- [Evidencia de gestión de claves](evidencias/03-gestion-claves.md)
- [Política de protección de claves](evidencias/10-politica-claves.md)

## 6. Resultados

Los principales resultados obtenidos durante el laboratorio fueron:

1. Se identificaron los riesgos de almacenar contraseñas en texto claro.
2. Se generaron hashes mediante bcrypt utilizando `crypt()` y `gen_salt('bf')`.
3. Se verificaron contraseñas correctas e incorrectas sin recuperar el valor original.
4. Se cifró y recuperó un RFC ficticio mediante funciones de `pgcrypto`.
5. Se comprobó el error producido por una clave de descifrado incorrecta.
6. Se verificó la configuración SSL/TLS de PostgreSQL.
7. Se comparó una conexión por socket Unix con una conexión TCP/IP protegida mediante TLS 1.3.
8. Se analizaron los riesgos relacionados con claves criptográficas, respaldos y repositorios.
9. Se realizaron búsquedas de posibles secretos mediante `grep`.
10. Se elaboró una política mínima de protección de claves criptográficas.

Las actividades demostraron que los mecanismos de seguridad deben utilizarse de manera complementaria.

## 7. Problemas encontrados

Durante el desarrollo se presentaron algunas dificultades técnicas.

**Autenticación mediante TCP/IP:** inicialmente se intentó realizar una conexión con TLS utilizando el usuario `postgres`, pero la autenticación solicitó una contraseña.

Al revisar las reglas de autenticación, se identificó que las conexiones TCP/IP locales utilizaban `scram-sha-256`, mientras que la conexión local mediante socket Unix utilizaba autenticación `peer`.

Para continuar, se creó un rol específico llamado `lab02_tls`, con permiso de inicio de sesión y sin privilegios de superusuario.

**Diferencia entre SSL habilitado y TLS utilizado:** inicialmente se observó que PostgreSQL tenía SSL habilitado, pero la sesión conectada mediante socket Unix no utilizaba TLS.

Esta situación se aclaró al establecer una conexión TCP/IP protegida y comprobar su estado mediante `pg_stat_ssl`.

**Gestión de claves:** se identificó que escribir claves directamente en consultas SQL representa una mala práctica, aunque los valores utilizados durante el laboratorio fueran ficticios.

**Revisión del repositorio:** las búsquedas mediante `grep` encontraron referencias a contraseñas, tokens y claves empleadas en ejemplos académicos. No se identificaron credenciales reales entre las coincidencias revisadas, aunque este procedimiento no garantiza detectar todos los secretos.

## 8. Conclusiones

Durante este laboratorio comprendí que la seguridad de una base de datos requiere diferentes mecanismos de protección.

Aprendí que las contraseñas deben almacenarse mediante funciones especializadas de hash, mientras que la información sensible que necesita recuperarse puede protegerse mediante cifrado.

También comprobé que TLS permite proteger las comunicaciones, pero no sustituye los controles de acceso de PostgreSQL.

Uno de los aprendizajes más importantes fue comprender que la seguridad del cifrado depende también de cómo se administran las claves criptográficas.

En un entorno productivo implementaría controles de acceso basados en mínimos privilegios, protección adecuada de credenciales, cifrado de datos sensibles, comunicaciones TLS con validación de certificados, gestión segura de claves y cifrado de respaldos.

También establecería procedimientos de auditoría, revisión de secretos y respuesta ante incidentes.

---

## 9. Preguntas de reflexión

### 1. ¿Por qué una contraseña no debe almacenarse como texto claro?

Porque cualquier persona que consiga acceso de lectura a los datos podría conocerla directamente. Además, su exposición podría permitir accesos no autorizados, especialmente si el usuario reutiliza la misma contraseña en otros servicios.

### 2. ¿Por qué un hash no es equivalente a un cifrado?

Porque el cifrado permite recuperar la información original mediante una clave autorizada, mientras que un hash de contraseñas está diseñado para verificar valores sin recuperar la contraseña original.

### 3. ¿Por qué el cifrado de una columna no sustituye al control de acceso?

Porque el cifrado protege la representación almacenada, pero no determina quién tiene autorización para consultar los datos o ejecutar funciones de descifrado. Es necesario restringir los permisos de los usuarios y aplicaciones.

### 4. ¿Por qué TLS no sustituye a los mecanismos de autorización de PostgreSQL?

Porque TLS protege la comunicación entre el cliente y el servidor, mientras que los mecanismos de autorización determinan qué operaciones puede realizar cada usuario dentro de la base de datos.

Una conexión cifrada no significa que el usuario tenga permiso para consultar o modificar todas las tablas.

### 5. ¿Qué ocurriría si una organización pierde una clave utilizada para cifrar información?

Si no dispone de una copia recuperable de la clave o de otro mecanismo autorizado de recuperación, podría perder el acceso a la información cifrada.

Por eso es importante contar con procedimientos seguros de respaldo y recuperación de claves.

### 6. ¿Qué ocurriría si una clave criptográfica se publica accidentalmente en GitLab?

La clave podría quedar expuesta a cualquier persona que tenga acceso al repositorio o a sus copias.

Además, aunque se elimine del archivo actual, podría permanecer en el historial de Git.

La organización debería considerar la clave comprometida, evaluar el incidente y proceder a su rotación o sustitución.

### 7. ¿Por qué un repositorio privado no debe considerarse un almacén de secretos?

Porque un repositorio privado sigue siendo accesible para determinadas personas y sistemas, y puede tener copias, integraciones o registros históricos.

Su privacidad reduce la exposición, pero no sustituye los controles específicos de almacenamiento y administración de secretos.

### 8. ¿Qué diferencia existe entre proteger información almacenada y proteger información durante su transmisión?

La protección de información almacenada busca evitar el acceso no autorizado a datos que se encuentran guardados, por ejemplo, en tablas o respaldos.

La protección durante la transmisión busca evitar que terceros observen o alteren la información mientras viaja entre sistemas.

El cifrado de datos almacenados y TLS son mecanismos complementarios.

### 9. ¿Por qué la gestión de claves es tan importante como el algoritmo criptográfico?

Porque un algoritmo seguro puede perder su utilidad si las claves utilizadas quedan expuestas.

La gestión de claves permite controlar su generación, almacenamiento, acceso, rotación, respaldo, revocación y eliminación.

Si una clave se compromete, también puede quedar comprometida la información que protege.

### 10. ¿Qué mecanismo adicional implementarías en una organización para proteger los respaldos de las bases de datos?

Implementaría cifrado de respaldos con claves administradas de forma independiente, acompañado de controles de acceso y almacenamiento protegido.

También utilizaría copias aisladas o inmutables cuando fuera posible y realizaría pruebas periódicas de restauración para comprobar que la información puede recuperarse.

---

## 10. Archivos del laboratorio

### Scripts SQL

- [Protección de credenciales](sql/01-credenciales.sql)
- [Cifrado de datos sensibles](sql/02-cifrado-datos.sql)
- [Verificación de TLS](sql/03-verificacion-tls.sql)

### Evidencias

- [01. Protección de credenciales](evidencias/01-credenciales.md)
- [02. Cifrado de datos sensibles](evidencias/02-cifrado-datos.md)
- [03. Gestión de claves](evidencias/03-gestion-claves.md)
- [04. Protección de comunicaciones y TLS](evidencias/04-tls.md)
- [07. Comparación de mecanismos de protección](evidencias/07-comparacion.md)
- [08. Análisis de un escenario de seguridad](evidencias/08-analisis-escenario.md)
- [10. Política de protección de claves](evidencias/10-politica-claves.md)

### Documentación complementaria

- [Desarrollo de las diez actividades](desarrollo-actividades.md)
