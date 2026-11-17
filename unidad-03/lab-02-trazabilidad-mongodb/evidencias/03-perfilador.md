# Actividad 3 — Activar el perfilador y registrar operaciones

## Objetivo

Activar el perfilador de MongoDB Community Edition para registrar operaciones sobre la colección `clientes`, identificar al usuario que las ejecutó y analizar la información disponible para la trazabilidad de las operaciones.

## Entorno de trabajo

- Sistema operativo: Ubuntu 22.04.5 LTS.
- MongoDB: 7.0.48 Community Edition.
- MongoDB Shell: 2.14.2.
- Base de datos: `comercial`.
- Colección: `clientes`.
- Usuario administrador: `admin`.
- Usuario de aplicación: `app_ventas`.
- Aplicación: `app-ventas-web`.
- Dirección del cliente: `127.0.0.1`.
- Fecha de realización: 16 de noviembre de 2026.

## Comandos ejecutados

### 1. Activación del perfilador

Desde la sesión del administrador se ejecutaron los siguientes comandos:

```javascript
use comercial

db.setProfilingLevel(2)

db.getProfilingStatus()
```

El nivel 2 permite registrar las operaciones realizadas sobre la base de datos.

A diferencia del nivel 0, que mantiene desactivado el perfilador, el nivel 2 registra las operaciones para su posterior análisis.

Los registros se almacenan en la colección `system.profile` de la base de datos correspondiente.

### 2. Consulta de clientes

Desde la sesión del usuario `app_ventas` se ejecutó:

```javascript
db.clientes.find(
  { ciudad: "Culiacán" },
  { nombre: 1, ciudad: 1 }
).toArray()
```

Resultado:

```javascript
[
  { _id: 1, nombre: 'Ana López', ciudad: 'Culiacán' },
  { _id: 2, nombre: 'Carlos Pérez', ciudad: 'Culiacán' },
  { _id: 5, nombre: 'Laura Sánchez', ciudad: 'Culiacán' }
]
```

La consulta encontró tres clientes de Culiacán.

El perfilador registró:

- Operación: `query`.
- Documentos examinados: `5`.
- Documentos devueltos: `3`.
- Duración: `0 ms`.
- Usuario: `app_ventas@comercial`.
- Aplicación: `app-ventas-web`.
- Cliente: `127.0.0.1`.

### 3. Actualización del RFC

Se ejecutó:

```javascript
db.clientes.updateOne(
  { _id: 3 },
  { $set: { rfc: "GAMA780912XYZ" } }
)
```

Resultado:

```javascript
{
  acknowledged: true,
  insertedId: null,
  matchedCount: 1,
  modifiedCount: 1,
  upsertedCount: 0
}
```

MongoDB confirmó que se modificó un documento.

El perfilador registró:

- Operación: `update`.
- Documento identificado: `_id: 3`.
- Nuevo RFC: `GAMA780912XYZ`.
- Documentos examinados: `1`.
- Documentos modificados: `1`.
- Duración: `0 ms`.
- Usuario: `app_ventas@comercial`.
- Aplicación: `app-ventas-web`.

### 4. Eliminación de un cliente

Se ejecutó:

```javascript
db.clientes.deleteOne({ _id: 2 })
```

Resultado:

```javascript
{
  acknowledged: true,
  deletedCount: 1
}
```

Se eliminó correctamente un documento.

El perfilador registró:

- Operación: `remove`.
- Documento identificado: `_id: 2`.
- Documentos examinados: `1`.
- Documentos eliminados: `1`.
- Duración: `0 ms`.
- Usuario: `app_ventas@comercial`.
- Aplicación: `app-ventas-web`.

### 5. Consulta de system.profile

Desde la sesión del administrador se ejecutó:

```javascript
db.system.profile.find(
  { ns: "comercial.clientes" },
  {
    op: 1,
    ns: 1,
    command: 1,
    user: 1,
    client: 1,
    appName: 1,
    ts: 1,
    millis: 1,
    nreturned: 1,
    docsExamined: 1,
    nModified: 1,
    ndeleted: 1
  }
).sort({ ts: 1 }).toArray()
```

El resultado mostró las tres operaciones realizadas por `app_ventas`.

Se pudo identificar el tipo de operación, el comando ejecutado, el usuario, la aplicación, la dirección del cliente y la fecha y hora de cada evento.

## Interpretación de los documentos

| # | Operación | Usuario | Cliente | Aplicación | Momento (UTC) | Qué hizo | Documentos afectados |
|---|---|---|---|---|---|---|---|
| 1 | query | app_ventas@comercial | 127.0.0.1 | app-ventas-web | 2026-11-17 05:32:09.632 | Consultó clientes de Culiacán | 3 devueltos |
| 2 | update | app_ventas@comercial | 127.0.0.1 | app-ventas-web | 2026-11-17 05:32:15.570 | Modificó el RFC del cliente 3 | 1 modificado |
| 3 | remove | app_ventas@comercial | 127.0.0.1 | app-ventas-web | 2026-11-17 05:32:24.936 | Eliminó el cliente 2 | 1 eliminado |

