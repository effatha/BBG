DECLARE @MONTH_DATE AS date= '2025-01-01'
DECLARE @Channel VARCHAR(50)= ''
DECLARE @Country VARCHAR(50)= ''

;WITH CTE_NEW AS
(
	SELECT
		Dataset = 'New BP',
		TargetMonth = @MONTH_DATE,
		ItemId =	ID_ITEM,
		MEK = MAX([AMT_MEK_HEDGING_EUR]),
		GTS = MAX([AMT_GTS_MARKUP_EUR]),
		ChannelGroup = [CD_CHANNEL_GROUP_3],
		CountryGroup = [CD_COUNTRY_GROUP],
		NetOrderValue = SUM([AMT_NET_ORDER_VALUE_FC_EUR]),
		RefundOrderValue = SUM([AMT_REFUNDED_ORDER_VALUE_FC_EUR]),
		Revenue = SUM([AMT_REVENUE_FC_EUR]),
		CogsProduct= SUM([AMT_FULL_NET_PRODUCT_COST_FC_EUR] ),
		MekToCustomer= SUM([AMT_MEK_TO_CUSTOMER_FC_EUR] ),
		ShippingOutbound= SUM(AMT_SHIPPING_OUTBOUND_FC_EUR),
		Commissions= SUM([AMT_COMMISSIONS_FC_EUR]),
		MarketingCost= SUM([AMT_MARKETING_COST_EUR]),
		ElectronicWasteEst= SUM(AMT_ENVIRO_AND_LICENSE_COST_FC_EUR),
		SteeringMargin= SUM([AMT_STEERING_MARGIN_FC_EUR])
	FROM [L1].[L1_FACT_F_BUSINESS_PLAN_KPI_SM] fact
	WHERE 1=1
		AND YEAR(fact.D_TARGET) = YEAR(@MONTH_DATE)
		AND	MONTH(fact.D_TARGET) = MONTH(@MONTH_DATE)
		AND ([CD_CHANNEL_GROUP_3] = @Channel OR @Channel = '')
		AND ([CD_COUNTRY_GROUP] = @Country OR @Country = '')

	GROUP BY
		YEAR(fact.D_TARGET),
		MONTH(fact.D_TARGET),
		[CD_CHANNEL_GROUP_3],
		[CD_COUNTRY_GROUP],
		ID_ITEM
		
),
CTE_OLD AS
(
	SELECT
		Dataset = 'OLD BP',
		TargetMonth = @MONTH_DATE,
		ItemId =	ID_ITEM,
		MEK = MAX([AMT_MEK_HEDGING_EUR]),
		GTS = MAX([AMT_GTS_MARKUP_EUR]),
		ChannelGroup = [CD_CHANNEL_GROUP_3],
		CountryGroup = [CD_COUNTRY_GROUP],
		NetOrderValue = SUM(AMT_NET_ORDER_VALUE_EST_EUR),
		RefundOrderValue = SUM(AMT_REFUNDED_ORDER_VALUE_EST_EUR),
		Revenue = SUM(AMT_REVENUE_EST_EUR),
		CogsProduct	= SUM(AMT_FULL_NET_PRODUCT_COST_PLAN_EUR_SM),
		MekToCustomer= SUM(AMT_MEK_TO_CUSTOMER_PLAN_EUR_SM ),
		ShippingOutbound= SUM(AMT_FULFILLMENT_OUTBOUND_EST_EUR),
		Commissions= SUM(AMT_COMMISSIONS_PLAN_EUR_SM),
		MarketingCost= SUM(AMT_MARKETING_ATTRIBUTION_PLAN_EUR_SM),
		ElectronicWasteEst= SUM([AMT_ENVIRO_AND_LICENSE_COST_EST_EUR]),
		SteeringMargin= SUM(AMT_STEERING_MARGIN_PLAN_EUR_SM)
	FROM TEST.[L1_FACT_F_BUSINESS_PLAN_KPI_SM] fact
	WHERE 1=1
		AND YEAR(fact.D_TARGET) = YEAR(@MONTH_DATE)
		AND	MONTH(fact.D_TARGET) = MONTH(@MONTH_DATE)
		AND ([CD_CHANNEL_GROUP_3] = @Channel OR @Channel = '')
		AND ([CD_COUNTRY_GROUP] = @Country OR @Country = '')
	GROUP BY

		[CD_CHANNEL_GROUP_3],
		[CD_COUNTRY_GROUP],
		ID_ITEM,
		YEAR(fact.D_TARGET),
		MONTH(fact.D_TARGET)

)
SELECT 
	TargetMonth = ISNULL(n.TargetMonth,o.TargetMonth)
	,ChannelGroup = ISNULL(n.ChannelGroup,o.ChannelGroup)
	,CountryGroup = ISNULL(n.CountryGroup,o.CountryGroup)
	,ItemId = ISNULL(n.ItemId,o.ItemId)

	,NEW_MEK = ISNULL(n.MEK,0)
	,OLD_MEK = ISNULL(o.MEK,0)
	,DIFF_MEK = ISNULL(n.MEK,0) -  ISNULL(o.MEK,0)

	,NEW_GTS = ISNULL(n.GTS,0)
	,OLD_GTS = ISNULL(o.GTS,0)
	,DIFF_GTS = ISNULL(n.GTS,0) -  ISNULL(o.GTS,0)

	,NEW_NetOrderValue = ISNULL(n.NetOrderValue,0)
	,OLD_NetOrderValue = ISNULL(o.NetOrderValue,0)
	,DIFF_NetOrderValue = ISNULL(n.NetOrderValue,0) -  ISNULL(o.NetOrderValue,0)
	
	,NEW_RefundOrderValue = ISNULL(n.RefundOrderValue,0)
	,OLD_RefundOrderValue = ISNULL(o.RefundOrderValue,0)
	,DIFF_RefundOrderValue = ISNULL(n.RefundOrderValue,0) -  ISNULL(o.RefundOrderValue,0)

	,NEW_Revenue = ISNULL(n.Revenue,0)
	,OLD_Revenue = ISNULL(o.Revenue,0)
	,DIFF_Revenue = ISNULL(n.Revenue,0) -  ISNULL(o.Revenue,0)

	,NEW_CogsProduct = ISNULL(n.CogsProduct,0)
	,OLD_CogsProduct = ISNULL(o.CogsProduct,0)
	,DIFF_CogsProduct = ISNULL(n.CogsProduct,0) -  ISNULL(o.CogsProduct,0)

	,NEW_MekToCustomer = ISNULL(n.MekToCustomer,0)
	,OLD_MekToCustomer = ISNULL(o.MekToCustomer,0)
	,DIFF_MekToCustomer = ISNULL(n.MekToCustomer,0) -  ISNULL(o.MekToCustomer,0)

	,NEW_ShippingOutbound = ISNULL(n.ShippingOutbound,0)
	,OLD_ShippingOutbound = ISNULL(o.ShippingOutbound,0)
	,DIFF_ShippingOutbound = ISNULL(n.ShippingOutbound,0) -  ISNULL(o.ShippingOutbound,0)

	,NEW_Commissions = ISNULL(n.Commissions,0)
	,OLD_Commissions = ISNULL(o.Commissions,0)
	,DIFF_Commissions = ISNULL(n.Commissions,0) -  ISNULL(o.Commissions,0)

	,NEW_MarketingCost = ISNULL(n.MarketingCost,0)
	,OLD_MarketingCost = ISNULL(o.MarketingCost,0)
	,DIFF_MarketingCost = ISNULL(n.MarketingCost,0) -  ISNULL(o.MarketingCost,0)

	,NEW_ElectronicWasteEst = ISNULL(n.ElectronicWasteEst,0)
	,OLD_ElectronicWasteEst = ISNULL(o.ElectronicWasteEst,0)
	,DIFF_ElectronicWasteEst = ISNULL(n.ElectronicWasteEst,0) -  ISNULL(o.ElectronicWasteEst,0)

	,NEW_SteeringMargin = ISNULL(n.SteeringMargin,0)
	,OLD_SteeringMargin = ISNULL(o.SteeringMargin,0)
	,DIFF_SteeringMargin = ISNULL(n.SteeringMargin,0) -  ISNULL(o.SteeringMargin,0)
