# Actividad 5. Análisis de una finalidad secundaria

## Objetivo

Analizar los riesgos de utilizar datos personales para una finalidad diferente de aquella para la que fueron recopilados, identificando los controles necesarios para proteger la privacidad de los clientes.

## Procedimiento

Se analizó el escenario de una empresa que desea utilizar la información de sus clientes para enviar promociones personalizadas basadas en edad, ciudad y comportamiento de compra.

Se revisaron los principios de finalidad, minimización de datos y control de acceso para determinar qué información podría utilizar el departamento de marketing y bajo qué condiciones.

## Resultado obtenido

### 1. ¿El hecho de que la organización ya tenga los datos significa automáticamente que puede utilizarlos para cualquier finalidad?

No. Que una organización almacene información personal no significa que esté autorizada para utilizarla con cualquier propósito.

Los datos deben tratarse conforme a las finalidades informadas al titular y a las condiciones legales aplicables.

Antes de utilizar la información para enviar promociones personalizadas, la empresa debe comprobar si esa finalidad fue informada, si es compatible con la finalidad original y si existe una base jurídica válida para realizar el tratamiento.

### 2. ¿Qué preguntas debería realizar la organización antes de implementar este tratamiento?

La organización debería analizar las siguientes cuestiones:

1. ¿Para qué finalidad se recopilaron originalmente los datos?
2. ¿Se informó a los clientes que sus datos podrían utilizarse para promociones?
3. ¿Existe una base jurídica que permita realizar este tratamiento?
4. ¿Es necesario obtener consentimiento para esta finalidad?
5. ¿Qué información necesita realmente marketing?
6. ¿Durante cuánto tiempo se conservarán los datos utilizados?
7. ¿Qué personas o sistemas tendrán acceso a la información?
8. ¿Cómo podrán atenderse las solicitudes de oposición de los clientes?
9. ¿Qué riesgos de privacidad genera la personalización de promociones?
10. ¿Qué medidas técnicas y administrativas protegerán los datos?

Estas preguntas deben resolverse con las áreas responsables de privacidad y cumplimiento antes de implementar el tratamiento.

### 3. ¿Qué datos serían realmente necesarios?

La información necesaria dependerá de cómo se diseñe la campaña y de la finalidad autorizada.

Podrían considerarse:

- **Correo electrónico:** para enviar promociones a los clientes que puedan recibirlas conforme a las condiciones aplicables.
- **Ciudad:** para segmentar campañas geográficas cuando exista una necesidad justificada.
- **Rango de edad:** para crear grupos de clientes sin utilizar necesariamente su edad exacta.
- **Comportamiento de compra:** únicamente cuando exista una justificación válida y se disponga de información obtenida conforme a las condiciones aplicables.

No sería necesario proporcionar automáticamente el RFC, teléfono, nombre completo ni otros datos que no se utilicen para la campaña.

En la estructura actual de `public.clientes` no existe un campo de comportamiento de compra. Por lo tanto, no podemos asumir que la empresa dispone de esa información.

### 4. ¿Necesitaría el área de marketing acceso directo a `clientes`?

No necesariamente.

El departamento de marketing podría recibir información previamente seleccionada y limitada a la finalidad autorizada, sin acceder directamente a toda la tabla original.

Por ejemplo, podría utilizarse una vista que contenga únicamente los campos indispensables para la campaña.

También sería posible preparar segmentos estadísticos sin compartir identificadores individuales, dependiendo de las necesidades del proceso.

El acceso directo a `public.clientes` aumentaría el riesgo de consultar información que marketing no necesita.

### 5. ¿Qué controles técnicos podrían limitar la información entregada?

Se podrían implementar los siguientes mecanismos:

1. **Vistas de PostgreSQL:** mostrar solamente las columnas necesarias.
2. **Roles y permisos:** restringir el acceso según las responsabilidades del personal.
3. **Mínimo privilegio:** evitar que marketing consulte información de otros departamentos.
4. **Seudonimización:** sustituir identificadores directos por referencias cuando el proceso lo permita.
5. **Agregación:** proporcionar estadísticas o segmentos en lugar de registros individuales cuando sea suficiente.
6. **Separación por finalidad:** distinguir los datos operativos de los autorizados para campañas.
7. **Control de preferencias:** impedir que los datos de clientes que hayan ejercido válidamente su oposición se utilicen para la finalidad correspondiente.
8. **Auditoría:** registrar accesos y operaciones relevantes sobre la información.

Estos controles técnicos deben acompañarse de políticas y procedimientos administrativos.

## Análisis

La propuesta de marketing representa un tratamiento para una finalidad secundaria que requiere evaluación.

La organización debe comprobar que el nuevo uso de los datos se encuentra permitido y que los clientes cuentan con la información y los mecanismos necesarios para ejercer sus derechos.

Desde el punto de vista técnico, PostgreSQL permite utilizar vistas, roles y permisos para restringir la información disponible.

Sin embargo, el DBA no debe decidir por sí solo si una finalidad es jurídicamente válida. Su responsabilidad consiste en implementar los controles correspondientes a las decisiones autorizadas por las áreas competentes.

## Conclusión

Se identificó que disponer de datos personales no autoriza automáticamente a una organización a utilizarlos para finalidades diferentes.

Antes de implementar campañas personalizadas, es necesario revisar la finalidad del tratamiento, la información requerida, las condiciones aplicables y los mecanismos de protección.

También se comprendió que los controles de acceso deben relacionarse con la finalidad autorizada y no únicamente con la existencia de los datos en una tabla.
