-- Unidad 03 - LAB-01
-- Actividad 6: Cambios de privilegios y estructura
-- PostgreSQL 18.6 | Puerto 5433 | Base de datos comercial
--
-- Registro de las instrucciones realizadas en la practica.
-- No ejecutar nuevamente el archivo completo:
-- la columna segmento ya existe.

-- 1. Revocacion preventiva de privilegios.
REVOKE UPDATE ON clientes FROM soporte_ana;

-- 2. Confirmacion del privilegio de actualizacion.
GRANT UPDATE ON clientes TO app_ventas;

-- 3. Modificacion de la estructura de clientes.
ALTER TABLE clientes
ADD COLUMN segmento VARCHAR(20);

-- 4. Experimento con un rol temporal.
-- Se creo un rol utilizando una contrasena ficticia.
-- La sentencia quedo registrada en texto claro.
--
-- Sentencia documentada con la contrasena redactada:
-- CREATE ROLE rol_temporal LOGIN PASSWORD '[REDACTADA]';
--
-- Posteriormente se elimino:
-- DROP ROLE rol_temporal;
--
-- Ambas operaciones ya fueron ejecutadas.
-- No se incluye la contrasena original por seguridad.

-- 5. Verificar si el rol temporal existe.
SELECT
    rolname,
    rolcanlogin
FROM pg_roles
WHERE rolname = 'rol_temporal';

-- 6. Buscar las sentencias registradas.
-- Se redacta cualquier contrasena antes de mostrarla.

SELECT
    num,
    regexp_replace(
        linea,
        '(PASSWORD\s+)''[^'']*''',
        '\1''[REDACTADA]''',
        'gi'
    ) AS evento
FROM dba.bitacora
WHERE linea ILIKE '%rol_temporal%'
ORDER BY num;
