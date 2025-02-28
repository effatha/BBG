--LEFT JOIN L0.L0_MI_COST_DELAY_FACTOR cancellation_delay
--	on getdate() between cancellation_delay.validfrom and cancellation_delay.ValidTo
--	AND cancellation_delay.COST_KPI = 'Cancellations'
--LEFT JOIN L0.L0_MI_COST_DELAY_FACTOR return_delay
--	on getdate() between return_delay.validfrom and return_delay.ValidTo
--	AND return_delay.COST_KPI = 'Returns'
--LEFT JOIN L0.L0_MI_COST_DELAY_FACTOR refunds_delay
--	on getdate() between refunds_delay.validfrom and refunds_delay.ValidTo
--	AND refunds_delay.COST_KPI = 'Refunds'
--LEFT JOIN L0.L0_MI_COST_DELAY_FACTOR depreciation_delay
--	on getdate() between depreciation_delay.validfrom and depreciation_delay.ValidTo
--	AND depreciation_delay.COST_KPI = 'Depreciation'
--LEFT JOIN L0.L0_MI_COST_DELAY_FACTOR replacement_delay
--	on getdate() between replacement_delay.validfrom and replacement_delay.ValidTo
--	AND replacement_delay.COST_KPI = 'Replacements'


----------------------------------------------------------
-- UNPIVOT CTE FOR FORECAST VALUES
---------------------------------------------------------
with cte_monthly_forecast AS (
SELECT 
    [ITEMNO],
    [ITEMTYPE],
    [CHANNELGROUP3],
    [REASONCODE],
    [REASONCOMMMENT],
    [forecastdate] = CAST(REPLACE(SUBSTRING(forecastdate,1,10), '_', '-') as date),
    [forecastvalue]
FROM 
    (SELECT 
        [ITEMNO],
        [ITEMTYPE],
        [CHANNELGROUP3],
        [REASONCODE],
        [REASONCOMMMENT]
      ,[2023_01_01_00_00_00]
      ,[2023_02_01_00_00_00]
      ,[2023_03_01_00_00_00]
      ,[2023_04_01_00_00_00]
      ,[2023_05_01_00_00_00]
      ,[2023_06_01_00_00_00]
      ,[2023_07_01_00_00_00]
      ,[2023_08_01_00_00_00]
      ,[2023_09_01_00_00_00]
      ,[2023_10_01_00_00_00]
      ,[2023_11_01_00_00_00]
      ,[2023_12_01_00_00_00]
      ,[2024_01_01_00_00_00]
      ,[2024_02_01_00_00_00]
      ,[2024_03_01_00_00_00]
      ,[2024_04_01_00_00_00]
      ,[2024_05_01_00_00_00]
      ,[2024_06_01_00_00_00]
      ,[2024_07_01_00_00_00]
      ,[2024_08_01_00_00_00]
      ,[2024_09_01_00_00_00]
      ,[2024_10_01_00_00_00]
      ,[2024_11_01_00_00_00]
      ,[2024_12_01_00_00_00]
      ,[2025_01_01_00_00_00]
      ,[2025_02_01_00_00_00]
      ,[2025_03_01_00_00_00]
      ,[2025_04_01_00_00_00]
      ,[2025_05_01_00_00_00]
      ,[2025_06_01_00_00_00]
      ,[2025_07_01_00_00_00]
      ,[2025_08_01_00_00_00]
      ,[2025_09_01_00_00_00]
      ,[2025_10_01_00_00_00]
      ,[2025_11_01_00_00_00]
      ,[2025_12_01_00_00_00]
      ,[2026_01_01_00_00_00]
      ,[2026_02_01_00_00_00]
      ,[2026_03_01_00_00_00]
      ,[2026_04_01_00_00_00]
      ,[2026_05_01_00_00_00]
      ,[2026_06_01_00_00_00]
      ,[2026_07_01_00_00_00]
      ,[2026_08_01_00_00_00]
      ,[2026_09_01_00_00_00]
      ,[2026_10_01_00_00_00]
      ,[2026_11_01_00_00_00]
      ,[2026_12_01_00_00_00]
      ,[2027_01_01_00_00_00]
      ,[2027_02_01_00_00_00]
      ,[2027_03_01_00_00_00]
      ,[2027_04_01_00_00_00]
      ,[2027_05_01_00_00_00]
      ,[2027_06_01_00_00_00]
      ,[2027_07_01_00_00_00]
      ,[2027_08_01_00_00_00]
      ,[2027_09_01_00_00_00]
      ,[2027_10_01_00_00_00]
      ,[2027_11_01_00_00_00]
      ,[2027_12_01_00_00_00]
        [LOAD_TIMESTAMP]
    FROM L0.L0_MI_FORECAST_INPUT
    ) AS SourceTable
UNPIVOT
    (
        forecastvalue FOR forecastdate IN 
        (
		     [2023_01_01_00_00_00]
			,[2023_02_01_00_00_00]
			,[2023_03_01_00_00_00]
			,[2023_04_01_00_00_00]
			,[2023_05_01_00_00_00]
			,[2023_06_01_00_00_00]
			,[2023_07_01_00_00_00]
			,[2023_08_01_00_00_00]
			,[2023_09_01_00_00_00]
			,[2023_10_01_00_00_00]
			,[2023_11_01_00_00_00]
			,[2023_12_01_00_00_00]
			,[2024_01_01_00_00_00]
			,[2024_02_01_00_00_00]
			,[2024_03_01_00_00_00]
			,[2024_04_01_00_00_00]
			,[2024_05_01_00_00_00]
			,[2024_06_01_00_00_00]
			,[2024_07_01_00_00_00]
			,[2024_08_01_00_00_00]
			,[2024_09_01_00_00_00]
			,[2024_10_01_00_00_00]
			,[2024_11_01_00_00_00]
			,[2024_12_01_00_00_00]
			,[2025_01_01_00_00_00]
			,[2025_02_01_00_00_00]
			,[2025_03_01_00_00_00]
			,[2025_04_01_00_00_00]
			,[2025_05_01_00_00_00]
			,[2025_06_01_00_00_00]
			,[2025_07_01_00_00_00]
			,[2025_08_01_00_00_00]
			,[2025_09_01_00_00_00]
			,[2025_10_01_00_00_00]
			,[2025_11_01_00_00_00]
			,[2025_12_01_00_00_00]
			,[2026_01_01_00_00_00]
			,[2026_02_01_00_00_00]
			,[2026_03_01_00_00_00]
			,[2026_04_01_00_00_00]
			,[2026_05_01_00_00_00]
			,[2026_06_01_00_00_00]
			,[2026_07_01_00_00_00]
			,[2026_08_01_00_00_00]
			,[2026_09_01_00_00_00]
			,[2026_10_01_00_00_00]
			,[2026_11_01_00_00_00]
			,[2026_12_01_00_00_00]
			,[2027_01_01_00_00_00]
			,[2027_02_01_00_00_00]
			,[2027_03_01_00_00_00]
			,[2027_04_01_00_00_00]
			,[2027_05_01_00_00_00]
			,[2027_06_01_00_00_00]
			,[2027_07_01_00_00_00]
			,[2027_08_01_00_00_00]
			,[2027_09_01_00_00_00]
			,[2027_10_01_00_00_00]
			,[2027_11_01_00_00_00]
		
		)
    ) AS monthly_forecast
	),
