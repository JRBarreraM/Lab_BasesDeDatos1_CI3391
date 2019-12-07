CREATE OR REPLACE FUNCTION categoryStrToId()
	RETURNS trigger AS
$$
BEGIN
	INSERT INTO product(id_category_product)
	SELECT id_category
	FROM category
	INNER JOIN product ON product.id_category_product = category.id_category;
	RETURN NEW;
END;
$$
LANGUAGE 'plpgsql';

CREATE TRIGGER categoryId_trigger
	BEFORE INSERT
	ON product
	FOR EACH ROW
	EXECUTE PROCEDURE categoryStrToId();

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