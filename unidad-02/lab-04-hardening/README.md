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

### Actividad 10. Revisar extensiones de PostgreSQL

**Objetivo**

Identificar las extensiones instaladas en PostgreSQL, analizar sus funciones y determinar si representan funcionalidades necesarias o innecesarias para el entorno del laboratorio.

**Procedimiento**

Se consultó el catálogo `pg_extension` para identificar las extensiones instaladas en la base de datos `laboratorios_unidad2` y sus respectivas versiones.

Se utilizó la siguiente consulta:

```sql
SELECT
    extname,
    extversion
FROM pg_extension
ORDER BY extname;
```

**Resultados**

Se encontraron dos extensiones instaladas:

| Extensión | Versión | Función | Evaluación |
|---|---|---|---|
| `pgcrypto` | 1.4 | Proporciona funciones criptográficas. | Utilizada durante las prácticas de cifrado del LAB-02. |
| `plpgsql` | 1.0 | Permite desarrollar funciones y procedimientos almacenados. | Funcionalidad habitual de PostgreSQL que puede ser necesaria para funciones procedurales. |

### Preguntas de análisis

**1. ¿Qué extensiones existen?**

En la base de datos `laboratorios_unidad2` se encontraron `pgcrypto`, versión 1.4, y `plpgsql`, versión 1.0.

**2. ¿Cuáles son necesarias?**

`pgcrypto` resulta útil para las actividades criptográficas desarrolladas durante el LAB-02.

`plpgsql` proporciona capacidades para desarrollar funciones y procedimientos almacenados.

Antes de determinar que alguna extensión es innecesaria, sería necesario revisar las dependencias y los requisitos reales de las aplicaciones.

**3. ¿Cuáles fueron instaladas para prácticas?**

Durante el LAB-02 se utilizó `pgcrypto` para realizar ejercicios de cifrado de información.

No se comprobó durante esta actividad cuándo se instaló `plpgsql`.

**4. ¿Cuáles podrían representar funcionalidad innecesaria en otro entorno?**

En una instalación donde no se utilicen funciones criptográficas de `pgcrypto`, podría evaluarse si es necesario mantener esa extensión.

De manera similar, cualquier extensión instalada debe justificarse de acuerdo con las necesidades del sistema.

Sin embargo, no debe eliminarse una extensión sin comprobar primero sus dependencias y posibles consecuencias.

### Análisis

La revisión permitió identificar las extensiones disponibles en la base de datos utilizada para los laboratorios.

Se observó que `pgcrypto` proporciona funcionalidades relacionadas con prácticas anteriores, mientras que `plpgsql` permite desarrollar lógica procedural dentro de PostgreSQL.

No se identificó una extensión que debiera eliminarse inmediatamente.

La aplicación del hardening requiere evaluar las funcionalidades instaladas, pero no implica eliminar componentes simplemente porque estén presentes.

También debe considerarse que `pg_extension` muestra las extensiones instaladas en la base de datos consultada, no necesariamente en todas las bases del servidor.

### Conclusión

Se identificaron dos extensiones instaladas: `pgcrypto` y `plpgsql`.

La actividad permitió comprender que las extensiones amplían las capacidades de PostgreSQL y deben revisarse según las necesidades del entorno.

No se realizaron modificaciones ni se eliminaron extensiones.

**Script utilizado:** [03-configuracion.sql](sql/03-configuracion.sql).

### Actividad 11. Revisar configuración relacionada con conexiones

**Objetivo**

Identificar los parámetros de PostgreSQL relacionados con los límites de conexiones y los tiempos de espera, para analizar sus implicaciones en la seguridad y disponibilidad del servidor.

**Procedimiento**

Se consultaron cuatro parámetros de PostgreSQL mediante instrucciones `SHOW`, sin realizar modificaciones en la configuración.

**Resultados**

