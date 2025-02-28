select top 200 * 
from [CT dwh 03 Intelligence].[logbase].[vFactStockLevel]
where 1=1
and date = '2024-04-01' 
--and ItemQuality = 'A' 
--and StorageLocationId = 1000 
--and Quantity > 1
and itemno = '10000109'
order by date desc

select top 100 *,CASE WHEN StorageLocation = '1008' THEN '1003' WHEN StorageLocation='1005' THEN '1002' ELSE StorageLocation END StorageLocationLogbase 
from [CT dwh 03 Intelligence].[dim].[vFactStockLevels]
where 
date = '2024-04-01' 
--and Batch = 'A' 
--and Plant = '1000' 
--and Quantity > 1 
and itemno = '10000109'





;with  cte_stock_type as(
 
	 select
		BSTAUS,StockType,
		LogBaseStockType = CASE		
								WHEN BSTAUS IN ('A','K','Q') THEN 'F'
								WHEN BSTAUS IN ('E','M','P','S') THEN 'R'
								WHEN BSTAUS IN ('C','W') THEN 'B'
								WHEN BSTAUS IN ('D') THEN 'S'
								WHEN BSTAUS IN ('B','L','O') THEN 'Q'
								WHEN BSTAUS IN ('H','F') THEN 'T'
								ELSE
								'C' END
	 from [CT dwh 00 Meta].[sap].[t2LIS_03_BF_Mapping_BSTAUS]
 
 ),
CTE_STOCK_LOGBASE AS (
	
	SELECT 
		[Date],
		[StorageLocationID],
		svr.ServerName   StorageLocation,
		ItemNo,
		Quantity = SUM(Quantity),
		ItemQuality,
		[Availability]
	FROM [CT dwh 03 Intelligence].[logbase].[vFactStockLevel] st
	INNER JOIN [CT dwh 03 Intelligence].logbase.tDimLogbaseServer svr on st.StorageLocationID = svr.LogBaseID
	WHERE [Date]>= '2024-04-01'
	GROUP BY [Date],[StorageLocationID],ItemNo,ItemQuality,[Availability],svr.ServerName
 ),
  CTE_STOCK_SAP AS (
	
	SELECT 
		[Date],
		CASE WHEN StorageLocation = '1008' THEN '1003' WHEN StorageLocation='1005' THEN '1002' ELSE StorageLocation END [StorageLocationID],
		ItemNo,
		Quantity = SUM(Quantity),
		Batch,
		LogBaseStockType,
		svr.ServerName as StorageLocation
	select top 10 * FROM [CT dwh 03 Intelligence].[dim].[vFactStockLevels] st
	INNER JOIN cte_stock_type tt on st.StockType = tt.StockType
	INNER JOIN [CT dwh 03 Intelligence].logbase.tDimLogbaseServer svr on st.StorageLocation = ISNULL(svr.SapLocationID,svr.LogBaseID)
	WHERE [Date]>= '2024-04-01'
	GROUP BY [Date],CASE WHEN StorageLocation = '1008' THEN '1003' WHEN StorageLocation='1005' THEN '1002' ELSE StorageLocation END,ItemNo,Batch,LogBaseStockType,svr.ServerName
 )
 SELECT
	[Date] = ISNULL(sap.DATE,logb.Date),
	[ItemNo] = ISNULL(sap.ItemNo,logb.ItemNo),
	[ItemType] = ISNULL(sap.Batch,logb.Availability),
	[StockAvailability] = ISNULL(sap.LogBaseStockType,logb.Availability),
	[StorageLocationID] = ISNULL(sap.StorageLocationID,logb.StorageLocationID),
	[StorageLocation] = ISNULL(sap.StorageLocation,logb.StorageLocation),
	SAPQuantity = sap.Quantity,
	LogbaseQuantity = logb.Quantity
	INTO [CT dwh 03 Intelligence].dbo.StockOverviewSapLogbase
 FROM CTE_STOCK_SAP sap
 FULL JOIN CTE_STOCK_LOGBASE logb
 on 
	sap.DATE = logb.Date
	 AND sap.ItemNo = logb.ItemNo
	 AND sap.Batch = logb.ItemQuality
	 AND sap.LogBaseStockType = logb.Availability
	 AND sap.StorageLocationID = logb.StorageLocationID


	 	select top 100 * FROM [CT dwh 03 Intelligence].[dim].[vFactStockLevels] st
		where itemno = '10035443' and plant = '1100' and date = '2024-06-23' And batch = 'A'
		

	 	select top 100 * FROM [CT dwh 03 Intelligence].[dim].[vFactStockLevels] st
		where itemno = '10035443' and plant = '1100' and date = '2024-06-24'   And batch = 'A'
		

		--select top 10 * FROM [CT dwh 03 Intelligence].[dim].[tFactStockLevels] st
		--where itemno = '10035443' and plant = '1100' and date = '2024-06-23'


		--select top 100 * FROM [CT dwh 03 Intelligence].[logbase].[vFactStockLevel] st  
		--where itemno = '10035443' and StorageLocation = 'Bratislava' and ItemQuality = 'A' and date = '2024-06-23'

		select top 10 * from [CT dwh 03 Intelligence].dim.vFactStockMovements where itemno = '10035443' and plant = '1100' and date = '2024-06-23'  And batch = 'A'
select * FROM (	
	SELECT cal.Date
	,ItemNo_SAP as ItemNo
	,PlantCode as Plant
	,StorageLocation
	,Artikelzustand as Batch
	,StockType
	,Quantity
	,rank() over (partition by ItemNo_SAP,PlantCode,StorageLocation,StockType  order by cal.Date desc) as rnk 
  FROM [CT dwh 03 Intelligence].[dim].[tFactStockMovements] fact WITH (NOLOCK)
  left join dim.tDimItem_SL dsl WITH (NOLOCK)
  on dsl.DimItemId = fact.DimItemId
  left join dim.tDimStorageLocation sl WITH (NOLOCK)
  on fact.DimStorageLocationId = sl.DimStorageLocationId
  left join dim.tDimSource ds WITH (NOLOCK)
  on fact.DimSourceId = ds.DimSourceId
  left join dim.tDimPlant comp WITH (NOLOCK)
  on fact.DimPlantID = comp.DimPlantId
  left join dim.tDimCalendar cal WITH (NOLOCK)
  on fact.TransactionDateDimCalendarID = cal.DimCalendarId
   where ItemNo_SAP = '10035443' and PlantCode = '1100' and cal.Date <= '2024-06-24'  And Artikelzustand = 'A'

   ) stock  WHERE RNK=1

  
select 
	getdate() AS SnapshotDateDimCalendarID, 
	DimItemId, 
	DimPlantID, 
	DimStorageLocationId, 
	StockType, 
	QUANTITY, 
	TransactionDateDimCalendarID, 
	DimSourceId 
	FROM (  SELECT 
	DimItemId,  DimPlantID,  DimStorageLocationId,  StockType, 
	QUANTITY, 
	TransactionDateDimCalendarID,  DimSourceId  ,
	rank() over (partition by DimItemId,DimPlantID,DimStorageLocationId,stocktype  order by TransactionDateDimCalendarID desc) as rnk 
FROM [CT dwh 03 Intelligence].[dim].[tFactStockMovements] with (nolock)  where TransactionDateDimCalendarID <='20240624'  )STOCK  WHERE RNK=1
