# Informe general — LAB-01: Bitácoras y auditoría del dato

## 1. Despliegue y situación inicial

El laboratorio se realizó en Ubuntu utilizando PostgreSQL 18.6, mediante la terminal y la herramienta `psql`.

Se trabajó con el clúster `18/main`, configurado en el puerto `5433`, y con la base de datos `comercial`.

El servidor se administró mediante los servicios de PostgreSQL disponibles en Ubuntu, utilizando `systemctl` y `pg_lsclusters` para verificar su funcionamiento.

Al comenzar la práctica, se identificó que la configuración de registros era insuficiente para investigar completamente los cambios realizados sobre datos sensibles.

El parámetro `logging_collector` se encontraba desactivado, `log_disconnections` tenía el valor `off` y `log_statement` estaba configurado como `none`.

Además, el registro de conexiones no estaba habilitado.

Esta situación dificultaba reconstruir acontecimientos relacionados con accesos, errores y modificaciones de información.

El escenario principal consistió en investigar cambios realizados sobre los datos de clientes, especialmente el RFC de María García.

Se comprobó que no era posible reconstruir completamente los acontecimientos anteriores a la activación de los mecanismos de auditoría, debido a que la información necesaria no había sido registrada.

## 2. Configuración aplicada

Se configuraron distintos mecanismos para mejorar el registro de actividades en PostgreSQL.

### 2.1. Configuración de bitácoras

Los parámetros quedaron establecidos de la siguiente manera:

| Parámetro | Valor final | Finalidad |
|---|---|---|
| `logging_collector` | `on` | Recolectar los registros del servidor. |
| `log_connections` | `on` | Registrar conexiones. |
| `log_disconnections` | `on` | Registrar desconexiones. |
| `log_statement` | `mod` | Registrar sentencias de modificación y determinadas operaciones administrativas. |
| `log_line_prefix` | `%m [%p] user=%u db=%d app=%a client=%h ` | Identificar fecha, proceso, usuario, base de datos, aplicación y cliente. |

Para activar `logging_collector` fue necesario reiniciar el clúster PostgreSQL 18.

Los demás cambios se aplicaron mediante recargas de configuración y la actualización de las sesiones correspondientes.

Se comprobó el funcionamiento de los registros consultando la bitácora desde la vista `dba.bitacora`.

### 2.2. Configuración de auditoría de datos

Se creó el esquema `auditoria` y se restringieron sus permisos.

Dentro del esquema se creó la tabla `cambios_clientes`, destinada a conservar información sobre las operaciones realizadas en la tabla `clientes`.

Se implementó la función `auditoria.registrar_cambio_cliente()` y el disparador `trg_auditoria_clientes`.

La función registra las operaciones de inserción, actualización y eliminación, conservando los valores anteriores y posteriores cuando corresponde.

### 2.3. Configuración de pgAudit

Se instaló pgAudit 18.0 y se configuró PostgreSQL para cargar la biblioteca al iniciar.

Posteriormente se creó la extensión en la base de datos `comercial`.

Se creó el rol `auditor_datos`, sin capacidad de iniciar sesión, y se utilizaron sus privilegios para seleccionar las columnas sensibles que debían auditarse.

Los parámetros utilizados fueron:

| Parámetro | Valor |
|---|---|
| `pgaudit.log` | `role, ddl` |
| `pgaudit.role` | `auditor_datos` |
| `pgaudit.log_relation` | `on` |

Se verificó que los parámetros estuvieran aplicados y que no existieran reinicios pendientes.

## 3. Eventos observados

Durante el laboratorio se generaron y analizaron distintos tipos de eventos.

### 3.1. Conexiones exitosas

Se identificaron conexiones autorizadas de los usuarios `postgres`, `app_ventas` y `soporte_ana`.

Los registros permitieron reconocer el usuario, la base de datos, la aplicación y la dirección de conexión.

En las conexiones TCP utilizadas para las pruebas también se identificó el uso de TLS.

### 3.2. Intentos fallidos de autenticación

Se provocaron errores de contraseña utilizando los usuarios `app_ventas` y `soporte_ana`.

También se intentó iniciar sesión con un usuario inexistente.

PostgreSQL generó registros `FATAL`, permitiendo identificar los intentos fallidos de acceso.

### 3.3. Desconexiones

Se verificó que `log_disconnections` registrara la finalización de sesiones.

Los eventos permitieron identificar al usuario y la duración de la conexión.

### 3.4. Cambios de privilegios

Se ejecutaron instrucciones `GRANT` y `REVOKE`.

Los registros permitieron identificar operaciones administrativas sobre los permisos de los usuarios.