| Parámetro | Valor actual | Función |
|---|---|---|
| `max_connections` | `100` | Establece el número máximo de conexiones simultáneas permitidas por el servidor. |
| `superuser_reserved_connections` | `3` | Reserva capacidad de conexión para superusuarios. |
| `statement_timeout` | `0` | Controla la duración máxima de las instrucciones SQL. El valor cero desactiva este límite. |
| `idle_in_transaction_session_timeout` | `0` | Controla cuánto tiempo puede permanecer una sesión inactiva dentro de una transacción. El valor cero desactiva este límite. |

### Análisis de los parámetros

**1. `max_connections`**

El servidor permite un máximo de 100 conexiones simultáneas, considerando las reservas de conexiones configuradas.

Un número excesivamente alto puede incrementar el consumo de memoria y otros recursos.

Un límite demasiado bajo puede impedir que las aplicaciones establezcan conexiones cuando se alcance la capacidad disponible.

Para determinar si el valor es adecuado, sería necesario conocer las necesidades de las aplicaciones y el consumo real de recursos.

**2. `superuser_reserved_connections`**

Se identificaron tres conexiones reservadas para superusuarios.

Este mecanismo ayuda a conservar capacidad de acceso administrativo cuando el servidor se aproxima a su límite de conexiones.

**3. `statement_timeout`**

El valor obtenido fue `0`, lo que significa que no existe un límite general de duración de las instrucciones mediante este parámetro.

Esto puede permitir que determinadas consultas consuman recursos durante periodos prolongados.

Sin embargo, establecer un límite requiere considerar cuánto tiempo necesitan las operaciones legítimas.

**4. `idle_in_transaction_session_timeout`**

El valor obtenido fue `0`, por lo que no existe un límite general de inactividad dentro de una transacción mediante este parámetro.

Esto puede representar un riesgo cuando una sesión deja una transacción abierta sin ejecutar `COMMIT` o `ROLLBACK`.

En determinadas circunstancias, estas transacciones pueden mantener bloqueos, conservar versiones antiguas de registros e interferir con operaciones de mantenimiento.

### Pregunta de análisis

**¿Por qué mantener conexiones indefinidamente abiertas puede representar un problema de disponibilidad o consumo de recursos?**

Porque cada conexión utiliza recursos del servidor, como memoria y estructuras de administración de procesos.

Cuando existen demasiadas conexiones abiertas, puede aumentar el consumo de recursos y reducirse la capacidad para atender nuevas solicitudes.

Además, una sesión que permanece inactiva dentro de una transacción puede conservar bloqueos y dificultar determinadas operaciones sobre la base de datos.

Por ello, es importante establecer políticas adecuadas de administración de conexiones, utilizar mecanismos de reutilización cuando corresponda y evaluar los tiempos máximos de ejecución e inactividad.

Sin embargo, no todas las conexiones inactivas representan el mismo riesgo. Una conexión inactiva sin transacción abierta tiene implicaciones diferentes de una sesión que mantiene una transacción pendiente.

### Conclusión

Se identificaron los límites de conexiones y tiempos de espera configurados en PostgreSQL.

El servidor tiene un máximo de 100 conexiones y reserva tres para superusuarios.

También se observó que `statement_timeout` e `idle_in_transaction_session_timeout` tienen un valor de cero.

Estos valores deben evaluarse de acuerdo con las necesidades del entorno antes de aplicar modificaciones.

Durante esta actividad no se cambiaron parámetros del servidor.

**Script utilizado:** [03-configuracion.sql](sql/03-configuracion.sql).

### Actividad 12. Revisar permisos del sistema operativo

**Objetivo**

Verificar los propietarios, grupos y permisos de los archivos y directorios sensibles de PostgreSQL en Ubuntu.

**Procedimiento**

Se utilizaron los comandos `ls -l` y `ls -ld` para inspeccionar los permisos de los archivos `postgresql.conf`, `pg_hba.conf`, el directorio de datos y el directorio de configuración.

