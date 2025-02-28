--truncate table  [CT dwh 01 Stage].[settlement].[tAmazonData]

select  count(*) from  [CT dwh 01 Stage].[settlement].[tAmazonData]
select top 10  * from  [CT dwh 01 Stage].[settlement].[tAmazonData]  
where 1=1
--AND settlement_id in ('21726418552') AND settlement_start_date <> ''
AND order_id = '028-2080052-4009165'

select  settlement_id 
from  [CT dwh 01 Stage].[settlement].[tAmazonData] 
where settlement_start_date<> ''
group by settlement_id
having count(*)>1

select  * from  [CT dwh 02 Data].[settlement].[tAmazonData]  
where 1=1
--AND settlement_id = '19004949142' --AND settlement_start_date <> ''
AND order_id = '304-0676388-1354768' and [amount_type]= 'ItemPrice'
and amount_description = 'Principal'


select  * from  [CT dwh 02 Data].[settlement].tAmazonData_dedup   
where 1=1 
--and posted_date like '%2023'
--and settlement_id not in (select  distinct settlement_id from  [CT dwh 01 Stage].[settlement].[tAmazonData] )
--AND settlement_id = '10406195032' --AND settlement_start_date <> ''
AND order_id = '306-2312784-1160347'


select * from  [CT dwh 03 Intelligence].[settlement].[vFactAmazonData] 
where  1 = 1
	AND MarketOrderID = '028-7235510-1072329'

select * from  [CT dwh 03 Intelligence].[settlement].[tFactAmazonData] 
where  1 = 1
	AND MarketOrderID = '028-7235510-1072329'

--material = '10038299' and MarketplaceName = 'Amazon.nl' --MarketOrderID='406-9653359-0323508'--invoiceno = '19491148792'

select * from [CT dwh 03 Intelligence].[settlement].[vFactAmazonData] where MarketOrderID = '402-7504749-4047523'

--DELETE FROM [CT dwh 03 Intelligence].[settlement].[tFactAmazonData]  where SettlementId in (20518974932)

select top 10 * from  [CT dwh 01 Stage].[settlement].[tAmazonData] where settlement_id = '19491148792'

select *,cast(amount as money) from  [CT dwh 02 Data].[settlement].[tAmazonData]  where settlement_id = '19491148792'


select top 10 * from [CT dwh 03 Intelligence].dim.tDimCalendar

--DELETE FROM [CT dwh 02 Data].[settlement].[tAmazonData]  where settlement_id in (
--select distinct settlement_id from [CT dwh 01 Stage].[settlement].[tAmazonData] 
--)

16.300.071

select count(*) from [CT dwh 03 Intelligence].[settlement].[tFactAmazonData]

select * into [CT dwh 03 Intelligence].[settlement].[tFactAmazonData_bck20240425] from [CT dwh 03 Intelligence].[settlement].[tFactAmazonData]

DELETE from [CT dwh 03 Intelligence].[settlement].[tFactAmazonData] where SettlementId in (
select distinct settlement_id from [CT dwh 01 Stage].[settlement].[tAmazonData] 
)

with cte_currency as (
	select distinct settlement_id,currency from [CT dwh 01 Stage].[settlement].[tAmazonData] where settlement_start_date <> ''
)


Update stg
SET stg.currency =cur.currency
FROM [CT dwh 01 Stage].[settlement].[tAmazonData] stg
inner join cte_currency cur on cur.settlement_id = stg.settlement_id
where 
stg.currency = ''


select top 10* FROM [CT dwh 01 Stage].[settlement].[tAmazonData] where settlement_id='11853562961' and settlement_start_date <> ''



