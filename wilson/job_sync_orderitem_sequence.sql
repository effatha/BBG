

DECLARE @cnt INT = 0;
DECLARE @total INT = 0;
DECLARE @PageSize INT = 10000;

select @total=count(id)  from [dbo].[OrderItemSequence] with (nolock) Where IsDeleted=0

print 'TotalCount:'+convert(nvarchar(10),@total)
WHILE @cnt < @total
BEGIN

/** Update orderItem OrderId field*/

update Top(@PageSize) OrderItemSequence
set OrderId=[Order].Id
from [Order] Inner join
OrderItemSequence on OrderItemSequence.SapOrderId=[Order].OrderId
where (OrderItemSequence.OrderId is null or OrderItemSequence.OrderId=0)


/****************Update orderItem ************/

select top (@PageSize) * 
into #tempOrderItemSequenceOrderResponseRows
from [dbo].[OrderItemSequence] with (nolock)
where (OrderItemSequence.OrderId is not null and OrderItemSequence.OrderId!=0 and OrderItemSequence.IsDeleted=0
and OrderItemSequence.Quantity>0)

select top (@PageSize) * 
into #tempOrderItemSequenceInvoiceRows
from [dbo].[OrderItemSequence] with (nolock)
where (OrderItemSequence.OrderId is not null and OrderItemSequence.OrderId!=0 and OrderItemSequence.IsDeleted=0
and OrderItemSequence.UnitPriceGrossLocalCurrency>0)

/* remove already inserted rows from temp table and save into another temp table to be inserted*/
select * 
into #tempOrderItemSequenceToInsertFromOrder
from #tempOrderItemSequenceOrderResponseRows
where id not in 
(select OSequence.id from [dbo].[OrderItemSequence] OSequence
inner join [dbo].[OrderItem] OItem on oitem.orderId=OSequence.OrderId
and OItem.ArticleNumber=OSequence.ArticleNumber and OItem.OrderPosition=OSequence.OrderPosition)

/*insert*/
insert into [dbo].[OrderItem]
(ArticleNumber,ArticleDescription,Quantity,Condition,EAN,UnitPriceNetLocalCurrency
,TaxAmountLocalCurrency,UnitPriceGrossLocalCurrency,OrderPosition,UePos,OrderId,CreatedOn,CreatedBy,IsDeleted)
select ArticleNumber,ArticleDescription,Quantity,Condition,EAN,UnitPriceNetLocalCurrency
,TaxAmountLocalCurrency,UnitPriceGrossLocalCurrency,OrderPosition,UePos,OrderId,GETUTCDATE() CreatedOn,'SAPSyncJob' CreatedBy,0 from 
#tempOrderItemSequenceToInsertFromOrder

select * 
into #tempOrderItemSequenceToInsertFromInvoice
from #tempOrderItemSequenceInvoiceRows
where id not in 
(select OSequence.id from [dbo].[OrderItemSequence] OSequence
inner join [dbo].[OrderItem] OItem on oitem.orderId=OSequence.OrderId
and OItem.ArticleNumber=OSequence.ArticleNumber and OItem.OrderPosition=OSequence.OrderPosition)


insert into [dbo].[OrderItem]
(ArticleNumber,ArticleDescription,Quantity,Condition,EAN,UnitPriceNetLocalCurrency
,TaxAmountLocalCurrency,UnitPriceGrossLocalCurrency,OrderPosition,UePos,OrderId,CreatedOn,CreatedBy,IsDeleted)
select ArticleNumber,ArticleDescription,Quantity,Condition,EAN,UnitPriceNetLocalCurrency
,TaxAmountLocalCurrency,UnitPriceGrossLocalCurrency,OrderPosition,UePos,OrderId,GETUTCDATE() CreatedOn,'SAPSyncJob' CreatedBy,0 from 
#tempOrderItemSequenceToInsertFromInvoice

/* update from invoice records*/
update [dbo].[OrderItem] 
set OrderPosition=OItemSequence.OrderPosition,
UnitPriceNetLocalCurrency=OItemSequence.UnitPriceNetLocalCurrency,
TaxAmountLocalCurrency=OItemSequence.TaxAmountLocalCurrency,
UnitPriceGrossLocalCurrency=OItemSequence.UnitPriceGrossLocalCurrency,
MEK=OItemSequence.MEK,
ModifiedOn=GETUTCDATE(),
ModifiedBy='SAPSyncJob'
FROM    #tempOrderItemSequenceInvoiceRows OItemSequence INNER JOIN
            [dbo].[OrderItem] OItem on oitem.orderId=OItemSequence.OrderId
            and OItem.ArticleNumber=OItemSequence.ArticleNumber
            and OItem.OrderPosition=OItemSequence.OrderPosition
where OItemSequence.UnitPriceGrossLocalCurrency>0

/* update from order response records*/
update [dbo].[OrderItem] 
set 
ModifiedOn=GETUTCDATE(),
ModifiedBy='SAPSyncJob',
Quantity=OItemSequence.Quantity,
ArticleDescription=OItemSequence.ArticleDescription,
EAN=OItemSequence.EAN,
UePos=OItemSequence.UePos
FROM    #tempOrderItemSequenceOrderResponseRows OItemSequence INNER JOIN
            [dbo].[OrderItem] OItem on oitem.orderId=OItemSequence.OrderId
            and OItem.ArticleNumber=OItemSequence.ArticleNumber
            and OItem.OrderPosition=OItemSequence.OrderPosition

where OItemSequence.Quantity>0



update [dbo].[OrderItemSequence]
set IsDeleted=1,modifiedon = GETUTCDATE(),modifiedby='SAPSyncJob'
where id in (select id from #tempOrderItemSequenceInvoiceRows)
and isdeleted=0
update [dbo].[OrderItemSequence]
set IsDeleted=1,modifiedon = GETUTCDATE(),modifiedby='SAPSyncJob'
where id in (select id from #tempOrderItemSequenceOrderResponseRows)
 and isdeleted=0
   
  SET @cnt = @cnt + @PageSize;
  print 'Processed rows:'+convert(nvarchar(10),@cnt)
  
  drop table #tempOrderItemSequenceOrderResponseRows
  drop table #tempOrderItemSequenceInvoiceRows
  drop table #tempOrderItemSequenceToInsertFromOrder
  drop table #tempOrderItemSequenceToInsertFromInvoice
END;