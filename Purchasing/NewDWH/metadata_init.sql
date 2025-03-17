-- add the purchasing types
INSERT INTO [TEST].[L0_MI_TRANSACTION_TYPE]
(
	[TRANSACTIONTYPESHORT],
	[TRANSACTIONTYPE],
	[SOURCETYPE],
	[LOAD_TIMESTAMP]
)

SELECT 'K','Contract','BSTYP',getdate()
UNION
SELECT 'F','Purchasing Order','BSTYP',getdate()




--CREATE TABLE [TEST].[L0_MI_TRANSACTION_TYPE]
--(
--	[TRANSACTIONTYPESHORT] [varchar](4) NOT NULL,
--	[TRANSACTIONTYPE] [varchar](20) NOT NULL,
--	[SOURCETYPE] [varchar](20) NOT NULL,
--	[LOAD_TIMESTAMP] [datetime2](7) NULL
--)
--WITH
--(
--	DISTRIBUTION = REPLICATE,
--	HEAP
--)




SSELECT TOP (1000) [TableName]
      ,[SchemaName]
      ,[FolderPath]
      ,[Is_Active]
      ,[EntityName]
      ,[KeyColumns]
      ,[PipelineLastRun]
  FROM [MD].[MD_L0_LOAD_LIST]
  where [TableName] like '%02_ITM%'

  INSERT INTO [MD].[MD_L0_LOAD_LIST] ( [TableName]
      ,[SchemaName]
      ,[FolderPath]
      ,[Is_Active]
      ,[EntityName]
      ,[KeyColumns]
      ,[PipelineLastRun])
SELECT 
 [TableName] = 'L0_S4HANA_2LIS_02_HDR'
      ,[SchemaName] = 'TEST'
      ,[FolderPath] = 'curated/s4hana_theobald/cbp/2lis_02_hdr'
      ,[Is_Active] = 0
      ,[EntityName]
      ,[KeyColumns] = 'EBELN,ROCANCEL'
      ,[PipelineLastRun] = '2024-01-01'
FROM [MD].[MD_L0_LOAD_LIST] 
where [TableName] like '%02_ITM%'
