USE [CT dwh 01 Stage]
GO

/****** Object:  View [dbo].[vSAP_EKBE]    Script Date: 27/11/2025 11:10:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[vSAP_EKKO]
AS
	with cte_ekko as(
		SELECT DISTINCT  
			EKORG,
			BSART,
			WAERS,
			BEDAT,
			WKURS,
			EBELN,
			[ZTERM],
			[ZBD1T],
			[AEDAT],
			[WEAKT],
			MANDT = '100',
			BSTYP,
			LIFNR,
			BUKRS,
			KNUMV,
			LASTCHANGEDATETIME
		FROM [CT dwh 01 Stage].dbo.[tSAP_EKKO_FULL]
),
 cte_hdr as (
		
		SELECT DISTINCT  
			EKORG,
			BSART,
			WAERS,
			BEDAT,
			WKURS,
			EBELN,
			[ZZ_ZTERM],
			[ZZ_ZBD1T],
			[ZZ_AEDAT],
			[ZZ_WEAKT],
			MANDT = '100',
			BSTYP,
			LIFNR,
			BUKRS,
			KNUMV,
			ZZ_LASTCHANGEDATETIME 
  FROM [CT dwh 02 Data].[dbo].[tSAP2LIS_02_HDR]
  where is_current = 1 and 1=0
  )
  SELECT 
			EKORG  = ISNULL(ekko.EKORG,hdr.EKORG),
			BSART = ISNULL(ekko.BSART,hdr.BSART),
			WAERS = ISNULL(ekko.WAERS,hdr.WAERS),
			BEDAT = ISNULL(ekko.BEDAT,hdr.BEDAT),
			WKURS = ISNULL(ekko.WKURS,hdr.WKURS),
			EBELN = ISNULL(ekko.EBELN,hdr.EBELN),
			ZTERM = ISNULL(ekko.ZTERM,hdr.[ZZ_ZTERM]),
			ZBD1T = ISNULL(ekko.ZBD1T,hdr.[ZZ_ZBD1T]),
			AEDAT = ISNULL(ekko.AEDAT,hdr.[ZZ_AEDAT]),
			MANDT  = ISNULL(ekko.MANDT,hdr.MANDT),
			WEAKT  = ISNULL(ekko.WEAKT,hdr.[ZZ_WEAKT]),
			BSTYP = ISNULL(ekko.BSTYP,hdr.BSTYP),
			LIFNR= ISNULL(ekko.LIFNR,hdr.LIFNR),
			BUKRS= ISNULL(ekko.BUKRS,hdr.BUKRS),
			KNUMV= ISNULL(ekko.KNUMV,hdr.KNUMV),
			LASTCHANGEDATETIME= ISNULL(ekko.LASTCHANGEDATETIME,hdr.ZZ_LASTCHANGEDATETIME)

  FROM cte_ekko ekko
  FULL JOIN cte_hdr hdr
	on ekko.MANDT = hdr.MANDT
	AND ekko.EBELN = hdr.EBELN



GO



    --select MANDT,EBELN
    --FROM [CT dwh 01 Stage].[dbo].[vSAP_EKKO]
    --group by  MANDT,EBELN
    --having count(*) > 1
