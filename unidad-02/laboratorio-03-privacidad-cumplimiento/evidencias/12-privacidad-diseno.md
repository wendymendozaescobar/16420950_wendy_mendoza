# Actividad 12. Privacidad por diseño

## Objetivo

Analizar una propuesta de diseño de base de datos e identificar cómo aplicar los principios de minimización, finalidad, privacidad por diseño y privacidad por defecto desde el desarrollo de una aplicación.

## Procedimiento

Se revisó la propuesta de un desarrollador que desea crear una tabla `clientes` con numerosos campos personales, argumentando que podrían utilizarse en el futuro.

Se evaluó la necesidad de los datos propuestos, los riesgos de recopilarlos sin una finalidad definida y las medidas que permitirían proteger la privacidad desde el diseño.

No se ejecutó la instrucción `CREATE TABLE`, debido a que el ejercicio solicita realizar un análisis conceptual.

## Resultado obtenido

### 1. ¿Qué problemas identificas?

El problema principal es que el desarrollador propone recopilar información sin justificar previamente su necesidad.

Se identificaron los siguientes riesgos:

1. **Recopilación excesiva:** se pretende almacenar información que podría no ser necesaria para registrar clientes.
2. **Finalidades indefinidas:** no se explica para qué se utilizará cada campo.
3. **Mayor exposición:** almacenar más datos personales puede aumentar el impacto de una filtración.
4. **Falta de controles de acceso:** el diseño no especifica quién podrá consultar cada dato.
5. **Ausencia de una política de retención:** no se indica cuánto tiempo se conservará la información.
6. **Duplicidad de información:** almacenar edad y fecha de nacimiento podría resultar innecesario si ambas cumplen la misma finalidad.
7. **Falta de restricciones:** la propuesta no establece una clave primaria ni las restricciones necesarias para asegurar la calidad e integridad de los registros.

Aunque el último punto corresponde principalmente al diseño técnico de la base de datos, también puede afectar la capacidad de administrar correctamente los datos personales.

### 2. ¿Qué principio de privacidad se está ignorando?

Principalmente, el principio de minimización de datos.

Este principio busca que la organización recopile únicamente información adecuada, relevante y necesaria para cumplir finalidades determinadas.

También se están descuidando los principios de limitación de finalidad y privacidad por diseño.

La posibilidad de necesitar información en el futuro no justifica automáticamente su recopilación.

### 3. ¿Qué preguntas realizarías antes de aprobar el diseño?

Antes de aprobar la tabla preguntaría:

1. ¿Cuál es la finalidad específica de la aplicación?
2. ¿Para qué se necesita cada campo propuesto?
3. ¿Qué datos son indispensables para registrar a un cliente?
4. ¿Existe una justificación para recopilar información financiera o personal adicional?
5. ¿Qué áreas o usuarios tendrán acceso a cada dato?
6. ¿Qué fundamento permite realizar el tratamiento?
7. ¿Cuánto tiempo deberá conservarse la información?
8. ¿Cómo se atenderán las solicitudes de derechos ARCO?
9. ¿Qué medidas protegerán los datos almacenados y transmitidos?
10. ¿Es posible cumplir la finalidad con menos campos o utilizando información menos detallada?

Estas preguntas permitirían identificar requisitos antes de construir la base de datos.

### 4. ¿Qué datos eliminarías?

Si la aplicación únicamente necesita registrar clientes y proporcionarles atención básica, propondría eliminar del diseño inicial los siguientes campos:

- `edad`
- `fecha_nacimiento`
- `ocupacion`
- `salario`
- `estado_civil`

También evaluaría eliminar `direccion`, `ciudad`, `codigo_postal` y `rfc` si no existe una finalidad operativa, fiscal o contractual que justifique recopilarlos.

No se trata de que estos datos nunca puedan utilizarse, sino de que su necesidad debe comprobarse antes de incorporarlos.

Como estructura inicial, podrían mantenerse `id`, `nombre`, `correo` y, si resulta necesario, `telefono`.

Esta selección es una propuesta para el escenario de atención básica, no una estructura obligatoria para cualquier aplicación de clientes.

### 5. ¿Qué datos requerirían una justificación adicional?

Los siguientes campos merecen una revisión especial:

| Campo | Justificación que debería comprobarse |
|---|---|
| `rfc` | Necesidad de identificación fiscal o facturación. |
| `direccion` | Necesidad de entregas, servicios presenciales u otra finalidad específica. |
| `edad` | Necesidad de validar requisitos por edad o realizar análisis justificados. |
| `fecha_nacimiento` | Necesidad de conocer la fecha exacta, en lugar de utilizar una categoría menos detallada. |
| `ocupacion` | Relación con algún proceso específico de la aplicación. |
| `salario` | Existencia de una finalidad financiera justificada y controles reforzados por el riesgo asociado. |
| `estado_civil` | Necesidad concreta relacionada con el servicio ofrecido. |
| `ciudad` y `codigo_postal` | Necesidad operativa o de análisis geográfico justificada. |

La organización debe evitar recopilar información únicamente porque podría resultar útil posteriormente.

### 6. ¿Cómo aplicarías privacidad por defecto?

Implementaría las siguientes medidas:

1. **Recopilación mínima:** los formularios solicitarían solamente los datos indispensables.
2. **Acceso restringido:** los usuarios recibirían únicamente los permisos necesarios para sus funciones.
3. **Vistas limitadas:** cada departamento consultaría las columnas correspondientes a su finalidad.
4. **Separación de información:** los datos utilizados para operaciones, facturación y analítica se presentarían de manera diferenciada.
5. **Protección de información:** se utilizarían mecanismos apropiados de cifrado, control de acceso y protección de comunicaciones.
6. **Retención definida:** los datos tendrían criterios de conservación y eliminación documentados.
7. **Configuración inicial protectora:** los usos secundarios, como las campañas promocionales, no se habilitarían automáticamente sin comprobar las condiciones aplicables.
8. **Trazabilidad:** se implementarían mecanismos para registrar operaciones relevantes sobre los datos personales.

Estas medidas permitirían que la aplicación ofreciera inicialmente una protección adecuada, sin depender de que el usuario configure manualmente todos los controles.

## Análisis

La propuesta del desarrollador demuestra que un diseño técnicamente posible no necesariamente es adecuado desde el punto de vista de la privacidad.

PostgreSQL permite crear tablas con numerosos campos, pero corresponde a la organización determinar cuáles son realmente necesarios.

La privacidad debe considerarse antes de definir las columnas, los permisos y las políticas de conservación.

Además, los campos deben relacionarse con finalidades documentadas y responsabilidades organizacionales.

El DBA puede contribuir proponiendo estructuras mínimas, restricciones, roles y vistas, pero las decisiones sobre las finalidades y las condiciones legales del tratamiento deben involucrar a las áreas correspondientes.

## Conclusión

Se comprendió que la privacidad por diseño implica incorporar la protección de datos desde las primeras etapas de desarrollo de una aplicación.

También se identificó que recopilar información sin una finalidad definida puede aumentar los riesgos de exposición y dificultar su administración.

La privacidad por defecto permite que el sistema comience con configuraciones que reduzcan el tratamiento y acceso a datos innecesarios.

Como DBA, es importante participar en las decisiones técnicas del diseño para implementar los controles autorizados y evitar estructuras que recopilen información sin justificación.
