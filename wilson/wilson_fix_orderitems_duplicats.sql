    select oi.OrderId, ArticleNumber,OrderPosition,max(oi.CreatedOn),count(*)
	from [OrderItem] oi
	INNER JOIN [order] o on o.id = oi.orderid and o.isdeleted = 0
	where oi.IsDeleted = 0
	GROUP BY oi.OrderId, ArticleNumber,OrderPosition
	having count(*) >1
	order by 4 desc

	SELECT * INTO [order_bck20250911] FROM [order]
	SELECT * INTO [OrderItem_bck20250911] FROM [OrderItem]

  select * from [order] where OrderId = 407891490 invoicenumber = '4007035044'

  9409551

  select * from [OrderItem] where orderid =   3671102


with cte_dup  as 
(

    select oi.*, rk = rank() over(partition by oi.OrderId, ArticleNumber,OrderPosition order by oi.id desc)
	from [OrderItem] oi
	INNER JOIN [order] o on o.id = oi.orderid and o.isdeleted = 0
	where oi.IsDeleted = 0 --and oi.OrderId = 3673250
),
cte_dup_data_update as 
(
    select oi.OrderId, ArticleNumber,OrderPosition,max(oi.Quantity) Quantity,  
		UnitPriceNetLocalCurrency = max(ISNULL(oi.UnitPriceNetLocalCurrency,0)),
		TaxAmountLocalCurrency = max(ISNULL(oi.TaxAmountLocalCurrency,0)),
		UnitPriceGrossLocalCurrency = max(ISNULL(oi.UnitPriceGrossLocalCurrency,0)),
		MEK = max(ISNULL(oi.MEK,0)),
		EAN = max(ISNULL(oi.EAN,0))
	from [OrderItem] oi
	INNER JOIN [order] o on o.id = oi.orderid and o.isdeleted = 0
	where oi.IsDeleted = 0
	GROUP BY oi.OrderId, ArticleNumber,OrderPosition
	having count(*) >1
)
--UPDATE oi
--	SET 
--		oi.Quantity = up.Quantity,
--		oi.UnitPriceNetLocalCurrency = up.UnitPriceNetLocalCurrency,
--		oi.TaxAmountLocalCurrency = up.TaxAmountLocalCurrency,
--		oi.UnitPriceGrossLocalCurrency = up.UnitPriceGrossLocalCurrency,
--		oi.MEK = up.MEK,
--		oi.EAN = up.EAN
--FROM OrderItem oi
--INNER JOIN cte_dup ct on ct.Id = oi.Id and rk = 1
--INNER JOIN cte_dup_data_update up 
--	on
--		ct.OrderId = up.OrderId
--		AND
--		ct.ArticleNumber = up.ArticleNumber
--		AND
--		ct.OrderPosition = up.OrderPosition
--WHERE
--	YEAR(oi.CreatedOn) = 2024
--	and
--	month(oi.CreatedOn) >= 7 
--	and month(oi.CreatedOn) <= 12

UPDATE oi
	SET IsDeleted = 1
	FROM OrderItem oi
INNER JOIN cte_dup ct on ct.Id = oi.Id and rk > 1
	

