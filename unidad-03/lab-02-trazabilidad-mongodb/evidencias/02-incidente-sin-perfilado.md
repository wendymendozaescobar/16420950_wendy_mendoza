# Actividad 2 — El incidente sin perfilado

## Objetivo

Comprobar qué información permite recuperar MongoDB Community Edition cuando se modifica un documento mientras el perfilador de la base de datos está desactivado, y determinar las limitaciones para identificar quién realizó la modificación.

## Entorno de trabajo

- Sistema operativo: Ubuntu 22.04.5 LTS.
- Motor de base de datos: MongoDB 7.0.48 Community Edition.
- MongoDB Shell: 2.14.2.
- Base de datos: `comercial`.
- Colección: `clientes`.
- Usuario administrador: `admin`.
- Usuario de aplicación: `app_ventas`.
- Aplicación identificada como: `app-ventas-web`.
- Fecha de realización: 16 de noviembre de 2026.

## Comandos ejecutados

### 1. Verificación del perfilador

Desde la sesión del administrador se ejecutó:

```javascript
use comercial
db.getProfilingStatus()
```

Resultado obtenido:

```javascript
{
  was: 0,
  slowms: 100,
  sampleRate: 1,
  ok: 1
}
```

El valor `was: 0` confirma que el perfilador estaba desactivado.

Esto significa que MongoDB no estaba registrando las operaciones de la base de datos mediante el Database Profiler.

### 2. Consulta de la bitácora

Se creó una función auxiliar para consultar los eventos recientes del servidor:

```javascript
function bitacora() {
  return db.adminCommand({ getLog: "global" }).log.map(l => JSON.parse(l))
}
```

Posteriormente se ejecutó:

```javascript
bitacora().length
```

Resultado:

```text
222
```

La consulta devolvió 222 eventos disponibles en la bitácora en memoria del servidor en ese momento.

### 3. Modificación del RFC

Se abrió una segunda sesión de MongoDB utilizando el usuario `app_ventas` y el nombre de aplicación `app-ventas-web`.

Desde esa sesión se ejecutó:

```javascript
db.clientes.updateOne(
  { _id: 3 },
  { $set: { rfc: "GAMA780912XXX" } }
)
```

Resultado obtenido:

```javascript
{
  acknowledged: true,
  insertedId: null,
  matchedCount: 1,
  modifiedCount: 1,
  upsertedCount: 0
}
```

El resultado confirmó que se encontró un documento y que la operación modificó un registro.

El documento corresponde a María García, cuyo identificador es `_id: 3`.

El nuevo valor establecido para su RFC fue `GAMA780912XXX`.

### 4. Búsqueda de evidencia en system.profile

Desde la sesión del administrador se ejecutó:

```javascript
db.system.profile.countDocuments()
```

Resultado:

```text
0
```

No se encontraron documentos en `system.profile`.

Esto concuerda con el resultado anterior, donde comprobamos que el perfilador se encontraba desactivado.

### 5. Búsqueda del RFC en la bitácora

Se ejecutó:

```javascript
bitacora().filter(e =>
  JSON.stringify(e).includes("GAMA780912XXX")
).length
```

Resultado:

```text
0
```

No se encontraron eventos que contuvieran el nuevo RFC entre los registros recientes consultados.

Por lo tanto, esta consulta no proporcionó evidencia de la modificación realizada.

### 6. Búsqueda de conexiones de la aplicación

Se ejecutó:

```javascript
bitacora().filter(e =>
  JSON.stringify(e).includes("app-ventas-web")
).map(e => ({
  t: e.t,
  c: e.c,
  ctx: e.ctx,
  msg: e.msg
}))
```

La consulta mostró eventos relacionados con conexiones de la aplicación.

Entre los resultados obtenidos se identificaron los siguientes:

| Conexión | Categoría | Mensaje |
|---|---|---|
| conn26 | NETWORK | client metadata |
| conn26 | ACCESS | Connection not authenticating |
| conn27 | NETWORK | client metadata |
| conn27 | ACCESS | Successfully authenticated |
| conn28 | NETWORK | client metadata |
| conn29 | NETWORK | client metadata |
| conn28 | ACCESS | Successfully authenticated |
| conn29 | ACCESS | Successfully authenticated |
| conn30 | NETWORK | client metadata |
| conn30 | ACCESS | Connection not authenticating |

