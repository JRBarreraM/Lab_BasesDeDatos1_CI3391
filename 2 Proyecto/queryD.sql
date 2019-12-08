--d. ¿Cuántas subastas se realizan por mes por categoría? (tomar en cuenta todas las categorías)
SELECT to_char(start_date_auction,'Month') as month, id_category_tag as product_category,
       COUNT(1) as auctions_this_month
FROM auction AS a INNER JOIN tag AS t ON t.id_product_tag = a.id_product_auction
GROUP BY month, id_category_tag
ORDER BY month, id_category_tag