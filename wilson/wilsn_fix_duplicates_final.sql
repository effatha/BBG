--SELECT * INTO Wilson.dbo.Order_bck20250305 FROM Wilson.dbo.[Order]
--SELECT * INTO Wilson.dbo.OrderItem_bck20250305 FROM Wilson.dbo.[OrderItem]
select COUNT(*) from Wilson.dbo.Order_bck20250305
select COUNT(*) from Wilson.dbo.[Order]

select COUNT(*) from Wilson.dbo.OrderItem_bck20250305
select COUNT(*) from Wilson.dbo.[OrderItem]


------------------------------------------
-- Wilson Duplicates Removal
-----------------------------------------
DECLARE @OrderID nvarchar(50) = ''

------------------------------------------
-- Create the necessary temp tables
-----------------------------------------
DROP TABLE IF EXISTS #tempOrders

CREATE TABLE #tempOrders 
	(
		OrderID int, 
		OrderNo nvarchar(50),
		CreatedOn datetime2,
		ModifiedOn datetime2,
		NumberOrderItems int default(0),
		orderrank int,
		ToDelete bit default(0),
		DeliveryAddressId int,
		InvoiceNumber nvarchar(50),
		DeliveryOrderId nvarchar(50),
		CoolingOffExpirationDate datetime2,
		InvoiceDate datetime2,
		BusinessPartnerNumber nvarchar(50),
		TrackingNumber nvarchar(50),
		Carrier nvarchar(50)

	)

DROP TABLE IF EXISTS #tempOrderItem
CREATE TABLE #tempOrderItem 
	(
		OrderItemID int, 
		OrderID int,
		OrderNo nvarchar(50),
		CreatedOn datetime2,
		ModifiedOn datetime2,
		ToDelete bit default(0),
		OrderItemRank int,
		ArticleNumber  nvarchar(50),
		OrderPosition  nvarchar(50),
		MEK money
	)

----------------------------------------------------------------------------------------------------------------------
-- Remove first duplicates from order table. Get all order id's that have multiple records for the same order no. 
-- Because there's no way to tell which one has all the info, we copy all the relevant info from the record that have not nulls in the relevant fierds
-- and copy those values to the other ones
---------------------------------------------------------------------------------------------------------------------
;with cte_orders as
(
	SELECT o.OrderId
	from Wilson.dbo.[Order] o
	--where (o.Orderid = @OrderID OR @OrderID = '')
	--where  cast(o.CreatedOn as date)>= '20250101'
	Group by OrderId
	having count(*)>1
),
cte_items as
(
	SELECT o.id orderid, count(distinct oi.id) NumberItemRows
	FROM Wilson.dbo.[Order] o
	Left JOIN Wilson.dbo.OrderItem oi on oi.OrderId = o.Id
	INNER JOIN cte_orders cte on cte.OrderId = o.OrderId 
	GROUP BY o.id
)
INSERT INTO #tempOrders(OrderID,OrderNo,CreatedOn,ModifiedOn,NumberOrderItems,orderrank,DeliveryAddressId,InvoiceNumber,DeliveryOrderId,CoolingOffExpirationDate,InvoiceDate,BusinessPartnerNumber,TrackingNumber,Carrier)
SELECT id,o.orderid,CreatedOn,ModifiedOn,ISNULL(cte.NumberItemRows,0), rank() over(partition by o.orderid order by CreatedOn asc, o.id asc), DeliveryAddressId,InvoiceNumber,DeliveryOrderId,CoolingOffExpirationDate,InvoiceDate,BusinessPartnerNumber,TrackingNumber,Carrier
FROM Wilson.dbo.[Order] o
INNER join cte_items cte on cte.OrderId = o.id

-- set delete to the record with no orderitem
UPDATE t
	SET t.ToDelete = 1
FROM #tempOrders t
WHERE
	NumberOrderItems =0 

--SELECT count(*) FROM #tempOrders where OrderNo = '0200857253'

--SELECT top 10 *  FROM Wilson.dbo.[Order]
--- unify all records of the same order with the same data points
;with cte_orders_update as (
	
	SELECT
		OrderNo,
		DeliveryAddressId = MAX(ISNULL(DeliveryAddressId,0)),
		DeliveryOrderId = MAX(ISNULL(DeliveryOrderId,0)),
		InvoiceNumber = MAX(ISNULL(InvoiceNumber,0)),
		InvoiceDate = MAX(ISNULL(InvoiceDate,'1999-01-01')),
		CoolingOffExpirationDate = MAX(ISNULL(CoolingOffExpirationDate,'1999-01-01')),
		ModifiedOn = MAX(ISNULL(ModifiedOn,'1999-01-01')),
		BusinessPartnerNumber  = MAX(ISNULL(BusinessPartnerNumber,'0')),
		TrackingNumber  = MAX(ISNULL(TrackingNumber,'0')),
		Carrier  = MAX(ISNULL(Carrier,''))
	FROM #tempOrders
	Group by OrderNo

)
UPDATE w
	SET 
		w.DeliveryAddressId = CASE WHEN tmp.DeliveryAddressId = 0 THEN NULL ELSE tmp.DeliveryAddressId END
		,w.DeliveryOrderId = tmp.DeliveryOrderId
		,w.InvoiceNumber = tmp.InvoiceNumber
		,w.InvoiceDate = tmp.InvoiceDate
		,w.CoolingOffExpirationDate = tmp.CoolingOffExpirationDate
		,w.ModifiedOn = tmp.ModifiedOn
		,w.BusinessPartnerNumber = tmp.BusinessPartnerNumber
		,w.TrackingNumber = tmp.TrackingNumber
		,w.Carrier = tmp.Carrier
