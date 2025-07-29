CREATE TABLE [TEST].[L0_S4HANA_2LIS_02_SCN]
(
	[ROCANCEL] [nvarchar](1) NULL,
	[CNFNR] [nvarchar](4) NULL,
	[EBELN] [nvarchar](10) NULL,
	[EBELP] [nvarchar](5) NULL,
	[SCLNR] [nvarchar](4) NULL,
	[BWVORG] [nvarchar](3) NULL,
	[CNFDT] [date] NULL,
	[CNFQTY] [decimal](13, 3) NULL,
	[CNFTM] [nvarchar](6) NULL,
	[EBTYP] [nvarchar](2) NULL,
	[is_current] [int] NULL,
	[is_deleted] [int] NULL,
	[MEINS] [nvarchar](3) NULL,
	[OPNQTY] [decimal](13, 3) NULL,
	[SCLDT] [date] NULL,
	[SCLQTY] [decimal](13, 3) NULL,
	[SCLTM] [nvarchar](6) NULL,
	[TTLQTY] [decimal](13, 3) NULL,
	[UMREN] [int] NULL,
	[UMREZ] [int] NULL,
	[ZZ_ERDAT] [date] NULL,
	[ZZ_ESTKZ] [nvarchar](1) NULL,
	[LOAD_TIMESTAMP] [datetime2](7) NOT NULL
)



INSERT INTO [MD].[MD_L0_LOAD_LIST]
           ([TableName]
           ,[SchemaName]
           ,[FolderPath]
           ,[Is_Active]
           ,[EntityName]
           ,[KeyColumns]
           ,[PipelineLastRun])
     VALUES
           ('L0_S4HANA_2LIS_02_SCN'
           ,'TEST'
           ,'curated/s4hana_theobald/cbp/2lis_02_scn'
           ,0
           ,'SAP'
           ,'ROCANCEL,EBELN,EBELP,CNFNR,SCLNR'
           ,'2024-01-01')

update [MD].[MD_L0_LOAD_LIST]set [KeyColumns] = 'EBELN,EBELP,CNFNR,SCLNR' where [TableName] = 'L0_S4HANA_2LIS_02_SCN'
update [MD].[MD_L0_LOAD_LIST]set [FolderPath] = 'curated/s4hana_theobald/cbp/2lis_02_scn', [PipelineLastRun] = '2025-03-01' where [TableName] = 'L0_S4HANA_2LIS_02_SCN'

---- select * INTO [TEST].[L0_S4HANA_2LIS_02_ITM] from [L0].[L0_S4HANA_2LIS_02_ITM]


select count(*) from [L0].L0_S4HANA_2LIS_02_SCN 
select count(*) from [TEST].L0_S4HANA_2LIS_02_SCN 