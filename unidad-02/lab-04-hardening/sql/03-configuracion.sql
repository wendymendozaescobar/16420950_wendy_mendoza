-- LAB-04: Hardening y configuración segura
-- Actividad 10: Revisión de extensiones
-- Consulta de solo lectura

SELECT
    extname,
    extversion
FROM pg_extension
ORDER BY extname;

-- Actividad 11: Revisar configuración de conexiones
-- Consultas de solo lectura

SHOW max_connections;
SHOW superuser_reserved_connections;
SHOW statement_timeout;
SHOW idle_in_transaction_session_timeout;

-- Actividad 15: Verificar configuración TLS
-- Consultas de solo lectura

SHOW ssl;
SHOW ssl_min_protocol_version;

-- Comprobar si la conexión actual utiliza TLS

SELECT
    a.pid,
    a.usename,
    a.client_addr,
    s.ssl,
    s.version,
    s.cipher
FROM pg_stat_ssl AS s
JOIN pg_stat_activity AS a
    ON s.pid = a.pid
WHERE s.pid = pg_backend_pid();
