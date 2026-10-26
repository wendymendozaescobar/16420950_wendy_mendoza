# Línea base de seguridad de PostgreSQL

## Actividad 19. Construcción de una línea base

### Objetivo

Establecer una propuesta de configuración segura para PostgreSQL, considerando controles de red, autenticación, autorización, configuración, sistema operativo, cifrado y mantenimiento.

### Entorno

El profesor plantea PostgreSQL 16 como referencia para el laboratorio. La inspección práctica se realizó en PostgreSQL 18.6 sobre Ubuntu, utilizando el puerto `5433` y la base de datos `laboratorios_unidad2`.

La presente línea base distingue los controles ya comprobados de las recomendaciones pendientes de implementación.

No representa una configuración aplicada completamente al servidor.

## 1. Red

| Control | Estado actual | Línea base propuesta |
|---|---|---|
| Interfaces autorizadas | `listen_addresses = 'localhost'` | Escuchar únicamente en las interfaces necesarias para el funcionamiento del sistema. |
| Puerto | `5433` | Mantener documentado el puerto utilizado. No considerar el cambio de puerto como una medida suficiente de seguridad. |
| Firewall | Se elaboró una política conceptual. No se comprobó una política efectiva completa. | Permitir conexiones únicamente desde redes autorizadas y denegar los orígenes innecesarios. |
| Redes permitidas | El servidor escucha en `127.0.0.1:5433` y las reglas TCP inspeccionadas contemplan direcciones locales. | Aplicar restricciones específicas según las necesidades de las aplicaciones y administradores. |

**Justificación**

Reducir las interfaces y redes autorizadas disminuye la superficie de ataque.

En nuestro laboratorio no se requieren conexiones TCP desde equipos externos, por lo que la configuración local debe conservarse mientras no exista una necesidad justificada.

## 2. Autenticación

| Control | Estado actual | Línea base propuesta |
|---|---|---|
| Método de autenticación | `scram-sha-256` para conexiones TCP locales y `peer` para determinados accesos mediante sockets Unix. | Utilizar métodos adecuados para cada tipo de conexión y evitar autenticación insegura. |
| Política de credenciales | Se revisó `password_encryption = scram-sha-256`. No se auditó la política completa de contraseñas. | Establecer credenciales individuales, protegerlas y definir procedimientos de rotación y revocación según los riesgos. |
| Cuentas administrativas | Se identificó `postgres` como superusuario. | Reservar las cuentas administrativas para actividades que requieran sus privilegios. |

**Justificación**

La autenticación permite verificar la identidad de los usuarios, pero debe complementarse con controles de autorización.

Las aplicaciones no deben utilizar credenciales administrativas para realizar operaciones habituales.

## 3. Autorización

| Control | Estado actual | Línea base propuesta |
|---|---|---|
| Roles | Se identificaron `postgres`, `lab02_tls`, `analista` y `soporte`, además de los roles predefinidos. | Asignar roles de acuerdo con las responsabilidades de cada usuario o aplicación. |
| Privilegios | Se revisaron los atributos administrativos de los roles, pero no todos los permisos sobre objetos. | Aplicar el principio de mínimo privilegio y revisar periódicamente las concesiones. |
| Cuentas de aplicación | Se propuso una separación conceptual entre DBA, APP y CONSULTA. | Utilizar cuentas de aplicación independientes de las administrativas, con permisos limitados. |

**Justificación**

Una cuenta debe tener solamente los privilegios necesarios para desarrollar sus funciones.

Separar las cuentas administrativas, de aplicación y de consulta permite reducir el impacto de credenciales comprometidas.

## 4. Configuración

| Control | Estado actual | Línea base propuesta |
|---|---|---|
| Parámetros relevantes | `max_connections = 100`, `statement_timeout = 0` e `idle_in_transaction_session_timeout = 0`. | Establecer límites justificados según la carga, los recursos y las necesidades de las aplicaciones. |
| Extensiones | `pgcrypto` 1.4 y `plpgsql` 1.0. | Conservar únicamente las extensiones necesarias, después de comprobar sus funciones y dependencias. |
| Conexiones | Tres conexiones reservadas para superusuarios. | Mantener capacidad administrativa y supervisar el consumo de conexiones. |
| Reglas de acceso | Se inspeccionaron siete reglas de `pg_hba.conf`. | Documentar las reglas y restringir usuarios, bases de datos, métodos y orígenes según las necesidades reales. |
| Registro de eventos | `log_connections` presenta un valor vacío y `log_disconnections` está en `off`. | Evaluar una política de registros que permita investigar conexiones, errores e incidentes sin generar información excesiva. |

**Justificación**

