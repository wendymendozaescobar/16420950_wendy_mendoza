# Actividad 1. Inventario y finalidad de los datos

## Objetivo

Identificar los datos personales almacenados en la tabla `public.clientes`, analizar su finalidad y determinar qué información necesita cada área de la organización.

## Procedimiento

Se revisó la estructura de la tabla `public.clientes` mediante PostgreSQL y se identificaron nueve campos.

Posteriormente, se analizaron las necesidades de las áreas de atención al cliente, facturación y analítica descritas en el escenario del laboratorio.

Para cada campo se evaluó su carácter personal, finalidad, necesidad, nivel de acceso y retención.

## Resultado obtenido

### Matriz de inventario de datos

| Campo | ¿Es dato personal? | Finalidad | ¿Es necesario? | Nivel de acceso | Retención |
|---|---|---|---|---|---|
| `id` | Sí, como identificador asociado al cliente | Identificar registros y relacionar operaciones | Sí | Áreas autorizadas que necesiten identificar registros | Mientras exista una finalidad operativa o una obligación de conservación |
| `nombre` | Sí | Identificación y atención del cliente | Sí | Atención al cliente y facturación | Según la relación con el cliente y obligaciones aplicables |
| `correo` | Sí | Comunicación y atención | Sí, cuando se utiliza este medio de contacto | Atención al cliente | Mientras sea necesario para la comunicación y otras finalidades autorizadas |
| `telefono` | Sí | Contacto y seguimiento | Condicional, dependiendo del medio de contacto requerido | Atención al cliente | Mientras sea necesario para la finalidad autorizada |
| `rfc` | Sí | Identificación fiscal y facturación | Sí, cuando se requiere para obligaciones fiscales | Facturación | Según las obligaciones fiscales y la política de conservación aplicable |
| `edad` | Sí, cuando está asociada al cliente | Estadísticas por rangos de edad | Condicional; no es necesaria para atención al cliente | Analítica, preferentemente mediante información agregada | Mientras exista una finalidad estadística justificada; preferir datos agregados |
| `ciudad` | Sí, cuando está asociada al cliente | Estadísticas geográficas y posibles necesidades operativas | Condicional | Analítica mediante información agregada y áreas operativas justificadas | Según la finalidad documentada |
| `codigo_postal` | Sí, cuando está asociado al cliente | Análisis regional y necesidades operativas justificadas | Condicional | Áreas autorizadas; analítica mediante regiones o agregados | Según la finalidad documentada |
| `fecha_alta` | Sí, al relacionarse con un cliente identificable | Seguimiento de antigüedad y ciclo de vida del registro | Sí, cuando se utiliza para administración y retención | Administración autorizada | Según la política de retención y las obligaciones aplicables |

### Justificación de las decisiones

**1. ID**

Aunque el identificador no contiene el nombre, permite relacionar información con una persona específica dentro de la base de datos. Por eso debe considerarse información personal cuando puede vincularse con el titular.

Es necesario para identificar registros y mantener relaciones entre tablas.

**2. Nombre**

Permite identificar y atender correctamente al cliente.

El área de atención necesita conocerlo para prestar su servicio. Sin embargo, el área de analítica no necesita recibir nombres individuales para elaborar estadísticas.

**3. Correo electrónico**

Es un dato de contacto que puede identificar directamente a una persona.

Su almacenamiento se justifica cuando la organización lo utiliza para comunicarse con el cliente. No debe emplearse automáticamente para finalidades diferentes, como campañas publicitarias.

**4. Teléfono**

Permite establecer contacto con el cliente, pero su necesidad depende del procedimiento de atención.

Si la organización puede cumplir la finalidad sin recopilarlo, debería evaluar si realmente necesita almacenarlo.

**5. RFC**

Es información de identificación fiscal.

Su tratamiento se justifica cuando la organización necesita cumplir actividades de facturación u obligaciones fiscales.

No es necesario que todos los departamentos puedan consultarlo.

**6. Edad**

Cuando está relacionada con un cliente identificable, constituye información personal.

Puede utilizarse para estadísticas, pero no necesariamente se requiere conocer la edad exacta de cada persona.

Para analítica, sería preferible utilizar rangos de edad y resultados agregados.

**7. Ciudad**

Puede ser útil para estadísticas geográficas y algunas necesidades operativas.

Sin embargo, no todos los departamentos necesitan conocerla. Su utilización debe relacionarse con una finalidad documentada.

**8. Código postal**

Puede utilizarse para identificar regiones o cumplir determinadas necesidades operativas.

Cuando se encuentra asociado con otros datos del cliente, también forma parte de su información personal.

Para estadísticas regionales, podría utilizarse una agrupación geográfica en lugar del código postal individual.

**9. Fecha de alta**

Permite conocer cuándo comenzó la relación con el cliente y apoyar la administración del ciclo de vida de sus datos.

Puede ayudar a determinar cuándo corresponde revisar la conservación o eliminación de información.

Su retención debe vincularse con una política documentada y no mantenerse indefinidamente sin justificación.

## Análisis

La tabla `public.clientes` contiene información utilizada para diferentes finalidades.

Sin embargo, esto no significa que todos los departamentos necesiten acceder a todos los campos.

Atención al cliente requiere principalmente información de identificación y contacto.

Facturación necesita los datos fiscales correspondientes.

Analítica puede trabajar con información agregada para generar estadísticas sin identificar directamente a cada cliente.

Los periodos de retención deben definirse considerando la finalidad del tratamiento, las necesidades operativas y las obligaciones legales aplicables. El escenario no proporciona información suficiente para establecer plazos específicos.

## Conclusión

Se identificaron los nueve campos de la tabla `public.clientes` y se analizaron sus finalidades.

La actividad permitió comprender que almacenar información no significa que todos los usuarios deban consultarla ni que todos los datos deban conservarse indefinidamente.

Como administrador de bases de datos, es importante implementar controles técnicos que respeten las finalidades y responsabilidades definidas por la organización.
