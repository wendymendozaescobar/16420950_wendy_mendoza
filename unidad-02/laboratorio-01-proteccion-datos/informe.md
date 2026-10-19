# LAB-01 - Proteccion y privacidad de datos
  
**Estudiante:** Wendy Guadalupe Mendoza Escobar  
**Grado y grupo:** 4-4      
**Docente:** Alexis Moises Montaño Araujo   

---

## Actividad 1. Clasificación de los datos
### Matriz de clasificación

| Campo | ¿Identifica directamente? | ¿Puede contribuir a identificar? | ¿Requiere protección? | Justificación |
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
Solo la view v_clientes_soporte que creamos donde solo puede ver el id y el nombre completo, tambien puede ver el correo pero las dos primeras letras se conservan, las siguientes 5 letras no se pueden visualizar y apartir del @ del correo se ve todo. El telefono solo puede visualizar los ultimos 4 digitos y tambien en el rfc solo puede ver los ultimos 4 datos.  

**3. ¿Por qué no es suficiente ocultar los datos únicamente en la aplicación?**   
Porque si los datos solo se ocultan en la aplicación, una persona que tenga acceso directo a la base de datos podría consultar la tabla original y visualizar toda la información. Por eso también es necesario aplicar restricciones desde PostgreSQL para que cada usuario tenga acceso solamente a los datos que necesita. 

**4. ¿Qué ocurriría si soporte tuviera acceso directo a clientes?**  
La empresa tiene la obligación de no divulgar datos personales de sus usuarios ademas de que es algo que por organizacion se recomienda ya que no es un dato necesario para realizar el trabajo del area de soporte.  

### Explicación del mecanismo de enmascaramiento  
Se crea una vista a la cual se le asigna un nombre y seleccionamos qué es lo que se quiere visualizar. En este caso, es el ID y el nombre completo. Del correo solo mostramos los primeros dos caracteres, indicamos que se concatenen 5 asteriscos y después concatenamos todo el dominio a partir del @. También en el teléfono concatenamos 6 asteriscos y mostramos los últimos 4 dígitos. Después, concatenamos 9 asteriscos y mostramos los últimos 4 caracteres del RFC. Al final indicamos que los datos provienen de la tabla clientes.
Otorgamos el permiso USAGE sobre el esquema public al rol soporte y después le dimos permiso SELECT para consultar la vista v_clientes_soporte. También utilizamos REVOKE ALL para retirar los permisos directos sobre la tabla clientes.
Para comprobar que los permisos funcionaran, utilizamos SET ROLE soporte y realizamos consultas. Pudimos visualizar la vista con los datos enmascarados, pero cuando intentamos consultar directamente la tabla clientes, PostgreSQL mostró un error de permisos.
Este mecanismo se implementó para el área de soporte, ya que necesita consultar cierta información de los clientes para realizar su trabajo, pero no requiere visualizar los correos, teléfonos y RFC completos.  

## Actividad 3. Seudonimización de datos

### Preguntas

**1. ¿Qué ocurriría si analista pudiera consultar también pii.mapa_cliente?**  
Pudiera ver la relacion de cada token con el id original del cliente, lo que aumentaría el riesgo de identificar a las personas si también tuviera acceso a la información original.

**2. ¿Qué principio de seguridad se está aplicando al separar ambos accesos?**  
Principio de minimo privilegio  

**3. ¿Por qué la seudonimización no equivale a anonimización?**  
Porque en la seudonimización todavía existe la posibilidad de identificar a los clientes mediante el mapa de correspondencia que relaciona los tokens con sus identificadores originales. En cambio, la anonimización busca que no sea posible identificar a las personas mediante medios razonablemente disponibles.

**4. ¿Qué información permite volver a relacionar el token con una persona?**  
La tabla pii.mapa_cliente, porque contiene la relación entre los tokens y los ID originales de los clientes. Con esos ID podemos consultar la tabla public.clientes y conocer a qué persona pertenece cada token.

### Explicación del mecanismo de seudonimización  

Primero creamos dos esquemas llamados pii y analitica para separar la información. Después dentro del esquema pii, creamos una tabla llamada mapa_cliente, donde guardamos los tokens y los ID originales de los clientes.
Para generar los tokens utilizamos la función gen_random_uuid(), que genera un identificador aleatorio para cada cliente. Estos tokens se relacionaron con los ID originales que ya teníamos en la tabla public.clientes.
Después creamos la tabla analitica.clientes, donde colocamos los tokens junto con la edad, ciudad, código postal y fecha de alta de cada cliente, sin incluir su nombre, correo, teléfono ni RFC.
El mapa de correspondencia se encuentra en pii.mapa_cliente y solamente debería poder consultarlo el personal autorizado que necesite relacionar los tokens con los clientes originales.
Por último, creamos el rol analista y le otorgamos permisos para consultar únicamente la tabla analitica.clientes. Separamos los permisos para evitar que el analista pueda consultar el mapa de correspondencia y descubrir la identidad de los clientes. Para comprobarlo, cambiamos al rol analista y realizamos las consultas. Pudimos visualizar los datos seudonimizados, pero PostgreSQL nos negó el acceso al mapa de correspondencia y a la tabla original.  

