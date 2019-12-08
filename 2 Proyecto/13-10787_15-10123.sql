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

ALTER TABLE users
ADD  CONSTRAINT payMethod
CHECK ((credit_card_type_user IS NULL AND credit_card_number_user IS NULL)OR(credit_card_type_user IS NOT NULL AND credit_card_number_user IS NOT NULL));

\COPY users(id_user,first_name_user,last_name_user,email_user,credit_card_type_user,credit_card_number_user,password_user) FROM 'Users.csv' DELIMITER ',' CSV HEADER

CREATE TABLE IF NOT EXISTS admin(
	id_user_admin BIGINT PRIMARY KEY,
	FOREIGN KEY (id_user_admin) REFERENCES users(id_user)
);

\COPY admin(id_user_admin) FROM 'Admin.csv' DELIMITER ',' CSV HEADER

-- Tabla de arbol de categoria
CREATE EXTENSION ltree;
CREATE TABLE IF NOT EXISTS category(
    id_category TEXT PRIMARY KEY,
    nodePath ltree NOT NULL UNIQUE
);

\COPY category(id_category, nodePath) FROM 'Categories.csv' DELIMITER ';' CSV HEADER

CREATE INDEX path_gist_idx ON category USING gist(nodePath);
CREATE INDEX path_idx ON category USING btree(nodePath);

-- Tabla de producto
CREATE TABLE IF NOT EXISTS product(
	id_product BIGSERIAL PRIMARY KEY,
	name_product TEXT NOT NULL,
	description_product TEXT NOT NULL
);

\COPY product(name_product,description_product) FROM 'Products.csv' DELIMITER ',' CSV HEADER

-- Tabla para el atributo multivaluado categoria de producto
CREATE TABLE IF NOT EXISTS tag(
	id_product_tag BIGINT,
	FOREIGN KEY (id_product_tag) REFERENCES product(id_product),
	id_category_tag TEXT,
	FOREIGN KEY (id_category_tag) REFERENCES category(id_category),
	PRIMARY KEY (id_product_tag, id_category_tag)
);

\COPY tag(id_product_tag,id_category_tag) FROM 'Tag.csv' DELIMITER ',' CSV HEADER

-- Tabla de subasta
CREATE TABLE IF NOT EXISTS auction(
	id_auction BIGSERIAL PRIMARY KEY,
	reserve_price_auction NUMERIC(15,2) NOT NULL CHECK(reserve_price_auction > 0),
	base_price_auction NUMERIC(15,2) NOT NULL CHECK(base_price_auction <= reserve_price_auction),
	actual_price_auction NUMERIC(15,2) CHECK(actual_price_auction > 0),
	id_product_auction BIGINT,
	FOREIGN KEY (id_product_auction) REFERENCES product(id_product),
	description_auction TEXT NOT NULL,
	actual_winner_auction BIGINT,
	FOREIGN KEY (actual_winner_auction) REFERENCES users(id_user),
	owner_auction BIGINT,
	FOREIGN KEY (owner_auction) REFERENCES users(id_user),
	start_date_auction TIMESTAMP NOT NULL,
	end_date_auction TIMESTAMP NOT NULL CHECK(end_date_auction > start_date_auction),
	bid_count_auction NUMERIC(15,2) NOT NULL,
    image_product_auction TEXT NOT NULL,
	stock_product_auction INT NOT NULL CHECK(stock_product_auction >= 0),
	estate_product_auction VARCHAR(8) NOT NULL,
	extend_date_auction VARCHAR(16) NOT NULL,
	is_active_auction BOOLEAN NOT NULL
);

\COPY auction(reserve_price_auction,base_price_auction,actual_price_auction,id_product_auction,description_auction,actual_winner_auction,owner_auction,start_date_auction,end_date_auction,bid_count_auction,image_product_auction,stock_product_auction,estate_product_auction,extend_date_auction,is_active_auction) FROM 'Auction.csv' DELIMITER ',' CSV HEADER

-- Tabla de registro de bids historicos
CREATE TABLE IF NOT EXISTS bid_registry(
	id_bid_registry BIGSERIAL PRIMARY KEY,
	id_auction_bid_registry BIGINT,
	FOREIGN KEY (id_auction_bid_registry) REFERENCES auction(id_auction),
	id_user_bid_registry BIGINT,
	FOREIGN KEY (id_user_bid_registry) REFERENCES users(id_user),
	amount_bid_registry NUMERIC(15,2) NOT NULL CHECK(amount_bid_registry >= 0),
	date_bid_registry TIMESTAMP NOT NULL
);

