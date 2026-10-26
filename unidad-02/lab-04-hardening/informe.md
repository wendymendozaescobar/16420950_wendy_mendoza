# LAB-04 — Informe de hardening y configuración segura de PostgreSQL

## Introducción

El objetivo de este laboratorio fue analizar la configuración de seguridad de PostgreSQL, identificar posibles riesgos y proponer medidas de hardening para reducir la superficie de ataque.

Las actividades se realizaron en Ubuntu, utilizando PostgreSQL 18.6, el puerto `5433` y la base de datos `laboratorios_unidad2`.

Durante las prácticas se revisaron las interfaces de escucha, las reglas de autenticación, los roles y privilegios, las extensiones, los parámetros de conexión, los permisos del sistema operativo y el uso de TLS.

También se diseñó una política conceptual de firewall, se elaboró un checklist de seguridad y se construyó una línea base.

No se aplicaron modificaciones a la configuración del servidor. Las propuestas de mejora se documentaron para distinguirlas de los controles realmente verificados.

## Preguntas del informe

### 1. ¿Cuál era la principal superficie de ataque?

La principal superficie de ataque que analizamos fue el acceso al servicio PostgreSQL mediante conexiones de red, ya que una configuración demasiado permisiva podría permitir intentos de conexión desde equipos no autorizados.

Por eso revisamos el parámetro `listen_addresses`, el puerto y las reglas de `pg_hba.conf`.

En nuestro servidor comprobamos que PostgreSQL utiliza el puerto `5433` y escucha mediante TCP en `127.0.0.1`.

Esto significa que no encontramos exposición TCP del servidor hacia interfaces externas.

También revisamos otras posibles superficies de ataque, como las cuentas con privilegios administrativos, las extensiones instaladas y los archivos del sistema operativo.

### 2. ¿Qué configuración representaba el mayor riesgo?

En el escenario hipotético analizado, una de las configuraciones más riesgosas era la combinación de `listen_addresses = '*'`, un firewall que permitía conexiones desde cualquier origen y una regla de `pg_hba.conf` con `0.0.0.0/0`.

Esta combinación ampliaba considerablemente los orígenes desde los que se podía intentar acceder a PostgreSQL.

El riesgo aumentaba porque una aplicación utilizaba una cuenta con privilegios administrativos.

En nuestro servidor local no encontramos esa combinación. Las interfaces de escucha y las reglas de autenticación estaban limitadas a conexiones locales.

Por lo tanto, ese riesgo corresponde al caso propuesto por el profesor y no a un problema que hayamos detectado en nuestra instalación.

### 3. ¿Qué cambio produjo la mayor reducción de exposición?

Durante el laboratorio no realizamos modificaciones a la configuración del servidor, por lo que no podemos afirmar que algún cambio aplicado haya reducido su exposición.

Sin embargo, al analizar el escenario hipotético, identificamos que restringir las interfaces y los orígenes autorizados produciría una reducción importante de la superficie de ataque.

Por ejemplo, reemplazar una configuración que escucha en todas las interfaces por otra que utiliza únicamente las necesarias impediría que PostgreSQL aceptara conexiones TCP a través de interfaces no autorizadas.

Esta medida debe complementarse con reglas de firewall y `pg_hba.conf`.

En nuestra instalación ya encontramos `listen_addresses = 'localhost'`, por lo que no fue necesario aplicar esa modificación.

### 4. ¿Qué diferencia existe entre firewall y `pg_hba.conf`?

El firewall controla el tráfico de red que puede llegar a un servidor, utilizando condiciones como la dirección de origen, la dirección de destino, el puerto y el protocolo.

Por su parte, `pg_hba.conf` es un archivo de configuración de PostgreSQL que define qué conexiones pueden autenticarse y qué método de autenticación deben utilizar.

