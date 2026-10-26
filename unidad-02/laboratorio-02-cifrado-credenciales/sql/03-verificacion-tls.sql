-- LAB-02: Cifrado, credenciales y comunicaciones seguras
-- Actividad 5: Verificacion del estado de TLS

-- Consultar la configuracion del servidor.

SHOW ssl;

SHOW ssl_min_protocol_version;

SHOW port;

SHOW listen_addresses;

-- Identificar el origen de la conexion.

SELECT
    inet_client_addr(),
    inet_client_port();

-- Comprobar si la sesion actual utiliza TLS.

SELECT
    ssl,
    version,
    cipher
FROM pg_stat_ssl
WHERE pid = pg_backend_pid();

-- Actividad 6: Verificar una conexion TCP/IP protegida con TLS.
-- Conexion realizada con el usuario lab02_tls y sslmode=require.

SELECT
    current_user,
    inet_client_addr(),
    inet_client_port();

SELECT
    ssl,
    version,
    cipher
FROM pg_stat_ssl
WHERE pid = pg_backend_pid();
