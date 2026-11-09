-- Unidad 03 - LAB-01
-- Actividad 2: Colector de bitacoras y vista de auditoria
-- PostgreSQL 18.6 - Base de datos comercial
--
-- Registro de las instrucciones utilizadas en la actividad.
-- No ejecutar nuevamente el archivo completo sobre la
-- base comercial, porque el esquema y la vista ya existen.

-- 1. Activar el colector de bitacoras
-- Este cambio requirio reiniciar PostgreSQL 18.

ALTER SYSTEM SET logging_collector = on;

-- 2. Verificar la configuracion

SELECT
    name,
    setting,
    source,
    pending_restart
FROM pg_settings
WHERE name = 'logging_collector';

-- 3. Identificar el archivo de bitacora vigente

SELECT pg_current_logfile();

-- 4. Crear el esquema administrativo

CREATE SCHEMA dba;

REVOKE ALL ON SCHEMA dba FROM PUBLIC;

-- 5. Crear la vista de bitacora

CREATE VIEW dba.bitacora AS
SELECT
    t.n AS num,
    t.linea
FROM regexp_split_to_table(
    pg_read_file(pg_current_logfile()),
    E'\n'
) WITH ORDINALITY AS t(linea, n)
WHERE t.linea <> '';

-- 6. Consultar las ultimas diez lineas

SELECT
    num,
    linea
FROM dba.bitacora
ORDER BY num DESC
LIMIT 10;

-- 7. Verificar los permisos de acceso

SELECT
    rolname,
    has_schema_privilege(
        rolname, 'dba', 'USAGE'
    ) AS acceso_esquema,
    has_table_privilege(
        rolname, 'dba.bitacora', 'SELECT'
    ) AS puede_consultar
FROM pg_roles
WHERE rolname IN ('app_ventas', 'soporte_ana')
ORDER BY rolname;

-- 8. Buscar operaciones UPDATE

SELECT
    num,
    LEFT(linea, 160) AS evento
FROM dba.bitacora
WHERE linea ILIKE '%update%'
ORDER BY num DESC
LIMIT 10;

-- 9. Buscar errores

SELECT
    num,
    LEFT(linea, 160) AS evento
FROM dba.bitacora
WHERE linea ~ '(FATAL|ERROR)'
ORDER BY num DESC
LIMIT 10;