\COPY bid_registry(id_auction_bid_registry,id_user_bid_registry,amount_bid_registry,date_bid_registry) FROM 'BidRegistry.csv' DELIMITER ',' CSV HEADER

CREATE OR REPLACE FUNCTION isLeaf(TEXT) RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
	node ALIAS FOR $1;
	a integer := (SELECT COUNT (nodePath) FROM category WHERE nodePath ~ ('*.'|| node || '.*')::lquery);
BEGIN
	IF 1 < a THEN
		RAISE NOTICE 'is not a leaf';
		RETURN FALSE;
	END IF;
	IF 1 = a THEN
		RAISE NOTICE 'is leaf';
		RETURN TRUE;
	END IF;
END;
$$;

CREATE OR REPLACE FUNCTION leafChecker()
  RETURNS TRIGGER AS
$BODY$
BEGIN
	IF isLeaf(tag.id_category_tag) THEN
		RETURN NEW;
	ELSE
		RAISE EXCEPTION 'Invalid category';
		RETURN NULL;
	END IF;

	RETURN NEW;
END;
$BODY$

CREATE TRIGGER categoryChecker
	BEFORE INSERT
	ON tag
	FOR EACH STATEMENT
	EXECUTE PROCEDURE leafChecker();

SELECT isLeaf('Unisex_Kids_Clothing');

CREATE OR REPLACE PROCEDURE undoLastBid(INT)
LANGUAGE plpgsql
AS $$
DECLARE
	auctionId ALIAS FOR $1;
    undoBidId integer := 
        (SELECT id_bid_registry
        FROM
        (SELECT *
        FROM (SELECT id_bid_registry,date_bid_registry FROM bid_registry WHERE id_auction_bid_registry = auctionId) AS thisBids
        ORDER BY date_bid_registry DESC
        LIMIT 1) AS lastBidId);
    newWinner integer :=
            (SELECT id_user_bid_registry
            FROM (
                SELECT date_bid_registry, id_user_bid_registry,
                    dense_rank() over (partition by date_bid_registry order by date_bid_registry desc) as rnk
                FROM bid_registry
                WHERE id_auction_bid_registry = auctionId
            ) AS prevLastBidId
            WHERE rnk = 2);
    amount integer := (SELECT amount_bid_registry FROM bid_registry WHERE id_bid_registry = undoBidId);
BEGIN
    UPDATE auction 
    SET actual_price_auction = actual_price_auction - amount
    WHERE id_auction = auctionId;

    UPDATE auction 
    SET actual_winner_auction = newWinner
    WHERE id_auction = auctionId;

    COMMIT;
END;
$$;

CREATE OR REPLACE FUNCTION usersPayMethod(BIGINT) RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
	RETURN ((SELECT credit_card_number_user FROM users WHERE id_user = $1) IS NOT NULL);
END;
$$;

--Only user with a credit card can do bids
ALTER TABLE bid_registry
ADD CONSTRAINT payMethodCheck
CHECK (usersPayMethod(id_user_bid_registry));

CREATE OR REPLACE PROCEDURE doBid(BIGINT,BIGINT,NUMERIC,TIMESTAMP)
LANGUAGE plpgsql
AS $$
DECLARE
	auctionId ALIAS FOR $1;
	userId ALIAS FOR $1;
	amount ALIAS FOR $1;
	time ALIAS FOR $1;
    undoBidId integer := 
        
    newWinner integer :=
            (SELECT id_user_bid_registry
            FROM (
                SELECT date_bid_registry, id_user_bid_registry,
                    dense_rank() over (partition by date_bid_registry order by date_bid_registry desc) as rnk
                FROM bid_registry
                WHERE id_auction_bid_registry = auctionId
            ) AS prevLastBidId
            WHERE rnk = 2);
    amount integer := (SELECT amount_bid_registry FROM bid_registry WHERE id_bid_registry = undoBidId);
BEGIN
    UPDATE auction 
    SET actual_price_auction = actual_price_auction - amount
    WHERE id_auction = auctionId;

    UPDATE auction 
    SET actual_winner_auction = newWinner
    WHERE id_auction = auctionId;

    COMMIT;
END;
$$;
--CALL doBid(1,1,100,1/13/2020 9:28:55);
--CALL undoLastBid(3);
--SELECT * FROM auction;