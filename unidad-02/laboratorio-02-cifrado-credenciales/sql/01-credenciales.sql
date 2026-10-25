-- LAB-02: Cifrado, credenciales y comunicaciones seguras
-- Actividad 1: Protección de credenciales

-- 1. Crear una tabla que almacena contraseñas en texto plano.

CREATE TABLE usuarios_insegura (
    id BIGSERIAL PRIMARY KEY,
    usuario VARCHAR(50) NOT NULL,
    password VARCHAR(100) NOT NULL
);

-- 2. Insertar un usuario con una contraseña ficticia.

INSERT INTO usuarios_insegura (usuario, password)
VALUES ('juan', 'Password123');

-- 3. Consultar los datos para demostrar que la contraseña
-- se almacena sin protección.

SELECT *
FROM usuarios_insegura;

-- Apartado 7.3: Generar una representación no reversible.
-- Ejecutar dos veces para comparar los hashes.

SELECT crypt(
    'Password123',
    gen_salt('bf')
);

SELECT crypt(
    'Password123',
    gen_salt('bf')
);

-- Apartado 7.4: Crear una tabla para credenciales protegidas.

CREATE TABLE usuarios_segura (
    id BIGSERIAL PRIMARY KEY,
    usuario VARCHAR(50) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL
);

INSERT INTO usuarios_segura (usuario, password_hash)
VALUES (
    'juan',
    crypt('Password123', gen_salt('bf'))
);

SELECT *
FROM usuarios_segura;

-- Apartado 7.5: Verificación de contraseñas.

-- Verificar una contraseña correcta.
-- Resultado obtenido: TRUE (t).

SELECT
    usuario,
    password_hash = crypt('Password123', password_hash)
        AS contraseña_correcta
FROM usuarios_segura
WHERE usuario = 'juan';


-- Verificar una contraseña incorrecta.
-- Resultado obtenido: FALSE (f).

SELECT
    usuario,
    password_hash = crypt('OtraPassword', password_hash)
        AS contraseña_correcta
FROM usuarios_segura
WHERE usuario = 'juan';