cte_daily_fc as 
(
	SELECT
		    [ITEMNO],
			[ITEMTYPE],
			[CHANNELGROUP3],
			[REASONCODE],
			[REASONCOMMMENT],
			[forecastdate] = calendar.[DATE],
			[forecastvalue] = CAST(fc.forecastvalue as decimal (19,2))/DAY(EOMONTH(calendar.[DATE]))  
	FROM cte_monthly_forecast fc
	LEFT JOIN [L0].[L0_CALENDAR] calendar
		ON YEAR(fc.forecastdate) = YEAR(calendar.date)
		AND MONTH(fc.forecastdate) = MONTH(calendar.date)

),
cte_mek as (
SELECT 
		MATNR
	,VERPR
	,BWKEY
	,BWTAR
	,LOAD_TIMESTAMP 
	,rank() over (partition by CAST(MATNR as int),BWKEY,BWTAR ORDER BY LOAD_TIMESTAMP DESC ) AS LastVersion
FROM [L0].[L0_S4HANA_MBEW] 
WHERE cast(MATNR as int) in (SELECT ItemNo from cte_monthly_forecast)
),
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
	AND cost.item_code in  (SELECT cast(ItemNo as nvarchar(50)) from cte_monthly_forecast)
GROUP BY 
	cost.item_code,
	cost.warehouse,
	cost.country,
	ctypes.cost_type_name
)
----------------------------------------------------------
-- UNPIVOT CTE FOR FORECAST VALUES
---------------------------------------------------------
, cte_l1 as (
SELECT
	[CD_ITEM]				= f.[ITEMNO]
	,[ID_ITEM]				= item.ID_ITEM
    ,[CD_ITEM_TYPE]			= f.[ITEMTYPE]
    ,[CD_CHANNEL_GROUP_3]	= f.[CHANNELGROUP3]
    ,[CD_REASON_CODE]		= f.[REASONCODE]
    ,[T_REASON_COMMENT]		= f.[REASONCOMMMENT]
    ,[D_FORECAST]			= f.[forecastdate]
    ,[VL_QUANTITY_TOTAL]	= f.[forecastvalue]
	,[CD_COUNTRY_GROUP]			= ct.Country
	,[VL_QUANTITY]			= Round(f.[forecastvalue] * ct.ratio,2)
	,[AMT_PLAN_PRICE_TOTAL]	= ROUND(Round(f.[forecastvalue] * ct.ratio,2) * ISNULL(pl.PLANPRICEWITHOUTVAT,pl_default.PLANPRICEWITHOUTVAT),2)
	,[AMT_PLAN_PRICE_EUR]	= ROUND(ISNULL(pl.PLANPRICEWITHOUTVAT,pl_default.PLANPRICEWITHOUTVAT),2)
	,[AMT_MEK_HEDGING_EUR]  = mek.VERPR
    ,[AMT_GTS_MARKUP_EUR]       = ISNULL(mek.VERPR,0) / (1+ ISNULL(L0_MI_OTHER_DELIVERY_COSTSRATES.OTHERDELIVERYRELATEDCOSTSRATES,0)) /(1+ CASE WHEN GTS.GTSMARKUPRATES < 0 THEN 0 ELSE ISNULL(GTS.GTSMARKUPRATES,0) END) * CASE WHEN GTS.GTSMARKUPRATES < 0 THEN 0 ELSE ISNULL(GTS.GTSMARKUPRATES,0) END
	,[AMT_SHIPPING_COST_EST_EUR]              = ship_cost_fbm.main_shipping_cost
	,[VL_RETURN_RATE]                         = ISNULL(ret.VL_RATE,0) 
    ,[VL_REFUND_RATE]                         = ISNULL(ref.VL_RATE,0) 
    ,[VL_REPLACEMENT_RATE]                    = ISNULL(replacement.VL_RATE,0)	
	,[VL_REPLACEMENT_QUANTITY_RATE]           = ISNULL(replacement.VL_QUANTITY_RATE,0)	
    ,[VL_DEPRECIATION_RATE]                   = ISNULL(depreciation.VL_RATE,0)
	,[VL_CANCELLATION_RATE]					  = ISNULL(cll.VL_RATE,0)	
	,[VL_COMMISSIONS_RATE]					  = ISNULL(COMMISSIONS_RATE,0)
	,[VL_MARKETING_RATE]					  = ISNULL(MARKETING_COMMISSIONS_PLAN_RATE,0)
	--,[NUM_RETURN_DELAY]                         = ISNULL(return_delay.DELAYFACTORDAYS,0)
 --   ,[NUM_REFUND_DELAY]                         = ISNULL(refunds_delay.DELAYFACTORDAYS,0)
 --   ,[NUM_REPLACEMENT_DELAY]                    = ISNULL(replacement_delay.DELAYFACTORDAYS,0)
 --   ,[NUM_DEPRECIATION_DELAY]                   = ISNULL(depreciation_delay.DELAYFACTORDAYS,0)
	--,[NUM_CANCELLATION_DELAY]					= ISNULL(cancellation_delay.DELAYFACTORDAYS,0)	
--	,[AMT_TAX_TOTAL_EUR]					  = 0.19 * ROUND(Round(f.[forecastvalue] * ct.ratio,2) * ISNULL(pl.PLANPRICEWITHOUTVAT,pl_default.PLANPRICEWITHOUTVAT),2)---- default de ---maybe using a lookup table for VAT ratess
FROM cte_daily_fc f
INNER JOIN L1.L1_DIM_A_ITEM item
	ON cast(f.ItemNo as int) = cast(item.CD_ITEM as int)	
LEFT JOIN  L0.L0_MI_FC_COUNTRY_CHANNEL_SHARE ct
	on ct.CHANNELGROUP3 = f.CHANNELGROUP3
LEFT JOIN L0.L0_MI_FC_COUNTRY_PLAN_PRICE pl
	on pl.ITEMNO = f.ITEMNO
	AND pl.ITEMTYPE = f.ITEMTYPE
	AND pl.COUNTRY = ct.COUNTRY
LEFT JOIN L0.L0_MI_FC_COUNTRY_PLAN_PRICE pl_default
	on pl_default.ITEMNO = f.ITEMNO
	AND pl_default.ITEMTYPE = f.ITEMTYPE
	AND pl_default.COUNTRY = 'INT'
	AND pl.itemno is null
LEFT JOIN CTE_MEK mek
	on cast(mek.MATNR as int)  =  cast(f.ITEMNO as int)	
	AND CASE WHEN f.ITEMTYPE = 'A' THEN '100' ELSE f.ITEMTYPE END = mek.BWTAR
	AND mek.BWKEY = 1000 ----- for now will use 100 but it would make sense that for CEE we use bratislava plant?
	AND LastVersion = 1
LEFT JOIN [L0].[L0_MI_STORAGE_LOCATION] stor1 
        ON stor1.STORAGELOCATIONCODE= '1000'
            AND stor1.COMPANYCODE='1000'
            AND stor1.Source = 'SAP' 
LEFT JOIN [L0].[L0_MI_COUNTRY_MAPPING] cmi
		ON ct.COUNTRY = cmi.COUNTRY
LEFT JOIN  [L0].[L0_MI_OTHER_DELIVERY_COSTSRATES] L0_MI_OTHER_DELIVERY_COSTSRATES
    ON getdate() between L0_MI_OTHER_DELIVERY_COSTSRATES.VALID_FROM and L0_MI_OTHER_DELIVERY_COSTSRATES.VALID_TO
LEFT JOIN [L0].[L0_MI_GTS_MARKUP_RATES] GTS
	ON f.ItemNo = GTS.ITEMNO
		AND getdate() between GTS.VALID_FROM and GTS.VALID_TO
LEFT JOIN CTE_SHIPP_COSTS ship_cost_fbm
	ON cast(f.ItemNo as nvarchar(50)) = ship_cost_fbm.Item_code
		AND CASE WHEN ct.Country = 'INT'THEN 'DE'ELSE ct.Country END =ship_cost_fbm.country
		AND ship_cost_fbm.warehouse = 'Kamp-Lintfort'
		AND ship_cost_fbm.Fulfillment = 'FBM'
---- Proxies
LEFT JOIN [L1].[L1_DIM_A_SALES_REPLACEMENT_VALUES] replacement
		ON item.T_PRODUCT_HIERARCHY_2 = replacement.T_PRODUCT_HIERARCHY_2
		AND isnull(cmi.INVOICECOUNTRYGROUP,'INT') = replacement.[CD_COUNTRY_INVOICE_GROUP]
		AND getdate() BETWEEN replacement.D_VALID_FROM AND replacement.D_VALID_TO
LEFT JOIN L1.L1_DIM_A_SALES_REFUND_VALUES ref  
		on getdate()  BETWEEN ref.D_VALID_FROM AND ref.D_VALID_TO
		and isnull(cmi.INVOICECOUNTRYGROUP,'INT')=ref.CD_COUNTRY_INVOICE_GROUP
		and item.T_PRODUCT_HIERARCHY_2 =ref.[T_PRODUCT_HIERARCHY_2]
LEFT JOIN L1.L1_DIM_A_SALES_RETURN_VALUES ret  
		on getdate()  BETWEEN ret.D_VALID_FROM AND ret.D_VALID_TO
		and isnull(cmi.INVOICECOUNTRYGROUP,'INT')=ret.CD_COUNTRY_INVOICE_GROUP
		and item.T_PRODUCT_HIERARCHY_2 =ret.T_PRODUCT_HIERARCHY_2
	--join Depreciation values
LEFT JOIN [L1].[L1_DIM_A_DEPRECIATION_VALUES] depreciation
	ON getdate() BETWEEN depreciation.D_VALID_FROM AND depreciation.D_VALID_TO
		AND stor1.STORAGELOCATION=depreciation.[T_STORAGE_LOCATION]
		AND item.T_PRODUCT_HIERARCHY_2 =depreciation.[T_PRODUCT_HIERARCHY_2]	
LEFT JOIN L1.L1_DIM_A_ORDER_CANCELLATION_VALUES cll  
			on getdate() BETWEEN cll.D_VALID_FROM AND cll.D_VALID_TO
			and isnull(cmi.INVOICECOUNTRYGROUP,'INT')=cll.CD_COUNTRY_INVOICE_GROUP
			and item.T_PRODUCT_HIERARCHY_2 =cll.[T_PRODUCT_HIERARCHY_2]
LEFT JOIN  L0.[L0_MI_PLAN_PRICE_COUNTRY_MARKETING_COMMISSIONS] com
	on com.ChannelCountry = ct.COUNTRY





where
	f.ItemNo = 10000109
	--AND f.[forecastdate] = '2025_03_01_00_00_00'
	--AND MONTH(f.[forecastdate]) = 3
	--AND YEAR(f.[forecastdate]) = 2025
	--AND f.[CHANNELGROUP3] = 'Shop WE'

)
, cte_l2 as (
SELECT 
*
,AMT_TURNOVER_EUR						= [AMT_PLAN_PRICE_TOTAL]
,AMT_GROSS_ORDER_VALUE_EUR				= [AMT_PLAN_PRICE_TOTAL]
,VL_CANCELLED_ORDER_QUANTITY			= [VL_QUANTITY] * [VL_CANCELLATION_RATE]
,AMT_CANCELLED_ORDER_VALUE_EUR			= [AMT_PLAN_PRICE_TOTAL] * [VL_CANCELLATION_RATE]
,VL_NET_ORDER_QUANTITY_EST				= [VL_QUANTITY] - ([VL_QUANTITY] * [VL_CANCELLATION_RATE])
,AMT_MARKETING_EUR						= [AMT_PLAN_PRICE_TOTAL] * [VL_MARKETING_RATE]
,AMT_COMMISSIONS_EUR					= [AMT_PLAN_PRICE_TOTAL] * [VL_COMMISSIONS_RATE]
,AMT_COMMISSIONS_REFUNDS_EUR			= ([AMT_PLAN_PRICE_TOTAL] * [VL_REFUND_RATE]) * [VL_COMMISSIONS_RATE]
,AMT_REFUNDED_ORDER_VALUE_EST			= [AMT_PLAN_PRICE_TOTAL] * [VL_REFUND_RATE]
,VL_REFUNDED_QUANTITY_EST				= ([VL_QUANTITY] - ([VL_QUANTITY] * [VL_CANCELLATION_RATE]) ) * [VL_REFUND_RATE]
,AMT_RETURNED_QUANTITY_EST				= ([VL_QUANTITY] - ([VL_QUANTITY] * [VL_CANCELLATION_RATE]) ) * [VL_RETURN_RATE]
,AMT_REPLACEMENT_ORDER_QUANTITY_EST		= ([VL_QUANTITY] - ([VL_QUANTITY] * [VL_CANCELLATION_RATE]) ) * [VL_REPLACEMENT_QUANTITY_RATE]
FROM 
cte_l1
), cte_final as (

SELECT
	*
	,AMT_NET_ORDER_VALUE_EST			= [AMT_PLAN_PRICE_TOTAL] - ([AMT_PLAN_PRICE_TOTAL] * [VL_CANCELLATION_RATE])
	,AMT_NET_PRODUCT_COST_EST			= (VL_NET_ORDER_QUANTITY_EST-VL_REFUNDED_QUANTITY_EST)*(ISNULL([AMT_MEK_HEDGING_EUR],0)-ISNULL([AMT_GTS_MARKUP_EUR],0))
	,AMT_SHIPPING_COSTS_INVOICED_EST	= VL_NET_ORDER_QUANTITY_EST * [AMT_SHIPPING_COST_EST_EUR]
	,AMT_SHIPPING_COSTS_RETURNED_EST	= (VL_NET_ORDER_QUANTITY_EST * [VL_RETURN_RATE]) *[AMT_SHIPPING_COST_EST_EUR]
	,AMT_SHIPPING_COSTS_REPLACED_EST	= AMT_REPLACEMENT_ORDER_QUANTITY_EST *  [AMT_SHIPPING_COST_EST_EUR]
	,AMT_REVENUE_EST_EUR				=  ([AMT_PLAN_PRICE_TOTAL] - ([AMT_PLAN_PRICE_TOTAL] * [VL_CANCELLATION_RATE])) - ([AMT_PLAN_PRICE_TOTAL] * [VL_REFUND_RATE])
FROM cte_l2
)
INSERT INTO [TEST].[L1_FACT_A_FORECAST_CPNL]
           ([CD_FORECAST]
           ,[D_FORECAST]
           ,[ID_ITEM]
           ,[CD_ITEM_TYPE]
           ,[CD_CHANNEL_GROUP_3]
           ,[CD_REASON_CODE]
           ,[T_REASON_COMMENT]
           ,[CD_COUNTRY_GROUP]
           ,[VL_QUANTITY]
           ,[AMT_PLAN_PRICE_EUR]
           ,[AMT_MEK_HEDGING_EUR]
           ,[AMT_GTS_MARKUP_EUR]
           ,[AMT_SHIPPING_COST_EST_EUR]
           ,[VL_RETURN_RATE]
           ,[VL_REFUND_RATE]
           ,[VL_REPLACEMENT_RATE]
           ,[VL_REPLACEMENT_QUANTITY_RATE]
           ,[VL_DEPRECIATION_RATE]
           ,[VL_CANCELLATION_RATE]
           ,[VL_COMMISSIONS_RATE]
           ,[VL_MARKETING_RATE]
           ,[AMT_TURNOVER_EUR]
           ,[VL_CANCELLED_ORDER_QUANTITY]
           ,[AMT_CANCELLED_ORDER_VALUE_EUR]
           ,[AMT_NET_ORDER_VALUE_EST]
           ,[VL_NET_ORDER_QUANTITY_EST]
           ,[AMT_REFUNDED_ORDER_VALUE_EST]
           ,[VL_REFUNDED_QUANTITY_EST]
           ,[AMT_COMMISSIONS_EUR]
           ,[AMT_COMMISSIONS_REFUNDS_EUR]
           ,[AMT_MARKETING_EUR]
           ,[AMT_REPLACEMENT_ORDER_QUANTITY_EST]
           ,[AMT_NET_PRODUCT_COST_EST]
           ,[AMT_SHIPPING_COSTS_INVOICED_EST]
           ,[AMT_SHIPPING_COSTS_RETURNED_EST]
           ,[AMT_SHIPPING_COSTS_REPLACED_EST]
           ,[AMT_REVENUE_EST_EUR])