FROM Wilson.dbo.[Order] w
INNER JOIN cte_orders_update tmp
	on tmp.OrderNo = w.OrderId


DELETE w
FROM Wilson.dbo.[Order] w
INNER JOIN #tempOrders tmp 
	on tmp.OrderID = w.id and tmp.ToDelete = 1


---DELETE FROM temp table the records already deleted
DELETE tmp
FROM #tempOrders tmp
where OrderNo in (select OrderNo from #tempOrders where ToDelete = 1)
----------------------------------------------------------------------------------------------------------------------
-- Update the orderid in order item table, from the main order id to keep
---------------------------------------------------------------------------------------------------------------------

;with cte_orders_update as (
	
	SELECT
		OrderID,OrderNo
	FROM #tempOrders where orderrank = 1

)
UPDATE oi
	SET  oi.OrderId = tmp.OrderID
FROM Wilson.dbo.OrderItem oi
INNER JOIN Wilson.dbo.[Order] o on o.Id = oi.OrderId
INNER JOIN cte_orders_update tmp
	on tmp.OrderNo = o.OrderId
where 
	tmp.OrderID <> oi.OrderId


----------------------------------------------------------------------------------------------------------------------
-- Truncate temp table and select again the duplicates
---------------------------------------------------------------------------------------------------------------------

TRUNCATE TABLE #tempOrders

;with cte_orders as
(
	SELECT o.OrderId
	from Wilson.dbo.[Order] o
	--where (o.Orderid = @OrderID OR @OrderID = '')
	Group by OrderId
	having count(*)>1
),
cte_items as
(
	SELECT o.id orderid, count(distinct oi.id) NumberItemRows
	FROM Wilson.dbo.[Order] o
	Left JOIN Wilson.dbo.OrderItem oi on oi.OrderId = o.Id
	INNER JOIN cte_orders cte on cte.OrderId = o.OrderId 
	GROUP BY o.id
)
INSERT INTO #tempOrders(OrderID,OrderNo,CreatedOn,ModifiedOn,NumberOrderItems,orderrank,DeliveryAddressId,InvoiceNumber,DeliveryOrderId,CoolingOffExpirationDate,InvoiceDate,BusinessPartnerNumber,TrackingNumber,Carrier)
SELECT id,o.orderid,CreatedOn,ModifiedOn,ISNULL(cte.NumberItemRows,0), rank() over(partition by o.orderid order by CreatedOn asc, o.id asc), DeliveryAddressId,InvoiceNumber,DeliveryOrderId,CoolingOffExpirationDate,InvoiceDate,BusinessPartnerNumber,TrackingNumber,Carrier
FROM Wilson.dbo.[Order] o
INNER join cte_items cte on cte.OrderId = o.id

-- set delete to the record with no orderitem
UPDATE t
	SET t.ToDelete = 1
FROM #tempOrders t
WHERE
	NumberOrderItems =0 


DELETE w
FROM Wilson.dbo.[Order] w
INNER JOIN #tempOrders tmp 
	on tmp.OrderID = w.id and tmp.ToDelete = 1

---DELETE FROM temp table the records already deleted
DELETE tmp
FROM #tempOrders tmp
where OrderNo in (select OrderNo from #tempOrders where ToDelete = 1)

--SELECT * FROM #tempOrders



----------------------------------------------------------------------------------------------------------------------
-- Remove duplicates from the order item table 
---------------------------------------------------------------------------------------------------------------------
;with cte_orders as
(
	SELECT o.OrderId as OrderNo, oi.OrderId,  oi.ArticleNumber, oi.OrderPosition
		FROM Wilson.dbo.OrderItem oi
		INNER join Wilson.dbo.[Order] o  on oi.OrderId = o.id
--	where (o.Orderid = @OrderID OR @OrderID = '')
	Group by oi.OrderId,oi.ArticleNumber,oi.OrderPosition,o.OrderId
	having count(*)>1
)

INSERT INTO #tempOrderItem(OrderItemID,OrderID,OrderNo,CreatedOn,ModifiedOn,ArticleNumber,OrderPosition,MEK,OrderItemRank)
SELECT oi.id,oi.orderid,o.OrderId,oi.CreatedOn,oi.ModifiedOn,oi.ArticleNumber,oi.OrderPosition,MEK,OrderItemRank = rank() over(partition by o.OrderID, oi.ArticleNumber, oi.OrderPosition order by isnull(oi.mek,0) desc,oi.id asc)
FROM Wilson.dbo.OrderItem oi
INNER join Wilson.dbo.[Order] o  on oi.OrderId = o.id
INNER JOIN cte_orders ord on ord.ArticleNumber = oi.ArticleNumber and ord.OrderPosition = oi.OrderPosition and oi.OrderId = ord.OrderId

DELETE oi
FROM 
[Wilson].[dbo].OrderItem oi
inner join #tempOrderItem tmp on tmp.OrderItemID  = oi.Id
and tmp.OrderItemRank > 1



----------------------------------------------------------------------------------------------------------------------
-- Ritesh request: Update orderitems with quantity = 0 to 1
---------------------------------------------------------------------------------------------------------------------

SELECT TOP 10 * from Wilson.dbo.orderitem where Quantity = 0

--UPDATE 
-- Wilson.dbo.orderitem
--SET Quantity = 1
-- where Quantity = 0



select * 
from Wilson.dbo.Order_bck20250305
where orderid not in (select distinct orderid  
from Wilson.dbo.[Order])