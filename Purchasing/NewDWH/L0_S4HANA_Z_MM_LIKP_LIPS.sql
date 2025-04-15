
CREATE TABLE [TEST].[L0_S4HANA_Z_MM_LIKP_LIPS](
	[VBELN] [nvarchar](10) NULL,
	[POSNR] [char](6) NULL,
	[ABLAD] [nvarchar](25) NULL,
	[AEDAT] [date] NULL,
	[ANZPK] [char](5) NULL,
	[AUFNR] [nvarchar](12) NULL,
	[BESTK] [nvarchar](1) NULL,
	[BLDAT] [date] NULL,
	[BOLNR] [nvarchar](35) NULL,
	[BTGEW] [numeric](15, 3) NULL,
	[BWART] [nvarchar](3) NULL,
	[CHARG] [nvarchar](10) NULL,
	[EAN11] [nvarchar](18) NULL,
	[ERDAT] [date] NULL,
	[ERDAT002] [date] NULL,
	[ERZET] [char](6) NULL,
	[FKDAT] [date] NULL,
	[FKSTK] [nvarchar](1) NULL,
	[FOLAR] [nvarchar](4) NULL,
	[GEWEI] [nvarchar](3) NULL,
	[GEWEI008] [nvarchar](3) NULL,
	[KDGRP] [nvarchar](2) NULL,
	[KNUMV] [nvarchar](10) NULL,
	[KODAT] [date] NULL,
	[KOKRS] [nvarchar](4) NULL,
	[KOQUK] [nvarchar](1) NULL,
	[KOSTK] [nvarchar](1) NULL,
	[KOSTL] [nvarchar](10) NULL,
	[KUNAG] [nvarchar](10) NULL,
	[KUNNR] [nvarchar](10) NULL,
	[LDDAT] [date] NULL,
	[LFART] [nvarchar](4) NULL,
	[LFDAT] [date] NULL,
	[LFIMG] [numeric](13, 3) NULL,
	[LFUHR] [char](6) NULL,
	[LGNUM] [nvarchar](3) NULL,
	[LGORT] [nvarchar](4) NULL,
	[LVSTK] [nvarchar](1) NULL,
	[MATKL] [nvarchar](9) NULL,
	[MATNR] [nvarchar](40) NULL,
	[MEINS] [nvarchar](3) NULL,
	[MTART] [nvarchar](4) NULL,
	[NTGEW] [numeric](15, 3) NULL,
	[PDSTK] [nvarchar](1) NULL,
	[PKSTK] [nvarchar](1) NULL,
	[POSNR_PP] [char](4) NULL,
	[POTIM] [char](6) NULL,
	[PRCTR] [nvarchar](10) NULL,
	[PSTYV] [nvarchar](4) NULL,
	[SGT_SCAT] [nvarchar](40) NULL,
	[SPART] [nvarchar](2) NULL,
	[SPE_LOEKZ] [nvarchar](1) NULL,
	[SPE_REV_VLSTK] [nvarchar](1) NULL,
	[TDDAT] [date] NULL,
	[TERNR] [nvarchar](12) NULL,
	[TRAGR] [nvarchar](4) NULL,
	[TRAGR005] [nvarchar](4) NULL,
	[TRAID] [nvarchar](20) NULL,
	[TRATY] [nvarchar](4) NULL,
	[UEBTK] [nvarchar](1) NULL,
	[UEBTO] [numeric](3, 1) NULL,
	[UMVKN] [numeric](5, 0) NULL,
	[UMVKZ] [numeric](5, 0) NULL,
	[UNTTO] [numeric](3, 1) NULL,
	[UVALL] [nvarchar](1) NULL,
	[UVFAK] [nvarchar](1) NULL,
	[UVPAK] [nvarchar](1) NULL,
	[UVPIK] [nvarchar](1) NULL,
	[UVVLK] [nvarchar](1) NULL,
	[UVWAK] [nvarchar](1) NULL,
	[VBTYP] [nvarchar](4) NULL,
	[VESTK] [nvarchar](1) NULL,
	[VGBEL] [nvarchar](10) NULL,
	[VGPOS] [char](6) NULL,
	[VGTYP] [nvarchar](4) NULL,
	[VKBUR] [nvarchar](4) NULL,
	[VKGRP] [nvarchar](3) NULL,
	[VKORG] [nvarchar](4) NULL,
	[VLSTK] [nvarchar](1) NULL,
	[VOLEH] [nvarchar](3) NULL,
	[VOLEH004] [nvarchar](3) NULL,
	[VOLUM] [numeric](15, 3) NULL,
	[VOLUM003] [numeric](15, 3) NULL,
	[VRKME] [nvarchar](3) NULL,
	[VSART] [nvarchar](2) NULL,
	[VSTEL] [nvarchar](4) NULL,
	[VTWEG] [nvarchar](2) NULL,
	[WADAT] [date] NULL,
	[WADAT_IST] [date] NULL,
	[WAERK] [nvarchar](5) NULL,
	[WBSTK] [nvarchar](1) NULL,
	[WERKS] [nvarchar](4) NULL,
	[WERKS006] [nvarchar](4) NULL,
	[XBLNR] [nvarchar](25) NULL,
	[LASTCHANGE_CDHDR] [numeric](15, 0) NULL,
	[TSTMP] [numeric](15, 0) NULL,
	[LIFNR] [nvarchar](10) NULL,
	[INCO1] [nvarchar](3) NULL,
	[INCO2] [nvarchar](28) NULL,
	[INCO2_L] [nvarchar](70) NULL,
	[INCO3_L] [nvarchar](70) NULL,
	[ZZ_ETAPORT] [date] NULL,
	[ZZ_LOESCHDATE] [date] NULL,
	[ZZ_TELEXREL] [date] NULL,
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
           ('L0_S4HANA_Z_MM_LIKP_LIPS'
           ,'TEST'
           ,'curated/s4hana_theobald/cbp/z_mm_likp_lips_v3'
           ,1
           ,'SAP'
           ,'VBELN,POSNR'
           ,'2024-01-01')


--select * from [MD].[MD_L0_LOAD_LIST] where tablename like '%LIKP%'