También se comprobó que pgAudit generara un evento `AUDIT: SESSION` al ejecutar:

`GRANT SELECT ON clientes TO soporte_ana`.

### 3.5. Cambios estructurales

Se observaron instrucciones relacionadas con la creación de esquemas, tablas, funciones y disparadores.

Entre los objetos creados se encontraron el esquema `auditoria`, la tabla `auditoria.cambios_clientes` y el disparador `trg_auditoria_clientes`.

### 3.6. Modificaciones de datos

Se ejecutaron instrucciones `UPDATE` sobre la tabla `clientes`.

La configuración de `log_statement` permitió registrar sentencias de modificación.

Además, el mecanismo de auditoría mediante disparadores conservó los valores anteriores y posteriores de los registros.

### 3.7. Errores por permisos insuficientes

Se comprobó que el usuario `soporte_ana` no podía ejecutar determinadas operaciones sobre la tabla `clientes`.

PostgreSQL registró el error de permiso denegado.

Este resultado permitió comprobar que los privilegios restringen las operaciones que pueden realizar los usuarios.

## 4. Auditoría del dato

La auditoría del dato se implementó mediante la tabla `auditoria.cambios_clientes`.

Su estructura permite conservar información como:

- Identificador y fecha del evento.
- Usuario de sesión.
- Usuario efectivo.
- Aplicación utilizada.
- Dirección IP.
- Operación realizada.
- Cliente afectado.
- Valores anteriores y posteriores en formato JSONB.

La función utiliza `SECURITY DEFINER`, por lo que puede ejecutar las instrucciones necesarias con los privilegios de su propietario.

Sin embargo, mediante `session_user` se conserva la identidad del usuario que inició la sesión.

Durante las pruebas se comprobó que `app_ventas` aparecía como usuario de sesión, mientras que `postgres` aparecía como usuario efectivo.

Esta diferencia permite identificar quién realizó la modificación y bajo qué privilegios se registró el evento.

### Resultados de la auditoría

En la verificación final se encontraron:

| Operación | Cantidad |
|---|---:|
| INSERT | 1 |
| UPDATE | 8 |
| DELETE | 1 |
| **Total** | **10** |

La consulta de campos modificados identificó ocho diferencias entre valores anteriores y posteriores:

- Dos cambios de RFC.
- Cinco cambios de segmento.
- Un cambio de ciudad.

Durante el incidente de María García se comprobó que la auditoría podía conservar el valor anterior y el nuevo valor del RFC.

También se realizaron pruebas deshabilitando temporalmente el disparador.

Estas demostraron que, si el mecanismo de auditoría está desactivado, pueden realizarse modificaciones sin generar el registro correspondiente en la tabla de auditoría.

Por lo tanto, la efectividad de la auditoría depende de que sus mecanismos estén activos y protegidos.

## 5. Limitaciones

Durante el laboratorio se identificaron las siguientes limitaciones.

### 5.1. Acontecimientos anteriores

La auditoría no permite recuperar automáticamente información que nunca fue registrada.

Por esta razón, activar mecanismos de registro después de un incidente no garantiza reconstruir los acontecimientos anteriores.

### 5.2. Consultas de lectura

El disparador implementado registra `INSERT`, `UPDATE` y `DELETE`, pero no las operaciones `SELECT`.

Para registrar accesos de lectura sobre columnas sensibles se utilizó pgAudit.

### 5.3. Volumen de registros

Una configuración excesivamente detallada puede generar grandes cantidades de información.

Esto puede aumentar el consumo de almacenamiento y dificultar el análisis.

Por ello se utilizaron mecanismos selectivos y se analizaron sus diferencias.

### 5.4. Privilegios administrativos

Un superusuario puede modificar configuraciones y mecanismos de auditoría.

Durante el laboratorio se comprobó que es posible deshabilitar un disparador y alterar parámetros de registro.

Por lo tanto, la auditoría administrada únicamente dentro del mismo servidor no proporciona independencia completa frente a los administradores.

## 6. Riesgos de la bitácora

Las bitácoras pueden contener información sensible.

Durante la práctica se observó que determinadas sentencias SQL podían quedar registradas con sus valores literales.

También se identificó una contraseña utilizada durante una actividad de prueba, por lo que fue necesario sustituirla antes de publicar la copia de la bitácora.

Los principales riesgos son:

- Exposición de contraseñas y datos personales.
- Acceso de usuarios no autorizados.
- Modificación o eliminación de registros.
- Pérdida de evidencias por fallas del servidor.
- Eliminación accidental durante la rotación de archivos.
- Conservación de la única copia en el mismo servidor investigado.

Para disminuir estos riesgos es recomendable aplicar controles de acceso, proteger la información sensible, establecer políticas de conservación y almacenar copias independientes.

