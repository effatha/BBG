CREATE VIEW PL.PL_V_REFUND_RATES_NEW_LAUNCH
AS
-- first identify items with first sale in the last 6 days
with cte_new_items as
(
	SELECT  ID_ITEM,NUM_ITEM,T_PRODUCT_HIERARCHY_3,T_PRODUCT_HIERARCHY_4,D_LAUNCH
	FROM L1.L1_DIM_A_ITEM
	where 
		D_LAUNCH between CAST(DATEADD(day,-60,getdate()) as date) and CAST(getdate() as date)
		and NUM_ITEM like '10%'
)
,
cte_rrr_item_rates as (
SELECT  distinct 
		c.ID_ITEM,T_PRODUCT_HIERARCHY_4,T_PRODUCT_HIERARCHY_3,
		ReturnRate					= ROUND((SUM([VL_RETURN_QUANTITY])/SUM([VL_ORDER_QUANTITY])),2),
		RefundRate					= ROUND((SUM(AMT_REFUNDS_EUR)/SUM(AMT_GROSS_ORDER_VALUE_EUR)),2),
		ReplacementRate				= ROUND((SUM(VL_REPLACEMENT_QUANTITY)/SUM(AMT_GROSS_ORDER_VALUE_EUR)),2) 
  FROM [L1].[L1_FACT_A_CLAIM_RATES] c
  INNER JOIN cte_new_items item
	on item.id_item = c.id_item
  WHERE 
   [D_SALES_PROCESS] between CAST(DATEADD(day,-60,getdate()) as date) and CAST(getdate() as date)
	and c.num_item like '1%'  
  GROUP BY 
   c.ID_ITEM,T_PRODUCT_HIERARCHY_4,T_PRODUCT_HIERARCHY_3
  HAVING  
	SUM(AMT_GROSS_ORDER_VALUE_EUR) > 0

)
, cte_rrr_item_family_rates as (
SELECT 
		T_PRODUCT_HIERARCHY_4,
		ReturnRate					= ROUND((SUM([VL_RETURN_QUANTITY])/SUM([VL_ORDER_QUANTITY])),2),
		RefundRate					= ROUND((SUM(AMT_REFUNDS_EUR)/SUM(AMT_GROSS_ORDER_VALUE_EUR)),2),
		ReplacementRate				= ROUND((SUM(VL_REPLACEMENT_QUANTITY)/SUM(AMT_GROSS_ORDER_VALUE_EUR)),2) 
  FROM [L1].[L1_FACT_A_CLAIM_RATES] c
  INNER JOIN cte_new_items it on it.ID_ITEM = c.ID_ITEM

  WHERE 
   [D_SALES_PROCESS] between CAST(DATEADD(day,-60,getdate()) as date) and CAST(getdate() as date)
	and c.num_item like '1%' 
  GROUP BY 
   T_PRODUCT_HIERARCHY_4
   HAVING  
	SUM(AMT_GROSS_ORDER_VALUE_EUR) > 0
),
 cte_rrr_item_L3_rates as (
SELECT 
		T_PRODUCT_HIERARCHY_3,
		ReturnRate					= ROUND((SUM([VL_RETURN_QUANTITY])/SUM([VL_ORDER_QUANTITY])),2),
		RefundRate					= ROUND((SUM(AMT_REFUNDS_EUR)/SUM(AMT_GROSS_ORDER_VALUE_EUR)),2),
		ReplacementRate				= ROUND((SUM(VL_REPLACEMENT_QUANTITY)/SUM(AMT_GROSS_ORDER_VALUE_EUR)),2) 
  FROM [L1].[L1_FACT_A_CLAIM_RATES] c
  INNER JOIN cte_new_items it on it.ID_ITEM = c.ID_ITEM
  WHERE 
   [D_SALES_PROCESS] between CAST(DATEADD(day,-60,getdate()) as date) and CAST(getdate() as date)
	and c.num_item like '1%' 
  GROUP BY 
   T_PRODUCT_HIERARCHY_3
   HAVING  
	SUM(AMT_GROSS_ORDER_VALUE_EUR) > 0
),
CTE_cpnl_rates as (


SELECT 
	NUM_ITEM,AVG(VL_REFUND_RATE) VL_REFUND_RATE
FROM [L1].[L1_FACT_A_NOV_CLAIM_RATES] c
INNER JOIN L1.L1_DIM_A_ITEM it
	on it.ID_ITEM = c.ID_ITEM
where 1=1 --ID_item = 34662
and D_VALID_TO > GETDATE()
GROUP BY NUM_ITEM
)



SELECT
	ItemNo = x.NUM_ITEM
	,L3 = x.T_PRODUCT_HIERARCHY_3
	,L4 = x.T_PRODUCT_HIERARCHY_4
	,ItemLauncDate = D_LAUNCH
	,RefundRateItem = ISNULL(item_rates.RefundRate,0)
	,RefundRateL3 = ISNULL(l3_rates.RefundRate,0)
	,RefundRateL4 = ISNULL(family_rates.RefundRate,0)
	,RefundRate = CASE 
						WHEN ISNULL(item_rates.RefundRate,0) > 0 THEN item_rates.RefundRate
						WHEN ISNULL(family_rates.RefundRate,0) > 0 THEN family_rates.RefundRate
						WHEN ISNULL(l3_rates.RefundRate,0) > 0 THEN l3_rates.RefundRate
						ELSE 0.12 END
	,RefundRateAct = cpnl.VL_REFUND_RATE
FROM cte_new_items x
LEFT JOIN  cte_rrr_item_rates item_rates 
	on item_rates.id_item = x.id_item 
LEFT JOIN cte_rrr_item_family_rates family_rates 
	ON family_rates.T_PRODUCT_HIERARCHY_4 = x.T_PRODUCT_HIERARCHY_4
LEFT JOIN cte_rrr_item_L3_rates l3_rates 
	on l3_rates.T_PRODUCT_HIERARCHY_3 = x.T_PRODUCT_HIERARCHY_3
LEFT JOIN CTE_cpnl_rates cpnl	
	on cpnl.NUM_ITEM = x.NUM_ITEM





	SELECT * 
	FROM PL.PL_V_REFUND_RATES_NEW_LAUNCH
	ORDER BY abs(RefundRate-RefundRateAct) desc