-- ACTIVIDAD 3: SEUDONIMIZACIÓN DE DATOS

-- Crear dos esquemas para separar la información.
CREATE SCHEMA pii;
CREATE SCHEMA analitica;

-- Crear una tabla que relacione los tokens
CREATE TABLE pii.mapa_cliente (
    token UUID PRIMARY KEY,
    cliente_id BIGINT UNIQUE
    REFERENCES public.clientes(id)
);

-- Habilitar la extensión pgcrypto.
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Generar un token UUID para cada cliente y
-- relacionarlo con su identificador original.
INSERT INTO pii.mapa_cliente
(token, cliente_id)
SELECT
    gen_random_uuid(),
    id
FROM clientes;

-- Consultar el mapa de correspondencia.
SELECT * FROM pii.mapa_cliente;

-- Crear el conjunto de datos para analítica.
CREATE TABLE analitica.clientes AS
SELECT
    m.token AS cliente_token,
    c.edad,
    c.ciudad,
    c.codigo_postal,
    c.fecha_alta
FROM pii.mapa_cliente m
JOIN clientes c
ON c.id = m.cliente_id;

-- Consultar la tabla para verificar que contiene
-- los cinco registros con sus respectivos tokens.
SELECT * FROM analitica.clientes;

-- Separación de funciones.
-- Se crea el rol analista sin permiso para iniciar sesión directamente.
CREATE ROLE analista NOLOGIN;

-- Se concede al rol analista permiso para utilizar el esquema analitica.
GRANT USAGE
ON SCHEMA analitica
TO analista;

-- Se permite al rol analista consultar la tabla analitica.clientes.
-- No se conceden permisos sobre pii.mapa_cliente ni public.clientes.
GRANT SELECT
ON analitica.clientes
TO analista;

-- Verificación de permisos.
-- Cambiamos temporalmente al rol analista para comprobar sus permisos.
SET ROLE analista;

-- Comprobamos que estamos utilizando el rol analista.
SELECT current_user;

-- Comprobamos que analista puede consultar los datos seudonimizados.
SELECT * FROM analitica.clientes;

-- Intentamos consultar el mapa de correspondencia.
SELECT * FROM pii.mapa_cliente;

-- Intentamos consultar la tabla original.
SELECT * FROM public.clientes;
