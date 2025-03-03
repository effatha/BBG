select 	 D_TARGET							
	,it.num_item							
	,CD_COUNTRY_GROUP					
	,CD_CHANNEL_GROUP_3					
	,VL_ITEM_QUANTITY	=					 sum(VL_ITEM_QUANTITY)
	,AMT_PLAN_PRICE_TOTAL_EUR = SUM(AMT_PLAN_PRICE_EUR)
	,AMT_SHIPPING_COST_EST_EUR = SUM(AMT_SHIPPING_COST_EST_EUR)
	,AMT_MEK_HEDGING_EUR = SUM(AMT_MEK_HEDGING_EUR)
	,AMT_GTS_MARKUP_EUR = SUM(AMT_GTS_MARKUP_EUR)
	,VL_CANCELLED_ORDERS_QUANTITY_EST = SUM(VL_CANCELLED_ORDERS_QUANTITY_EST)
	,VL_NET_ORDER_QUANTITY = SUM(VL_NET_ORDER_QUANTITY)
	,VL_REFUNDED_QUANTITY_EST = SUM(VL_REFUNDED_QUANTITY_EST)
	,VL_RETURNED_QUANTITY_EST = SUM(VL_RETURNED_QUANTITY_EST)
	,VL_REPLACEMENT_ORDER_QUANTITY_EST = SUM(VL_REPLACEMENT_ORDER_QUANTITY_EST)
	,AMT_GROSS_ORDER_VALUE_EUR = SUM(AMT_GROSS_ORDER_VALUE_EUR)
	,AMT_CANCELLED_ORDER_VALUE_EST_EUR = SUM(AMT_CANCELLED_ORDER_VALUE_EST_EUR)
	,AMT_NET_ORDER_VALUE_EST_EUR = SUM(AMT_NET_ORDER_VALUE_EST_EUR)
	,AMT_REFUNDED_ORDER_VALUE_EST_EUR = SUM(AMT_REFUNDED_ORDER_VALUE_EST_EUR)
	,AMT_REVENUE_EST_EUR = SUM(AMT_REVENUE_EST_EUR)
	,AMT_DEPRECIATION_EST_EUR = SUM(AMT_DEPRECIATION_EST_EUR)
	,AMT_NET_PRODUCT_COST_EST_EUR = SUM(AMT_NET_PRODUCT_COST_EST_EUR)
	,AMT_PC0_EST_EUR = SUM(AMT_PC0_EST_EUR)
	,PCT_PC0 = CASE WHEN SUM(AMT_PC0_EST_EUR) = 0 or sum(AMT_REVENUE_EST_EUR) = 0 THEN 0 ELSE SUM(AMT_PC0_EST_EUR) / SUM(AMT_REVENUE_EST_EUR) END
	,AMT_DEMURRAGE_DETENTION_EUR = SUM(AMT_DEMURRAGE_DETENTION_EUR)
	,AMT_DEADFREIGHT_EUR = SUM(AMT_DEADFREIGHT_EUR)
	,AMT_KICKBACKS_EUR = SUM(AMT_KICKBACKS_EUR)
	,AMT_3RD_PARTY_SERVICES_EUR = SUM(AMT_3RD_PARTY_SERVICES_EUR)
	,AMT_RETURN_MERCHANDISE_AUTHORIZATION_EUR = SUM(AMT_RETURN_MERCHANDISE_AUTHORIZATION_EUR)
	,AMT_SAMPLES_EUR = SUM(AMT_SAMPLES_EUR)
	,AMT_OTHER_COGS_EFFECT_EST_EUR = SUM(AMT_OTHER_COGS_EFFECT_EST_EUR)
	,AMT_DROPSHIPMENT_CEOTRA9ER_EST_EUR = SUM(AMT_DROPSHIPMENT_CEOTRA9ER_EST_EUR)
	,AMT_INBOUND_FREIGHT_COST_EST_EUR = SUM(AMT_INBOUND_FREIGHT_COST_EST_EUR)
	,AMT_PO_CANCELLATION_EUR = SUM(AMT_PO_CANCELLATION_EUR)
	,AMT_STOCK_ADJUSTMENT_EUR = SUM(AMT_STOCK_ADJUSTMENT_EUR)
	,AMT_FX_HEDGING_IMPACT_EST_EUR = SUM(AMT_FX_HEDGING_IMPACT_EST_EUR)
	,AMT_COGS_STOCK_VALUE_ADJUSTMENT_EST_EUR = SUM(AMT_COGS_STOCK_VALUE_ADJUSTMENT_EST_EUR)
	,AMT_COGS_OPERATIONS_EST = SUM(AMT_COGS_OPERATIONS_EST)
	,AMT_PC1_EST_EUR = SUM(AMT_PC1_EST_EUR)
	,PCT_PC1 = CASE WHEN SUM(AMT_PC1_EST_EUR) = 0 or sum(AMT_REVENUE_EST_EUR) = 0 THEN 0 ELSE SUM(AMT_PC1_EST_EUR) / SUM(AMT_REVENUE_EST_EUR) END
	,AMT_PACKAGING_EUR = SUM(AMT_PACKAGING_EUR)
	,AMT_HANDLING_ORDERS_EST_EUR = SUM(AMT_HANDLING_ORDERS_EST_EUR)
	,AMT_HANDLING_INBOUND_EST_EUR = SUM(AMT_HANDLING_INBOUND_EST_EUR)
	,AMT_HANDLING_TRANS_SHIPPMENT_EST_EUR = SUM(AMT_HANDLING_TRANS_SHIPPMENT_EST_EUR)
	,AMT_TRUCKING_TRANS_SHIPMENT_EST_EUR = SUM(AMT_TRUCKING_TRANS_SHIPMENT_EST_EUR)
	,AMT_HANDLING_RETURNS_EST_EUR = SUM(AMT_HANDLING_RETURNS_EST_EUR)
	,AMT_WAREHOUSING_FBA_EUR = SUM(AMT_WAREHOUSING_FBA_EUR)
	,AMT_FULFILLMENT_OUTBOUND_EST_EUR = SUM(AMT_FULFILLMENT_OUTBOUND_EST_EUR)
	,AMT_COMMISSIONS_MARKETPLACES_EUR = SUM(AMT_COMMISSIONS_MARKETPLACES_EUR)
	,AMT_COMMISSIONS_MARKETPLACES_REFUNDS_EUR = SUM(AMT_COMMISSIONS_MARKETPLACES_REFUNDS_EUR)
	,AMT_MARKETING_MARKETPLACES_EST_EUR = SUM(AMT_MARKETING_MARKETPLACES_EST_EUR)
	,AMT_COMMISSIONS_AMAZON_EUR = SUM(AMT_COMMISSIONS_AMAZON_EUR)
	,AMT_COMMISSIONS_AMAZON_REFUNDS_EUR = SUM(AMT_COMMISSIONS_AMAZON_REFUNDS_EUR)
	,AMT_SHOP_MARKETING_EUR = SUM(AMT_SHOP_MARKETING_EUR)
	,AMT_CS_HANDLING_CLAIMS_EUR = SUM(AMT_CS_HANDLING_CLAIMS_EUR)
	,AMT_PAYMENTS_EUR = SUM(AMT_PAYMENTS_EUR)
	,AMT_AMAZON_MARKETING_COSTS_EUR = SUM(AMT_AMAZON_MARKETING_COSTS_EUR)
	,AMT_ENVIRO_AND_LICENSE_COST_EST_EUR = SUM(AMT_ENVIRO_AND_LICENSE_COST_EST_EUR)
	,AMT_PC2_EST_EUR = SUM(AMT_PC2_EST_EUR)
	,PCT_PC2 = CASE WHEN SUM(AMT_PC2_EST_EUR) = 0 or sum(AMT_REVENUE_EST_EUR) = 0 THEN 0 ELSE SUM(AMT_PC2_EST_EUR) / SUM(AMT_REVENUE_EST_EUR) END
	,AMT_WAREHOUSING_RENT_EST_EUR = SUM(AMT_WAREHOUSING_RENT_EST_EUR)
	,AMT_WAREHOUSING_OPEX_EST_EUR = SUM(AMT_WAREHOUSING_OPEX_EST_EUR)
	,AMT_CS_MANAGEMENT_EST_EUR = SUM(AMT_CS_MANAGEMENT_EST_EUR)
	,AMT_MARKETING_FIXED_COST_EST_EUR = SUM(AMT_MARKETING_FIXED_COST_EST_EUR)	
	,AMT_PC3_EST_EUR = SUM(AMT_PC3_EST_EUR)
	,PCT_PC2 = CASE WHEN SUM(AMT_PC3_EST_EUR) = 0 or sum(AMT_REVENUE_EST_EUR) = 0 THEN 0 ELSE SUM(AMT_PC3_EST_EUR) / SUM(AMT_REVENUE_EST_EUR) END
