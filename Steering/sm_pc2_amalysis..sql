/********************************************************************
This script is a query designed to analyze salesmargin performance across different 
dimensions ( Item,product hierarchy, country group, channel group) 
by comparing mostly the PC levels and Steering margin.

For the effect this uses 4 different types of metrics / datasets

1. CPnL
Pulls actual sales data from PL.PL_V_SALES_TRANSACTIONS, the current CPnl
Aggregates NetOrderValueEst, RevenueEst, PC1, PC2, PC3, and marketing costs (attributed + marketing marketplaces).

The output fields related to this will have the suffix [*_CPnL]

2. Steering margin
Pulls data from TEST.PL_V_SALES_TRANSACTIONS_SM. This is new view with the sales data but used to calculate the Steering margin
Aggregates SteeringMarginEstSM and marketing attribution. (rates from the business plan)

The output fields related to this will have the suffix [*_SM]

3- Steering margin - Forecast
Pulls forecast data from PL_V_BUSINESS_PLAN_KPI_SM.
Aggregates forecasted NOV, revenue, SM, and marketing costs, based on teh Live business plan but leveled up to the Financial targets.
Example: Businness Plan NOV = 1000 ; Financial Target = 1100; this results in each combination(Item/country/channel) to have the NOV increased by 10%

This is waht is represented in Forecast Fulfillment Dashboard

The output fields related to this will have the suffix [*_FC]


4. Business Plan - Forecast
Pulls forecast data from PL_V_BUSINESS_PLAN_KPI.
Aggregates forecasted NOV, revenue, PC1–PC3, and marketing costs.

This is what is represented in Live Business Plan Dashboard

The output fields related to this will have the suffix [*_PLAN]


*******************************************************************/


