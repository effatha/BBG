select 
*
,rank() over (partition by BookingConfirmed,ful.[ItemNo] order by ful.ETAWarehouse,ful.ETD,ful.ProcessId) as rank
from(
SELECT
  'purchasetransaction' as [source]
  ,ProcessId
  ,CASE WHEN OrderDocumentType='UB' THEN -1 ELSE BookingConfirmed END BookingConfirmed
  ,CASE WHEN LEFT(ItemNo,2)='11' THEN '10' ELSE LEFT(ItemNo,2) END + RIGHT(ItemNo,6) [ItemNo]
  ,CASE WHEN OrderDocumentType = 'UB' THEN 'Stock in Transfer' ELSE CASE WHEN BookingConfirmed = -1 THEN 'Booking is confirmed' ELSE 'Booking NOT Confirmed' END END [BookingStatus]
--  ,ForwarderReference
  ,cast(CASE
    WHEN ETAWarehouse<=CAST(GETDATE()-1 as date)
 THEN DATEADD(dd,11,CAST(GETDATE()-1 as date))
 ELSE ETAWarehouse
 END as date) ETAWarehouse
      ,[ETD]
      ,isnull([ETD],DATEADD(dd,-70,ETAWarehouse)) [calc_ETD]
      ,[ETAPort]
 ,sum(isnull(OrderValue,0))/sum(ISNULL(OrderQuantity,0)) OrderItemPrice
   ,SUM(ISNULL(OrderQuantity,0)) - SUM(ISNULL(StockReceiptQuantity,0)) [Open_QTY]
  FROM [CT dwh 03 Intelligence].[dbo].[vFactPurchasingOrdersTransactions]
  WHERE CompanyId=1000
  AND ItemNo IS NOT NULL
  AND ItemNo <> ''
  AND OrderDocumentNo IS NOT NULL
  AND ISNULL(ItemProcessFulfilled,0)=0
  AND ISNULL(ProcessFulfilled,0)=0
  AND OrderDocumentType IN (
--  'UB',					--stock in transfer
 'Z101',
 'Z102',
 'Z103',
 'Z105',				--direct to FBA shipment
 'Z106'					--direct to FBA shipment
 )
-- and plant=1100
-- and BookingConfirmed=-1
  --and ProcessId='4501018791'
  --and itemno=10034227
  GROUP BY
  ProcessId
  ,CASE WHEN OrderDocumentType='UB' THEN -1 ELSE BookingConfirmed END
,CASE WHEN LEFT(ItemNo,2)='11' THEN '10' ELSE LEFT(ItemNo,2) END + RIGHT(ItemNo,6)
,CASE WHEN OrderDocumentType = 'UB' THEN 'Stock in Transfer' ELSE CASE WHEN BookingConfirmed = -1 THEN 'Booking is confirmed' ELSE 'Booking NOT Confirmed' END END
--,ForwarderReference
,ETAWarehouse
       ,[ETD]
      ,[ETAPort]
HAVING SUM(ISNULL(OrderQuantity,0)) - SUM(ISNULL(StockReceiptQuantity,0))>0
union all 
SELECT  
'kitting delivery note' as [source]
,header.[ProcessId]
,'-1' as BookingConfirmed
,CASE WHEN LEFT(header.itemno,2)='11' THEN '10' ELSE LEFT(header.itemno,2) END + RIGHT(header.itemno,6) [ItemNo]
,'Booking is confirmed' as [BookingStatus]
--,upper([ForwarderReferenceNumber]) as   ForwarderReference
,header.[ETAWareHouse]
,header.[ETD]
,isnull(header.[ETD],DATEADD(dd,-70,header.ETAWarehouse)) [calc_ETD]
,header.[ETAport]
--,header.[ItemPriceForeignCurrency]
,avg(case when header.[ItemPrice] = 0 then null else header.[ItemPrice] end) as OrderItemPrice
,sum(header.[Quantity]) as [Open_QTY]
--,header.[ValueForeignCurrency]
--,header.[Value]
FROM [CT dwh 03 Intelligence].[purch].[vFactVertical] header
---------------relevant ProcessIDs---------------
inner join(
SELECT  
[ProcessId]
,dn.ItemNo
FROM [CT dwh 03 Intelligence].[purch].[vFactVertical] vert
--------------ProcessID to ProductionOrder---------------
left join(
select 
documentno
from [CT dwh 03 Intelligence].[purch].[vFactVertical] 
where transactiontypedetail = 'Inbound Delivery Movement' 
and documentno <>'' 
group by documentno
)doc on vert.[DeliveryNo]=doc.documentno
--------------find ProductionOrder in Logistics temp---------------
left join (
select 
temp.[DeliveryNumber]
,bom.ItemNo
FROM [CT dwh 03 Intelligence].[dbo].[tDeliveryNotesLogisticsTemp] temp
  left join (
  select
  [ItemNo],
  [BOMComponent]
  from [CT dwh 03 Intelligence].[purch].[vDimBOMItem]
  where
  Plant=1000
  and DeletionIndicator=0
  and left([ItemNo],2)='10'
  group by 
  [ItemNo],
  [BOMComponent]
  ) bom on temp.DeliveryItemNo=bom.BOMComponent
WHERE [DeliveryType]='DIG'
AND DeliveryDistributionStatus<>'C'
AND DeliveryDistributionStatus<>''
AND ISNULL([ProductionOrderNo],'') <>''
AND Quantity>0
group by [DeliveryNumber],bom.ItemNo
)dn on dn.DeliveryNumber = vert.[DeliveryNo]
where 1=1
--and plant=1100
and [DeliveryNo] not in (
'0180000065',
'0180002585',
'0180002802',
'0180003066',
'0180003238',
'0180004280',
'0180009887',
'0180014055',
'0180016232',
'0180043979',
'0180051574',
'0180062747',
'0180063445',
'0180078056',
'0180291365',
'0180330105',
'0180349397',
'0180356147',
'0180364826',
'0180398085')  -- incident
and [TransactionTypeDetail]='ProductionOrder'
and dn.DeliveryNumber is not null
group by 
[ProcessId]
,dn.ItemNo
)relevant on relevant.ProcessId=header.ProcessId
and relevant.ItemNo=CASE WHEN LEFT(header.itemno,2)='11' THEN '10' ELSE LEFT(header.itemno,2) END + RIGHT(header.itemno,6)
where header.[TransactionTypeDetail] ='Order'
and header.[ETAWareHouse] != '0001-01-01'
and left(header.itemno,2)='11'
group by
header.[ProcessId]
,CASE WHEN LEFT(header.itemno,2)='11' THEN '10' ELSE LEFT(header.itemno,2) END + RIGHT(header.itemno,6)
--,upper([ForwarderReferenceNumber])
,header.[ETAWareHouse]
,header.[ETD]
,isnull(header.[ETD],DATEADD(dd,-70,header.ETAWarehouse)) 
,header.[ETAport]
)ful