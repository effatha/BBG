SELECT DISTINCT TOP (100)
  o.id
   ,o.CreatedOn as OrderCreateOn
   ,o.WayOfDistribution as ChannelID
   ,o.OrderID 
   ,O.InvoiceNumber 
   ,o.DeliveryOrderId
   ,oi.ArticleNumber
   ,o.TrackingNumber
   ,oi.ID as ArticleID
   ,oi.Quantity
FROM [Wilson].[dbo].[Order_BCK] as O
	left join [Wilson].[dbo].[OrderItem_BCK] as OI on OI.OrderId = O.ID
	WHERE o.orderID in ('0406632174')
order by o.id,oi.id DESC


SELECT *  FROM [Wilson].[dbo].[Order_BCK]-- WHERE orderID in ('0406632174')

SELECT * FROM [Wilson].[dbo].[OrderItem_BCK]-- WHERE orderid in (8639976,8644803,8644939,8644939,8644939)


UPDATE oi  
SET 
	ArticleDescription = 'Klarstein Kenbu 2L Red', Quantity = 1 ,Condition = 'A', EAN = '4060656519741', orderID = 8639976
FROM [Wilson].[dbo].[OrderItem_BCK] oi
WHERE Id IN(9611326)

DELETE FROM [Wilson].[dbo].[OrderItem_BCK] WHERE Id IN(9609473,9610255,9610359)

DELETE o
FROM [Wilson].[dbo].[Order_BCK] o
WHERE Id IN(8644803,8644939)