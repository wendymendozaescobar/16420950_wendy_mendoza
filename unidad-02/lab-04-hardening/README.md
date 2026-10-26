# LAB-04 — Hardening y configuración segura de PostgreSQL

## Objetivo

Analizar la configuración de seguridad de un servidor PostgreSQL e identificar mecanismos para reducir su superficie de ataque mediante controles de red, autenticación, autorización y protección de archivos.

## Entorno

| Elemento | Descripción |
|---|---|
| Sistema operativo | Ubuntu |
| PostgreSQL | 18.6 |
| Puerto | 5433 |
| Base de datos | `laboratorios_unidad2` |
| Herramienta | `psql` |
| Modalidad | Laboratorio local |

El documento del profesor utiliza PostgreSQL 16 como referencia. Las actividades se realizan sobre la versión 18.6 disponible en el entorno local.

## Superficie de ataque inicial

### Actividad 1. Identificar la superficie de ataque

**Objetivo:** Identificar los principales puntos de exposición del servidor antes de aplicar medidas de hardening.

**Procedimiento:** Se ejecutaron consultas de solo lectura para identificar la versión, el puerto, las interfaces de escucha, el estado de SSL/TLS, el mecanismo configurado para nuevas contraseñas y las conexiones registradas.

### Resultados

| Elemento | Estado actual | ¿Es necesario? | Riesgo identificado |
|---|---|---|---|
| Puerto PostgreSQL | 5433 | Sí, para las conexiones del laboratorio | Un puerto expuesto innecesariamente podría permitir intentos de conexión no deseados. |
| Interfaces de escucha | `localhost` | Sí, para el acceso local | No se identificó exposición TCP en todas las interfaces. |
| Conexiones remotas | No observadas en la consulta | No son necesarias para las prácticas actuales | Permitir conexiones remotas innecesarias aumentaría la superficie de ataque. |
| Usuarios administrativos | Se observó una sesión con el usuario `postgres` | Sí, para tareas administrativas | Utilizar cuentas administrativas para operaciones normales puede generar privilegios excesivos. |
| SSL/TLS | `on` | Recomendable para proteger conexiones de red | El valor `on` no demuestra que todas las conexiones utilicen TLS. |
| Métodos de autenticación | `password_encryption = scram-sha-256` | Sí, para proteger las credenciales de cuentas que utilizan contraseñas | Aún debe revisarse `pg_hba.conf` para determinar los métodos de autenticación permitidos. |

La consulta a `pg_stat_activity` devolvió nueve filas. Se identificó una sesión de `psql` conectada a `laboratorios_unidad2` mediante el usuario `postgres`.

No se observaron direcciones IP de clientes remotos en los resultados.

### Pregunta de análisis

**¿Por qué conocer la superficie de ataque debe preceder al hardening?**

Porque antes de modificar la configuración de seguridad es necesario identificar qué servicios, puertos, interfaces, usuarios y métodos de acceso están disponibles.

Esto permite determinar qué elementos representan riesgos reales y cuáles son necesarios para el funcionamiento del sistema.

También evita aplicar restricciones innecesarias que podrían afectar la disponibilidad del servidor.

En este laboratorio, la inspección inicial permitió comprobar que PostgreSQL ya escucha únicamente en `localhost`, tiene habilitado SSL/TLS y utiliza SCRAM-SHA-256 para establecer nuevas contraseñas.

Por lo tanto, no sería correcto modificar estos parámetros sin identificar primero una necesidad concreta.

**Evidencia:** [Superficie de ataque inicial](evidencias/01-superficie-ataque.png)

**Script:** [Consultas de inspección](sql/01-inspeccion.sql)

## Hallazgos

Pendiente de completar conforme avancen las actividades.

## Cambios realizados

Todavía no se han realizado modificaciones de seguridad.

## Justificación de los cambios

Pendiente de documentar.

## Verificación

Pendiente de completar después de las actividades de hardening.

## Checklist de hardening

Pendiente de elaborar en la Actividad 17.

## Conclusiones

Pendiente de completar al finalizar el laboratorio.