**Resultados**

| Elemento | Permisos | Propietario | Grupo | Evaluación |
|---|---|---|---|---|
| `postgresql.conf` | `640` | postgres | postgres | Acceso restringido |
| `pg_hba.conf` | `640` | postgres | postgres | Acceso restringido |
| `/var/lib/postgresql/18/main` | `700` | postgres | postgres | Directorio protegido |
| `/etc/postgresql/18/main` | `755` | postgres | postgres | Directorio accesible; archivos protegidos individualmente |

### Análisis

Los archivos `postgresql.conf` y `pg_hba.conf` permiten lectura y escritura al propietario, lectura al grupo y ningún acceso ordinario a los demás usuarios.

El directorio de datos tiene permisos `700`, por lo que solamente su propietario dispone de permisos ordinarios sobre él.

El directorio de configuración tiene permisos `755`, que permiten a otros usuarios recorrerlo y consultar su contenido a nivel de nombres. Sin embargo, los permisos individuales de los archivos restringen su lectura y modificación.

No se identificó una necesidad inmediata de modificar los permisos inspeccionados.

### Pregunta de análisis

**¿Por qué no es suficiente proteger PostgreSQL mediante GRANT y REVOKE si cualquier usuario del sistema operativo puede leer archivos sensibles?**

Porque `GRANT` y `REVOKE` controlan privilegios sobre objetos administrados por PostgreSQL, pero no sustituyen los mecanismos de protección de archivos del sistema operativo.

Si un usuario no autorizado pudiera leer archivos sensibles, podría obtener información sobre la configuración del servidor o acceder a información que debería permanecer protegida.

Además, si pudiera modificar archivos como `pg_hba.conf`, podría intentar alterar las condiciones de autenticación.

Por esta razón, la seguridad de PostgreSQL también requiere controlar los permisos de archivos y directorios desde Ubuntu.

### Conclusión

Se comprobó que los archivos de configuración y el directorio de datos presentan permisos restrictivos.

La actividad permitió comprender la importancia de combinar los controles de autorización de PostgreSQL con los permisos del sistema operativo.

No se modificaron propietarios, grupos ni permisos durante esta actividad.

### Actividad 13. Revisar exposición de red

**Objetivo**

Verificar las interfaces y los puertos TCP utilizados por PostgreSQL para identificar posibles exposiciones innecesarias del servidor.

**Procedimiento**

Se utilizaron los comandos `ss -lnt` y `ss -lntp` desde Ubuntu para consultar los puertos que se encuentran escuchando.

Posteriormente, se filtraron los resultados correspondientes al puerto `5433`, utilizado por PostgreSQL 18.

**Resultados**

| Elemento | Resultado |
|---|---|
| Dirección de escucha | `127.0.0.1` |
| Puerto | `5433` |
| Protocolo | TCP |
| Estado | `LISTEN` |
| Proceso | `postgres` |
| PID observado | `28591` |
| ¿Está expuesto fuera de la interfaz necesaria? | No se identificó exposición TCP fuera de la interfaz local. |

También se observó un servicio escuchando en `127.0.0.1:5432`. No se identificó su proceso durante esta comprobación.

**Análisis**

La dirección `127.0.0.1` corresponde a la interfaz local IPv4, por lo que el servidor PostgreSQL 18 no está escuchando en interfaces TCP externas.

Este resultado coincide con el parámetro `listen_addresses = 'localhost'`, identificado durante las actividades anteriores.

La configuración es adecuada para el laboratorio, debido a que las prácticas se realizan desde el mismo equipo y no requieren conexiones remotas.

La presencia del valor `0.0.0.0:*` en la columna `Peer Address` del comando `ss` no indica exposición externa. Para identificar la dirección de escucha se revisó la columna `Local Address:Port`.

**Conclusión**

