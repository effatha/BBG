/******************************************
** TODO: create a second setting for default time for transit time port-> WH
** Take in consideration that there might be an confirmed order after the OOS DATE
*******************************************/

ALTER VIEW TEST.PL_V_REPLENISHMENT_ORDERS_CALCULATED
AS

WITH CTE_OOS_DATE AS (
SELECT 
	NUM_ITEM,
	OOSDate = MIN(D_CALENDAR_DATE)
FROM TEST.L1_FACT_A_STOCK_DEVELOPMENT 
WHERE 1=1
	AND	VL_FORECAST_TOTAL_STOCK <= 0
--	AND	NUM_ITEM = 10039049
GROUP BY NUM_ITEM
),
CTE_CLUSTER_REPLISHMENT AS
(
	SELECT ITEMCLUSTER,STOCKOVERLAP,FCCOVERAGE
	FROM TEST.L0_MI_PURCH_STOCK_REPLENISHMENT
	WHERE
		ISNULL(PRODUCTHIERARCHY2,'') = ''

),
CTE_L2_REPLISHMENT AS
(
	SELECT PRODUCTHIERARCHY2,ITEMCLUSTER,STOCKOVERLAP,FCCOVERAGE
	FROM TEST.L0_MI_PURCH_STOCK_REPLENISHMENT
	WHERE
		ISNULL(PRODUCTHIERARCHY2,'') <> ''

),
CTE_ITEM_PRICE AS
(
	SELECT DISTINCT CAST(MATNR AS INT) ItemNo, NetPrice = ZZ_NETPR ,Currency = WAERS, rk = RANK() OVER(Partition by CAST(MATNR AS INT) ORDER BY SYDAT DESC)
	FROM L0.L0_S4HANA_2LIS_02_ITM itm
	WHERE
		ROCANCEL <> 'X'
		AND 
		LGORT = '1000'

),
CTE_REP_TOTAL AS
(

SELECT
	oos.NUM_ITEM,
	OOSDate,
	ETAWarehouse = DATEADD(day,ISNULL(l2.STOCKOVERLAP,cl.STOCKOVERLAP) * -1 ,OOSDate), -- calculate the overlap period
	MaxReplenishmentDate = DATEADD(day,ISNULL(l2.FCCOVERAGE,cl.FCCOVERAGE),OOSDate), --- how many days in the future should this cover
	ETAPort = DATEADD(day,(ISNULL(l2.STOCKOVERLAP,cl.STOCKOVERLAP)  + ISNULL(sup.TRANSITTIMEINDAYS, cast(etaport.Value as int)))* -1 ,OOSDate),
	ETD = DATEADD(day,(ISNULL(l2.STOCKOVERLAP,cl.STOCKOVERLAP)  + cast(etd.Value as int))* -1 ,OOSDate),
	NextOrderDate = DATEADD(day,(ISNULL(l2.STOCKOVERLAP,cl.STOCKOVERLAP)  + ISNULL(sup.TRANSITTIMEINDAYS, cast(etaport.Value as int)) +cast(ISNULL(itd.DT_PLANNED_DELIVERY_TIME,cast(plead.Value as int)) as int))* -1 ,OOSDate) ,
	ItemPriceFC = price.NetPrice,
	ItemPriceCurrency = price.Currency,
	ItemPriceEUR  = CASE WHEN price.NetPrice IS NULL THEN (mek.MEKHedging/1+(lcost.value)) ELSE price.NetPrice / fx.FX_rates END,
	RepleshmentQTY = CASE WHEN ISNULL(stfcd.VL_FC_QUANTITY,0) = 0 THEN 0 ELSE ISNULL(stfcd.VL_FC_QUANTITY,0) - ISNULL(stoosd.VL_FC_QUANTITY,0) END,
	LandingCostRate = lcost.value,
	---suplier setting
	DEPOSIT_TYPE,
	DEPOSIT_CURRENCY,
	FIXED_DEPOSIT_AMOUNT,
	DEPOSIT_PERC,
	PAYMENT_TERM,
	CurrencyRate = fx.FX_rates,
	LandingCostPaymentDays = cast(lcostDays.Value as int)
FROM CTE_OOS_DATE oos
INNER JOIN L1.L1_DIM_A_ITEM it
	on it.NUM_ITEM = oos.NUM_ITEM
LEFT JOIN CTE_L2_REPLISHMENT l2
	ON l2.PRODUCTHIERARCHY2 = it.T_PRODUCT_HIERARCHY_2
		AND l2.ITEMCLUSTER = ISNULL(it.CD_ITEM_CLUSTER,'N Cluster')
LEFT JOIN CTE_CLUSTER_REPLISHMENT cl
	ON l2.PRODUCTHIERARCHY2 IS NULL
		AND cl.ITEMCLUSTER = ISNULL(it.CD_ITEM_CLUSTER,'N Cluster')
LEFT JOIN L1.L1_DIM_A_ITEM_DETAILED itd 
	ON itd.NUM_Item =  '10'+right(it.NUM_ITEM,6) 
		AND itd.CD_PLANT = '1000' --- default plant to use 
		AND isnull(DT_PLANNED_DELIVERY_TIME,0)>0
LEFT JOIN L0.[L0_MI_PROCUREMENT_SETTINGS] etaport on etaport.setting_name = 'ETAPortDateNumberDays'
LEFT JOIN L0.[L0_MI_PROCUREMENT_SETTINGS] etd on etd.setting_name = 'ETDTransit'
LEFT JOIN L0.[L0_MI_PROCUREMENT_SETTINGS] plead on plead.setting_name = 'ProdLeadTime'
LEFT JOIN L0.[L0_MI_PROCUREMENT_SETTINGS] lcost on lcost.setting_name = 'LandingCosts'
LEFT JOIN L0.[L0_MI_PROCUREMENT_SETTINGS] lcostDays on lcostDays.setting_name = 'LandingCostsPaymentDays'
LEFT JOIN TEST.L0_MI_PURCH_SUPPLIER_SETTINGS sup on sup.Supplier_code = it.cd_item_group
LEFT JOIN CTE_ITEM_PRICE price 
	ON price.ItemNo = oos.NUM_ITEM and rk = 1
LEFT JOIN PL.PL_V_LAST_MEK mek on mek.ItemNo = oos.Num_item
LEFT JOIN TEST.L0_MI_PURCH_FX_RATES fx
	ON fx.CurrencyCode = price.Currency
LEFT JOIN TEST.L1_FACT_A_STOCK_DEVELOPMENT stoosd ---- Join to get the cumulative forecast at OOS date
	ON stoosd.NUM_ITEM = oos.NUM_ITEM
		AND stoosd.D_CALENDAR_DATE = OOSDate
LEFT JOIN TEST.L1_FACT_A_STOCK_DEVELOPMENT stfcd ---- Join to get the cumulative forecast at the maximunfc coverage date
	ON stfcd.NUM_ITEM = oos.NUM_ITEM
		AND stfcd.D_CALENDAR_DATE = DATEADD(day,ISNULL(l2.FCCOVERAGE,cl.FCCOVERAGE),OOSDate)
--ORDER BY OOSDATE DESC
)
SELECT
	TypeRepleshiment = 'Calculated',
	ItemNo = NUM_ITEM,
	OOSDate,
	ETAWarehouse,
	MaxReplenishmentDate,
	ETAPort, 
	ETD,
	NextOrderDate,
	ItemPriceFC ,
	ItemPriceCurrency,
	ItemPriceEUR  ,
	RepleshmentQTY ,
	LandingCostsEUR = (RepleshmentQTY * ItemPriceEUR) * LandingCostRate,
	DepositPaymentEUR = CASE 
						WHEN DEPOSIT_TYPE = 'No Deposit' THEN 0 
						WHEN DEPOSIT_TYPE = 'Percentage' THEN  RepleshmentQTY * ItemPriceEUR * DEPOSIT_PERC
						WHEN DEPOSIT_TYPE = 'Fixed amount' THEN  RepleshmentQTY * ItemPriceEUR * 0.10
						ELSE 0 END,
	BalancePaymentEUR = (RepleshmentQTY * ItemPriceEUR) - CASE 
						WHEN DEPOSIT_TYPE = 'No Deposit' THEN 0 
						WHEN DEPOSIT_TYPE = 'Percentage' THEN  RepleshmentQTY * ItemPriceEUR * DEPOSIT_PERC
						WHEN DEPOSIT_TYPE = 'Fixed amount' THEN  RepleshmentQTY * ItemPriceEUR * 0.10
						ELSE 0 END,
	LandindCostsPaymentDate	= DATEADD(day,LandingCostPaymentDays,ETAWarehouse),
	DepositDate				= NextOrderDate,
	BalancePaymentDate		= DATEADD(day,PAYMENT_TERM,ETD)
FROM CTE_REP_TOTAL t
WHERE
		RepleshmentQTY >0
--ORDER BY OOSDATE DESC




--SELECT * FROM TEST.PL_V_REPLENISHMENT_ORDERS_CALCULATED