Durante la práctica se exportó una copia de la bitácora y se calculó su resumen SHA-256.

La verificación del resumen confirmó que el archivo coincidía con el hash calculado.

Sin embargo, este procedimiento no impide modificar el archivo y requiere proteger el resumen original para que la comprobación tenga valor.

## 7. Cronología y conclusión

### 7.1. Cronología del incidente

Durante las actividades se reconstruyó una cronología utilizando los registros disponibles.

Primero se verificó la configuración inicial de PostgreSQL y se identificaron las limitaciones del registro de actividades.

Después se configuraron los mecanismos de bitácora y se generaron eventos de conexiones, errores, cambios administrativos y modificaciones de datos.

Posteriormente se creó el mecanismo de auditoría mediante disparadores para conservar los valores anteriores y posteriores de las modificaciones.

Se realizaron pruebas sobre el RFC de María García y se identificaron eventos correspondientes a modificaciones de datos.

También se deshabilitó temporalmente el disparador para comprobar qué sucedía cuando la auditoría no estaba activa.

Finalmente, se restauró el funcionamiento del disparador, se comprobó su estado habilitado y se verificaron los eventos conservados.

La cronología detallada de los acontecimientos se documentó en:

`evidencias/15-cronologia.md`

### 7.2. Conclusión

El laboratorio permitió comprender la importancia de configurar mecanismos de registro y auditoría antes de que ocurra un incidente.

La bitácora de PostgreSQL permite identificar conexiones, desconexiones, errores y sentencias SQL.

La auditoría mediante disparadores permite conservar los valores anteriores y posteriores de los datos modificados.

pgAudit complementa estos mecanismos mediante la supervisión de operaciones administrativas y accesos a columnas sensibles.

**Con la configuración implementada es posible demostrar quién modificó un dato sensible y cuál era su valor anterior, siempre que el disparador estuviera activo y que las evidencias se hayan conservado íntegramente.**

Sin embargo, no puede garantizarse la reconstrucción de modificaciones anteriores a la activación de la auditoría ni de aquellas realizadas mientras los mecanismos estaban deshabilitados.

También se comprendió que la seguridad de la auditoría requiere proteger los registros frente a modificaciones, pérdidas y accesos no autorizados.

En un entorno profesional, los mecanismos implementados deberían complementarse con controles independientes de conservación y supervisión de evidencias.

---

# Preguntas de reflexión

## 1. ¿Por qué la auditoría no puede configurarse después de un incidente para investigarlo?

Porque la auditoría registra acontecimientos a partir del momento en que se encuentra habilitada.

Si antes de un incidente no existían mecanismos que conservaran información sobre las conexiones o modificaciones de datos, no es posible reconstruir automáticamente esos acontecimientos.

Durante el laboratorio comprobamos que la información anterior a la activación de los registros era insuficiente para investigar completamente los cambios realizados.

Esto demuestra que la auditoría debe configurarse como una medida preventiva.

## 2. ¿Por qué conviene que la bitácora la administre el propio servidor y no el mecanismo de despliegue?

Porque PostgreSQL conoce directamente las conexiones, las sesiones y las operaciones que procesa.

El mecanismo de despliegue administra la instalación y configuración del servicio, pero no necesariamente tiene visibilidad sobre todas las operaciones que realizan los usuarios dentro de la base de datos.

Al administrar sus propios registros, PostgreSQL puede relacionar los eventos con información como el usuario, la base de datos, la aplicación y el proceso.

Sin embargo, la conservación y supervisión de esas evidencias también deben apoyarse en mecanismos independientes.

## 3. ¿Por qué el prefijo de línea es tan importante como el nivel de `log_statement`?

Porque `log_statement` determina qué tipos de sentencias se registran, mientras que `log_line_prefix` agrega información que permite interpretar quién ejecutó una operación y en qué contexto.

Durante el laboratorio configuramos el prefijo para registrar datos como fecha, identificador del proceso, usuario, base de datos, aplicación y dirección del cliente.

Sin esta información sería más difícil relacionar una sentencia SQL con su responsable.

Por lo tanto, registrar una operación no es suficiente si no podemos identificar su contexto.

## 4. ¿Qué diferencia práctica hay entre registrar la sentencia y registrar el cambio en el dato?

Registrar la sentencia permite conocer la instrucción SQL ejecutada.

Por ejemplo, una sentencia `UPDATE` indica qué operación se solicitó, pero no necesariamente conserva todos los valores originales de los registros afectados.

En cambio, la auditoría mediante disparadores permite almacenar los valores anteriores y posteriores a cada modificación.

Durante la práctica utilizamos ambas opciones y comprobamos que se complementan.