Se comprobó que el servidor PostgreSQL utilizado en el laboratorio escucha mediante TCP en `127.0.0.1:5433`.

No se identificó exposición TCP en interfaces externas y no fue necesario modificar la configuración de red.

La actividad permitió comprender cómo comprobar desde Ubuntu que las interfaces utilizadas por un servicio coinciden con su configuración.

### Actividad 14. Diseñar una política de firewall

**Objetivo**

Diseñar una política de firewall que restrinja las conexiones hacia PostgreSQL a los orígenes autorizados, aplicando el principio de mínimo privilegio en la red.

**Procedimiento**

Se analizó el escenario proporcionado, en el que un servidor PostgreSQL utiliza la dirección `10.10.10.20` y el puerto `5432`.

Se estableció una regla conceptual para permitir conexiones desde la red `10.10.10.0/24` y denegar conexiones desde cualquier otro origen.

No se realizaron modificaciones en el firewall del sistema operativo.

### Resultados

**Política de firewall propuesta:**

| Origen | Destino | Puerto | Acción |
|---|---|---|---|
| `10.10.10.0/24` | `10.10.10.20` | TCP `5432` | Permitir |
| Cualquier otro origen | `10.10.10.20` | TCP `5432` | Denegar |

Esta política contempla únicamente el acceso al servicio PostgreSQL del escenario.

Los valores corresponden al ejemplo del profesor y no a la configuración real de nuestro servidor local.

### Pregunta de análisis

**¿Por qué `pg_hba.conf` y el firewall no son controles equivalentes?**

Porque funcionan en niveles diferentes y cumplen objetivos distintos.

El firewall controla el tráfico de red, permitiendo o bloqueando comunicaciones según criterios como la dirección de origen, la dirección de destino, el puerto y el protocolo.

Por su parte, `pg_hba.conf` establece las reglas que PostgreSQL utiliza para determinar qué conexiones pueden autenticarse y mediante qué método.

Por ejemplo, el firewall puede permitir que un equipo alcance el puerto de PostgreSQL, pero el servidor puede rechazar posteriormente la conexión si no cumple las condiciones de autenticación.

Por ello, el firewall y `pg_hba.conf` son controles complementarios y no deben utilizarse como sustitutos uno del otro.

### Análisis

La política propuesta restringe el acceso al puerto `5432` del servidor `10.10.10.20` a una red específica.

Esto reduce la exposición frente a conexiones procedentes de redes no autorizadas.

Sin embargo, permitir el acceso desde una red no significa que todos sus usuarios deban disponer de privilegios sobre las bases de datos.

También es necesario configurar correctamente las reglas de autenticación y los permisos de PostgreSQL.

En nuestro entorno local, el servidor PostgreSQL 18 utiliza el puerto `5433` y escucha en `127.0.0.1`.

Por esta razón, no existe una necesidad identificada de aplicar la regla hipotética al sistema que utilizamos para las prácticas.

### Conclusión

Se diseñó una política conceptual de firewall que permite conexiones desde una red autorizada y deniega los demás orígenes hacia el servicio PostgreSQL.

La actividad permitió comprender que el firewall protege el acceso a nivel de red, mientras que `pg_hba.conf` controla las condiciones de autenticación de PostgreSQL.

Ambos mecanismos deben trabajar conjuntamente para reducir la superficie de ataque.

No se modificó la configuración del firewall ni del servidor.

### Actividad 15. Revisar TLS

**Objetivo**

Verificar la configuración TLS de PostgreSQL y comprobar si las conexiones establecidas utilizan cifrado durante la comunicación.

**Procedimiento**

Se consultaron los parámetros `ssl` y `ssl_min_protocol_version`.

Posteriormente, se utilizó `pg_stat_ssl` para verificar el estado de cifrado de una conexión local mediante socket Unix.

Finalmente, se estableció una conexión TCP hacia `127.0.0.1:5433`, utilizando la cuenta `lab02_tls` y exigiendo TLS mediante `sslmode=require`.

