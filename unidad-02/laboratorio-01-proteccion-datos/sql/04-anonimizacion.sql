-- ACTIVIDAD 4: ANONIMIZACIÓN DE DATOS


-- Generalizar la edad.
SELECT
    CASE
        WHEN edad BETWEEN 18 AND 30 THEN '18-30'
        WHEN edad BETWEEN 31 AND 45 THEN '31-45'
        ELSE '46+'
    END AS rango_edad,
    COUNT(*) AS total
FROM clientes
GROUP BY 1;

-- Generalizar la región.
SELECT
    LEFT(codigo_postal, 2) AS region,
    COUNT(*) AS total
FROM clientes
GROUP BY 1;

-- Combinar atributos
SELECT
    CASE
        WHEN edad BETWEEN 18 AND 30 THEN '18-30'
        WHEN edad BETWEEN 31 AND 45 THEN '31-45'
        ELSE '46+'
    END AS rango_edad,
    LEFT(codigo_postal, 2) AS region,
    COUNT(*) AS total
FROM clientes
GROUP BY 1, 2;

-- 12.4 Suprimir grupos pequeños.
SELECT
    CASE
        WHEN edad BETWEEN 18 AND 30 THEN '18-30'
        WHEN edad BETWEEN 31 AND 45 THEN '31-45'
        ELSE '46+'
    END AS rango_edad,
    LEFT(codigo_postal, 2) AS region,
    COUNT(*) AS total
FROM clientes
GROUP BY 1, 2
HAVING COUNT(*) >= 5;

-- 13. Reto: Reducir el riesgo de reidentificación.
SELECT
    CASE
        WHEN edad BETWEEN 18 AND 60 THEN '18-60'
        ELSE 'Otro rango'
    END AS rango_edad,
    LEFT(codigo_postal, 1) AS region,
    COUNT(*) AS total
FROM clientes
GROUP BY 1, 2
HAVING COUNT(*) >= 5;