## Actividad 4. Anonimización de datos  

### Preguntas  
**1. ¿Qué identificadores directos fueron eliminados?**  
En los resultados de las consultas dejamos de mostrar el ID, nombre, correo electrónico, teléfono y RFC de los clientes. Solo mostramos los rangos de edad, las regiones y la cantidad de clientes que pertenecen a cada grupo. Los datos originales siguen almacenados en la tabla clientes.  
**2. ¿Qué cuasi-identificadores permanecen?**  
Permanecen la edad y la región.   
**3. ¿Qué combinaciones de atributos podrían reducir el anonimato?**  
La combinación del rango de edad y la región puede reducir el anonimato. En nuestras consultas encontramos dos grupos que contienen solamente un cliente, lo que aumenta el riesgo de identificar a esas personas.  
**4. ¿Qué sucede cuando un grupo contiene pocos registros?**  
Aumenta el riesgo de reidentificación porque es más fácil distinguir a una persona cuando hay pocos registros con las mismas características. Por eso utilizamos HAVING COUNT(*) >= 5 para evitar mostrar grupos pequeños.  
**5. ¿Qué atributos deberían generalizarse?**  
Se podrían generalizar todavía más la edad y la región. Por ejemplo, utilizar rangos de edad más amplios y mostrar una región geográfica menos específica para evitar que los grupos tengan pocos registros.  
**6. ¿Qué información debería suprimirse?**  
Se deberían suprimir de los resultados los grupos que tengan pocos registros, especialmente aquellos que contienen una sola persona. También se deben evitar los identificadores directos, como nombres, correos, teléfonos y RFC, cuando no sean necesarios para el análisis.  
**7. ¿Es correcto afirmar que el conjunto de datos es «100 % anónimo»? ¿Por qué?**  
No, porque aunque generalizamos los datos y eliminamos los identificadores directos de los resultados, todavía podría existir el riesgo de identificar a una persona utilizando información adicional. Por eso no podemos garantizar que los datos sean completamente anónimos.  

### Reto: Reducir el riesgo de reidentificación  
Modificamos la consulta para ampliar el rango de edad de 18 a 60 años y mostrar solamente el primer carácter del código postal, en lugar de los primeros dos. Mantuvimos la condición HAVING COUNT(*) >= 5.
Anteriormente teníamos tres grupos de clientes, dos con un solo registro y otro con tres. Esto aumentaba el riesgo de reidentificación, por lo que decidimos generalizar más la información. Después de modificar la consulta, PostgreSQL mostró un solo grupo con cinco clientes, todos dentro del rango de edad de 18 a 60 años y con una región que comienza con 8.
Buscamos reducir el riesgo de identificar individualmente a los clientes mediante la combinación de su edad y ubicación geográfica.  

### Explicación del mecanismo de anonimización  
En esta actividad realizamos consultas para mostrar información estadística de los clientes sin incluir sus identificadores directos, como el nombre, ID, correo, teléfono y RFC. Estos datos no se eliminaron de la tabla original, solamente dejaron de mostrarse en los resultados. Generalizamos la edad utilizando rangos y el código postal mostrando únicamente sus primeros dos caracteres. Después combinamos ambos atributos para identificar cuántos clientes pertenecían a cada grupo. Encontramos dos grupos con un solo cliente y otro con tres, por lo que utilizamos HAVING COUNT(*) >= 5 para suprimir de los resultados los grupos con menos de cinco registros. Como ninguno cumplía la condición, la consulta devolvió cero filas.  
Finalmente, ampliamos los rangos de edad y generalizamos más la región, consiguiendo un grupo de cinco clientes. Esto reduce el riesgo de reidentificación, aunque no garantiza que los datos sean completamente anónimos porque podría existir información adicional que permita identificar a una persona.  

## Actividad 5. Retención de datos