select 
id as InternalSettlementId
,settlement_id as SettlementId
,transaction_type as TransactionType
,order_id as MarketOrderID
,marketplace_name as MarketplaceName
,amount_description as amountdescription
,Amount = cast(replace(Amount,',','.') as money)
,amount
,fulfillment_id as FulfillmentType
,PostedDate =   FORMAT(CASE WHEN posted_date ='' or posted_date is null THEN '1900-01-01' WHEN  posted_date like '%.%' THEN TRY_CONVERT(DATE, posted_date, 104) ELSE TRY_CONVERT(DATE, posted_date, 120) END,'yyyyMMdd')-- CAST(FORMAT(CASE WHEN posted_date ='' or posted_date is null THEN '1900-01-01' ELSE try_parse(posted_date as date)  END,'yyyyddMM') AS INT)
,posted_date
,SKU as AmazonSKU
,QuantityPurchased = cast(quantity_purchased as int)
,order_item_code as OrderItemCode
,amount_type as Type
,custom_merchant_token
,currency
from [CT dwh 01 Stage].[settlement].[tAmazonData] with(nolock)
Where 1 =1 
--and try_parse(replace(Amount,',','.') as money ) is  null
and settlement_start_date = ''


update [CT dwh 01 Stage].[settlement].[tAmazonData] SET amount = '1557.18' where id = 1203954
update [CT dwh 01 Stage].[settlement].[tAmazonData] SET amount = '1481.22' where id = 1320878


and order_id = '402-7504749-4047523'



select Month(orderdate)[Month],YEAR(orderdate)[YEAR],sum(Amount_EUR)Amount_EUR ,sum(Amount)Amount, sum(Quantity)Quantity
from  [CT dwh 03 Intelligence].[settlement].[vFactAmazonData] 
where MarketplaceName = 'Amazon.co.uk'
 and orderdate>='2024-01-01'-- and Material = '10037444'
	and TransactionType = 'Order'
	and AmountDescription = 'Principal'
		and type = 'ItemPrice'
Group by Month(orderdate),YEAR(orderdate)



Select *
from  [CT dwh 03 Intelligence].[settlement].[vFactAmazonData] 
where MarketplaceName = 'Amazon.co.uk'
 and orderdate>='2023-01-01' and Material = '10037444'
 and Month(orderdate) =1
 	and TransactionType = 'Order'
	and AmountDescription = 'Principal'
	and type = 'ItemPrice'






with cte_currency as (
	select distinct settlement_id,currency from [CT dwh 02 Data].[settlement].tAmazonData_dedup where settlement_start_date <> ''
)
UPDATE fact
	SET fact.currency = cur.currency
FROM [CT dwh 03 Intelligence].[settlement].[tFactAmazonData] fact
inner join cte_currency cur on cur.settlement_id = fact.settlementid
WHERE 
	isnull(fact.currency,'') =''

select  * from  [CT dwh 02 Data].[settlement].tAmazonData_dedup  
where 1=1
AND settlement_id = '20271406492' AND settlement_start_date <> ''



select count(*) from  [CT dwh 02 Data].[settlement].tAmazonData_dedup   
where 1=1 
and posted_date like '%2023'
and try_parse(amount as money ) is not null




select settlementid,count(*)
from  [CT dwh 03 Intelligence].[settlement].[tFactAmazonData] fact
where settlementid in (select distinct settlement_id from  [CT dwh 02 Data].[settlement].tAmazonData_dedup where  posted_date like '%2023' and try_parse(amount as money ) is not null
 )
 and DimPostedDateId like '2023%'
 group by settlementid

select count(distinct settlement_id) from  [CT dwh 02 Data].[settlement].tAmazonData  
where 1=1 
and posted_date like '%2023'
and try_parse(amount as money ) is not null

select settlement_id,count(*) from  [CT dwh 02 Data].[settlement].tAmazonData_dedup   
where 1=1 
and posted_date like '%2023'
and try_parse(amount as money ) is not null group by settlement_id

