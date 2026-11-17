# Actividad 1 — Lo que no existe en esta edición

## Objetivo

Identificar la edición de MongoDB utilizada, comprobar la configuración de arranque del servidor y reconocer las limitaciones de auditoría de MongoDB Community Edition.

## Entorno de trabajo

- Sistema operativo: Ubuntu 22.04.5 LTS.
- MongoDB: 7.0.48 Community Edition.
- MongoDB Shell: 2.14.2.
- Puerto: 27017.
- Dirección: 127.0.0.1.
- Usuario administrador: admin.
- Autenticación: habilitada.

## Comandos ejecutados

```javascript
db.version()

db.adminCommand({ buildInfo: 1 }).modules

db.serverCmdLineOpts().parsed

db.runCommand({ connectionStatus: 1 }).authInfo.authenticatedUsers
```

## Resultados obtenidos

La consulta `db.version()` devolvió:

```text
7.0.48
```

La consulta de módulos devolvió:

```javascript
[]
```

La configuración de arranque confirmó:

- Archivo de configuración: `/etc/mongod.conf`.
- Puerto: `27017`.
- Dirección de escucha: `127.0.0.1`.
- Autorización: `enabled`.
- Directorio de datos: `/var/lib/mongodb`.
- Destino de la bitácora: archivo.
- Ruta de la bitácora: `/var/log/mongodb/mongod.log`.
- `logAppend`: `true`.

También se comprobó que la sesión estaba autenticada con el usuario `admin` de la base de datos `admin`.

## Preguntas de la actividad

### 1. ¿Qué edición de MongoDB estás usando? ¿Qué evidencia lo demuestra?

Se utiliza MongoDB Community Edition, versión 7.0.48.

La instalación se realizó mediante el paquete oficial `mongodb-org` de MongoDB 7.

Además, la consulta de módulos devolvió un arreglo vacío (`[]`), por lo que no se identificaron módulos adicionales de Enterprise.

MongoDB Community no dispone de la auditoría nativa de seguridad incluida en Enterprise y en determinados servicios de Atlas.

### 2. ¿A dónde escribe tu servidor su bitácora? ¿Cómo lo sabes?

El servidor escribe su bitácora en:

`/var/log/mongodb/mongod.log`

Esto se comprobó mediante `db.serverCmdLineOpts().parsed`, que mostró la configuración `systemLog` con destino `file` y la ruta indicada.

También se verificó que `logAppend` está habilitado, por lo que el servidor agrega información al archivo existente en lugar de sobrescribirlo durante el arranque normal.

### 3. Según REF-U3-04, ¿qué cuatro categorías de eventos registraría la auditoría nativa?

Según la documentación de referencia indicada por el profesor, la auditoría nativa puede registrar:

1. Cambios de esquema o DDL.
2. Eventos de conjuntos de réplicas y clústeres fragmentados.
3. Eventos de autenticación y autorización.
4. Operaciones CRUD, con la configuración de auditoría correspondiente, incluido `auditAuthorizationSuccess: true` cuando sea necesario registrar autorizaciones exitosas.

Esta funcionalidad no se encuentra disponible en MongoDB Community Edition.

### 4. ¿Qué tendría que evaluar una organización antes de licenciar Enterprise o migrar a Atlas solo para obtener auditoría?

Una organización debería evaluar sus necesidades reales de seguridad, los requisitos de cumplimiento normativo, los eventos que necesita registrar y el nivel de trazabilidad requerido.

También tendría que comparar los costos de licenciamiento, infraestructura, administración, almacenamiento y conservación de evidencias.

En caso de considerar Atlas, debería evaluar las condiciones del servicio, la disponibilidad de las funciones de auditoría en el nivel contratado y los requisitos de migración.

La decisión debe considerar si los mecanismos disponibles en Community son suficientes o si se necesita una auditoría de seguridad más completa y verificable.

## Conclusión

Se comprobó que MongoDB Community Edition permite configurar autenticación, autorización y registros del servidor, pero no incluye la auditoría nativa de Enterprise.

Por lo tanto, para obtener trazabilidad en este laboratorio será necesario utilizar mecanismos alternativos, como el perfilador de operaciones, `system.profile` y la bitácora de `mongod`.

Es importante reconocer que estos mecanismos ofrecen evidencias útiles, pero no son equivalentes a una auditoría nativa de seguridad.
