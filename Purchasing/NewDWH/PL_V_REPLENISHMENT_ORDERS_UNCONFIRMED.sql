/******************************************
** For unconfirmed orders we need to make sure that we split the qty accordingly with the DIO (fc coverage). 
** (cannot excede original quantity)
*******************************************/

--CREATE VIEW TEST.PL_V_REPLENISHMENT_ORDERS_UNCONFIRMED
--AS

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

)

	SELECT  
		TypeRepleshiment				= 'Unconfirmed'
		,ItemNo							= inb.ItemNo
		,OOSDate						= oos.OOSDate
		,ETAWarehouse					= inb.ETAWarehouse
		,MaxReplenishmentDate			= NULL
		,ETAPort						= inb.ETAPort
		,ETD							= DATEADD(day,(ISNULL(l2.STOCKOVERLAP,cl.STOCKOVERLAP)  + cast(etd.Value as int))* -1 ,OOSDate)
		,NextOrderDate					= NULL
		,ItemPriceFC					= purch.AMT_NET_PRICE_FC / VL_ITEM_ORDER_QTY 
		,ItemPriceCurrency				= purch.CD_CURRENCY
		,ItemPriceEUR					= inb.OrderItemPrice
		,RepleshmentQTY					= inb.Open_Qty
		,LandingCostsEUR 				= (inb.Open_Qty * inb.OrderItemPrice) * lcost.value
		,DepositPaymentEUR 				= AMT_LINE_FIXED_DOWN_PAYMENT_FC * VL_EXCHANGE_RATE
		,BalancePaymentEUR				= (purch.AMT_NET_PRICE_FC - ISNULL(AMT_LINE_FIXED_DOWN_PAYMENT_FC,0))* VL_EXCHANGE_RATE
		,LandindCostsPaymentDate		= DATEADD(day,lcostDays.value,inb.ETAWarehouse)
		,DepositDate					= D_LINE_DOWN_PAYMENT
		,BalancePaymentDate				= DATEADD(day,PAYMENT_TERM,inb.calc_ETD)
	FROM TEST.PL_V_FUTURE_INBOUND inb
	INNER JOIN TEST.L1_FACT_A_PURCHASING_TRANSACTIONS purch
		ON
			inb.ProcessId = purch.CD_DOCUMENT_NO
			AND inb.ItemNo = CAST(purch.CD_ITEM as int) 
	INNER JOIN L1.L1_DIM_A_ITEM it
		on it.NUM_ITEM = inb.itemNo
	LEFT JOIN L0.[L0_MI_PROCUREMENT_SETTINGS] lcost on lcost.setting_name = 'LandingCosts'
	LEFT JOIN L0.[L0_MI_PROCUREMENT_SETTINGS] lcostDays on lcostDays.setting_name = 'LandingCostsPaymentDays'
	LEFT JOIN L0.[L0_MI_PROCUREMENT_SETTINGS] etd on etd.setting_name = 'ETDTransit'
	LEFT JOIN TEST.L0_MI_PURCH_SUPPLIER_SETTINGS sup on sup.Supplier_code = it.cd_item_group
	LEFT JOIN CTE_OOS_DATE oos on oos.NUM_ITEM = inb.ItemNo
	LEFT JOIN CTE_L2_REPLISHMENT l2
	ON l2.PRODUCTHIERARCHY2 = it.T_PRODUCT_HIERARCHY_2
		AND l2.ITEMCLUSTER = ISNULL(it.CD_ITEM_CLUSTER,'N Cluster')
	LEFT JOIN CTE_CLUSTER_REPLISHMENT cl
	ON l2.PRODUCTHIERARCHY2 IS NULL
		AND cl.ITEMCLUSTER = ISNULL(it.CD_ITEM_CLUSTER,'N Cluster')

	WHERE
		inb.BookingStatus <> 'Booking is confirmed'
		
select
	min_by()
FROM TEST.PL_V_FUTURE_INBOUND inb



--SELECT  top 10 *							
--	FROM TEST.PL_V_FUTURE_INBOUND inb
--	where itemno = '10035362'

--SELECT * 
--FROM TEST.L1_FACT_A_PURCHASING_TRANSACTIONS 
--where 1=1 and  CD_DOCUMENT_NO = '4501021609'
--and d_ETA_PORT > getdate() and AMT_LINE_FIXED_DOWN_PAYMENT_FC >0

--select top 10 * FROM  TEST.L0_MI_PURCH_SUPPLIER_SETTINGS sup where supplier_code = 'HTR2'
--select * from pl.pl_V_ITEM where itemno = '10035362'

--purchasinggroup = 003
--purchasing category z102
--payment discount dasys = 100
--cdpaymentterm = ETX3
--vendor = 0000010100
--/*



select top 10 * from L0.L0_S4HANA_0ORD_REASON_TEXT where bezei like 'Defect%'


select * from L0.L0_S4HANA_2LIS_11_VAITM WHERE AUGRU = 'R10' order by ERDAT desc


select * from PL.PL_V_SALES_TRANSACTIONS WHERE documentno = '1400930215'

select * from L1.L1_FACT_A_SALES_TRANSACTION WHERE CD_DOCUMENT_NO = '1400930215'
select * from L1.L1_FACT_A_SALES_TRANSACTION_KPI WHERE CD_DOCUMENT_NO = '1400930215'



SELECT *
FROM TEST.L1_FACT_A_STOCK_DEVELOPMENT 
WHERE 1=1
		AND	NUM_ITEM = 10033098
order by 2