select * from  [CT dwh 03 Intelligence].[settlement].[tFactAmazonData] fact where SettlementId = '19139389652'
select *from  [CT dwh 02 Data].[settlement].tAmazonData_dedup     where settlement_id = '19139389652'
 select *from  [CT dwh 02 Data].[settlement].tAmazonData     where settlement_id = '19139389652'




 update fact	
	set fact.Amount = REPLACE(dl.amount,',','.')
 from  [CT dwh 03 Intelligence].[settlement].[tFactAmazonData] fact
 Inner join [CT dwh 02 Data].[settlement].tAmazonData dl on fact.internalsettlementid = dl.id
 where 1=1 
	--fact.MarketOrderID = '206-6094467-5632362'
	and dl.settlement_id not in (select distinct settlement_id from  [CT dwh 01 Stage].[settlement].tAmazonData)
	and dl.posted_date like '%2023'
	and try_parse(dl.amount as money ) is not null 



select MarketplaceName, Month(orderdate)[Month],YEAR(orderdate)[YEAR],sum(Amount_EUR)Amount_EUR ,sum(Amount)Amount, sum(Quantity)Quantity
from  [CT dwh 03 Intelligence].[settlement].[vFactAmazonData] 
where 1=1
--and MarketplaceName = 'Amazon.nl'
 and orderdate>='2024-01-01' 
 and orderdate<='2024-01-31' 
 --and Material = '10037444'
	and TransactionType = 'Order'
	and AmountDescription = 'Principal'
		and type = 'ItemPrice'
Group by Month(orderdate),YEAR(orderdate)


select *
from  [CT dwh 03 Intelligence].[settlement].[vFactAmazonData] 
where 1=1
--AND MarketplaceName = 'Amazon.co.nl'
-- --and orderdate>='2023-01-01' and Material = '10039281'
--	and TransactionType = 'Order'
--	and AmountDescription = 'Principal'
--		and type = 'ItemPrice'
	and MarketOrderID = '304-0676388-1354768'

	AND order_id = '303-8473363-1274747'

	select  InvoiceNo,TransactionType,MarketOrderID,Type,Fulfillment,OrderDate,AmazonSKU,OrderItemCode,count(*)
	from  [CT dwh 03 Intelligence].[settlement].[vFactAmazonData] 
	where orderdate>='2023-01-01' and MarketplaceName = 'Amazon.nl' and TransactionType = 'Order'  and AmountDescription = 'Principal' and Type = 'ItemPrice'
	group by InvoiceNo,TransactionType,MarketOrderID,Type,Fulfillment,OrderDate,AmazonSKU,OrderItemCode
	having count(*) > 1
	
	
	select * from [settlement].[tDimItem] where dimitemid = 40277

	select distinct ias.SKU, VariationNumber from [CT dwh 03 Intelligence].plentymarket.tDimItem_live pmitem WITH(NOLOCK)
		INNER JOIN [CT dwh 03 Intelligence].plentymarket.tDimItemASINSKU_live ias WITH(NOLOCK)
		      on ias.dimItemId = pmItem.dimItemId


			  select * from [CT dwh 03 Intelligence].plentymarket.tDimItemASINSKU_live ias WITH(NOLOCK) where sku = '10038781-fba-de'


			  select *  from [CT dwh 03 Intelligence].plentymarket.tDimItem_live where dimItemId in ( select distinct dimitemid from [CT dwh 03 Intelligence].plentymarket.tDimItemASINSKU_live ias WITH(NOLOCK) where sku = '10038781-fba-de')







select  invoiceno,Material,count(*)
from  [CT dwh 03 Intelligence].[settlement].[vFactAmazonData] 
--where MATERIAL IS NOT NULL --YEAR(OrderDate) = 2023
group by invoiceno,Material

select * 
from  [CT dwh 03 Intelligence].[settlement].[tFactAmazonData] where SettlementId = '10406195032'

select * 
from  [CT dwh 03 Intelligence].[settlement].[vFactAmazonData] where Material = '10045358'

select * 
from  [CT dwh 03 Intelligence].[settlement].[vFactAmazonData_ori] where Material = '10045358'