SELECT 
			[CD_FORECAST] = CONCAT(ID_ITEM,'#',CD_ITEM_TYPE,'#',D_FORECAST,'#',CD_CHANNEL_GROUP_3,'#',CD_COUNTRY_GROUP)
           ,[D_FORECAST]
           ,[ID_ITEM]
           ,[CD_ITEM_TYPE]
           ,[CD_CHANNEL_GROUP_3]
           ,[CD_REASON_CODE]
           ,[T_REASON_COMMENT]
           ,[CD_COUNTRY_GROUP]
           ,[VL_QUANTITY]
           ,[AMT_PLAN_PRICE_EUR]
           ,[AMT_MEK_HEDGING_EUR]
           ,[AMT_GTS_MARKUP_EUR]
           ,[AMT_SHIPPING_COST_EST_EUR]
           ,[VL_RETURN_RATE]
           ,[VL_REFUND_RATE]
           ,[VL_REPLACEMENT_RATE]
           ,[VL_REPLACEMENT_QUANTITY_RATE]
           ,[VL_DEPRECIATION_RATE]
           ,[VL_CANCELLATION_RATE]
           ,[VL_COMMISSIONS_RATE]
           ,[VL_MARKETING_RATE]
           ,[AMT_TURNOVER_EUR]
           ,[VL_CANCELLED_ORDER_QUANTITY]
           ,[AMT_CANCELLED_ORDER_VALUE_EUR]
           ,[AMT_NET_ORDER_VALUE_EST]
           ,[VL_NET_ORDER_QUANTITY_EST]
           ,[AMT_REFUNDED_ORDER_VALUE_EST]
           ,[VL_REFUNDED_QUANTITY_EST]
           ,[AMT_COMMISSIONS_EUR]
           ,[AMT_COMMISSIONS_REFUNDS_EUR]
           ,[AMT_MARKETING_EUR]
           ,[AMT_REPLACEMENT_ORDER_QUANTITY_EST]
           ,[AMT_NET_PRODUCT_COST_EST]
           ,[AMT_SHIPPING_COSTS_INVOICED_EST]
           ,[AMT_SHIPPING_COSTS_RETURNED_EST]
           ,[AMT_SHIPPING_COSTS_REPLACED_EST]
           ,[AMT_REVENUE_EST_EUR]
