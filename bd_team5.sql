
-- Jose Ramon Barrera, 15-10123
-- Maria Fernanda Magallanes, 13-10787

--Eliminamos la BD si existe
DROP DATABASE IF EXISTS bd_team5;

--Creamos la BD
CREATE DATABASE bd_team5;

--Nos conectamos a la BD
\c bd_team5


CREATE TABLE IF NOT EXISTS cargo(
	id_cargo SMALLINT PRIMARY KEY,
	nombre_cargo VARCHAR(64) NOT NULL,
); 

CREATE TABLE IF NOT EXISTS departamento(
	id_departamento SMALLINT PRIMARY KEY,
	nombre_departamento VARCHAR(64) NOT NULL,
	id_sede SMALLINT FOREIGN KEY,
); 

CREATE TABLE IF NOT EXISTS autoridad(
	id_autoridad SMALLINT PRIMARY KEY,
	nombre_autoridad VARCHAR(64) NOT NULL,
	id_sede SMALLINT FOREIGN KEY,
); 

CREATE TABLE IF NOT EXISTS sede(
	id_sede SMALLINT PRIMARY KEY,
	nombre_sede VARCHAR(64) NOT NULL,
);

CREATE TABLE IF NOT EXISTS censo(
	id_censo INT AUTO_INCREMENT PRIMARY KEY,
	nombre_censo VARCHAR(64) NOT NULL,
	id_personal INT FOREIGN KEY,
); 

CREATE TABLE IF NOT EXISTS ruta(
	id_ruta SMALLINT PRIMARY KEY,
	nombre_ruta VARCHAR(64) NOT NULL,
	id_sede SMALLINT FOREIGN KEY,
); 

CREATE TABLE IF NOT EXISTS personal(
	tipo_personal CHAR(1) NOT NULL,
	id_personal INT NOT NULL,
	constraint PK_personal PRIMARY KEY(tipo_personal , id_personal),
	nombre_personal VARCHAR(64) NOT NULL,
	genero CHAR(1) NOT NULL,
	fecha_ingreso DATE NOT NULL,
	id_sede SMALLINT FOREIGN KEY,
	id_autoridad SMALLINT FOREIGN KEY,
	id_departamento SMALLINT FOREIGN KEY,
	id_cargo SMALLINT FOREIGN KEY,
); 