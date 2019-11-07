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
CREATE TABLE IF NOT EXISTS estado(
	id_estado SERIAL PRIMARY KEY,
	nombre_estado VARCHAR(64) CHECK(IN('ACTIVO','INACTIVO'))
);

CREATE TABLE IF NOT EXISTS tipo_p(
	id_tipo_personal SMALLINT PRIMARY KEY,
	nombre_tipo_personal VARCHAR(64) NOT NULL
);

CREATE TABLE IF NOT EXISTS genero(
	id_genero SERIAL PRIMARY KEY,
	nombre_genero VARCHAR() CHECK(IN('FEMENINO','MASCULINO'))
);

CREATE TABLE IF NOT EXISTS medio_transporte(
	id_medio_transporte SERIAL PRIMARY KEY,
	nombre_medio_transporte VARCHAR(64) NOT NULL
);

CREATE TABLE IF NOT EXISTS zona_vive(
	id_zona_vive SERIAL PRIMARY KEY,
	nombre_zona_vive VARCHAR(64) NOT NULL
);

CREATE TABLE IF NOT EXISTS horas_estandar(
	id_horas_estandar SERIAL PRIMARY KEY,
	nombre_horas_estandar VARCHAR(64) NOT NULL
);

CREATE TABLE IF NOT EXISTS dias(
	id_dias SERIAL PRIMARY KEY,
	nombre_dias VARCHAR(20) NOT NULL
);

CREATE TABLE IF NOT EXISTS tiempo_llegada(
	id_tiempo_llegada SERIAL PRIMARY KEY,
	nombre_tiempo_llegada VARCHAR(64) NOT NULL
);

CREATE TABLE IF NOT EXISTS tipo_ruta(
	id_tipo_ruta SERIAL PRIMARY KEY,
	nombre_tipo_ruta VARCHAR(64) CHECK(IN('Urbana','Interurbana','Vacio'))
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
);

CREATE TABLE IF NOT EXISTS autoridad(
	id_autoridad SMALLINT PRIMARY KEY,
	nombre_autoridad VARCHAR(64) NOT NULL,
);

CREATE TABLE IF NOT EXISTS ruta(
	id_ruta SERIAL PRIMARY KEY,
	nombre_ruta VARCHAR(64) NOT NULL,
);

CREATE TABLE IF NOT EXISTS personal(
	documento_identidad_personal INT PRIMARY KEY,
	tipo_personal SMALLINT,
	FOREIGN KEY (tipo_personal) REFERENCES tipo_p(id_tipo_personal),
	estado SMALLINT,
	FOREIGN KEY (estado) REFERENCES estado(id_estado),
	id_sede SMALLINT,
	FOREIGN KEY (id_sede) REFERENCES sede(id_sede),
	nacionalidad CHAR(1) NOT NULL,
	nombre_personal VARCHAR(64) NOT NULL,
	apellido_personal VARCHAR(64) NOT NULL,
	genero_personal SMALLINT,
	FOREIGN KEY (genero_personal) REFERENCES genero(id_genero),
	fecha_ingreso_personal DATE NOT NULL,
	id_cargo SMALLINT,
	FOREIGN KEY (id_cargo) REFERENCES cargo(id_cargo),
	id_autoridad SMALLINT,
	FOREIGN KEY (id_autoridad) REFERENCES autoridad(id_autoridad),
	id_departamento SMALLINT,
	FOREIGN KEY (id_departamento) REFERENCES departamento(id_departamento),
);

CREATE TABLE IF NOT EXISTS censo(
	id_censo SERIAL PRIMARY KEY,
	documento_identidad_personal INT NOT NULL,
	FOREIGN KEY (documento_identidad_personal) REFERENCES personal( documento_identidad_personal),
	medio_de_transporte SMALLINT,
	FOREIGN KEY (medio_de_transporte) REFERENCES medio_transporte(id_medio_transporte),
	zona_vive SMALLINT,
	FOREIGN KEY (zona_vive) REFERENCES zona_vive(id_zona_vive),
	tipo_ruta SMALLINT,
	FOREIGN KEY (tipo_ruta) REFERENCES tipo_ruta(id_tipo_ruta),
	ruta SMALLINT,
	FOREIGN KEY (ruta) REFERENCES ruta(id_ruta),
	tiempo_llegada SMALLINT,
	FOREIGN KEY (tiempo_llegada) REFERENCES tiempo_llegada(id_tiempo_llegada),
);

CREATE TABLE IF NOT EXISTS horas_dias(
	id_horas_dias SERIAL PRIMARY KEY,
	documento_identidad_personal INT NOT NULL,
	FOREIGN KEY (documento_identidad_personal) REFERENCES personal(documento_identidad_personal),
	horas INT NOT NULL,
	FOREIGN KEY (horas) REFERENCES horas_estandar(id_horas_estandar),
	dias INT NOT NULL,
	FOREIGN KEY (dias) REFERENCES dias(id_dias),
)

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
SELECT DISTINCT id_departamento, nombre_departamento
FROM temp_nomina
ORDER BY id_departamento;

INSERT INTO autoridad
SELECT DISTINCT id_autoridad, nombre_autoridad
FROM temp_nomina
ORDER BY id_autoridad;

INSERT INTO ruta
SELECT DISTINCT censo.nombre_ruta
FROM temp_nomina as nomina JOIN temp_censo as censo ON censo.documento_identidad_personal = nomina.documento_identidad_personal
WHERE censo.nombre_ruta IS NOT NULL;

INSERT INTO personal
SELECT DISTINCT ON (temp_nomina.tipo_personal, temp_nomina.documento_identidad_personal) tipo_personal, documento_identidad_personal, nombre_personal, apellido_personal, genero_personal, fecha_ingreso_personal, id_sede, id_autoridad, id_departamento, id_cargo
FROM temp_nomina
ORDER BY documento_identidad_personal;

INSERT INTO censo (tipo_personal, documento_identidad_personal)
SELECT DISTINCT ON (temp_nomina.tipo_personal, temp_nomina.documento_identidad_personal) tipo_personal, documento_identidad_personal
FROM temp_nomina
ORDER BY documento_identidad_personal;

--	Eliminamos las tablas temporales
DROP TABLE temp_nomina, temp_censo
