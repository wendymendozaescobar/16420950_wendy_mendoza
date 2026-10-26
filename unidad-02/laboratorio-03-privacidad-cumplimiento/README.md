# LAB-03. Privacidad, cumplimiento y gobierno de los datos

## 1. Introducción

Este laboratorio aborda la importancia de administrar los datos personales conforme a finalidades definidas y necesidades justificadas.

Se utilizará PostgreSQL para analizar aspectos relacionados con privacidad, minimización, controles de acceso, derechos ARCO, retención y gobierno de datos.

El escenario corresponde a una empresa ficticia que administra información de clientes.

## 2. Inventario y finalidad de los datos

Se identificaron nueve campos de la tabla `public.clientes` y se analizaron sus finalidades, necesidades, niveles de acceso y criterios de retención.

Se determinó que no todas las áreas necesitan consultar todos los datos.

El área de atención al cliente requiere principalmente información de identificación y contacto, mientras que facturación necesita información fiscal y analítica puede trabajar con resultados agregados.

### Evidencia

- [Inventario y finalidad de los datos](evidencias/01-inventario-datos.md)

## 3. Principio de minimización de datos

### Objetivo

Aplicar el principio de minimización mediante una tabla que contenga únicamente la información necesaria para el departamento de atención al cliente.

### Procedimiento

Se creó el esquema `lab03` para mantener separados los objetos de este laboratorio.

Posteriormente, se creó la tabla `lab03.clientes_soporte`, que contiene únicamente las columnas `id`, `nombre`, `correo` y `telefono`.

Los registros se obtuvieron desde `public.clientes`, seleccionando solamente las columnas necesarias.

### Preguntas de análisis

**1. ¿Todos los campos son necesarios para atención al cliente?**

No. El escenario indica que atención al cliente necesita información para identificar y contactar a los clientes, por lo que no requiere automáticamente todos los campos de la tabla original.

**2. ¿Por qué soporte necesitaría conocer el RFC?**

En el escenario presentado no se identifica una necesidad que justifique que soporte consulte el RFC. Este dato corresponde principalmente a actividades fiscales, por lo que su acceso debería limitarse al personal autorizado de facturación.

**3. ¿Necesita conocer la edad?**

No para las funciones de atención descritas en el ejercicio. La edad podría utilizarse en otros procesos justificados, pero eso no significa que soporte deba consultarla.

**4. ¿Necesita conocer el código postal?**

No para la finalidad de soporte planteada. Si existiera un procedimiento que requiriera información geográfica, sería necesario justificarlo antes de otorgar acceso.

**5. ¿Qué principio de privacidad está relacionado con esta decisión?**

El principio de minimización de datos, que busca limitar la información tratada a aquella adecuada, relevante y necesaria para una finalidad específica.

### Resultados

Se creó una tabla de soporte con cuatro columnas, en lugar de las nueve disponibles en la tabla original.
Tuve 5 registros.
Los datos fueron seleccionados desde `public.clientes` y se comprobó su estructura mediante consultas SQL.

### Análisis

La tabla original contiene información para distintas finalidades, pero atención al cliente no necesita acceder a todos esos datos.

Separar únicamente la información necesaria permite reducir la exposición de datos personales.

En un sistema productivo también sería conveniente evaluar el uso de vistas y permisos para evitar copias innecesarias de información.

### Conclusión

La actividad permitió aplicar el principio de minimización de datos mediante una estructura que contiene solamente la información necesaria para una finalidad específica.

También permitió comprender que el diseño de tablas y los permisos de acceso deben relacionarse con las funciones de cada departamento.

### Archivo SQL

- [Minimización de datos](sql/01-minimizacion.sql)

## 4. Separación por finalidad

### Objetivo

Generar información estadística para el departamento de analítica sin proporcionar directamente los datos personales que identifican a los clientes.

### Procedimiento

Se realizaron consultas SQL sobre la tabla `public.clientes`, utilizando funciones de agrupación y conteo.

Primero se agruparon los clientes por ciudad mediante `COUNT()` y `GROUP BY`.

Posteriormente, se utilizó `CASE` para clasificar a los clientes por rangos de edad.

Como complemento, se agruparon los códigos postales utilizando sus dos primeros caracteres.

### Resultados

Las consultas permitieron obtener estadísticas agrupadas sin incluir nombres, correos electrónicos, teléfonos ni RFC en los resultados.

Se utilizaron las siguientes herramientas de SQL:

- `COUNT()` para contar registros.
- `GROUP BY` para agrupar información.
- `ORDER BY` para ordenar resultados.
- `CASE` para crear categorías de edad.
- `LEFT()` para obtener prefijos postales.

Los resultados corresponden a grupos de clientes y no a registros individuales completos.

### Pregunta de análisis

**¿Por qué esta información puede ser más apropiada para analítica que entregar directamente la tabla completa de clientes?**

Porque el departamento de analítica necesita generar estadísticas y no identificar individualmente a cada cliente.

Las consultas agrupadas permiten conocer la distribución de los clientes por ciudad, edad y prefijo postal sin proporcionar directamente sus nombres, correos, teléfonos ni RFC.

Esto contribuye a reducir la exposición de datos personales y aplica los principios de minimización y limitación de finalidad.

Sin embargo, los resultados agregados también deben evaluarse, porque los grupos con muy pocos registros podrían facilitar la identificación de personas al combinarse con otra información.

### Análisis

La separación por finalidad permite proporcionar información diferente a cada departamento, dependiendo de sus funciones.

Atención al cliente necesita información para contactar personas, mientras que analítica requiere principalmente datos estadísticos.

Esto demuestra que no es necesario entregar acceso directo a toda la tabla para obtener resultados útiles.

### Conclusión

Se comprobó que las consultas de agrupación permiten generar información útil para analítica y disminuir la exposición de datos personales.

En un entorno productivo sería recomendable implementar vistas y controles de acceso que permitan consultar únicamente la información necesaria.

### Archivo SQL

- [Consultas de separación por finalidad](sql/02-finalidad.sql)
