# Actividad 10. Política de retención de datos

## Objetivo

Analizar la importancia de establecer periodos de conservación para los datos personales y comprender los riesgos de almacenar información indefinidamente sin una finalidad justificada.

## Procedimiento

Se analizó la propuesta de la empresa Comercializadora Norte S.A. de C.V., que plantea conservar todos los datos de sus clientes indefinidamente porque podrían resultar útiles en el futuro.

Se relacionó esta propuesta con los principios de minimización, finalidad, necesidad y ciclo de vida de los datos.

Posteriormente, se identificaron los riesgos de conservar información innecesaria y los elementos que debería considerar una organización para establecer una política de retención.

## Resultado obtenido

### 1. ¿Es compatible con el principio de minimización?

No.

Conservar todos los datos personales indefinidamente únicamente porque podrían utilizarse en el futuro no es compatible con el principio de minimización.

Este principio busca que una organización trate solamente la información adecuada, relevante y necesaria para cumplir finalidades determinadas.

Por ello, la empresa debe evaluar qué información necesita conservar, para qué propósito y durante cuánto tiempo.

La posibilidad de utilizar un dato en el futuro no constituye, por sí sola, una justificación suficiente para conservarlo indefinidamente.

### 2. ¿Qué riesgos genera conservar información innecesaria?

Conservar información personal durante más tiempo del necesario puede generar diferentes riesgos:

1. **Exposición de datos personales:** mientras más información se conserve, mayor puede ser el impacto de un acceso no autorizado o una filtración.

2. **Incumplimiento de obligaciones:** mantener información sin una finalidad o justificación adecuada puede generar problemas relacionados con la normativa aplicable.

3. **Información desactualizada:** los registros antiguos pueden contener correos, teléfonos y otros datos que ya no corresponden a la situación actual del titular.

4. **Mayor impacto de incidentes:** una vulneración podría afectar tanto a clientes actuales como a personas cuya información ya no debería conservarse.

5. **Costos de almacenamiento y administración:** conservar datos innecesarios requiere recursos adicionales para su almacenamiento, respaldo y protección.

6. **Dificultades para atender derechos ARCO:** si no se conoce dónde está almacenada la información, pueden complicarse las solicitudes de acceso, rectificación, cancelación u oposición.

### 3. ¿Qué debería determinar la organización antes de establecer un periodo de retención?

La organización debería determinar:

1. La finalidad para la cual se recopilaron los datos.
2. Si los datos siguen siendo necesarios para cumplir esa finalidad.
3. Las obligaciones legales, fiscales, contractuales o regulatorias que correspondan.
4. El momento a partir del cual comenzará a calcularse el periodo de conservación.
5. Qué área será responsable de revisar la necesidad de conservar los datos.
6. Qué procedimiento se utilizará cuando finalice el periodo.
7. Si existen copias de los datos en respaldos, sistemas externos o archivos exportados.
8. Si determinadas circunstancias justifican conservar temporalmente información que normalmente debería eliminarse.

Los periodos deben definirse de acuerdo con las características y obligaciones de cada tipo de información.

### 4. ¿Qué información debería documentarse para justificar el periodo seleccionado?

La organización debería mantener una política de retención que documente:

- **Categoría de datos:** qué información se conservará.
- **Finalidad:** por qué es necesario mantenerla.
- **Justificación:** qué necesidad operativa u obligación aplicable respalda la conservación.
- **Periodo de retención:** durante cuánto tiempo se conservará.
- **Inicio del periodo:** desde qué acontecimiento se calculará.
- **Responsable:** qué área debe supervisar el cumplimiento de la política.
- **Acciones al finalizar:** eliminación, anonimización u otra medida que corresponda.
- **Excepciones:** circunstancias justificadas que permitan conservar la información durante un periodo adicional.
- **Revisión:** cuándo se evaluará nuevamente la vigencia de la política.

Esta documentación permitiría justificar las decisiones de conservación y establecer procedimientos para administrar el ciclo de vida de la información.

## Análisis

La retención forma parte del ciclo de vida de los datos personales.

Una organización debe evaluar no solamente qué información necesita recopilar, sino también durante cuánto tiempo resulta necesario conservarla.

En el escenario del laboratorio, la tabla `public.clientes` contiene diferentes tipos de información, como nombres, correos electrónicos, teléfonos, RFC y fechas de alta.

Estos datos pueden tener finalidades distintas, por lo que no necesariamente deberían conservarse durante el mismo periodo.

Por ejemplo, la información necesaria para cumplir determinadas obligaciones fiscales podría requerir un periodo de conservación diferente del correspondiente a información utilizada únicamente para contactar a un cliente.

Sin embargo, el escenario no proporciona información suficiente para establecer plazos concretos. Estos tendrían que ser determinados por las áreas responsables conforme a los requisitos aplicables.

Desde el punto de vista técnico, el DBA puede colaborar identificando registros, tablas relacionadas, respaldos y mecanismos necesarios para aplicar la política.

También debe considerar que eliminar información de la tabla principal no implica necesariamente que desaparezca de todas las copias existentes.

## Conclusión

Se comprendió que conservar información personal indefinidamente sin una finalidad justificada puede generar riesgos de privacidad, seguridad y cumplimiento.

Una política de retención debe establecer qué información necesita conservarse, durante cuánto tiempo, quién es responsable y qué procedimiento se aplicará cuando deje de ser necesaria.

El DBA debe colaborar en la implementación técnica de estas decisiones, pero la determinación de los periodos de conservación debe involucrar a las áreas responsables de privacidad, cumplimiento y otras funciones competentes.

Durante esta actividad no se modificaron ni eliminaron registros de PostgreSQL.
