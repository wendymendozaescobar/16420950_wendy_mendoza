# Actividad 10. Política mínima de protección de claves criptográficas

## Objetivo

Establecer reglas básicas para administrar y proteger las claves criptográficas utilizadas por una organización, reduciendo los riesgos de exposición, pérdida y uso no autorizado.

## Procedimiento

Se analizaron los riesgos relacionados con el manejo de claves criptográficas y se elaboró una política de ocho reglas que contempla las principales etapas de su ciclo de vida.

## Política de protección de claves

### Regla 1. Generación

Las claves criptográficas deberán generarse utilizando herramientas confiables y mecanismos criptográficamente seguros. No se permitirá utilizar claves predecibles, reutilizadas o creadas manualmente sin criterios de seguridad.

### Regla 2. Almacenamiento

Las claves deberán almacenarse en un sistema especializado de gestión de claves o secretos, separado de los datos que protegen. No se permitirá guardar claves reales directamente en archivos SQL, código fuente o repositorios Git.

### Regla 3. Control de acceso

Únicamente los usuarios, aplicaciones y servicios expresamente autorizados podrán utilizar las claves criptográficas. Los permisos deberán limitarse a las funciones necesarias y revisarse periódicamente.

### Regla 4. Rotación

Las claves deberán renovarse de acuerdo con una política de rotación establecida por la organización. El procedimiento deberá garantizar que los datos cifrados puedan seguir recuperándose de manera autorizada durante la transición.

### Regla 5. Respaldo

Las claves que sea necesario recuperar deberán contar con respaldos protegidos contra accesos no autorizados y pérdidas accidentales. Estos respaldos deberán almacenarse de forma segura y probarse periódicamente mediante procedimientos controlados de recuperación.

### Regla 6. Revocación

Cuando una clave deje de ser necesaria, pierda su autorización o exista evidencia de uso indebido, deberá revocarse o deshabilitarse según el mecanismo utilizado. También deberán actualizarse los sistemas que dependan de ella.

### Regla 7. Exposición accidental

Si una clave se publica accidentalmente en un repositorio, documento o sistema no autorizado, deberá considerarse comprometida. Se notificará el incidente, se evaluará su alcance y se procederá a sustituir la clave y proteger nuevamente los datos afectados cuando corresponda.

Eliminar la clave del archivo publicado no será suficiente, porque podría permanecer en el historial de Git.

### Regla 8. Eliminación segura

Las claves que hayan terminado su ciclo de vida deberán eliminarse de manera controlada, incluyendo las copias que ya no deban conservarse. Antes de eliminarlas, deberá comprobarse que no sean necesarias para recuperar información o respaldos autorizados.

## Resultado obtenido

Se establecieron ocho reglas que contemplan la generación, almacenamiento, acceso, rotación, respaldo, revocación, exposición accidental y eliminación de claves criptográficas.

La política permite definir responsabilidades y medidas preventivas durante las diferentes etapas de administración de las claves.

## Análisis

La seguridad de la información cifrada no depende únicamente del algoritmo utilizado.

Una clave puede haber sido generada mediante un mecanismo seguro, pero si se almacena incorrectamente o se publica en un repositorio, puede comprometer la confidencialidad de los datos.

Por eso, las organizaciones necesitan establecer procedimientos para controlar quién utiliza las claves, cómo se protegen y qué debe hacerse cuando se pierden o quedan expuestas.

## Conclusión

La gestión de claves criptográficas es fundamental para mantener la seguridad de los datos cifrados.

Una política adecuada debe proteger las claves durante todo su ciclo de vida, desde su generación hasta su eliminación definitiva.

También debe permitir responder ante incidentes sin comprometer la disponibilidad de la información que la organización necesita conservar.
