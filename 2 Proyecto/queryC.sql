--c. En promedio, ¿Cuáles productos tienen precios de venta más alto? ¿Los que
--empiezan con un precio base menor de $1 ó los que empiezan con un precio base de
--por lo menos $1? (no puedo comparar precios de productos diferentes)

SELECT * FROM (SELECT to_char(float8 (AVG(actual_price_auction)),'FM999999999.00') AS avg_price_produtcs_base_price_above_1,base_price_auction, id_product_auction
FROM auction
GROUP BY id_product_auction, base_price_auction
HAVING base_price_auction > 1) AS above INNER JOIN
(SELECT to_char(float8 (AVG(actual_price_auction)),'FM999999999.00') AS avg_price_produtcs_base_price_under_1,base_price_auction, id_product_auction
FROM auction
GROUP BY id_product_auction, base_price_auction
HAVING base_price_auction < 1) AS under ON under.id_product_auction = above.id_product_auction;