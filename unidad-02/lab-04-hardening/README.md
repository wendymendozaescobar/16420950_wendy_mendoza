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

### Actividad 5. Analizar una regla permisiva

**Objetivo**

Analizar una regla de autenticación excesivamente amplia y proponer una alternativa basada en el principio de mínimo privilegio.

**Regla proporcionada:**

```text
host    all    all    0.0.0.0/0    scram-sha-256
```

### Preguntas de análisis

**1. ¿Qué bases de datos permite?**

La regla contempla todas las bases de datos mediante el valor `all`.

**2. ¿Qué usuarios permite?**

Contempla todos los usuarios de PostgreSQL mediante el valor `all`, siempre que cumplan las condiciones de autenticación y conexión correspondientes.

**3. ¿Qué direcciones de origen permite?**

El rango `0.0.0.0/0` contempla todas las direcciones IPv4.

Sin embargo, esto no garantiza que todas puedan establecer una conexión, porque también intervienen las interfaces de escucha y los controles de red.

**4. ¿Qué método de autenticación utiliza?**

Utiliza `scram-sha-256`, un mecanismo de autenticación mediante contraseña que emplea un protocolo de desafío y respuesta.

**5. ¿Por qué puede representar una exposición innecesaria?**

Porque permite intentar autenticarse desde un conjunto de direcciones mucho más amplio del que probablemente necesita una aplicación.

Además, no restringe específicamente las bases de datos ni los usuarios.

Esto puede aumentar la superficie de ataque cuando el servidor acepta conexiones desde redes externas.

**6. ¿Qué información necesitarías para restringirla?**

Sería necesario conocer:

- Qué aplicación necesita conectarse.
- Qué base de datos utiliza.
- Qué cuenta de PostgreSQL necesita acceso.
- Desde qué dirección IP o red se conecta.
- Qué método de autenticación debe utilizar.
- Qué restricciones de red existen.
- Si el cambio podría afectar conexiones legítimas.

### Propuesta de regla restringida

**Regla actual del escenario:**

```text
host    all    all    0.0.0.0/0    scram-sha-256
```

**Problema:**

La regla contempla cualquier base de datos, usuario y origen IPv4.

**Origen que realmente necesita acceso:**

Para el escenario de nuestro laboratorio local, se propone limitar las conexiones TCP a `127.0.0.1/32`.

**Base de datos:**

`laboratorios_unidad2`

**Usuario:**

Una cuenta de aplicación específica que deberá definirse y autorizarse antes de implementar la regla.

**Regla conceptual propuesta:**

```text
host    laboratorios_unidad2    usuario_app    127.0.0.1/32    scram-sha-256
```

El nombre `usuario_app` representa una cuenta propuesta y no implica que actualmente exista en PostgreSQL.

La regla se presenta únicamente como ejemplo de una configuración más específica.

### Análisis

La propuesta reduce el alcance del acceso al establecer una base de datos, un usuario y una dirección de origen determinados.

Esto permite aplicar el principio de mínimo privilegio.

Durante la Actividad 4 se comprobó que nuestro servidor ya utiliza reglas limitadas a direcciones locales IPv4 e IPv6, por lo que no se encontró la regla excesivamente amplia del escenario.

No es necesario introducir una regla nueva sin comprobar primero las necesidades reales de las aplicaciones.

### Conclusión

Se comprendió que utilizar `scram-sha-256` no elimina los riesgos derivados de permitir conexiones desde redes innecesariamente amplias.

Una configuración segura debe considerar conjuntamente la base de datos, el usuario, la dirección de origen y el método de autenticación.

Durante esta actividad no se modificó `pg_hba.conf`.

### Actividad 6. Aplicar mínimo privilegio a las conexiones

**Objetivo**

Diseñar una regla de autenticación que limite las conexiones a PostgreSQL de acuerdo con la base de datos, el usuario, el origen y el método de autenticación necesarios.

**Procedimiento**

Se revisaron las características del entorno local identificadas durante las actividades anteriores.

