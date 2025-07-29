/****** Object:  StoredProcedure [TEST].[WR_TX_L0_MI_BUSINESS_PLAN_L1_FACT_F_BUSINESS_PLAN_SM]    Script Date: 23/07/2025 09:52:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [TEST].[WR_TX_L0_MI_BUSINESS_PLAN_L1_FACT_F_BUSINESS_PLAN_SM] @MonthDate [datetime] AS
BEGIN
--[TEST].[WR_TX_L0_MI_BUSINESS_PLAN_L1_FACT_F_BUSINESS_PLAN_SM] @MonthDate = '2026-01-01'

DELETE FROM [TEST].L1_FACT_F_BUSINESS_PLAN_SM 
WHERE
    MONTH(D_TARGET) = 	MONTH(@MonthDate)
	AND
	YEAR(D_TARGET) = YEAR(@MonthDate)


    
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
	AND cost.item_code in  (SELECT cast(ItemNo as nvarchar(50)) from  WR.WR_V_L0_MI_BUSINESS_PLAN)
GROUP BY 
	cost.item_code,
	cost.warehouse,
	cost.country,
	ctypes.cost_type_name
), cte_final as (

SELECT                                    
     D_SNAPSHOT                           = CAST(GETDATE() as date)
    ,[D_TARGET]                           = input.TARGET_DATE
    ,[CD_SOURCE]                          = CONCAT('BP',YEAR(TARGET_DATE))
    ,[D_TARGET_LOOKUP]                    = CASE 
                                                WHEN YEAR(TARGET_DATE) = 2025 THEN CASE WHEN input.TARGET_DATE>=DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1) THEN DATEADD(year,-1,input.TARGET_DATE)   ELSE input.TARGET_DATE END
                                                WHEN YEAR(TARGET_DATE) = 2026 THEN CASE WHEN DATEADD(year,-1,input.TARGET_DATE)>=DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1) THEN DATEADD(year,-1,DATEADD(year,-1,input.TARGET_DATE))   ELSE DATEADD(year,-1,input.TARGET_DATE) END
                                            ELSE TARGET_DATE END  
    ,[ID_ITEM]                            = item.ID_ITEM
    ,[ID_ITEM_BUSINESS_PLAN]              = itemBS.ID_ITEM_BUSINESS_PLAN
    ,[ID_COMPANY]                         = cp.ID_COMPANY
    ,[CD_CHANNEL_GROUP_3]                 = ISNULL(channel_country.CHANNELGROUP3,input.[CHANNELGROUP3])
    ,[CD_COUNTRY_GROUP]                   = ISNULL(channel_country.COUNTRYGROUP,ct.COUNTRY)
    ,[CD_CURRENCY]                        = 'EUR'
    ,[T_REVISED_LOCATION]                 = CASE WHEN input.[CHANNELGROUP3] = 'B2B' THEN 'Alicante' 
                                                 WHEN input.[CHANNELGROUP3] = 'CEE' THEN 'Bratislava' ELSE 'Kamp-Lintfort' END
    ,[CD_FULFILLMENT]                     = CASE WHEN input.[CHANNELGROUP3] = 'B2B' THEN 'B2B' ELSE 'FBM' END
    ,[AMT_PLAN_PRICE_EUR]                 = input.PLAN_PRICE
    ,[VL_ITEM_QUANTITY]                   = CAST(input.Quantity as decimal (19,2)) * ISNULL(channel_country.DISTRIBUTION_SHARE,ct.BUSINNES_PLAN_SHARE)
    ,[AMT_MEK_HEDGING_EUR]                = ISNULL(mek.MEK,0)
    ,[AMT_GTS_MARKUP_EUR]                 = ISNULL(mek.MEK,0) / (1+ ISNULL(L0_MI_OTHER_DELIVERY_COSTSRATES.OTHERDELIVERYRELATEDCOSTSRATES,0)) /(1+ CASE WHEN GTS.ItemNo is not null THEN 0.13 ELSE 0 END) * CASE WHEN GTS.ItemNo is not null THEN 0.13 ELSE 0 END
    ,[AMT_SHIPPING_COST_EST_EUR]          = ISNULL(ship_cost_fbm.main_shipping_cost,capo_override.TotalCost)
    ,[AMT_TARGET_NET_ORDER_VALUE_EUR]     = ROUND(input.PLAN_PRICE * (CAST(input.Quantity as decimal (19,4)) * ISNULL(channel_country.DISTRIBUTION_SHARE,ct.BUSINNES_PLAN_SHARE)) ,2)
    ,[VL_REFUND_RATE] 					
	,[VL_RETURN_RATE]					
	,[VL_REPLACEMENT_RATE]
	,[CD_REFUND_RATE_SOURCE] 
    ,[CD_RETURN_RATE_SOURCE] 
    ,[CD_REPLACEMENT_RATE_SOURCE]
    ,[DT_DWH_CREATED]                     = GETDATE()
    ,[DT_DWH_UPDATED]                     = GETDATE()
FROM WR.WR_V_L0_MI_BUSINESS_PLAN input
LEFT JOIN [L0].[L0_MI_BUSINESS_PLAN_COUNTRY_SHARE] ct
	on ct.CHANNELGROUP3 = input.CHANNELGROUP3
		and ct.[DATE] = input.[TARGET_DATE]
LEFT JOIN [L0].[L0_MI_BS_CHANNEL_COUNTRY_SPLIT] channel_country
ON input.CHANNELGROUP3 = channel_country.[COUNTRYGROUP]
AND input.[TARGET_DATE] = channel_country.[VALID_FROM]
LEFT JOIN WR.WR_SRG_L1_DIM_A_ITEM item
    on CAST(item.CD_ITEM as bigint) = input.ITEMNO
LEFT JOIN WR.WR_SRG_L1_DIM_A_COMPANY cp
    on CAST(cp.CD_COMPANY as int) = 1000
    and cp.cd_source_system = 'SAP'
LEFT JOIN WR.WR_SRG_L1_DIM_A_ITEM_BUSINESS_PLAN itemBS
    on itemBS.NUM_ITEM = input.ITEMNO   
LEFT JOIN cte_mek mek 
    on CAST(mek.MATNR as bigint) = input.ITEMNO
    and mek.LastVersion = 1
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
LEFT JOIN [L0].[L0_C4PO_OVERRIDE] capo_override 
		ON capo_override.ItemNo=input.ItemNo
		and capo_override.[destinationCountry] = CASE WHEN ct.COUNTRY = 'INT' THEN 'ES' ELSE ct.COUNTRY END
    --rrr rates
 LEFT JOIN [L1].[L1_FACT_A_NOV_CLAIM_RATES] rrr
	ON rrr.id_item = item.ID_ITEM
    AND '2025-05-01' BETWEEN rrr.d_valid_from and rrr.d_valid_to
	AND (rrr.CD_COUNTRY_INVOICE_GROUP is null OR rrr.CD_COUNTRY_INVOICE_GROUP = CASE WHEN ct.Country = 'INT'THEN 'ES'ELSE ct.Country END)
	AND (rrr.CD_COUNTRY_DELIVERY IS null OR rrr.CD_COUNTRY_DELIVERY = CASE WHEN ct.Country = 'INT'THEN 'ES'ELSE ct.Country END)
	AND (rrr.CD_CHANNEL_GROUP_3 is null OR REPLACE(rrr.CD_CHANNEL_GROUP_3,' ','') = REPLACE(input.[CHANNELGROUP3],' ',''))     
where 
    MONTH(input.TARGET_DATE) = 	MONTH(@MonthDate)
	AND
	YEAR(input.TARGET_DATE) = 	YEAR(@MonthDate)
    AND
    (input.PLAN_PRICE * CAST(input.Quantity as decimal (19,4)))>0
)
, bp_global as (
	
	SELECT CD_CHANNEL_GROUP_3, D_TARGET,SUM(AMT_TARGET_NET_ORDER_VALUE_EUR) BP_NOV,SUM(VL_ITEM_QUANTITY) BP_NOQ
	FROM [L1].[L1_FACT_F_BUSINESS_PLAN] bs
	GROUP BY CD_CHANNEL_GROUP_3, D_TARGET
)

, cte_fc_factor as (
SELECT 
	bp.CD_CHANNEL_GROUP_3,
	bp.D_TARGET,
	bp.BP_NOV,
	fc.NOV,
	FCNOVFactor = --(NOV-BP_NOV)/NOV ,
                    CASE 
					WHEN ISNULL(NOV,0) > 0 THEN (NOV-BP_NOV)/NOV ELSE 0 END
                    ,
	bp.BP_NOQ,
	fc.NOQ,
	FCNOQFactor = CASE 
					WHEN 
						CASE WHEN ISNULL(NOQ,0) > 0 THEN (NOQ-BP_NOQ)/NOQ ELSE (NOV-BP_NOV)/NOV END IS NULL THEN 0  
					ELSE 
						CASE WHEN ISNULL(NOQ,0) > 0 THEN (NOQ-BP_NOQ)/NOQ ELSE (NOV-BP_NOV)/NOV END
                    END
  FROM bp_global bp
LEFT JOIN [L0].[L0_MI_BL_FORECAST_TARGETS] fc
	on REPLACE(fc.CHANNELGROUP3,' ','') = REPLACE(bp.CD_CHANNEL_GROUP_3,' ','')
	and cast(fc.TARGETMONTH as date) = bp.D_TARGET
	)

INSERT INTO [TEST].L1_FACT_F_BUSINESS_PLAN_SM(
    D_SNAPSHOT                       
    ,[D_TARGET] 
    ,[CD_SOURCE]
    ,[D_TARGET_LOOKUP]                       
    ,[ID_ITEM]                        
    ,[ID_ITEM_BUSINESS_PLAN]      
    ,[ID_COMPANY]
    ,[CD_CHANNEL_GROUP_3] 
    ,[CD_CHANNEL_GROUP_1]
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
     D_SNAPSHOT                           
    ,[D_TARGET]                           = ISNULL(run_rates.DATE_ADJUSTED,b_plan.[D_TARGET])
    ,[CD_SOURCE]                          = [CD_SOURCE]
    ,[D_TARGET_LOOKUP]                    
    ,[ID_ITEM]                            = b_plan.[ID_ITEM]
    ,[ID_ITEM_BUSINESS_PLAN]              
    ,[ID_COMPANY]                         
    ,[CD_CHANNEL_GROUP_3]                 = b_plan.[CD_CHANNEL_GROUP_3]
    ,[CD_CHANNEL_GROUP_1]                 = ISNULL(spl.CHANNELGROUP1,b_plan.[CD_CHANNEL_GROUP_3]) 
    ,[CD_COUNTRY_GROUP]                   
    ,[CD_CURRENCY]                        
    ,[T_REVISED_LOCATION]                 
    ,[CD_FULFILLMENT]                     
    ,[AMT_PLAN_PRICE_EUR]                 
    ,[VL_ITEM_QUANTITY]                   = (b_plan.VL_ITEM_QUANTITY/(1-FCNOQFactor))* isnull(spl.NOQ_SHARE,1) *  ISNULL(CAST(run_rates.rr as decimal(19,9)) ,1)
    ,[AMT_MEK_HEDGING_EUR]                
    ,[AMT_GTS_MARKUP_EUR]                
    ,[AMT_SHIPPING_COST_EST_EUR]          
     ,[AMT_TARGET_NET_ORDER_VALUE_EUR] =(b_plan.AMT_TARGET_NET_ORDER_VALUE_EUR /(1-FCNOVFactor))* isnull(spl.NOV_SHARE,1) *  ISNULL(CAST(run_rates.rr as decimal(19,9)) ,1)
    ,[VL_REFUND_RATE] 					
	,[VL_RETURN_RATE]					
	,[VL_REPLACEMENT_RATE]
	,[CD_REFUND_RATE_SOURCE] 
    ,[CD_RETURN_RATE_SOURCE] 
    ,[CD_REPLACEMENT_RATE_SOURCE]
    ,[DT_DWH_CREATED]                     = b_plan.[DT_DWH_CREATED]
    ,[DT_DWH_UPDATED]                     = b_plan.[DT_DWH_UPDATED]
    


FROM cte_final b_plan
LEFT JOIN L0.L0_MI_BS_CHANNEL_SPLIT spl
		on spl.TARGET_DATE = b_plan.[D_TARGET]
		and REPLACE(spl.CHANNELGROUP3,' ','') = REPLACE(b_plan.[CD_CHANNEL_GROUP_3],' ','')
LEFT JOIN L1.L1_DIM_A_ITEM item
    on item.[ID_ITEM] = b_plan.[ID_ITEM]
LEFT JOIN [L0].[L0_MI_FC_BL_RUN_RATES] run_rates
	on run_rates.[CategoryL1] = item.T_PRODUCT_HIERARCHY_1
	AND	run_rates.[CategoryL2] = item.T_PRODUCT_HIERARCHY_2
	AND	run_rates.[CategoryL3] = item.T_PRODUCT_HIERARCHY_3
	AND	REPLACE(run_rates.[CHANNELGROUP3],' ','') = REPLACE(b_plan.[CD_CHANNEL_GROUP_3],' ','')
	AND YEAR(run_rates.date_adjusted) = YEAR(b_plan.[D_TARGET])
    AND MONTH(run_rates.date_adjusted) = MONTH(b_plan.[D_TARGET])
LEFT JOIN cte_fc_factor factor
	on factor.CD_CHANNEL_GROUP_3 = b_plan.CD_CHANNEL_GROUP_3
	and factor.D_TARGET = b_plan.[D_TARGET]

    


END




--SELECT distinct MONTH(D_TARGET) FROM [TEST].L1_FACT_F_BUSINESS_PLAN_SM 
--select top 10 * from [L0].L0_MI_BUSINESS_PLAN_COMMISSIONS_MARKETPLACES where month = '2025-01-01'