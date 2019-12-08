CREATE OR REPLACE PROCEDURE undoLastBid(INT)
LANGUAGE plpgsql
AS $$
DECLARE
	auctionId ALIAS FOR $1;
    undoBidId integer :=
        SELECT id_bid_registry
        FROM
        (SELECT *
        FROM (SELECT id_bid_registry,date_bid_registry FROM bid_registry WHERE id_auction_bid_registry = auctionId) AS thisBids
        ORDER BY date_bid_registry DESC
        LIMIT 1) AS lastBidId;
    newWinner integer :=
            SELECT id_user_bid_registry
            FROM (
                SELECT date_bid_registry, 
                    dense_rank() over (partition by date_bid_registry order by date_bid_registry desc) as rnk
                FROM bid_registry
                WHERE id_auction_bid_registry = auctionId
            ) AS prevLastBidId
            WHERE rnk = 2;
    amount integer := (SELECT amount_bid_registry FROM bid_registry WHERE id_bid_registry = undoBidId);
BEGIN
    -- subtracting the amount from the actual price of auction
    UPDATE auction 
    SET actual_price_auction = actual_price_auction - amount
    SET actual_winner_auction = newWinner
    WHERE id_auction = auctionId;
    COMMIT;
END;
$$;

CALL undoLastBid(1);
	
SELECT * FROM auction;