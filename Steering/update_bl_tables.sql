;WITH bp_global as (
	
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
	FCNOVFactor = (NOV-BP_NOV)/NOV ,
	bp.BP_NOQ,
	fc.NOQ,
	FCNOQFactor = CASE WHEN ISNULL(NOQ,0) > 0 THEN (NOQ-BP_NOQ)/NOQ ELSE (NOV-BP_NOV)/NOV END
FROM bp_global bp
LEFT JOIN [L0].[L0_MI_BL_FORECAST_TARGETS] fc
	on REPLACE(fc.CHANNELGROUP3,' ','') = REPLACE(bp.CD_CHANNEL_GROUP_3,' ','')
	and cast(fc.TARGETMONTH as date) = bp.D_TARGET
	)
--select * from cte_fc_factor where d_target = '2025-01-01'

INSERT INTO [L1].[L1_FACT_F_BOTTOM_LINE_FORECAST_HISTORY]
(
	
	    [D_TARGET], 
	    [ID_ITEM],
		[NUM_ITEM],
        [CD_CHANNEL_GROUP_3],
		[CD_CHANNEL_GROUP_1],
	    [CD_COUNTRY_GROUP],
        [AMT_PLAN_PRICE_EUR],
        [VL_ITEM_QUANTITY],
        [AMT_TARGET_NET_ORDER_VALUE_EUR],
        [DT_DWH_CREATED],
        [DT_DWH_UPDATED] 
)

SELECT                                    
       D_TARGET = ISNULL(run_rates.DATE_ADJUSTED,'2025-02-01')
	  ,b_plan.[ID_ITEM]
	  ,item.[NUM_ITEM]
      ,b_plan.[CD_CHANNEL_GROUP_3]
	  ,ISNULL(spl.CHANNELGROUP1,b_plan.[CD_CHANNEL_GROUP_3]) [CD_CHANNEL_GROUP_1]
	  ,b_plan.[CD_COUNTRY_GROUP]
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
	WHERE month(b_plan.D_TARGET) =2
	AND year(b_plan.D_TARGET) =2025
	--and run_rates.DATE_ADJUSTED is null



		--select distinct T_PRODUCT_HIERARCHY_2,T_PRODUCT_HIERARCHY_1 
		--from l1.l1_fact_a_sales_transaction where id_item = 33782

	--select month(D_TARGET) ,sum([AMT_TARGET_NET_ORDER_VALUE_EUR]) from [L1].[L1_FACT_F_BOTTOM_LINE_FORECAST_HISTORY] group by  month(D_TARGET)