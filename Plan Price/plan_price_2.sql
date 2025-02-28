DECLARE @PRICE_DATE as DATE
SET @PRICE_DATE = '2023-11-01'

;WITH CTE_MEK as (

	SELECT 
		 MATNR
		,VERPR
		,BWKEY
		,BWTAR
		,LOAD_TIMESTAMP 
		,rank() over (partition by CAST(MATNR as int),BWKEY,BWTAR ORDER BY LOAD_TIMESTAMP DESC ) AS LastVersion
	FROM [L0].[L0_S4HANA_MBEW] 
	WHERE cast(MATNR as int) in (SELECT ItemNO from [L0].[L0_MI_PLAN_PRICE_EV_TARGETS])
	
	--BWKEY = 1000
 --   AND BWTAR = '100'
		
),
CTE_SHIPP_COSTS as
(SELECT 
	    cost.item_code,
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
		
	GROUP BY 
	    cost.item_code,
	    cost.warehouse,
	    cost.country,
		ctypes.cost_type_name
)

, cte_main AS (

	SELECT 
	    [CD_PLAN_PRICE]                           = Concat(ev.ItemNo,'#',ITEMTYPE,'#',ev.FULFILLMENT,'#',ev.STORAGELOCATIONCODE)
        ,[ID_ITEM]                                = item.ID_ITEM 
        ,[NUM_ITEM]                               = ev.ItemNo
        ,[CD_ITEM_TYPE]                           = ev.ITEMTYPE 
        ,[CD_FULFILLMENT]                         = ev.FULFILLMENT 
        ,[CD_STORAGE_LOCATION]                    = ev.STORAGELOCATIONCODE 
        ,[CD_CHANNEL_COUNTRY]                     = country.CHANNELCOUNTRY
        ,[VL_MIN_EV_RATE]                         = ev.MIN_EV_RATE 
        ,[VL_STD_EV_RATE]                         = ev.STD_EV_RATE 
        ,[VL_MAX_EV_RATE]                         = ev.MAX_EV_RATE
        ,[VL_COUNTRY_MARKETING_COMMISSION_RATE]   = country.MARKETING_COMMISSIONS_PLAN_RATE
        ,[VL_RETURN_RATE]                         = ISNULL(ret.VL_RATE,0) 
        ,[VL_REFUND_RATE]                         = ISNULL(ref.VL_RATE,0) 
        ,[VL_REPLACEMENT_RATE]                    = ISNULL(replacement.VL_RATE,0)	
        ,[VL_DEPRECIATION_RATE]                   = ISNULL(depreciation.VL_RATE,0)
        ,[AMT_MEK_HEDGING_EUR]                    = ISNULL(mek.VERPR,mek_last.VERPR)
		,[D_MEK_DATE]							  = ISNULL(mek.LOAD_TIMESTAMP,mek_last.LOAD_TIMESTAMP)
        ,[AMT_GTS_MARKUP]                         = mek.VERPR / (1+ ISNULL(L0_MI_OTHER_DELIVERY_COSTSRATES.OTHERDELIVERYRELATEDCOSTSRATES,0)) /(1+ CASE WHEN GTS.GTSMARKUPRATES < 0 THEN 0 ELSE ISNULL(GTS.GTSMARKUPRATES,0) END) * CASE WHEN GTS.GTSMARKUPRATES < 0 THEN 0 ELSE ISNULL(GTS.GTSMARKUPRATES,0) END
        ,[AMT_SHIPPING_COST_EST_EUR]              = ship_cost_fbm.main_shipping_cost 
        ,[D_EFFECTIVE]                            = @PRICE_DATE
	FROM L0.[L0_MI_PLAN_PRICE_EV_TARGETS] ev
	INNER JOIN L1.L1_DIM_A_ITEM item
		ON cast(ev.ItemNo as int) = cast(item.CD_ITEM as int)	
	CROSS JOIN L0.[L0_MI_PLAN_PRICE_COUNTRY_MARKETING_COMMISSIONS] country
	LEFT JOIN CTE_MEK mek
		on cast(mek.MATNR as int)  =  cast(ev.ItemNo as int)	
		AND CASE WHEN ev.ITEMTYPE = 'A' THEN '100' ELSE ev.ITEMTYPE END = mek.BWTAR
		AND ev.STORAGELOCATIONCODE = mek.BWKEY
		and mek.LOAD_TIMESTAMP = @PRICE_DATE
	LEFT JOIN CTE_MEK mek_last
		on cast(mek_last.MATNR as int)  =  cast(ev.ItemNo as int)	
		AND CASE WHEN ev.ITEMTYPE = 'A' THEN '100' ELSE ev.ITEMTYPE END = mek_last.BWTAR
		AND ev.STORAGELOCATIONCODE = mek_last.BWKEY
		AND mek_last.LastVersion = 1
	LEFT JOIN  [L0].[L0_MI_OTHER_DELIVERY_COSTSRATES] L0_MI_OTHER_DELIVERY_COSTSRATES
        ON @PRICE_DATE between L0_MI_OTHER_DELIVERY_COSTSRATES.VALID_FROM and L0_MI_OTHER_DELIVERY_COSTSRATES.VALID_TO
	LEFT JOIN [L0].[L0_MI_GTS_MARKUP_RATES] GTS
		ON ev.ItemNo = GTS.ITEMNO
			AND @PRICE_DATE between GTS.VALID_FROM and GTS.VALID_TO
	LEFT JOIN [L0].[L0_MI_STORAGE_LOCATION] stor1 
            ON stor1.STORAGELOCATIONCODE=ev.STORAGELOCATIONCODE
             AND stor1.COMPANYCODE='1000'
             AND stor1.Source = 'SAP' 
	LEFT JOIN CTE_SHIPP_COSTS ship_cost_fbm
		ON ev.ItemNo = ship_cost_fbm.Item_code
			AND country.CHANNELCOUNTRY=ship_cost_fbm.country
			AND stor1.STORAGELOCATION=ship_cost_fbm.warehouse
			AND ship_cost_fbm.Fulfillment = 'FBM'
	LEFT JOIN [L0].[L0_MI_COUNTRY_MAPPING] cmi
			ON country.CHANNELCOUNTRY = cmi.COUNTRY
	LEFT JOIN [L1].[L1_DIM_A_SALES_REPLACEMENT_VALUES] replacement
			ON item.T_PRODUCT_HIERARCHY_2 = replacement.T_PRODUCT_HIERARCHY_2
			AND cmi.INVOICECOUNTRYGROUP = replacement.[CD_COUNTRY_INVOICE_GROUP]
			AND @PRICE_DATE BETWEEN replacement.D_VALID_FROM AND replacement.D_VALID_TO
	LEFT JOIN L1.L1_DIM_A_SALES_REFUND_VALUES ref  
			on @PRICE_DATE BETWEEN ref.D_VALID_FROM AND ref.D_VALID_TO
			and cmi.INVOICECOUNTRYGROUP=ref.CD_COUNTRY_INVOICE_GROUP
			and item.T_PRODUCT_HIERARCHY_2 =ref.[T_PRODUCT_HIERARCHY_2]
	LEFT JOIN L1.L1_DIM_A_SALES_RETURN_VALUES ret  
			on @PRICE_DATE BETWEEN ret.D_VALID_FROM AND ret.D_VALID_TO
			and cmi.INVOICECOUNTRYGROUP=ret.CD_COUNTRY_INVOICE_GROUP
			and item.T_PRODUCT_HIERARCHY_2 =ret.T_PRODUCT_HIERARCHY_2
		--join Depreciation values
	LEFT JOIN [L1].[L1_DIM_A_DEPRECIATION_VALUES] depreciation
		ON @PRICE_DATE BETWEEN depreciation.D_VALID_FROM AND depreciation.D_VALID_TO
			AND stor1.STORAGELOCATION=depreciation.[T_STORAGE_LOCATION]
			AND item.T_PRODUCT_HIERARCHY_2 =depreciation.[T_PRODUCT_HIERARCHY_2]	
	where ev.ItemNo = '10035175'
		
), cte_l1 as(
SELECT 
	*
		,AMT_FIXED_COSTS_EUR					 =	(ISNULL([AMT_MEK_HEDGING_EUR],0) - ISNULL([AMT_GTS_MARKUP],0)  + (([VL_RETURN_RATE]*ISNULL([AMT_MEK_HEDGING_EUR],0))*[VL_DEPRECIATION_RATE]))												+
													--- Shipping estimates c4po
													+
													([AMT_SHIPPING_COST_EST_EUR] ) * (1+[VL_RETURN_RATE]+[VL_REPLACEMENT_RATE])


FROM cte_main
),
cte_marketing as
(
	select *,
			[AMT_PLAN_PRICE_MIN_EUR] = ROUND((AMT_FIXED_COSTS_EUR / (1 - [VL_COUNTRY_MARKETING_COMMISSION_RATE] - [VL_REFUND_RATE] - [VL_MIN_EV_RATE])),2)
			,[AMT_PLAN_PRICE_STD_EUR] = ROUND((AMT_FIXED_COSTS_EUR / (1 - [VL_COUNTRY_MARKETING_COMMISSION_RATE] - [VL_REFUND_RATE] - [VL_STD_EV_RATE])),2)
			,[AMT_PLAN_PRICE_MAX_EUR] = ROUND((AMT_FIXED_COSTS_EUR / (1 - [VL_COUNTRY_MARKETING_COMMISSION_RATE] - [VL_REFUND_RATE] - [VL_MAX_EV_RATE])),2)

	FROM cte_l1

),
cte_final as
(
	select *,
			[AMT_MARKETING_COSTS_MIN_EUR] = ROUND([AMT_PLAN_PRICE_MIN_EUR] * [VL_COUNTRY_MARKETING_COMMISSION_RATE] ,2)
			,[AMT_MARKETING_COSTS_STD_EUR] = ROUND([AMT_PLAN_PRICE_STD_EUR] * [VL_COUNTRY_MARKETING_COMMISSION_RATE] ,2)
			,[AMT_MARKETING_COSTS_MAX_EUR] = ROUND([AMT_PLAN_PRICE_MAX_EUR] * [VL_COUNTRY_MARKETING_COMMISSION_RATE] ,2)

			,[AMT_REFUND_VALUE_MIN_EUR] = ROUND([AMT_PLAN_PRICE_MIN_EUR] * [VL_REFUND_RATE] ,2)
			,[AMT_REFUND_VALUE_STD_EUR] = ROUND([AMT_PLAN_PRICE_STD_EUR] * [VL_REFUND_RATE] ,2)
			,[AMT_REFUND_VALUE_MAX_EUR] = ROUND([AMT_PLAN_PRICE_MAX_EUR] * [VL_REFUND_RATE] ,2)

	FROM cte_marketing
)


