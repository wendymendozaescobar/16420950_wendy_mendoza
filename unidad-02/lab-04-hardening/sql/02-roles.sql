-- LAB-04: Hardening y configuración segura
-- Actividad 8: Revisar usuarios y privilegios

-- Consultar roles y atributos.
SELECT
    rolname,
    rolsuper,
    rolinherit,
    rolcreaterole,
    rolcreatedb,
    rolcanlogin
FROM pg_roles
ORDER BY rolname;
