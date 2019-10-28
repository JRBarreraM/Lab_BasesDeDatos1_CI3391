--	Jose Barrera, 15-10123
--	Maria Magallanes, 13-10787

--	Eliminamos la BD si existe
DROP DATABASE IF EXISTS bd_team5;

--	Creamos la BD
CREATE DATABASE bd_team5;

--	Nos conectamos a la BD
\c bd_team5;

--	Cargamos los datos en dos tablas temporales

CREATE TABLE IF NOT EXISTS nomina(
	id_cargo SMALLINT PRIMARY KEY,
	nombre_cargo VARCHAR(64) NOT NULL
);

COPY temp_nomina(first_name,last_name,dob,email)
FROM 'C:\tmp\persons.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE IF NOT EXISTS temp_censo(
	id_cargo SMALLINT PRIMARY KEY,
	nombre_cargo VARCHAR(64) NOT NULL
);

COPY temp_censo(first_name,last_name,dob,email)
FROM 'C:\tmp\persons.csv' DELIMITER ',' CSV HEADER;

--	Creamos cada tabla
--	Extraemos la data de la temporal a donde corresponda

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
	nombre_departamento VARCHAR(64) NOT NULL,
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
	id_ruta SMALLINT PRIMARY KEY,
	nombre_ruta VARCHAR(64) NOT NULL,
	id_sede SMALLINT,
	FOREIGN KEY (id_sede) REFERENCES sede(id_sede)
);

CREATE TABLE IF NOT EXISTS personal(
	tipo_personal CHAR(1) NOT NULL,
	documento_identidad_personal INT NOT NULL,
	nombre_personal VARCHAR(64) NOT NULL,
	genero_personal CHAR(1) NOT NULL,
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