FROM [L1].[L1_FACT_F_BUSINESS_PLAN_KPI] kpi
INNER JOIN L1.L1_DIM_A_ITEM it on it.ID_ITEM = kpi.ID_ITEM
	WHERE D_TARGET = '2025-01-01' and CD_CHANNEL_GROUP_3 = 'MarketplacesWE'
	and AMT_MEK_HEDGING_EUR >3 --and it.num_item = '10033610'
GROUP BY CD_CHANNEL_GROUP_3,it.num_item, D_TARGET,CD_COUNTRY_GROUP
order by CASE WHEN SUM(AMT_PC0_EST_EUR) = 0 or sum(AMT_GROSS_ORDER_VALUE_EUR) = 0 THEN 0 ELSE SUM(AMT_PC0_EST_EUR) / SUM(AMT_GROSS_ORDER_VALUE_EUR) END desc
	--CD_CHANNEL_GROUP_3,D_TARGET


		SELECT * FROM 
		 [L1].[L1_DIM_A_DEPRECIATION_VALUES] depreciation
		where '2024-01-01' BETWEEN depreciation.D_VALID_FROM AND depreciation.D_VALID_TO
			AND depreciation.[T_STORAGE_LOCATION] = 'Kamp-Lintfort'
			AND depreciation.[T_PRODUCT_HIERARCHY_2] = 'Cooker Hoods'


			SELECT * FROM  L1.L1_DIM_A_ITEM it where num_item = 10030983


	--193842.64
	--select SUM(AMT_3RD_PARTY_SERVICES_EUR)
	--FROM [L1].[L1_FACT_F_BUSINESS_PLAN_KPI] kpi
	--where 
	--	d_target = '2025-01-01'

	--sekect