Por ejemplo, un firewall puede permitir que una computadora se comunique con el puerto de PostgreSQL, pero el servidor todavía puede rechazar la conexión si no cumple las reglas de `pg_hba.conf`.

Por eso ambos mecanismos son complementarios y no deben considerarse equivalentes.

### 5. ¿Qué diferencia existe entre autenticación y autorización?

La autenticación permite comprobar la identidad de un usuario que intenta conectarse a PostgreSQL.

La autorización determina qué operaciones puede realizar ese usuario después de autenticarse.

Por ejemplo, un usuario puede ingresar correctamente mediante su contraseña, pero eso no significa que tenga permiso para consultar, modificar o eliminar cualquier tabla.

Durante el laboratorio comprobamos mecanismos de autenticación como `peer` y `scram-sha-256`.

También revisamos los atributos de los roles para distinguir las cuentas administrativas de aquellas que no disponen de privilegios elevados.

### 6. ¿Por qué una cuenta de aplicación no debe ser `SUPERUSER`?

Una cuenta de aplicación no debe utilizar privilegios de superusuario porque normalmente necesita realizar un conjunto limitado de operaciones sobre determinadas bases de datos.

El atributo `SUPERUSER` permite superar muchas restricciones de permisos de PostgreSQL, por lo que utilizarlo incrementa el impacto de errores y accesos no autorizados.

Si una aplicación es comprometida y utiliza una cuenta de superusuario, el atacante podría disponer de capacidades administrativas sobre el servidor.

La alternativa es utilizar cuentas específicas para cada aplicación, con únicamente los permisos necesarios.

Esto corresponde al principio de mínimo privilegio, uno de los controles que analizamos durante el laboratorio.

### 7. ¿Por qué cambiar el puerto de PostgreSQL no constituye hardening suficiente?

Cambiar el puerto predeterminado de PostgreSQL puede reducir algunos intentos de conexión automatizados que buscan exclusivamente el puerto `5432`.

Sin embargo, no impide que una persona identifique el puerto utilizado ni corrige problemas de autenticación, autorización o exposición de red.

Por ejemplo, un servidor que escucha en todas las interfaces y permite conexiones desde cualquier origen continúa presentando riesgos aunque utilice un puerto diferente.

En nuestro laboratorio utilizamos el puerto `5433`, pero no lo consideramos una medida suficiente de seguridad.

Es necesario complementarlo con restricciones de red, autenticación adecuada, privilegios mínimos y otros controles.

### 8. ¿Por qué `listen_addresses = '*'` puede ser innecesario?

El valor `'*'` permite que PostgreSQL escuche en todas las interfaces de red disponibles, siempre que el sistema y el resto de la configuración lo permitan.

Esto puede ser innecesario cuando las aplicaciones se ejecutan en el mismo equipo o solamente necesitan acceder desde una red específica.

Mantener interfaces de escucha que no son necesarias aumenta la superficie de ataque.

Durante el laboratorio comprobamos que nuestro servidor utiliza `listen_addresses = 'localhost'`.

Esta configuración resulta adecuada para nuestras prácticas porque realizamos las conexiones desde el mismo equipo.

### 9. ¿Qué papel tiene el sistema operativo en la seguridad de PostgreSQL?

El sistema operativo protege los archivos, directorios y procesos utilizados por PostgreSQL.

Aunque la base de datos cuente con usuarios y permisos, también es necesario impedir que personas no autorizadas puedan acceder directamente a sus archivos físicos.

Durante la práctica revisamos permisos de Ubuntu y comprobamos que `postgresql.conf` y `pg_hba.conf` tenían permisos `640`.

También verificamos que el directorio de datos `/var/lib/postgresql/18/main` tenía permisos `700`.

Estos permisos restringen el acceso ordinario a los archivos y datos del servidor.

Por lo tanto, la seguridad de PostgreSQL depende tanto de sus controles internos como de la protección proporcionada por el sistema operativo.

