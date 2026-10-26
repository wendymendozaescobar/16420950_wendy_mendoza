# Actividad 14. Evaluación integral de privacidad

## Objetivo

Identificar riesgos de privacidad y gobierno de datos en una organización, relacionarlos con los principios afectados y proponer controles técnicos y administrativos que permitan reducirlos.

## Procedimiento

Se analizó el escenario de una empresa que almacena información de 50,000 clientes y presenta diferentes situaciones relacionadas con el acceso, utilización, conservación y protección de datos personales.

Se identificaron doce problemas o riesgos y se elaboró una matriz que relaciona cada situación con el principio de privacidad afectado, sus posibles consecuencias y los controles propuestos.

## Resultado obtenido

### Matriz de evaluación integral de privacidad

| Problema | Principio afectado | Riesgo | Control propuesto |
|---|---|---|---|
| 1. Todos los analistas pueden consultar directamente la tabla `clientes`. | Mínimo privilegio y limitación de finalidad. | Acceso a información personal que no necesitan para sus funciones. | Restringir el acceso directo y otorgar permisos sobre vistas autorizadas. |
| 2. Analítica puede consultar nombres, correos y teléfonos individuales. | Minimización de datos. | Exposición innecesaria de identificadores personales. | Proporcionar estadísticas agregadas sin identificadores directos. |
| 3. Analítica puede consultar el RFC de los clientes. | Confidencialidad y necesidad del tratamiento. | Divulgación de información de identificación fiscal sin justificación funcional. | Reservar el RFC para los procesos y usuarios autorizados de facturación. |
| 4. No se limita la información entregada a la finalidad estadística mensual. | Limitación de finalidad. | Utilización de datos más detallados de lo necesario. | Diseñar consultas y vistas que entreguen únicamente estadísticas mensuales. |
| 5. Se conservan datos desde hace 12 años sin una justificación de retención documentada. | Limitación de conservación y minimización. | Conservación de información que podría haber dejado de ser necesaria. | Evaluar las finalidades y obligaciones aplicables antes de establecer periodos de retención. |
| 6. No existe una política documentada de retención. | Gobierno de datos y conservación. | Falta de criterios para decidir cuándo conservar, revisar o eliminar información. | Establecer una política con plazos, responsables, justificaciones y procedimientos de disposición. |
| 7. Los desarrolladores reciben copias completas de la base de datos. | Minimización y mínimo privilegio. | Acceso a información productiva que podría no ser necesaria para realizar pruebas. | Proporcionar bases de prueba con datos sintéticos o conjuntos limitados. |
| 8. Las copias utilizadas en desarrollo contienen datos personales reales. | Confidencialidad y privacidad por diseño. | Exposición de información personal en ambientes distintos de producción. | Evitar datos reales cuando sea posible y aplicar controles de seguridad a cualquier copia autorizada. |
| 9. No se describen controles específicos para las copias de desarrollo. | Seguridad de los datos y responsabilidad. | Posibles accesos no autorizados o conservación innecesaria de copias. | Verificar permisos, almacenamiento, cifrado, auditoría y eliminación de copias. |
| 10. Marketing utiliza correos electrónicos para campañas sin que se explique la justificación del tratamiento. | Limitación de finalidad. | Uso de datos para una finalidad cuya autorización o fundamento no está acreditado en el escenario. | Revisar la finalidad informada, la base jurídica aplicable y las condiciones para realizar campañas. |
| 11. No existe documentación clara sobre la finalidad de cada dato. | Finalidad y gobierno de datos. | Dificultad para justificar la recopilación, utilización y conservación de la información. | Crear un catálogo que relacione datos, finalidades, responsables y usuarios autorizados. |
| 12. No se evidencia una separación adecuada de la información según las funciones de cada área. | Privacidad por diseño y mínimo privilegio. | Acceso o utilización de datos para funciones diferentes de aquellas que justifican su tratamiento. | Separar el acceso operativo, analítico y de marketing mediante roles, vistas y políticas por finalidad. |

### Clasificación de los controles propuestos

Los controles identificados pueden organizarse en dos categorías.

**Controles técnicos:**

- Roles y permisos específicos en PostgreSQL.
- Vistas con información limitada.
- Consultas que produzcan estadísticas agregadas.
- Separación de ambientes de producción y desarrollo.
- Uso de datos sintéticos para pruebas.
- Cifrado y protección de copias autorizadas.
- Mecanismos de auditoría y control de acceso.

**Controles administrativos:**

- Política documentada de retención.
- Catálogo de datos y finalidades.
- Designación de responsables.
- Procedimientos para autorizar accesos.
- Evaluación de tratamientos secundarios.
- Reglas para utilizar datos personales en ambientes de prueba.
- Revisiones periódicas del cumplimiento de las políticas.

Los controles técnicos permiten implementar restricciones en los sistemas, mientras que los administrativos establecen las reglas y responsabilidades que justifican su aplicación.

## Análisis

La organización presenta problemas relacionados con el acceso excesivo a los datos, la conservación de información, el uso de copias de producción y la falta de documentación sobre las finalidades.

Uno de los riesgos más importantes es que todos los empleados del área de analítica pueden consultar directamente la tabla de clientes, aunque únicamente necesitan generar estadísticas mensuales.

Esto demuestra que no se está limitando adecuadamente la información entregada a las funciones del departamento.

La organización podría utilizar vistas y consultas de agrupación para proporcionar resultados estadísticos sin entregar los identificadores originales.

Otro problema relevante es el uso de información real en los ambientes de desarrollo.

Aunque los desarrolladores necesitan datos para probar aplicaciones, no siempre requieren utilizar información personal auténtica.

Las bases de prueba con información sintética pueden reducir la exposición de datos de producción.

En cuanto a la conservación, el hecho de mantener registros durante doce años no demuestra por sí solo un incumplimiento. Sin embargo, la ausencia de una política documentada impide justificar adecuadamente por qué deben mantenerse durante ese tiempo.

También es necesario analizar el uso de correos electrónicos para campañas de marketing. El escenario no proporciona información suficiente para determinar si el tratamiento está autorizado, por lo que la organización debe revisar las condiciones aplicables antes de continuarlo.

La cantidad de clientes incrementa el posible impacto de un incidente, debido al volumen de información que podría verse afectada.

Finalmente, la falta de documentación sobre las finalidades dificulta determinar quién debe acceder a cada dato y durante cuánto tiempo debe conservarse.

## Conclusión

La evaluación permitió identificar doce problemas o riesgos relacionados con la privacidad y el gobierno de datos.

Se comprendió que una organización puede almacenar información necesaria para sus operaciones y, al mismo tiempo, generar riesgos cuando permite accesos excesivos o no establece reglas claras sobre su utilización y conservación.

Los controles técnicos, como vistas, roles, permisos y protección de ambientes, deben complementarse con políticas y responsabilidades organizacionales.

Como DBA, es importante identificar estos riesgos y proponer mecanismos técnicos, pero las decisiones sobre finalidades, bases jurídicas y periodos de conservación deben involucrar a las áreas competentes.

