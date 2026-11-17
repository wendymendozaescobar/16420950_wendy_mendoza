# Actividad 4 — Reducir el volumen con un filtro

## Objetivo

Configurar el perfilador de MongoDB Community Edition mediante un filtro que permita registrar únicamente las operaciones de inserción, actualización y eliminación, reduciendo la cantidad de información almacenada en `system.profile`.

## Entorno de trabajo

- Sistema operativo: Ubuntu 22.04.5 LTS.
- MongoDB: 7.0.48 Community Edition.
- MongoDB Shell: 2.14.2.
- Base de datos: `comercial`.
- Colección: `clientes`.
- Usuario administrador: `admin`.
- Usuario de aplicación: `app_ventas`.
- Aplicación: `app-ventas-web`.
- Fecha: 16 de noviembre de 2026.

## Comandos ejecutados

### 1. Desactivación del perfilador

Desde la sesión del administrador se ejecutó:

```javascript
db.setProfilingLevel(0)
```

Este comando desactivó temporalmente el perfilador.

Posteriormente se eliminó la colección de registros anteriores:

```javascript
db.system.profile.drop()
```

Resultado:

```text
true
```

Antes de realizar esta operación, se había exportado la información de la Actividad 3 al archivo `evidencias/system-profile.json`, con el objetivo de conservar los registros de las operaciones anteriores.

### 2. Configuración del filtro

Se ejecutó el siguiente comando:

```javascript
db.setProfilingLevel(1, {
  filter: {
    op: { $in: ["insert", "update", "remove"] }
  }
})
```

El comando configuró el perfilador en nivel 1 y estableció un filtro para registrar únicamente tres tipos de operaciones:

- `insert`: inserción de documentos.
- `update`: actualización de documentos.
- `remove`: eliminación de documentos.

Las consultas normales de lectura no cumplen las condiciones del filtro, por lo que no se registran en `system.profile`.

### 3. Verificación de la configuración

Se ejecutó:

```javascript
db.getProfilingStatus()
```

Resultado obtenido:

```javascript
{
  was: 1,
  slowms: 100,
  sampleRate: 1,
  filter: {
    op: {
      $in: ["insert", "remove", "update"]
    }
  },
  note: "When a filter expression is set, slowms and sampleRate are not used for profiling and slow-query log lines.",
  ok: 1
}
```

El valor `was: 1` confirmó que el perfilador estaba habilitado en nivel 1.

También se comprobó que el filtro contenía las operaciones `insert`, `update` y `remove`.

MongoDB indicó que, al utilizar una expresión de filtrado, los parámetros `slowms` y `sampleRate` no se utilizan para seleccionar las operaciones registradas.

## Pruebas realizadas

### 4. Consulta de un cliente

Desde la sesión del usuario `app_ventas` se ejecutó:

```javascript
db.clientes.find({ _id: 1 }).toArray()
```

La consulta devolvió el documento correspondiente a Ana López.

Esta operación permitió comprobar que el usuario podía consultar los datos correctamente.

Sin embargo, al tratarse de una lectura, no debía registrarse en `system.profile` debido al filtro configurado.

### 5. Actualización del teléfono

Desde la misma sesión se ejecutó:

