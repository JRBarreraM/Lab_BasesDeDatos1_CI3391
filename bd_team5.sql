--	Jose Barrera, 15-10123
--	Maria Magallanes, 13-10787

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
	tipo_personal CHAR(1),
	documento_identidad_personal INT,
	apellido_personal VARCHAR(64),
	nombre_personal VARCHAR(64),
	genero_personal VARCHAR(10),
	fecha_ingreso_personal DATE,
	id_cargo INT,
	nombre_cargo VARCHAR(64),
	id_autoridad SMALLINT,
	nombre_autoridad VARCHAR(64),
	id_departamento SMALLINT,
	nombre_departamento VARCHAR(70)
);

\COPY temp_nomina(id_tno, tno, estatus, id_sede, nombre_sede, tipo_personal, documento_identidad_personal, apellido_personal, nombre_personal, genero_personal, fecha_ingreso_personal, id_cargo, nombre_cargo, id_autoridad, nombre_autoridad, id_departamento, nombre_departamento) FROM 'Nomina Empleados Sartenejas.csv' DELIMITER ',' CSV HEADER

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
	tiempo_llegada VARCHAR(20)
);

\COPY temp_censo(documento_identidad_personal, nombre_completo_personal, medio_transporte, zona_residencia, relacion, hora_lunes, hora_martes, hora_miercoles, hora_jueves, hora_viernes, nombre_sede, tipo_ruta, nombre_ruta, tiempo_llegada) FROM 'Censo Empleados.csv' DELIMITER ',' CSV HEADER

--	Creamos cada tabla

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
	id_sede SMALLINT,
	FOREIGN KEY (id_sede) REFERENCES sede(id_sede)
);

CREATE TABLE IF NOT EXISTS autoridad(
	id_autoridad SMALLINT PRIMARY KEY,
	nombre_autoridad VARCHAR(64) NOT NULL,
	id_sede SMALLINT,
	FOREIGN KEY (id_sede) REFERENCES sede(id_sede)
);

CREATE TABLE IF NOT EXISTS ruta(
	id_ruta SERIAL PRIMARY KEY,
	nombre_ruta VARCHAR(64) NOT NULL,
	id_sede SMALLINT,
	FOREIGN KEY (id_sede) REFERENCES sede(id_sede)
);

CREATE TABLE IF NOT EXISTS personal(
	tipo_personal CHAR(1) NOT NULL,
	documento_identidad_personal INT NOT NULL,
	nombre_personal VARCHAR(64) NOT NULL,
	apellido_personal VARCHAR(64) NOT NULL,
	genero_personal VARCHAR(10) NOT NULL,
	fecha_ingreso_personal DATE NOT NULL,
	id_sede SMALLINT,
	FOREIGN KEY (id_sede) REFERENCES sede(id_sede),
	id_autoridad SMALLINT,
	FOREIGN KEY (id_autoridad) REFERENCES autoridad(id_autoridad),
	id_departamento SMALLINT,
	FOREIGN KEY (id_departamento) REFERENCES departamento(id_departamento),
	id_cargo SMALLINT,
	FOREIGN KEY (id_cargo) REFERENCES cargo(id_cargo),
	CONSTRAINT id_personal PRIMARY KEY(tipo_personal, documento_identidad_personal)
);

CREATE TABLE IF NOT EXISTS censo(
	id_censo SERIAL PRIMARY KEY,
	nombre_censo VARCHAR(64) NOT NULL,
	tipo_personal CHAR(1) NOT NULL,
	documento_identidad_personal INT NOT NULL,
	FOREIGN KEY (tipo_personal,documento_identidad_personal) REFERENCES personal(tipo_personal, documento_identidad_personal)
);

--	Extraemos la data de la temporal a donde corresponda
INSERT INTO cargo
SELECT DISTINCT id_cargo, nombre_cargo
FROM temp_nomina
ORDER BY id_cargo;

INSERT INTO sede
SELECT DISTINCT id_sede, nombre_sede
FROM temp_nomina
ORDER BY id_sede;

INSERT INTO departamento
SELECT DISTINCT id_departamento, nombre_departamento, id_sede
FROM temp_nomina
ORDER BY id_departamento;

INSERT INTO autoridad
SELECT DISTINCT id_autoridad, nombre_autoridad, id_sede
FROM temp_nomina
ORDER BY id_autoridad;

INSERT INTO ruta (nombre_ruta, id_sede)
SELECT DISTINCT censo.nombre_ruta, nomina.id_sede
FROM temp_nomina as nomina JOIN temp_censo as censo ON censo.nombre_sede = nomina.nombre_sede;

INSERT INTO personal
SELECT DISTINCT ON (tipo_personal), tipo_personal, documento_identidad_personal, nombre_personal, apellido_personal, genero_personal, fecha_ingreso_personal, id_sede, id_autoridad, id_departamento, id_cargo
FROM temp_nomina
ORDER BY documento_identidad_personal;