Se consideraron la base de datos `laboratorios_unidad2`, las interfaces locales y el método de autenticación `scram-sha-256`.

Posteriormente, se elaboró una propuesta de regla específica.

**Regla propuesta**

```text
host    laboratorios_unidad2    usuario_app    127.0.0.1/32    scram-sha-256
```

**Justificación**

| Elemento | Valor propuesto | Justificación |
|---|---|---|
| Tipo | `host` | Permite definir una regla para conexiones TCP. |
| Base de datos | `laboratorios_unidad2` | Limita la regla a la base de datos utilizada para las prácticas. |
| Usuario | `usuario_app` | Representa una cuenta específica destinada a una aplicación. |
| Origen | `127.0.0.1/32` | Restringe el origen a una sola dirección IPv4 local. |
| Autenticación | `scram-sha-256` | Utiliza un mecanismo seguro de autenticación mediante contraseña. |

**Análisis**

La regla propuesta aplica el principio de mínimo privilegio porque evita utilizar `all` para bases de datos y usuarios, así como rangos de red excesivamente amplios.

Se identificó que el servidor del laboratorio ya utiliza `listen_addresses = 'localhost'` y reglas de autenticación para direcciones locales.

La cuenta `usuario_app` es conceptual y debería crearse únicamente si una aplicación real necesitara conectarse.

Antes de aplicar esta regla sería necesario verificar las necesidades de conexión y asegurar que los cambios no afecten el acceso administrativo.

**Conclusión**

Se comprendió que una regla de autenticación debe ser tan específica como resulte razonablemente posible.

Restringir la base de datos, el usuario, el origen y el método de autenticación contribuye a reducir la superficie de ataque.

La actividad consistió en diseñar una regla conceptual. No se modificó `pg_hba.conf` ni se crearon nuevos usuarios.

### Actividad 7. Revisar autenticación

**Objetivo**

Identificar el mecanismo configurado para almacenar nuevas contraseñas en PostgreSQL y comprender la diferencia entre autenticación y autorización.

**Procedimiento**

Se consultó el parámetro `password_encryption` mediante la instrucción:

```sql
SHOW password_encryption;
```

**Resultado**

Se obtuvo el siguiente valor:

```text
scram-sha-256
```

Este resultado indica que PostgreSQL está configurado para utilizar SCRAM-SHA-256 al establecer nuevas contraseñas.

### Preguntas de análisis

**1. ¿Qué diferencia existe entre autenticación y autorización?**

La autenticación es el proceso mediante el cual un sistema verifica la identidad de un usuario.

La autorización determina qué recursos puede consultar y qué operaciones puede realizar después de autenticarse.

Por ejemplo, un usuario puede autenticarse correctamente en PostgreSQL, pero no tener autorización para consultar determinadas tablas.

**2. ¿Qué protege `scram-sha-256`?**

SCRAM-SHA-256 protege el proceso de autenticación mediante contraseña.

Utiliza mecanismos criptográficos para verificar que el cliente conoce la contraseña sin transmitirla directamente como texto plano durante el intercambio de autenticación.

También permite almacenar verificadores de contraseña en lugar de contraseñas recuperables directamente.

Sin embargo, no sustituye el cifrado de las comunicaciones mediante TLS ni los controles de autorización.

**3. ¿Por qué una contraseña almacenada mediante un mecanismo de autenticación no debe confundirse con cifrado reversible?**

Porque cumplen propósitos diferentes.

El cifrado reversible permite recuperar la información original utilizando una clave de descifrado.

En cambio, los mecanismos de almacenamiento de contraseñas como SCRAM-SHA-256 utilizan verificadores derivados de la contraseña para comprobar su conocimiento sin necesitar recuperar el valor original.

Por lo tanto, no debe tratarse una contraseña almacenada mediante SCRAM como si fuera información cifrada que simplemente pudiera descifrarse.

**4. ¿Qué sucede si una cuenta tiene permisos excesivos aunque utilice una contraseña fuerte?**

