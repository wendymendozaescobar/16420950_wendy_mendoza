-- LAB-04
-- Actividad 1: Identificar la superficie de ataque
-- Consultas de solo lectura

SELECT version();

SHOW port;
SHOW listen_addresses;
SHOW ssl;
SHOW password_encryption;

SELECT
    pid,
    usename,
    datname,
    client_addr,
    client_port,
    application_name
FROM pg_stat_activity;
