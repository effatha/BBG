/******************************
** Name: builds the stock development over the next 12 months
** Auth: [Helder Barbosa]
** Date: 12/08/2025
**************************
** Change History
**************************
** PR   Date		 Author			Description 
** --   --------	 -------		------------------------------------
** 1	12/08/2025	Hbarbosa	     Initial Script
*/
 

 --TEST.WR_TX_L0_S4HANA_LIKP_LIPS_L1_FACT_A_DELIVERY_NOTES

ALTER PROCEDURE TEST.WR_TX_L1_FACT_A_PURCHASING_L1_FACT_A_STOCK_DEVELOPMENT
AS
BEGIN

--delete current day snapshot if it exists

DELETE FROM TEST.L1_FACT_A_STOCK_DEVELOPMENT WHERE D_SNAPSHOT  = CAST(GETDATE() as date)

DECLARE @Itemno VARCHAR(50) = ''

;WITH CTE_CALENDAR_ITEM AS (

  SELECT 
	[TargetDay] = cal.DATE,
	NUM_ITEM = it.NUM_ITEM
  FROM [L0].[L0_CALENDAR] cal
  CROSS JOIN L1.L1_DIM_A_ITEM it
  WHERE
	cal.DATE between cast(getdate() as date) and cast(dateadd(month,12,getdate()) as date)
	AND it.CD_SOURCE_SYSTEM = 'SAP'
	and (it.NUM_ITEM = @Itemno OR  @Itemno ='')

),
CTE_STOCK AS (
--TODO:  Exclude storage localion used for swiming stock (virtual sotrage locations)
	--select 
	--	CD_ITEM,
	--	VL_TOTAL_QUANTITY = SUM(VL_TOTAL_QUANTITY)
	--FROM L1.L1_FACT_F_STOCK
	--WHERE 
	--	D_EFFECTIVE = CAST(GETDATE()-1 AS DATE)
	--	AND 
	--	CD_STOCK_TYPE IN ('PHYSICAL STOCK','InTransit','CONSIGNMENT STOCK')
	--	AND
	--	CD_ITEM_TYPE = 'A'
	--	AND
	--	CD_PLANT NOT IN ('5100') ---exclude gts
	--	AND (cast(CD_ITEM as bigint)  = @Itemno OR @Itemno ='')
	--	GROUP BY CD_ITEM
	select 
		CD_ITEM = itemno,
		VL_TOTAL_QUANTITY = SUM(TotalQuantity)
	FROM pl.PL_V_DETAILED_STOCK 
	WHERE 1=1
		AND 
		StockType IN ('PHYSICAL STOCK','InTransit','CONSIGNMENT STOCK')
	GROUP BY ItemNo

),
CTE_FORECAST AS (

--- TODO: apply the performance factor
--- TODO: use the consensus forecast
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
		AND  bs.D_TARGET between cast(getdate() as date) and cast(dateadd(month,1,getdate()) as date)
		AND (NUM_ITEM = @ItemNo OR  @Itemno ='')

	GROUP BY D_TARGET,NUM_ITEM


),

