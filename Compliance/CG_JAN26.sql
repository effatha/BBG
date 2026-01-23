--DROP TABLE  #tempItems
CREATE TABLE #tempItems(
	ItemNo varchar(50),
	ItemId int,
	ItemClass varchar(50)

)
INSERT INTO #tempItems(ItemNo, ItemID, ItemClass)
SELECT 
ItemNo, ItemID, ItemClass
FROM PL.PL_V_ITEM 
where
ItemNo in
(
'10035402',
'10046915',
'10035403',
'10035256',
'10035258',
'10033698',
'10033526',
'10036173',
'10032775',
'10033700',
'10045429',
'10030684',
'10041359',
'10034241',
'10031633',
'10041840',
'10045430',
'10033525',
'10046339',
'10041358',
'10033524',
'10045331',
'10035938',
'10046145',
'10033283',
'10041211',
'10032121',
'10031757',
'10034240',
'10047182',
'10035361',
'10035705',
'10047625',
'10034761',
'10035255',
'10041839',
'10035731',
'10046403',
'10047410',
'10045666',
'10034239',
'10046399',
'10026452',
'10046694',
'10041212',
'10034603',
'10033341',
'10030683',
'10041152',
'10035022',
'10034588',
'10038335',
'10045285',
'10040144',
'10047624',
'10035704',
'10045282',
'10034447',
'10041333',
'10046401',
'10030521',
'10012197',
'10033340',
'10034449',
'10046347',
'10035700',
'10035257',
'10034448',
'10035109',
'10047043',
'10033593',
'10046402',
'10035055',
'10031977',
'10035080',
'10033028',
'10040070',
'10047406',
'10045475'
)

--- get orders
;with sap_refund as (

SELECT
    ProcessID,
    ItemNo,
    ReturnQty = SUM(ISNULL(ReturnQty,0)) ,
	ReplacementQty = SUM(ISNULL(ReplacementQty,0)) 

FROM [PL].[PL_V_CLAIM_RATES]
   GROUP BY  ProcessID,ItemNo
   having SUM(ISNULL(ReturnQty,0))  > 0
    
), cte_sales
as
(
SELECT 
	it.ItemNo,
	s.ProcessID,
	Channel,
	ChannelGroup1,
	ProcessIDDate = MIN(isnull(s.ProcessIDDate,'2220-01-01')),
	s.CustomerId ,
	s.MarketPlaceOrderId,
	OrderQuantity = SUM(ISNULL(OrderQuantity,0)),
	GrossOrderValue = SUM(ISNULL(GrossOrderValue,0))
FROM PL.PL_V_SALES_TRANSACTIONS s
INNER JOIN #tempItems it
	on s.ItemId = it.ItemId
INNER JOIN PL.PL_V_SALES_CHANNEL ch
	on ch.ChannelId = s.ChannelId
WHERE
	Isnull(incidentflag,'N') = 'N'
	--AND
	--TransactionTypeShort in ('ZAA','ZKE','ZAZ')
	AND
	DeliveryCountry = 'CH'
	AND
	ISNULL(ReasonforRejections,'') =''
	and 
	CompanyID  in (43,343)
	and channelgroup1 not in ('Intercompany', 'Mandanten')
GROUP BY
	it.ItemNo,
	s.ProcessID,
	ch.Channel,
	ch.ChannelGroup1,
	s.ProcessIDDate,
	s.CustomerId,MarketPlaceOrderId
having 
	SUM(ISNULL(OrderQuantity,0)) > 0
)
select s.*,
	ReturnedQty = (ISNULL(ReturnQty,0)) ,
	Replacement =  (ISNULL(ReplacementQty,0))
FROM cte_sales s
LEFT JOIN  sap_refund ref
	on ref.ProcessId = s.ProcessID
	and ref.ItemNo = s.ItemNo
where 
OrderQuantity -  (ISNULL(ReturnQty,0)) + (ISNULL(ReplacementQty,0)) > 0

	select SUM(ISNULL(ReturnQty,0))  from pl.pl_v_company 



	--43
	--343


	--select SUM(ISNULL(OrderQuantity,0)) FROM PL.PL_V_SALES_TRANSACTIONS s where processid = '0406969316'

	--select SUM(ISNULL(ReturnQty,0))  from  [PL].[PL_V_CLAIM_RATES] where processid = '0406969316'