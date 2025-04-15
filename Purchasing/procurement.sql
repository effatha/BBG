/*********************************************************
select top 10 *
FROM L1.L1_FACT_F_STOCK


**********************************************************/

---build the calendar table
WITH CTE_CALENDAR_ITEM AS (

  SELECT 
	[TargetDay] = cal.DATE,
	NUM_ITEM = it.NUM_ITEM
  FROM [L0].[L0_CALENDAR] cal
  CROSS JOIN L1.L1_DIM_A_ITEM it
  WHERE
	YEAR(cal.DATE) = 2025
	AND MONTH(cal.DATE) = 3
	AND it.CD_SOURCE_SYSTEM = 'SAP'
),
CTE_STOCK AS (
--TODO:  Exclude storage localion used for swiming stock (virtual sotrage locations)
	select 
		CD_ITEM,
		VL_TOTAL_QUANTITY = SUM(VL_TOTAL_QUANTITY)
	FROM L1.L1_FACT_F_STOCK
	WHERE 
		D_EFFECTIVE = CAST(GETDATE()-1 AS DATE)
		AND 
		CD_STOCK_TYPE IN ('PHYSICAL STOCK','InTransit','CONSIGNMENT STOCK')
		AND
		CD_ITEM_TYPE = 'A'
		AND
		CD_PLANT NOT IN ('5100') ---exclude gts
	GROUP BY CD_ITEM
),
CTE_FORECAST AS (

--- TODO: apply the performance factor
	SELECT 
		D_TARGET,
		NUM_ITEM,
		VL_FC_QTY = SUM(VL_ITEM_QUANTITY),
		VL_CUMULATIVE_QTY = SUM(SUM(VL_ITEM_QUANTITY)) OVER (
															PARTITION BY NUM_ITEM 
															ORDER BY D_TARGET ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
															) -- Cumulative sum of quantity by item
	FROM L1.L1_FACT_F_BOTTOM_LINE_FORECAST bs
	WHERE 1=1
		AND MONTH(bs.D_TARGET) = 3
		AND  bs.D_TARGET>=cast(GETDATE() AS DATE)
		--and num_item = '10007485'
	GROUP BY D_TARGET,NUM_ITEM


)
---start with the stock development
SELECT TOP 10 
	D_CALENDAR_DATE = base.[TargetDay],
	NUM_ITEM = base.NUM_ITEM,
	VL_STOCK_QTY = ISNULL(stock.VL_TOTAL_QUANTITY,0),
	VL_FC_QUANTITY = ISNULL(fc.VL_CUMULATIVE_QTY,0)
FROM  CTE_CALENDAR_ITEM base
LEFT JOIN CTE_STOCK stock
	on base.NUM_ITEM = stock.CD_ITEM
LEFT JOIN CTE_FORECAST fc
	on base.NUM_ITEM = fc.NUM_ITEM
		AND base.[TargetDay] = fc.D_TARGET



		select sum(AMT_) from [L1].L1_FACT_A_AMAZON_ITEM_ATTRIBUTION 
		where CD_ITEM like '6%'