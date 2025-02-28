--/****** Script for SelectTopNRows command from SSMS  ******/

ALTER VIEW  PL.PL_V_AMAZON_SETTLEMENT
as
with cte_asin as (
	SELECT 
		cd_asin,CD_COUNTRY,ID_ITEM, RANK() over (partition by cd_asin,CD_COUNTRY,ID_ITEM order by ID_AMAZON_ASIN_2_ITEM_MAPPING DESC ) rk
  FROM [L1].[L1_DIM_A_AMAZON_ASIN_2_ITEM_MAPPING] asi
--  where cd_asin = 'B00B6CPRMM' and CD_COUNTRY = 'DE'
  group by cd_asin,CD_COUNTRY,ID_ITEM,ID_AMAZON_ASIN_2_ITEM_MAPPING

)
SELECT		DATA_SOURCE,amz.D_EFF_FROM
		   ,InvoiceNo = Settlement_ID 
		  ,TransactionType = TRANSACTION_TYPE
		  ,MarketOrderID = ORDER_ID
		  ,MarketplaceName = T_MARKETPLACE
		  ,[Type] = AMOUNT_TYPE
		  ,Amount = AMOUNT
		  ,Fulfillment  = ID_FULFILLMENT
		  ,OrderDate = DATE_POSTED 
		  ,AmazonSKU = SKU 
		  ,Quantity = Quantity_Purchased
		  ,OrderItemCode = ORDER_ITEM_CODE
		  ,AmountDescription = T_AMOUNT
		,custom_merchant_token = ID_MARKETPLACE
		,Material = ISNULL(it.NUM_ITEM,CASE WHEN Left(ISNULL(TRY_PARSE(LEFT(SKU,8) as int),TRY_PARSE(RIGHT(SKU,8) as int)),2) in ('11','15','13','16','12','14','17','18','19' ) and LEN(ISNULL(TRY_PARSE(LEFT(SKU,8) as int),TRY_PARSE(RIGHT(SKU,8) as int)))=8 
										THEN CONCAT('10',RIGHT(ISNULL(TRY_PARSE(LEFT(SKU,8) as int),TRY_PARSE(RIGHT(SKU,8) as int)),6)) 
										WHEN LEN(ISNULL(TRY_PARSE(LEFT(SKU,8) as int),TRY_PARSE(RIGHT(SKU,8) as int)))=8 THEN ISNULL(TRY_PARSE(LEFT(SKU,8) as int),TRY_PARSE(RIGHT(SKU,8) as int))  
										ELSE NULL END
		
		)
		,Currency = amz.CD_CURRENCY
		,Amount_EUR = CASE WHEN amz.CD_CURRENCY = 'EUR' THEN amz.amount ELSE ROUND(amz.amount * fx.VL_FX_RATE,2) END
		,FX_Currency = fx.VL_FX_RATE
		,amz.DT_DWH_UPDATED 

  FROM [L1].[L1_FACT_A_AMAZON_SETTLEMENT_REPORT] AMZ
  	LEFT JOIN  [l1].L1_FACT_F_FX_RATE fx
		on fx.CD_CURRENCY = amz.cd_currency and fx.D_EFFECTIVE = DATEADD(month, DATEDIFF(month, 0, DATE_POSTED), 0)
  LEFT JOIN cte_asin map
       on map.CD_ASIN = sku  and map.[CD_COUNTRY] = amz.[CD_COUNTRY] and rk = 1
  LEFT JOIN L1.L1_DIM_A_ITEM it on it.ID_ITEM = map.ID_ITEM


  select count(*) from  PL.PL_V_AMAZON_SETTLEMENT where material is null

--	SELECT amz.Settlement_ID,ORDER_ID,sku,AMOUNT_TYPE,TRANSACTION_TYPE,amz.[CD_COUNTRY]
--  FROM [L1].[L1_FACT_A_AMAZON_SETTLEMENT_REPORT] AMZ
--  INNER JOIN [L1].[L1_DIM_A_AMAZON_ASIN_2_ITEM_MAPPING] map
--       on map.CD_ASIN = sku  and map.[CD_COUNTRY] = amz.[CD_COUNTRY]
--group by amz.Settlement_ID,ORDER_ID,sku,AMOUNT_TYPE,TRANSACTION_TYPE,amz.[CD_COUNTRY]
--having count(*) > 1

--	SELECT 
--		cd_asin,CD_COUNTRY,ID_ITEM, RANK() over (partition by cd_asin,CD_COUNTRY,ID_ITEM order by ID_AMAZON_ASIN_2_ITEM_MAPPING DESC )
--  FROM [L1].[L1_DIM_A_AMAZON_ASIN_2_ITEM_MAPPING] asi
----  where cd_asin = 'B00B6CPRMM' and CD_COUNTRY = 'DE'
--  group by cd_asin,CD_COUNTRY,ID_ITEM,ID_AMAZON_ASIN_2_ITEM_MAPPING



  	SELECT *
  FROM [L1].[L1_DIM_A_AMAZON_ASIN_2_ITEM_MAPPING] asi
  where cd_asin = 'B01NCXEA0O' and CD_COUNTRY = 'GB'



 select MarketplaceName, Month(orderdate)[Month],YEAR(orderdate)[YEAR],sum(Amount_EUR)Amount_EUR ,sum(Amount)Amount, sum(Quantity)Quantity
from  PL.PL_V_AMAZON_SETTLEMENT
where 1=1
--and MarketplaceName = 'Amazon.nl'
 and orderdate>='2024-02-01' 
 and orderdate<='2024-02-29' 
 --and Material = '10037444'
	and TransactionType = 'Order'
	and AmountDescription = 'Principal'
		and type = 'ItemPrice'
Group by Month(orderdate),YEAR(orderdate),MarketplaceName



 select *
from  PL.PL_V_AMAZON_SETTLEMENT
where 1=1
and MarketplaceName = 'Amazon.it'
 --and orderdate>='2024-02-01' 
 --and orderdate<='2024-02-29' 
 --and Material = '10037444'
	and TransactionType = 'Order'
	and AmountDescription = 'Principal'
		and type = 'ItemPrice'
	and d_eff_from = '2024-07-08'
order by amount desc