;with cte_new as (
select  invoiceno,Material,count(*) NumberRows
from  [CT dwh 03 Intelligence].[settlement].[vFactAmazonData_bck] 
where 1=1 --and  MATERIAL IS NOT NULL --YEAR(OrderDate) = 2023
and type ='ItemPrice'
and AmountDescription ='Principal'
group by invoiceno,Material
),
cte_current as (
select  invoiceno,Material,count(*) NumberRows
from  [CT dwh 03 Intelligence].[settlement].[vFactAmazonData] 
where 1=1 --MATERIAL IS NOT NULL --YEAR(OrderDate) = 2023
and type ='ItemPrice'
and AmountDescription ='Principal'
group by invoiceno,Material
)

SELECT 
	cur.InvoiceNo as InvoiceNo_current,new.InvoiceNo as InvoiceNo_New, cur.Material as Item_Current,new.Material as Item_New,cur.NumberRows as Rows_Current, new.NumberRows as Rows_New
FROM cte_current cur
full join cte_new new
	on isnull(cur.InvoiceNo,'') = isnull(new.InvoiceNo,'')
	and isnull(cur.Material,'') = isnull(new.material,'')
where
	isnull(cur.NumberRows,0) <> isnull(new.NumberRows,0)


	
select 
id as InternalSettlementId
,settlement_id as SettlementId
,transaction_type as TransactionType
,order_id as MarketOrderID
,marketplace_name as MarketplaceName
,amount_description as amountdescription
,Amount = cast(replace(Amount,',','.') as money)
,fulfillment_id as FulfillmentType
,PostedDate =   CAST(FORMAT(CASE WHEN posted_date ='' or posted_date is null THEN '1900-01-01' ELSE try_parse(posted_date as date)  END,'yyyyMMdd') AS INT)
,SKU as AmazonSKU
,QuantityPurchased = cast(quantity_purchased as int)
,order_item_code as OrderItemCode
,amount_type as Type
,custom_merchant_token
,currency
from [CT dwh 01 Stage].[settlement].[tAmazonData] with(nolock)
WHERE 1=1
--and try_parse(amount as money ) is not null
and order_id = '028-8634642-0548300'


select MarketOrderID,Month(orderdate)[Month],YEAR(orderdate)[YEAR],sum(Amount_EUR)Amount_EUR ,sum(Amount)Amount, sum(Quantity)Quantity
from  [CT dwh 03 Intelligence].[settlement].[vFactAmazonData] 
where
--MarketplaceName = 'Amazon.nl'
 YEAR(orderdate) = 2024
	and TransactionType = 'Order'
	and AmountDescription = 'Principal'
		and type = 'ItemPrice'
Group by Month(orderdate),YEAR(orderdate),MarketOrderID




select * from [settlement].[vFactAmazonData]
where YEAR(OrderDate) = 2024 
and AmountDescription = 'Principal'
--and Amount_EUR is null
and type = 'ItemPrice'
and MarketOrderID = '028-2080052-4009165'



SELECT *
from 
	[CT dwh 03 Intelligence].[settlement].[vFactAmazonData] 
