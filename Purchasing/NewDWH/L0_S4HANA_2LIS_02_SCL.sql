CREATE TABLE [TEST].[L0_S4HANA_2LIS_02_SCL]
(
	[EBELN] [nvarchar](10) NULL,
	[EBELP] [nvarchar](5) NULL,
	[ETENR] [nvarchar](4) NULL,
	[AFNAM] [nvarchar](12) NULL,
	[AKTNR] [nvarchar](10) NULL,
	[ATTYP] [nvarchar](2) NULL,
	[BANFN] [nvarchar](10) NULL,
	[BEDAT] [date] NULL,
	[BNFPO] [nvarchar](5) NULL,
	[BSART] [nvarchar](4) NULL,
	[BSGRU] [nvarchar](3) NULL,
	[BSTYP] [nvarchar](1) NULL,
	[BUDAT] [date] NULL,
	[BUDG_TYPE] [nvarchar](2) NULL,
	[BWAPPLNM] [nvarchar](30) NULL,
	[BWBRTWR] [decimal](13, 2) NULL,
	[BWEFFWR] [decimal](15, 2) NULL,
	[BWGEO] [decimal](19, 2) NULL,
	[BWGEOO] [decimal](19, 2) NULL,
	[BWGVO] [decimal](19, 2) NULL,
	[BWGVP] [decimal](19, 2) NULL,
	[BWKZWI1] [decimal](13, 2) NULL,
	[BWKZWI2] [decimal](13, 2) NULL,
	[BWKZWI3] [decimal](13, 2) NULL,
	[BWKZWI4] [decimal](13, 2) NULL,
	[BWKZWI5] [decimal](13, 2) NULL,
	[BWKZWI6] [decimal](13, 2) NULL,
	[BWMNG] [decimal](15, 3) NULL,
	[BWVORG] [nvarchar](3) NULL,
	[BZGWR] [decimal](13, 2) NULL,
	[CHARG] [nvarchar](10) NULL,
	[CHECK_TYPE] [nvarchar](1) NULL,
	[CNCL_ANCMNT_DONE] [nvarchar](1) NULL,
	[DATESHIFT_NUMBER] [int] NULL,
	[DBWGEO] [decimal](19, 2) NULL,
	[DBWMNG] [decimal](15, 3) NULL,
	[DL_ID] [nvarchar](22) NULL,
	[DNG_DATE] [date] NULL,
	[DNG_TIME] [nvarchar](6) NULL,
	[EINDT] [date] NULL,
	[EKGRP] [nvarchar](3) NULL,
	[EKORG] [nvarchar](4) NULL,
	[ELIKZ] [nvarchar](1) NULL,
	[EMATN] [nvarchar](40) NULL,
	[EREKZ] [nvarchar](1) NULL,
	[HANDOVER_DATE] [date] NULL,
	[HWAER] [nvarchar](5) NULL,
	[ITEM_CAT] [nvarchar](2) NULL,
	[ITMUSE] [nvarchar](2) NULL,
	[KDATB] [date] NULL,
	[KDATE] [date] NULL,
	[KEY_ID] [nvarchar](16) NULL,
	[KONNR] [nvarchar](10) NULL,
	[KTPNR] [nvarchar](5) NULL,
	[LBLIF] [nvarchar](10) NULL,
	[LGORT] [nvarchar](4) NULL,
	[LIFNR] [nvarchar](10) NULL,
	[LIFRE] [nvarchar](10) NULL,
	[LLIEF] [nvarchar](10) NULL,
	[LMEIN] [nvarchar](3) NULL,
	[LOGSY] [nvarchar](10) NULL,
	[MAHNZ] [int] NULL,
	[MATKL] [nvarchar](9) NULL,
	[MATNR] [nvarchar](40) NULL,
	[MEINS] [nvarchar](3) NULL,
	[NETPR] [decimal](11, 2) NULL,
	[NO_SCEM] [nvarchar](1) NULL,
	[NOSCL] [int] NULL,
	[ORGLOGSY] [nvarchar](10) NULL,
	[OTB_CURR] [nvarchar](5) NULL,
	[OTB_REASON] [nvarchar](3) NULL,
	[OTB_RES_VALUE] [decimal](17, 2) NULL,
	[OTB_SPEC_VALUE] [decimal](17, 2) NULL,
	[OTB_STATUS] [nvarchar](1) NULL,
	[OTB_VALUE] [decimal](17, 2) NULL,
	[PBEST] [nvarchar](10) NULL,
	[PEINH] [int] NULL,
	[PERIV] [nvarchar](2) NULL,
	[PLIEF] [nvarchar](10) NULL,
	[PLIWK] [nvarchar](10) NULL,
	[PREST] [nvarchar](10) NULL,
	[PSTYP] [nvarchar](1) NULL,
	[PWLIF] [nvarchar](10) NULL,
	[REC_TYPE] [nvarchar](1) NULL,
	[RESLO] [nvarchar](4) NULL,
	[RESWK] [nvarchar](4) NULL,
	[SCL_BEDAT] [date] NULL,
	[SHIPTO] [nvarchar](10) NULL,
	[SLFDT] [date] NULL,
	[SPR_RSN_PROFILE] [nvarchar](4) NULL,
	[STATU] [nvarchar](1) NULL,
	[SYDAT] [date] NULL,
	[TXZ01] [nvarchar](40) NULL,
	[UEBPO] [nvarchar](5) NULL,
	[UMREN] [int] NULL,
	[UMREZ] [int] NULL,
	[UZEIT] [nvarchar](6) NULL,
	[VLFKZ] [nvarchar](1) NULL,
	[WAERS] [nvarchar](5) NULL,
	[WEBRE] [nvarchar](1) NULL,
	[WEPOS] [nvarchar](1) NULL,
	[WERKS] [nvarchar](4) NULL,
	[WKURS] [decimal](9, 5) NULL,
	[XERSY] [nvarchar](1) NULL,
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
           ('L0_S4HANA_2LIS_02_SCL'
           ,'TEST'
           ,'curated/s4hana_theobald/cbp/2lis_02_scl_temp'
           ,0
           ,'SAP'
           ,'EBELN,EBELP,ETENR'
           ,'2024-01-01')



		update [MD].[MD_L0_LOAD_LIST]set [KeyColumns] = 'EBELN,EBELP,ETENR' where [TableName] = 'L0_S4HANA_2LIS_02_SCL'



		select top 100 ISNULL(BWMNG, 0) - ISNULL(DBWMNG, 0)
,* 
		from [TEST].[L0_S4HANA_2LIS_02_SCL] where ebeln = '4501020375'
		




		select top 100 [KTMNG],ebelp,MENGE,
* 
		from [TEST].[L0_S4HANA_2LIS_02_ITM] 
		where ebeln = '4501020375' and cast(matnr as int) = '10005399'

		SELECT * FROM
		[TEST].[L0_S4HANA_2LIS_02_SCN]
		where ebeln = '4501020375' and ebelp = '00010'



