-- Unidad 03 - LAB-01
-- Actividad 10: Diseñar y crear el registro de auditoria
-- PostgreSQL 18.6
-- Base de datos: comercial
--
-- Este archivo documenta la estructura creada.
-- No volver a ejecutarlo en la misma base de datos
-- porque el esquema y la tabla ya existen.

-- 1. Crear el esquema de auditoria

CREATE SCHEMA auditoria;

-- 2. Restringir los permisos publicos

REVOKE ALL ON SCHEMA auditoria FROM PUBLIC;

-- 3. Crear la tabla de auditoria

CREATE TABLE auditoria.cambios_clientes (
    id_evento        BIGSERIAL PRIMARY KEY,
    momento          TIMESTAMPTZ NOT NULL DEFAULT now(),
    usuario_sesion   TEXT        NOT NULL DEFAULT session_user,
    usuario_efectivo TEXT        NOT NULL DEFAULT current_user,
    aplicacion       TEXT        DEFAULT current_setting('application_name'),
    ip_cliente       INET        DEFAULT inet_client_addr(),
    operacion        TEXT        NOT NULL,
    id_cliente       BIGINT,
    valores_antes    JSONB,
    valores_despues  JSONB
);

-- 4. Verificar que la tabla comienza vacia

SELECT COUNT(*)
FROM auditoria.cambios_clientes;
