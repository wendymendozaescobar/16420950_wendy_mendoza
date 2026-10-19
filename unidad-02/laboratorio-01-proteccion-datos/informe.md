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

## Actividad 2. Enmascaramiento de datos.
### Preguntas

**1. ¿Qué información continúa existiendo en la tabla original?**  
Toda ya que no modificamos nada de la tabla original.  

**2. ¿Qué información puede visualizar el usuario soporte?**  
Solo la view v_cliente_soporte que creamos donde solo puede ver el id y el nombre completo, tambien puede ver el correo pero las dos primeras letras se conservan, las siguientes 5 letras no se pueden visualizar y apartir del @ del correo se ve todo. El telefono solo puede visualizar los ultimos 4 digitos y tambien en el rfc solo puede ver los ultimos 4 datos.  

**3. ¿Por qué no es suficiente ocultar los datos únicamente en la aplicación?**   
Porque si los datos solo se ocultan en la aplicación, una persona que tenga acceso directo a la base de datos podría consultar la tabla original y visualizar toda la información. Por eso también es necesario aplicar restricciones desde PostgreSQL para que cada usuario tenga acceso solamente a los datos que necesita. 

**4. ¿Qué ocurriría si soporte tuviera acceso directo a clientes?**  
La empresa tiene la obligación de no divulgar datos personales de sus usuarios ademas de que es algo que por organizacion se recomienda ya que no es un dato necesario para realizar el trabajo del area de soporte.  

### Explicación del mecanismo de enmascaramiento  
Se crea una vista a la cual se le asigna un nombre y seleccionamos qué es lo que se quiere visualizar. En este caso, es el ID y el nombre completo. Del correo solo mostramos los primeros dos caracteres, indicamos que se concatenen 5 asteriscos y después concatenamos todo el dominio a partir del @. También en el teléfono concatenamos 6 asteriscos y mostramos los últimos 4 dígitos. Después, concatenamos 9 asteriscos y mostramos los últimos 4 caracteres del RFC. Al final indicamos que los datos provienen de la tabla clientes.
Otorgamos el permiso USAGE sobre el esquema public al rol soporte y después le dimos permiso SELECT para consultar la vista v_clientes_soporte. También utilizamos REVOKE ALL para retirar los permisos directos sobre la tabla clientes.
Para comprobar que los permisos funcionaran, utilizamos SET ROLE soporte y realizamos consultas. Pudimos visualizar la vista con los datos enmascarados, pero cuando intentamos consultar directamente la tabla clientes, PostgreSQL mostró un error de permisos.
Este mecanismo se implementó para el área de soporte, ya que necesita consultar cierta información de los clientes para realizar su trabajo, pero no requiere visualizar los correos, teléfonos y RFC completos.
