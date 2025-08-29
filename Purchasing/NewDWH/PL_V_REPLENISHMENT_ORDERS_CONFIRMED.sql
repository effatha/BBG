/******************************************
** The confirmed bookings are line based, so i suspect that the discounts will only appear when the line booking is confirmed
*******************************************/

CREATE VIEW TEST.PL_V_REPLENISHMENT_ORDERS_CONFIRMED
AS

	SELECT  
		TypeRepleshiment				= 'Confirmed'
		,ItemNo							= inb.ItemNo
		,OOSDate						= NULL
		,ETAWarehouse					= inb.ETAWarehouse
		,MaxReplenishmentDate			= NULL
		,ETAPort						= inb.ETAPort
		,ETD							= inb.calc_ETD
		,OrderDate						= purch.D_CREATED
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
	LEFT JOIN TEST.L0_MI_PURCH_SUPPLIER_SETTINGS sup on sup.Supplier_code = it.cd_item_group

	WHERE
		inb.BookingStatus = 'Booking is confirmed'
		and sup.Supplier_Code = 'HTR2'




SELECT  top 10 *							
	FROM TEST.PL_V_FUTURE_INBOUND inb
	where itemno = '10033098'

SELECT * 
FROM TEST.L1_FACT_A_PURCHASING_TRANSACTIONS 
where 1=1 and  CD_DOCUMENT_NO = '4501022068'
--and d_ETA_PORT > getdate() and AMT_LINE_FIXED_DOWN_PAYMENT_FC >0

--select top 10 * FROM  TEST.L0_MI_PURCH_SUPPLIER_SETTINGS sup where supplier_code = 'HTR2'
--select * from pl.pl_V_ITEM where itemno = '10035362'

--purchasinggroup = 003
--purchasing category z102
--payment discount dasys = 100
--cdpaymentterm = ETX3
--vendor = 0000010100
--/*
/*
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
	*/


	--select * from L1.[L1_FACT_A_COUNTRY_VAT] where cd_country = 'SK'


	--UPDATE v SET v.D_VALID_TO = '9999-12-31' from L1.[L1_FACT_A_COUNTRY_VAT] v WHERE ID_COUNTRY_VAT = 249108103199
	----UPDATE v SET v.D_VALID_TO = '2018-12-31' from L1.[L1_FACT_A_COUNTRY_VAT] v WHERE ID_COUNTRY_VAT = 249108103199
	----UPDATE v SET v.D_VALID_TO = '9999-12-31' from L1.[L1_FACT_A_COUNTRY_VAT] v WHERE ID_COUNTRY_VAT = 30
	--UPDATE v SET v.D_VALID_TO = '2023-03-02' from L1.[L1_FACT_A_COUNTRY_VAT] v WHERE ID_COUNTRY_VAT = 30
	--WR.WR_TX_L0_MI_CHANNEL_PRICE_LISTS_L1_FACT_F_SALES_PRICE