--------------------------------------------------------------------------------
--	Jose Barrera, 15-10123
--	Maria Magallanes, 13-10787
--------------------------------------------------------------------------------

--	Eliminamos la BD si existe
DROP DATABASE IF EXISTS bd_team5;

--	Creamos la BD
CREATE DATABASE bd_team5;

--	Nos conectamos a la BD
\c bd_team5;

--	Cargamos los datos en dos tablas temporales
CREATE TABLE IF NOT EXISTS temp_nomina(
	id_nomina SERIAL PRIMARY KEY,
	id_tno SMALLINT,
	tno CHAR(5),
	estatus VARCHAR(8),
	id_sede SMALLINT,
	nombre_sede VARCHAR(20),
	nacionalidad CHAR(1),
	documento_identidad_personal INT,
	apellido_personal VARCHAR(64),
	nombre_personal VARCHAR(64),
	genero_personal VARCHAR(16),
	fecha_ingreso_personal DATE,
	id_cargo INT,
	nombre_cargo VARCHAR(64),
	id_autoridad SMALLINT,
	nombre_autoridad VARCHAR(64),
	id_departamento SMALLINT,
	nombre_departamento VARCHAR(70)
);

\COPY temp_nomina(id_tno, tno, estatus, id_sede, nombre_sede, nacionalidad, documento_identidad_personal, apellido_personal, nombre_personal, genero_personal, fecha_ingreso_personal, id_cargo, nombre_cargo, id_autoridad, nombre_autoridad, id_departamento, nombre_departamento) FROM 'Nomina Empleados Sartenejas.csv' DELIMITER ',' CSV HEADER

CREATE TABLE IF NOT EXISTS temp_censo(
	id_censo SERIAL PRIMARY KEY,
	documento_identidad_personal INT,
	nombre_completo_personal VARCHAR(127),
	medio_transporte VARCHAR(64),
	zona_residencia VARCHAR(64),
	relacion VARCHAR(32),
	hora_lunes VARCHAR(32),
	hora_martes VARCHAR(32),
	hora_miercoles VARCHAR(32),
	hora_jueves VARCHAR(32),
	hora_viernes VARCHAR(32),
	nombre_sede VARCHAR(20),
	tipo_ruta VARCHAR(32),
	nombre_ruta VARCHAR(32),
	tiempo_llegada VARCHAR(20) NOT NULL
);

\COPY temp_censo(documento_identidad_personal, nombre_completo_personal, medio_transporte, zona_residencia, relacion, hora_lunes, hora_martes, hora_miercoles, hora_jueves, hora_viernes, nombre_sede, tipo_ruta, nombre_ruta, tiempo_llegada) FROM 'Censo Empleados.csv' DELIMITER ',' CSV HEADER

--	Creamos cada tabla
CREATE TABLE IF NOT EXISTS estado_personal(
	id_estado_personal SERIAL PRIMARY KEY,
	nombre_estado_personal VARCHAR(64)
);

CREATE TABLE IF NOT EXISTS tipo_personal(
	id_tipo_personal SMALLINT PRIMARY KEY,
	nombre_tipo_personal VARCHAR(64) NOT NULL
);

CREATE TABLE IF NOT EXISTS genero_personal(
	id_genero_personal SERIAL PRIMARY KEY,
	nombre_genero_personal VARCHAR(16)
);

