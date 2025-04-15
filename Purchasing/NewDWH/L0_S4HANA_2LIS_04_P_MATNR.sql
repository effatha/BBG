
CREATE TABLE [TEST].[L0_S4HANA_2LIS_04_P_MATNR](
	[AUFNR] [nvarchar](12) NULL,
	[BUKRS] [nvarchar](4) NULL,
	[MATNR] [nvarchar](40) NULL,
	[POSNR] [nvarchar](4) NULL,
	[WERKS] [nvarchar](4) NULL,
	[BUDAT] [date] NULL,
	[DFZEH] [nvarchar](3) NULL,
	[DFZEXEH] [nvarchar](3) NULL,
	[ERDAT] [date] NULL,
	[ETRMP] [date] NULL,
	[FA_GLFT] [nvarchar](1) NULL,
	[FTRMI] [date] NULL,
	[FTRMP] [date] NULL,
	[FTRMS] [date] NULL,
	[GETRI] [date] NULL,
	[GLTRP] [date] NULL,
	[GLTRS] [date] NULL,
	[GSTRI] [date] NULL,
	[GSTRP] [date] NULL,
	[GSTRS] [date] NULL,
	[I_DFZ] [decimal](7, 1) NULL,
	[I_DFZ_EX] [decimal](12, 2) NULL,
	[I_DLZ] [decimal](7, 1) NULL,
	[I_DLZ_EX] [decimal](12, 2) NULL,
	[IAMNG] [decimal](15, 3) NULL,
	[is_current] [int] NULL,
	[is_deleted] [int] NULL,
	[KDAUF] [nvarchar](10) NULL,
	[KEINH] [nvarchar](3) NULL,
	[KSUMS] [decimal](7, 1) NULL,
	[LEAD_AUFNR] [nvarchar](12) NULL,
	[LEAD_MATNR] [nvarchar](40) NULL,
	[LTRMI] [date] NULL,
	[LTRMP] [date] NULL,
	[MAUFNR] [nvarchar](12) NULL,
	[MEINS] [nvarchar](3) NULL,
	[P_DLZ] [decimal](7, 1) NULL,
	[PAMNG] [decimal](15, 3) NULL,
	[PGMNG] [decimal](15, 3) NULL,
	[PI_FREI] [decimal](7, 1) NULL,
	[PI_LIEF] [decimal](7, 1) NULL,
	[PI_STAR] [decimal](7, 1) NULL,
	[PLNUM] [nvarchar](10) NULL,
	[PS_FREI] [decimal](7, 1) NULL,
	[PS_LIEF] [decimal](7, 1) NULL,
	[PS_STAR] [decimal](7, 1) NULL,
	[PSAMG] [decimal](15, 3) NULL,
	[PSMNG] [decimal](15, 3) NULL,
	[PWERK] [nvarchar](4) NULL,
	[S_DFZ] [decimal](7, 1) NULL,
	[S_DFZ_EX] [decimal](12, 2) NULL,
	[S_DLZ] [decimal](7, 1) NULL,
	[S_DLZ_EX] [decimal](12, 2) NULL,
	[SI_FREI] [decimal](7, 1) NULL,
	[SI_LIEF] [decimal](7, 1) NULL,
	[SI_STAR] [decimal](7, 1) NULL,
	[STRMP] [date] NULL,
	[WEMNG] [decimal](15, 3) NULL,
	[ZEITP] [nvarchar](2) NULL,
	[ZZ_EBELP] [nvarchar](5) NULL,
	[ZZ_EBELN] [nvarchar](10) NULL,
	[ZZ_CY_SEQNR] [nvarchar](14) NULL,
	[LOAD_TIMESTAMP] [datetime2](7) NOT NULL

	)



	
INSERT INTO   [MD].[MD_L0_LOAD_LIST]
           ([TableName]
           ,[SchemaName]
           ,[FolderPath]
           ,[Is_Active]
           ,[EntityName]
           ,[KeyColumns]
           ,[PipelineLastRun])
     VALUES
           ('L0_S4HANA_2LIS_04_P_MATNR'
           ,'TEST'
           ,'curated/s4hana_theobald/cbp/2lis_04_p_matnr_temp'
           ,0
           ,'SAP'
           ,('AUFNR,BUKRS,WERKS,MATNR,POSNR')
           ,'2024-01-01'
		  )