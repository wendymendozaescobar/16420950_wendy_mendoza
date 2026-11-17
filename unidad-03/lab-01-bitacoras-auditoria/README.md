# LAB-01 — Bitácoras y auditoría del dato

## 1. Objetivo

Implementar y verificar mecanismos de registro y auditoría en PostgreSQL para identificar accesos, errores, cambios de configuración, modificaciones de privilegios y operaciones sobre datos sensibles.

El laboratorio se desarrolló mediante tres mecanismos complementarios:

- Bitácoras del servidor PostgreSQL.
- Auditoría de datos mediante una tabla y un disparador.
- Auditoría de sesión y objeto mediante la extensión pgAudit.

El escenario consiste en investigar modificaciones realizadas sobre los datos de clientes de una base de datos comercial, especialmente los cambios en el RFC de María García.

## 2. Entorno y despliegue

El laboratorio se realizó en una instalación local de PostgreSQL sobre Ubuntu, administrada mediante la terminal.

El servidor utiliza el sistema de servicios de Linux y los clústeres PostgreSQL disponibles en el equipo.

| Elemento | Configuración utilizada |
|---|---|
| Sistema operativo | Ubuntu |
| Gestor de bases de datos | PostgreSQL |
| Versión | 18.6 |
| Clúster | 18/main |
| Puerto | 5433 |
| Base de datos | comercial |
| Usuario administrador | postgres |
| Herramienta de administración | psql |
| Extensión adicional | pgAudit 18.0 |
| Repositorio | GitHub |

La instalación utiliza paquetes PostgreSQL para Ubuntu y el clúster se administra mediante `systemctl`.

### Conexión al servidor

Para acceder como administrador:

```bash
sudo -u postgres psql -p 5433 -d comercial
```

Para verificar los clústeres disponibles:

```bash
pg_lsclusters
```

Para comprobar el estado del servidor utilizado:

```bash
systemctl is-active postgresql@18-main
```

El laboratorio se realizó en PostgreSQL 18, aunque la guía del profesor utiliza PostgreSQL 16 como referencia.

Se conservó el servidor y la base de datos para continuar con los siguientes laboratorios de la Unidad 03.

## 3. Situación inicial

Al comenzar el laboratorio, PostgreSQL no registraba toda la información necesaria para reconstruir las modificaciones de los datos.

Se identificaron las siguientes limitaciones:

- El colector de registros estaba desactivado.
- El registro de conexiones no estaba habilitado.
- El registro de desconexiones estaba desactivado.
- `log_statement` tenía el valor `none`.
- No existía una auditoría de datos que conservara los valores anteriores y posteriores a cada modificación.

Estas limitaciones impedían responder con suficiente evidencia quién había realizado determinados cambios y qué valores tenían los registros antes de modificarse.

## 4. Configuración de bitácoras

Durante el laboratorio se configuraron los siguientes parámetros:

| Parámetro | Valor final |
|---|---|
| logging_collector | on |
| log_connections | on |
| log_disconnections | on |
| log_statement | mod |
| log_line_prefix | %m [%p] user=%u db=%d app=%a client=%h |

La activación de `logging_collector` requirió reiniciar el servicio PostgreSQL 18.

Las demás configuraciones se aplicaron mediante los procedimientos de recarga o actualización correspondientes.

Se comprobó el registro de:

- Conexiones exitosas.
- Intentos fallidos de autenticación.
- Desconexiones.
- Cambios de privilegios.
- Cambios estructurales.
- Sentencias de modificación de datos.
- Errores por permisos insuficientes.

También se creó la vista `dba.bitacora` para consultar las entradas del archivo de registro desde PostgreSQL.

## 5. Auditoría de modificaciones de datos

Se creó el esquema `auditoria` y la tabla:

`auditoria.cambios_clientes`

La tabla conserva información como:

- Fecha y hora del acontecimiento.
- Usuario de sesión.
- Usuario efectivo.
- Aplicación.
- Dirección IP.
- Tipo de operación.
- Identificador del cliente.
- Valores anteriores y posteriores en formato JSONB.

Se implementó la función:

`auditoria.registrar_cambio_cliente()`

La función utiliza `SECURITY DEFINER` para escribir los registros de auditoría con los privilegios de su propietario.

Al mismo tiempo, conserva el usuario original mediante `session_user`.

Se creó el disparador:

`trg_auditoria_clientes`

Este registra operaciones `INSERT`, `UPDATE` y `DELETE` sobre la tabla `clientes`.

### Resultados

En la verificación final se encontraron:

