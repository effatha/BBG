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





SELECT TOP (100) [T_SAP_ENTITY_NAME]
,[T_SAP_ENTITY_TYPE]
,[T_PRIMARY_KEYS]
,[T_PRIMARY_KEYS_NUM_CHECK]
,[T_DAILY_RUN_MODE]
,[B_DAILY_RUN_ACTIVE]
,[T_THEOBALD_SETUP_MODE]
,[T_THEOBALD_VM]
,[T_SAP_SOURCE]
,[T_ENV_DESTINATION]
,[T_LOAD_COLUMNS]
,[T_ADLS_PATH]
,[T_LOAD_GROUP]
 FROM [MD].[MD_S4HANA_LOAD_LIST]
 WHERE T_LOAD_GROUP = 'evening_full'