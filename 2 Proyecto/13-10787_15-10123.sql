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

-- Tabla de usuario
CREATE TABLE IF NOT EXISTS users(
	id_user BIGINT PRIMARY KEY,
	first_name_user VARCHAR(64) NOT NULL,
	last_name_user VARCHAR(64) NOT NULL,
	email_user VARCHAR(64) UNIQUE,
	credit_card_type_user VARCHAR(32),
	credit_card_number_user BIGINT,
	password_user VARCHAR(64) NOT NULL
);

\COPY users(id_user,first_name_user,last_name_user,email_user,credit_card_type_user,credit_card_number_user,password_user) FROM 'Users.csv' DELIMITER ',' CSV HEADER

-- Tabla de categoria
CREATE EXTENSION ltree;
CREATE TABLE IF NOT EXISTS category(
    id_category TEXT PRIMARY KEY,
    path ltree NOT NULL UNIQUE
);

\COPY category(id_category, path) FROM 'Categories.csv' DELIMITER ';' CSV HEADER

CREATE INDEX path_gist_idx ON category USING gist(path);
CREATE INDEX path_idx ON category USING btree(path);


-- Tabla de producto
CREATE TABLE IF NOT EXISTS product(
	id_product BIGSERIAL PRIMARY KEY,
	name_product TEXT NOT NULL,
	id_category_product TEXT,
	FOREIGN KEY (id_category_product) REFERENCES category(id_category),
	description_product TEXT NOT NULL
);

\COPY product(name_product,id_category_product,description_product) FROM 'Products.csv' DELIMITER ',' CSV HEADER

CREATE TABLE IF NOT EXISTS admin(
	id_admin BIGSERIAL PRIMARY KEY,
	id_user_admin BIGINT,
	FOREIGN KEY (id_user_admin) REFERENCES users(id_user)
);

\COPY admin(id_user_admin) FROM 'Admin.csv' DELIMITER ',' CSV HEADER

-- Tabla de subasta
CREATE TABLE IF NOT EXISTS auction(
	id_auction BIGSERIAL PRIMARY KEY,
	reserve_price_auction MONEY NOT NULL,
	base_price_auction MONEY NOT NULL,
	actual_price_auction MONEY,
	id_product_auction BIGINT,
	FOREIGN KEY (id_product_auction) REFERENCES product(id_product),
	description_auction TEXT NOT NULL,
	actual_winner_auction BIGINT,
	FOREIGN KEY (actual_winner_auction) REFERENCES users(id_user),
	owner_auction BIGINT,
	FOREIGN KEY (owner_auction) REFERENCES users(id_user),
	start_date_auction TIMESTAMP NOT NULL,
	end_date_auction TIMESTAMP NOT NULL,
	bid_count_auction MONEY NOT NULL,
    image_product_auction TEXT NOT NULL,
	stock_product_auction INT NOT NULL,
	estate_product_auction VARCHAR(8) NOT NULL,
	is_active_auction BOOLEAN NOT NULL
);

\COPY auction(reserve_price_auction,base_price_auction,actual_price_auction,id_product_auction,description_auction,actual_winner_auction,owner_auction,start_date_auction,end_date_auction,bid_count_auction,image_product_auction,stock_product_auction,estate_product_auction,is_active_auction) FROM 'Auction.csv' DELIMITER ',' CSV HEADER

CREATE TABLE IF NOT EXISTS bid_registry(
	id_bid_validation BIGSERIAL PRIMARY KEY,
	id_auction_bid_validation BIGINT,
	FOREIGN KEY (id_auction_bid_validation) REFERENCES auction(id_auction),
	id_user_bid_validation BIGINT,
	FOREIGN KEY (id_user_bid_validation) REFERENCES users(id_user),
	amount_bid_validation MONEY NOT NULL,
	date_bid_validation TIMESTAMP NOT NULL
);

\COPY bid_registry(id_auction_bid_validation,id_user_bid_validation,amount_bid_validation,date_bid_validation) FROM 'BidRegistry.csv' DELIMITER ',' CSV HEADER

CREATE TABLE IF NOT EXISTS bid_validation(
	id_bid_validation BIGSERIAL PRIMARY KEY,
	id_auction_bid_validation BIGINT,
	FOREIGN KEY (id_auction_bid_validation) REFERENCES auction(id_auction),
	id_user_bid_validation BIGINT,
	FOREIGN KEY (id_user_bid_validation) REFERENCES users(id_user),
	amount_bid_validation MONEY NOT NULL,
	date_bid_validation TIMESTAMP NOT NULL
);