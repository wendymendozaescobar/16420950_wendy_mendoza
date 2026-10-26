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