CREATE TABLE IF NOT EXISTS medio_transporte(
	id_medio_transporte SERIAL PRIMARY KEY,
	nombre_medio_transporte VARCHAR(64) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS zona_residencia(
	id_zona_residencia SERIAL PRIMARY KEY,
	nombre_zona_residencia VARCHAR(64) NOT NULL
);

CREATE TABLE IF NOT EXISTS horas_estandar(
	id_horas_estandar SERIAL PRIMARY KEY,
	nombre_horas_estandar VARCHAR(32) UNIQUE
);

CREATE TABLE IF NOT EXISTS tiempo_llegada(
	id_tiempo_llegada SERIAL PRIMARY KEY,
	nombre_tiempo_llegada VARCHAR(32) NOT NULL
);

CREATE TABLE IF NOT EXISTS tipo_ruta(
	id_tipo_ruta SERIAL PRIMARY KEY,
	nombre_tipo_ruta VARCHAR(32) NOT NULL
);

CREATE TABLE IF NOT EXISTS cargo(
	id_cargo SMALLINT PRIMARY KEY,
	nombre_cargo VARCHAR(64) NOT NULL
);

CREATE TABLE IF NOT EXISTS sede(
	id_sede SMALLINT PRIMARY KEY,
	nombre_sede VARCHAR(64) NOT NULL
);

CREATE TABLE IF NOT EXISTS departamento(
	id_departamento SMALLINT PRIMARY KEY,
	nombre_departamento VARCHAR(70) NOT NULL,
	sede SMALLINT,
	FOREIGN KEY (sede) REFERENCES sede(id_sede)
);

CREATE TABLE IF NOT EXISTS autoridad(
	id_autoridad SMALLINT PRIMARY KEY,
	nombre_autoridad VARCHAR(64) NOT NULL,
	sede SMALLINT,
	FOREIGN KEY (sede) REFERENCES sede(id_sede)
);

CREATE TABLE IF NOT EXISTS ruta(
	id_ruta SERIAL PRIMARY KEY,
	nombre_ruta VARCHAR(64) NOT NULL,
	sede SMALLINT,
	FOREIGN KEY (sede) REFERENCES sede(id_sede)
);

CREATE TABLE IF NOT EXISTS personal(
	nacionalidad CHAR(1) NOT NULL,
	documento_identidad_personal INT NOT NULL,
	nombre_personal VARCHAR(64) NOT NULL,
	apellido_personal VARCHAR(64) NOT NULL,
	fecha_ingreso_personal DATE NOT NULL,
	genero_personal SMALLINT,
	FOREIGN KEY (genero_personal) REFERENCES genero_personal(id_genero_personal),
	sede SMALLINT,
	FOREIGN KEY (sede) REFERENCES sede(id_sede),
	autoridad SMALLINT,
	FOREIGN KEY (autoridad) REFERENCES autoridad(id_autoridad),
	departamento SMALLINT,
	FOREIGN KEY (departamento) REFERENCES departamento(id_departamento),
	cargo SMALLINT,
	FOREIGN KEY (cargo) REFERENCES cargo(id_cargo),
	tipo_personal SMALLINT,
	FOREIGN KEY (tipo_personal) REFERENCES tipo_personal(id_tipo_personal),
	estado_personal SMALLINT,
	FOREIGN KEY (estado_personal) REFERENCES estado_personal(id_estado_personal),
	PRIMARY KEY(nacionalidad, documento_identidad_personal)
);

CREATE TABLE IF NOT EXISTS censo(
	id_censo SERIAL PRIMARY KEY,
	nacionalidad CHAR(1) NOT NULL,
	documento_identidad_personal INT NOT NULL,
	FOREIGN KEY (nacionalidad,documento_identidad_personal) REFERENCES personal(nacionalidad, documento_identidad_personal),
	medio_transporte SMALLINT,
	FOREIGN KEY (medio_transporte) REFERENCES medio_transporte(id_medio_transporte),
	zona_residencia SMALLINT,
	FOREIGN KEY (zona_residencia) REFERENCES zona_residencia(id_zona_residencia),
	tipo_ruta SMALLINT,
	FOREIGN KEY (tipo_ruta) REFERENCES tipo_ruta(id_tipo_ruta),
	ruta SMALLINT,
	FOREIGN KEY (ruta) REFERENCES ruta(id_ruta),
	tiempo_llegada SMALLINT,
	FOREIGN KEY (tiempo_llegada) REFERENCES tiempo_llegada(id_tiempo_llegada),
	hora_lunes SMALLINT,
	FOREIGN KEY (hora_lunes) REFERENCES horas_estandar(id_horas_estandar),
	hora_martes SMALLINT,
	FOREIGN KEY (hora_martes) REFERENCES horas_estandar(id_horas_estandar),
	hora_miercoles SMALLINT,
	FOREIGN KEY (hora_miercoles) REFERENCES horas_estandar(id_horas_estandar),
	hora_jueves SMALLINT,
	FOREIGN KEY (hora_jueves) REFERENCES horas_estandar(id_horas_estandar),
	hora_viernes SMALLINT,
	FOREIGN KEY (hora_viernes) REFERENCES horas_estandar(id_horas_estandar)
);

--	Cambiamos todos los valores null por NR (no responde)
UPDATE temp_censo
	SET hora_lunes = COALESCE(hora_lunes, 'NR'),
		hora_martes = COALESCE(hora_martes, 'NR'),
		hora_miercoles = COALESCE(hora_miercoles, 'NR'),
		hora_jueves = COALESCE(hora_jueves, 'NR'),
		hora_viernes = COALESCE(hora_viernes, 'NR'),
		tipo_ruta = COALESCE(tipo_ruta, 'NR'),
		nombre_ruta = COALESCE(nombre_ruta, 'NR');

--	Extraemos la data de la temporal a donde corresponda
\echo 'llenando estado_personal'
INSERT INTO estado_personal (nombre_estado_personal)
SELECT DISTINCT estatus
FROM temp_nomina;

--SELECT * FROM estado_personal;

\echo 'llenando tipo_personal'
INSERT INTO tipo_personal (id_tipo_personal, nombre_tipo_personal)
SELECT DISTINCT id_tno, tno
FROM temp_nomina;

--SELECT * FROM tipo_personal;

\echo 'llenando genero_personal'
INSERT INTO genero_personal (nombre_genero_personal)
SELECT DISTINCT genero_personal
FROM temp_nomina;

--SELECT * FROM genero_personal;

\echo 'llenando medio_transporte'
INSERT INTO medio_transporte (nombre_medio_transporte)
SELECT DISTINCT medio_transporte
FROM temp_censo
ON CONFLICT DO NOTHING;

--SELECT * FROM medio_transporte;

\echo 'llenando zona_residencia'
INSERT INTO zona_residencia (nombre_zona_residencia)
SELECT DISTINCT zona_residencia
FROM temp_censo;

--SELECT * FROM zona_residencia;

\echo 'llenando horas_estandar'
INSERT INTO horas_estandar (nombre_horas_estandar)
SELECT DISTINCT hora_lunes
FROM temp_censo;

INSERT INTO horas_estandar (nombre_horas_estandar)
SELECT DISTINCT hora_martes
FROM temp_censo
ON CONFLICT DO NOTHING;

INSERT INTO horas_estandar (nombre_horas_estandar)
SELECT DISTINCT hora_miercoles
FROM temp_censo
ON CONFLICT DO NOTHING;

INSERT INTO horas_estandar (nombre_horas_estandar)
SELECT DISTINCT hora_jueves
FROM temp_censo
ON CONFLICT DO NOTHING;

INSERT INTO horas_estandar (nombre_horas_estandar)
SELECT DISTINCT hora_viernes
FROM temp_censo
ON CONFLICT DO NOTHING;

--SELECT * FROM horas_estandar;

\echo 'llenando tiempo_llegada'
INSERT INTO tiempo_llegada (nombre_tiempo_llegada)
SELECT DISTINCT tiempo_llegada
FROM temp_censo;

--SELECT * FROM tiempo_llegada;

\echo 'llenando tipo_ruta'
INSERT INTO tipo_ruta (nombre_tipo_ruta)
SELECT DISTINCT tipo_ruta
FROM temp_censo;

--SELECT * FROM tipo_ruta;

\echo 'llenando cargo'
INSERT INTO cargo
SELECT DISTINCT id_cargo, nombre_cargo
FROM temp_nomina
ORDER BY id_cargo;

--SELECT * FROM cargo;

\echo 'llenando sede'
INSERT INTO sede
SELECT DISTINCT id_sede, nombre_sede
FROM temp_nomina
ORDER BY id_sede;

--SELECT * FROM sede;

\echo 'llenando departamento'
INSERT INTO departamento
SELECT DISTINCT id_departamento, nombre_departamento, id_sede
FROM temp_nomina
ORDER BY id_departamento;

--SELECT * FROM departamento;

\echo 'llenando autoridad'
INSERT INTO autoridad
SELECT DISTINCT id_autoridad, nombre_autoridad, id_sede
FROM temp_nomina
ORDER BY id_autoridad;

--ELECT * FROM autoridad;

\echo 'llenando ruta'
INSERT INTO ruta (nombre_ruta, sede)
SELECT DISTINCT censo.nombre_ruta, nomina.id_sede
FROM temp_nomina as nomina JOIN temp_censo as censo ON censo.documento_identidad_personal = nomina.documento_identidad_personal
WHERE censo.nombre_ruta IS NOT NULL;

--SELECT * FROM ruta;

\echo 'llenando personal'
INSERT INTO personal
SELECT DISTINCT ON (temp_nomina.nacionalidad, temp_nomina.documento_identidad_personal) temp_nomina.nacionalidad, temp_nomina.documento_identidad_personal, temp_nomina.nombre_personal, temp_nomina.apellido_personal, temp_nomina.fecha_ingreso_personal, genero_personal.id_genero_personal, sede.id_sede, autoridad.id_autoridad, departamento.id_departamento, cargo.id_cargo, tipo_personal.id_tipo_personal, estado_personal.id_estado_personal
FROM (((((((temp_nomina
INNER JOIN genero_personal ON temp_nomina.genero_personal = genero_personal.nombre_genero_personal)
INNER JOIN sede ON temp_nomina.id_sede = sede.id_sede)
INNER JOIN autoridad ON temp_nomina.id_autoridad = autoridad.id_autoridad)
INNER JOIN departamento ON temp_nomina.id_departamento = departamento.id_departamento)
INNER JOIN cargo ON temp_nomina.id_cargo = cargo.id_cargo)
INNER JOIN tipo_personal ON temp_nomina.id_tno = tipo_personal.id_tipo_personal)
INNER JOIN estado_personal ON temp_nomina.estatus = estado_personal.nombre_estado_personal);

--SELECT * FROM personal;

\echo 'llenando censo'
INSERT INTO censo (nacionalidad, documento_identidad_personal, medio_transporte, zona_residencia, tipo_ruta, ruta, tiempo_llegada, hora_lunes, hora_martes, hora_miercoles, hora_jueves, hora_viernes)
SELECT DISTINCT ON (temp_nomina.nacionalidad, temp_nomina.documento_identidad_personal) temp_nomina.nacionalidad, temp_nomina.documento_identidad_personal, medio_transporte.id_medio_transporte, zona_residencia.id_zona_residencia, tipo_ruta.id_tipo_ruta, ruta.id_ruta, tiempo_llegada.id_tiempo_llegada, lunes.id_horas_estandar, martes.id_horas_estandar, miercoles.id_horas_estandar, jueves.id_horas_estandar, viernes.id_horas_estandar
FROM (((((((((((temp_censo
INNER JOIN temp_nomina ON temp_censo.documento_identidad_personal = temp_nomina.documento_identidad_personal)
INNER JOIN medio_transporte ON temp_censo.medio_transporte = medio_transporte.nombre_medio_transporte)
INNER JOIN zona_residencia ON temp_censo.zona_residencia = zona_residencia.nombre_zona_residencia)
INNER JOIN tipo_ruta ON temp_censo.tipo_ruta = tipo_ruta.nombre_tipo_ruta)
INNER JOIN ruta ON temp_censo.nombre_ruta = ruta.nombre_ruta)
INNER JOIN tiempo_llegada ON temp_censo.tiempo_llegada = tiempo_llegada.nombre_tiempo_llegada)
INNER JOIN horas_estandar as lunes ON temp_censo.hora_lunes = lunes.nombre_horas_estandar)
INNER JOIN horas_estandar as martes ON temp_censo.hora_martes = martes.nombre_horas_estandar)
INNER JOIN horas_estandar as miercoles ON temp_censo.hora_miercoles = miercoles.nombre_horas_estandar)
INNER JOIN horas_estandar as jueves ON temp_censo.hora_jueves = jueves.nombre_horas_estandar)
INNER JOIN horas_estandar as viernes ON temp_censo.hora_viernes = viernes.nombre_horas_estandar);