### 10. ¿Qué controles deberían revisarse periódicamente?

Considero importante revisar periódicamente las interfaces y los puertos utilizados por PostgreSQL, las reglas de `pg_hba.conf` y las políticas de firewall.

También deben supervisarse las cuentas administrativas, los privilegios asignados a los roles y las cuentas utilizadas por las aplicaciones.

Otros elementos que requieren revisión son los certificados TLS, las extensiones instaladas, los parámetros de conexión, los permisos del sistema operativo y los registros de actividad.

Además, es importante mantener una política de actualizaciones de seguridad y comprobar que los cambios de configuración no afecten el funcionamiento del servicio.

Estas revisiones permiten identificar riesgos nuevos, eliminar accesos innecesarios y mantener actualizada la línea base de seguridad.

## Reflexión individual

### ¿Qué cambiarías primero si recibieras la responsabilidad de asegurar un servidor PostgreSQL que ya se encuentra funcionando en producción?

Si recibiera la responsabilidad de asegurar un servidor PostgreSQL que ya está funcionando en producción, primero revisaría su exposición de red y determinaría desde qué equipos y aplicaciones necesita aceptar conexiones.

No modificaría inmediatamente la configuración, porque en producción podría haber aplicaciones que dependan del acceso actual.

Primero identificaría las conexiones legítimas, los puertos utilizados, las interfaces de escucha y las reglas existentes en el firewall y en `pg_hba.conf`.

También comprobaría si existen respaldos y procedimientos de recuperación, además de coordinar una ventana de mantenimiento cuando fuera necesaria.

Una vez identificadas las conexiones autorizadas, mi primera modificación, si encontrara una exposición innecesaria, sería restringir los orígenes permitidos mediante reglas de firewall cuidadosamente verificadas.

Elegiría este control porque puede reducir los intentos de conexión desde equipos no autorizados antes de que lleguen al proceso de autenticación de PostgreSQL.

Sin embargo, aplicaría las restricciones de forma gradual para evitar bloquear a las aplicaciones que necesitan utilizar la base de datos.

Después revisaría `listen_addresses` y `pg_hba.conf` para asegurar que sus reglas coincidan con las necesidades reales del sistema.

También consideraría prioritario comprobar si las aplicaciones utilizan cuentas con privilegios administrativos.

Si encontrara una aplicación conectándose como superusuario, planificaría su migración a una cuenta con permisos mínimos, después de identificar las operaciones que necesita realizar.

No haría ese cambio sin pruebas porque podría provocar errores en la aplicación y afectar la disponibilidad del servicio.

Finalmente, verificaría los mecanismos de autenticación, TLS, los permisos del sistema operativo y el monitoreo.

Mi objetivo sería reducir primero los riesgos de mayor exposición, pero sin comprometer la continuidad de las operaciones.

Considero que asegurar un servidor de producción no consiste en cambiar muchos parámetros rápidamente, sino en conocer su funcionamiento, identificar los riesgos más importantes, aplicar controles justificados y comprobar que cada modificación mantenga el servicio disponible.

## Conclusión general

El LAB-04 me permitió comprender que la seguridad de PostgreSQL depende de diferentes controles que deben trabajar conjuntamente.

Aprendí a identificar las interfaces de escucha, revisar las reglas de autenticación, analizar los privilegios de los roles y comprobar el uso de TLS en conexiones específicas.

También comprendí la importancia de proteger los archivos del sistema operativo, documentar las configuraciones y evaluar los riesgos antes de realizar modificaciones.

La verificación final confirmó que los parámetros inspeccionados mantenían los valores registrados durante el desarrollo de las actividades.

Aunque no realizamos cambios técnicos en el servidor, identificamos controles existentes y documentamos medidas de mejora.

La principal enseñanza del laboratorio fue que el hardening debe realizarse a partir de evidencia, considerando tanto la seguridad como la disponibilidad y continuidad de los sistemas.