Las marcas de tiempo `ts` están expresadas en UTC. En la zona horaria local de Sinaloa, las operaciones se realizaron el 16 de noviembre de 2026, aproximadamente entre las 22:32:09 y las 22:32:24.

## Preguntas de la actividad

### 1. ¿Puedes saber cuál era el RFC antes del cambio con la información de system.profile?

No. El perfilador registra la operación de actualización y el nuevo valor asignado al campo `rfc`, pero no conserva automáticamente el valor anterior.

En esta actividad, `system.profile` mostró que el usuario `app_ventas` ejecutó una actualización sobre el documento `_id: 3` y estableció el RFC `GAMA780912XYZ`.

Sabemos que anteriormente el RFC era `GAMA780912XXX` porque ese valor se estableció durante la Actividad 2.

Sin embargo, esta información proviene de una operación anterior del laboratorio y no puede recuperarse únicamente del registro actual de `system.profile`.

Por lo tanto, el perfilador permite identificar la modificación realizada, pero no reconstruir automáticamente el historial completo de valores del documento.

### 2. ¿Puedes saber qué datos tenía el documento eliminado?

No. El perfilador registró que se eliminó el documento con `_id: 2`, pero no almacenó una copia completa de su contenido.

El registro mostró:

```javascript
{
  q: { _id: 2 },
  limit: 1
}
```

También indicó que se eliminó un documento mediante `ndeleted: 1`.

En este laboratorio sabemos que el documento correspondía a Carlos Pérez porque sus datos fueron insertados durante la preparación del entorno.

Sin embargo, esa información no puede reconstruirse únicamente a partir del registro de eliminación de `system.profile`.

Para recuperar el contenido anterior sería necesario contar con respaldos, registros históricos u otro mecanismo que conservara los datos eliminados.

### 3. A diferencia de log_statement = 'mod' en PostgreSQL, el nivel 2 sí registró la consulta. ¿Qué ventaja y qué riesgo tiene eso?

La principal ventaja es que el nivel 2 permite obtener mayor información sobre las operaciones realizadas en la base de datos.

Además de las modificaciones y eliminaciones, registra las consultas ejecutadas, lo que puede ayudar a investigar accesos a la información, identificar consultas problemáticas y analizar el comportamiento de las aplicaciones.

En esta actividad pudimos identificar que `app_ventas` consultó los clientes de Culiacán y que MongoDB examinó cinco documentos para devolver tres resultados.

Sin embargo, también existen riesgos.

El perfilador puede registrar filtros y parámetros de consultas que contengan información personal o sensible.

Esto significa que los registros pueden almacenar datos que deben protegerse adecuadamente para evitar accesos no autorizados.

Además, activar el nivel 2 puede incrementar el consumo de recursos y el volumen de información almacenada, especialmente en sistemas con muchas operaciones.

Por lo tanto, considero que el nivel 2 es útil para investigaciones y diagnósticos específicos, pero debe utilizarse cuidadosamente en ambientes de producción.

### 4. ¿Por qué el campo user incluye @comercial?

El campo `user` contiene el nombre del usuario autenticado y la base de datos donde está definido.

En esta actividad apareció:

```text
app_ventas@comercial
```

Esto significa que el nombre del usuario es `app_ventas` y que fue creado en la base de datos `comercial`.

MongoDB permite que existan usuarios con el mismo nombre en distintas bases de datos de autenticación.

Por ello, incluir `@comercial` permite identificar de manera más precisa la cuenta utilizada para ejecutar la operación.

No significa que el usuario tenga acceso a todas las bases de datos, sino que su identidad está asociada a esa base de datos de autenticación.

## Análisis de resultados

Al comparar esta actividad con la anterior, se observó una diferencia importante.

En la Actividad 2, el perfilador estaba desactivado y `system.profile` no contenía registros de la modificación realizada.

En cambio, al activar el nivel 2, MongoDB registró una consulta, una actualización y una eliminación.

Los documentos permitieron identificar al usuario `app_ventas@comercial`, la aplicación `app-ventas-web`, la dirección `127.0.0.1` y el momento de ejecución.

También se observó que el perfilador no conserva automáticamente los valores anteriores de los documentos modificados o eliminados.

Esto demuestra que el perfilador proporciona información útil para la trazabilidad, aunque no sustituye a una auditoría nativa de seguridad ni a un mecanismo de historial de cambios.

## Conclusión

En esta actividad comprobé que MongoDB Community Edition permite registrar operaciones mediante el Database Profiler.

Al activar el nivel 2, pude consultar en `system.profile` las operaciones de lectura, actualización y eliminación realizadas por el usuario `app_ventas`.

También pude identificar el momento de cada operación, la aplicación utilizada y la dirección desde la cual se estableció la conexión.

Comprendí que esta herramienta mejora la trazabilidad de las operaciones, pero tiene limitaciones importantes, especialmente porque no conserva automáticamente los valores anteriores de los documentos.

Además, su utilización requiere considerar el impacto en el rendimiento y la posible exposición de datos personales dentro de los registros.

Por lo tanto, el perfilador resulta útil para analizar operaciones y realizar diagnósticos, pero no debe considerarse un sustituto completo de la auditoría de seguridad.
