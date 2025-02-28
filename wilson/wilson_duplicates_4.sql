
DECLARE @cnt INT = 0;
DECLARE @total INT = 0;
DECLARE @PageSize INT = 10000;

/************** Insert new orders *****/


select @total=count(id) from [dbo].[OrderSequence] with (nolock)
where InvoiceNumber is null and DeliveryOrderId is null and OrderId is NOT null

WHILE @cnt < @total
BEGIN

select top (@PageSize) * 
into #TempOrderSequence
from  OrderSequence with (nolock)
where InvoiceNumber is null and DeliveryOrderId is null and OrderId is NOT null

;WITH CTE AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY OrderId ORDER BY (SELECT NULL)) AS RowNum
    FROM #TempOrderSequence
)
insert into [Order]
(IsDeleted,CreatedOn,CreatedBy,OrderId,InvoiceAddressId,ExpiryDays,CoolingOffExpirationDate,OrderDate,
ClientId,CompanyId,Currency,CustomerId,ERPId,GrossAmount,MarketplaceOrderId,NormalizedMarketplaceOrderId,
PaymentMethod,ProcessId,ReferenceDocumentId,TaxAmount,WayOfDistribution,TotalAmountGrossForeignCurrency,TotalAmountGrossLocalCurrency,TotalAmountNetForeignCurrency,TotalAmountNetLocalCurrency)

select 
CTE.IsDeleted,CTE.CreatedOn,CTE.CreatedBy,CTE.OrderId,CTE.InvoiceAddressId,CTE.ExpiryDays,CTE.CoolingOffExpirationDate,CTE.OrderDate,
CTE.ClientId,CTE.CompanyId,CTE.Currency,CTE.CustomerId,CTE.ERPId,CTE.GrossAmount,CTE.MarketplaceOrderId,CTE.NormalizedMarketplaceOrderId,
CTE.PaymentMethod,CTE.ProcessId,CTE.ReferenceDocumentId,CTE.TaxAmount,
CTE.WayOfDistribution,CTE.TotalAmountGrossForeignCurrency,CTE.TotalAmountGrossLocalCurrency,CTE.TotalAmountNetForeignCurrency,CTE.TotalAmountNetLocalCurrency
from CTE
LEFT JOIN [Order] WITH (NOLOCK)
ON CTE.ORDERID = [Order].ORDERID
WHERE RowNum = 1
AND [Order].ORDERID IS NULL;

/* delete processed ids*/
delete from OrderSequence
where id in (select id from #TempOrderSequence)

drop table #TempOrderSequence

  SET @cnt = @cnt + @PageSize;
  print 'Processed rows:'+convert(nvarchar(10),@cnt)  
END