Los eventos observados ocurrieron aproximadamente entre las 22:25:35 y las 22:25:45 del 16 de noviembre de 2026, según la marca de tiempo mostrada en la bitácora.

Estos registros permiten identificar conexiones de la aplicación y eventos relacionados con la autenticación.

Sin embargo, no contienen evidencia directa de la modificación del RFC.

## Preguntas de la actividad

### 1. ¿Puedes demostrar qué cambió? ¿Y quién se conectó a esa hora?

Durante la ejecución del laboratorio pude comprobar que el usuario `app_ventas` realizó una operación para modificar el RFC del documento con `_id: 3`, correspondiente a María García.

El comando `updateOne()` estableció el valor `GAMA780912XXX` y MongoDB confirmó la modificación mediante `modifiedCount: 1`.

Sin embargo, no es posible reconstruir esta modificación utilizando únicamente las evidencias recuperadas del perfilador y la bitácora.

La colección `system.profile` no contenía registros porque el perfilador estaba desactivado.

Además, la búsqueda del nuevo RFC en la bitácora devolvió cero coincidencias.

Por otro lado, los registros del servidor mostraron conexiones de `app-ventas-web` y autenticaciones exitosas durante el periodo investigado.

La sesión utilizada para ejecutar la modificación se conectó mediante las credenciales del usuario `app_ventas`. No obstante, la consulta resumida de la bitácora no incluyó el nombre del usuario autenticado.

Por lo tanto, los resultados permiten demostrar que hubo conexiones y autenticaciones, pero no proporcionan una evidencia independiente que relacione directamente una conexión con la modificación del RFC.

**No hay evidencia con esta edición y esta configuración que permita atribuir la modificación mediante una auditoría nativa de seguridad.**

### 2. ¿Por qué mongosh abre varias conexiones (conn8, conn9, …) para una sola instrucción? ¿Cuál es la que se autentica?

MongoDB Shell utiliza un controlador de conexión que puede establecer varias conexiones con el servidor.

Estas conexiones pueden utilizarse para realizar operaciones, supervisar el estado del servidor y administrar la comunicación con MongoDB.

Por este motivo, aunque se ejecute una sola instrucción, pueden aparecer diferentes identificadores de conexión en la bitácora.

En mi práctica se observaron las conexiones `conn26`, `conn27`, `conn28`, `conn29` y `conn30`.

Los registros mostraron que:

- `conn26` presentó el mensaje `Connection not authenticating`.
- `conn27` presentó el mensaje `Successfully authenticated`.
- `conn28` presentó el mensaje `Successfully authenticated`.
- `conn29` presentó el mensaje `Successfully authenticated`.
- `conn30` presentó el mensaje `Connection not authenticating`.

Esto demuestra que varias conexiones realizaron una autenticación exitosa.

El mensaje `Connection not authenticating` no significa necesariamente que haya ocurrido un intento fallido de autenticación, sino que esa conexión no realizó el proceso de autenticación.

Por lo tanto, no existe necesariamente una sola conexión que se autentique por cada instrucción ejecutada.

## Análisis de resultados

La actividad permitió observar una diferencia importante entre registrar conexiones y registrar operaciones sobre los datos.

La bitácora del servidor proporcionó información sobre eventos de red y autenticación, pero no permitió identificar directamente el cambio realizado sobre el RFC.

Por otra parte, al encontrarse desactivado el perfilador, no existían registros de la operación en `system.profile`.

Esto representa una limitación para investigar incidentes, ya que conocer que una aplicación se conectó no demuestra por sí mismo qué documentos consultó o modificó.

## Conclusión

En esta actividad comprobé que MongoDB Community Edition puede registrar conexiones y eventos de autenticación mediante la bitácora del servidor.

Sin embargo, cuando el perfilador está desactivado, no se obtiene evidencia de las operaciones de la base de datos mediante `system.profile`.

Aunque durante la práctica pude observar que el usuario `app_ventas` modificó el RFC de María García, los registros consultados no permitieron reconstruir ni atribuir de manera independiente esa modificación.

Por lo tanto, comprendí la importancia de configurar mecanismos de trazabilidad antes de que ocurra un incidente y de reconocer que la bitácora del servidor no sustituye a una auditoría nativa de seguridad.
