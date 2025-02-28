
--SELECT top 10 * from [order] where Orderid = 0400033573
--SELECT orderid,* from OrderItem where orderid in (3158489,3159404)
--SELECT * INTO [Order_bck20240815] FROM [Order]
--SELECT * INTO [OrderItem_bck20240815] FROM [OrderItem]
------------------------------------------
-- Deduplicate Orders with more than 1 rows with the same info
-----------------------------------------
DROP TABLE #tempOrders
CREATE TABLE #tempOrders (OrderID int, OrderNo nvarchar(50),CreatedOn datetime2,ModifiedOn datetime2,NumberOrderItems int default(0), orderrank int,ToDelete bit default(0) )

;with cte_orders as
(
	SELECT o.OrderId
	from Order_bck20240815 o
	--where o.Orderid = '0400033573'
	Group by OrderId
	having count(*)>1
),
cte_items as
(
	SELECT o.id orderid, count(distinct oi.id) NumberItemRows
	FROM Order_bck20240815 o
	Left JOIN OrderItem_bck20240815 oi on oi.OrderId = o.Id
	INNER JOIN cte_orders cte on cte.OrderId = o.OrderId 
	GROUP BY o.id
)

--SELECT * from cte_items

INSERT INTO #tempOrders(OrderID,OrderNo,CreatedOn,ModifiedOn,NumberOrderItems,orderrank)
SELECT id,o.orderid,CreatedOn,ModifiedOn,ISNULL(cte.NumberItemRows,0), rank() over(partition by o.orderid order by CreatedOn asc) 
FROM Order_bck20240815 o
INNER join cte_items cte on cte.OrderId = o.id

--where orderid in (select OrderId from cte_orders)

UPDATE t
	SET t.ToDelete = 1
FROM #tempOrders t
WHERE
	NumberOrderItems =0 --AND orderrank >1



--select distinct OrderNo  from #tempOrders where ToDelete = 0


------------------------------------------
-- Deduplicate OrdersItem with more than 1 rows with the same info
-----------------------------------------

DROP TABLE #tempOrdersItems
CREATE TABLE #tempOrdersItems (ID int,ArticleNumber nvarchar(50), OrderID int, OrderNo nvarchar(50),CreatedOn datetime2,ModifiedOn datetime2, orderrank int,ToDelete bit default(0) )

;with cte_orders as
(
	SELECT o.OrderId,ArticleNumber
	from OrderItem_bck20240815 o
	--where o.Orderid = '0400033573'
	Group by OrderId
	having count(*)>1
),



