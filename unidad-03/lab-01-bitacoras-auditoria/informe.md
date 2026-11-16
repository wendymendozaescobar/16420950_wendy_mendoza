## Actividad 16 — Exportación y conservación de la bitácora

Se exportó la bitácora vigente de PostgreSQL 18.6, correspondiente a la base de datos `comercial`, utilizando `pg_current_logfile()` y `pg_read_file()`.

Durante la exportación se sustituyó la contraseña de práctica por `<REDACTED>`.

Posteriormente se preparó una copia para el repositorio público, ocultando RFC y correos ficticios identificados durante la revisión.

El archivo resultante, `evidencias/bitacora-lab01.log`, contenía 210 líneas antes de las sustituciones finales.

Se calculó su resumen criptográfico mediante SHA-256 y se guardó en `evidencias/bitacora-lab01.sha256`.

Después de las sustituciones, se volvió a calcular el resumen. La comprobación con `sha256sum -c` devolvió el resultado **«La suma coincide»**.

### 1. ¿SHA-256 impide modificar la bitácora?

No. SHA-256 no impide modificar un archivo. Permite comprobar si su contenido coincide con el resumen criptográfico calculado anteriormente.

Si el archivo cambia, su hash normalmente también cambia. Para que esta comprobación sea confiable, el resumen original debe conservarse de forma segura.

### 2. ¿Dónde debería guardarse el hash?

En una ubicación independiente y protegida, preferentemente administrada por un área distinta de la responsable del servidor PostgreSQL.

Esto reduce el riesgo de que alguien modifique tanto la bitácora como su resumen criptográfico.

### 3. ¿Qué riesgos existen al conservar la bitácora únicamente en el servidor que la produce?

Según los principios de protección y gestión de registros tratados en NIST SP 800-92, conservar las bitácoras únicamente en el servidor de origen presenta riesgos como pérdida de evidencias, alteraciones por usuarios privilegiados, fallas del equipo y eliminación durante la rotación de archivos.

Por ello, conviene conservar copias independientes y aplicar controles de acceso, integridad y disponibilidad.

### 4. ¿Durante cuánto tiempo conservarías la bitácora?

Para este escenario académico propondría una conservación de 12 meses, sujeta a las necesidades de investigación y a las políticas institucionales.

En un entorno real, el periodo debe determinarse considerando los requisitos legales, la clasificación de la información, las necesidades operativas y los riesgos de seguridad.

El plazo propuesto no representa una obligación universal.

### Conclusión

La actividad permitió comprender la importancia de preservar las evidencias generadas por PostgreSQL.

Se exportó una copia de la bitácora, se ocultó información identificada durante la revisión y se verificó su integridad mediante SHA-256.

También se comprendió que la protección de evidencias requiere controles adicionales, como almacenamiento independiente, restricciones de acceso y políticas de conservación.
