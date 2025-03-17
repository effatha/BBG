;WITH bp_global as (
	
	SELECT CD_CHANNEL_GROUP_3, D_TARGET,SUM(AMT_TARGET_NET_ORDER_VALUE_EUR) BP_NOV
	FROM [L1].[L1_FACT_F_BUSINESS_PLAN] bs
	 
	GROUP BY CD_CHANNEL_GROUP_3, D_TARGET
)

, cte_fc_factor as (
SELECT bp.CD_CHANNEL_GROUP_3,bp.D_TARGET, bp.BP_NOV,fc.NOV, (NOV-BP_NOV)/NOV AS FCFactor
FROM bp_global bp
LEFT JOIN [L0].[L0_MI_BL_FORECAST_TARGETS] fc
	on REPLACE(fc.CHANNELGROUP3,' ','') = REPLACE(bp.CD_CHANNEL_GROUP_3,' ','')
	and cast(fc.TARGETMONTH as date) = bp.D_TARGET
	)



SELECT                                    
       D_TARGET = run_rates.DATE_ADJUSTED 
	  ,b_plan.[ID_ITEM]
	  ,item.[NUM_ITEM]
      ,b_plan.[CD_CHANNEL_GROUP_3]
	  ,ISNULL(spl.CHANNELGROUP1,b_plan.[CD_CHANNEL_GROUP_3]) [CD_CHANNEL_GROUP_1]
	  ,b_plan.[CD_COUNTRY_GROUP]
      ,b_plan.[AMT_PLAN_PRICE_EUR]
      ,[VL_ITEM_QUANTITY] = (b_plan.VL_ITEM_QUANTITY/(1-FCFactor))* isnull(spl.NOQ_SHARE,1) *  ISNULL(CAST(run_rates.rr as decimal(19,9)) ,1)
      ,[AMT_TARGET_NET_ORDER_VALUE_EUR] =(b_plan.AMT_TARGET_NET_ORDER_VALUE_EUR /(1-FCFactor))* isnull(spl.NOV_SHARE,1) *  ISNULL(CAST(run_rates.rr as decimal(19,9)) ,1)
      ,b_plan.[DT_DWH_CREATED]
      ,b_plan.[DT_DWH_UPDATED]
	
	from [L1].[L1_FACT_F_BUSINESS_PLAN] b_plan
	LEFT JOIN TEST.L0_MI_BS_CHANNEL_SPLIT spl
		on spl.TARGET_DATE = b_plan.[D_TARGET]
		and REPLACE(spl.CHANNELGROUP3,' ','') = REPLACE(b_plan.[CD_CHANNEL_GROUP_3],' ','')
	LEFT JOIN L1.L1_DIM_A_ITEM item
    on item.[ID_ITEM] = b_plan.[ID_ITEM]
	INNER JOIN [L0].[L0_MI_FC_BL_RUN_RATES] run_rates
	on run_rates.[CategoryL1] = item.T_PRODUCT_HIERARCHY_1
	AND	run_rates.[CategoryL2] = item.T_PRODUCT_HIERARCHY_2
	AND	run_rates.[CategoryL3] = item.T_PRODUCT_HIERARCHY_3
	AND	REPLACE(run_rates.[CHANNELGROUP3],' ','') = REPLACE(b_plan.[CD_CHANNEL_GROUP_3],' ','')
	AND run_rates.[month] = MONTH(b_plan.[D_TARGET])
	LEFT JOIN cte_fc_factor factor
	on factor.CD_CHANNEL_GROUP_3 = b_plan.CD_CHANNEL_GROUP_3
	and factor.D_TARGET = b_plan.[D_TARGET]
	WHERE month(b_plan.D_TARGET) = month(getdate())
	AND year(b_plan.D_TARGET) =year(getdate())
	and b_plan.[CD_CHANNEL_GROUP_3] = 'CEE'



	SELECT CD_CHANNEL_GROUP_1,sum([VL_ITEM_QUANTITY])[VL_ITEM_QUANTITY],sum([AMT_TARGET_NET_ORDER_VALUE_EUR])
	FROM 
	[TEST].[L1_FACT_F_BOTTOM_LINE_FORECAST]
	GROUP BY CD_CHANNEL_GROUP_3,CD_CHANNEL_GROUP_1


	SELECT CD_CHANNEL_GROUP_3,CD_Country_GROUP,sum([VL_ITEM_QUANTITY])[VL_ITEM_QUANTITY],sum([AMT_TARGET_NET_ORDER_VALUE_EUR])
	FROM 
	[TEST].[L1_FACT_F_BOTTOM_LINE_FORECAST]
	GROUP BY CD_CHANNEL_GROUP_3,CD_Country_GROUP



	SELECT * FROM TEST.L0_MI_BS_CHANNEL_SPLIT 