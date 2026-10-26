-- LAB-03: Privacidad, cumplimiento y gobierno de los datos
-- Actividad 3: Separacion por finalidad
--
-- Objetivo:
-- Generar estadisticas para el area de analitica sin mostrar
-- nombres, correos electronicos, telefonos ni RFC.
--
-- Las consultas son de solo lectura.
-- No modifican ni eliminan registros.


-- =====================================================
-- 1. CANTIDAD DE CLIENTES POR CIUDAD
-- =====================================================

SELECT
    ciudad,
    COUNT(*) AS cantidad_clientes
FROM public.clientes
GROUP BY ciudad
ORDER BY cantidad_clientes DESC;


-- =====================================================
-- 2. CANTIDAD DE CLIENTES POR RANGO DE EDAD
-- =====================================================

SELECT
    CASE
        WHEN edad IS NULL THEN 'No especificada'
        WHEN edad < 18 THEN 'Menor de 18'
        WHEN edad BETWEEN 18 AND 29 THEN '18-29'
        WHEN edad BETWEEN 30 AND 44 THEN '30-44'
        WHEN edad BETWEEN 45 AND 59 THEN '45-59'
        ELSE '60 o mas'
    END AS rango_edad,
    COUNT(*) AS cantidad
FROM public.clientes
GROUP BY
    CASE
        WHEN edad IS NULL THEN 'No especificada'
        WHEN edad < 18 THEN 'Menor de 18'
        WHEN edad BETWEEN 18 AND 29 THEN '18-29'
        WHEN edad BETWEEN 30 AND 44 THEN '30-44'
        WHEN edad BETWEEN 45 AND 59 THEN '45-59'
        ELSE '60 o mas'
    END
ORDER BY rango_edad;


