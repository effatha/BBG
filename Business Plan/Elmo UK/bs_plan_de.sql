
;with cte_mek as (
	SELECT 
		 [ItemNo] as MATNR
		,[MekHedging] as MEK
		,[LastValueDate] as LOAD_TIMESTAMP 
		,1 AS LastVersion
	FROM  [PL].[PL_V_LAST_MEK]
 
    UNION
 
		SELECT 
		 ov.[ItemNo] as MATNR
		,ov.[MEK] as MEK
		,ov.LOAD_TIMESTAMP 
		,1 AS LastVersion
	FROM  [L0].L0_MI_BUSINESS_PLAN_MEK_OVERRIDE ov
    LEFT JOIN [PL].[PL_V_LAST_MEK]  mek on mek. itemno = ov.itemno
    Where 
        mek.ItemNo is null
	
)
,
CTE_SHIPP_COSTS as
(SELECT 
	cast(cost.item_code as nvarchar(50))item_code,
	    CASE WHEN cost.warehouse=1 THEN 'Kamp-Lintfort'
	         WHEN cost.warehouse=2 THEN 'Hoppegarten'
	         WHEN cost.warehouse=3 THEN 'Bratislava'
	         WHEN cost.warehouse=4 THEN 'Werne'
             WHEN cost.warehouse=6 THEN 'Bucharest'
             WHEN cost.warehouse=7 THEN 'Lager UK'
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
),
CTE_GB_ITEMS AS
(
SELECT DISTINCT 
       [D_TARGET]
      ,[CD_SOURCE]
      ,[D_TARGET_LOOKUP]
      ,[ID_ITEM]
      ,[ID_ITEM_BUSINESS_PLAN]
      ,[ID_COMPANY]
      ,[CD_CHANNEL_GROUP_3]
      ,[CD_COUNTRY_GROUP] = 'FR'
      ,[CD_CURRENCY]
      ,[T_REVISED_LOCATION]
      ,[CD_FULFILLMENT]
      ,[AMT_PLAN_PRICE_EUR]
  FROM [TEST].[L1_FACT_F_BUSINESS_PLAN_KPI_ELMO]
  WHERE D_TARGET = '2025-10-01'
  AND [CD_CHANNEL_GROUP_3] = 'Amazon'

)

INSERT INTO [TEST].[L1_FACT_F_BUSINESS_PLAN_ELMO](
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
	,[CD_REFUND_RATE_SOURCE] 
    ,[CD_RETURN_RATE_SOURCE] 
    ,[CD_REPLACEMENT_RATE_SOURCE]
    ,[DT_DWH_CREATED]    
    ,[DT_DWH_UPDATED]    
 )

SELECT                                    
     D_SNAPSHOT                           = CAST(GETDATE() as date)
    ,[D_TARGET]                           = input.[D_TARGET]
    ,[CD_SOURCE]                          = 'ELM'
    ,[D_TARGET_LOOKUP]                    = [D_TARGET_LOOKUP]
    ,[ID_ITEM]                            = input.[ID_ITEM]
    ,[ID_ITEM_BUSINESS_PLAN]              = input.ID_ITEM_BUSINESS_PLAN
    ,[ID_COMPANY]                         = input.ID_COMPANY
    ,[CD_CHANNEL_GROUP_3]                 = input.[CD_CHANNEL_GROUP_3]
    ,[CD_COUNTRY_GROUP]                   = input.[CD_COUNTRY_GROUP]
    ,[CD_CURRENCY]                        = 'EUR'
    ,[T_REVISED_LOCATION]                 = input.[T_REVISED_LOCATION]
    ,[CD_FULFILLMENT]                     = 'FBM'
    ,[AMT_PLAN_PRICE_EUR]                 = input.[AMT_PLAN_PRICE_EUR]
    ,[VL_ITEM_QUANTITY]                   = 1
    ,[AMT_MEK_HEDGING_EUR]                = ISNULL(mek.MEK,0)
    ,[AMT_GTS_MARKUP_EUR]                 = ISNULL(mek.MEK,0) / (1+ ISNULL(L0_MI_OTHER_DELIVERY_COSTSRATES.OTHERDELIVERYRELATEDCOSTSRATES,0)) /(1+ CASE WHEN GTS.GTSMARKUPRATES < 0 THEN 0 WHEN GTS.GTSMARKUPRATES>0.15 THEN 0.15 ELSE ISNULL(GTS.GTSMARKUPRATES,0) END) * CASE WHEN GTS.GTSMARKUPRATES < 0 THEN 0 WHEN GTS.GTSMARKUPRATES>0.15 THEN 0.15 ELSE ISNULL(GTS.GTSMARKUPRATES,0) END
    ,[AMT_SHIPPING_COST_EST_EUR]          = ISNULL(ship_cost_fbm.main_shipping_cost,capo_override.TotalCost)
    ,[AMT_TARGET_NET_ORDER_VALUE_EUR]     = input.[AMT_PLAN_PRICE_EUR]
    ,[VL_REFUND_RATE] 					
	,[VL_RETURN_RATE]					
	,[VL_REPLACEMENT_RATE]
	,[CD_REFUND_RATE_SOURCE] 
    ,[CD_RETURN_RATE_SOURCE] 
    ,[CD_REPLACEMENT_RATE_SOURCE]
   ,[DT_DWH_CREATED]                     = GETDATE()
    ,[DT_DWH_UPDATED]                     = GETDATE()
