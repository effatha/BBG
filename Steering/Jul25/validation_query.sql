-- SELECT * FROM PL.PL_V_ITEM it  WHERE ItemNo in(10039858)
-- SELECT * FROM PL.PL_V_LAST_MEK WHERE ItemNo = 10045873
/**************************************************
**	New SM
***************************************************/

 SELECT 
	it.itemNo,
	NetOrderValue = SUM(NetOrderValueEst),
	NetOrderQuantity = SUM(NetOrderQuantityEst),
	Revenue = SUM(RevenueEst),
	Commissions = SUM([CommissionsEstSM]),
	Marketing = SUM([MarketingAttributionEstSM]),
	Shipping = SUM(FulfillmentOutboundEst),
	Cogs = SUM([FullNetProductCostSM]),
	CogsOld = SUM([NetProductcostEst]),
	SteeringMargin = SUM(SteeringMarginEstSM),
	[Steeringmargin%] = SUM(SteeringMarginEstSM) / SUM(RevenueEst)
 FROM TEST.PL_V_SALES_TRANSACTIONS_SM sales
 INNER JOIN PL.PL_V_ITEM it 
	on  it.ItemID = sales.ItemId
 WHERE
	TransactionYear = 2025
	AND
	TransactionMonth = 6
	AND
	ItemNo = 10034666

GROUP BY it.itemNo
HAVING  SUM(RevenueEst) >0 
ORDER BY SUM(SteeringMarginEstSM) / SUM(RevenueEst) desc




 SELECT 
	it.itemNo,DeliveryCountryGroup,
	NetOrderValue = SUM(NetOrderValueEst),
	NetOrderQuantity = SUM(NetOrderQuantityEst),
	Revenue = SUM(RevenueEst),
	Commissions = SUM([CommissionsEstSM]),
	Marketing = SUM([MarketingAttributionEstSM]),
	Shipping = SUM(FulfillmentOutboundEst),
	Cogs = SUM([FullNetProductCostSM]),
	CogsOld = SUM([NetProductcostEst]),
	SteeringMargin = SUM(SteeringMarginEstSM),
	[Steeringmargin%] = SUM(SteeringMarginEstSM) / SUM(RevenueEst)
 FROM TEST.PL_V_SALES_TRANSACTIONS_SM sales
 INNER JOIN PL.PL_V_ITEM it 
	on  it.ItemID = sales.ItemId
 WHERE
	TransactionYear = 2025
	AND
	TransactionMonth = 6
	AND
	ItemNo = 10034666

GROUP BY it.itemNo,DeliveryCountryGroup
HAVING  SUM(RevenueEst) >0 
ORDER BY SUM(SteeringMarginEstSM) / SUM(RevenueEst) desc

 SELECT 
	it.itemNo,Channelgroup1,
	NetOrderValue = SUM(NetOrderValueEst),
	NetOrderQuantity = SUM(NetOrderQuantityEst),
	Revenue = SUM(RevenueEst),
	Commissions = SUM([CommissionsEstSM]),
	Marketing = SUM([MarketingAttributionEstSM]),
	Shipping = SUM(FulfillmentOutboundEst),
	Cogs = SUM([FullNetProductCostSM]),
	CogsOld = SUM([NetProductcostEst]),
	SteeringMargin = SUM(SteeringMarginEstSM),
	[Steeringmargin%] = SUM(SteeringMarginEstSM) / SUM(RevenueEst)
 FROM TEST.PL_V_SALES_TRANSACTIONS_SM sales
 INNER JOIN PL.PL_V_ITEM it 
	on  it.ItemID = sales.ItemId
 INNER JOIN PL.PL_V_SALES_CHANNEL ch 
	on ch.ChannelId = sales.ChannelId
 WHERE
	TransactionYear = 2025
	AND
	TransactionMonth = 6
	AND
	ItemNo = 10034666

GROUP BY it.itemNo,Channelgroup1
HAVING  SUM(RevenueEst) >0 
ORDER BY SUM(SteeringMarginEstSM) / SUM(RevenueEst) desc












 SELECT 
	it.itemNo,
	ch.ChannelGroup1,
	MaxMEK = MAX(MEKHedging),
	MinMEK = MIN(MEKHedging),
	NetOrderValue = SUM(NetOrderValueEst),
	Revenue = SUM(RevenueEst),
	Commissions = SUM([CommissionsEstSM]),
	Marketing = SUM([MarketingAttributionEstSM]),
	Shipping = SUM(FulfillmentOutboundEst),
	Cogs = SUM([FullNetProductCostSM]),
	SteeringMargin = SUM(SteeringMarginEstSM),
	[Steeringmargin%] = SUM(SteeringMarginEstSM) / SUM(RevenueEst)
 FROM TEST.PL_V_SALES_TRANSACTIONS_SM sales
 INNER JOIN PL.PL_V_ITEM it 
	on  it.ItemID = sales.ItemId
 INNER JOIN PL.PL_V_SALES_CHANNEL ch 
	on ch.ChannelId = sales.ChannelId
 WHERE
	TransactionYear = 2025
	AND
	TransactionMonth = 6
	AND
	ItemNo = 10033235
GROUP BY it.itemNo,ch.ChannelGroup1
HAVING  SUM(RevenueEst) >0
ORDER BY SUM(SteeringMarginEstSM) / SUM(RevenueEst) DESC

--SELECT TOP 10 *  FROM  [L1].[L1_DIM_A_CS_COMMISSIONS_MARKETPLACES]
--where 
--	D_VALID_FROM  = 'Marketplaces CEE'




 SELECT TransactionMonth,
	Marketing = SUM([MarketingAttributionEstSM])
 FROM TEST.PL_V_SALES_TRANSACTIONS_SM sales
 INNER JOIN PL.PL_V_ITEM it 
	on  it.ItemID = sales.ItemId
 WHERE
	TransactionYear = 2025
	--AND
	--TransactionMonth = 6
Group by TransactionMonth


SELECT TOP 10 *
FROM 
	[TEST].[PL_V_SALES_TRANSACTIONS_SM]
WHERE 
	TRANSACTIOnYEAR = 2024
	AND TransactionMonth = 7
	AND DeliveryCountryGroup = 'DE'
	and channelgroup3= 'Shop WE'
	and TransactionTypeShort = 'ZAA'

SELECT *
FROM 	[Pl].[PL_V_SALES_TRANSACTIONS]
WHERE 
SalesTransactionCode = '0406195112#000100'


SELECT *
FROM 	[L1].L1_FACT_A_SALES_TRANSACTION
WHERE 
CD_SALES_TRANSACTION = '0406195112#000100'
