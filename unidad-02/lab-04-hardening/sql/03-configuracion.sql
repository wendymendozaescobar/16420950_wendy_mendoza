-- LAB-04: Hardening y configuración segura
-- Actividad 10: Revisión de extensiones
-- Consulta de solo lectura

SELECT
    extname,
    extversion
FROM pg_extension
ORDER BY extname;