La bitácora permite investigar las acciones realizadas, mientras que la tabla de auditoría permite analizar los cambios concretos en los datos.

## 5. ¿Qué evidencia ofrece `pg_stat_activity` que no ofrece la bitácora, y viceversa?

`pg_stat_activity` permite observar las sesiones y actividades existentes en un momento determinado.

Muestra información como usuario, aplicación, dirección del cliente, estado de la sesión y consulta ejecutada.

Durante el laboratorio utilizamos esta vista para identificar una sesión activa del usuario `soporte_ana`.

Sin embargo, cuando la sesión terminó, dejó de aparecer como una actividad activa.

La bitácora conserva acontecimientos registrados anteriormente, incluso después de que las conexiones finalizan, siempre que el archivo no se haya eliminado.

Por lo tanto, `pg_stat_activity` permite observar la actividad actual y la bitácora permite investigar acontecimientos históricos.

## 6. Si el administrador puede cambiar `log_statement` a `none` y desactivar el disparador, ¿quién audita al administrador?

El administrador debe estar sujeto a mecanismos de supervisión independientes de aquellos que puede modificar directamente.

Durante el laboratorio comprobamos que una cuenta con privilegios elevados podía alterar parámetros de registro y deshabilitar el disparador.

Esto significa que no es suficiente confiar únicamente en la auditoría almacenada dentro del mismo servidor.

En un entorno profesional deberían utilizarse controles adicionales, como el envío de registros a un sistema externo, la separación de funciones y la supervisión por personal distinto al administrador de la base de datos.

También deben aplicarse políticas de acceso mínimo y mecanismos para detectar modificaciones en la configuración.

La finalidad es evitar que una sola persona tenga control exclusivo sobre el servidor y sobre las evidencias utilizadas para investigar sus propias acciones.

---

# Anexo: conservación de evidencias

A continuación se conserva la documentación desarrollada durante la Actividad 16, correspondiente a la exportación, protección y verificación de integridad de la bitácora.  

## Actividad 16 — Exportación y conservación de la bitácora

Se exportó la bitácora vigente de PostgreSQL 18.6, correspondiente a la base de datos `comercial`, utilizando `pg_current_logfile()` y `pg_read_file()`.

Durante la exportación se sustituyó la contraseña de práctica por `<REDACTED>`.

Posteriormente se preparó una copia para el repositorio público, ocultando RFC y correos ficticios identificados durante la revisión.

El archivo resultante, `evidencias/bitacora-lab01.log`, contenía 210 líneas antes de las sustituciones finales.

Se calculó su resumen criptográfico mediante SHA-256 y se guardó en `evidencias/bitacora-lab01.sha256`.

Después de las sustituciones, se volvió a calcular el resumen. La comprobación con `sha256sum -c` devolvió el resultado **«La suma coincide»**.

### 1. ¿SHA-256 impide modificar la bitácora?

No. SHA-256 no impide modificar un archivo. Permite comprobar si su contenido coincide con el resumen criptográfico calculado anteriormente.

Si el archivo cambia, su hash normalmente también cambia. Para que esta comprobación sea confiable, el resumen original debe conservarse de forma segura.

### 2. ¿Dónde debería guardarse el hash?

En una ubicación independiente y protegida, preferentemente administrada por un área distinta de la responsable del servidor PostgreSQL.

Esto reduce el riesgo de que alguien modifique tanto la bitácora como su resumen criptográfico.

### 3. ¿Qué riesgos existen al conservar la bitácora únicamente en el servidor que la produce?

Según los principios de protección y gestión de registros tratados en NIST SP 800-92, conservar las bitácoras únicamente en el servidor de origen presenta riesgos como pérdida de evidencias, alteraciones por usuarios privilegiados, fallas del equipo y eliminación durante la rotación de archivos.

Por ello, conviene conservar copias independientes y aplicar controles de acceso, integridad y disponibilidad.

### 4. ¿Durante cuánto tiempo conservarías la bitácora?

Para este escenario académico propondría una conservación de 12 meses, sujeta a las necesidades de investigación y a las políticas institucionales.

En un entorno real, el periodo debe determinarse considerando los requisitos legales, la clasificación de la información, las necesidades operativas y los riesgos de seguridad.

El plazo propuesto no representa una obligación universal.

### Conclusión

La actividad permitió comprender la importancia de preservar las evidencias generadas por PostgreSQL.

Se exportó una copia de la bitácora, se ocultó información identificada durante la revisión y se verificó su integridad mediante SHA-256.

También se comprendió que la protección de evidencias requiere controles adicionales, como almacenamiento independiente, restricciones de acceso y políticas de conservación.
