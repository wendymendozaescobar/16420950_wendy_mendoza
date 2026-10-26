# Actividad 1. Protección de credenciales

## Objetivo

Identificar los riesgos de almacenar contraseñas en texto plano
y comprobar cómo protegerlas mediante funciones de hash
en PostgreSQL.

## Procedimiento

Primero se creó una tabla llamada `usuarios_insegura`
y se almacenó una contraseña ficticia en texto plano.

Después se utilizó `crypt()` junto con `gen_salt('bf')`
para generar hashes y comprobar que una misma contraseña
puede producir resultados diferentes.

Posteriormente se creó la tabla `usuarios_segura`,
donde se almacenó el hash de la contraseña.

Finalmente, se realizaron dos pruebas de autenticación:
una con la contraseña correcta y otra con una incorrecta.

Los comandos utilizados se encuentran en
`../sql/01-credenciales.sql`.

## Almacenamiento inseguro de contraseñas

Se creó la tabla `lab02.usuarios_insegura` y se insertó
un usuario con una contraseña ficticia.

### Resultado obtenido

Al consultar la tabla, PostgreSQL mostró:

- Usuario: juan
- Contraseña: Password123
- Registros obtenidos: 1

Esto demuestra que la contraseña se almacenó en texto plano.

### Pregunta de análisis

**¿Qué ocurriría si una persona obtiene acceso de lectura a esta tabla?**

Podría visualizar las contraseñas originales y utilizarlas
para acceder a las cuentas sin autorización.

### Análisis

Almacenar contraseñas en texto plano es inseguro porque
las personas con acceso de lectura pueden conocerlas.

Para protegerlas es necesario utilizar funciones
especializadas de hash de contraseñas.

## 7.3 Generar una representación no reversible

### Resultado

Se ejecutó dos veces la función crypt() con la misma
contraseña ficticia: Password123.

PostgreSQL generó dos hashes diferentes porque
gen_salt('bf') utiliza una sal aleatoria nueva
en cada ejecución.

### Preguntas

**1. ¿Son iguales?**

No. Los dos hashes son diferentes.

**2. Si no son iguales, ¿por qué?**

Porque gen_salt() genera una sal aleatoria distinta
en cada ejecución.

**3. ¿Qué función cumple gen_salt()?**

Genera una sal aleatoria que se utiliza para crear el hash
y dificulta ciertos ataques contra las contraseñas.

**4. ¿Qué función cumple crypt()?**

Genera un hash de la contraseña utilizando el algoritmo
y la sal proporcionados. También permite verificarla.

**5. ¿Esto es cifrado reversible?**

No. Es un hash de contraseña diseñado para verificarla
sin recuperar su valor original.

## 7.4 Crear una tabla para credenciales protegidas

### Resultado

Se creó la tabla `lab02.usuarios_segura` y se insertó
un usuario llamado `juan`.

PostgreSQL confirmó la inserción con `INSERT 0 1`.

Al consultar la tabla, la columna `password_hash`
mostró una cadena que comienza con `$2a$06$`,
en lugar de la contraseña original.

### Análisis

A diferencia de la tabla insegura, la contraseña
no se almacenó directamente.

Se utilizó `crypt()` junto con `gen_salt('bf')`
para generar un hash antes de guardarlo.

Esto permite proteger las contraseñas almacenadas,
aunque sigue siendo necesario restringir el acceso
a la tabla mediante permisos.

## 7.5 Verificar una contraseña

### Resultados

Al verificar la contraseña correcta `Password123`,
PostgreSQL devolvió `t` (verdadero).

Al utilizar la contraseña incorrecta `OtraPassword`,
PostgreSQL devolvió `f` (falso).

### Preguntas

**1. ¿Qué resultado obtuviste con la contraseña correcta?**

Obtuve `t` (verdadero), porque la contraseña ingresada
coincidió con el hash almacenado.

**2. ¿Qué resultado obtuviste con la contraseña incorrecta?**

Obtuve `f` (falso), porque la contraseña ingresada
no coincidió con el hash almacenado.

**3. ¿Por qué no es necesario recuperar la contraseña original?**

Porque podemos verificar la contraseña ingresada
comparando su hash con el que está almacenado,
sin necesidad de conocer la contraseña original.

**4. ¿Por qué un hash no debe confundirse con cifrado?**

Porque el cifrado es reversible cuando se dispone
de la clave correspondiente. En cambio, un hash
de contraseña no está diseñado para recuperar
el texto original.

## Conclusión

Se comprobó que almacenar contraseñas en texto plano
representa un riesgo porque cualquier persona con acceso
de lectura a la tabla podría conocerlas.

Mediante `crypt()` y `gen_salt()` logramos almacenar
una representación protegida de la contraseña.

También comprobamos que es posible verificar una contraseña
sin necesidad de recuperar su valor original.

En una aplicación real utilizaría mecanismos especializados
de hash de contraseñas y controles de acceso adecuados
para proteger las credenciales de los usuarios.
