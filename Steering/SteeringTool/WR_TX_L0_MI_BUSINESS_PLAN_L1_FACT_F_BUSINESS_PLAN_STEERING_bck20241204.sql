/****** Object:  StoredProcedure [WR].[WR_TX_L0_MI_BUSINESS_PLAN_L1_FACT_F_BUSINESS_PLAN_STEERING]    Script Date: 04/12/2024 17:08:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [WR].[WR_TX_L0_MI_BUSINESS_PLAN_L1_FACT_F_BUSINESS_PLAN_STEERING] AS
BEGIN

DELETE FROM [L1].[L1_FACT_F_BUSINESS_PLAN_STEERING] WHERE [CD_SOURCE] = 'BUD'


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
, cte_rates as (
SELECT c.NUM_ITEM ItemNo,CD_ITEM_CLASS, 
		SUM([VL_ORDER_QUANTITY]+VL_REPLACEMENT_QUANTITY)[VL_ORDER_QUANTITY],
		SUM([VL_RETURN_QUANTITY])[VL_RETURN_QUANTITY],
		SUM(AMT_GROSS_ORDER_VALUE_EUR)AMT_GROSS_ORDER_VALUE_EUR,
		SUM(AMT_REFUNDS_EUR)AMT_REFUNDS_EUR,
		--ROUND((SUM(AMT_REFUNDS_EUR)/SUM(ISNULL(AMT_GROSS_ORDER_VALUE_EUR,1)))*100,2) [RefundRate],
		SUM(VL_REPLACEMENT_QUANTITY)VL_REPLACEMENT_QUANTITY
		--ROUND((SUM(VL_REPLACEMENT_QUANTITY)/SUM(ISNULL(AMT_GROSS_ORDER_VALUE_EUR,1)))*100,2) [ReplacementRate]
  FROM [L1].[L1_FACT_A_CLAIM_RATES] c
  inner join l1.l1_dim_a_item it on it.num_item =c.num_item
  WHERE 
	D_SALES_PROCESS BETWEEN '2024-01-01' and '2024-08-31'
	and c.num_item like '1%' and CD_ITEM_CLASS <> 'Kitting-Item'
GROUP BY c.NUM_ITEM,CD_ITEM_CLASS
),cte_rates_summary as (
SELECT *,
		ROUND(([VL_RETURN_QUANTITY]/[VL_ORDER_QUANTITY]),2) [ReturnRate],
		ROUND((AMT_REFUNDS_EUR/AMT_GROSS_ORDER_VALUE_EUR),2) RefundRate,
		ROUND((VL_REPLACEMENT_QUANTITY/[VL_ORDER_QUANTITY]),2) ReplacementRate
FROM cte_rates
WHERE
	AMT_GROSS_ORDER_VALUE_EUR > 0 
	)

INSERT INTO [L1].[L1_FACT_F_BUSINESS_PLAN_STEERING](
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
    ,[DT_DWH_CREATED]    
    ,[DT_DWH_UPDATED]    
 )

SELECT                                    
     D_SNAPSHOT                           = CAST(GETDATE() as date)
    ,[D_TARGET]                           = input.TARGET_DATE
    ,[CD_SOURCE]                          = 'BUD'
    ,[D_TARGET_LOOKUP]                    = CASE WHEN input.TARGET_DATE>='2025-09-01' THEN '2025-09-01' ELSE input.TARGET_DATE END
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
    ,[VL_ITEM_QUANTITY]                   = CAST(input.Quantity as decimal (19,2)) * ct.BUSINNES_PLAN_SHARE
    ,[AMT_MEK_HEDGING_EUR]                = GREATEST(ISNULL(mek_over.MEK,ISNULL(def.[MEK_HEDGING],0)),ISNULL(mek.MekHedging,0))
   -- ,[AMT_GTS_MARKUP_EUR]                 = GREATEST(ISNULL(mek_over.MEK,0),ISNULL(mek.VERPR,0)) / (1+ ISNULL(L0_MI_OTHER_DELIVERY_COSTSRATES.OTHERDELIVERYRELATEDCOSTSRATES,0)) /(1+ CASE WHEN GTS.GTSMARKUPRATES < 0 THEN 0 WHEN GTS.GTSMARKUPRATES>0.15 THEN 0.15 ELSE ISNULL(GTS.GTSMARKUPRATES,0) END)
    ,[AMT_GTS_MARKUP_EUR]                 = GREATEST(ISNULL(mek_over.MEK,ISNULL(def.[MEK_HEDGING],0)),ISNULL(mek.MekHedging,0)) / (1+ ISNULL(L0_MI_OTHER_DELIVERY_COSTSRATES.OTHERDELIVERYRELATEDCOSTSRATES,0)) /(1+ CASE WHEN GTS.GTSMARKUPRATES < 0 THEN 0 WHEN GTS.GTSMARKUPRATES>0.15 THEN 0.15 ELSE ISNULL(GTS.GTSMARKUPRATES,0) END) * CASE WHEN GTS.GTSMARKUPRATES < 0 THEN 0 WHEN GTS.GTSMARKUPRATES>0.15 THEN 0.15 ELSE ISNULL(GTS.GTSMARKUPRATES,0) END
    ,[AMT_SHIPPING_COST_EST_EUR]          = ISNULL(ship_cost_fbm.main_shipping_cost,capo_override.TotalCost)
    ,[AMT_TARGET_NET_ORDER_VALUE_EUR]     = ROUND(input.PLAN_PRICE * (CAST(input.Quantity as decimal (19,2)) * ct.BUSINNES_PLAN_SHARE) ,2)
	,[VL_REFUND_RATE]					  = rates.RefundRate
	,[VL_RETURN_RATE]					  = rates.[ReturnRate]
	,[VL_REPLACEMENT_RATE]				  = rates.ReplacementRate

    ,[DT_DWH_CREATED]                     = GETDATE()
    ,[DT_DWH_UPDATED]                     = GETDATE()
FROM WR.WR_V_L0_MI_BUSINESS_PLAN input
LEFT JOIN [L0].[L0_MI_BUSINESS_PLAN_COUNTRY_SHARE] ct
	on ct.CHANNELGROUP3 = input.CHANNELGROUP3
		and ct.[DATE] = input.[TARGET_DATE]
LEFT JOIN WR.WR_SRG_L1_DIM_A_ITEM item
    on CAST(item.CD_ITEM as bigint) = input.ITEMNO
LEFT JOIN WR.WR_SRG_L1_DIM_A_COMPANY cp
    on CAST(cp.CD_COMPANY as int) = 1000
    and cp.cd_source_system = 'SAP'
LEFT JOIN WR.WR_SRG_L1_DIM_A_ITEM_BUSINESS_PLAN itemBS
    on itemBS.NUM_ITEM = input.ITEMNO
    
LEFT JOIN PL.PL_V_LAST_MEK_V3 mek 
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
LEFT JOIN cte_rates_summary rates on rates.itemno = input.itemNo


END
GO