Se comprobó la conexión utilizando `\conninfo` y la vista `pg_stat_ssl`.

**Resultados**

| Elemento | Resultado |
|---|---|
| TLS habilitado | `on` |
| Versión mínima configurada | `TLSv1.2` |
| Usuario de prueba | `lab02_tls` |
| Dirección del cliente | `127.0.0.1` |
| Puerto | `5433` |
| Conexión mediante socket Unix | No utiliza TLS |
| Conexión TCP con `sslmode=require` | Utiliza TLS |
| Versión negociada | `TLSv1.3` |
| Algoritmo de cifrado | `TLS_AES_256_GCM_SHA384` |

### Análisis

La primera comprobación se realizó mediante una conexión local utilizando un socket Unix.

En esa sesión, `pg_stat_ssl` devolvió `ssl = false`, debido a que no se estaba utilizando una conexión TCP cifrada.

Posteriormente, se estableció una conexión TCP local con la cuenta `lab02_tls` y el parámetro `sslmode=require`.

La conexión fue exitosa y permitió confirmar que PostgreSQL negoció TLS 1.3 con el algoritmo `TLS_AES_256_GCM_SHA384`.

Esto demuestra que tener TLS habilitado en el servidor y utilizar TLS en una conexión específica son condiciones diferentes.

También se comprobó que la cuenta utilizada para la prueba no dispone de privilegios de superusuario.

El parámetro `sslmode=require` exige una conexión cifrada, pero no garantiza por sí solo una verificación completa de la identidad del servidor mediante certificados de confianza.

### Conclusión

Se verificó que PostgreSQL tiene habilitado TLS y admite conexiones cifradas.

La prueba TCP permitió comprobar el uso efectivo de TLS 1.3.

La actividad permitió distinguir entre la configuración de seguridad del servidor y las propiedades de una conexión específica.

No fue necesario modificar certificados, usuarios ni parámetros de PostgreSQL.

**Evidencia:** [Verificación de TLS](evidencias/05-tls.png).

**Script utilizado:** [03-configuracion.sql](sql/03-configuracion.sql).

## Cambios realizados

### Actividad 16. Comparación antes y después del hardening

Se elaboró una comparación de diez controles de seguridad utilizando los resultados obtenidos durante las actividades anteriores.

La revisión incluyó interfaces de escucha, reglas de autenticación, métodos de autenticación, usuarios, cuentas de aplicación, puerto, TLS, permisos del sistema operativo, extensiones y conexiones.

No se realizaron cambios en la configuración del servidor durante las primeras quince actividades.

Se comprobó que varios controles ya estaban configurados adecuadamente y se identificaron mejoras pendientes de evaluación.

La ausencia de cambios no implica que se haya completado todo el hardening del servidor. Significa que las actividades realizadas hasta este punto consistieron en inspección, análisis y documentación.

**Evidencia:** [Comparación de configuración antes y después](configuracion/cambios.md).

## Justificación de los cambios

Pendiente de documentar.

## Verificación

Pendiente de completar después de las actividades de hardening.

## Checklist de hardening

### Actividad 17. Elaborar checklist de hardening

**Objetivo**

Elaborar una lista de verificación de seguridad para evaluar los controles existentes en PostgreSQL, utilizando los resultados obtenidos durante las actividades anteriores.

**Procedimiento**

Se revisaron los resultados de las inspecciones realizadas sobre el servidor PostgreSQL 18.6 y el sistema operativo Ubuntu.

Se evaluaron los quince controles propuestos en el laboratorio, indicando su estado y la evidencia que respalda cada evaluación.

Se utilizaron los siguientes estados:

- **Sí:** el control fue comprobado o documentado según su propósito.
- **Parcial:** solamente se verificaron algunos aspectos del control.
- **No:** el control todavía no se ha implementado o documentado.

