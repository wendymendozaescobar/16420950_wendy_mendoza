# LAB-01 - Proteccion y privacidad de datos
  
**Estudiante:** Wendy Guadalupe Mendoza Escobar  
**Grado y grupo:** 4-4      
**Docente:** Alexis Moises Montaño Araujo   

---

## Actividad 1. Clasificación de los datos
### Matriz de clasificación

| Campo | ¿Identifica directamente? | ¿Puede contribuir a identificar? | ¿Requiere protección | Justificación |
|---|---|---|---|---|
| id | no | si | si | Por si solo no revela la identidad de una persona, pero permite relacionarlo con otros datos que si puedan identificarla. |
| nombre | si | si | si | Es un dato personal que puede identificar directamente a una persona dependiendo del contexto. Requiere protección para evitar su divulgación o utilización no autorizada. |
| correo | si | si | si | Puede identificar a una persona porque casi siempre en nuestro correo escribimos nuestro nombre o algun dato personal para identificarlo. Requiere protección porque podria utilizarse para enviar mensajes fraudulentos, publicidad no deseada o comercializar información personal.|
| telefono | si | si | si | El número de telefono puede identificar a una persona cuando lo tenemos registrado en algun lugar a nuestro nombre. Requiere protección porque podria utilizarse para realizar llamadas fraudulentas, extorsiones o enviar mensajes no deseados. |
| rfc | si | si | si | El rfc es un identificador único que permite distinguir a una persona como contribuyente. Requiere protección porque su uso indebido podría facilitar intentos de suplantación de identidad o fraudes. |
| edad | no | si | si | Por si sola no permite identificar directamente a una persona , ya que muchas personas pueden tener la misma edad. Sin embargo al combinarse con otros datos, como la ciudad o el código postal, pude contribuir a identificarla.|
| ciudad | no | si | si | Por si sola no identifica a ninguna persona, porque muchas personas pueden vivir en donde mismo. Pero cuando se combina con otros datos puede facilitar su identificaión y revelar información sobre su ubicación. |
| codigo_postal | no | si | si | No identifica directamente a una persona, ya que en la zona de ese CP viven muchas personas. Pero al combinarse con otros datos puede identificar su localización aproximada o su identidad. |
| fecha_alta | no | si | si | No identifica directamente a una persona ya que varios clientes se pueden registrar el mismo día. Sin embargo, cuando se combina con otros datos puede contribuir a su identificación. |
|

### Preguntas de análisis 
**1. ¿Qué campos identifican directamente a una persona?** 

Nombre, correo, télefono y rfc

**2. ¿Qué campos no identifican por sí solos, pero podrían contribuir a hacerlo?**

id, edad, ciudad, código postal y fecha de alta.

**3. ¿Qué combinación de campos podrían incrementar el riesgo de reidentificación?**

Edad y ciudad, código postal y ciudad, o edad y código postal. Tambien se pueden combinar tres campos como  edad, código postal y fecha de alta.

**4. ¿Todos los datos que deben protegerse son necesariamente datos personales sensibles desde el punto de vista jurídico?** 

No, porque existen diferentes tipos de datos personales. Algunos, como el nombre, correo electrónico y teléfono, necesitan protección para evitar que se utilicen de manera indebida, pero no necesariamente son datos personales sensibles.
Los datos sensibles requieren una protección especial debido a los riesgos que puede generar su uso o divulgación.
