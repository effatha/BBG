with 
cte_mkt_item as 
(
SELECT 
	TransactionDate,
	ItemNo,
	MarketingCost =  sum(ISNULL(MarketingAmazon,0) + ISNULL(MarketingGoogle,0)+ISNULL(MarketingD2C,0))

FROM 
TEST.PL_V_MARKETING_COST_SM_ITEM_FULL mkt 
WHERE	
	YEAR(TransactionDate) = 2025
	AND
	MONTH(TransactionDate) = 7
GROUP BY TransactionDate,ItemNo

),
cte_stock as 
(
	select 
		StockDate,
		ItemNo,
		QuantityUnrestricted = SUM(ISNULL(QuantityUnrestricted,0)),
		TotalQuantity = SUM(ISNULL(TotalQuantity,0))
	FROM pl.PL_V_DEtailed_stock_history 
	WHERE 1=1
		AND 
		StockType IN ('PHYSICAL STOCK','InTransit','CONSIGNMENT STOCK')
	GROUP BY ItemNo,StockDate

)

SELECT
	f.TransactionDate,f.ItemNo,
	MarketingCost = ISNULL(f.MarketingCost,0),
	QuantityUnrestricted = ISNULL(QuantityUnrestricted,0),
	TotalQuantity = TotalQuantity

FROM cte_mkt_item f
LEFT JOIN cte_stock s on s.ItemNo = f.ItemNo and s.StockDate = f.TransactionDate
ORDER BY 1




--select top 10 * from Pl.PL_V_DEtailed_stock_history