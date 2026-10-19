-- ACTIVIDAD 5: RETENCIÓN DE DATOS
-- CURRENT_DATE obtiene la fecha actual.
-- INTERVAL '5 years' representa un periodo de cinco años.
-- WHERE selecciona los clientes cuya fecha de alta
-- es anterior a ese periodo.

SELECT *
FROM clientes
WHERE fecha_alta <
CURRENT_DATE - INTERVAL '5 years';

-- Resultado obtenido: 0 filas.