# Actividad 8. Análisis de un escenario de seguridad

## Objetivo

Identificar riesgos relacionados con la protección de credenciales, información sensible, comunicaciones, claves criptográficas y respaldos, proponiendo mecanismos adecuados para reducirlos.

## Procedimiento

Se analizó el escenario de una empresa que cuenta con usuarios y roles correctamente configurados, pero presenta deficiencias en otros mecanismos de seguridad.

Se identificaron los principales riesgos y se relacionaron con los mecanismos estudiados durante el laboratorio.

## Pregunta 1. ¿Cuáles son los principales riesgos?

Los principales riesgos son:

1. **Exposición de credenciales:** las contraseñas almacenadas en texto claro pueden ser utilizadas por personas no autorizadas si consiguen acceso a la información.

2. **Divulgación de datos personales:** los RFC almacenados sin cifrado pueden quedar expuestos ante accesos indebidos o filtraciones.

3. **Intercepción de comunicaciones:** una conexión que no valida adecuadamente la identidad del servidor podría permitir que un atacante suplante al servidor y comprometa la información transmitida.

4. **Exposición de claves criptográficas:** almacenar claves directamente en archivos SQL facilita que sean divulgadas mediante repositorios, respaldos o archivos compartidos.

5. **Exposición de respaldos:** una copia de seguridad sin protección adicional podría permitir recuperar información sensible fuera del servidor original.

## Pregunta 2. ¿Qué mecanismo utilizarías para cada elemento?

| Elemento | Mecanismo de protección |
|---|---|
| Nombre | Control de acceso y protección de datos personales según su clasificación. |
| Correo electrónico | Control de acceso y enmascaramiento cuando no sea necesario mostrarlo completo. |
| Contraseña | Hash especializado para contraseñas, como Argon2id o bcrypt, utilizando una sal adecuada. |
| RFC | Cifrado de datos y permisos que restrinjan su recuperación. |
| Información financiera | Cifrado, control de acceso y auditoría de consultas. |
| Claves criptográficas | Sistema de gestión de claves o secretos, separado de los archivos SQL y del repositorio. |
| Comunicaciones | TLS con validación adecuada del certificado del servidor, preferentemente mediante `sslmode=verify-full`. |
| Respaldos | Cifrado de las copias de seguridad, almacenamiento seguro y acceso restringido. |

## Pregunta 3. ¿Cuál de los problemas consideras más crítico y por qué?

Considero especialmente crítica la exposición de las claves criptográficas.

Si una persona obtiene una clave utilizada para cifrar información y también consigue los datos protegidos, podría descifrarlos y acceder a información confidencial.

Además, cuando una clave se publica en un repositorio Git, eliminarla del archivo actual no garantiza que desaparezca del historial.

Por esta razón, una clave comprometida debe tratarse como expuesta y sustituirse siguiendo un procedimiento de rotación.

Las contraseñas almacenadas en texto claro también representan un riesgo grave, porque permiten comprometer directamente las credenciales de los usuarios.

## Pregunta 4. ¿Tener correctamente configurados los usuarios y permisos elimina estos riesgos?

No. Aunque los usuarios y permisos estén configurados correctamente, siguen existiendo otros riesgos.

Por ejemplo, si las contraseñas están almacenadas en texto claro, una filtración de la base de datos podría exponerlas.

De igual manera, los permisos de PostgreSQL no protegen automáticamente los archivos SQL que contienen claves, las comunicaciones mal verificadas ni las copias de seguridad almacenadas sin cifrado.

Por eso es necesario implementar diferentes medidas de seguridad que funcionen de manera complementaria.

## Resultado obtenido

Se identificaron cinco problemas principales de seguridad y se propusieron mecanismos de protección adecuados para los diferentes tipos de información.

También se determinó que una correcta configuración de usuarios y roles no garantiza por sí sola la seguridad de todos los componentes del sistema.

## Análisis

La seguridad de una base de datos debe abordarse de manera integral.

Los controles de acceso restringen las operaciones que pueden realizar los usuarios autorizados, mientras que el hash, el cifrado, TLS y la gestión de claves protegen otros aspectos de la información.

Estos mecanismos deben complementarse con medidas de protección de respaldos, auditoría y procedimientos de respuesta ante incidentes.

## Conclusión

Una base de datos puede tener permisos correctamente configurados y continuar siendo vulnerable si utiliza mecanismos inadecuados para proteger contraseñas, datos sensibles, comunicaciones o claves criptográficas.

Como administradores de bases de datos, debemos identificar los riesgos específicos de cada elemento y aplicar diferentes mecanismos de protección de manera conjunta.