with cte_cpnl as
(
	SELECT 
		ItemNo,
		CountryGroup = ISNULL(cc.CD_COUNTRY,'INT'),
		ProductHierarchy1,
		ProductHierarchy2,
		ProductHierarchy3,
		ProductHierarchy4,
		ChannelGroup3,
		NOV = SUM(NetOrderValueEst),
		Revenue = SUM(RevenueEst),
		PC1 = SUM(PC1),
		PC2 = SUM(PC2),
		PC3 = SUM(PC3),
		MarketingCost_CPnL = SUM(ISNULL([MarketingShops],0)) + SUM(ISNULL(MarketingAmazon,0)) +SUM(ISNULL(MarketingMarketplacesEst,0)) 
	FROM PL.PL_V_SALES_TRANSACTIONS sales
	INNER JOIN PL.PL_V_ITEM it 
			on it.ItemId = sales.ItemId
	INNER JOIN PL.PL_V_SALES_CHANNEL ch 
			on ch.ChannelId = sales.ChannelId
	LEFT JOIN TEST.L0_MI_COUNTRY_GROUP cc
			on cc.CD_COUNTRY = sales.DeliveryCountry
	WHERE 1=1
		AND TransactionYear = 2025
		AND TransactionMonth < 8
		AND (NetOrderValueEst=0 OR ABS(ISNULL(PC2,0))>0)
		AND ISNULL(IncidentFlag,'N') = 'N'
	GROUP BY
		ItemNo,
		ISNULL(cc.CD_COUNTRY,'INT'),
		ProductHierarchy1,
		ProductHierarchy2,
		ProductHierarchy3,
		ProductHierarchy4,
		ChannelGroup3
),
cte_SM as
(
	SELECT 
		ItemNo,
		CountryGroup = 		ISNULL(cc.CD_COUNTRY,'INT'),
		ProductHierarchy1,
		ProductHierarchy2,
		ProductHierarchy3,
		ProductHierarchy4,
		ch.ChannelGroup3,
		NOV = SUM(NetOrderValueEst),
		Revenue = SUM(RevenueEst),
		SM = SUM(ISNULL(SteeringMarginEstSM,0)),
		MarketingCost_SM = SUM(ISNULL(MarketingAttributionEstSM,0)) + SUM(ISNULL(MarketingMarketplacesEst,0))

	FROM TEST.PL_V_SALES_TRANSACTIONS_SM sales
	INNER JOIN PL.PL_V_ITEM it 
			on it.ItemId = sales.ItemId
	INNER JOIN PL.PL_V_SALES_CHANNEL ch 
			on ch.ChannelId = sales.ChannelId
	LEFT JOIN TEST.L0_MI_COUNTRY_GROUP cc
			on cc.CD_COUNTRY = sales.DeliveryCountry
	WHERE 1=1
		AND TransactionYear = 2025
		AND TransactionMonth < 8

		AND NetOrderValueEst>0
				AND ISNULL(IncidentFlag,'N') = 'N'

	GROUP BY
		ItemNo,
		ISNULL(cc.CD_COUNTRY,'INT'),
		ProductHierarchy1,
		ProductHierarchy2,
		ProductHierarchy3,
		ProductHierarchy4,
		ch.ChannelGroup3
),
cte_forecast_SM as
(
	SELECT 
		ItemNo,
		ChannelGroup3,
		CountryGroup = ISNULL(cc.CD_COUNTRY,'INT'),
		Nov_FC = SUM(NetOrderValueEst),
		Revenue_FC = SUM(RevenueESt),
		SM_FC = SUM(SteeringMarginPlanSM),
		MarketingCost_FC = SUM(ISNULL(MarketingAttributionPlanEurSM,0))
	FROM TEST.[PL_V_BUSINESS_PLAN_KPI_SM] bs
	INNER JOIN PL.PL_V_ITEM it 
			on it.ItemId = bs.ItemId
	LEFT JOIN TEST.L0_MI_COUNTRY_GROUP cc
			on cc.CD_COUNTRY = bs.CountryGroup
	WHERE
		TargetMonth < 8
		AND
		TargetYear = 2025
		AND 
		NetOrderValueEst >0
	GROUP BY ItemNo,
		ChannelGroup3,
		ISNULL(cc.CD_COUNTRY,'INT')
),
cte_forecast_fc as
(
	SELECT 
		ItemNo,
		ChannelGroup3,
		CountryGroup = ISNULL(cc.CD_COUNTRY,'INT'),
		NOV_Plan = SUM(NetOrderValueEst),
		Revenue_Plan = SUM(RevenueEst),
		PC1_Plan = SUM(PC1Est),
		PC2_Plan = SUM(PC2Est),
		PC3_Plan = SUM(PC3Est),
		MarketingCost_Plan = SUM(ISNULL([MarketingShops],0)) + SUM(ISNULL(MarketingAmazon,0)) +SUM(ISNULL(MarketingMarketplacesEst,0)) 
	FROM PL.[PL_V_BUSINESS_PLAN_KPI] bs
	INNER JOIN PL.PL_V_ITEM it 
			on it.ItemId = bs.ItemId
	LEFT JOIN TEST.L0_MI_COUNTRY_GROUP cc
			on cc.CD_COUNTRY = bs.Country
	WHERE
		TargetMonth < 8
		AND
		TargetYear = 2025
		AND 
		NetOrderValueEst >0
	GROUP BY ItemNo,
		ChannelGroup3,
		ISNULL(cc.CD_COUNTRY,'INT')
),
cte_final_sales as 
(
SELECT
		ItemNo				= ISNULL(cp.ItemNo,sm.ItemNo),
		CountryGroup 		= ISNULL(cp.CountryGroup,sm.CountryGroup),
		ProductHierarchy1	= ISNULL(cp.ProductHierarchy1,sm.ProductHierarchy1),
		ProductHierarchy2	= ISNULL(cp.ProductHierarchy2,sm.ProductHierarchy2),
		ProductHierarchy3	= ISNULL(cp.ProductHierarchy3,sm.ProductHierarchy3),
		ProductHierarchy4	= ISNULL(cp.ProductHierarchy4,sm.ProductHierarchy4),
		ChannelGroup3		= ISNULL(cp.ChannelGroup3,sm.ChannelGroup3),
		NOV_CPnL			= ISNULL(cp.NOV,0),
		NOV_SM				= ISNULL(sm.NOV,0),
		MarketingCost_SM	= ISNULL(sm.MarketingCost_SM,0),
		MarketingCost_CPnL	= ISNULL(cp.MarketingCost_CPnL,0),
		--MarketingCost_FC	= sm.MarketingCost_FC,
		--MarketingCost_PLAN	= sm.MarketingCost_PLAN,
		Revenue_CPnL		= cp.Revenue,
		Revenue_SM			= sm.Revenue,
		PC1_CPnL			= cp.PC1,
		PC2_CPnL			= cp.PC2,
		PC3_CPnL			= cp.PC3,
		SM					= sm.SM
FROM cte_cpnl cp
FULL JOIN cte_SM sm
	on cp.ItemNo = sm.ItemNo
		AND
		cp.ChannelGroup3 = sm.ChannelGroup3
		AND
		cp.CountryGroup = sm.CountryGroup

)
SELECT
	sales.*,
	NOV_FC = fcsm.Nov_FC,
	NOV_Plan = fcf.Nov_Plan,
	Revenue_FC = fcsm.Revenue_FC,
	Revenue_Plan = fcf.Revenue_Plan,
	NOV_CPnL_FF = FORMAT(sales.NOV_CPnL/ fcsm.Nov_FC,'P2'),
	NOV_SM_FF = FORMAT(sales.NOV_SM / fcsm.Nov_FC,'P2'),
	MarketingCost_CPnL = ABS(MarketingCost_CPnL),
	MarketingCost_SM = ABS(MarketingCost_SM),
	MarketingCost_FC = ABS(MarketingCost_FC),
	MarketingCost_Plan = ABS(MarketingCost_Plan),
	[MarketingCost_CPnL%] = FORMAT(CASE WHEN ISNULL(Revenue_CPnL,0) = 0 THEN 0 ELSE ABS(MarketingCost_CPnL)/Revenue_CPnL END,'P2'),
	[MarketingCost_SM%] = FORMAT(CASE WHEN ISNULL(Revenue_SM,0) = 0 THEN 0 ELSE ABS(MarketingCost_SM)/Revenue_SM END,'P2'),
	[MarketingCost_FC%] = FORMAT(CASE WHEN ISNULL(Revenue_FC,0) = 0 THEN 0 ELSE ABS(MarketingCost_FC)/Revenue_FC END,'P2'),
	[MarketingCost_Plan%] = FORMAT(CASE WHEN ISNULL(Revenue_Plan,0) = 0 THEN 0 ELSE ABS(MarketingCost_Plan)/Revenue_Plan END,'P2'),
	SM = sales.SM,
	SM_FC = fcsm.SM_FC,
	SM_FF = FORMAT(CASE WHEN ISNULL(fcsm.SM_FC,0) = 0 and ISNULL(sales.SM,0)> 0 THEN 1 ELSE sales.SM/fcsm.SM_FC END,'P2'),
	[SM%] = FORMAT(CASE WHEN ISNULL(fcsm.Revenue_FC,0) = 0 and ISNULL(sales.SM,0)> 0 THEN 1 ELSE sales.SM/fcsm.Revenue_FC END,'P2'),

	PC1_Plan = fcf.PC1_Plan,
	PC2_Plan = fcf.PC2_Plan,
	PC3_Plan = fcf.PC3_Plan,

	[PC1%] =   FORMAT(CASE WHEN ISNULL(sales.Revenue_CPnL,0) = 0 THEN 0 ELSE sales.PC1_CPnL/sales.Revenue_CPnL END,'P2') ,
	[PC1_Plan%] =  FORMAT(fcf.PC1_Plan/fcf.Revenue_Plan,'P2'),
	[PC2%] =   FORMAT(CASE WHEN ISNULL(sales.Revenue_CPnL,0) = 0 THEN 0 ELSE sales.PC2_CPnL/sales.Revenue_CPnL END,'P2') ,
	--[PC2%] =  FORMAT(sales.PC2_CPnL/sales.Revenue_CPnL,'P2'),
	[PC2_Plan%] =  FORMAT(fcf.PC2_Plan/fcf.Revenue_Plan,'P2'),
	--[PC3%] =  FORMAT(sales.PC3_CPnL/sales.Revenue_CPnL,'P2'),
	[PC3%] =   FORMAT(CASE WHEN ISNULL(sales.Revenue_CPnL,0) = 0 THEN 0 ELSE sales.PC3_CPnL/sales.Revenue_CPnL END,'P2') ,
	[PC3_Plan%] =  FORMAT(fcf.PC3_Plan/fcf.Revenue_Plan,'P2'),

	--PC1_FF = FORMAT(CASE WHEN ISNULL(fcf.PC1_Plan,0) = 0  THEN 0 ELSE (sales.PC1_CPnL / fcf.PC1_Plan) END,'P2'),
	[PC1_FF] =   FORMAT(CASE WHEN ISNULL(fcf.PC1_Plan,0) = 0 THEN 0 ELSE sales.PC1_CPnL/fcf.PC1_Plan END,'P2') ,

	PC2_FF = FORMAT(CASE WHEN ISNULL(fcf.PC2_Plan,0) = 0  THEN 0 ELSE (sales.PC2_CPnL / fcf.PC2_Plan) END,'P2'),
	PC3_FF = FORMAT(CASE WHEN ISNULL(fcf.PC3_Plan,0) = 0  THEN 0 ELSE (sales.PC3_CPnL / fcf.PC3_Plan) END,'P2')

FROM 
cte_final_sales sales
LEFT JOIN cte_forecast_sm fcsm
	on sales.ItemNo = fcsm.ItemNo
		and
		sales.ChannelGroup3 = fcsm.ChannelGroup3
		AND
		sales.CountryGroup = fcsm.CountryGroup
LEFT JOIN cte_forecast_fc fcf
	on sales.ItemNo = fcf.ItemNo
		and
		sales.ChannelGroup3 = fcf.ChannelGroup3
		AND
		sales.CountryGroup = fcf.CountryGroup

