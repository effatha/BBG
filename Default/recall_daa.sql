
with sap_returns as (

SELECT distinct [CD_SALES_PROCESS_ID]
      ,[NUM_ITEM]
  FROM [L1].[L1_FACT_A_CLAIM_RATES]
  where isnull([VL_RETURN_QUANTITY],0) <> 0

)

select 
	sales.Source,
	TransactionDate,
	ProcessID,
	DocumentNo,
	--DocumentId,
	ItemNo,
	MarketplaceOrderId,
	CustomerName = b.A0Name1,
	CustomerId,
	SalesOffice,
	Channel,
	ChannelGroup1,
	ChannelGroup2,
	ChannelCountry,
	InvoiceCountry,
	DeliveryCountry,
	InvoiceCity,
	InvoiceZipCode,
	Quantity,
	HasReturns = CASE WHEN sap_ret.NUM_ITEM is null THEN 'NO' ELSE 'YES' END 
from [PL].[PL_V_SALES_TRANSACTIONS] sales
INNER JOIN PL.PL_V_SALES_CHANNEL ch 
	on ch.ChannelId = sales.ChannelId
INNER JOIN PL.[PL_V_SALES_TRANSACTION_TYPE] ttypes 
	on ttypes.TransactionTypeId = sales.TransactionTypeId
INNER JOIN PL.[PL_V_ITEM] item 
	on item.ItemId = sales.ItemId
LEFT JOIN  L0.L0_SAGE_KHKVKBELEGE b 
	on cast(b.VorId as nvarchar(50)) = sales.ProcessID
	and cast(b.BelegNummer as nvarchar(50))= sales.DocumentNo
	and b.BelegDatum = sales.TransactionDate
LEFT JOIN sap_returns sap_ret on sap_ret.[CD_SALES_PROCESS_ID] = ProcessID and ItemNo=NUM_ITEM
WHERE 1=1
	--ch.ChannelCountry = 'DE'
	and
	ttypes.TransactionType in ('Order','OrderInvoice')
	and
	item.ItemNo in (10028193,10028194,10029390,10029391)
	and
	ISNULL(ReasonForRejections,'') = ''
	and
	ISNULL(IncidentFlag,'N') = 'N'
	AND
	 channelgroup1 not in ('Mandanten','Intercompany','B2B')
	 AND 
	 YEAR(TransactionDate) in (2020,2021,2022,2023,2024,2025)


	 select year(transactiondate),sum(netordervalueest)  from [PL].[PL_V_SALES_TRANSACTIONS] sales where source = 'sge' group by year(transactiondate)

--	select 
--	distinct
--	SalesOffice
--from [PL].[PL_V_SALES_TRANSACTIONS] sales
--LEFT JOIN PL.PL_V_SALES_CHANNEL ch 
--	on ch.ChannelId = sales.ChannelId
--INNER JOIN PL.[PL_V_SALES_TRANSACTION_TYPE] ttypes 
--	on ttypes.TransactionTypeId = sales.TransactionTypeId
--INNER JOIN PL.[PL_V_ITEM] item 
--	on item.ItemId = sales.ItemId
--WHERE
--	ch.ChannelCountry = 'DE' --OR DeliveryCountry = 'DE')
--	and
--	ttypes.TransactionType in ('Order','OrderInvoice')
--	and
--	item.ItemNo in ('10033132','10033133','10034972','10035464','10035469','10037804')
--	and
--	ISNULL(ReasonForRejections,'') = ''
--	and
--	ISNULL(IncidentFlag,'N') = 'N'
--	AND
--	 channelgroup1 not in ('Mandanten','Intercompany')
--	 AND 
--	 YEAR(TransactionDate) in (2021,2022,2023)


select * from PL.PL_V_ITEM where itemno in (10028193,10028194,10029390,10029391)