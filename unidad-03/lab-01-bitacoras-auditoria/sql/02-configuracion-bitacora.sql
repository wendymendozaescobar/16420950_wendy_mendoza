-- Unidad 03 - LAB-01
-- Actividad 4: Configurar la bitacora
-- PostgreSQL 18.6 - Puerto 5433
-- Base de datos: comercial
--
-- Registro de los comandos ya ejecutados.
-- No es necesario volver a aplicar la configuracion.

-- 1. Registrar conexiones
ALTER SYSTEM SET log_connections = on;

-- 2. Registrar desconexiones
ALTER SYSTEM SET log_disconnections = on;

-- 3. Identificar usuario, base de datos, aplicacion y cliente
ALTER SYSTEM SET log_line_prefix =
'%m [%p] user=%u db=%d app=%a client=%h ';

-- 4. Registrar operaciones DDL
ALTER SYSTEM SET log_statement = 'ddl';

-- 5. Recargar la configuracion
SELECT pg_reload_conf();

-- 6. Verificar los parametros
-- Los parametros superuser-backend deben revisarse
-- desde una nueva sesion.

SELECT
    name,
    setting,
    source,
    context,
    pending_restart
FROM pg_settings
WHERE name IN (
    'log_connections',
    'log_disconnections',
    'log_line_prefix',
    'log_statement'
)
ORDER BY name;

-- 7. Consultar los eventos recientes

SELECT
    num,
    LEFT(linea, 200) AS evento
FROM dba.bitacora
ORDER BY num DESC
LIMIT 15;

-- 8. Buscar desconexiones

SELECT
    num,
    LEFT(linea, 220) AS evento
FROM dba.bitacora
WHERE linea ILIKE '%desconex%'
   OR linea ILIKE '%disconnection%'
ORDER BY num DESC
LIMIT 10;
