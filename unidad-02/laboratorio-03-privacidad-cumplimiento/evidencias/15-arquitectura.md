# Actividad 15. Propuesta de arquitectura de datos protegidos

## Objetivo

Diseñar una arquitectura conceptual que permita separar la información de una organización según su finalidad, incorporando controles de privacidad, seguridad y gobierno de datos.

## Procedimiento

Se analizó el escenario de Comercializadora Norte S.A. de C.V. y se retomaron los mecanismos estudiados durante los laboratorios anteriores.

Se propuso una arquitectura organizada en tres áreas principales: operación, analítica y auditoría.

Posteriormente, se definieron controles para el acceso, minimización, protección de información sensible, retención, trazabilidad, eliminación y atención de solicitudes de los titulares.

La propuesta es conceptual. No se implementaron nuevos componentes ni se modificaron registros de PostgreSQL durante esta actividad.

## Resultado obtenido

### 1. Arquitectura conceptual propuesta

```text
                     ORGANIZACIÓN
                          |
                          v
                    POSTGRESQL
                          |
        +-----------------+-----------------+
        |                 |                 |
        v                 v                 v
     OPERACIÓN         ANALÍTICA         AUDITORÍA
        |                 |                 |
        v                 v                 v
 Información para   Información para   Información para
 atención al        estadísticas       registrar y revisar
 cliente y          y reportes         operaciones
 facturación
        |                 |                 |
        v                 v                 v
 Roles y permisos   Datos agrupados    Registros de acceso
 por finalidad      o seudonimizados   y modificaciones
        |                 |                 |
        +-----------------+-----------------+
                          |
                          v
                  GOBIERNO DE DATOS
                          |
       +------------------+------------------+
       |                  |                  |
       v                  v                  v
    RETENCIÓN        DERECHOS ARCO        SEGURIDAD
       |                  |                  |
       v                  v                  v
 Conservación       Procedimientos       Control de acceso
 y eliminación      de atención          Cifrado y TLS
 justificadas       de solicitudes       Gestión de claves
```

### 2. Separación de la información por finalidad

**Operación**

Esta área contiene la información necesaria para realizar las actividades comerciales y administrativas.

Se propone separar el acceso de atención al cliente y facturación.

Atención al cliente podría consultar únicamente información de identificación y contacto, mientras que facturación tendría acceso a los datos fiscales necesarios.

Durante el LAB-03 se creó `lab03.clientes_soporte`, que contiene identificador, nombre, correo y teléfono.

En un entorno productivo sería conveniente evaluar si una vista restringida podría sustituir esta copia y evitar problemas de sincronización.

**Analítica**

Esta área debe proporcionar información para elaborar estadísticas sin entregar automáticamente identificadores personales.

Durante el LAB-01 se utilizó el esquema `analitica` para trabajar con información seudonimizada.

En el LAB-03 se creó `lab03.v_analitica_clientes`, que presenta ciudad y rango de edad.

Sin embargo, esa vista todavía devuelve registros individuales. Por ello, se propone complementar la arquitectura con vistas que proporcionen resultados agregados y controles para evitar la identificación indirecta.

**Auditoría**

Se propone implementar mecanismos que permitan registrar y revisar operaciones relevantes sobre los datos.

Estos registros podrían incluir el usuario o proceso que ejecutó una operación, su fecha y hora, el tipo de acción y el objeto afectado.

La información de auditoría debe protegerse mediante permisos restringidos y una política de conservación apropiada.

Durante este laboratorio se analizó la importancia de la trazabilidad, pero no se implementó un sistema completo de auditoría persistente.

### 3. Controles propuestos

| Área de control | Mecanismo propuesto | Finalidad |
|---|---|---|
| Acceso | Roles, permisos y vistas restringidas | Permitir que cada departamento consulte únicamente la información autorizada. |
| Minimización | Selección de columnas y datos agregados | Reducir la recopilación y exposición de información innecesaria. |
| Protección de información sensible | Cifrado, hash de contraseñas, TLS y gestión segura de claves | Proteger datos almacenados, credenciales y comunicaciones. |
| Retención | Política documentada de conservación | Definir cuánto tiempo deben mantenerse los datos y bajo qué justificación. |
| Trazabilidad | Registros de auditoría y seguimiento de operaciones | Identificar las acciones relevantes realizadas sobre los datos. |
| Eliminación | Procedimientos de revisión y disposición de información | Aplicar las decisiones autorizadas sobre eliminación o conservación. |
| Atención de solicitudes | Procedimientos para derechos ARCO | Localizar, corregir, restringir o cancelar datos cuando corresponda. |

### 4. Aplicación de los controles

#### Control de acceso

Se propone utilizar roles de PostgreSQL con permisos específicos para cada área funcional.

