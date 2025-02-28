SELECT 
	Source,
	--ItemID,
	--OrderCountry,
	--InvoiceCountry,
	--DeliveryCountry,
	--ChannelId,
	--ProcessID,
	SUM(CASE WHEN TransactionType in ('Order','OrderInvoice') AND ReasonForRejections is null THEN GrossOrderValue ELSE 0 END) GrossOrderValue,
	SUM(CASE WHEN  TransactionType in ('Refund','RefundCancellation') and (TransactionTypeCode like'%FKART%' or TransactionTypeCode like'%SAGE%') 
			THEN (isnull(GrossPrice,0)- isnull(TaxPrice,0) - isnull(Discount,0) + isnull(NetShippingRevenue,0)) ELSE 0 END) RefundValue

FROM
[PL].[PL_V_SALES_TRANSACTIONS] pl
JOIN  PL.PL_V_SALES_TRANSACTION_TYPE typ on typ.TransactionTypeID= pl.TransactionTypeID
where 
	Month(transactiondate) = 5
	AND YEAR(transactiondate) = 2023
GROUP BY source









select top 100 * from  [PL].PL_V_SALES_TRANSACTION_TYPE pl where TransactionType in ('Refund','RefundCancellation','RefundRequest') and (TransactionTypeCode like'%FKART%' or TransactionTypeCode like'%SAGE%')
select top 10 * from [PL].[PL_V_SALES_TRANSACTIONS] pl where TransactionTypeid = 1986
and 	Month(transactiondate) = 5
	AND YEAR(transactiondate) = 2023



--	------REFUNDS unrelated


--SELECT 
--	Source,
--	ItemID,
--	OrderCountry,
--	InvoiceCountry,
--	DeliveryCountry,
--	ChannelId,
--	ProcessID,
--	Sum(GrossPrice) Refunds,

--FROM
--[PL].[PL_V_SALES_TRANSACTIONS]
--where 
--	Month(transactiondate) = 5
--	YEAR(transactiondate) = 2023
--	AND ReasonforRejection <> '' and not in ('Wrongly created') 


--	------REFUNDS related


--SELECT 
--	Source,
--	ItemID,
--	OrderCountry,
--	InvoiceCountry,
--	DeliveryCountry,
--	ChannelId,
--	ProcessID,
--	Sum(GrossPrice) Refunds
--FROM
--[PL].[PL_V_SALES_TRANSACTIONS]
--where 
--	Month(ProcessIDDate) = 5
--	YEAR(ProcessIDDate) = 2023
--	AND ReasonforRejection <> '' and not in ('Wrongly created') 


29.534.758