La cuenta puede representar un riesgo importante.

Si un atacante obtiene acceso a ella, podría realizar todas las operaciones permitidas por sus privilegios.

Por ejemplo, una aplicación que utiliza una cuenta `SUPERUSER` podría comprometer gravemente el servidor si sus credenciales son robadas.

Por esta razón, las contraseñas seguras deben complementarse con el principio de mínimo privilegio.

### Análisis

La configuración observada utiliza SCRAM-SHA-256 para el almacenamiento de nuevas contraseñas, lo cual es adecuado para el entorno del laboratorio.

Durante la revisión de `pg_hba.conf` también se identificó que las conexiones TCP locales utilizan `scram-sha-256`, mientras que determinadas conexiones mediante sockets Unix utilizan `peer`.

Esto demuestra que los mecanismos de autenticación pueden variar según el tipo de conexión.

También se comprendió que la autenticación no sustituye la autorización y que las cuentas deben disponer únicamente de los permisos necesarios para cumplir sus funciones.

### Conclusión

Se identificó el mecanismo configurado para el almacenamiento de nuevas contraseñas en PostgreSQL.

La actividad permitió distinguir autenticación, autorización y cifrado reversible.

Se comprendió que una configuración segura requiere combinar métodos adecuados de autenticación con permisos restringidos.

No fue necesario modificar la configuración del servidor.

### Actividad 8. Revisar usuarios y privilegios

**Objetivo**

Identificar los roles de PostgreSQL, sus capacidades administrativas y sus permisos para iniciar sesión, con el propósito de detectar posibles privilegios excesivos.

**Procedimiento**

Se ejecutó el comando `\du` para visualizar los roles y sus atributos.

Posteriormente, se consultó `pg_roles` para identificar los privilegios de superusuario, creación de roles, creación de bases de datos e inicio de sesión.

**Resultados**

La consulta devolvió 20 roles, incluyendo los roles predefinidos de PostgreSQL.

Los cuatro roles propios del entorno de prácticas fueron:

| Rol | LOGIN | SUPERUSER | CREATEROLE | CREATEDB | Función |
|---|---|---|---|---|---|
| `postgres` | Sí | Sí | Sí | Sí | Administración del servidor |
| `lab02_tls` | Sí | No | No | No | Cuenta utilizada durante LAB-02 |
| `analista` | No | No | No | No | Administración de privilegios para analítica |
| `soporte` | No | No | No | No | Administración de privilegios para soporte |

### Análisis

Se identificó que `postgres` es el único superusuario entre los roles propios del laboratorio.

También se comprobó que `lab02_tls` puede iniciar sesión, pero no tiene los atributos `SUPERUSER`, `CREATEROLE` ni `CREATEDB`.

Los roles `analista` y `soporte` no pueden iniciar sesión directamente debido a su configuración `NOLOGIN`.

Los demás roles encontrados comienzan con `pg_` y corresponden a roles predefinidos de PostgreSQL.

No se identificó una cuenta de aplicación productiva cuya configuración pudiera evaluarse.

Tampoco se determinó que alguno de los roles existentes fuera innecesario, ya que esto requeriría comprobar previamente sus funciones y dependencias.

**¿Por qué no debería utilizarse una cuenta SUPERUSER como cuenta normal de una aplicación?**

Porque una cuenta `SUPERUSER` dispone de capacidades administrativas que normalmente no son necesarias para el funcionamiento de una aplicación.

Si la aplicación presentara una vulnerabilidad o sus credenciales fueran comprometidas, un atacante podría aprovechar esos privilegios elevados para acceder a información, modificar objetos o realizar operaciones administrativas.

Por ello, las aplicaciones deberían utilizar cuentas específicas con los permisos mínimos necesarios para realizar sus funciones.

### Conclusión

Se identificaron los roles existentes y se distinguieron sus capacidades de inicio de sesión y administración.

La actividad permitió comprender que los roles administrativos deben utilizarse únicamente cuando sus privilegios sean necesarios.

