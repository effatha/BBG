--select count(*) FROM [CT dwh 03 Intelligence].[dbo].[tDeliveryNotesLogisticsTemp] delivery with(nolock)
--select count(*) FROM  [CT dwh 03 Intelligence].[purch].tFactInboundDelivery  with(nolock)




with cte_idv as (
--SELECT '123' as DeliveryNumber
SELECT distinct  DeliveryNumber

FROM [CT dwh 03 Intelligence].[dbo].[tDeliveryNotesLogisticsTemp] delivery with(nolock)
Left join  [CT dwh 03 Intelligence].[purch].[vFactVertical]   idv with(nolock)
	on idv.DocumentNo = delivery.DeliveryNumber
where 
	delivery.productionorderno <> '' and delivery.DeliveryDistributionStatus <> 'C'
	and idv.DocumentNo is not null
	and idv.transactiontypedetail = 'Inbound Delivery Movement'

)
select *
,rank() over (partition by ful.[ItemNo] order by ful.ETAWarehouse) as rank

 

from(
SELECT
  'purchasetransaction' as [source]
  ,ProcessID
  ,CASE WHEN OrderDocumentType='UB' THEN -1 ELSE BookingConfirmed END BookingConfirmed
  ,CASE WHEN LEFT(ItemNo,2)='11' THEN '10' ELSE LEFT(ItemNo,2) END + RIGHT(ItemNo,6) [ItemNo]

  ,cast(CASE
    WHEN ETAWarehouse<=CAST(GETDATE()-1 as date)
THEN DATEADD(dd,11,CAST(GETDATE()-1 as date))
ELSE ETAWarehouse
END as date) ETAWarehouse

 


   ,SUM(ISNULL(OrderQuantity,0)) - SUM(ISNULL(StockReceiptQuantity,0)) [Open QTY]

 



  FROM [CT dwh 03 Intelligence].[dbo].[vFactPurchasingOrdersTransactions] with(nolock)

 

  WHERE CompanyId=1000
  AND ItemNo IS NOT NULL
  AND ItemNo <> ''
  AND OrderDocumentNo IS NOT NULL
  AND ISNULL(ItemProcessFulfilled,0)=0
  AND ISNULL(ProcessFulfilled,0)=0
  AND OrderDocumentType IN (
  --'UB',
'Z101',
'Z102',
'Z103',
'Z105',  --direct to FBA shipment
'Z106'      --direct to FBA shipment
)

 


  GROUP BY

 

CASE WHEN OrderDocumentType='UB' THEN -1 ELSE BookingConfirmed END
,CASE WHEN LEFT(ItemNo,2)='11' THEN '10' ELSE LEFT(ItemNo,2) END + RIGHT(ItemNo,6)
,ETAWarehouse
, processID


 

HAVING SUM(ISNULL(OrderQuantity,0)) - SUM(ISNULL(StockReceiptQuantity,0))>0

 


union all

 


SELECT 
'kitting delivery note' as [source],
a.processID,
'-1' as BookingConfirmed,
[main kitting item] as [ItemNo],
max(cast([adj. ETA WH] as date)) [ETAWarehouse],
min([main kitting item quantity])  [Open QTY]

 


FROM
(
SELECT
dn.DeliveryNumber Delivery
,ProductionOrderNo ProcessID
,case when idv.DeliveryNumber is not null
		THEN 'C' Else DeliveryDistributionStatus END as 'DeliveryNoteStatus'
,TransportType
,ContainerId Containernumber
,SUM(dn.Quantity) QTY
,StorageLocation1 [StorageLocation]
,DeliveryItemNo ItemNo
,CASE WHEN DeliveryDate=DeliveryCreationDate THEN DATEADD(dd, 40, DeliveryCreationDate) ELSE DeliveryDate END [ETA WH]
,DeliveryDate [Delivery_Date]
,DeliveryCreationDate [Document_created_on]
,kit.ItemNo as [main kitting item]
,sum(kit.[Quantity]) as 'picking QTY'
,SUM(dn.Quantity)/sum(kit.[Quantity]) as [main kitting item quantity]
,case when 
CASE WHEN DeliveryDate=DeliveryCreationDate THEN DATEADD(dd, 40, DeliveryCreationDate) ELSE DeliveryDate END<getdate() then getdate() +10 
else 
CASE WHEN DeliveryDate=DeliveryCreationDate THEN DATEADD(dd, 40, DeliveryCreationDate) ELSE DeliveryDate END
end [adj. ETA WH]

 


FROM (

 

 

SELECT DISTINCT [DeliveryNumber]
,[DeliveryPosition]
,[PONo]
,[POPosition]
,[ProductionOrderNo]
,[DeliveryDistributionStatus]
,[MovementCode]
,[MovementType]
,[DeliveryType]
,[DeliverySubType]
,[TransportType]
,[ContainerId]
,[Quantity]
,[StorageLocation1]
,[DeliveryItemNo]
,[Batch]
,[MaterialGroup]
,[DeliveryCreationDate]
,[DeliveryDate]

 

FROM [CT dwh 03 Intelligence].[dbo].[tDeliveryNotesLogisticsTemp] with(nolock)

 

 

WHERE [DeliveryType]='DIG'
AND DeliveryDistributionStatus<>'C'
AND ISNULL([ProductionOrderNo],'') <>''
AND Quantity>0
--AND DeliveryNumber ='0180023465'
--AND DeliveryItemNo='10034105'
) DN

 left join cte_idv idv on idv.DeliveryNumber = dn.DeliveryNumber


left join (SELECT [ItemNo]
      ,[BOMComponent]
       ,[Quantity]
  FROM [CT dwh 03 Intelligence].[purch].[vDimBOMItem] with(nolock)

 

  where itemno like '1%'
  and [BOMComponent] like '7%'
  and [Plant]=1000) kit
on dn.DeliveryItemNo=kit.[BOMComponent]

 

 

GROUP BY
dn.DeliveryNumber
,idv.DeliveryNumber 
,PONo
,ProductionOrderNo
,DeliveryDistributionStatus
,TransportType
,ContainerId
,StorageLocation1
,DeliveryItemNo
,DeliveryDate
,DeliveryCreationDate
,kit.ItemNo
,case when 
CASE WHEN DeliveryDate=DeliveryCreationDate THEN DATEADD(dd, 40, DeliveryCreationDate) ELSE DeliveryDate END<getdate() then getdate() +10 
else 
CASE WHEN DeliveryDate=DeliveryCreationDate THEN DATEADD(dd, 40, DeliveryCreationDate) ELSE DeliveryDate END
end
) as a

 

where a.deliverynotestatus<>'C'
and [main kitting item] is not null
--and ProcessID='000001003043'

 


group by [main kitting item], ProcessID
)ful