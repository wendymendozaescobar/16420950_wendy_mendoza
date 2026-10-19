-- ACTIVIDAD 2: ENMASCARAMIENTO DE DATOS

-- Crear el rol soporte.
CREATE ROLE soporte NOLOGIN;

-- Crear una vista que muestre los datos parcialmente ocultos.
CREATE VIEW v_clientes_soporte AS
SELECT
    id,
    nombre,

    CONCAT(
        LEFT(correo, 2),
        '*****',
        SUBSTRING(correo FROM POSITION('@' IN correo))
    ) AS correo,

    CONCAT(
        '******',
        RIGHT(telefono, 4)
    ) AS telefono,

    CONCAT(
        '*********',
        RIGHT(rfc, 4)
    ) AS rfc

FROM clientes;


-- Consultar la vista para comprobar que los datos aparecen enmascarados.
SELECT * FROM v_clientes_soporte;


-- Conceder al rol soporte permiso de uso sobre el esquema public.
GRANT USAGE ON SCHEMA public TO soporte;


-- Permitir que soporte consulte la vista con los datos enmascarados.
GRANT SELECT ON v_clientes_soporte TO soporte;


-- Revocar los permisos directos del rol soporte sobre la tabla original.
REVOKE ALL ON clientes FROM soporte;

-- Verificar los permisos del rol soporte.
-- Cambiar temporalmente al rol soporte para probar sus permisos.
SET ROLE soporte;

-- Comprobar que las consultas se ejecutan con el rol soporte.
SELECT current_user;

-- Comprobar que soporte puede consultar la vista.
SELECT * FROM v_clientes_soporte;

-- Intentar consultar directamente la tabla original.
SELECT * FROM clientes;
