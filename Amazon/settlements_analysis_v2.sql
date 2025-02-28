select OrderDate,MarketOrderId,AmazonSKU, MONTH(OrderDate) [OrderMonth],SUM(Amount)Amount,SUM(Amount_EUR)Amount_EUR, sum(quantity)
from  [CT dwh 03 Intelligence].[settlement].[vFactAmazonData] 
where 1=1 --MATERIAL IS NOT NULL --YEAR(OrderDate) = 2023
and type ='ItemPrice'
and AmountDescription ='Principal'
and Material ='10038811'
and YEAR(OrderDate) = 2023
--and MONTH(OrderDate) = 8
--and OrderDate  ='2023-08-19'
and TransactionType = 'Order'
--and AmazonSKU not like 'US%'
group by MONTH(OrderDate),OrderDate,MarketOrderId,AmazonSKU
order by 1


select *from  [CT dwh 03 Intelligence].[settlement].[vFactAmazonData]  where marketorderid = '302-2734159-9811567'



select * from  [CT dwh 01 Stage].[settlement].[tAmazonData] stg where order_id = '028-4483261-5129141'

select order_id,posted_date,SUM(CAST(REPLACE(stg.amount,',','.') as money))Amount,
SUM(CAST(CASE WHEN stg.currency = 'EUR' THEN REPLACE(stg.amount,',','.') ELSE ROUND(REPLACE(stg.amount,',','.') * fx.VL_FX_RATE,2) END as money))Amount_EUR, 
sum(cast(quantity_purchased as int)) QTY

from  [CT dwh 01 Stage].[settlement].[tAmazonData] stg
	LEFT JOIN [CT dwh 03 Intelligence].[settlement].[fx_currencies] fx
		on fx.CD_CURRENCY = stg.currency and fx.D_EFFECTIVE = '2023-08-01'
	LEFT JOIN (
		select distinct ias.SKU, VariationNumber from [CT dwh 03 Intelligence].plentymarket.tDimItem_live pmitem WITH(NOLOCK)
		INNER JOIN [CT dwh 03 Intelligence].plentymarket.tDimItemASINSKU_live ias WITH(NOLOCK)
			  on ias.dimItemId = pmItem.dimItemId
			  AND ias.SKU IS NOT NULL				--subquery to prevent duplicates
) vn
	
		on vn.SKU = stg.sku
			and ISNULL(TRY_PARSE(LEFT(stg.sku,8) as int),TRY_PARSE(RIGHT(stg.sku,8) as int)) is null
where 1=1 --MATERIAL IS NOT NULL --YEAR(OrderDate) = 2023
and amount_type ='ItemPrice'
and Amount_Description ='Principal'
and ISNULL(vn.VariationNumber,CASE WHEN Left(ISNULL(TRY_PARSE(LEFT(stg.sku,8) as int),TRY_PARSE(RIGHT(stg.sku,8) as int)),2) in ('11','15','13','16','12','14','17','18','19' )
										THEN CONCAT('10',RIGHT(ISNULL(TRY_PARSE(LEFT(stg.sku,8) as int),TRY_PARSE(RIGHT(stg.sku,8) as int)),6)) ELSE ISNULL(TRY_PARSE(LEFT(stg.sku,8) as int),TRY_PARSE(RIGHT(stg.sku,8) as int)) END) ='10039049'
and RIGHT(posted_date,7) = '08.2023'
and try_parse(REPLACE(stg.amount,',','.') as money ) is not null 
and settlement_start_date = ''
group by posted_date,order_id
order by 1




select * from  [CT dwh 03 Intelligence].plentymarket.tDimItemASINSKU_live ias WITH(NOLOCK)
where sku = '11040335k'


1604035
1605977

select *
from [CT dwh 03 Intelligence].plentymarket.tDimItem_live pmitem WITH(NOLOCK)
where DimItemId in (1604035,1605977)




select distinct ias.SKU, VariationNumber from [CT dwh 03 Intelligence].plentymarket.tDimItem_live pmitem WITH(NOLOCK)
INNER JOIN [CT dwh 03 Intelligence].plentymarket.tDimItemASINSKU_live ias WITH(NOLOCK)
  on ias.dimItemId = pmItem.dimItemId
			  AND ias.SKU IS NOT NULL		
			where ias.sku= '11040335k'



