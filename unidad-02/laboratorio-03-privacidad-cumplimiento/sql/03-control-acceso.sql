-- LAB-03: Privacidad, cumplimiento y gobierno de los datos
-- Actividad 4: Control de acceso relacionado con la finalidad

-- Objetivo:
-- Permitir que el rol analista consulte informacion preparada
-- para su finalidad sin acceder directamente a public.clientes.

-- El rol analista fue creado durante el LAB-01.
-- No es necesario crearlo nuevamente.

-- =====================================================
-- 1. COMPROBAR EL ROL
-- =====================================================

SELECT
    rolname,
    rolcanlogin,
    rolsuper
FROM pg_roles
WHERE rolname = 'analista';


-- =====================================================
-- 2. CREAR UNA VISTA CON INFORMACION LIMITADA
-- =====================================================

CREATE OR REPLACE VIEW lab03.v_analitica_clientes AS
SELECT
    ciudad,
    CASE
        WHEN edad IS NULL THEN 'No especificada'
        WHEN edad < 18 THEN 'Menor de 18'
        WHEN edad BETWEEN 18 AND 29 THEN '18-29'
        WHEN edad BETWEEN 30 AND 44 THEN '30-44'
        WHEN edad BETWEEN 45 AND 59 THEN '45-59'
        ELSE '60 o más'
    END AS rango_edad
FROM public.clientes;


-- =====================================================
-- 3. OTORGAR PERMISOS
-- =====================================================

GRANT USAGE ON SCHEMA lab03 TO analista;

GRANT SELECT
ON lab03.v_analitica_clientes
TO analista;


-- =====================================================
-- 4. VERIFICAR LOS PERMISOS ASIGNADOS
-- =====================================================

SELECT
    grantee,
    table_schema,
    table_name,
    privilege_type
FROM information_schema.role_table_grants
WHERE grantee = 'analista'
ORDER BY table_schema, table_name, privilege_type;


-- =====================================================
-- 5. COMPROBAR LOS PERMISOS EFECTIVOS
-- =====================================================

SELECT
    has_table_privilege(
        'analista',
        'lab03.v_analitica_clientes',
        'SELECT'
    ) AS puede_consultar_vista,

    has_table_privilege(
        'analista',
        'public.clientes',
        'SELECT'
    ) AS puede_consultar_tabla_original;


-- =====================================================
-- 6. PROBAR LA CONSULTA CON EL ROL ANALISTA
-- =====================================================

SET ROLE analista;

SELECT *
FROM lab03.v_analitica_clientes
LIMIT 5;

RESET ROLE;
