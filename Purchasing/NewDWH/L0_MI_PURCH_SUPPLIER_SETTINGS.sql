CREATE TABLE TEST.L0_MI_PURCH_SUPPLIER_SETTINGS(
	SUPPLIER_CODE				VARCHAR(50) ,
	SUPPLIER_CURRENCY		    VARCHAR(10) ,
	DEPOSIT_TYPE				VARCHAR(20) ,
	DEPOSIT_CURRENCY			VARCHAR(10),
	FIXED_DEPOSIT_AMOUNT		DECIMAL(19,4),
	DEPOSIT_PERC				DECIMAL(19,4),
	PAYMENT_TERM				INT,
	LEAD_TIME					INT,
	TRANSITTIMEINDAYS			INT,
	[LOAD_TIMESTAMP] [DATETIME] NULL

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
           ('L0_MI_PURCH_SUPPLIER_SETTINGS'
           ,'TEST'
           ,'curated/file/excel_upload_v2/purchasing/procurement_cash_flow_xlsx/supplier_settings'
           ,0
           ,'PROC'
           ,'SUPPLIER_CODE'
           ,'2025-01-01')


        select * from TEST.L0_MI_PURCH_SUPPLIER_SETTINGS where supplier_code in ('SLP1')