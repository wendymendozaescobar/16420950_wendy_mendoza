-- LAB-03: Privacidad, cumplimiento y gobierno de los datos
-- Actividad 2: Principio de minimizacion

-- 1. Preparar esquema independiente.
CREATE SCHEMA IF NOT EXISTS lab03;

-- 2. Crear tabla con los datos necesarios para soporte.
CREATE TABLE IF NOT EXISTS lab03.clientes_soporte (
    id BIGINT PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    correo VARCHAR(150) NOT NULL,
    telefono VARCHAR(20)
);

-- 3. Cargar solamente las columnas necesarias.
INSERT INTO lab03.clientes_soporte (
    id,
    nombre,
    correo,
    telefono
)
SELECT
    id,
    nombre,
    correo,
    telefono
FROM public.clientes
ON CONFLICT (id) DO NOTHING;

-- 4. Consultar los datos preparados para soporte.
SELECT *
FROM lab03.clientes_soporte;

-- 5. Comparar cantidades de registros.
SELECT
    (SELECT COUNT(*) FROM public.clientes)
        AS clientes_originales,
    (SELECT COUNT(*) FROM lab03.clientes_soporte)
        AS clientes_soporte;
