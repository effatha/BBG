SELECT
	ItemNo,
	Nov = SUM(NetOrderValueEst),
	Mkt = SUM(ISNULL(MarketingShops,0) + ISNULL(MarketingAmazon,0) + ISNULL(MarketingMarketplacesEst,0)),
	GGL = SUM(ISNULL(MarketingShops,0)),
	MktAmazon  =SUM(ISNULL(MarketingAmazon,0)),
	MarketingMarketplacesEst =  SUM(ISNULL(MarketingMarketplacesEst,0))
FROM Pl.PL_V_SALES_TRANSACTIONS s
INNER JOIN PL.PL_V_ITEM it 
	on s.ItemId = it.ItemId
WHERE
	it.ItemNo = '10047455'
	--it.ProductHierarchy4 = 'Athena'

	AND
	TransactionDate between '2025-11-02' and '2025-11-02'
	AND
	DeliveryCountry = 'GB'
GROUP BY ItemNo


SELECT
	ItemNo,
	Nov = SUM(NetOrderValueEst),
	Mkt = SUM(ISNULL(MarketingCostAct,0))
FROM Pl.PL_V_SALES_TRANSACTIONS_SM s
INNER JOIN PL.PL_V_ITEM it 
	on s.ItemId = it.ItemId
WHERE
	it.ItemNo = '10047455'
	--it.ProductHierarchy4 = 'Athena'
	AND
	TransactionDate between '2025-11-02' and '2025-11-02'
	AND
	DeliveryCountry = 'GB'
GROUP BY ItemNo


----marketing item
SELECT
	it.NUM_ITEM,
	AMT_MKT_COST_EUR = ROUND(SUM(isnull(fact.[AMT_COST_EUR_ATT],0)),2) 

FROM 
		[L1].L1_FACT_A_GOOGLE_ITEM_ATTRIBUTION fact
		INNER JOIN L1.L1_DIM_A_ITEM it on it.ID_ITEM = fact.ID_ITEM
WHERE
	it.NUM_ITEM ='10047455'
	AND
	D_CAMPAIGN between '2025-11-01' and '2025-11-01'
	AND
	CD_COUNTRY = 'GB'
GROUP BY it.NUM_ITEM



----marketing item
SELECT
	it.NUM_ITEM,
	AMT_MKT_COST_EUR = ROUND(SUM(isnull(fact.[AMT_COST_EUR_ATT],0)),2) 

FROM 
		[L1].L1_FACT_A_GOOGLE_ITEM_ATTRIBUTION fact
		INNER JOIN L1.L1_DIM_A_ITEM it on it.ID_ITEM = fact.ID_ITEM
WHERE
	--it.NUM_ITEM ='10047455'
	AND
	D_CAMPAIGN between '2025-11-01' and '2025-11-04'
	AND
	CD_COUNTRY = 'GB'
GROUP BY it.NUM_ITEM



select * from L1.L1_DIM_A_ITEM where num_item = '10047455' ---Athena

SELECT
	it.NUM_ITEM,
	AMT_MKT_COST_EUR = ROUND(SUM(isnull(fact.[AMT_COST_EUR_ATT],0)),2) 

FROM 
		[L1].L1_FACT_A_GOOGLE_ITEM_ATTRIBUTION fact
		INNER JOIN L1.L1_DIM_A_ITEM it on it.ID_ITEM = fact.ID_ITEM
WHERE
	--it.NUM_ITEM ='10047455'
	it.T_PRODUCT_HIERARCHY_4 = 'Athena'
	AND
	D_CAMPAIGN between '2025-11-02' and '2025-11-02'
	AND
	CD_COUNTRY = 'GB'
GROUP BY it.NUM_ITEM


select top 10 *
FROM Pl.PL_V_SALES_TRANSACTIONS_SM s