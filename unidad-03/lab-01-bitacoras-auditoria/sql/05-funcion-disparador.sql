-- Unidad 03 - LAB-01
-- Actividad 11: Crear la funcion y el disparador
-- PostgreSQL 18.6
-- Base de datos: comercial
--
-- Este archivo documenta la configuracion realizada.
-- El disparador ya existe; no ejecutar nuevamente
-- CREATE TRIGGER sin comprobar su existencia.

-- 1. Funcion de auditoria

CREATE OR REPLACE FUNCTION auditoria.registrar_cambio_cliente()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN

        INSERT INTO auditoria.cambios_clientes (
            operacion,
            id_cliente,
            valores_despues
        )
        VALUES (
            TG_OP,
            NEW.id,
            to_jsonb(NEW)
        );

        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN

        INSERT INTO auditoria.cambios_clientes (
            operacion,
            id_cliente,
            valores_antes,
            valores_despues
        )
        VALUES (
            TG_OP,
            NEW.id,
            to_jsonb(OLD),
            to_jsonb(NEW)
        );

        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN

        INSERT INTO auditoria.cambios_clientes (
            operacion,
            id_cliente,
            valores_antes
        )
        VALUES (
            TG_OP,
            OLD.id,
            to_jsonb(OLD)
        );

        RETURN OLD;

    END IF;

    RETURN NULL;
END;
$$;

-- 2. Restringir ejecucion publica

REVOKE ALL ON FUNCTION auditoria.registrar_cambio_cliente()
FROM PUBLIC;

-- 3. Crear disparador

CREATE TRIGGER trg_auditoria_clientes
AFTER INSERT OR UPDATE OR DELETE ON clientes
FOR EACH ROW
EXECUTE FUNCTION auditoria.registrar_cambio_cliente();

-- 4. Verificar disparador

SELECT
    tgname,
    tgenabled,
    tgrelid::regclass
FROM pg_trigger
WHERE NOT tgisinternal;

-- 5. Verificar privilegios de ejecucion

SELECT
    has_function_privilege(
        'app_ventas',
        'auditoria.registrar_cambio_cliente()',
        'EXECUTE'
    ) AS app_puede_ejecutar,

    has_function_privilege(
        'soporte_ana',
        'auditoria.registrar_cambio_cliente()',
        'EXECUTE'
    ) AS soporte_puede_ejecutar;

-- 6. Consultar las instrucciones registradas

SELECT
    num,
    LEFT(linea, 230) AS evento
FROM dba.bitacora
WHERE linea ILIKE '%CREATE SCHEMA auditoria%'
   OR linea ILIKE '%CREATE TABLE auditoria.cambios_clientes%'
   OR linea ILIKE '%CREATE OR REPLACE FUNCTION auditoria.registrar_cambio_cliente%'
   OR linea ILIKE '%CREATE TRIGGER trg_auditoria_clientes%'
ORDER BY num;

-- 7. Preguntas de analisis

-- Pregunta 1:
-- REVOKE ALL FROM PUBLIC restringe los permisos
-- de ejecucion directa sobre la funcion.
-- El disparador puede invocarla sin conceder
-- EXECUTE directamente a app_ventas.
-- SECURITY DEFINER permite registrar los eventos
-- con los privilegios del propietario de la funcion.

-- Pregunta 2:
-- Sin SECURITY DEFINER, la funcion se ejecutaria
-- con los privilegios del usuario que modifica clientes.
-- Como app_ventas no tiene INSERT en la tabla
-- de auditoria, la operacion probablemente fallaria.
-- Esta hipotesis se verificara en la Actividad 12.

-- Pregunta 3:
-- Si quedaron registradas las cuatro operaciones:
-- Registro 50: CREATE SCHEMA
-- Registro 52: CREATE TABLE
-- Registro 70: CREATE FUNCTION
-- Registro 127: CREATE TRIGGER
-- Esto ocurre porque log_statement = 'mod'
-- tambien registra instrucciones DDL.
