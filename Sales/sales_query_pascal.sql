with cte_sage_sales as 
(

SELECT TransactionYear = YEAR(D_CREATED),TransactionMonth = MONTH(D_CREATED)
,ItemNo, SUM([VL_ITEM_QUANTITY]) [VL_ITEM_QUANTITY], SUM(ISNULL(AMT_GROSS_PRICE_EUR,0)- ABS(ISNULL(AMT_TAX_PRICE_EUR,0)) - ABS(ISNULL(AMT_NET_DISCOUNT_EUR,0)) + ISNULL(AMT_NET_SHIPPING_REVENUE_EUR,0) )GOV
FROM WR.WR_L1_FACT_A_SALES_TRANSACTION sales
INNER JOIN PL.PL_V_ITEM  it
	ON
		it.ItemId = sales.ID_ITEM
where 
	[CD_TYPE] in ('VVA','VSD','VSD')
Group by ItemNo,YEAR(D_CREATED),MONTH(D_CREATED)
),
cte_sales as
(
SELECT
	TransactionYear		= sales.TransactionYear,
	TransactionMonth	= sales.TransactionMonth,
--	sales.Source				,
	ItemNo				= it.ItemNo,
--	ChannelGroup3		= ch.ChannelGroup3,
--	Country				= sales.DeliveryCountryGroup ,
	--Revenue				= SUM(RevenueEst),
	OrderQuantity		= SUM(OrderQuantity),
	GrossOrderValue	= SUM(GrossOrderValue)
	--PC1					= SUM(PC1),
	--Marketing			= SUM(ISNULL(MarketingShops,0)+ISNULL(MarketingAmazon,0)++ISNULL(MarketingMarketplacesEst,0)),
	--PC3					= SUM(PC3),
	--PC3rate				= SUM(PC3)/SUM(RevenueEst)

FROM PL.PL_V_SALES_TRANSACTIONS sales
INNER JOIN PL.PL_V_ITEM  it
	ON
		it.ItemId = sales.ItemId
LEFT JOIN PL.PL_V_SALES_CHANNEL ch
	ON
		ch.ChannelId = sales.ChannelId
WHERE
	--AND
	ISNULL(IncidentFlag,'N') = 'N'
	--AND
	--PC3 <> 0 ---- doesn't show the records that dont have nov
	and sales.source in ('SGE','SAP')
GROUP BY 
		TransactionYear,
		TransactionMonth,
--		sales.Source,
		it.ItemNo
		--ch.ChannelGroup3,
		--sales.DeliveryCountryGroup 
)
select 
	TransactionYear =ISNULL(s.TransactionYear,sg.TransactionYear),
	TransactionMonth =ISNULL(s.TransactionMonth,sg.TransactionMonth),
	ItemNo =ISNULL(s.ItemNo,sg.ItemNo),
	Quantity =SUM( ISNULL(s.OrderQuantity,0) + ISNULL(sg.[VL_ITEM_QUANTITY],0)),
	OrderValue =SUM( ISNULL(s.GrossOrderValue,0) + ISNULL(sg.GOV,0))
FROm cte_sales s
FULL JOIN cte_sage_sales sg
	on sg.ItemNo = s.itemno
	and s.TransactionYear = sg.TransactionYear
	and s.TransactionMonth = sg.TransactionMonth

GROUP BY ISNULL(s.TransactionYear,sg.TransactionYear),ISNULL(s.TransactionMonth,sg.TransactionMonth),ISNULL(s.ItemNo,sg.ItemNo)
	

	

--SELECT ItemNo, SUM([VL_ITEM_QUANTITY]) [VL_ITEM_QUANTITY], SUM(ISNULL(AMT_GROSS_PRICE_EUR,0)- ABS(ISNULL(AMT_TAX_PRICE_EUR,0)) - ABS(ISNULL(AMT_NET_DISCOUNT_EUR,0)) + ISNULL(AMT_NET_SHIPPING_REVENUE_EUR,0) )
--FROM WR.WR_L1_FACT_A_SALES_TRANSACTION sales
--INNER JOIN PL.PL_V_ITEM  it
--	ON
--		it.ItemId = sales.ID_ITEM
--where 
--	[CD_TYPE] in ('VVA','VSD','VSD')
--Group by ItemNo

--	select * from [L1].[L1_DIM_A_SALES_TRANSACTION_TYPE] where VL_AMT_GROSS_ORDER_VALUE_PARAM = 1



--SELECT TransactionYear = YEAR(D_CREATED), SUM([VL_ITEM_QUANTITY]) [VL_ITEM_QUANTITY], SUM(ISNULL(AMT_GROSS_PRICE_EUR,0)- ABS(ISNULL(AMT_TAX_PRICE_EUR,0)) - ABS(ISNULL(AMT_NET_DISCOUNT_EUR,0)) + ISNULL(AMT_NET_SHIPPING_REVENUE_EUR,0) )GOV
--FROM WR.WR_L1_FACT_A_SALES_TRANSACTION sales
--inner JOIN PL.PL_V_ITEM  it
--	ON
--		it.ItemId = sales.ID_ITEM
--where 
--	[CD_TYPE] in ('VVA','VSD','VSD')
--Group by YEAR(D_CREATED)
