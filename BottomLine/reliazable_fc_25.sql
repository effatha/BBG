/****** Object:  Table [L0].[L0_AKENEO_FAMILIES]    Script Date: 08/09/2025 10:40:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [L0].[L0_MI_REALIZABLE_FC_25]
(
	ITEMNO [VARCHAR](50) NULL,
	EOL INT NULL,
	PLANPRICED DECIMAL(19,4),
	FCQTYSEP25 INT,
	OOSQTYSEP25 INT,
	REALIZABLEFCQTYSEP25 INT,
	REALIZABLEFCNOVSEP25 DECIMAL(19,4)
)
WITH
(
	DISTRIBUTION = REPLICATE,
	HEAP
)
GO


INSERT INTO [MD].[MD_L0_LOAD_LIST]
           ([TableName]
           ,[SchemaName]
           ,[FolderPath]
           ,[Is_Active]
           ,[EntityName]
           ,[KeyColumns]
           ,[PipelineLastRun])
     VALUES
           ('L0_MI_REALIZABLE_FC_25'
           ,'L0'
           ,'curated/file/excel_upload_v2/sales/blforecast/realizablefc25_xlsx/sheet1'
           ,0
           ,'FCB'
           ,'ITEMNO'
           ,'2025-08-01')