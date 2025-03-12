/****** Object:  StoredProcedure [TEST].[WR_TX_L0_MI_BUSINESS_PLAN_L1_FACT_F_BUSINESS_PLAN_STEERING]    Script Date: 05/03/2025 14:57:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [TEST].[WR_TX_L0_MI_BUSINESS_PLAN_L1_FACT_F_BUSINESS_PLAN_STEERING] AS
BEGIN

DELETE FROM [TEST].[L1_FACT_F_BUSINESS_PLAN_STEERING] WHERE [CD_SOURCE] = 'BUD'


;with
CTE_SHIPP_COSTS as
(SELECT 
	cast(cost.item_code as nvarchar(50))item_code,
	CASE WHEN cost.warehouse=1 THEN 'Kamp-Lintfort'
	        WHEN cost.warehouse=2 THEN 'Hoppegarten'
	        WHEN cost.warehouse=3 THEN 'Bratislava'
	        WHEN cost.warehouse=4 THEN 'Werne'
	END warehouse,
    warehouse as warehouse_id,
	cost.country,
	ctypes.cost_type_name as Fulfillment,
	SUM(cost.parcel_total_cost) as main_shipping_cost
FROM [L0].[L0_MERCURY_LOGISTIC_BUDGET_CAPO_COST] cost 
LEFT JOIN [L0].[L0_MERCURY_LOGISTIC_BUDGET_COST_TYPES] ctypes
ON cost.cost_type_id = ctypes.id
WHERE 0=0
	--AND cost.warehouse IN (1, 3, 4)
	AND cost.item_code in  (SELECT cast(ItemNo as nvarchar(50)) from  WR.WR_V_L0_MI_BUSINESS_PLAN )
GROUP BY 
	cost.item_code,
	cost.warehouse,
	cost.country,
	ctypes.cost_type_name
)
----calculate RRR rates on a sku level
, cte_rrr_item_rates as (
SELECT 
		c.ID_ITEM,
		ch.CD_CHANNEL_GROUP_3,
		CD_COUNTRY_DELIVERY = CASE WHEN CD_COUNTRY_DELIVERY in('PL','FR','CZ','HR','IT','GB','RO','HU','ES','BG','DE','SI','SK') THEN CD_COUNTRY_DELIVERY
							  WHEN  ch.CD_CHANNEL_GROUP_3 ='CEE' then 'SK' 
							  ELSE 'INT' END ,
		--VL_ORDER_QUANTITY			= SUM([VL_ORDER_QUANTITY]+VL_REPLACEMENT_QUANTITY),
		--VL_RETURN_QUANTITY			= SUM([VL_RETURN_QUANTITY]),
		--AMT_GROSS_ORDER_VALUE_EUR	= SUM(AMT_GROSS_ORDER_VALUE_EUR),
		--AMT_REFUNDS_EUR				= SUM(AMT_REFUNDS_EUR),
		--VL_REPLACEMENT_QUANTITY		= SUM(VL_REPLACEMENT_QUANTITY),
		ReturnRate					= ROUND((SUM([VL_RETURN_QUANTITY])/SUM([VL_ORDER_QUANTITY])),2),
		RefundRate					= ROUND((SUM(AMT_REFUNDS_EUR)/SUM(AMT_GROSS_ORDER_VALUE_EUR)),2),
		ReplacementRate				= ROUND((SUM(VL_REPLACEMENT_QUANTITY)/SUM(AMT_GROSS_ORDER_VALUE_EUR)),2) 
  FROM [L1].[L1_FACT_A_CLAIM_RATES] c
  INNER JOIN L1.L1_DIM_A_SALES_CHANNEL ch on ch.ID_SALES_CHANNEL = c.ID_SALES_CHANNEL
  WHERE 
   [D_SALES_PROCESS] between DATEADD(MONTH,-12,DATEADD(week,-8,getdate())) and DATEADD(week,-8,getdate())
	and c.num_item like '1%' --and CD_ITEM_CLASS <> 'Kitting-Item'
  GROUP BY 
   c.ID_ITEM,ch.CD_CHANNEL_GROUP_3,CASE WHEN CD_COUNTRY_DELIVERY in('PL','FR','CZ','HR','IT','GB','RO','HU','ES','BG','DE','SI','SK') THEN CD_COUNTRY_DELIVERY
							  WHEN  ch.CD_CHANNEL_GROUP_3 ='CEE' then 'SK' 
							  ELSE 'INT' END
  HAVING  
	SUM(AMT_GROSS_ORDER_VALUE_EUR) > 0
	AND
	SUM([VL_ORDER_QUANTITY]) > 50

)
, cte_rrr_item_family_rates as (
SELECT 
		T_PRODUCT_HIERARCHY_4,
		ch.CD_CHANNEL_GROUP_3,
		CD_COUNTRY_DELIVERY = CASE WHEN CD_COUNTRY_DELIVERY in('PL','FR','CZ','HR','IT','GB','RO','HU','ES','BG','DE','SI','SK') THEN CD_COUNTRY_DELIVERY
							  WHEN  ch.CD_CHANNEL_GROUP_3 ='CEE' then 'SK' 
							  ELSE 'INT' END ,
		--VL_ORDER_QUANTITY			= SUM([VL_ORDER_QUANTITY]+VL_REPLACEMENT_QUANTITY),
		--VL_RETURN_QUANTITY			= SUM([VL_RETURN_QUANTITY]),
		--AMT_GROSS_ORDER_VALUE_EUR	= SUM(AMT_GROSS_ORDER_VALUE_EUR),
		--AMT_REFUNDS_EUR				= SUM(AMT_REFUNDS_EUR),
		--VL_REPLACEMENT_QUANTITY		= SUM(VL_REPLACEMENT_QUANTITY),
		ReturnRate					= ROUND((SUM([VL_RETURN_QUANTITY])/SUM([VL_ORDER_QUANTITY])),2),
		RefundRate					= ROUND((SUM(AMT_REFUNDS_EUR)/SUM(AMT_GROSS_ORDER_VALUE_EUR)),2),
		ReplacementRate				= ROUND((SUM(VL_REPLACEMENT_QUANTITY)/SUM(AMT_GROSS_ORDER_VALUE_EUR)),2) 
  FROM [L1].[L1_FACT_A_CLAIM_RATES] c
  INNER JOIN L1.L1_DIM_A_SALES_CHANNEL ch on ch.ID_SALES_CHANNEL = c.ID_SALES_CHANNEL
  INNER JOIN L1.L1_DIM_A_ITEM it on it.ID_ITEM = c.ID_ITEM

  WHERE 
   [D_SALES_PROCESS] between DATEADD(MONTH,-12,DATEADD(week,-8,getdate())) and DATEADD(week,-8,getdate())
	and c.num_item like '1%' --and CD_ITEM_CLASS <> 'Kitting-Item'
  GROUP BY 
   T_PRODUCT_HIERARCHY_4,ch.CD_CHANNEL_GROUP_3,CASE WHEN CD_COUNTRY_DELIVERY in('PL','FR','CZ','HR','IT','GB','RO','HU','ES','BG','DE','SI','SK') THEN CD_COUNTRY_DELIVERY
							  WHEN  ch.CD_CHANNEL_GROUP_3 ='CEE' then 'SK' 
							  ELSE 'INT' END
   HAVING  
	SUM(AMT_GROSS_ORDER_VALUE_EUR) > 0
	AND
	SUM([VL_ORDER_QUANTITY]) > 50
),
 cte_rrr_item_L3_rates as (
SELECT 
		T_PRODUCT_HIERARCHY_3,
		ch.CD_CHANNEL_GROUP_3,
		CD_COUNTRY_DELIVERY = CASE WHEN CD_COUNTRY_DELIVERY in('PL','FR','CZ','HR','IT','GB','RO','HU','ES','BG','DE','SI','SK') THEN CD_COUNTRY_DELIVERY
							  WHEN  ch.CD_CHANNEL_GROUP_3 ='CEE' then 'SK' 
							  ELSE 'INT' END ,
		ReturnRate					= ROUND((SUM([VL_RETURN_QUANTITY])/SUM([VL_ORDER_QUANTITY])),2),
		RefundRate					= ROUND((SUM(AMT_REFUNDS_EUR)/SUM(AMT_GROSS_ORDER_VALUE_EUR)),2),
		ReplacementRate				= ROUND((SUM(VL_REPLACEMENT_QUANTITY)/SUM(AMT_GROSS_ORDER_VALUE_EUR)),2) 
  FROM [L1].[L1_FACT_A_CLAIM_RATES] c
  INNER JOIN L1.L1_DIM_A_SALES_CHANNEL ch on ch.ID_SALES_CHANNEL = c.ID_SALES_CHANNEL
  INNER JOIN L1.L1_DIM_A_ITEM it on it.ID_ITEM = c.ID_ITEM

  WHERE 
   [D_SALES_PROCESS] between DATEADD(MONTH,-12,DATEADD(week,-8,getdate())) and DATEADD(week,-8,getdate())
	and c.num_item like '1%' --and CD_ITEM_CLASS <> 'Kitting-Item'
  GROUP BY 
   T_PRODUCT_HIERARCHY_3,ch.CD_CHANNEL_GROUP_3,CASE WHEN CD_COUNTRY_DELIVERY in('PL','FR','CZ','HR','IT','GB','RO','HU','ES','BG','DE','SI','SK') THEN CD_COUNTRY_DELIVERY
							  WHEN  ch.CD_CHANNEL_GROUP_3 ='CEE' then 'SK' 
							  ELSE 'INT' END
   HAVING  
	SUM(AMT_GROSS_ORDER_VALUE_EUR) > 0
	AND
	SUM([VL_ORDER_QUANTITY]) > 50
)
,
 bs_global as (
	
	SELECT CHANNELGROUP3, TARGET_DATE,SUM(PLAN_PRICE * Quantity) NOV
	FROM WR.WR_V_L0_MI_BUSINESS_PLAN bs
	 
	GROUP BY CHANNELGROUP3, TARGET_DATE
), cte_fc_factor as (
SELECT bs.CHANNELGROUP3,bs.TARGET_DATE, bs.NOV,fc.FCNov, (FCNov-NOV)/FCNov AS FCFactor
FROM bs_global bs
LEFT JOIN [WR].[WR_V_L0_MI_FC_BL_TARGET] fc
	on REPLACE(fc.CHANNELGROUP3,' ','') = REPLACE(bs.CHANNELGROUP3,' ','')
	and bs.TARGET_DATE = fc.TARGET_DATE

)

INSERT INTO TEST.[L1_FACT_F_BUSINESS_PLAN_STEERING](
    D_SNAPSHOT                       
    ,[D_TARGET] 
    ,[CD_SOURCE]
    ,[D_TARGET_LOOKUP]                       
    ,[ID_ITEM]                        
    ,[ID_ITEM_BUSINESS_PLAN]      
    ,[ID_COMPANY]
    ,[CD_CHANNEL_GROUP_3]             
    ,[CD_COUNTRY_GROUP]
    ,[CD_CURRENCY]
    ,[T_REVISED_LOCATION]
    ,[CD_FULFILLMENT]
    ,[AMT_PLAN_PRICE_EUR]             
    ,[VL_ITEM_QUANTITY]               
    ,[AMT_MEK_HEDGING_EUR]            
    ,[AMT_GTS_MARKUP_EUR]     
    ,[AMT_SHIPPING_COST_EST_EUR]  
    ,[AMT_TARGET_NET_ORDER_VALUE_EUR] 
	,[VL_REFUND_RATE]
	,[VL_RETURN_RATE]
	,[VL_REPLACEMENT_RATE]
	,CD_REFUND_RATE_SOURCE
	,CD_RETURN_RATE_SOURCE
	,CD_REPLACEMENT_RATE_SOURCE
    ,[DT_DWH_CREATED]    
    ,[DT_DWH_UPDATED]    
 )

SELECT                                    
     D_SNAPSHOT                           = CAST(GETDATE() as date)
    ,[D_TARGET]                           = ISNULL(run_rates.date_adjusted,input.TARGET_DATE)
    ,[CD_SOURCE]                          = 'BUD'
    ,[D_TARGET_LOOKUP]                    = CASE WHEN input.TARGET_DATE > GETDATE() THEN DATEADD(YEAR,-1,ISNULL(run_rates.date_adjusted,input.TARGET_DATE)) ELSE ISNULL(run_rates.date_adjusted,input.TARGET_DATE) END
    ,[ID_ITEM]                            = item.ID_ITEM
    ,[ID_ITEM_BUSINESS_PLAN]              = itemBS.ID_ITEM_BUSINESS_PLAN
    ,[ID_COMPANY]                         = cp.ID_COMPANY
    ,[CD_CHANNEL_GROUP_3]                 = input.[CHANNELGROUP3]
    ,[CD_COUNTRY_GROUP]                   = ct.COUNTRY
    ,[CD_CURRENCY]                        = 'EUR'
    ,[T_REVISED_LOCATION]                 = CASE WHEN input.[CHANNELGROUP3] = 'B2B' THEN 'Alicante' 
                                                WHEN input.[CHANNELGROUP3] = 'CEE' THEN 'Bratislava' ELSE 'Kamp-Lintfort' END
    ,[CD_FULFILLMENT]                     = CASE WHEN input.[CHANNELGROUP3] = 'B2B' THEN 'B2B' ELSE 'FBM' END
    ,[AMT_PLAN_PRICE_EUR]                 = input.PLAN_PRICE
    ,[VL_ITEM_QUANTITY]                   = CAST(input.Quantity as decimal (19,4)) * ct.BUSINNES_PLAN_SHARE /(1-FCFactor) * ISNULL(run_rates.rr,1) 
    ,[AMT_MEK_HEDGING_EUR]                = GREATEST(ISNULL(mek_over.MEK,ISNULL(def.[MEK_HEDGING],0)),ISNULL(mek.MekHedging,0))
    ,[AMT_GTS_MARKUP_EUR]                 = GREATEST(ISNULL(mek_over.MEK,ISNULL(def.[MEK_HEDGING],0)),ISNULL(mek.MekHedging,0)) / (1+ ISNULL(L0_MI_OTHER_DELIVERY_COSTSRATES.OTHERDELIVERYRELATEDCOSTSRATES,0)) /(1+ CASE WHEN GTS.GTSMARKUPRATES < 0 THEN 0 WHEN GTS.GTSMARKUPRATES>0.15 THEN 0.15 ELSE ISNULL(GTS.GTSMARKUPRATES,0) END) * CASE WHEN GTS.GTSMARKUPRATES < 0 THEN 0 WHEN GTS.GTSMARKUPRATES>0.15 THEN 0.15 ELSE ISNULL(GTS.GTSMARKUPRATES,0) END
    ,[AMT_SHIPPING_COST_EST_EUR]          = ISNULL(ship_cost_fbm.main_shipping_cost,capo_override.TotalCost)
    ,[AMT_TARGET_NET_ORDER_VALUE_EUR]     = (ROUND(input.PLAN_PRICE * (CAST(input.Quantity as decimal (19,4)) * ct.BUSINNES_PLAN_SHARE) ,4) /(1-FCFactor))* ISNULL(run_rates.rr,1)

	,[VL_REFUND_RATE]					  = CASE 
												WHEN ISNULL(item_rates.RefundRate,0) > 0 THEN item_rates.RefundRate
												WHEN ISNULL(family_rates.RefundRate,0) > 0 THEN family_rates.RefundRate
												WHEN ISNULL(l3_rates.RefundRate,0) > 0 THEN l3_rates.RefundRate
												ELSE 0.12 END
	,[VL_RETURN_RATE]					  = CASE 
												WHEN ISNULL(item_rates.[ReturnRate],0) > 0 THEN item_rates.[ReturnRate]
												WHEN ISNULL(family_rates.[ReturnRate],0) > 0 THEN family_rates.[ReturnRate]
												WHEN ISNULL(l3_rates.[ReturnRate],0) > 0 THEN l3_rates.[ReturnRate]
												ELSE 0.12 END
	,[VL_REPLACEMENT_RATE]				  = CASE 
												WHEN ISNULL(item_rates.ReplacementRate,0) > 0 THEN item_rates.ReplacementRate
												WHEN ISNULL(family_rates.ReplacementRate,0) > 0 THEN family_rates.ReplacementRate
												WHEN ISNULL(l3_rates.ReplacementRate,0) > 0 THEN l3_rates.ReplacementRate
												ELSE 0.01 END
	,CD_REFUND_RATE_SOURCE				  = CASE 
												WHEN ISNULL(item_rates.RefundRate,0) > 0 THEN 'item_rates'
												WHEN ISNULL(family_rates.RefundRate,0) > 0 THEN 'family_rates'
												WHEN ISNULL(l3_rates.RefundRate,0) > 0 THEN 'l3_rates'
												ELSE 'Default' END
	,CD_RETURN_RATE_SOURCE				  = CASE 
												WHEN ISNULL(item_rates.[ReturnRate],0) > 0 THEN 'item_rates'
												WHEN ISNULL(family_rates.[ReturnRate],0) > 0 THEN 'family_rates'
												WHEN ISNULL(l3_rates.[ReturnRate],0) > 0 THEN 'l3_rates'
												ELSE 'Default' END
	,CD_REPLACEMENT_RATE_SOURCE			  = CASE 
												WHEN ISNULL(item_rates.ReplacementRate,0) > 0 THEN 'item_rates'
												WHEN ISNULL(family_rates.ReplacementRate,0) > 0 THEN 'family_rates'
												WHEN ISNULL(l3_rates.ReplacementRate,0) > 0 THEN 'l3_rates'
												ELSE 'Default' END
    ,[DT_DWH_CREATED]                     = GETDATE()
    ,[DT_DWH_UPDATED]                     = GETDATE()
FROM WR.WR_V_L0_MI_BUSINESS_PLAN input
LEFT JOIN [L0].[L0_MI_BUSINESS_PLAN_COUNTRY_SHARE] ct
	on ct.CHANNELGROUP3 = input.CHANNELGROUP3
		and ct.[DATE] = input.[TARGET_DATE]
LEFT JOIN L1.L1_DIM_A_ITEM item
    on item.NUM_ITEM = input.ITEMNO
LEFT JOIN WR.WR_SRG_L1_DIM_A_COMPANY cp
    on CAST(cp.CD_COMPANY as int) = 1000
    and cp.cd_source_system = 'SAP'
LEFT JOIN WR.WR_SRG_L1_DIM_A_ITEM_BUSINESS_PLAN itemBS
    on itemBS.NUM_ITEM = input.ITEMNO
LEFT JOIN [L0].[L0_MI_FC_BL_RUN_RATES] run_rates
	on 
	run_rates.[CategoryL1] = item.T_PRODUCT_HIERARCHY_1
	AND
	run_rates.[CategoryL2] = item.T_PRODUCT_HIERARCHY_2
	AND
	run_rates.[CategoryL3] = item.T_PRODUCT_HIERARCHY_3
	AND
	REPLACE(run_rates.[CHANNELGROUP3],' ','') = REPLACE(input.CHANNELGROUP3,' ','')
	AND
	run_rates.[month] = MONTH(input.[TARGET_DATE])
		AND
	YEAR(run_rates.date_adjusted) = YEAR(input.[TARGET_DATE])

LEFT JOIN PL.PL_V_LAST_MEK mek 
    on mek.ItemNo = input.ITEMNO
LEFT JOIN  [L0].[L0_MI_OTHER_DELIVERY_COSTSRATES] L0_MI_OTHER_DELIVERY_COSTSRATES
    ON TARGET_DATE between L0_MI_OTHER_DELIVERY_COSTSRATES.VALID_FROM and L0_MI_OTHER_DELIVERY_COSTSRATES.VALID_TO
LEFT JOIN [L0].[L0_MI_GTS_MARKUP_RATES] GTS
	ON input.ItemNo = GTS.ITEMNO
		AND TARGET_DATE between GTS.VALID_FROM and GTS.VALID_TO    
LEFT JOIN CTE_SHIPP_COSTS ship_cost_fbm
	ON cast(input.ItemNo as nvarchar(50)) = ship_cost_fbm.Item_code
		AND CASE WHEN ct.Country = 'INT'THEN 'ES'ELSE ct.Country END =ship_cost_fbm.country
		AND ship_cost_fbm.warehouse = 'Kamp-Lintfort'
		AND ship_cost_fbm.Fulfillment = 'FBM'
LEFT JOIN [TEST].[L0_C4PO_OVERRIDE] capo_override 
		ON capo_override.ItemNo=input.ItemNo
		and capo_override.[destinationCountry] = CASE WHEN ct.COUNTRY = 'INT' THEN 'ES' ELSE ct.COUNTRY END
LEFT JOIN  L0.L0_MI_BUSINESS_PLAN_MEK_OVERRIDE mek_over on mek_over.ITEMNO = input.ITEMNO
LEFT JOIN L0.L0_MI_BUSINESS_PLAN_ITEM_DEFAULT def on def.itemno = input.Itemno
LEFT JOIN cte_rrr_item_rates item_rates 
	on item_rates.ID_ITEM = input.itemNo
		AND REPLACE(item_rates.CD_CHANNEL_GROUP_3,' ','') = REPLACE(input.ChannelGroup3,' ','')
		AND item_rates.CD_COUNTRY_DELIVERY = ct.COUNTRY
LEFT JOIN cte_rrr_item_family_rates family_rates 
	on family_rates.T_PRODUCT_HIERARCHY_4 = item.T_PRODUCT_HIERARCHY_4
		AND REPLACE(family_rates.CD_CHANNEL_GROUP_3,' ','') = REPLACE(input.ChannelGroup3,' ','')
		AND family_rates.CD_COUNTRY_DELIVERY = ct.COUNTRY
LEFT JOIN cte_rrr_item_L3_rates l3_rates 
	on l3_rates.T_PRODUCT_HIERARCHY_3 = item.T_PRODUCT_HIERARCHY_3
		AND REPLACE(l3_rates.CD_CHANNEL_GROUP_3,' ','') = REPLACE(input.ChannelGroup3,' ','')
		AND l3_rates.CD_COUNTRY_DELIVERY = ct.COUNTRY
LEFT JOIN cte_fc_factor factor
	on REPLACE(factor.CHANNELGROUP3,' ','') = REPLACE(input.CHANNELGROUP3,' ','')
	and factor.TARGET_DATE = input.TARGET_DATE

END