También se comprobó que los roles `NOLOGIN` pueden servir para organizar permisos sin permitir conexiones directas.

Durante esta actividad no se modificaron ni eliminaron roles.

**Evidencia:** [Usuarios y privilegios](evidencias/04-roles.png).

**Script:** [Consultas de roles](sql/02-roles.sql).

### Actividad 9. Separar cuentas administrativas y de aplicación

**Objetivo**

Diseñar una separación de cuentas administrativas, de aplicación y de consulta que permita aplicar el principio de mínimo privilegio en PostgreSQL.

**Procedimiento**

Se analizaron las responsabilidades de tres tipos de cuentas y se establecieron los privilegios que deberían recibir según sus funciones.

Se consideraron los roles identificados durante la Actividad 8, pero no se modificaron las cuentas existentes.

**Resultados**

Se propone la siguiente separación:

| Cuenta | Propósito | LOGIN | Privilegios |
|---|---|---|---|
| DBA | Administración de PostgreSQL | Sí | Privilegios administrativos necesarios para gestionar el servidor |
| APP | Conexión utilizada por una aplicación | Sí | Acceso únicamente a las tablas y operaciones que necesita la aplicación |
| CONSULTA | Consulta de información autorizada | Sí | Permisos `SELECT` sobre los objetos necesarios |

Las tres cuentas son conceptuales y no fueron creadas durante esta actividad.

### Justificación

**Cuenta DBA**

Debe utilizarse exclusivamente para realizar actividades administrativas.

Sus privilegios deben corresponder a las responsabilidades asignadas. No todas las tareas de administración requieren utilizar permanentemente una cuenta `SUPERUSER`.

**Cuenta APP**

Debe contar solamente con los permisos necesarios para realizar las operaciones de la aplicación.

Por ejemplo, una aplicación de administración de clientes podría requerir permisos específicos de lectura, inserción y actualización, sin autorización para modificar la configuración del servidor.

**Cuenta CONSULTA**

Debe utilizarse cuando únicamente se necesita consultar información.

Sus permisos deberían limitarse a `SELECT` sobre las tablas o vistas autorizadas.

No debería disponer de permisos para insertar, actualizar o eliminar registros.

### Pregunta de análisis

**¿Qué riesgo existe si la aplicación se conecta utilizando una cuenta administrativa?**

Si una aplicación utiliza una cuenta administrativa, cualquier vulnerabilidad que permita ejecutar operaciones con sus credenciales podría comprometer gravemente la seguridad de PostgreSQL.

Por ejemplo, si la aplicación se conecta como `postgres`, un atacante que consiga utilizar esa conexión podría aprovechar los privilegios de superusuario para consultar o modificar información y realizar operaciones administrativas.

Esto aumentaría el impacto potencial de una vulnerabilidad.

Por esa razón, las aplicaciones deben utilizar cuentas específicas con privilegios limitados a sus necesidades funcionales.

### Análisis

La separación de cuentas permite establecer diferentes niveles de autorización según las funciones.

Las tareas administrativas requieren capacidades diferentes de las operaciones normales de una aplicación.

En el entorno del laboratorio, `postgres` tiene privilegios elevados y debe reservarse para las actividades que realmente los requieren.

Los roles `analista` y `soporte`, configurados con `NOLOGIN`, también demuestran que PostgreSQL permite organizar privilegios sin habilitar necesariamente el inicio de sesión directo.

La propuesta utiliza el principio de mínimo privilegio para reducir los posibles efectos de un acceso no autorizado.

### Conclusión

Se comprendió que las cuentas administrativas y las cuentas utilizadas por aplicaciones deben tener responsabilidades y privilegios diferentes.

El uso de cuentas específicas permite limitar las operaciones disponibles y reducir los riesgos relacionados con privilegios excesivos.

Durante esta actividad se realizó únicamente un diseño conceptual. No se crearon ni modificaron roles en PostgreSQL.

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
