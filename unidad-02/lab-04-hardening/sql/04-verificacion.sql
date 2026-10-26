-- LAB-04: Verificación final de hardening
-- Todas las consultas son de solo lectura.

-- 1. Configuración general del servidor

SELECT
    name AS parametro,
    setting AS valor
FROM pg_settings
WHERE name IN (
    'server_version',
    'port',
    'listen_addresses',
    'ssl',
    'ssl_min_protocol_version',
    'password_encryption',
    'max_connections',
    'superuser_reserved_connections',
    'statement_timeout',
    'idle_in_transaction_session_timeout',
    'log_connections',
    'log_disconnections'
)
ORDER BY name;

-- 2. Reglas de autenticación

SELECT
    type,
    database,
    user_name,
    address,
    auth_method,
    error
FROM pg_hba_file_rules;

-- 3. Roles del laboratorio

SELECT
    rolname,
    rolsuper,
    rolcreaterole,
    rolcreatedb,
    rolcanlogin
FROM pg_roles
WHERE rolname IN (
    'postgres',
    'lab02_tls',
    'analista',
    'soporte'
)
ORDER BY rolname;

-- 4. Extensiones instaladas

SELECT
    extname,
    extversion
FROM pg_extension
ORDER BY extname;

-- 5. Estado TLS de la conexión actual

SELECT
    a.usename,
    a.client_addr,
    s.ssl,
    s.version,
    s.cipher
FROM pg_stat_ssl AS s
JOIN pg_stat_activity AS a
    ON s.pid = a.pid
WHERE s.pid = pg_backend_pid();