FROM CTE_GB_ITEMS input
LEFT JOIN WR.WR_SRG_L1_DIM_A_ITEM item
    on item.ID_ITEM = input.ID_ITEM
LEFT JOIN WR.WR_SRG_L1_DIM_A_ITEM_BUSINESS_PLAN itemBS
    on itemBS.ID_ITEM_BUSINESS_PLAN = input.ID_ITEM_BUSINESS_PLAN
LEFT JOIN cte_mek mek 
    on CAST(mek.MATNR as bigint) = ISNULL(CAST(item.CD_ITEM as bigint),itemBS.NUM_ITEM)
    and mek.LastVersion = 1
LEFT JOIN  [L0].[L0_MI_OTHER_DELIVERY_COSTSRATES] L0_MI_OTHER_DELIVERY_COSTSRATES
    ON [D_TARGET] between L0_MI_OTHER_DELIVERY_COSTSRATES.VALID_FROM and L0_MI_OTHER_DELIVERY_COSTSRATES.VALID_TO
LEFT JOIN [L0].[L0_MI_GTS_MARKUP_RATES] GTS
	ON ISNULL(CAST(item.CD_ITEM as bigint),itemBS.NUM_ITEM) = GTS.ITEMNO
		AND [D_TARGET] between GTS.VALID_FROM and GTS.VALID_TO    
LEFT JOIN CTE_SHIPP_COSTS ship_cost_fbm
	ON CAST(item.CD_ITEM as bigint) = ship_cost_fbm.Item_code
		AND CASE WHEN [CD_COUNTRY_GROUP] = 'INT'THEN 'ES'ELSE [CD_COUNTRY_GROUP] END =ship_cost_fbm.country
		AND ship_cost_fbm.warehouse = [T_REVISED_LOCATION]
		AND ship_cost_fbm.Fulfillment = 'FBM'
LEFT JOIN [L0].[L0_C4PO_OVERRIDE] capo_override 
		ON capo_override.ItemNo=ISNULL(CAST(item.CD_ITEM as bigint),itemBS.NUM_ITEM)
		and capo_override.[destinationCountry] = CASE WHEN [CD_COUNTRY_GROUP] = 'INT' THEN 'ES' ELSE [CD_COUNTRY_GROUP] END
    --rrr rates
 LEFT JOIN [L1].[L1_FACT_A_NOV_CLAIM_RATES] rrr
	ON rrr.id_item = item.ID_ITEM
    AND DATEFROMPARTS(year(getdate()), month(getdate()), 1)  BETWEEN rrr.d_valid_from and rrr.d_valid_to
	AND (rrr.CD_COUNTRY_INVOICE_GROUP is null OR rrr.CD_COUNTRY_INVOICE_GROUP = [CD_COUNTRY_GROUP])
	AND (rrr.CD_COUNTRY_DELIVERY IS null OR rrr.CD_COUNTRY_DELIVERY = [CD_COUNTRY_GROUP])
	AND (rrr.CD_CHANNEL_GROUP_3 is null OR REPLACE(rrr.CD_CHANNEL_GROUP_3,' ','') = REPLACE(input.CD_CHANNEL_GROUP_3,' ',''))     





    select * 
    from [TEST].[L1_FACT_F_BUSINESS_PLAN_ELMO] where id_item = 8219