--SELECT * INTO Wilson.dbo.Order_bck20250827 FROM Wilson.dbo.[Order]
--SELECT * INTO Wilson.dbo.OrderItem_bck20250827 FROM Wilson.dbo.OrderItem
--SELECT * INTO Wilson.dbo.OrderItemSequence_bck20250827 FROM Wilson.dbo.OrderItemSequence
--SELECT * INTO Wilson.dbo.OrderSequence_bck20250827 FROM Wilson.dbo.OrderSequence

--DECLARE @cnt INT = 0;
--DECLARE @total INT = 0;
--DECLARE @PageSize INT = 10000;

--select count(*) from wilson.[dbo].[OrderItemSequence_bck20250827] with (nolock) 
--Where IsDeleted=0 and  (ISNULL(OrderItemSequence_bck20250827.OrderId,0)=0)

--print 'TotalCount:'+convert(nvarchar(10),@total)
--WHILE @cnt < @total
--BEGIN

--CREATE PROCEDURE usp_SyncUpdateOrderItems
--AS

/** Update orderItem OrderId field*/

--update Top(@PageSize) OrderItemSequence_bck20250827
--set OrderId=[Order].Id
--from Order_bck20250827 [order] Inner join
--OrderItemSequence_bck20250827 on OrderItemSequence_bck20250827.SapOrderId=[Order].Orde.,rId
--where (OrderItemSequence_bck20250827.OrderId is null or OrderItemSequence_bck20250827.OrderId=0)


/** TO DO: DELETE old records from OrderItemSequence that to not have a join with order and are there for more than 3 months*/








/****************Update orderItem ************/
update  os
		set os.OrderId=[O].Id
from [Wilson].[dbo].[OrderItemSequence_bck20250827] os
INNER join [Wilson].[dbo].[Order_bck20250827] o
 on os.SapOrderId=o.OrderId and o.IsDeleted = 0
Where 
	os.IsDeleted=0 
	and  
	(ISNULL(os.OrderId,0)=0)


/**************** Get Order items we need in insert/update ************/

select *,rk = RANK() OVER(partition by SapOrderId,ArticleNumber,OrderPosition Order by id desc) 
into #tempOrderItemSequenceOrderResponseRows
from [Wilson].[dbo].[OrderItemSequence_bck20250827] with (nolock)
where 
	ISNULL(OrderId,0)>0 
	and IsDeleted=0	
	and Quantity>0
/**************** Get Invoice items we need in insert/update ************/

select  *,rk = RANK() OVER(partition by SapOrderId,ArticleNumber,OrderPosition Order by id desc)  
into #tempOrderItemSequenceInvoiceRows
from [Wilson].[dbo].[OrderItemSequence_bck20250827] with (nolock)
where 
	ISNULL(OrderId,0)>0  
	and IsDeleted=0
	and UnitPriceGrossLocalCurrency>0

/**************** Insert New Order Item Records ************/

select tmp.* 
into #tempOrderItemSequenceToInsertFromOrder
from #tempOrderItemSequenceOrderResponseRows tmp
LEFT join [Wilson].[dbo].[OrderItem_bck20250827] OItem 
	on 
		oitem.orderId=tmp.OrderId 
		and OItem.ArticleNumber=tmp.ArticleNumber 
		and OItem.OrderPosition=tmp.OrderPosition  
		and OItem.IsDeleted= 0
WHERE
	rk = 1
	AND OItem.Id is null


insert into [Wilson].[dbo].[OrderItem_bck20250827] (
	ArticleNumber,
	ArticleDescription,
	Quantity,
	Condition,
	EAN,
	UnitPriceNetLocalCurrency,
	TaxAmountLocalCurrency,
	UnitPriceGrossLocalCurrency,
	OrderPosition,
	UePos,
	OrderId,
	CreatedOn,
	CreatedBy,
	IsDeleted)
select 
	ArticleNumber,
	ArticleDescription,
	Quantity,
	Condition,
	EAN,
	UnitPriceNetLocalCurrency,
	TaxAmountLocalCurrency,
	UnitPriceGrossLocalCurrency,
	OrderPosition,
	UePos,
	OrderId,
	GETUTCDATE() CreatedOn,
	'SAPSyncJob' CreatedBy,
	0 
from 
	#tempOrderItemSequenceToInsertFromOrder

/**************** Insert New Invoice Item Records ************/