FROM CTE_NEW n
FULL JOIN CTE_OLD o
	ON 
		o.TargetMonth = n.TargetMonth
		AND
		o.ChannelGroup = n.ChannelGroup
		AND
		o.CountryGroup = n.CountryGroup
		AND
		o.ItemId = n.ItemId
order by 
 ISNULL(n.MekToCustomer,0) -  ISNULL(o.MekToCustomer,0) desc
--1 desc




--SELECT TOP 100 *	FROM TEST.[L1_FACT_F_BUSINESS_PLAN_SM] fact where id_item = 269 and[CD_COUNTRY_GROUP] = 'INT' and [CD_CHANNEL_GROUP_3] = 'Amazon' and D_TARGET between '2025-01-01' and '2025-01-31'
--SELECT TOP 100 *	FROM L1.[L1_FACT_F_BUSINESS_PLAN_KPI_SM] fact where id_item = 269 and[CD_COUNTRY_GROUP] = 'INT'and [CD_CHANNEL_GROUP_3] = 'Amazon' and D_TARGET = '2025-01-01'
--SELECT TOP 100 *	FROM TEST.[L1_FACT_F_BUSINESS_PLAN_KPI_SM] fact where id_item = 269 and[CD_COUNTRY_GROUP] = 'INT' and [CD_CHANNEL_GROUP_3] = 'Amazon' and D_TARGET between '2025-01-01' and '2025-01-31'

