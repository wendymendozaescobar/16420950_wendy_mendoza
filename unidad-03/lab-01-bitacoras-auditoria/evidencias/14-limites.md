# Actividad 15 — Límites: lecturas y volumen

## Objetivo

Identificar las limitaciones de los mecanismos de auditoría implementados en PostgreSQL, especialmente en relación con las consultas de lectura de información sensible y las modificaciones masivas de registros.

También se busca comparar el comportamiento de la bitácora del servidor y la auditoría mediante disparadores.

## Entorno de trabajo

- Sistema operativo: Ubuntu.
- PostgreSQL: 18.6.
- Puerto: `5433`.
- Base de datos: `comercial`.
- Usuarios: `postgres` y `soporte_ana`.
- Tabla principal: `public.clientes`.
- Tabla de auditoría: `auditoria.cambios_clientes`.
- Disparador: `trg_auditoria_clientes`.
- Configuración de sentencias: `log_statement = 'mod'`.

## 1. Lectura de información sensible

Se realizó una consulta utilizando el usuario `soporte_ana` para acceder al nombre, RFC y teléfono de María García.

La consulta utilizada fue:

```sql
SELECT nombre, rfc, telefono
FROM clientes
WHERE id = 3;
```

El objetivo fue comprobar si una lectura autorizada de información sensible generaba un registro de auditoría.

El disparador implementado anteriormente solamente responde a las operaciones `INSERT`, `UPDATE` y `DELETE`.

Por lo tanto, no registra directamente las operaciones `SELECT`.

Además, la configuración `log_statement = 'mod'` no registra de manera general las consultas de lectura exitosas.

## 2. Verificación del estado inicial

Antes de ejecutar la actualización masiva, se verificó la cantidad de clientes:

```sql
SELECT COUNT(*) AS total_clientes
FROM clientes;
```

Resultado: **5 clientes**.

Posteriormente, se comprobó la cantidad de eventos de auditoría:

```sql
SELECT COUNT(*) AS eventos_antes
FROM auditoria.cambios_clientes;
```

Resultado: **3 eventos**.

También se verificó el estado del disparador:

```sql
SELECT tgname, tgenabled
FROM pg_trigger
WHERE tgname = 'trg_auditoria_clientes';
```

Resultado:

| Disparador | Estado |
|---|---|
| trg_auditoria_clientes | O |

El estado `O` confirmó que el disparador se encontraba habilitado.

## 3. Ejecución de una actualización masiva

Se ejecutó:

```sql
UPDATE clientes
SET segmento = 'regular';
```

PostgreSQL respondió:

```text
UPDATE 5
```

Esto confirmó que la sentencia afectó cinco registros.

Como la instrucción no contenía una cláusula `WHERE`, PostgreSQL procesó todas las filas de la tabla.

El disparador estaba configurado con `FOR EACH ROW`, por lo que generó un evento de auditoría por cada fila actualizada.

## 4. Comprobación de la bitácora

Inicialmente se utilizó:

```sql
SELECT COUNT(*) AS lineas_bitacora
FROM dba.bitacora
WHERE linea LIKE '%UPDATE clientes SET segmento%';
```

Resultado:

```text
lineas_bitacora
---------------
0
```

Posteriormente se investigó el resultado mediante una búsqueda más flexible:

```sql
SELECT
    num,
    LEFT(linea, 250) AS evento
FROM dba.bitacora
WHERE linea ILIKE '%UPDATE clientes%'
   OR linea ILIKE '%SET segmento%'
ORDER BY num DESC
LIMIT 15;
```

Se identificaron los siguientes registros relevantes:

| Registro | Descripción |
|---|---|
| 137 | Actualización anterior realizada por app_ventas. |
| 188 | Actualización anterior realizada por postgres. |
| 202 | Inicio de la sentencia UPDATE masiva. |
| 203 | Continuación de la sentencia: SET segmento = 'regular'. |

La actualización masiva quedó registrada en la bitácora del servidor.

La búsqueda inicial devolvió cero debido a que la sentencia SQL estaba distribuida en varias líneas.

Una búsqueda adicional encontró tres sentencias `UPDATE clientes` en el historial, correspondientes a modificaciones realizadas en diferentes momentos.

La actualización masiva de esta actividad corresponde al registro 202, cuya continuación aparece en el registro 203.

## 5. Comprobación de los eventos de auditoría

Se ejecutó:

```sql
SELECT
    operacion,
    COUNT(*)
FROM auditoria.cambios_clientes
GROUP BY operacion
ORDER BY operacion;
```

Se obtuvo:

| Operación | Cantidad |
|---|---:|
| DELETE | 1 |
| INSERT | 1 |
| UPDATE | 6 |

Total: **8 eventos**.

Antes de la prueba existía un evento `UPDATE`.

Después de ejecutar la actualización masiva, se generaron cinco eventos adicionales.

Por lo tanto:

1 evento UPDATE anterior + 5 eventos UPDATE nuevos = 6 eventos UPDATE.

Esto demuestra que una sola sentencia SQL puede producir múltiples registros en una auditoría configurada por fila.

## 6. Verificación de las lecturas

Se ejecutó:

