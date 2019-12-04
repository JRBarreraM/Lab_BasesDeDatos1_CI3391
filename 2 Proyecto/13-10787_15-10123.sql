--------------------------------------------------------------------------------
--	Jose Barrera, 15-10123
--	Maria Magallanes, 13-10787
--------------------------------------------------------------------------------

--	Eliminamos la BD si existe
DROP DATABASE IF EXISTS "13-10787_15-10123";

--	Creamos la BD
CREATE DATABASE "13-10787_15-10123";

--	Nos conectamos a la BD
\c "13-10787_15-10123";

--	Cargamos los datos en tablas

-- Tabla de usuarios
CREATE TABLE IF NOT EXISTS users(
	id_user BIGINT PRIMARY KEY,
	first_name_user VARCHAR(64),
	last_name_user VARCHAR(64),
	email_user VARCHAR(64) UNIQUE,
	credit_card_type_user VARCHAR(32),
	credit_card_number_user BIGINT,
	password_user VARCHAR(64) NOT NULL
);

\COPY users(id_user,first_name_user,last_name_user,email_user,credit_card_type_user,credit_card_number_user,password_user) FROM 'Users.csv' DELIMITER ',' CSV HEADER

-- Tabla de categorias
CREATE EXTENSION ltree;
CREATE TABLE IF NOT EXISTS category(
    id_category TEXT PRIMARY KEY,
    path ltree NOT NULL
);

\COPY category(id_category, path) FROM 'Categories.csv' DELIMITER ';' CSV HEADER

CREATE INDEX path_gist_idx ON category USING gist(path);
CREATE INDEX path_idx ON category USING btree(path);


-- Tabla de productos
CREATE TABLE IF NOT EXISTS product(
	id_product BIGSERIAL PRIMARY KEY,
	name_product TEXT,
	estate_product VARCHAR(4),
	id_category_product TEXT,
	FOREIGN KEY (id_category_product) REFERENCES category(id_category),
	description_product TEXT,
	price_product MONEY,
	stock_product SMALLINT,
    image_product TEXT
);

\COPY product(name_product,estate_product,id_category_product,description_product,price_product,stock_product,image_product) FROM 'Products.csv' DELIMITER ',' CSV HEADER