--SELECT TOP 10 *	FROM L1.[L1_FACT_F_BUSINESS_PLAN] fact where id_item = 13755 and[CD_COUNTRY_GROUP] = 'de' and [CD_CHANNEL_GROUP_3] = 'Amazon' and D_TARGET = '2025-01-01'
--SELECT TOP 10 *	FROM L1.[L1_FACT_F_BOTTOM_LINE_FORECAST_HISTORY] fact where id_item = 13755 and[CD_COUNTRY_GROUP] = 'de' and [CD_CHANNEL_GROUP_3] = 'Amazon' and D_TARGET = '2025-01-01'

--SELECT top 100 * FROM PL.PL_V_MEK_HISTORY WHERE Itemno = 10034553 and [Date] = '2025-07-24'  and ItemType = '100'
--SELECT top 100 * FROM PL.PL_V_MEK_HISTORY WHERE Itemno = 10034553 and [Date] = '2025-10-13' and  ItemType = '100'

--SELECT top 10 * FROM PL.PL_V_item WHERE Itemid = 8950



	SELECT
		Dataset = 'New BP',
		TargetMonth = MONTH(fact.D_TARGET),
		NetOrderValue = SUM([AMT_NET_ORDER_VALUE_FC_EUR]),
		RefundOrderValue = SUM([AMT_REFUNDED_ORDER_VALUE_FC_EUR]),
		Revenue = SUM([AMT_REVENUE_FC_EUR]),
		CogsProduct= SUM([AMT_FULL_NET_PRODUCT_COST_FC_EUR] ),
		MekToCustomer= SUM([AMT_MEK_TO_CUSTOMER_FC_EUR] ),
		ShippingOutbound= SUM(AMT_SHIPPING_OUTBOUND_FC_EUR),
		Commissions= SUM([AMT_COMMISSIONS_FC_EUR]),
		MarketingCost= SUM([AMT_MARKETING_COST_EUR]),
		ElectronicWasteEst= SUM(AMT_ENVIRO_AND_LICENSE_COST_FC_EUR),
		SteeringMargin= SUM([AMT_STEERING_MARGIN_FC_EUR])
	FROM [L1].[L1_FACT_F_BUSINESS_PLAN_KPI_SM_v2] fact

	GROUP BY
		YEAR(fact.D_TARGET),
		MONTH(fact.D_TARGET)
	order by 1


	select TOP 100 * 
	FROM [L1].[L1_FACT_F_BUSINESS_PLAN_KPI_SM_v2] fact 
	where 1=1
	--AMT_MEK_HEDGING_EUR = 0
	--AND ID_ITEM IS NULL##
	AND VL_ITEM_QUANTITY = 0
	AND
	ID_ITEM_BUSINESS_PLAN = 124389
	AND
	CD_COUNTRY_GROUP = 'INT'
	AND
	CD_CHANNEL_GROUP_3 = 'MarketplacesWE'
	AND
	D_TARGET = '2025-01-01'
	
	
	select top 10 * 
	FROM [L1].[L1_FACT_F_BUSINESS_PLAN_KPI_SM] fact 
	where VL_REFUND_RATE = 0
	--ID_ITEM IS NULL
	--AND
	ID_ITEM_BUSINESS_PLAN = 124389
	AND
	CD_COUNTRY_GROUP = 'INT'
	AND
	CD_CHANNEL_GROUP_3 = 'MarketplacesWE'
	AND
	D_TARGET = '2025-01-01'



	select * 
	FROM [L1].[L1_FACT_F_BUSINESS_PLAN] fact 
	where 
	ID_ITEM = 22600
	AND
	CD_COUNTRY_GROUP = 'NL'
	AND
	CD_CHANNEL_GROUP_3 = 'MarketplacesWE'
	AND
	D_TARGET = '2025-01-01'


	SELECT *
	FROM L1.[L1_FACT_F_BOTTOM_LINE_FORECAST_HISTORY] fact
	WHERE 
		1=1
	AND ID_ITEM = 22600
	AND
	CD_COUNTRY_GROUP = 'NL'
	AND
	CD_CHANNEL_GROUP_3 = 'MarketplacesWE'
	AND
	D_TARGET = '2025-01-01'



	;WITH bp_global as (
	
	SELECT CD_CHANNEL_GROUP_3, D_TARGET,SUM(AMT_TARGET_NET_ORDER_VALUE_EUR) BP_NOV,SUM(VL_ITEM_QUANTITY) BP_NOQ
	FROM [L1].[L1_FACT_F_BUSINESS_PLAN] bs
	 
	GROUP BY CD_CHANNEL_GROUP_3, D_TARGET
	HAVING SUM(VL_ITEM_QUANTITY) > 0
)