### Checklist de hardening

| # | Control | Verificado | Evidencia |
|---|---|---|---|
| 1 | Puerto documentado | Sí | Se comprobó el puerto `5433` mediante `SHOW port` y `ss`. |
| 2 | Interfaces de escucha justificadas | Sí | Se verificó `localhost` y la escucha TCP en `127.0.0.1:5433`. |
| 3 | `pg_hba.conf` revisado | Sí | Se analizaron siete reglas mediante `pg_hba_file_rules`. |
| 4 | Redes autorizadas restringidas | Sí, en la configuración TCP inspeccionada | PostgreSQL escucha únicamente en la interfaz local y las reglas revisadas contemplan orígenes locales. |
| 5 | Autenticación segura | Parcial | Se comprobó el uso de `scram-sha-256` en conexiones TCP locales y `peer` en conexiones mediante sockets Unix. No se realizó una auditoría completa de credenciales. |
| 6 | Superusuarios identificados | Sí | Se comprobó que `postgres` tiene privilegios `SUPERUSER`. |
| 7 | Cuentas de aplicación separadas | No, solamente diseño conceptual | Se propusieron cuentas DBA, APP y CONSULTA. No se implementó esa arquitectura de cuentas. |
| 8 | Privilegios mínimos | Parcial | Se identificaron roles sin privilegios administrativos, pero no se realizó una auditoría completa de permisos sobre todos los objetos. |
| 9 | Extensiones revisadas | Sí | Se identificaron `pgcrypto` 1.4 y `plpgsql` 1.0. |
| 10 | TLS verificado | Sí, para el cifrado de la conexión probada | Se comprobó una conexión TCP con TLS 1.3 mediante `lab02_tls`. La validación de identidad del servidor requiere una revisión adicional. |
| 11 | Configuración protegida | Sí, en los permisos revisados | `postgresql.conf` y `pg_hba.conf` tienen permisos `640`. |
| 12 | Directorio de datos protegido | Sí, en los permisos revisados | `/var/lib/postgresql/18/main` tiene permisos `700`. |
| 13 | Firewall documentado | Sí, diseño conceptual | Se elaboró una política que permite una red autorizada y deniega otros orígenes. No se aplicaron reglas al firewall. |
| 14 | Actualizaciones documentadas | No | Está pendiente elaborar una política de actualización y revisión periódica. |
| 15 | Configuración registrada | Sí | Se documentaron los parámetros inspeccionados y la comparación antes/después en `configuracion/cambios.md`. |

### Análisis

De los quince controles, varios pudieron verificarse directamente mediante consultas a PostgreSQL y comandos de Ubuntu.

Se comprobó que el servidor escucha únicamente en una interfaz TCP local, utiliza métodos de autenticación identificados y cuenta con permisos restrictivos sobre sus archivos principales.

También se verificó una conexión cifrada mediante TLS 1.3.

Sin embargo, no todos los controles se encuentran implementados completamente.

La separación de cuentas administrativas y de aplicación se realizó de manera conceptual. Asimismo, la revisión de privilegios y autenticación fue parcial.

La política de firewall se documentó, pero no fue aplicada al sistema operativo.

Finalmente, se identificó que todavía debe elaborarse una política de actualizaciones y revisiones periódicas.

Estos resultados permiten distinguir entre controles comprobados, controles parcialmente revisados y mejoras pendientes.

### Conclusión

Se elaboró un checklist de quince controles de hardening utilizando los resultados reales del laboratorio.

La actividad permitió comprobar qué medidas de seguridad se encuentran presentes y cuáles necesitan una evaluación o implementación adicional.

También se comprendió que una lista de verificación no debe limitarse a marcar controles como completados, sino que debe respaldar cada evaluación mediante evidencia.

No se modificó la configuración del servidor durante esta actividad.

## Conclusiones

Pendiente de completar al finalizar el laboratorio.
