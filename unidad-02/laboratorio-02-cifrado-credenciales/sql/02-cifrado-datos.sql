-- LAB-02: Cifrado, credenciales y comunicaciones seguras
-- Actividad 2: Cifrado de información sensible

-- Esquema utilizado para aislar las tablas de este laboratorio.
CREATE SCHEMA IF NOT EXISTS lab02;

SET search_path TO lab02, public;

-- Requiere la extension pgcrypto para usar pgp_sym_encrypt()
-- y pgp_sym_decrypt().
-- Ejecutar el archivo completo en una base de prueba limpia.
-- Los valores utilizados en este laboratorio son ficticios.

-- 8.1 Crear una tabla para almacenar datos cifrados.

CREATE TABLE clientes_protegidos (
    id BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    rfc_cifrado BYTEA NOT NULL
);

-- Insertar un cliente con su RFC cifrado.
-- Se utilizan datos y una clave ficticios.

INSERT INTO clientes_protegidos (nombre, rfc_cifrado)
VALUES (
    'Ana López',
    pgp_sym_encrypt('LOPA900101ABC', 'CLAVE-DE-PRUEBA')
);

-- Consultar la información almacenada.

SELECT *
FROM clientes_protegidos;


-- 8.2 Recuperar el dato original con la clave correcta.

SELECT
    id,
    nombre,
    pgp_sym_decrypt(
        rfc_cifrado,
        'CLAVE-DE-PRUEBA'
    ) AS rfc
FROM clientes_protegidos;


-- Prueba adicional realizada con una clave incorrecta.
-- Esta consulta produce un error de descifrado.
-- Se conserva comentada para evitar errores al reutilizar el script.

-- SELECT
--     id,
--     nombre,
--     pgp_sym_decrypt(
--         rfc_cifrado,
--         'CLAVE-INCORRECTA'
--     ) AS rfc
-- FROM clientes_protegidos;