where YEAR(OrderDate) = 2024 
and AmountDescription = 'Principal'
--and Amount_EUR is null
and type = 'ItemPrice'
and MarketOrderID = '406-3186707-9619559'












	SELECT 
		   InvoiceNo = SettlementID 
		  ,TransactionType 
		  ,MarketOrderID
		  ,MarketplaceName 
		  ,[Type] = AmountType
		  ,Amount 
		  ,Fulfillment  
		  ,OrderDate = dtPosted.Date 
		  ,AmazonSKU = ItemSku 
		  ,Quantity = QuantityPurchased
		  ,OrderItemCode
		  ,AmountDescription
		,cust.[MerchantCode] as custom_merchant_token
		,Material = ISNULL(vn.VariationNumber,CASE WHEN Left(ISNULL(TRY_PARSE(LEFT(ItemSku,8) as int),TRY_PARSE(RIGHT(ItemSku,8) as int)),2) in ('11','15','13','16','12','14','17','18','19' ) and LEN(ISNULL(TRY_PARSE(LEFT(ItemSku,8) as int),TRY_PARSE(RIGHT(ItemSku,8) as int)))=8 
										THEN CONCAT('10',RIGHT(ISNULL(TRY_PARSE(LEFT(ItemSku,8) as int),TRY_PARSE(RIGHT(ItemSku,8) as int)),6)) 
										WHEN LEN(ISNULL(TRY_PARSE(LEFT(ItemSku,8) as int),TRY_PARSE(RIGHT(ItemSku,8) as int)))=8 THEN ISNULL(TRY_PARSE(LEFT(ItemSku,8) as int),TRY_PARSE(RIGHT(ItemSku,8) as int))  
										ELSE NULL END
		
		)
		,Currency =fact.currency
		,Amount_EUR = CASE WHEN fact.currency = 'EUR' THEN fact.amount ELSE ROUND(fact.amount * fx.VL_FX_RATE,2) END
		,FX_Currency = fx.VL_FX_RATE
		,fact.[LastUpdate] 
	FROM [CT dwh 03 Intelligence].settlement.tFactAmazonData fact WITH(NOLOCK)
	INNER JOIN [CT dwh 03 Intelligence].settlement.tDimTransactionType ttype WITH(NOLOCK)
		on ttype.DimTransactionTypeId = fact.DimTransactionTypeId
	INNER JOIN [CT dwh 03 Intelligence].settlement.tDimFulfillment ful WITH(NOLOCK)
		on ful.DimFulfillmentId = fact.DimFulfillmentId 
	INNER JOIN [CT dwh 03 Intelligence].settlement.tDimAmountType amt WITH(NOLOCK)
		on amt.DimAmountTypeId = fact.DimAmountTypeId 
	INNER JOIN [CT dwh 03 Intelligence].settlement.tDimItem item WITH(NOLOCK)
		on item.DimItemId = fact.DimItemId
	INNER JOIN [CT dwh 03 Intelligence].settlement.tDimMarketPlace mkt WITH(NOLOCK)
		on mkt.DimMarketPlaceId = fact.DimMarketplaceId
	INNER JOIN [CT dwh 03 Intelligence].dim.tDimCalendar dtPosted WITH(NOLOCK)
		on dtPosted.DimCalendarId = fact.DimPostedDateId
	LEFT JOIN [CT dwh 03 Intelligence].[settlement].[fx_currencies] fx
		on fx.CD_CURRENCY = fact.currency and fx.D_EFFECTIVE = dtPosted.MonthDate
	LEFT JOIN [CT dwh 03 Intelligence].settlement.[tDimMerchant] cust WITH(NOLOCK)
		on cust.DimMerchantId = fact.DimMerchantId 
	LEFT JOIN (
		select distinct ias.SKU, VariationNumber from [CT dwh 03 Intelligence].plentymarket.tDimItem_live pmitem WITH(NOLOCK)
		INNER JOIN [CT dwh 03 Intelligence].plentymarket.tDimItemASINSKU_live ias WITH(NOLOCK)
			  on ias.dimItemId = pmItem.dimItemId
			  AND ias.SKU IS NOT NULL				--subquery to prevent duplicates
) vn
	
		on vn.SKU = ItemSku
			and (ISNULL(TRY_PARSE(LEFT(ItemSku,8) as int),TRY_PARSE(RIGHT(ItemSku,8) as int)) is null OR LEN(ISNULL(TRY_PARSE(LEFT(ItemSku,8) as int),TRY_PARSE(RIGHT(ItemSku,8) as int)))<>8 )
WHERE 
 MarketOrderID = '171-0509830-9805118'



 select * from  [CT dwh 03 Intelligence].[settlement].[tFactAmazonData] fact where MarketOrderID = '406-3186707-9619559'



 select * from [CT dwh 03 Intelligence].[settlement].[fx_currencies] where D_EFFECTIVE = '2024-05-01'