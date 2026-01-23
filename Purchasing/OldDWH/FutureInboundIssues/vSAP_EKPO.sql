USE [CT dwh 01 Stage]
GO

/****** Object:  View [dbo].[vSAP_EKBE]    Script Date: 27/11/2025 11:10:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[vSAP_EKPO]
AS
	with cte_ekpo as(
		SELECT DISTINCT  
			[MATNR],
			TXZ01,
			MENGE,
			NETPR,
			NETWR,
			EBELP,
			EBELN,
			ZMM_MRD,
			ZMM_QC_DATE,
			ZMM_ETD,
			MANDT,
			WERKS,
			LGORT,
			LOEKZ,
			BUKRS
		FROM [CT dwh 01 Stage].dbo.[tSAP_EKPO_FULL]
),
 cte_itm as (
		
		SELECT DISTINCT  
			[MATNR],
			TXZ01,
			MENGE,
			NETPR,
			NETWR,
			EBELP,
			EBELN,
			ZMM_MRD,
			ZMM_QC_DATE,
			ZMM_ETD,
			MANDT = '100',
			WERKS,
			LGORT,
			LOEKZ  = CASE WHEN ITM.is_deleted = 1 THEN 'L' ELSE ITM.LOEKZ END,
			BUKRS
  FROM [CT dwh 02 Data].[dbo].[tSAP2LIS_02_ITM] ITM
  where is_current = 1
  and BSTYP = 'F'
  )
  SELECT 
			[MATNR]  = ISNULL(ekpo.[MATNR],itm.[MATNR]),
			TXZ01 = ISNULL(ekpo.TXZ01,itm.TXZ01),
			MENGE = ISNULL(ekpo.MENGE,itm.MENGE),
			NETPR = ISNULL(ekpo.NETPR,itm.NETPR),
			NETWR = ISNULL(ekpo.NETWR,itm.NETWR),
			EBELP = ISNULL(ekpo.EBELP,itm.EBELP),
			EBELN = ISNULL(ekpo.EBELN,itm.EBELN),
			ZMM_MRD = ISNULL(ekpo.ZMM_MRD,itm.ZMM_MRD),
			ZMM_QC_DATE = ISNULL(ekpo.ZMM_QC_DATE,itm.ZMM_QC_DATE),
			ZMM_ETD = ISNULL(ekpo.ZMM_ETD,itm.ZMM_ETD),
			MANDT  = ISNULL(ekpo.MANDT,itm.MANDT),
			WERKS  = ISNULL(ekpo.WERKS,itm.WERKS),
			LGORT = ISNULL(ekpo.LGORT,itm.LGORT),
			LOEKZ= ISNULL(ekpo.LOEKZ,itm.LOEKZ),
			BUKRS = ISNULL(ekpo.BUKRS,itm.BUKRS)
  FROM cte_ekpo ekpo
  FULL JOIN cte_itm itm
	on ekpo.MANDT = itm.MANDT
	AND ekpo.EBELN = itm.EBELN
	AND ekpo.EBELP = itm.EBELP



GO

