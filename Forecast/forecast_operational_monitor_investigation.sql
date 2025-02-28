----FORECAST OPERATIONAL MONITOR

--Tables used
--QUERY 1  ---- NOT USED
select top 10
	ArticleNumber,
	Channel,
	Country,
	Campaign,
	*
from [CT dwh 03 Intelligence].[sales].[vFactPricingCampaign]
 
where Channel = 'Amazon FBA' and Country = 'DE' and Campaign = 'Yield_Management-Price'

---QUERY 2

SELECT top 100 *
	
from [CT dwh 03 Intelligence].forecast.vForecastCalculation qty
left join  [CT dwh 03 Intelligence].[forecast].[vfactPlanPriceCalculation] as price
	on qty.ItemNo=price.ItemNo
	and qty.Channel = price.Channel
	and qty.Country = price.Country
	and qty.month = price.month
	and qty.year = price.year


--qty.year  = year (getdate()-1)
--qty.LastModifiedTimeStamp < '2023-09-22'


--- Query 3
SELECt top 100
	*
FROM [CT dwh 03 Intelligence].[stockturnover].[vFactStockServiceData]
where
date >= DATEADD (month , -4 , getdate()-1)  and AvailableStock > 0  and sku   like '1%' 

--- QUERY 4
SELECT top 100
	 [ItemNo] ,[DIOWH_Final],[DIOShip_Final] ,[DIOOrder_Final]
FROM [CT dwh 03 Intelligence].[dbo].[vFactDioCalculation]
where ImportDate=(select MAX(ImportDate) FROM [CT dwh 03 Intelligence].[dbo].[vFactDioCalculation])

----query 5 ---- Harmony

----query 6 
SELECT distinct fc.Country FROM [CT dwh 03 Intelligence].[forecast].[vFactForecast]



---query 7 --- harmony
select 
	aam.asin as asin,
	aam.parent_asin as Parent_ASIN,
	aam.artikelnummer,
	aam.channel as channel,
	case when aam.country_code in ('DE','ES','FR','IT') then aam.country_code when aam.country_code = 'UK' then 'GB'else 'INT' end as country_code,
	aam.report_date ,
	CASE when aam.lowest_node_sales_rank = 0 THEN NULL ELSE aam.lowest_node_sales_rank END AS RANK, case when aam.Buybox_Enabled = 'true' then 1 else 0 end as BuyboxEnabled
	from   amazing_amazon_all_brands_ as aam 
	where DATE_PART('month',aam.report_date )>=DATE_PART('month',CURRENT_DATE) - 2
	AND DATE_PART('year',aam.report_date )>=DATE_PART('year',CURRENT_DATE) 
	and   aam.country_code not in ('US','CA')

--- query 8 -- \\chal-tec.local\files\server\\BI-Dashboards\0. INPUT FILES\FC FF Monitor\Liquidation (including kill list).xlsx"

--- query 9 --harmony
select [SKU],[Sales quantity delta until 1st delivery] as [Stockout risk until next ETA/60 days (units)], [First delivery date] as [Next ETA]
from pricing_yield_management#
where date_added = current_date
and [Sales quantity delta until 1st delivery] <>0

---query 9 --- mercury db --