El personal de atención al cliente debería acceder únicamente a la información necesaria para atender solicitudes.

Facturación tendría acceso a los datos fiscales justificados.

Analítica recibiría resultados estadísticos o información preparada para su finalidad.

Los permisos administrativos del DBA no deberían utilizarse para consultar información personal sin una necesidad relacionada con sus funciones.

#### Minimización de datos

La organización debería determinar qué información necesita realmente cada proceso.

Se propone evitar copias completas de la tabla de clientes cuando sea suficiente una vista o una consulta con información limitada.

También se recomienda generar estadísticas agregadas y evitar identificadores individuales cuando no sean necesarios.

#### Protección de información sensible

Se propone aplicar mecanismos de protección adecuados al tipo de información.

Las contraseñas deberían almacenarse mediante funciones especializadas de hash.

Los datos sensibles recuperables podrían requerir cifrado y controles de acceso.

Las comunicaciones entre clientes y servidores deberían protegerse mediante TLS con una validación apropiada de la identidad del servidor.

Las claves criptográficas deberían administrarse mediante mecanismos seguros y no almacenarse directamente en repositorios.

#### Retención

La organización debería establecer periodos de conservación asociados con las finalidades y obligaciones aplicables.

La política debe identificar los responsables, las condiciones de conservación y las acciones que corresponden cuando la información deja de ser necesaria.

No se propone un periodo único para todos los datos, porque pueden existir obligaciones diferentes según su naturaleza y finalidad.

#### Trazabilidad

Se propone implementar registros que permitan identificar las operaciones relevantes sobre la información.

Por ejemplo, una rectificación debería contar con información que permita conocer qué solicitud motivó el cambio, quién lo autorizó y qué usuario o proceso lo ejecutó.

También deberían establecerse mecanismos para proteger los registros de auditoría frente a alteraciones no autorizadas.

#### Eliminación

Antes de eliminar información, deberían identificarse las tablas relacionadas, respaldos, réplicas, exportaciones y sistemas externos pertinentes.

La eliminación debe responder a procedimientos autorizados y considerar las obligaciones de conservación aplicables.

También es necesario documentar las acciones realizadas y evitar que copias innecesarias permanezcan disponibles indefinidamente.

#### Atención de solicitudes

Se propone establecer procedimientos para atender solicitudes de acceso, rectificación, cancelación y oposición.

El DBA colaboraría identificando la información y ejecutando las operaciones técnicas autorizadas.

Las áreas responsables de privacidad y cumplimiento determinarían la procedencia y el alcance de las solicitudes.

La arquitectura también debería contemplar mecanismos para aplicar restricciones de tratamiento según las finalidades autorizadas.

### 5. Relación con los laboratorios anteriores

La propuesta integra conocimientos adquiridos durante las prácticas.

| Laboratorio | Conocimiento aplicado |
|---|---|
| LAB-01 | Clasificación, enmascaramiento, seudonimización y control de acceso. |
| LAB-02 | Protección de contraseñas, cifrado, TLS y gestión de claves criptográficas. |
| LAB-03 | Minimización, limitación de finalidad, derechos ARCO, retención y gobierno de datos. |

Estos mecanismos son complementarios y permiten abordar diferentes riesgos relacionados con la administración de información personal.

## Análisis

La separación de la información según su finalidad permite establecer controles de acceso más adecuados para cada departamento.

Una organización no necesita proporcionar acceso completo a la tabla de clientes para que sus áreas realicen sus funciones.

Las vistas, roles y permisos de PostgreSQL pueden utilizarse para restringir la información disponible.

Sin embargo, también deben existir políticas de gobierno de datos que definan las finalidades, responsabilidades, periodos de conservación y procedimientos para atender solicitudes.

La arquitectura propuesta distingue entre los mecanismos técnicos y las decisiones organizacionales.

También considera que las copias de información y los registros de auditoría forman parte del ciclo de vida de los datos y requieren controles específicos.

No todos los componentes propuestos están implementados en la base de datos del laboratorio. Su implementación completa requeriría un proyecto adicional de configuración, pruebas y validación.

## Conclusión

Se diseñó una arquitectura conceptual que separa la información en las áreas de operación, analítica y auditoría.

La propuesta incorpora controles de acceso, minimización, protección de información sensible, retención, trazabilidad, eliminación y atención de derechos ARCO.

La actividad permitió comprender que proteger una base de datos no consiste únicamente en utilizar cifrado o configurar permisos.

También es necesario determinar para qué se utiliza cada dato, quién puede consultarlo, durante cuánto tiempo debe conservarse y cómo deben atenderse las solicitudes de los titulares.

Como DBA, resulta importante traducir las decisiones autorizadas de privacidad y gobierno de datos en mecanismos técnicos adecuados, trabajando de manera coordinada con las áreas responsables.
