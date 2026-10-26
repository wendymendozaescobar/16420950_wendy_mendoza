# Registro de cambios y comparación de configuración

## Actividad 16. Comparación antes y después del hardening

### Objetivo

Comparar el estado inicial de seguridad de PostgreSQL con el estado observado después de las actividades de inspección, identificando los controles existentes y las mejoras que podrían considerarse.

### Procedimiento

Se utilizaron los resultados obtenidos durante las primeras quince actividades del LAB-04.

Se revisaron las interfaces de escucha, reglas de autenticación, roles, privilegios, puerto, TLS, permisos del sistema operativo, extensiones y configuración de conexiones.

No se modificaron parámetros, cuentas, permisos ni archivos de configuración durante estas actividades.

### Resultados

| Control | Antes | Después | Justificación |
|---|---|---|---|
| `listen_addresses` | `localhost` | Sin cambios: `localhost` | Las prácticas utilizan conexiones locales y no requieren exponer PostgreSQL en interfaces externas. |
| `pg_hba.conf` | Siete reglas: conexiones locales con `peer` y TCP local con `scram-sha-256` | Sin cambios | No se identificaron reglas con `0.0.0.0/0` ni `::/0`. Se conservó el acceso necesario para las prácticas. |
| Método de autenticación | `password_encryption = scram-sha-256` | Sin cambios | El mecanismo configurado para establecer nuevas contraseñas es adecuado. Deben considerarse también las reglas efectivas de autenticación. |
| Usuarios administrativos | `postgres` identificado como superusuario | Sin cambios | Se identificaron los privilegios administrativos y se reconoció la importancia de limitar su utilización. |
| Cuentas de aplicación | `lab02_tls` con `LOGIN`; `analista` y `soporte` con `NOLOGIN`. No se identificó una cuenta productiva de aplicación. | Sin cambios | Se propuso conceptualmente separar cuentas DBA, APP y CONSULTA, pero no se crearon cuentas nuevas. |
| Puerto | `5433` | Sin cambios: `5433` | El puerto corresponde a nuestra instalación PostgreSQL 18. Cambiarlo no constituye por sí solo una mejora suficiente de seguridad. |
| TLS | `ssl = on`, mínimo TLS 1.2 | Sin cambios | Se verificó una conexión TCP cifrada con TLS 1.3 mediante `lab02_tls`. No fue necesario modificar el servidor. |
| Permisos del sistema operativo | Archivos de configuración `640`; directorio de datos `700` | Sin cambios | Los permisos inspeccionados restringen el acceso ordinario a los archivos sensibles. |
| Extensiones | `pgcrypto` 1.4 y `plpgsql` 1.0 | Sin cambios | Se identificaron las extensiones y sus funciones. No se justificó eliminar ninguna sin revisar sus dependencias. |
| Conexiones | Máximo `100`; tres reservadas para superusuarios; tiempos de espera consultados en `0` | Sin cambios | Se identificaron límites y posibles mejoras relacionadas con tiempos de espera, pero no se establecieron valores arbitrarios. |

### Comprobaciones realizadas

Durante las actividades se verificó que:

1. PostgreSQL 18.6 utiliza el puerto `5433`.
2. El servidor escucha mediante TCP en `127.0.0.1:5433`.
3. Las reglas de autenticación inspeccionadas se limitan a conexiones locales.
4. Las conexiones TCP configuradas utilizan `scram-sha-256`.
5. El usuario `postgres` tiene privilegios de superusuario.
6. Los archivos de configuración y datos presentan permisos restrictivos.
7. Se identificaron las extensiones instaladas en la base de datos del laboratorio.
8. Se comprobó una conexión cifrada mediante TLS 1.3.
9. Se revisaron los límites de conexiones y tiempos de espera.

### Mejoras pendientes de evaluación

Aunque se identificaron configuraciones favorables, existen aspectos que podrían estudiarse antes de proponer cambios:

- Evaluar límites de tiempo apropiados para consultas y transacciones inactivas.
- Revisar los mecanismos de registro de conexiones y desconexiones.
- Verificar periódicamente los privilegios de las cuentas.
- Comprobar que las aplicaciones utilicen cuentas específicas y no superusuarios.
- Definir procedimientos de actualización y revisión de seguridad.
- Evaluar una política de validación de certificados TLS para conexiones que lo requieran.

Estas medidas representan recomendaciones pendientes de evaluación, no cambios ya implementados.

### Análisis

La comparación demuestra que aplicar hardening no siempre implica modificar inmediatamente la configuración.

Antes de realizar cambios, es necesario identificar riesgos concretos y determinar si los controles actuales cumplen las necesidades del entorno.

En nuestro laboratorio, varias medidas ya estaban configuradas adecuadamente, como la escucha local, la autenticación SCRAM-SHA-256 para conexiones TCP y los permisos restrictivos del sistema operativo.

Por esta razón, conservar esas configuraciones fue una decisión justificada.

Los controles pendientes requieren una evaluación adicional antes de establecer parámetros específicos.

### Conclusión

Se documentó el estado inicial y el estado posterior a las actividades de inspección.

No se registraron modificaciones de configuración del servidor durante el LAB-04 hasta esta actividad.

Se comprobó que diversos controles de seguridad ya estaban presentes y se identificaron oportunidades de mejora que deberán evaluarse antes de implementarse.

La actividad permitió comprender que un proceso de hardening debe basarse en evidencia, justificación técnica y verificación de resultados.