select tmp.* 
into #tempOrderItemSequenceToInsertFromInvoice
from #tempOrderItemSequenceInvoiceRows tmp
LEFT join [Wilson].[dbo].[OrderItem_bck20250827] OItem 
	on 
		oitem.orderId=tmp.OrderId 
		and OItem.ArticleNumber=tmp.ArticleNumber 
		and OItem.OrderPosition=tmp.OrderPosition  
		and OItem.IsDeleted= 0
WHERE
	rk = 1
	AND OItem.Id is null

insert into [Wilson].[dbo].[OrderItem_bck20250827] (
	ArticleNumber,
	ArticleDescription,
	Quantity,
	Condition,
	EAN,
	UnitPriceNetLocalCurrency,
	TaxAmountLocalCurrency,
	UnitPriceGrossLocalCurrency,
	OrderPosition,
	UePos,
	OrderId,
	CreatedOn,
	CreatedBy,
	IsDeleted)
select 
	ArticleNumber,
	ArticleDescription,
	Quantity,
	Condition,
	EAN,
	UnitPriceNetLocalCurrency,
	TaxAmountLocalCurrency,
	UnitPriceGrossLocalCurrency,
	OrderPosition,
	UePos,
	OrderId,
	GETUTCDATE() CreatedOn,
	'SAPSyncJob' CreatedBy,
	0 
from 
	#tempOrderItemSequenceToInsertFromInvoice

/**************** update from invoice records ************/


update OItem
		set 
			OrderPosition=OItemSequence.OrderPosition,
			UnitPriceNetLocalCurrency=OItemSequence.UnitPriceNetLocalCurrency,
			TaxAmountLocalCurrency=OItemSequence.TaxAmountLocalCurrency,
			UnitPriceGrossLocalCurrency=OItemSequence.UnitPriceGrossLocalCurrency,
			MEK=OItemSequence.MEK,
			ModifiedOn=GETUTCDATE(),
			ModifiedBy='SAPSyncJob'
FROM    #tempOrderItemSequenceInvoiceRows OItemSequence 
INNER JOIN [Wilson].[dbo].[OrderItem_bck20250827] OItem 
		on oitem.orderId=OItemSequence.OrderId
			and OItem.ArticleNumber=OItemSequence.ArticleNumber
			and OItem.OrderPosition=OItemSequence.OrderPosition
where OItemSequence.UnitPriceGrossLocalCurrency>0 and OItemSequence.rk = 1

/**************** update from order response records ************/
update OItem
		set 
			ModifiedOn=GETUTCDATE(),
			ModifiedBy='SAPSyncJob',
			Quantity=OItemSequence.Quantity,
			ArticleDescription=OItemSequence.ArticleDescription,
			EAN=OItemSequence.EAN,
			UePos=OItemSequence.UePos
FROM    #tempOrderItemSequenceOrderResponseRows OItemSequence 
INNER JOIN [Wilson].[dbo].[OrderItem_bck20250827] OItem on oitem.orderId=OItemSequence.OrderId
			and OItem.ArticleNumber=OItemSequence.ArticleNumber
			and OItem.OrderPosition=OItemSequence.OrderPosition
where OItemSequence.Quantity>0 and OItemSequence.rk = 1

/**************** update processed records in order sequence as deleted ************/


update [Wilson].[dbo].[OrderItemSequence_bck20250827] 
		set IsDeleted=1,
			modifiedon = GETUTCDATE(),
			modifiedby='SAPSyncJob'
where id in (select id from #tempOrderItemSequenceInvoiceRows)
and isdeleted=0



update [Wilson].[dbo].[OrderItemSequence_bck20250827]  
	set 
		IsDeleted=1,
		modifiedon = GETUTCDATE(),
		modifiedby='SAPSyncJob'
where id in (select id from #tempOrderItemSequenceOrderResponseRows)
 and isdeleted=0
   

  drop table #tempOrderItemSequenceOrderResponseRows
  drop table #tempOrderItemSequenceInvoiceRows
  drop table #tempOrderItemSequenceToInsertFromOrder
  drop table #tempOrderItemSequenceToInsertFromInvoice






  select * from [order] where OrderId = 407891490 invoicenumber = '4007035044'

  9409551

  select * from [OrderItem] where orderid = 
  10202890

    select oi.OrderId, ArticleNumber,OrderPosition,max(oi.CreatedOn),count(*)
	from [OrderItem] oi
	INNER JOIN [order] o on o.id = oi.orderid and o.isdeleted = 0
	where oi.IsDeleted = 0
	GROUP BY oi.OrderId, ArticleNumber,OrderPosition
	having count(*) >1
	order by 4 desc