Una configuración segura debe equilibrar protección, rendimiento y disponibilidad.

No es adecuado establecer tiempos de espera arbitrarios sin considerar el funcionamiento de las aplicaciones.

Los cambios deben probarse antes de aplicarse y documentarse para permitir su revisión.

## 5. Sistema operativo

| Control | Estado actual | Línea base propuesta |
|---|---|---|
| Propietario de archivos | `postgres` es propietario de los archivos y directorios inspeccionados. | Mantener propietarios autorizados para los recursos del servicio. |
| Permisos de configuración | `postgresql.conf` y `pg_hba.conf` tienen permisos `640`. | Restringir la lectura y modificación de archivos sensibles a usuarios autorizados. |
| Directorio de datos | `/var/lib/postgresql/18/main` tiene permisos `700`. | Mantener el acceso al directorio de datos restringido. |
| Directorio de configuración | `/etc/postgresql/18/main` tiene permisos `755`. | Revisar que los permisos de los archivos internos impidan accesos no autorizados. |

**Justificación**

Los permisos de PostgreSQL sobre las tablas no sustituyen los controles del sistema operativo.

También es necesario proteger los archivos físicos, los directorios de datos y la configuración del servidor.

## 6. Cifrado

| Control | Estado actual | Línea base propuesta |
|---|---|---|
| TLS | `ssl = on`; versión mínima TLS 1.2. Se verificó una conexión TLS 1.3. | Utilizar TLS en conexiones de red que lo requieran y verificar su funcionamiento. |
| Verificación de identidad | La prueba utilizó `sslmode=require`. | Utilizar validación del certificado y de la identidad del servidor, por ejemplo `verify-full`, cuando corresponda y exista una infraestructura de certificados adecuada. |
| Protección de credenciales | Se comprobó la configuración SCRAM-SHA-256 para nuevas contraseñas. | Evitar contraseñas en texto plano dentro de scripts y repositorios. |
| Información sensible | En laboratorios anteriores se utilizaron funciones criptográficas de `pgcrypto`. | Evaluar el cifrado y otros mecanismos de protección según la sensibilidad de los datos. |

**Justificación**

El cifrado protege la información durante su transmisión o almacenamiento, según el mecanismo utilizado.

Sin embargo, habilitar TLS no demuestra por sí solo que todas las conexiones estén cifradas ni que el cliente valide la identidad del servidor.

## 7. Mantenimiento

| Control | Estado actual | Línea base propuesta |
|---|---|---|
| Actualizaciones | Se identificó PostgreSQL 18.6. No se documentó una política completa de actualizaciones. | Establecer un procedimiento para evaluar, probar y aplicar actualizaciones de seguridad. |
| Revisión periódica | Se realizaron inspecciones durante el laboratorio. | Programar revisiones de usuarios, privilegios, redes, autenticación, TLS, extensiones y registros. |
| Documentación | Se registraron resultados y hallazgos en el repositorio. | Mantener la documentación actualizada y conservar un historial de cambios. |
| Verificación posterior | No se aplicaron cambios técnicos de hardening durante las actividades anteriores. | Comprobar que cada modificación produzca el efecto esperado y que las conexiones legítimas continúen funcionando. |

**Justificación**

La seguridad debe mantenerse durante todo el ciclo de vida del servidor.

Las actualizaciones, revisiones periódicas y documentación ayudan a identificar configuraciones obsoletas y nuevas necesidades de protección.

Antes de realizar cambios que puedan afectar la disponibilidad, deben prepararse respaldos y procedimientos de recuperación adecuados.

## Resumen de la línea base

La propuesta contempla siete áreas:

1. Red.
2. Autenticación.
3. Autorización.
4. Configuración.
5. Sistema operativo.
6. Cifrado.
7. Mantenimiento.

Los resultados de las inspecciones muestran que el servidor cuenta con varios controles favorables, como escucha TCP local, autenticación SCRAM-SHA-256, permisos restrictivos sobre archivos sensibles y soporte para TLS.

Sin embargo, todavía existen aspectos pendientes de evaluación, como los tiempos de espera, la política de registros, la separación efectiva de cuentas de aplicación y la política de actualizaciones.

## Conclusión

Se elaboró una línea base de seguridad para PostgreSQL utilizando los requisitos del laboratorio y las características del entorno local.

Se comprendió que el hardening requiere medidas complementarias y que una configuración segura no depende exclusivamente de contraseñas fuertes, cifrado o restricciones de red.

La línea base permitirá evaluar futuras modificaciones y comprobar si los controles continúan siendo adecuados.

Esta actividad consistió en una propuesta documentada. No se modificaron los parámetros ni los permisos del servidor.