| Operación | Eventos |
|---|---:|
| INSERT | 1 |
| UPDATE | 8 |
| DELETE | 1 |
| **Total** | **10** |

El disparador permaneció habilitado al finalizar las pruebas.

## 6. Auditoría con pgAudit

Se instaló el paquete `postgresql-18-pgaudit` y se habilitó su biblioteca mediante:

```sql
ALTER SYSTEM SET shared_preload_libraries = 'pgaudit';
```

Después de reiniciar PostgreSQL 18, se creó la extensión en la base de datos `comercial`.

La versión comprobada fue pgAudit 18.0.

Para la auditoría selectiva se creó el rol:

`auditor_datos`

Este rol tiene el atributo `NOLOGIN` y privilegios de consulta y modificación sobre las columnas `rfc` y `telefono`.

Se configuraron los siguientes parámetros:

| Parámetro | Valor |
|---|---|
| pgaudit.log | role, ddl |
| pgaudit.role | auditor_datos |
| pgaudit.log_relation | on |

### Resultados de las pruebas

| Operación | Auditoría de objeto |
|---|---|
| SELECT nombre, ciudad | No |
| SELECT nombre, rfc | Sí |
| SELECT * | Sí |
| UPDATE rfc | Sí |
| UPDATE ciudad | No |

También se comprobó que la sentencia `GRANT SELECT ON clientes TO soporte_ana` generó un evento de auditoría de sesión.

Los resultados permitieron distinguir entre la auditoría de objeto y la auditoría de sesión.

## 7. Conservación e integridad de evidencias

Se exportó una copia de la bitácora del servidor PostgreSQL.

Archivo:

`evidencias/bitacora-lab01.log`

Se revisó y se sustituyó la información sensible identificada antes de incorporarla al repositorio.

Posteriormente se calculó un resumen criptográfico SHA-256.

Archivo:

`evidencias/bitacora-lab01.sha256`

La integridad se verificó mediante:

```bash
sha256sum -c evidencias/bitacora-lab01.sha256
```

La comprobación indicó que la suma coincidía.

El resumen SHA-256 permite verificar la integridad de la copia exportada, pero no sustituye los controles de acceso ni el almacenamiento independiente de evidencias.

## 8. Estructura del laboratorio

Los archivos se organizaron de la siguiente manera:

```text
lab-01-bitacoras-auditoria/
├── README.md
├── sql/
│   ├── 01-colector-y-vista.sql
│   ├── 02-configuracion-bitacora.sql
│   ├── 03-privilegios-estructura.sql
│   ├── 04-esquema-auditoria.sql
│   ├── 05-funcion-disparador.sql
│   └── 06-campos-modificados.sql
├── evidencias/
│   ├── 01-configuracion-inicial.md
│   ├── 02-colector.md
│   ├── 03-incidente-sin-bitacora.md
│   ├── 04-configuracion-bitacora.md
│   ├── 05-accesos.md
│   ├── 06-privilegios-estructura.md
│   ├── 07-modificaciones.md
│   ├── 08-errores.md
│   ├── 09-pg-stat-activity.md
│   ├── 10-diseno-auditoria.md
│   ├── 12-altas-bajas.md
│   ├── 13-manipulacion.md
│   ├── 14-limites.md
│   ├── 15-cronologia.md
│   ├── 16-pgaudit.md
│   ├── bitacora-lab01.log
│   └── bitacora-lab01.sha256
└── informe.md
```

Los archivos SQL contienen las instrucciones utilizadas durante las actividades.

Los documentos de evidencias incluyen los resultados y su interpretación.

El archivo `informe.md` reúne el análisis general, las limitaciones y las conclusiones del laboratorio.

## 9. Resultados y conclusiones

Durante el laboratorio se comprobó que los mecanismos de auditoría ofrecen información complementaria.

La bitácora de PostgreSQL permite registrar actividades del servidor, conexiones, errores y sentencias SQL.

La auditoría mediante disparadores permite conservar los valores anteriores y posteriores de los datos modificados.

pgAudit permite ampliar el registro de operaciones y supervisar accesos a columnas sensibles.

También se comprobó que existen limitaciones:

- Los acontecimientos anteriores a la activación de los registros no pueden reconstruirse completamente.
- Los disparadores no registran consultas SELECT.
- Un usuario con privilegios elevados puede intervenir en la configuración de auditoría.
- El registro de sentencias no siempre permite conocer los valores anteriores de los datos.
- La conservación de evidencias requiere protección adicional.

En conclusión, una estrategia de auditoría debe combinar mecanismos de registro, permisos mínimos, protección de evidencias y supervisión independiente para mejorar la trazabilidad y la seguridad de la información.
