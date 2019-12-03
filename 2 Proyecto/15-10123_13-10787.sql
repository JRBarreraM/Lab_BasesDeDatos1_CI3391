
-- Tabla de productos
CREATE TABLE IF NOT EXISTS product(
	id_product BIGINT PRIMARY KEY,
	category_product VARCHAR(64),
	FOREIGN KEY (category_product) REFERENCES category(id_category)	
	description_product TEXT,
	price_product MONEY,
    image_product TEXT
);

-- Tabla de productos
CREATE TABLE IF NOT EXISTS auction(
	id_auction BIGINT PRIMARY KEY,
	reserve_price_auction MONEY,
	base_price_auction MONEY,
	actual_price_auction MONEY,
	id_product_auction BIGINT,
	FOREIGN KEY (id_product_auction) REFERENCES product(id_product),	
	description_product TEXT,
	actual_winner_auction BIGINT,
	FOREIGN KEY (actual_winner_auction) REFERENCES users(id_users),
	owner_auction BIGINT,
	FOREIGN KEY (owner_auction) REFERENCES users(id_users)
	start_date_product SMALLDATETIME,
	end_date_product SMALLDATETIME,
	bid_count INT,
	is_active BOOLEAN
);

create table tree(
    id serial primary key,
    letter char,
    path ltree
);
create index tree_path_idx on tree using gist (path);





CREATE TABLE IF NOT EXISTS category(

);

CREATE TABLE IF NOT EXISTS bid_validation(

);

CREATE TABLE IF NOT EXISTS bid_registry(

);

\COPY temp_nomina(id_user,first_name_user,last_name_user,email_user,credit_card_type_user,credit_card_number_user,password_user) FROM 'Users.csv' DELIMITER ',' CSV HEADER

CREATE OR REPLACE PROCEDURE undoLastBid(INT, INT, DEC)
LANGUAGE plpgsql    
AS $$
BEGIN
    -- subtracting the amount from the sender's account 
    UPDATE accounts 
    SET balance = balance - $3
    WHERE id = $1;
 
    -- adding the amount to the receiver's account
    UPDATE accounts 
    SET balance = balance + $3
    WHERE id = $2;
 
    COMMIT;
END;
$$;

CALL undoLastBid(1,2,1000);

CREATE OR REPLACE PROCEDURE doBid(INT, INT, DEC)
LANGUAGE plpgsql
AS $$
BEGIN
    -- subtracting the amount from the sender's account 
    UPDATE accounts 
    SET balance = balance - $3
    WHERE id = $1;
 
    -- adding the amount to the receiver's account
    UPDATE accounts 
    SET balance = balance + $3
    WHERE id = $2;
 
    COMMIT;
END;
$$;

CALL doBid(1,2,1000);