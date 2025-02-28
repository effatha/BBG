;with amazon_orders as(
SELECT 
	   [CD_AMAZON_ORDER],
       MIN([D_ORDER]) [MIN_ORDER_DATE],
       MAX([D_ORDER]) [MAX_ORDER_DATE],
	   SUM(AMT_ECOMMERCE_ITEM_TURNOVER_EUR)Turnover,
	   CD_ORDER_STATUS,
	   T_AMAZON_CHANNEL
 FROM [L1].[L1_FACT_A_AMAZON_ORDER_DAILY] amazon
 WHERE
		YEAR([D_ORDER])>=2024
		--AND CD_ORDER_STATUS not in ('cancelled','Pending')
		and T_AMAZON_CHANNEL NOT IN ('AMAZON_COM','AMAZON_CA')
 GROUP BY [CD_AMAZON_ORDER],CD_ORDER_STATUS,T_AMAZON_CHANNEL
),
sales_orders as (
	SELECT [CD_MARKET_ORDER_ID], MIN(D_CREATED) OrderDate, SUM(AMT_TURNOVER_EUR)Turnover
	FROM L1.L1_FACT_A_SALES_TRANSACTION_KPI 
	WHERE 
		[CD_MARKET_ORDER_ID] IS NOT NULL
		AND	
		CD_SOURCE_SYSTEM = 'SAP'
		AND 
		YEAR(D_CREATED)=2024
	GROUP BY [CD_MARKET_ORDER_ID]
)

, CTE_FINAL AS (
SELECT
	AmazonOrderDate = amz.[MIN_ORDER_DATE],
	AmazonTurnoverEUR = SUM(amz.Turnover),
	DWHTurnoverEUR = SUM(sales.Turnover),
	AmazonOrderStatus = CD_ORDER_STATUS,
	AmazonChannel =T_AMAZON_CHANNEL,
	DelayInDays = CASE WHEN sales.OrderDate is null THEN -1 ELSE DateDIFF(day,amz.[MIN_ORDER_DATE],sales.OrderDate) END,
	NumberOrders = Count(*)
FROM amazon_orders amz
LEFT JOIN sales_orders sales
	on amz.[CD_AMAZON_ORDER] = sales.[CD_MARKET_ORDER_ID]
WHERE 
	amz.[MIN_ORDER_DATE] >= '2024-01-01'
Group by amz.[MIN_ORDER_DATE],CASE WHEN sales.OrderDate is null THEN -1 ELSE DateDIFF(day,amz.[MIN_ORDER_DATE],sales.OrderDate) END,CD_ORDER_STATUS,T_AMAZON_CHANNEL
)
SELECT TOP 10  
	*,
	Total = SUM(NumberOrders) OVER (Partition by AmazonOrderDate),
	DelayPercentage = ROUND((NumberOrders*1.0 /SUM(NumberOrders*1.0) OVER (Partition by AmazonOrderDate)) * 100,2)
FROM CTE_FINAL
Order by AmazonOrderDate, DelayinDays

----	amazonDay,delayindays 




 --select top 10 BSTKD,* from L0.L0_S4HANA_2LIS_11_VAITM



 --select top 10 * FROM [L1].[L1_FACT_A_AMAZON_ORDER_DAILY] amazon
