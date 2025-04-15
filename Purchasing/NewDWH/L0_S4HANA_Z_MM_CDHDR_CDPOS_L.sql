CREATE TABLE TEST.[L0_S4HANA_Z_MM_CDHDR_CDPOS_L](
	[TS_SEQUENCE_NUMBER] [int] NOT NULL,
	[OBJECTCLAS] [nvarchar](15) NOT NULL,
	[OBJECTID] [nvarchar](90) NOT NULL,
	[CHANGENR] [nvarchar](10) NOT NULL,
	[USERNAME] [nvarchar](12) NULL,
	[UDATE] [date] NULL,
	[UTIME] [char](6) NULL,
	[TCODE] [nvarchar](20) NULL,
	[PLANCHNGNR] [nvarchar](12) NULL,
	[ACT_CHNGNO] [nvarchar](10) NULL,
	[WAS_PLANND] [nvarchar](1) NULL,
	[CHANGE_IND] [nvarchar](1) NULL,
	[LANGU] [nvarchar](1) NULL,
	[_DATAAGING] [date] NULL,
	[TABNAME] [nvarchar](30) NOT NULL,
	[TABKEY] [nvarchar](70) NOT NULL,
	[FNAME] [nvarchar](30) NOT NULL,
	[CHNGIND] [nvarchar](1) NOT NULL,
	[TEXT_CASE] [nvarchar](1) NULL,
	[UNIT_OLD] [nvarchar](3) NULL,
	[UNIT_NEW] [nvarchar](3) NULL,
	[CUKY_OLD] [nvarchar](5) NULL,
	[CUKY_NEW] [nvarchar](5) NULL,
	[VALUE_NEW] [nvarchar](254) NULL,
	[VALUE_OLD] [nvarchar](254) NULL,
	[_DATAAGING001] [date] NULL,
	[VERSION1] [nvarchar](3) NULL,
	[LASTCHANGE_CDHDR] [numeric](21, 7) NULL,
	[ODQ_CHANGEMODE] [nvarchar](1) NULL,
	[ODQ_ENTITYCNTR] [numeric](19, 0) NULL,
	[LOAD_TIMESTAMP] [datetime] NULL

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
           ('L0_S4HANA_Z_MM_CDHDR_CDPOS_L'
           ,'TEST'
           ,'curated/s4hana_theobald/cbp/z_mm_cdhdr_cdpos_l'
           ,0
           ,'PURCH'
           ,'ROCANCEL,OBJECTCLAS,OBJECTID,CHANGENR,TABNAME,TABKEY,FNAME,CHNGIND'
           ,'2024-01-01')