CTE_FORECAST_MONTH AS (

--- TODO: apply the performance factor
  SELECT  
		D_TARGET_DAY = cal.date,
		D_TARGET,
		NUM_ITEM,
		VL_FC_QTY = SUM(VL_ITEM_QUANTITY)/DAY(EOMONTH(bs.D_TARGET)),
  		VL_CUMULATIVE_QTY = SUM(SUM(VL_ITEM_QUANTITY)/DAY(EOMONTH(bs.D_TARGET))) OVER (
															PARTITION BY NUM_ITEM 
															ORDER BY cal.date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
															) 

  FROM [L0].[L0_CALENDAR] cal
  INNER JOIN L1.L1_FACT_F_BUSINESS_PLAN bs 
    on cal.date between bs.D_TARGET and EOMONTH(bs.D_TARGET)
  INNER JOIN L1.L1_DIM_A_ITEM it 
    on it.ID_ITEm = bs.ID_ITEM
  WHERE
  	cal.DATE between cast(dateadd(day,1,EOMONTH(getdate())) as date) and cast(dateadd(month,12,getdate()) as date)
    and (it.NUM_ITEM = @ItemNo OR @Itemno ='')
    and D_TARGET > getdate()
  GROUP BY cal.DATE,D_TARGET,NUM_ITEM

),
CTE_GLOBAL_Forecast as
(
	SELECT D_TARGET,
			NUM_ITEM,
  			VL_FC_QTY
	FROM CTE_FORECAST 
		UNION
	SELECT D_TARGET_DAY,
			NUM_ITEM,
  			VL_FC_QTY
	FROM CTE_FORECAST_MONTH m


),
CTE_calculated_forecast as (

	SELECT 
			D_TARGET,
			NUM_ITEM,
  			VL_CUMULATIVE_QTY = SUM(VL_FC_QTY) OVER (
															PARTITION BY NUM_ITEM 
															ORDER BY D_TARGET ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
															) 
	FROM CTE_GLOBAL_Forecast

)
,
CTE_INBOUND_ORDERS AS
(
	SELECT  ETAWarehouse,ItemNo, 
			OpenQty =  SUM(SUM(Open_Qty)) OVER (
											PARTITION BY ItemNo 
											ORDER BY ETAWarehouse
											ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
										)
	FROM TEST.PL_V_FUTURE_INBOUND
	WHERE
		BookingStatus = 'Booking is confirmed'
		AND
		(ItemNo = @ItemNo OR @Itemno ='')
	GROUP BY ETAWarehouse,ItemNo
),
CTE_STOCK_DEVELOPMENT AS (
---start with the stock development
SELECT 
	D_CALENDAR_DATE = base.[TargetDay],
	NUM_ITEM = base.NUM_ITEM,
	VL_FORECAST_TOTAL_STOCK = ISNULL(stock.VL_TOTAL_QUANTITY,0)- ISNULL(fc.VL_CUMULATIVE_QTY,0) + (0+ISNULL(SUM(Open_Qty) OVER (
											PARTITION BY base.NUM_ITEM 
											ORDER BY [TargetDay]
											ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
											),0)),
	VL_INTIAL_STOCK_QTY = ISNULL(stock.VL_TOTAL_QUANTITY,0),
	VL_FC_QUANTITY = ISNULL(fc.VL_CUMULATIVE_QTY,0), --+ ISNULL(fcm.VL_CUMULATIVE_QTY,0),
	VL_OPEN_QUANTITY = 0+ISNULL(SUM(Open_Qty) OVER (
											PARTITION BY base.NUM_ITEM 
											ORDER BY [TargetDay]
											ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
											),0)
FROM  CTE_CALENDAR_ITEM base
LEFT JOIN CTE_STOCK stock
	on base.NUM_ITEM = stock.CD_ITEM
LEFT JOIN CTE_calculated_forecast fc
	on base.NUM_ITEM = fc.NUM_ITEM
		AND base.[TargetDay] = fc.D_TARGET
LEFT JOIN TEST.PL_V_FUTURE_INBOUND inb
		on base.[TargetDay] = inb.ETAWarehouse
			AND base.NUM_ITEM = inb.ItemNo
				and BookingStatus = 'Booking is confirmed'
WHERe
	base.NUM_ITEM = @ItemNo OR @Itemno =''
--ORDER BY base.[TargetDay]
)

INSERT INTO TEST.L1_FACT_A_STOCK_DEVELOPMENT (

D_SNAPSHOT
,[D_CALENDAR_DATE] 		
,[NUM_ITEM] 
,[VL_FORECAST_TOTAL_STOCK]	
,[VL_INTIAL_STOCK_QTY] 		
,[VL_FC_QUANTITY]			
,[VL_OPEN_QUANTITY]		
,DT_DWH_CREATED
,DT_DWH_UPDATED
)

SELECT 

	D_SNAPSHOT						= CAST(GETDATE() as date)
	,[D_CALENDAR_DATE]				
	,[NUM_ITEM]						
	,[VL_FORECAST_TOTAL_STOCK]		
	,[VL_INTIAL_STOCK_QTY]			
	,[VL_FC_QUANTITY] 
	,[VL_OPEN_QUANTITY]
	--,
	,DT_DWH_CREATED					= getdate()
	,DT_DWH_UPDATED					= getdate()
FROM  CTE_STOCK_DEVELOPMENT AS A 

		
where 1=1







END
