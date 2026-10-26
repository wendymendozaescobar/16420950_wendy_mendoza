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
