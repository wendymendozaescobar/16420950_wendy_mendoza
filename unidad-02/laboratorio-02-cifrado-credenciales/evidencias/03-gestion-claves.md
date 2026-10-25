# Actividad 3. El problema de la gestión de claves

## Objetivo  
Identificar los riesgos de almacenar claves criptográficas
directamente en archivos SQL y repositorios Git.

## Procedimiento realizado  
Se creó un archivo temporal llamado `ejemplo-mala-practica.sql`
que contenía una consulta de descifrado con una clave ficticia.
Se analizó el riesgo de publicar ese archivo y posteriormente
se eliminó para evitar incluirlo en la entrega final.

## Resultado obtenido  
Se identificó que la clave criptográfica estaba escrita
directamente dentro de la consulta SQL.
Esto demuestra cómo una clave podría quedar expuesta
al publicar un archivo en un repositorio.

## Pregunta de análisis

**¿Qué ocurriría si esta clave fuera una clave utilizada
realmente por una organización y el archivo se publicara
en un repositorio Git?**  
Cualquier persona con acceso al repositorio podría obtener
la clave y, si también tuviera acceso a los datos cifrados
podría descifrarlos. No sería suficiente borrar la clave del
archivo, porque podría permanecer en el historial de Git desde
el commit en el que fue publicada. 

## Análisis  
Los repositorios Git conservan un historial de cambios.
Por eso, eliminar una clave del archivo actual no garantiza
que desaparezca de los commits anteriores.
Las claves reales deben administrarse mediante mecanismos
seguros de gestión de secretos, separados del código fuente.

## Conclusión  
La seguridad del cifrado también depende de proteger
las claves utilizadas. No debemos almacenar secretos
reales directamente en archivos SQL ni publicarlos
en repositorios.
