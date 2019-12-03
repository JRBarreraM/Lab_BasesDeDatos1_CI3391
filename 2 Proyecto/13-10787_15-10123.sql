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
CREATE TABLE IF NOT EXISTS users(
	id_user BIGINT PRIMARY KEY,
	first_name_user VARCHAR(64),
	last_name_user VARCHAR(64),
	email_user VARCHAR(64),
	credit_card_type_user VARCHAR(32),
	credit_card_number_user BIGINT,
	password_user VARCHAR(64)
);

\COPY users(id_user,first_name_user,last_name_user,email_user,credit_card_type_user,credit_card_number_user,password_user) FROM 'Users.csv' DELIMITER ',' CSV HEADER

CREATE EXTENSION ltree;

CREATE TABLE IF NOT EXISTS category(
    id SERIAL PRIMARY KEY,
    node text,
    PATH ltree
);

INSERT INTO category (node, path) VALUES ('Top','Top');
INSERT INTO category (node, path) VALUES ('Science', 'Top.Science');
INSERT INTO category (node, path) VALUES ('Astronomy','Top.Science.Astronomy');
INSERT INTO category (node, path) VALUES ('Astrophysics','Top.Science.Astronomy.Astrophysics');
INSERT INTO category (node, path) VALUES ('Cosmology','Top.Science.Astronomy.Cosmology');
INSERT INTO category (node, path) VALUES ('Hobbies','Top.Hobbies');
INSERT INTO category (node, path) VALUES ('Amateurs_Astronomy','Top.Hobbies.Amateurs_Astronomy');
INSERT INTO category (node, path) VALUES ('Collections','Top.Collections');
INSERT INTO category (node, path) VALUES ('Pictures','Top.Collections.Pictures');
INSERT INTO category (node, path) VALUES ('Astronomy','Top.Collections.Pictures.Astronomy');
INSERT INTO category (node, path) VALUES ('Stars','Top.Collections.Pictures.Astronomy.Stars');
INSERT INTO category (node, path) VALUES ('Galaxies','Top.Collections.Pictures.Astronomy.Galaxies');
INSERT INTO category (node, path) VALUES ('Astronauts','Top.Collections.Pictures.Astronomy.Astronauts');



CREATE INDEX path_gist_idx ON category USING gist(path);
CREATE INDEX path_idx ON category USING btree(path);