, cte_fc_factor as (
SELECT 
	bp.CD_CHANNEL_GROUP_3,
	bp.D_TARGET,
	bp.BP_NOV,
	fc.NOV,
	FCNOVFactor = (NOV-BP_NOV)/NOV ,
	bp.BP_NOQ,
	fc.NOQ,
	FCNOQFactor = CASE WHEN ISNULL(NOQ,0) > 0 THEN (NOQ-BP_NOQ)/NOQ ELSE (NOV-BP_NOV)/NOV END
FROM bp_global bp
LEFT JOIN [L0].[L0_MI_BL_FORECAST_TARGETS] fc
	on REPLACE(fc.CHANNELGROUP3,' ','') = REPLACE(bp.CD_CHANNEL_GROUP_3,' ','')
	and cast(fc.TARGETMONTH as date) = bp.D_TARGET
	)
	SELECT                                    
       D_TARGET = ISNULL(run_rates.DATE_ADJUSTED,'2025-01-01')
	  ,b_plan.[ID_ITEM]
	  ,item.[NUM_ITEM]
      ,b_plan.[CD_CHANNEL_GROUP_3]
	  ,ISNULL(spl.CHANNELGROUP1,b_plan.[CD_CHANNEL_GROUP_3]) [CD_CHANNEL_GROUP_1]
	  ,b_plan.[CD_COUNTRY_GROUP]
	  ,b_plan.VL_ITEM_QUANTITY AS VLLLLLLQTY
      ,b_plan.[AMT_PLAN_PRICE_EUR]
      ,[VL_ITEM_QUANTITY] = (b_plan.VL_ITEM_QUANTITY/(1-FCNOQFactor))* isnull(spl.NOQ_SHARE,1) *  ISNULL(CAST(run_rates.rr as decimal(19,9)) ,1)
      ,[AMT_TARGET_NET_ORDER_VALUE_EUR] =(b_plan.AMT_TARGET_NET_ORDER_VALUE_EUR /(1-FCNOVFactor))* isnull(spl.NOV_SHARE,1) *  ISNULL(CAST(run_rates.rr as decimal(19,9)) ,1)
      ,sysdatetime() as [DT_DWH_CREATED]
      ,sysdatetime() as [DT_DWH_UPDATED]
	
	from [L1].[L1_FACT_F_BUSINESS_PLAN] b_plan
	LEFT JOIN L0.L0_MI_BS_CHANNEL_SPLIT spl
		on spl.TARGET_DATE = b_plan.[D_TARGET]
		and REPLACE(spl.CHANNELGROUP3,' ','') = REPLACE(b_plan.[CD_CHANNEL_GROUP_3],' ','')
	LEFT JOIN L1.L1_DIM_A_ITEM item
    on item.[ID_ITEM] = b_plan.[ID_ITEM]
	LEFT JOIN [L0].L0_MI_FC_BL_RUN_RATES_bck20250930 run_rates
	on run_rates.[CategoryL1] = item.T_PRODUCT_HIERARCHY_1
	AND	run_rates.[CategoryL2] = item.T_PRODUCT_HIERARCHY_2
	AND	run_rates.[CategoryL3] = item.T_PRODUCT_HIERARCHY_3
	AND	REPLACE(run_rates.[CHANNELGROUP3],' ','') = REPLACE(b_plan.[CD_CHANNEL_GROUP_3],' ','')
	AND run_rates.[month] = MONTH(b_plan.[D_TARGET])
	LEFT JOIN cte_fc_factor factor
	on factor.CD_CHANNEL_GROUP_3 = b_plan.CD_CHANNEL_GROUP_3
	and factor.D_TARGET = b_plan.[D_TARGET]
	
	WHERE month(b_plan.D_TARGET) =1
	AND year(b_plan.D_TARGET) =2025
	AND b_plan.[ID_ITEM] =1850 --22600
	AND b_plan.[CD_CHANNEL_GROUP_3] = 'MarketplacesWE'
	AND b_plan.[CD_COUNTRY_GROUP]= 'NL'


	select * FROM [L1].[L1_FACT_F_BUSINESS_PLAN_KPI_SM_v2] fact WHERE vl_net_order_quantity = 0




		SELECT
		Dataset = 'New BP',
		TargetMonth = MONTH(fact.D_TARGET),
		NetOrderValue = SUM([AMT_NET_ORDER_VALUE_FC_EUR]),
		RefundOrderValue = SUM([AMT_REFUNDED_ORDER_VALUE_FC_EUR]),
		Revenue = SUM([AMT_REVENUE_FC_EUR]),
		CogsProduct= SUM([AMT_FULL_NET_PRODUCT_COST_FC_EUR] ),
		MekToCustomer= SUM([AMT_MEK_TO_CUSTOMER_FC_EUR] ),
		ShippingOutbound= SUM(AMT_SHIPPING_OUTBOUND_FC_EUR),
		Commissions= SUM([AMT_COMMISSIONS_FC_EUR]),
		MarketingCost= SUM([AMT_MARKETING_COST_EUR]),
		ElectronicWasteEst= SUM(AMT_ENVIRO_AND_LICENSE_COST_FC_EUR),
		SteeringMargin= SUM([AMT_STEERING_MARGIN_FC_EUR])
	FROM [L1].[L1_FACT_F_BUSINESS_PLAN_KPI_SM] fact

	GROUP BY
		YEAR(fact.D_TARGET),
		MONTH(fact.D_TARGET)
	order by 1

		SELECT
		Dataset = 'OLD BP',
		TargetMonth = MONTH(fact.D_TARGET),
		NetOrderValue = SUM(AMT_NET_ORDER_VALUE_EST_EUR),
		RefundOrderValue = SUM(AMT_REFUNDED_ORDER_VALUE_EST_EUR),
		Revenue = SUM(AMT_REVENUE_EST_EUR),
		CogsProduct	= SUM(AMT_FULL_NET_PRODUCT_COST_PLAN_EUR_SM),
		MekToCustomer= SUM(AMT_MEK_TO_CUSTOMER_PLAN_EUR_SM ),
		ShippingOutbound= SUM(AMT_FULFILLMENT_OUTBOUND_EST_EUR),
		Commissions= SUM(AMT_COMMISSIONS_PLAN_EUR_SM),
		MarketingCost= SUM(AMT_MARKETING_ATTRIBUTION_PLAN_EUR_SM),
		ElectronicWasteEst= SUM([AMT_ENVIRO_AND_LICENSE_COST_EST_EUR]),
		SteeringMargin= SUM(AMT_STEERING_MARGIN_PLAN_EUR_SM)
	FROM TEST.[L1_FACT_F_BUSINESS_PLAN_KPI_SM] fact
	WHERE YEAR(D_TARGET) = 2025
	GROUP BY
		YEAR(fact.D_TARGET),
		MONTH(fact.D_TARGET)
	order by 1