SELECT
			[D_EFFECTIVE]								= @PRICE_DATE
           ,[ID_ITEM]									= [ID_ITEM]
           ,[NUM_ITEM]									= [NUM_ITEM]
           ,[CD_ITEM_TYPE]								= [CD_ITEM_TYPE]
           ,[CD_FULFILLMENT]							= [CD_FULFILLMENT]
           ,[CD_STORAGE_LOCATION]						= [CD_STORAGE_LOCATION]
           ,[CD_CHANNEL_COUNTRY]						= [CD_CHANNEL_COUNTRY]
           ,[VL_MIN_EV_RATE]							= [VL_MIN_EV_RATE]
           ,[VL_STD_EV_RATE]							= [VL_STD_EV_RATE]
           ,[VL_MAX_EV_RATE]							= [VL_MAX_EV_RATE]
           ,[VL_COUNTRY_MARKETING_COMMISSION_RATE]		= [VL_COUNTRY_MARKETING_COMMISSION_RATE]
           ,[VL_RETURN_RATE]							= [VL_RETURN_RATE]
           ,[VL_REFUND_RATE]							= [VL_REFUND_RATE]
           ,[VL_REPLACEMENT_RATE]						= [VL_REPLACEMENT_RATE]
           ,[VL_DEPRECIATION_RATE]						= [VL_DEPRECIATION_RATE]
           ,[AMT_MEK_HEDGING_EUR]						= [AMT_MEK_HEDGING_EUR]
           ,[AMT_GTS_MARKUP]							= [AMT_GTS_MARKUP]
           ,[D_MEK_DATE]								= [D_MEK_DATE]
           ,[AMT_SHIPPING_COST_EST_EUR]					= [AMT_SHIPPING_COST_EST_EUR]
           ,[AMT_MARKETING_COSTS_MIN_EUR]				= [AMT_MARKETING_COSTS_MIN_EUR]
           ,[AMT_REFUND_VALUE_MIN_EUR]					= [AMT_REFUND_VALUE_MIN_EUR]
           ,[AMT_TOTAL_COSTS_MIN_EUR]					= [AMT_FIXED_COSTS_EUR] + [AMT_MARKETING_COSTS_MIN_EUR] + [AMT_REFUND_VALUE_MIN_EUR]
           ,[AMT_PLAN_PRICE_MIN_EUR]					= [AMT_PLAN_PRICE_MIN_EUR]
           ,[AMT_MARKETING_COSTS_STD_EUR]				= [AMT_MARKETING_COSTS_STD_EUR]
           ,[AMT_REFUND_VALUE_STD_EUR]					= [AMT_REFUND_VALUE_STD_EUR]
           ,[AMT_TOTAL_COSTS_STD_EUR]					= [AMT_FIXED_COSTS_EUR] + [AMT_MARKETING_COSTS_STD_EUR] + [AMT_REFUND_VALUE_STD_EUR]
           ,[AMT_PLAN_PRICE_STD_EUR]					= [AMT_PLAN_PRICE_STD_EUR]
           ,[AMT_MARKETING_COSTS_MAX_EUR]				= [AMT_MARKETING_COSTS_MAX_EUR]
           ,[AMT_REFUND_VALUE_MAX_EUR]					= [AMT_REFUND_VALUE_MAX_EUR]
           ,[AMT_TOTAL_COSTS_MAX_EUR]					= [AMT_FIXED_COSTS_EUR] + [AMT_MARKETING_COSTS_MAX_EUR] + [AMT_REFUND_VALUE_MAX_EUR] 
           ,[AMT_PLAN_PRICE_MAX_EUR]					= [AMT_PLAN_PRICE_MAX_EUR]
           ,[DT_DWH_CREATED]							= sysdatetime() 
           ,[DT_DWH_UPDATED]							= sysdatetime() 
FROM cte_final

select * 
from [L1].[L1_FACT_F_PLAN_PRICE]  where num_item ='10004397' and [CD_CHANNEL_COUNTRY] = 'DE' order by d_effective