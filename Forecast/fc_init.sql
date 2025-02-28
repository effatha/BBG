SELECT TOP (1000) [TableName]
      ,[SchemaName]
      ,[FolderPath]
      ,[Is_Active]
      ,[EntityName]
      ,[KeyColumns]
      ,[PipelineLastRun]
  FROM [MD].[MD_L0_LOAD_LIST]



  INSERT INTO [MD].[MD_L0_LOAD_LIST] (TableName,SchemaName,FolderPath,Is_ACTIVE,EntityName,KeyColumns,PipelineLastRun)
  SELECT
	'L0_MI_FORECAST_AMAZON'
	,'L0'
	,'curated/file/excel_upload_v2/masterdata/operational_forecast_amazon_xlsx/channelcountryforecast'
	,1
	,'OPFCF'
	,'ITEMNO,ITEMTYPE'
	,'2024-01-01'


  INSERT INTO [MD].[MD_L0_LOAD_LIST] (TableName,SchemaName,FolderPath,Is_ACTIVE,EntityName,KeyColumns,PipelineLastRun)
  SELECT
	'L0_MI_FORECAST_B2B'
	,'L0'
	,'curated/file/excel_upload_v2/masterdata/operational_forecast_b2b_xlsx/channelcountryforecast'
	,1
	,'OPFCF'
	,'ITEMNO,ITEMTYPE'
	,'2024-01-01'


	
  INSERT INTO [MD].[MD_L0_LOAD_LIST] (TableName,SchemaName,FolderPath,Is_ACTIVE,EntityName,KeyColumns,PipelineLastRun)
  SELECT
	'L0_MI_FORECAST_CEE'
	,'L0'
	,'curated/file/excel_upload_v2/masterdata/operational_forecast_cee_xlsx/channelcountryforecast'
	,1
	,'OPFCF'
	,'ITEMNO,ITEMTYPE'
	,'2024-01-01'


		
  INSERT INTO [MD].[MD_L0_LOAD_LIST] (TableName,SchemaName,FolderPath,Is_ACTIVE,EntityName,KeyColumns,PipelineLastRun)
  SELECT
	'L0_MI_FORECAST_MARKETPLACES_WE'
	,'L0'
	,'curated/file/excel_upload_v2/masterdata/operational_forecast_marketplaceswe_xlsx/channelcountryforecast'
	,1
	,'OPFCF'
	,'ITEMNO,ITEMTYPE'
	,'2024-01-01'


	  INSERT INTO [MD].[MD_L0_LOAD_LIST] (TableName,SchemaName,FolderPath,Is_ACTIVE,EntityName,KeyColumns,PipelineLastRun)
  SELECT
	'L0_MI_FORECAST_SHOP_WE'
	,'L0'
	,'curated/file/excel_upload_v2/masterdata/operational_forecast_shopwe_xlsx/channelcountryforecast'
	,1
	,'OPFCF'
	,'ITEMNO,ITEMTYPE'
	,'2024-01-01'



	INSERT INTO [MD].[MD_L0_LOAD_LIST] (TableName,SchemaName,FolderPath,Is_ACTIVE,EntityName,KeyColumns,PipelineLastRun)
  SELECT
	'L0_MI_FC_COUNTRY_CHANNEL_SHARE'
	,'L0'
	,'curated/file/excel_upload_v2/masterdata/fc_channel_country_share_xlsx/sheet1'
	,1
	,'OPFCF'
	,'CHANNELGROUP3,COUNTRY'
	,'2024-01-01'


	

	INSERT INTO [MD].[MD_L0_LOAD_LIST] (TableName,SchemaName,FolderPath,Is_ACTIVE,EntityName,KeyColumns,PipelineLastRun)
  SELECT
	'L0_MI_FC_COUNTRY_PLAN_PRICE'
	,'L0'
	,'curated/file/excel_upload_v2/masterdata/plan_price_country_xlsx/planpricecountry'
	,1
	,'OPFCF'
	,'ITEMNO,ITEMTYPE,COUNTRY'
	,'2024-01-01'


	--delete from [MD].[MD_L0_LOAD_LIST]  where EntityName = 'OPFCF'


	--curated/file/excel_upload_v2/Masterdata/plan_price_country_xlsx/planpricecountry
	--curated/file/excel_upload_v2/masterdata/plan_price_country_xlsx/planpricecountry




	CREATE TABLE L0.L0_MI_COST_DELAY_FACTOR(
		VALIDFROM			DATE,
		VALIDTO				DATE,
		COST_KPI			NVARCHAR(50),
		DELAYFACTORDAYS		INT,

	    [LOAD_TIMESTAMP]		DATETIME2
)
WITH (
    DISTRIBUTION = REPLICATE,
    HEAP
)


insert into L0.L0_MI_COST_DELAY_FACTOR(VALIDFROM,VALIDTO,COST_KPI,DELAYFACTORDAYS,LOAD_TIMESTAMP)
SELECT '2024-01-01','2025-12-31','Cancellations',1,getdate()
UNION
SELECT '2024-01-01','2025-12-31','Returns',14,getdate()
UNION
SELECT '2024-01-01','2025-12-31','Refunds',30,getdate()
UNION
SELECT '2024-01-01','2025-12-31','Depreciation',14,getdate()
UNION
SELECT '2024-01-01','2025-12-31','Replacements',30,getdate()