```sql
SELECT
    COUNT(*) AS lecturas_soporte
FROM dba.bitacora
WHERE linea LIKE '%user=soporte_ana%'
  AND linea ILIKE '%SELECT nombre, rfc%';
```

El resultado fue:

```text
lecturas_soporte
----------------
0
```

No se encontraron registros de la sentencia de lectura en la bitácora consultada.

Esto es coherente con la configuración `log_statement = 'mod'`, que no registra de manera general las consultas `SELECT` exitosas.

Sin embargo, las conexiones y desconexiones pueden quedar registradas mediante otros parámetros de PostgreSQL.

Por lo tanto, la ausencia de una sentencia SELECT en la bitácora no implica necesariamente la ausencia de toda evidencia de conexión.

## 7. Alternativas para auditar lecturas

| Alternativa | Ventaja | Desventaja |
|---|---|---|
| `log_statement = 'all'` | Permite registrar todas las sentencias SQL sin instalar extensiones. | Puede generar grandes cantidades de información y exponer datos sensibles contenidos en las sentencias. |
| Función que registre el acceso | Permite controlar específicamente las lecturas auditadas. | Requiere modificar la forma en que las aplicaciones consultan los datos. |
| pgAudit con auditoría de objeto | Permite realizar auditoría más específica sobre determinados objetos. | Requiere instalar y configurar una extensión adicional. |

Estas alternativas permiten fortalecer la trazabilidad de las consultas de lectura, aunque cada una presenta limitaciones y costos diferentes.

## Preguntas de análisis

### 1. Si clientes tuviera un millón de registros, ¿qué ocurriría con la auditoría tras un UPDATE sin WHERE?

Como nuestro disparador utiliza `FOR EACH ROW`, PostgreSQL ejecutaría la función de auditoría una vez por cada fila actualizada.

Si la tabla tuviera un millón de registros y la sentencia afectara a todos, se intentarían generar un millón de eventos de auditoría.

Esto provocaría un crecimiento considerable de la tabla `auditoria.cambios_clientes`, ya que cada evento almacena información sobre los valores anteriores y posteriores en formato JSONB.

También aumentaría el consumo de almacenamiento, la generación de WAL y el trabajo necesario para completar la transacción.

Como consecuencia, podrían incrementarse los tiempos de ejecución y la presión sobre los recursos del servidor.

La actividad demuestra la importancia de controlar las modificaciones masivas y planificar la capacidad del sistema de auditoría.

### 2. Propón quién podría autorizar la depuración de auditoria.cambios_clientes.

La depuración debería ser autorizada por los responsables de la información y del cumplimiento de las políticas de conservación de datos, en coordinación con las áreas de seguridad y auditoría.

El administrador de bases de datos no debería decidir de manera independiente qué evidencias históricas pueden eliminarse.

Un procedimiento adecuado debe considerar los periodos de retención, los requisitos legales aplicables, la necesidad de conservar evidencia y las investigaciones que puedan encontrarse pendientes.

Una vez autorizada la depuración, el DBA podría ejecutar el procedimiento técnico correspondiente.

También sería importante documentar quién autorizó la eliminación, qué registros fueron afectados y cuándo se realizó.

Esto permite aplicar el principio de separación de funciones y reducir el riesgo de eliminación indebida de evidencias.

### 3. ¿Por qué log_statement = 'all' puede convertir la bitácora en un nuevo depósito de datos sensibles?

Porque esta configuración registra todas las sentencias SQL procesadas por PostgreSQL.

Las consultas pueden contener información sensible escrita directamente en sus condiciones o valores.

Por ejemplo, una sentencia `UPDATE` puede incluir un RFC o un número telefónico dentro del código SQL.

Si estas sentencias se almacenan en la bitácora, parte de la información personal también quedará conservada en los archivos de registro.

Esto puede generar duplicación de datos sensibles fuera de las tablas principales y aumentar el riesgo de exposición.

Por ello, las bitácoras deben protegerse mediante permisos restringidos, políticas de retención y controles de acceso.

Es importante considerar que registrar una sentencia SELECT no equivale necesariamente a registrar todos los valores que devuelve la consulta.

## Análisis

La actividad permitió comprobar que los mecanismos de auditoría presentan diferentes alcances.

La bitácora del servidor registró la sentencia de actualización masiva, mientras que el disparador produjo cinco eventos adicionales, uno por cada registro afectado.

También se identificó que las consultas de lectura no se registran de forma general mediante `log_statement = 'mod'`.

Esto representa una limitación cuando se necesita investigar quién consultó información sensible.

Se analizaron alternativas para auditar lecturas y los riesgos relacionados con el volumen de registros y la conservación de datos personales.

## Conclusión

Se ejecutó correctamente una actualización masiva sobre cinco clientes.

La operación produjo cinco nuevos eventos de auditoría, mientras que la bitácora del servidor conservó la sentencia SQL correspondiente.

También se comprobó que no se encontraron registros de la consulta SELECT realizada por el usuario de soporte.

La práctica permitió comprender que una auditoría basada en disparadores ofrece información detallada sobre modificaciones, pero no registra directamente las lecturas.

Finalmente, se identificaron los riesgos de crecimiento del historial y la necesidad de proteger adecuadamente los registros de auditoría.
