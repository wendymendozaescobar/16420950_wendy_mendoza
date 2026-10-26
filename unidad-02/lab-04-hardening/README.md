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

### Actividad 2. Identificar los archivos de configuración

**Objetivo**

Identificar la ubicación física de los archivos de configuración, autenticación, datos y registros de PostgreSQL.

**Procedimiento**

Se utilizaron consultas `SHOW` para identificar las rutas y parámetros de configuración del servidor PostgreSQL 18.6.

**Resultados**

| Parámetro | Valor |
|---|---|
| `config_file` | `/etc/postgresql/18/main/postgresql.conf` |
| `hba_file` | `/etc/postgresql/18/main/pg_hba.conf` |
| `ident_file` | `/etc/postgresql/18/main/pg_ident.conf` |
| `data_directory` | `/var/lib/postgresql/18/main` |
| `log_directory` | `log` |
| `log_connections` | Cadena vacía (`''`) |
| `log_disconnections` | `off` |

**Análisis**

Se identificó que los archivos principales de configuración se encuentran en `/etc/postgresql/18/main/`, mientras que los datos se almacenan en `/var/lib/postgresql/18/main`.

Esto permite distinguir entre los archivos que controlan el funcionamiento del servidor y aquellos que almacenan físicamente la información de las bases de datos.

También se observó que `log_connections` está configurado con una cadena vacía y `log_disconnections` está desactivado.

En PostgreSQL 18, una cadena vacía en `log_connections` indica que no está habilitado el registro configurable de las etapas de conexión.

El parámetro `log_directory` utiliza el valor relativo `log`, pero todavía no se ha comprobado cuál es el destino efectivo de los registros.

**¿Por qué es importante conocer la ubicación física de estos archivos?**

Porque permite identificar qué archivos deben protegerse, respaldarse y administrarse durante el mantenimiento del servidor.

También facilita revisar los permisos del sistema operativo y localizar configuraciones que podrían representar riesgos de seguridad.

Por ejemplo, si usuarios no autorizados pudieran modificar `pg_hba.conf`, podrían alterar las reglas de autenticación del servidor.

Asimismo, proteger el directorio de datos es fundamental porque contiene la información física administrada por PostgreSQL.

Conocer estas ubicaciones permite aplicar medidas de seguridad adecuadas sin modificar archivos incorrectos ni afectar innecesariamente el funcionamiento del servidor.

**Conclusión**

Se identificaron correctamente los principales archivos y directorios utilizados por PostgreSQL 18.6.

La actividad permitió comprender la diferencia entre configuración, autenticación, almacenamiento y registros.

No se realizaron modificaciones en el servidor.

**Script utilizado:** [01-inspeccion.sql](sql/01-inspeccion.sql).

### Actividad 3. Revisar `listen_addresses`

**Objetivo**

Analizar las interfaces de red en las que PostgreSQL acepta conexiones y determinar si la configuración actual limita adecuadamente la exposición del servidor.

**Procedimiento**

Se consultó el parámetro `listen_addresses` mediante la instrucción:

```sql
SHOW listen_addresses;
```

Posteriormente, se identificaron las interfaces necesarias para el laboratorio y se compararon las dos arquitecturas de red propuestas.

**Resultados**

| Elemento | Resultado |
|---|---|
| Configuración encontrada | `localhost` |
| Puerto PostgreSQL | `5433` |
| Tipo de acceso TCP configurado | Local |
| Interfaces necesarias | Interfaces locales de loopback |
| Interfaces innecesarias | Interfaces externas, debido a que las prácticas actuales no requieren acceso remoto |

**Análisis**

El parámetro `listen_addresses` determina en qué direcciones de red PostgreSQL puede aceptar conexiones TCP.

En nuestro entorno se obtuvo el valor `localhost`, lo que significa que PostgreSQL está configurado para escuchar únicamente en las interfaces locales.

Esta configuración resulta adecuada para las prácticas realizadas porque no necesitamos establecer conexiones desde otros equipos.

No se identificó la necesidad de habilitar interfaces adicionales.

**Comparación de arquitecturas**

La primera arquitectura presenta un servidor PostgreSQL conectado mediante un firewall a Internet. Si el firewall permite conexiones externas hacia el puerto correspondiente, el servidor podría quedar expuesto a intentos de conexión desde redes no autorizadas.

La segunda arquitectura sitúa PostgreSQL en una red privada y contempla restricciones que impiden su acceso directo desde Internet.

La segunda opción reduce mejor la exposición cuando las reglas de red limitan efectivamente las conexiones a los orígenes autorizados.

Sin embargo, utilizar una red privada no sustituye las medidas de autenticación, autorización y seguridad del sistema operativo.

**Conclusión**

Se comprobó que PostgreSQL utiliza `listen_addresses = 'localhost'`, una configuración adecuada para nuestro laboratorio local.

No fue necesario modificar el parámetro porque las actividades actuales no requieren conexiones remotas.

También se comprendió que restringir las interfaces de escucha contribuye a reducir la superficie de ataque.

**Evidencia:** [Revisión de listen_addresses](evidencias/02-listen-addresses.png).

### Actividad 4. Revisar `pg_hba.conf`

**Objetivo**

Analizar las reglas de autenticación configuradas en PostgreSQL e identificar posibles accesos excesivamente permisivos.

**Procedimiento**

Se consultó la vista `pg_hba_file_rules` para identificar los tipos de conexión, bases de datos, usuarios, direcciones de origen y métodos de autenticación configurados.

**Resultados**

Se encontraron siete reglas:

| Tipo | Base de datos | Usuario | Dirección | Método |
|---|---|---|---|---|
| `local` | Todas | `postgres` | Local | `peer` |
| `local` | Todas | Todos | Local | `peer` |
| `host` | Todas | Todos | `127.0.0.1` | `scram-sha-256` |
| `host` | Todas | Todos | `::1` | `scram-sha-256` |
| `local` | Replicación | Todos | Local | `peer` |
| `host` | Replicación | Todos | `127.0.0.1` | `scram-sha-256` |
| `host` | Replicación | Todos | `::1` | `scram-sha-256` |

**Análisis**

Las conexiones mediante sockets Unix utilizan el método `peer`, mientras que las conexiones TCP configuradas utilizan `scram-sha-256`.

Las direcciones identificadas corresponden a las interfaces locales IPv4 e IPv6.

No se encontraron reglas con los rangos `0.0.0.0/0` o `::/0`, que permitirían considerar orígenes de red mucho más amplios.

Sin embargo, algunas reglas utilizan `all` para bases de datos y usuarios, por lo que sería conveniente evaluar si cada aplicación requiere ese alcance.

El servidor también tiene configurado `listen_addresses = 'localhost'`, lo que contribuye a limitar su exposición TCP a conexiones locales.

La inspección no identificó una necesidad inmediata de modificar las reglas. Antes de cualquier cambio deben analizarse las conexiones necesarias y prepararse mecanismos para conservar el acceso administrativo.

**Conclusión**

Se identificaron las reglas de autenticación de PostgreSQL y se distinguieron los métodos `peer` y `scram-sha-256`.

No se observaron reglas que contemplen cualquier dirección de Internet como origen.

La actividad permitió comprender que la seguridad de las conexiones depende tanto de las interfaces disponibles como de las reglas de autenticación.

No se modificó la configuración de PostgreSQL.

**Evidencia:** [Reglas de autenticación](evidencias/03-pg-hba.png).

**Script:** [Consultas de inspección](sql/01-inspeccion.sql).

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
