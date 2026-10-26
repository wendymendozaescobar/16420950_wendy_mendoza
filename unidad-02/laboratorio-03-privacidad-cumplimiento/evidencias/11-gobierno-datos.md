# Actividad 11. Matriz de gobierno de datos

## Objetivo

Diseñar una matriz que permita identificar las finalidades, los responsables y los usuarios autorizados para consultar los principales datos personales almacenados por la organización.

## Procedimiento

Se analizaron los siete campos solicitados en el escenario de Comercializadora Norte S.A. de C.V.

Para cada dato se propuso una finalidad, un área responsable y los departamentos que deberían tener acceso de acuerdo con sus necesidades funcionales.

Se consideraron los principios de minimización, limitación de finalidad y mínimo privilegio.

Las responsabilidades propuestas deben validarse con las áreas correspondientes antes de aplicarse en un entorno real.

## Resultado obtenido

### Matriz de gobierno de datos

| Dato | Finalidad | Responsable propuesto | Usuarios autorizados |
|---|---|---|---|
| Nombre | Identificar al cliente para atención y facturación | Administración de clientes | Atención al cliente y facturación |
| Correo | Comunicaciones relacionadas con la atención del cliente | Atención al cliente | Atención al cliente |
| Teléfono | Contacto y seguimiento de solicitudes | Atención al cliente | Atención al cliente |
| RFC | Identificación fiscal y facturación | Facturación | Personal autorizado de facturación |
| Edad | Elaborar estadísticas por rangos | Responsable de analítica | Analítica, mediante información agrupada |
| Ciudad | Generar estadísticas geográficas y atender necesidades operativas justificadas | Administración de clientes | Analítica mediante resultados agregados; áreas operativas justificadas |
| Código postal | Análisis regional y operaciones justificadas | Administración de clientes | Analítica mediante regiones o agrupaciones; áreas operativas justificadas |

### Justificación de las decisiones

**1. Nombre**

El nombre permite identificar a los clientes durante las actividades de atención y facturación.

Por esta razón, su consulta puede justificarse para ambos departamentos.

Sin embargo, el área de analítica no necesita recibir nombres individuales para elaborar estadísticas.

**2. Correo electrónico**

Se utiliza para mantener comunicación relacionada con la atención al cliente.

Su acceso debe limitarse al personal que necesita utilizarlo para esa finalidad.

El departamento de marketing no debe recibirlo automáticamente para enviar publicidad. Esa finalidad requiere una evaluación independiente.

**3. Teléfono**

Se utiliza para contactar al cliente cuando resulta necesario atender sus solicitudes.

El acceso se asigna a atención al cliente porque corresponde a las funciones descritas en el escenario.

Otros departamentos necesitarían justificar su uso antes de recibir autorización.

**4. RFC**

El RFC se utiliza principalmente para la identificación fiscal y las actividades de facturación.

Por esta razón, se propone que el área de facturación sea responsable de su utilización operativa.

No existe una necesidad funcional en el escenario que justifique entregar el RFC al departamento de analítica o al personal de atención al cliente.

**5. Edad**

Puede utilizarse para clasificar clientes en grupos y generar estadísticas.

El departamento de analítica no necesita necesariamente conocer la edad exacta de cada cliente.

Por ello, se propone utilizar rangos de edad y, cuando sea posible, resultados agregados.

**6. Ciudad**

Puede utilizarse para generar estadísticas geográficas.

Analítica puede trabajar con resultados agrupados por ciudad sin recibir información que identifique directamente a los clientes.

Cualquier acceso individual por parte de otros departamentos debería justificarse mediante una necesidad operativa.

**7. Código postal**

Puede utilizarse para obtener información regional o cumplir determinadas funciones operativas.

Para analítica, se recomienda proporcionar regiones o agrupaciones geográficas cuando sean suficientes para cumplir su finalidad.

No debe considerarse necesario para todos los departamentos únicamente porque está almacenado en la tabla original.

## Análisis

La matriz permite relacionar los datos personales con las responsabilidades funcionales de la organización.

Se identificó que los departamentos requieren diferentes tipos de información para realizar sus actividades.

Atención al cliente necesita principalmente información de identificación y contacto.

Facturación requiere información relacionada con las operaciones fiscales.

Analítica puede utilizar estadísticas sin acceder directamente a identificadores personales.

El DBA debe colaborar implementando los permisos y mecanismos técnicos necesarios, pero no debería decidir individualmente las finalidades del tratamiento.

En el escenario propuesto, los responsables indicados corresponden a áreas funcionales. La organización tendría que definir formalmente quién desempeña el papel de propietario de los datos y quién actúa como responsable del tratamiento conforme al marco aplicable.

## Conclusión

La actividad permitió comprender que el gobierno de datos requiere establecer finalidades, responsabilidades y usuarios autorizados.

No todos los departamentos necesitan consultar toda la información almacenada.

Una matriz de gobierno de datos ayuda a justificar los accesos y a establecer una base para implementar roles, vistas y permisos en PostgreSQL.

También se comprendió que las decisiones organizacionales sobre el uso de información deben distinguirse de las tareas técnicas realizadas por el DBA.