FROM cte_final









--select * from  L0.[L0_MI_PLAN_PRICE_COUNTRY_MARKETING_COMMISSIONS]


--ALTER TABLE L0.[L0_MI_PLAN_PRICE_COUNTRY_MARKETING_COMMISSIONS] ADD COMMISSIONS_RATE decimal(19,2)





--CREATE TABLE TEST.L1_FACT_A_FORECAST_CPNL
--(
--	---dimensions
--	CD_FORECAST			VARCHAR(100),
--	D_FORECAST			DATE,
--	ID_ITEM				INT,
--	CD_ITEM_TYPE		VARCHAR(10),
--	CD_CHANNEL_GROUP_3	VARCHAR(50),
--	CD_REASON_CODE		VARCHAR(150),
--	T_REASON_COMMENT	VARCHAR(250),
--	CD_COUNTRY_GROUP	VARCHAR(10),
--	--measures
--	VL_QUANTITY							DECIMAL(19,2),
--	AMT_PLAN_PRICE_EUR					DECIMAL(19,2),
--	AMT_MEK_HEDGING_EUR					DECIMAL(19,2),
--	AMT_GTS_MARKUP_EUR					DECIMAL(19,2),
--	AMT_SHIPPING_COST_EST_EUR			DECIMAL(19,2),
--	VL_RETURN_RATE                      DECIMAL(19,2),
--    VL_REFUND_RATE                      DECIMAL(19,2),
--    VL_REPLACEMENT_RATE                 DECIMAL(19,2),
--	VL_REPLACEMENT_QUANTITY_RATE        DECIMAL(19,2),
--    VL_DEPRECIATION_RATE                DECIMAL(19,2),
--	VL_CANCELLATION_RATE				DECIMAL(19,2),
--	VL_COMMISSIONS_RATE					DECIMAL(19,2),
--	VL_MARKETING_RATE					DECIMAL(19,2),
--	---kpi's
--	AMT_TURNOVER_EUR					DECIMAL(19,2),
--	VL_CANCELLED_ORDER_QUANTITY			DECIMAL(19,2),
--	AMT_CANCELLED_ORDER_VALUE_EUR		DECIMAL(19,2),
--	AMT_NET_ORDER_VALUE_EST				DECIMAL(19,2),
--	VL_NET_ORDER_QUANTITY_EST			DECIMAL(19,2),
--	AMT_REFUNDED_ORDER_VALUE_EST		DECIMAL(19,2),
--	VL_REFUNDED_QUANTITY_EST			DECIMAL(19,2),
--	AMT_COMMISSIONS_EUR					DECIMAL(19,2),
--	AMT_COMMISSIONS_REFUNDS_EUR			DECIMAL(19,2),
--	AMT_MARKETING_EUR					DECIMAL(19,2),
--	AMT_REPLACEMENT_ORDER_QUANTITY_EST  DECIMAL(19,2),
--	AMT_NET_PRODUCT_COST_EST			DECIMAL(19,2),
--	AMT_SHIPPING_COSTS_INVOICED_EST	DECIMAL(19,2),
--	AMT_SHIPPING_COSTS_RETURNED_EST	DECIMAL(19,2),
--	AMT_SHIPPING_COSTS_REPLACED_EST	DECIMAL(19,2),
--	AMT_REVENUE_EST_EUR				DECIMAL(19,2)



--)
--WITH
--(
--    DISTRIBUTION = REPLICATE,
--    HEAP
--)