```javascript
db.clientes.updateOne(
  { _id: 1 },
  { $set: { telefono: "6670000000" } }
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

El resultado confirmó que se encontró un documento y que su información fue modificada correctamente.

### 6. Consulta de system.profile

Desde la sesión del administrador se ejecutó:

```javascript
db.system.profile.find(
  {},
  {
    op: 1,
    ns: 1,
    user: 1,
    appName: 1,
    "command.q": 1,
    "command.u": 1,
    ts: 1
  }
).toArray()
```

Resultado obtenido:

```javascript
[
  {
    op: 'update',
    ns: 'comercial.clientes',
    command: {
      q: { _id: 1 },
      u: { $set: { telefono: '6670000000' } }
    },
    ts: ISODate('2026-11-17T05:54:46.966Z'),
    appName: 'app-ventas-web',
    user: 'app_ventas@comercial'
  }
]
```

El perfilador registró únicamente la operación de actualización.

No apareció la consulta `find()` realizada anteriormente.

Además, se identificaron los siguientes datos:

| Campo | Resultado |
|---|---|
| Operación | update |
| Base de datos y colección | comercial.clientes |
| Usuario | app_ventas@comercial |
| Aplicación | app-ventas-web |
| Documento | _id: 1 |
| Campo modificado | telefono |
| Nuevo valor | 6670000000 |
| Fecha y hora UTC | 2026-11-17 05:54:46.966 |

Esto confirmó que el filtro estaba funcionando correctamente.

## Preguntas de la actividad

### 1. ¿Qué perdiste de evidencia al aplicar el filtro?

Al aplicar el filtro dejé de registrar las operaciones de lectura que no cumplían las condiciones establecidas.

En la Actividad 3, cuando el perfilador estaba configurado en nivel 2, fue posible identificar consultas realizadas sobre la colección `clientes`.

En esta actividad, la consulta `find()` ya no apareció en `system.profile`.

Esto significa que se pierde información sobre las consultas de lectura, como los filtros utilizados, el usuario que las ejecutó y el momento en que ocurrieron.

Esta limitación puede dificultar investigaciones relacionadas con accesos o consultas de información, especialmente cuando se necesita determinar si alguien consultó determinados datos.

Por lo tanto, aunque el filtro reduce la cantidad de registros, también disminuye la información disponible para reconstruir algunas actividades.

### 2. ¿Qué ganaste?

La principal ventaja fue reducir el volumen de información registrada por el perfilador.

Al registrar únicamente las operaciones de inserción, actualización y eliminación, se evita almacenar consultas de lectura que no son necesarias para el objetivo específico de esta configuración.

Esto permite disminuir el crecimiento de `system.profile` y reducir parte de la carga asociada al registro de operaciones.

También facilita el análisis, ya que los registros se concentran en las operaciones que modifican datos.

Otra ventaja es que se reduce la exposición de información que podría aparecer en los filtros de las consultas.

Considero que utilizar filtros permite adaptar el perfilador a las necesidades de monitoreo de una organización, aunque es importante reconocer que algunas operaciones dejan de registrarse.

### 3. ¿Qué filtro usarías si solo interesaran operaciones sobre la colección clientes?

Utilizaría un filtro basado en el campo `ns`, que identifica la base de datos y la colección sobre la que se ejecuta una operación.

El filtro sería:

```javascript
db.setProfilingLevel(1, {
  filter: {
    ns: "comercial.clientes"
  }
})
```

Con esta configuración se seleccionarían únicamente las operaciones cuyo espacio de nombres corresponda a la colección `clientes` de la base de datos `comercial`.

Si además quisiera conservar solamente las operaciones que modifican documentos de esa colección, utilizaría un filtro combinado:

```javascript
db.setProfilingLevel(1, {
  filter: {
    ns: "comercial.clientes",
    op: { $in: ["insert", "update", "remove"] }
  }
})
```

De esta manera, el perfilador registraría exclusivamente las inserciones, actualizaciones y eliminaciones realizadas sobre `comercial.clientes`.

Estos filtros se presentan como propuestas de configuración; no fueron aplicados durante esta actividad.

## Análisis de resultados

En esta actividad comprobé que MongoDB permite configurar filtros para controlar qué operaciones registra el perfilador.

El nivel 2 utilizado anteriormente registraba las operaciones de consulta, actualización y eliminación.

En cambio, al utilizar el nivel 1 con un filtro específico, únicamente se registró la actualización del teléfono de Ana López.

La operación quedó asociada al usuario `app_ventas@comercial` y a la aplicación `app-ventas-web`.

Esto demuestra que es posible obtener información útil sobre las modificaciones de los datos sin registrar todas las consultas.

Sin embargo, también se comprobó que la reducción del volumen de registros implica perder evidencia de determinadas operaciones.

## Conclusión

En esta actividad aprendí a configurar el perfilador de MongoDB utilizando un filtro personalizado.

Comprobé que las consultas de lectura dejaron de registrarse, mientras que las operaciones de actualización continuaron apareciendo en `system.profile`.

También comprendí que los filtros permiten reducir el volumen de información almacenada y concentrar el monitoreo en operaciones específicas.

Sin embargo, esta configuración implica una pérdida de evidencia sobre las operaciones excluidas.

Por lo tanto, considero importante definir los filtros de acuerdo con las necesidades de trazabilidad, seguridad y rendimiento de cada sistema.