### Explicación del procedimiento de retención  
En esta actividad utilizamos una consulta SQL para identificar los clientes cuya fecha de alta fuera anterior a cinco años. Al ejecutar la consulta obtuvimos cero filas, porque ninguno de nuestros cinco clientes supera ese periodo.  
Utilizamos un periodo hipotético de conservación de cinco años. En una empresa real, este periodo debería justificarse según las necesidades de la organización y las obligaciones legales que correspondan.
La información que todavía sea necesaria para las operaciones de la empresa o que deba conservarse por alguna obligación legal tendría que mantenerse protegida. Los registros que superen el periodo establecido podrían evaluarse para su eliminación, siempre que ya no exista una razón válida para conservarlos.
Antes de eliminar información, debería existir una autorización del responsable correspondiente, después de verificar que no haya obligaciones pendientes. También sería necesario realizar un respaldo seguro y comprobar que pueda recuperarse.
Como evidencia, se debería conservar un registro de los datos afectados, la fecha del procedimiento, quién lo autorizó, quién lo realizó y cuál fue el resultado.
Si se eliminara información accidentalmente, se tendría que seguir un procedimiento de recuperación utilizando el respaldo correspondiente y verificar que los registros se hayan restaurado correctamente.  

## Conclusiones  

**1. ¿Qué técnica utilizarías para un área de soporte?**  
Utilizaría el enmascaramiento de datos, porque el personal de soporte necesita consultar cierta información de los clientes, pero no requiere visualizarla completamente. Con una vista podemos mostrar solamente los datos necesarios y ocultar parcialmente los correos, teléfonos y RFC.  

**2. ¿Qué técnica utilizarías para un área de analítica?**  
Utilizaría la seudonimización, porque permite analizar información de los clientes sin utilizar directamente sus datos personales. Los identificadores originales se sustituyen por tokens y el mapa de correspondencia se mantiene protegido para evitar que los analistas puedan identificar a las personas.  

**3. ¿Qué técnica utilizarías para publicar estadísticas?**  
Utilizaría la anonimización, porque al publicar estadísticas no es necesario mostrar información que identifique individualmente a los clientes. Podemos generalizar atributos, agrupar registros y suprimir grupos pequeños para reducir el riesgo de reidentificación. También sería necesario evaluar los riesgos antes de publicar la información.  

**4. ¿Por qué ninguna de estas técnicas sustituye al control de acceso?**  
Porque aunque ocultemos, sustituyamos o generalicemos los datos, todavía es necesario controlar quién puede consultar la información. Por eso utilizamos permisos como GRANT y REVOKE, para que cada rol tenga acceso únicamente a lo que necesita para realizar su trabajo.  

## Preguntas de reflexión

**1. ¿Cuál es la diferencia entre enmascaramiento y seudonimización?**  
El enmascaramiento consiste en ocultar una parte o totalmente ciertos datos. En cambio la seudonimización sustituye los identificadores originales por otros valores, como los tokens que generamos en PostgreSQL.  

**2. ¿Por qué la seudonimización no significa anonimización?**  
Porque en la seudonimización todavía existe la posibilidad de identificar a las personas utilizando el mapa de correspondencia y en la anonimización busca evitar que las personas puedan ser identificadas mediante medios razonablemente disponibles.  

**3. ¿Por qué eliminar nombre y RFC no garantiza que un conjunto de datos sea anónimo?** 
Porque existen otros datos, como la edad, ciudad y código postal, que al combinarse podrían permitir identificar a una persona, aunque no se muestre su nombre o RFC.  

**4. ¿Qué función tienen los cuasi-identificadores?**  
Son datos que individualmente no necesariamente identifican a una persona, pero que al combinarse con otros pueden facilitar su identificación. Por ejemplo, la edad y el código postal.  

**5. ¿Por qué es importante separar el mapa de seudonimización?**  
Porque contiene la relación entre los tokens y los identificadores originales. Si el analista pudiera consultar ese mapa y relacionarlo con los datos originales, podría descubrir a qué cliente pertenece cada token.  

**6. ¿Qué principio de seguridad se aplica al impedir que el analista acceda al mapa?**  
El principio de mínimo privilegio.  

**7. ¿Por qué una vista puede ser preferible a entregar acceso directo a la tabla?**  
Porque una vista permite mostrar únicamente las columnas o los datos que necesita el usuario. En nuestro laboratorio utilizamos una vista para mostrar información enmascarada sin permitir que el rol soporte consulte directamente la tabla original.  

**8. ¿Qué diferencia existe entre proteger un dato para visualización y protegerlo contra acceso no autorizado?**  
Proteger un dato para visualización significa ocultar cierta información cuando se muestra al usuario. En cambio, protegerlo contra accesos no autorizados significa configurar permisos para impedir que usuarios sin autorización puedan consultar esa información directamente.  

**9. ¿Por qué la retención forma parte de la protección de datos?**  
Porque permite establecer durante cuánto tiempo es necesario conservar la información. Así se evita almacenar datos personales durante más tiempo del necesario y se reduce el riesgo de exposición.  

**10. ¿Qué riesgo existe si una organización conserva información indefinidamente?**  
Aumenta el riesgo de que la información sea robada, filtrada o utilizada de manera indebida. Además, la organización podría conservar datos que ya no necesita e incumplir las obligaciones legales relacionadas con su conservación.  


