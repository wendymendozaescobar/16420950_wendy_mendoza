# Actividad 7. Comparar protección en reposo y en tránsito

## Objetivo

Identificar los mecanismos adecuados para proteger diferentes tipos de información y distinguir entre protección de datos almacenados y protección durante su transmisión.

## Procedimiento

Se analizaron cinco situaciones de seguridad y se seleccionó el mecanismo de protección correspondiente a cada una.

## Resultado obtenido

| Situación | Mecanismo apropiado | ¿Qué protege? |
|---|---|---|
| Contraseña de usuario | Hash especializado para contraseñas, como bcrypt o Argon2id | Evita almacenar directamente la contraseña original y permite verificarla sin recuperarla. |
| RFC almacenado en una tabla | Cifrado de datos, por ejemplo, cifrado simétrico | Protege la confidencialidad del RFC almacenado y permite recuperarlo con la clave correspondiente. |
| Consulta enviada desde un cliente al servidor | TLS | Protege la información transmitida mediante mecanismos de confidencialidad e integridad. |
| Respaldo de una base de datos | Cifrado del respaldo | Protege la información contenida en las copias de seguridad frente a accesos no autorizados. |
| Clave criptográfica | Gestión segura de claves | Protege las claves mediante controles de almacenamiento, acceso, rotación, respaldo y revocación. |

## Análisis

No todos los datos requieren el mismo mecanismo de protección.

Las contraseñas deben almacenarse mediante mecanismos de hash especializados porque no es necesario recuperar su valor original.

En cambio, ciertos datos sensibles, como el RFC, pueden requerir cifrado cuando existe una necesidad legítima de recuperarlos.

TLS protege la información mientras se transmite entre el cliente y el servidor, mientras que el cifrado de datos almacenados protege información en reposo.

Las claves criptográficas requieren controles específicos porque su exposición puede comprometer la información que protegen.

## Conclusión

La seguridad de una base de datos requiere diferentes mecanismos que se complementan entre sí.

El hash protege contraseñas, el cifrado protege información recuperable, TLS protege las comunicaciones y la gestión de claves ayuda a mantener seguros los mecanismos criptográficos.

Ninguna de estas medidas sustituye los controles de acceso y permisos de PostgreSQL.
