# LAB-03. Privacidad, cumplimiento y gobierno de los datos

## 1. Introducción

Este laboratorio aborda la importancia de administrar los datos personales conforme a finalidades definidas y necesidades justificadas.

Se utilizará PostgreSQL para analizar aspectos relacionados con privacidad, minimización, controles de acceso, derechos ARCO, retención y gobierno de datos.

El escenario corresponde a una empresa ficticia que administra información de clientes.

## 2. Inventario y finalidad de los datos

Se identificaron nueve campos de la tabla `public.clientes` y se analizaron sus finalidades, necesidades, niveles de acceso y criterios de retención.

Se determinó que no todas las áreas necesitan consultar todos los datos.

El área de atención al cliente requiere principalmente información de identificación y contacto, mientras que facturación necesita información fiscal y analítica puede trabajar con resultados agregados.

### Evidencia

- [Inventario y finalidad de los datos](evidencias/01-inventario-datos.md)