--SELECT CD_CHANNEL_GROUP_3,D_TARGET,SUM([VL_ITEM_QUANTITY]),sum([AMT_PLAN_PRICE_EUR])
--FROM [L1].[L1_FACT_F_BUSINESS_PLAN]
--where CD_CHANNEL_GROUP_3 = 'AMAZON'
--GROUP BY CD_CHANNEL_GROUP_3,D_TARGET

--SELECT CHANNELGROUP3,TARGET_DATE,SUM(PLAN_PRICE),sum(QUANTITY)
--FROM [WR].WR_V_L0_MI_BUSINESS_PLAN
--where CHANNELGROUP3 = 'MarketplacesWE'
--GROUP BY CHANNELGROUP3,TARGET_DATE

--SELECT *
--  FROM [L0].[L0_MI_BUSINESS_PLAN_COUNTRY_SHARE]
--  where [CHANNELGROUP3] = 'B2B' --and [Date] ='2025-01-01' 
--  order by country, date 

 -- UPDATE ch
	--SET [Date] ='2025-01-01'
 -- FROM [L0].[L0_MI_BUSINESS_PLAN_COUNTRY_SHARE] ch
 -- where [CHANNELGROUP3] = 'B2B' and [Date] ='2025-01-02'



 select 	CD_CHANNEL_GROUP_3, 
			D_TARGET
			,PCT_PC0 = CASE WHEN SUM(AMT_PC0_EST_EUR) = 0 or sum(AMT_REVENUE_EST_EUR) = 0 THEN 0 ELSE SUM(AMT_PC0_EST_EUR) / SUM(AMT_REVENUE_EST_EUR) END
			,PCT_PC1 = CASE WHEN SUM(AMT_PC1_EST_EUR) = 0 or sum(AMT_REVENUE_EST_EUR) = 0 THEN 0 ELSE SUM(AMT_PC1_EST_EUR) / SUM(AMT_REVENUE_EST_EUR) END
			,PCT_PC2 = CASE WHEN SUM(AMT_PC2_EST_EUR) = 0 or sum(AMT_REVENUE_EST_EUR) = 0 THEN 0 ELSE SUM(AMT_PC2_EST_EUR) / SUM(AMT_REVENUE_EST_EUR) END
			,PCT_PC3 = CASE WHEN SUM(AMT_PC3_EST_EUR) = 0 or sum(AMT_REVENUE_EST_EUR) = 0 THEN 0 ELSE SUM(AMT_PC3_EST_EUR) / SUM(AMT_REVENUE_EST_EUR) END


FROM [L1].[L1_FACT_F_BUSINESS_PLAN_KPI] kpi
INNER JOIN L1.L1_DIM_A_ITEM it on it.ID_ITEM = kpi.ID_ITEM
	WHERE 1=1  --CD_CHANNEL_GROUP_3 = 'AMAZON'
	and D_TARGET = '2025-01-01'
--and AMT_MEK_HEDGING_EUR >3
GROUP BY CD_CHANNEL_GROUP_3 , D_TARGET
order by 
--CASE WHEN SUM(AMT_PC0_EST_EUR) = 0 or sum(AMT_GROSS_ORDER_VALUE_EUR) = 0 THEN 0 ELSE SUM(AMT_PC0_EST_EUR) / SUM(AMT_GROSS_ORDER_VALUE_EUR) END desc
	CD_CHANNEL_GROUP_3,D_TARGET



	select distinct 
		it.NUM_ITEM,
		[CD_COUNTRY_GROUP],
		[VL_GROSS_WEIGHT]  ,
		[VL_LENGTH] = [VL_LENGTH] * 10,
		[VL_WIDTH] = [VL_LENGTH] * 10,
		[VL_HEIGHT] = [VL_LENGTH] * 10,
		[VL_VOLUME] =  [VL_LENGTH] * 1000
	FROM [L1].[L1_FACT_F_BUSINESS_PLAN]  kpi
	INNER JOIN L1.L1_DIM_A_ITEM it on it.ID_ITEM = kpi.ID_ITEM
	--LEFT JOIN L1.L1_DIM_A_ITEM_BUSINESS_PLAN itbs on itbs.ID_ITEM_BUSINESS_PLAN = kpi.ID_ITEM_BUSINESS_PLAN

	where [AMT_SHIPPING_COST_EST_EUR] is null


	select * from  [L0].[L0_MI_BUSINESS_PLAN_MARKETING_RATES] mkt


	update 