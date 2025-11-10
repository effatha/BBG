;with cte_uk_stock as 
(
SELECT 	
	StockDate,
	StorageLocationName,
	ItemNo,
	AvailableStock = SUM(QuantityUnrestricted)
FROM PL.PL_V_DETAILED_STOCK_HISTORY
where
	StorageLocation = '1300'
GROUP BY 
	StockDate,
	StorageLocationName,
	ItemNo
)
  SELECT  
	ProcessID,
	ProcessidDate,
	it.ItemNo, 
	NetorderValueEst,
	Quantity,
	DeliveryCountry,
	StorageLocation,
	Channel,
	AvailableStockDayBefore= AvailableStock,
	QuantitySoldinSameDay = SUM(Quantity) over(partition by it.ItemNo,ProcessidDate)
  FROM PL.PL_V_SALES_TRANSACTIONS pl
  INNER JOIN PL.PL_V_ITEM it on it.ItemId = pl.ItemId
  INNER JOIN PL.PL_V_Sales_Channel ch on ch.ChannelId = pl.ChannelId
  INNER JOIN cte_uk_stock st 
	on st.ItemNo = it.ItemNo
	AND
	st.StockDate = DATEADD(DAY,-1,PRocessIDDate)
  WHERE 1=1
  and PRocessIDDate >= '2025-08-01'
  and DeliveryCountry = 'GB'
 and NetOrderQuantityEst > 0
 and storagelocation <> 'Lager UK'
  order by ProcessidDate desc 
