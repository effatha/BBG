SELECT
	TransactionYear		= sales.TransactionYear,
	TransactionMonth	= sales.TransactionMonth,
--	ItemNo				= it.ItemNo,
--	ChannelGroup3		= ch.ChannelGroup3,
--	Country				= sales.DeliveryCountryGroup ,
	Revenue				= SUM(RevenueEst),
	NetOrderValue		= SUM(NetOrderValueEst),
	NetOrderQuantity	= SUM(NetOrderQuantityEst),
	PC1					= SUM(PC1),
	Marketing			= SUM(ISNULL(MarketingShops,0)+ISNULL(MarketingAmazon,0)++ISNULL(MarketingMarketplacesEst,0)),
	PC3					= SUM(PC3),
	PC3rate				= SUM(PC3)/SUM(RevenueEst)

FROM PL.PL_V_SALES_TRANSACTIONS sales
INNER JOIN PL.PL_V_ITEM  it
	ON
		it.ItemId = sales.ItemId
LEFT JOIN PL.PL_V_SALES_CHANNEL ch
	ON
		ch.ChannelId = sales.ChannelId
WHERE
	TransactionYear>= 2024
	AND
	ISNULL(IncidentFlag,'N') = 'N'
	AND
	PC3 <> 0 ---- doesn't show the records that dont have nov
GROUP BY 
		TransactionYear,
		TransactionMonth
		--it.ItemNo,
		--ch.ChannelGroup3,
		--sales.DeliveryCountryGroup 