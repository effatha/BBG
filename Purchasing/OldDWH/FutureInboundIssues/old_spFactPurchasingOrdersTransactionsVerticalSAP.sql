USE [CT dwh 02 Data]
GO
/****** Object:  StoredProcedure [dbo].[spFactPurchasingOrdersTransactionsVerticalSAP]    Script Date: 23/11/2025 17:40:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[spFactPurchasingOrdersTransactionsVerticalSAP] AS BEGIN
SET NOCOUNT ON;

-- quick fix to exclude deleted Deliverynotes (DWH-1126)

PRINT LTRIM(CAST(GETDATE() AS NVARCHAR(20))) + ' start!'

SELECT 
	LI.*
INTO #tSAPZ_MM_LIKP_LIPS
FROM [CT dwh 02 Data].[dbo].[tSAPZ_MM_LIKP_LIPS] AS LI WITH (NOLOCK) 
LEFT JOIN
(
	SELECT
		CAST(OBJECTID AS NVARCHAR(10)) AS OBJECTID
		, CAST(RIGHT(TABKEY,6) AS NVARCHAR(6)) AS POSNR
	FROM [CT dwh 02 Data].[dbo].[tSAPZ_MM_CDHDR_CDPOS_L] WITH (NOLOCK)
	WHERE 1 = 1
		AND is_current = 1
		AND CHNGIND = 'D'
		AND OBJECTCLAS = 'LIEFERUNG' 
		AND TABNAME IN ('LIKP', 'LIPS')
) AS CD_L
	ON LI.VBELN = CD_L.OBJECTID
	AND LI.POSNR = CD_L.POSNR
WHERE 1 = 1
	AND LI.is_current = 1
	AND CD_L.OBJECTID IS NULL

PRINT LTRIM(CAST(GETDATE() AS NVARCHAR(20))) + ' #tSAPZ_MM_LIKP_LIPS filled to exclude deleted Deliverynotes'

CREATE INDEX idx_#tSAPZ_MM_LIKP_LIPS ON #tSAPZ_MM_LIKP_LIPS (VBELN, VGBEL, VGPOS);

PRINT LTRIM(CAST(GETDATE() AS NVARCHAR(20))) + ' Index on #tSAPZ_MM_LIKP_LIPS created'

---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------

TRUNCATE TABLE [CT dwh 03 Intelligence].[dbo].[tFactPurchasingOrdersTransactionsVerticalSAP]

PRINT LTRIM(CAST(GETDATE() AS NVARCHAR(20))) + ' tFactPurchasingOrdersTransactionsVerticalSAP truncated'

MERGE [CT dwh 03 Intelligence].[dbo].[tFactPurchasingOrdersTransactionsVerticalSAP] AS t
USING (
        SELECT
            EKKO.EKORG                                             AS CompanyId
          , ISNULL(TTC.TransactionType, 'Other')                   AS TransactionType
          , ISNULL(EKKO.BSART, 'Bestellung Andere')                AS TransactionTypeDetail
          , RIGHT(EKPO.[MATNR], 8)                                 AS ItemNo
            -- , MARA.[MFRNR]                                           AS ModelName
          , TMP_ModelName.ModelName   AS ModelName
          , EKPO.TXZ01                AS [Description]
          , ph.ProductHierarchie1_txt AS ProductHierarchie1
          , ph.ProductHierarchie2_txt AS ProductHierarchie2
          , ph.ProductHierarchie3_txt AS ProductHierarchie3
          , brand.USER_VKMarke        AS Brand
          , MARA.MSTAE                AS EOL
          , T024.EKNAM                AS Dispatcher --/26.08.2020/FT: before: EKKO.EKGRP
          , MARA.VOLUM                AS Volume
          , MARA.LAENG                AS [Length]
          , MARA.BREIT                AS Width
          , MARA.HOEHE                AS Height
          , MARA.MTART                AS ItemType
          , EKKO.WAERS                AS Currency
          , EKKO.BEDAT                AS TransactionDate
          , EKPO.MENGE                AS Quantity
          , EKPO.NETPR                AS ItemPriceForeignCurrency
          , (EKPO.NETPR *
            CASE
                WHEN EKKO.WKURS < 0
                    THEN (1 / ABS(EKKO.WKURS))
                    ELSE ABS(EKKO.WKURS)
            END) AS ItemPrice
            --, case when EKPO.MENGE > 0 THEN (EKPO.NETPR * EKKO.WKURS)/EKPO.MENGE   eLSE 0 end                AS ItemPrice
          , EKPO.NETWR AS ValueForeignCurrency
            --, (ABS(EKPO.NETPR))             AS ValueForeignCurrency
          , (EKPO.NETWR *
            CASE
                WHEN EKKO.WKURS < 0
                    THEN (1 / ABS(EKKO.WKURS))
                    ELSE ABS(EKKO.WKURS)
            END) AS [Value]
            --, (ABS(EKPO.NETPR * EKKO.WKURS))       AS [Value]
          , CASE
                WHEN EKKO.WKURS < 0
                    THEN (1 / ABS(EKKO.WKURS))
                    ELSE ABS(EKKO.WKURS)
            END AS ExchangeRate
            -- hier wechseln wir von BUDAT auf BEDAT
          , EKKO.BEDAT AS PostingDate
            --, EKKO.EBELN                                             AS DocumentNo // FT am 23.07.2020
            -- lt. https://jira.chal-tec.com/browse/DEVTCK-16637 soll EKKO.EBELN nun die ProcessID sein
          , EKKO.EBELN       AS ProcessID
          , EKPO.EBELP       AS ProcessPosition -- FT: 07.08.2020
          , EKPO.EBELN       AS DocumentNo
          , EKPO.ZMM_MRD     AS MaterialReadyDate
          , EKPO.ZMM_QC_DATE AS PlannedQCDate
		  --  24.09.2020/FT: nach Rücksprache mit Michael implementiert. Falsche Werte durch SAP
         -- , case when TRY_CONVERT(datetime, EKPO.ZMM_ETD) IS NOT NULL THEN EKPO.ZMM_ETD ELSE NULL End     AS PlannedETD
		  , EKPO.ZMM_ETD as PlannedETD
		  --  24.09.2020/FT: nach Rücksprache mit Michael implementiert. Falsche Werte durch SAP
          --, case when TRY_CONVERT(datetime, EKPO.ZMM_ETD) IS NOT NULL THEN EKPO.ZMM_ETD ELSE NULL end     AS ETD
		  --, EKPO.ZMM_ETD as ETD --changed
		  ,LIS.[ZZETD] as ETD	--changed
          , EKKO.[ZTERM]     AS Paymentterms
          , ITM.[ZZ_INCO1]   AS Incoterms
          , LFA1.[NAME1]     AS CreditorsName
          , SAP_MARA.MATKL   AS SupplierCode --LFA1.[SORTL]     AS SupplierCode --20.08.2020/FT: Ticket 17074 -> comes from tSAP_MARA.MATKL
          , LFB1.[ALTKN]     AS CreditorsNumber
          , LFB1.[FRGRP]     AS SupplierGroupNumber
            --, CASE
            --      WHEN EKES.[EBTYP] = 'Z3'
            --          THEN -1
            --          ELSE 0
            --  END AS DeliveryAdvise
          , case
                when
                    (
                        select
                            EBTYP
                        from
                            (
                                SELECT
                                    top 1 EBTYP
                                FROM
                                    [CT dwh 01 Stage].[dbo].[tSAP_EKES] AS EKES WITH (NOLOCK)
                                where
                                    EKPO.MANDT     = EKES.MANDT
                                    AND EKPO.EBELN = EKES.EBELN
                                    and EKES.ebtyp = 'Z3'
                            )
                            as x
                    )
                    = 'Z3'
                    then -1
                    else 0
            end                                    AS DeliveryAdvise
          , DATEADD(DAY, EKKO.ZBD1T, EKPO.ZMM_ETD) AS DueDate
		  --  24.09.2020/FT: nach Rücksprache mit Michael implementiert. Falsche Werte durch SAP
		  --, case when TRY_CONVERT(datetime, EKPO.ZMM_ETD) IS NOT NULL THEN DATEADD(DAY, EKKO.ZBD1T, EKPO.ZMM_ETD) ELSE NULL end AS DueDate
            /*
            , CASE
            WHEN EKES.[EBTYP] = 'Z3'
            THEN -1
            ELSE 0
            END AS BookingConfirmed
            */
          , case
                when
                    (
                        select
                            EBTYP
                        from
                            (
                                SELECT
                                    top 1 EBTYP
                                FROM
                                    [CT dwh 01 Stage].[dbo].[tSAP_EKES] AS EKES WITH (NOLOCK)
                                where
                                    EKPO.MANDT     = EKES.MANDT
                                    AND EKPO.EBELN = EKES.EBELN
                                    and EKES.ebtyp = 'Z3'
                            )
                            as x
                    )
                    = 'Z3'
                    then -1
                    else 0
            end as BookingConfirmed
          --, CASE --changed 
          --      WHEN LIKP.[ZZ_ETAPORT] < '1753-01-01'
          --          THEN '1753-01-01'
          --          ELSE LIKP.[ZZ_ETAPORT]
          --  END AS ETAPort
          , CASE 
                WHEN LIS.[ZZETA] < '1753-01-01'
                    THEN '1753-01-01'
                    ELSE LIS.[ZZETA]
            END AS ETAPort
          , CASE
                WHEN TTC.TransactionType = 'DeliveryNote'
                    THEN LIKP.[TRAID]
                    ELSE NULL
            END            AS ContainerNumber
          , ITM.[ZZ_DPPCT] AS PercentageDesposit
		  /* https://jira.chal-tec.com/browse/DEVTCK-17312
          , CASE
                WHEN ITM.[ZZ_DPTYP] = 'V'
                    THEN ITM.[ZZ_INCO2_L]
                    ELSE NULL
            END AS OutboundHarbour
          , CASE
                WHEN ITM.[ZZ_DPTYP] = 'N'
                    THEN ITM.[ZZ_INCO2_L]
                    ELSE NULL
            END AS InboundHarbour
			*/
		  , LIKP.INCO2_L as OutboundHarbour
		  , LIKP.INCO3_L as InboundHarbour
          , (ROW_NUMBER() OVER (PARTITION BY
                                CASE
                                    WHEN EKKO.EKORG = ''
                                        THEN '1000'
                                        ELSE EKKO.EKORG
                                END, TTC.TransactionType, EKKO.EBELN, MARA.[MATNR] ORDER BY
                                EKKO.BEDAT)) AS PositionIdRC
          , EKET.EINDT                       as ETAWarehouse
		  -- //26.08.2020/FT: https://jira.chal-tec.com/browse/DEVTCK-17112
           /*,
		  case
                when PRCD_ZCU2.KKURS < 0
                    then PRCD_ZCU2.KAWRT/PRCD_ZCU2.KKURS
                    else case
                when PRCD_ZCU2.KKURS > 0
                    then PRCD_ZCU2.KAWRT*PRCD_ZFV1.KKURS
                    else PRCD_ZCU2.KAWRT
            end
            end as ImportDutiesPlan
          , case
                when PRCD_ZFKV.KKURS < 0
                    then PRCD_ZFKV.KAWRT/PRCD_ZFKV.KKURS
                    else case
                when PRCD_ZFKV.KKURS > 0
                    then PRCD_ZFKV.KAWRT*PRCD_ZFV1.KKURS
                    else PRCD_ZFKV.KAWRT
            end
            end as SeaFreightPlan
          , case
                when PRCD_ZFV1.KKURS < 0
                    then PRCD_ZFV1.KAWRT/PRCD_ZFV1.KKURS
                    else case
                when PRCD_ZFV1.KKURS > 0
                    then PRCD_ZFV1.KAWRT*PRCD_ZFV1.KKURS
                    else PRCD_ZFV1.KAWRT
            end 
            end as OperationCostPlan
		 */
		 ,case
                when PPR0.KKURS < 0
                    then PRCD_ZCU2.KWERT/ABS(PPR0.KKURS)
                    else case
                when PPR0.KKURS > 0
                    then PRCD_ZCU2.KWERT*PPR0.KKURS
                    else PRCD_ZCU2.KWERT
            end
            end as ImportDutiesPlan
          , case
                when PPR0.KKURS < 0
                    then PRCD_ZFKV.KWERT/ABS(PPR0.KKURS)
                    else case
                when PPR0.KKURS > 0
                    then PRCD_ZFKV.KWERT*PPR0.KKURS
                    else PRCD_ZFKV.KWERT
            end
            end as SeaFreightPlan
          , case
                when PPR0.KKURS < 0
                    then PRCD_ZFV1.KWERT/ABS(PPR0.KKURS)
                    else case
                when PPR0.KKURS > 0
                    then PRCD_ZFV1.KWERT*PPR0.KKURS
                    else PRCD_ZFV1.KWERT
            end 
            end as OperationCostPlan
		, PRCD_ZCU2.KWERT as ImportDutiesPlanFC
		, PRCD_ZFKV.KWERT as SeaFreightPlanFC
		, PRCD_ZFV1.KWERT as OperationCostPlanFC
		--, CASE --changed
  --              WHEN EKKO.EKORG = '1000' OR EKKO.EKORG = ''
  --                  THEN left(EM_F06.message, 80)
  --                  ELSE NULL
  --          END              AS ForwarderReference
		, CASE 
                WHEN EKKO.EKORG = '1000' OR EKKO.EKORG = ''
                    THEN left(LIS.[ZZFORWARDER_REF], 80)
                    ELSE NULL
            END              AS ForwarderReference
		--, CASE	--changed
  --              WHEN EKKO.EKORG = '1000' OR EKKO.EKORG = ''
  --                  THEN left(EM_F01.message, 80)
  --                  ELSE NULL
  --          END AS SupplierReference
		, CASE
                WHEN EKKO.EKORG = '1000' OR EKKO.EKORG = ''
                    THEN left(LIS.[ZZSUPPLIER_REF], 80)
                    ELSE NULL
            END AS SupplierReference
		, EKKO.AEDAT as ProcessIDCreationDate
		,	CONVERT(datetime, 
			  SUBSTRING(cast([LASTCHANGEDATETIME] as varchar), 1, 4) + '-' 
			+ SUBSTRING(cast([LASTCHANGEDATETIME] as varchar), 5, 2) + '-' 
			+ SUBSTRING(cast([LASTCHANGEDATETIME] as varchar), 7, 2) + ' ' 
			+ SUBSTRING(cast([LASTCHANGEDATETIME] as varchar), 9, 2) + ':'
			+ SUBSTRING(cast([LASTCHANGEDATETIME] as varchar), 11, 2) + ':' 
			+ SUBSTRING(cast([LASTCHANGEDATETIME] as varchar), 13, 2), 120) AS ProcessIDLastChangeDate 
		, CASE WHEN EKKO.WEAKT='X' THEN -1 ELSE 0 END as ProcessFulfilled
		--, left(EM_F05.message, 50) as Forwarder	--changed	--> https://jira.chal-tec.com/browse/DEVTCK-17452
		, EKPA.[TEXT_EKPA_LIFN2] as Forwarder
		, NULL as DeliveryNoteStatus
		, EKPO.WERKS as Plant
		, MARC_CC.STAWN as CommodityCode
		, EKPO.LGORT as StorageLocation
		, LIS.[ZZKONNR] as ContractNumber				--changed
		, LIS.[ZZPORT_OF_DISCHARG] as PortOfDischarg	--changed
		, LIS.[ZZPORT_OF_LOADING] as PortOfLoading		--changed
		, LIS .[ZZTRANSPORT_MODE] as TransportMode		--changed
        FROM
           ( SELECT DISTINCT * FROM [CT dwh 01 Stage].[dbo].[tSAP_EKPO]  WITH (NOLOCK) )AS EKPO 
            INNER JOIN
              ( SELECT DISTINCT * FROM [CT dwh 01 Stage].[dbo].[tSAP_EKKO]  WITH (NOLOCK) )AS EKKO
                ON
                    EKPO.EBELN = EKKO.EBELN
					and EKPO.MANDT = EKKO.MANDT
            INNER JOIN
                [CT dwh 00 Meta].[dbo].[tTransactionTypesConfigSAP] AS TTC WITH (NOLOCK)
                ON
                    EKKO.BSTYP     = TTC.BSTYP
                    AND EKKO.BSART = TTC.BSART
			LEFT JOIN	--changed
                 [CT dwh 02 Data].[dbo].[tSAPZ_MM_EKPA] AS EKPA WITH (NOLOCK)
                ON
                    EKPA.EBELN	= EKPO.EBELN
					AND EKPA.EBELP = '00000'
					AND EKPA.PARVW = 'FS' --changed
					AND EKPA.is_current = 1 --changed
			LEFT JOIN	--changed
                 [CT dwh 02 Data].[dbo].[tSAP2LIS_02_HDR] AS LIS WITH (NOLOCK)
                ON
                    LIS.EBELN	= EKKO.EBELN
					AND LIS.is_current = 1 --changed
				
            LEFT JOIN
                 [CT dwh 01 Stage].[dbo].[tSAP_MATERIAL_ATTR] AS MARA WITH (NOLOCK)
                ON
                    MARA.MATNR = EKPO.MATNR
            LEFT JOIN
                (
                    SELECT
                        MATNR
					  , MANDT
                      , IDNLF AS ModelName
                      , ROW_NUMBER() OVER (PARTITION BY MATNR,MANDT ORDER BY
                                           INFNR DESC) AS Anzahl
                    FROM
                        [CT dwh 01 Stage].[dbo].[tSAP_EINA] WITH (NOLOCK)
                    WHERE
                        1 = 1
                )
                AS TMP_ModelName
                ON
                    MARA.MATNR               = TMP_ModelName.MATNR
                    AND TMP_ModelName.Anzahl = 1
            LEFT JOIN
                 [CT dwh 01 Stage].[dbo].[tSAP_LFA1] AS LFA1 WITH (NOLOCK)
                ON
                    EKKO.MANDT     = LFA1.MANDT
                    AND EKKO.LIFNR = LFA1.LIFNR
            LEFT JOIN
                 [CT dwh 01 Stage].[dbo].[tSAP_LFB1] AS LFB1 WITH (NOLOCK)
                ON
                    EKKO.MANDT     = LFB1.MANDT
                    AND EKKO.LIFNR = LFB1.LIFNR
					and EKKO.BUKRS = LFB1.BUKRS
            LEFT JOIN
                (
                    SELECT
                        MANDT
                      , EBELN
                      , EBELP
                      , ETENS
                      , EBTYP
                      , VBELN
                      , ROW_NUMBER() OVER (PARTITION BY MANDT, EBELN, EBELP ORDER BY
                                           ETENS DESC) AS IdRC
                    FROM
                         [CT dwh 01 Stage].[dbo].[tSAP_EKES] AS EKES WITH (NOLOCK)
                )
                AS EKES
                ON
                    EKPO.MANDT     = EKES.MANDT
                    AND EKPO.EBELN = EKES.EBELN
                    AND EKPO.EBELP = EKES.EBELP
                    /* Wähle immer den letzten Eintrag, daher ORDER BY DESC */
                    AND EKES.IdRC = 1
            LEFT JOIN
					(
					SELECT DISTINCT
						VBELN
						, INCO2_L
						, INCO3_L
						, TRAID
					FROM #tSAPZ_MM_LIKP_LIPS WITH (NOLOCK)
					WHERE 1 = 1
					) AS LIKP
                    ON EKES.VBELN = LIKP.VBELN
            LEFT JOIN
                (
                    SELECT distinct
                        BUKRS
                      , EBELN
                      , EBELP
                      , [ZZ_INCO1]   -- Incoterms
                      , [ZZ_DPTYP]   -- N: Inbound, V: Outboundtyp
                      , [ZZ_DPPCT]   -- PercentageDesposit
                      , [ZZ_INCO2_L] -- OutboundHarbour
					  , [ZZ_INCO3_L] -- InboundHarbour
                    FROM
                        [CT dwh 02 Data].[dbo].[tSAP2LIS_02_ITM] with (nolock)
					WHERE 1 = 1
					AND is_current = 1
                )
                AS ITM
                ON
                    EKPO.BUKRS     = ITM.BUKRS
                    AND EKPO.EBELN = ITM.EBELN
                    AND EKPO.EBELP = ITM.EBELP
            LEFT JOIN
                [CT dwh 02 Data].[dbo].[vProductHierarchieSAP] ph with (nolock)
                on
                    MARA.PRDHA = ph.ProductHierarchie3
            LEFT JOIN
                (
                    SELECT
                        Artikelnummer
                      , USER_VKMarke
                    FROM
                        [CT dwh 02 Data].[dbo].[tErpKHKArtikel] AS Art WITH (NOLOCK)
                    WHERE
                        1                          = 1
                        AND Mandant                = 1
                        AND Artikelnummer       LIKE '[17]%'
                        AND USER_VKMarke IS NOT NULL
                )
                brand
                on
                    RIGHT(EKPO.MATNR, 8) = brand.Artikelnummer
            LEFT JOIN
                ( SELECT DISTINCT * FROM [CT dwh 01 Stage].[dbo].[tSAP_EKET]  with (nolock)) EKET
                on
                    EKET.MANDT     = EKPO.MANDT
                    AND EKET.EBELN = EKPO.EBELN
                    AND EKET.EBELP = EKPO.EBELP
            LEFT JOIN
                 [CT dwh 01 Stage].[dbo].[tSAP_MARA] SAP_MARA with (nolock)
                on
                    EKPO.MANDT     = SAP_MARA.MANDT
                    AND EKPO.MATNR = SAP_MARA.MATNR
			LEFT JOIN
				 [CT dwh 01 Stage].[dbo].[tSAP_MARC] MARC with (nolock)
				on
					EKPO.MATNR	= MARC.MATNR
					AND MARC.WERKS in ('1000', '1100') -- //15.10.2020 DEVTCK-17593
					AND EKPO.WERKS = MARC.WERKS
			LEFT JOIN -- look at: https://jira.chal-tec.com/browse/DEVTCK-17659
				 [CT dwh 01 Stage].[dbo].[tSAP_MARC] MARC_CC with (nolock)
				on
					EKPO.MATNR	= MARC_CC.MATNR
					AND MARC_CC.WERKS in ('1000')
			LEFT JOIN
				 [CT dwh 01 Stage].[dbo].[tSAP_T024] T024 with (nolock)
				on
					MARC.EKGRP		= T024.EKGRP
					AND EKKO.MANDT	= T024.MANDT
			LEFT JOIN (select MAX(ZAEHK) over (partition by KNUMV, KPOSN, KSCHL) as ZAEHK_MAX, KNUMV, KPOSN, ZAEHK, KKURS, KAWRT, KWERT
						from  [CT dwh 01 Stage].[dbo].[tSAP_PRCD_ELEMENTS] with (nolock) where KSCHL = 'ZCU2') as PRCD_ZCU2
				on
					PRCD_ZCU2.ZAEHK_MAX				= PRCD_ZCU2.ZAEHK 
					AND PRCD_ZCU2.KNUMV				= EKKO.KNUMV 
					AND right(PRCD_ZCU2.KPOSN,5)	= EKPO.EBELP
			LEFT JOIN (select MAX(ZAEHK) over (partition by KNUMV, KPOSN, KSCHL) as ZAEHK_MAX, KNUMV, KPOSN, ZAEHK, KKURS, KAWRT, KWERT
						from [CT dwh 01 Stage].[dbo].[tSAP_PRCD_ELEMENTS] with (nolock) where KSCHL = 'ZFKV') as  PRCD_ZFKV
				on
					PRCD_ZFKV.ZAEHK_MAX				= PRCD_ZFKV.ZAEHK  
					AND PRCD_ZFKV.KNUMV				= EKKO.KNUMV 
					AND right(PRCD_ZFKV.KPOSN,5)	= EKPO.EBELP
			LEFT JOIN (select MAX(ZAEHK) over (partition by KNUMV, KPOSN, KSCHL) as ZAEHK_MAX, KNUMV, KPOSN, ZAEHK, KKURS, KAWRT, KWERT
						from  [CT dwh 01 Stage].[dbo].[tSAP_PRCD_ELEMENTS] with (nolock) where KSCHL = 'ZFV1') as PRCD_ZFV1
				on
					PRCD_ZFV1.ZAEHK_MAX				= PRCD_ZFV1.ZAEHK  
					AND PRCD_ZFV1.KNUMV				= EKKO.KNUMV 
					AND right(PRCD_ZFV1.KPOSN,5)	= EKPO.EBELP
			LEFT JOIN (select MAX(ZAEHK) over (partition by KNUMV, KPOSN, KSCHL) as ZAEHK_MAX, KNUMV, KPOSN, ZAEHK, KKURS, KAWRT, KWERT
						from  [CT dwh 01 Stage].[dbo].[tSAP_PRCD_ELEMENTS] with (nolock) where KSCHL = 'PPR0') as PPR0
				on
					PPR0.ZAEHK_MAX				= PPR0.ZAEHK  
					AND PPR0.KNUMV				= EKKO.KNUMV 
					AND right(PPR0.KPOSN,5)		= EKPO.EBELP
			LEFT JOIN (Select message, EBELB, MANDT FROM [CT dwh 01 Stage].[dbo].[tSAP_EKKO_messages] with (nolock) where TextID = 'F06') AS EM_F06
				on EKKO.EBELN = EM_F06.EBELB
					AND EKKO.MANDT = EM_F06.MANDT
			LEFT JOIN (Select message, EBELB, MANDT FROM [CT dwh 01 Stage].[dbo].[tSAP_EKKO_messages] with (nolock) where TextID = 'F01') AS EM_F01
				on EKKO.EBELN = EM_F01.EBELB
					AND EKKO.MANDT = EM_F01.MANDT
			LEFT JOIN (Select message, EBELB, MANDT FROM [CT dwh 01 Stage].[dbo].[tSAP_EKKO_messages] with (nolock) where TextID = 'F05') AS EM_F05
				on EKKO.EBELN = EM_F05.EBELB
				AND EKKO.MANDT = EM_F05.MANDT
        WHERE
            1 = 1
            AND EKPO.LOEKZ not in ('L'
                                 , 'X') --//Anforderung: DEVTCK-17066
        UNION ALL
        -- andere DocmentTypes (außer DeliveryNotes, die kommen extra)
        SELECT
            NULL                                                        AS CompanyId
          , ISNULL(TTC.TransactionType, 'Other')                        AS TransactionType
          , ISNULL(TTC.TransactionTypeDetail, 'Bestellung Andere EKBE') AS TransactionTypeDetail
          , RIGHT(EKBE.[MATNR], 8)                                      AS ItemNo
            --, MARA.[MFRNR]                                                AS ModelName
          , TMP_ModelName.ModelName   AS ModelName
          , ''                        AS [Description]
          , ph.ProductHierarchie1_txt AS ProductHierarchie1
          , ph.ProductHierarchie2_txt AS ProductHierarchie2
          , ph.ProductHierarchie3_txt AS ProductHierarchie3
          , brand.USER_VKMarke        AS Brand
          , MARA.MSTAE                AS EOL
          , ''                        AS Dispatcher
          , MARA.VOLUM                AS Volume
          , MARA.LAENG                AS [Length]
          , MARA.BREIT                AS Width
          , MARA.HOEHE                AS Height
          , MARA.MTART                AS ItemType
          , EKBE.WAERS                AS Currency
          , CASE
                WHEN TTC.TransactionType = 'StockReceipt'
                    THEN EKBE.BUDAT
                    ELSE EKBE.BLDAT
            END                       AS TransactionDate
          , EKBE.MENGE                AS Quantity
          , case
                when EKBE.MENGE > 0
                    then EKBE.WRBTR/EKBE.MENGE
                    ELSE 0
            end AS ItemPriceForeignCurrency
            --, EKBE.BPMNG                                                  AS ItemPriceForeignCurrency
          , case
                when EKBE.MENGE > 0
                    then EKBE.DMBTR/EKBE.MENGE
                    ELSE 0
            end AS ItemPrice
            --, case when EKBE.MENGE > 0 then EKBE.DMBTR/EKBE.MENGE ELSE 0 end AS ItemPrice
          , (EKBE.WRBTR) AS ValueForeignCurrency
            --, (ABS(EKBE.WRBTR))           AS ValueForeignCurrency
          , (EKBE.DMBTR) AS [Value]
            --, (ABS(EKBE.DMBTR))           AS [Value]
          , ABS(EKBE.WKURS) AS ExchangeRate
          , EKBE.BUDAT      AS PostingDate
            --, EKBE.EBELN                                                  AS DocumentNo // FT am 23.07.2020
            -- lt. https://jira.chal-tec.com/browse/DEVTCK-16637 soll EKKO.EBELN nun die ProcessID sein
          , EKBE.EBELN AS ProcessID
          , EKBE.EBELP AS ProcessPosition -- FT: 07.08.2020
          , EKBE.BELNR AS DocumentNo
          , NULL       AS MaterialReadyDate
          , NULL       AS PlannedQCDate
          , NULL       AS PlannedETD
          , NULL       AS ETD
          , NULL       AS Paymentterms
          , NULL       AS Incoterms
          , NULL       AS CreditorsName
          , NULL       AS SupplierCode
          , NULL       AS CreditorsNumber
          , NULL       AS SupplierGroupNumber
            --, CASE
            --      WHEN EKES.[EBTYP] = 'Z3'
            --          THEN -1
            --          ELSE 0
            --  END AS DeliveryAdvise
          , case
                when
                    (
                        select
                            EBTYP
                        from
                            (
                                SELECT
                                    top 1 EBTYP
                                FROM
                                    [CT dwh 01 Stage].[dbo].[tSAP_EKES] AS EKES WITH (NOLOCK)
                                where
                                    EKBE.MANDT     = EKES.MANDT
                                    AND EKBE.EBELN = EKES.EBELN
                                    and ekes.ebtyp = 'Z3'
                            )
                            as x
                    )
                    = 'Z3'
                    then -1
                    else 0
            end  as DeliveryAdvise
          , NULL AS DueDate
            /*,CASE
            WHEN EKES.[EBTYP] = 'Z3'
            THEN -1
            ELSE 0
            END AS BookingConfirmed
            */
          , case
                when
                    (
                        select
                            EBTYP
                        from
                            (
                                SELECT
                                    top 1 EBTYP
                                FROM
                                    [CT dwh 01 Stage].[dbo].[tSAP_EKES] AS EKES WITH (NOLOCK)
                                where
                                    EKBE.MANDT     = EKES.MANDT
                                    AND EKBE.EBELN = EKES.EBELN
                                    and ekes.ebtyp = 'Z3'
                            )
                            as x
                    )
                    = 'Z3'
                    then -1
                    else 0
            end as BookingConfirmed
          , CASE 
                WHEN LIS.[ZZETA] < '1753-01-01'
                    THEN '1753-01-01'
                    ELSE LIS.[ZZETA]
            END AS ETAPort
		  /*
		  changed on 21.12.2021/FT: https://jira.chal-tec.com/browse/DEVTCK-20904
		  CASE
                WHEN LIKP.[ZZ_ETAPORT] < '1753-01-01'
                    THEN '1753-01-01'
                    ELSE LIKP.[ZZ_ETAPORT]
            END AS ETAPort
			*/
          , CASE
                WHEN TTC.TransactionType = 'DeliveryNote'
                    THEN LIKP.[TRAID]
                    ELSE NULL
            END  AS ContainerNumber
          , NULL AS PercentageDesposit
          , NULL AS OutboundHarbour
          , NULL AS InboundHarbour
          , (ROW_NUMBER() OVER (PARTITION BY
                                CASE
                                    WHEN EKBE.WERKS = ''
                                        THEN '1000'
                                        ELSE EKBE.WERKS
                                END, TTC.TransactionType, EKBE.EBELN, EKBE.[MATNR] ORDER BY
                                EKBE.BUDAT)) AS PositionIdRC
          , EKET.EINDT                       as ETAWarehouse
		  , NULL as ImportDutiesPlan
		  , NULL as SeaFreightPlan
		  , NULL as OperationCostPlan
		  , NULL as ImportDutiesPlanFC
		  , NULL as SeaFreightPlanFC
		  , NULL as OperationCostPlanFC
		  , NULL AS ForwarderReference
		  , NULL AS SupplierReference
		  , NULL AS ProcessIDCreationDate
		  , NULL AS ProcessIDLastChangeDate
		  , NULL AS ProcessFulfilled
		  , NULL as Forwarder
		  , NULL as DeliveryNoteStatus
		  , EKBE.WERKS as Plant
		  , NULL as CommunityCode
		  , NULL as StorageLocation
		  , NULL as ContractNumber		--changed
		  , NULL as PortOfDischarg		--changed
		  , NULL as PortOfLoading		--changed
		  , NULL as TransportMode		--changed
        FROM
            [CT dwh 01 Stage].[dbo].[vSAP_EKBE] AS EKBE WITH (NOLOCK) 
            INNER JOIN
                [CT dwh 00 Meta].[dbo].[tTransactionTypesConfigSAPEKBE] AS TTC WITH (NOLOCK)
                ON
                    (
                        EKBE.VGABE     = TTC.VGABE
                        AND EKBE.BWART = ISNULL(TTC.BWART,'')
                        AND EKBE.SHKZG = ISNULL(TTC.SHKZG,'')
                    )
            LEFT JOIN
                 [CT dwh 01 Stage].[dbo].[tSAP_MATERIAL_ATTR] AS MARA WITH (NOLOCK)
                ON
                    MARA.MATNR = EKBE.MATNR
            LEFT JOIN
                (
                    SELECT
                        MATNR
					  , MANDT
                      , IDNLF AS ModelName
                      , ROW_NUMBER() OVER (PARTITION BY MATNR ORDER BY
                                           INFNR DESC) AS Anzahl
                    FROM
                        [CT dwh 01 Stage].[dbo].[tSAP_EINA] WITH (NOLOCK)
                    WHERE
                        1 = 1
                )
                AS TMP_ModelName
                ON
                    MARA.MATNR               = TMP_ModelName.MATNR
                    AND TMP_ModelName.Anzahl = 1
					AND EKBE.MANDT			 = TMP_ModelName.MANDT
            LEFT JOIN
                (
                    SELECT
                        MANDT
                      , EBELN
                      , EBELP
                      , ETENS
                      , EBTYP
                      , VBELN
                      , ROW_NUMBER() OVER (PARTITION BY MANDT, EBELN, EBELP ORDER BY
                                           ETENS DESC) AS IdRC
                    FROM
                         [CT dwh 01 Stage].[dbo].[tSAP_EKES] AS EKES WITH (NOLOCK)
                )
                AS EKES
                ON
                    EKBE.MANDT     = EKES.MANDT
                    AND EKBE.EBELN = EKES.EBELN
                    AND EKBE.EBELP = EKES.EBELP
                    AND EKES.IdRC  = 1
					AND EKBE.ETENS = EKES.ETENS
            LEFT JOIN
					(
					SELECT DISTINCT
						VBELN
						, TRAID
					FROM #tSAPZ_MM_LIKP_LIPS WITH (NOLOCK)
					WHERE 1 = 1
					) AS LIKP
                    ON EKES.VBELN = LIKP.VBELN
			LEFT JOIN	--changed on 21.12.2021/FT: https://jira.chal-tec.com/browse/DEVTCK-20904
                 [CT dwh 02 Data].[dbo].[tSAP2LIS_02_HDR] AS LIS WITH (NOLOCK)
                ON
                    LIS.EBELN	= EKES.EBELN
					AND LIS.is_current = 1 --changed
            LEFT JOIN
                [CT dwh 02 Data].[dbo].[vProductHierarchieSAP] ph with (nolock)
                on
                    MARA.PRDHA = ph.ProductHierarchie3
            LEFT JOIN
                (
                    SELECT
                        Artikelnummer
                      , USER_VKMarke
                    FROM
                        [CT dwh 02 Data].[dbo].[tErpKHKArtikel] AS Art WITH (NOLOCK)
                    WHERE
                        1                          = 1
                        AND Mandant                = 1
                        AND Artikelnummer       LIKE '[17]%'
                        AND USER_VKMarke IS NOT NULL
                )
                brand
                on
                    RIGHT(EKBE.MATNR, 8) = brand.Artikelnummer
            LEFT JOIN
                ( SELECT DISTINCT * FROM [CT dwh 01 Stage].[dbo].[tSAP_EKET]  with (nolock)) EKET
            on
                    EKET.MANDT     = EKBE.MANDT
                    AND EKET.EBELN = EKBE.EBELN
                    AND EKET.EBELP = EKBE.EBELP		
        WHERE
            TTC.VGABE not in ('8') -- DeliveryNotes müssen wir extra behandeln -> Ticket 17100 vom 20.08.2020
        
		UNION ALL
        SELECT
            NULL    	                                                AS CompanyId
          , ISNULL(TTC.TransactionType, 'Other')                        AS TransactionType
          , ISNULL(TTC.TransactionTypeDetail, 'Bestellung Andere EKBE') AS TransactionTypeDetail
          , RIGHT(LIKP_LIPS.[MATNR], 8)                                      AS ItemNo
          , NULL                                                        AS ModelName
          , ''                                                          AS [Description]
          , NULL                                                        AS ProductHierarchie1
          , NULL                                                        AS ProductHierarchie2
          , NULL                                                        AS ProductHierarchie3
          , NULL                                                        AS Brand
          , NULL                                                        AS EOL
          , ''                                                          AS Dispatcher
          , NULL                                                        AS Volume
          , NULL                                                        AS [Length]
          , NULL                                                        AS Width
          , NULL                                                        AS Height
          , NULL                                                        AS ItemType
          , NULL                                                        AS Currency
          , LIKP_LIPS.ERDAT                                                  AS TransactionDate
          , LIKP_LIPS.LFIMG                                                  AS Quantity
          , 0                                                           AS ItemPriceForeignCurrency
          , 0                                                           AS ItemPrice
          , 0                                                           AS ValueForeignCurrency
          , 0                                                           AS [Value]
          , 0                                                           AS ExchangeRate
          , NULL                                                        AS PostingDate
          , LIKP_LIPS.VGBEL                                                  AS ProcessID
          , RIGHT(LIKP_LIPS.VGPOS, 5)                                        AS ProcessPosition -- FT: 07.08.2020  -- kommt 6 stellig aus der LIPS.VGPOS
          , LIKP_LIPS.VBELN                                                  AS DocumentNo
          , NULL                                                        AS MaterialReadyDate
          , NULL                                                        AS PlannedQCDate
          , NULL                                                        AS PlannedETD
          , NULL                                                        AS ETD
          , NULL                                                        AS Paymentterms
          , NULL                                                        AS Incoterms
          , NULL                                                        AS CreditorsName
          , NULL                                                        AS SupplierCode
          , NULL                                                        AS CreditorsNumber
          , NULL                                                        AS SupplierGroupNumber
          , NULL                                                        AS DeliveryAdvise
          , NULL                                                        AS DueDate
          , NULL                                                        AS BookingConfirmed
          , NULL                                                        AS ETAPort
          , LIKP_LIPS.[TRAID]                                                AS ContainerNumber
          , NULL                                                        AS PercentageDesposit
          , NULL                                                        AS OutboundHarbour
          , NULL                                                        AS InboundHarbour
          , (ROW_NUMBER() OVER (PARTITION BY
                                CASE
                                    WHEN LIKP_LIPS.WERKS006 = ''
                                        THEN '1000'
                                        ELSE LIKP_LIPS.WERKS006
                                END, TTC.TransactionType, LIKP_LIPS.VBELN, LIKP_LIPS.[MATNR] ORDER BY
                                LIKP_LIPS.VGPOS)) AS PositionIdRC
          , NULL                             AS ETAWarehouse
		  , NULL														AS ImportDutiesPlan
		  , NULL														AS SeaFreightPlan
		  , NULL														AS OperationCostPlan
		  , NULL														AS ImportDutiesPlanFC
		  , NULL														AS SeaFreightPlanFC
		  , NULL														AS OperationCostPlanFC
		  , NULL														AS ForwarderReference
		  , NULL														AS SupplierReference
		  , NULL														AS ProcessIDCreationDate
		  , NULL														AS ProcessIDLastChangeDate
		  , NULL														AS ProcessFulfilled
		  , NULL														AS Forwarder
		  , LIKP_LIPS.VLSTK													AS DeliveryNoteStatus
		  , LIKP_LIPS.WERKS006													AS Plant
		  , NULL														AS CommunityCode
		  , NULL														AS StorageLocation
		  , NULL														AS ContractNumber		--changed
		  , NULL														AS PortOfDischarg		--changed
		  , NULL														AS PortOfLoading		--changed
		  , NULL														AS TransportMode		--changed

        FROM
             #tSAPZ_MM_LIKP_LIPS AS LIKP_LIPS WITH (NOLOCK)
            INNER JOIN
                [CT dwh 00 Meta].[dbo].[tTransactionTypesConfigSAPEKBE] AS TTC WITH (NOLOCK)
                ON
                    (
                        '8'      = TTC.VGABE -- nur DeliveryNotes
                        AND '' = ISNULL(TTC.BWART,'')
                        AND '' = ISNULL(TTC.SHKZG,'')
                    )
			-- wir holen uns hier die Bestellungen, um zu prüfen, ob wir DeliveryNotes haben, die keiner Bestellung mehr zugrunde liegen
			-- diese möchten wir natürlich nicht verarbeiten, da wir diese später nicht verbinden können und es somit zum Fehler kommt.
			LEFT JOIN (
				select 
					EKKO.EBELN as ProcessId
					, EKPO.EBELP as ProcessPosition
					, EKKO.BSART
					, EKKO.BSTYP
					, EKPO.LOEKZ 
					, EKPO.MANDT
				from 
                         ( SELECT DISTINCT * FROM [CT dwh 01 Stage].[dbo].[tSAP_EKPO]  WITH (NOLOCK) )AS EKPO 
				INNER JOIN 
              ( SELECT DISTINCT * FROM [CT dwh 01 Stage].[dbo].[tSAP_EKKO]  WITH (NOLOCK) )AS EKKO
					ON EKPO.EBELN = EKKO.EBELN
						AND EKPO.MANDT = EKKO.MANDT
				INNER JOIN
				-- alle ausgrenzen, deren TransactionType wir nicht berücksichtigen
					[CT dwh 00 Meta].[dbo].[tTransactionTypesConfigSAP] AS TTC2 WITH (NOLOCK)
					ON
						EKKO.BSTYP     = TTC2.BSTYP
						AND EKKO.BSART = TTC2.BSART
				-- und alle auslassen, deren Order ein Loeschkennzeichen hat
				WHERE EKPO.LOEKZ not in ('X', 'L')
			) as EKPO
			on 
				EKPO.ProcessId = LIKP_LIPS.VGBEL 
				AND EKPO.ProcessPosition = right(LIKP_LIPS.VGPOS, 5)
		WHERE
		-- //15.10.2020 DEVTCK-17593
            LIKP_LIPS.WERKS006 in (1000, 1100)
            --AND LIPS.LGORT in ('1000'		--// 15.10.2020 DEVTCK-17593
            --                 , '1004') 
			AND LIKP_LIPS.POSNR like '9%'
            --AND LIPS.LFIMG != 0
			--and LIPS.VGBEL = '4501000069' -- lt. Definition des Tickets 17100
            --and LIPS.CHARG != 'A'
			-- https://jira.chal-tec.com/browse/DEVTCK-17163 -> see this ticket and comment from Frank Tylinski (27.08.2020)
			--AND LIPS.VGBEL != ''			-- es gibt DeliveryNotes, die haben kein VGBEL. Dadurch das das unser Matching-Kriterium ist, passt später keine Bestellung und der Datensatz ist leer und verursacht Fehler bei der Übertragung in das ChalTecDWH
		-- Neu: OutboundDeliveryNotes
		UNION ALL
		SELECT
            NULL    	                                                AS CompanyId
          , ISNULL(TTC.TransactionType, 'Other')                        AS TransactionType
          , ISNULL(TTC.TransactionTypeDetail, 'Bestellung Andere EKBE') AS TransactionTypeDetail
          , RIGHT(LIKP_LIPS.[MATNR], 8)                                      AS ItemNo
          , NULL                                                        AS ModelName
          , ''                                                          AS [Description]
          , NULL                                                        AS ProductHierarchie1
          , NULL                                                        AS ProductHierarchie2
          , NULL                                                        AS ProductHierarchie3
          , NULL                                                        AS Brand
          , NULL                                                        AS EOL
          , ''                                                          AS Dispatcher
          , NULL                                                        AS Volume
          , NULL                                                        AS [Length]
          , NULL                                                        AS Width
          , NULL                                                        AS Height
          , NULL                                                        AS ItemType
          , NULL                                                        AS Currency
          , LIKP_LIPS.ERDAT                                                  AS TransactionDate
          , LIKP_LIPS.LFIMG                                                  AS Quantity
          , 0                                                           AS ItemPriceForeignCurrency
          , 0                                                           AS ItemPrice
          , 0                                                           AS ValueForeignCurrency
          , 0                                                           AS [Value]
          , 0                                                           AS ExchangeRate
          , NULL                                                        AS PostingDate
          , LIKP_LIPS.VGBEL                                                  AS ProcessID
          , RIGHT(LIKP_LIPS.VGPOS, 5)                                        AS ProcessPosition -- FT: 07.08.2020  -- kommt 6 stellig aus der LIPS.VGPOS
		  --, RIGHT(LIPS.POSNR, 5)										AS ProcessPosition --FT: 23.10.2020 -- für ausgehende soll die POSNR unsere Verknüpfung sein?!				
          , LIKP_LIPS.VBELN                                                  AS DocumentNo
          , NULL                                                        AS MaterialReadyDate
          , NULL                                                        AS PlannedQCDate
          , NULL                                                        AS PlannedETD
          , NULL                                                        AS ETD
          , NULL                                                        AS Paymentterms
          , NULL                                                        AS Incoterms
          , NULL                                                        AS CreditorsName
          , NULL                                                        AS SupplierCode
          , NULL                                                        AS CreditorsNumber
          , NULL                                                        AS SupplierGroupNumber
          , NULL                                                        AS DeliveryAdvise
          , NULL                                                        AS DueDate
          , NULL                                                        AS BookingConfirmed
          , NULL                                                        AS ETAPort
          , LIKP_LIPS.[TRAID]                                                AS ContainerNumber
          , NULL                                                        AS PercentageDesposit
          , NULL                                                        AS OutboundHarbour
          , NULL                                                        AS InboundHarbour
          , (ROW_NUMBER() OVER (PARTITION BY
                                CASE
                                    WHEN LIKP_LIPS.WERKS006 = ''
                                        THEN '1000'
                                        ELSE LIKP_LIPS.WERKS006
                                END, TTC.TransactionType, LIKP_LIPS.VBELN, LIKP_LIPS.[MATNR] ORDER BY
                                LIKP_LIPS.VGPOS)) AS PositionIdRC
          , NULL                             AS ETAWarehouse
		  , NULL														AS ImportDutiesPlan
		  , NULL														AS SeaFreightPlan
		  , NULL														AS OperationCostPlan
		  , NULL														AS ImportDutiesPlanFC
		  , NULL														AS SeaFreightPlanFC
		  , NULL														AS OperationCostPlanFC
		  , NULL														AS ForwarderReference
		  , NULL														AS SupplierReference
		  , NULL														AS ProcessIDCreationDate
		  , NULL														AS ProcessIDLastChangeDate
		  , NULL														AS ProcessFulfilled
		  , NULL														AS Forwarder
		  , LIKP_LIPS.VLSTK													AS DeliveryNoteStatus
		  , LIKP_LIPS.WERKS006													AS Plant
		  , NULL														AS CommunityCode
		  , NULL														AS StorageLocation
		  , NULL														AS ContractNumber		--changed
		  , NULL														AS PortOfDischarg		--changed
		  , NULL														AS PortOfLoading		--changed
		  , NULL														AS TransportMode		--changed
        FROM
             #tSAPZ_MM_LIKP_LIPS AS LIKP_LIPS WITH (NOLOCK)
            INNER JOIN
                [CT dwh 00 Meta].[dbo].[tTransactionTypesConfigSAPEKBE] AS TTC WITH (NOLOCK)
                ON
                    (
                        'X'      = TTC.VGABE -- nur DeliveryNotes
                        AND '' = ISNULL(TTC.BWART,'')
                        AND '' = ISNULL(TTC.SHKZG,'')
                    )
			-- wir holen uns hier die Bestellungen, um zu prüfen, ob wir DeliveryNotes haben, die keiner Bestellung mehr zugrunde liegen
			-- diese möchten wir natürlich nicht verarbeiten, da wir diese später nicht verbinden können und es somit zum Fehler kommt.
			LEFT JOIN (
				select 
					EKKO.EBELN as ProcessId
					, EKPO.EBELP as ProcessPosition
					, EKKO.BSART
					, EKKO.BSTYP
					, EKPO.LOEKZ 
					, EKPO.MANDT
				from 
                    ( SELECT DISTINCT * FROM [CT dwh 01 Stage].[dbo].[tSAP_EKPO]  WITH (NOLOCK) )AS EKPO 
				INNER JOIN 
              ( SELECT DISTINCT * FROM [CT dwh 01 Stage].[dbo].[tSAP_EKKO]  WITH (NOLOCK) )AS EKKO
					ON EKPO.EBELN = EKKO.EBELN
						AND EKPO.MANDT = EKKO.MANDT
				INNER JOIN
				-- alle ausgrenzen, deren TransactionType wir nicht berücksichtigen
					[CT dwh 00 Meta].[dbo].[tTransactionTypesConfigSAP] AS TTC2 WITH (NOLOCK)
					ON
						EKKO.BSTYP     = TTC2.BSTYP
						AND EKKO.BSART = TTC2.BSART
				-- und alle auslassen, deren Order ein Loeschkennzeichen hat
				WHERE EKPO.LOEKZ not in ('X', 'L')
			) as EKPO
			on 
				EKPO.ProcessId = LIKP_LIPS.VGBEL 
				AND EKPO.ProcessPosition = right(LIKP_LIPS.VGPOS, 5)
				
		WHERE
			-- //15.10.2020 DEVTCK-17593
			--    LIPS.WERKS in (1000, 1100)
			-- keine Werks, da immer 5100
			1=1
			and LIKP_LIPS.VBELN like '008%'
			and LIKP_LIPS.POSNR like '0%'
			
       )
    AS s
ON
    (
        t.ItemNo         =s.ItemNo
        --AND t.CompanyId  = s.CompanyId
        and t.DocumentNo = s.DocumentNo
        --and t.PositionIdRC    = s.PositionIdRC -- ?? should we also change this to EBELP ? PositionIdRC looks anyways a little bit strange to me, regarding the definition behind it (18.08.2020, Micha)
        and t.ProcessPosition = s.ProcessPosition
        and t.TransactionType = s.TransactionType
		and t.Plant = s.Plant
    )
WHEN MATCHED
    AND t.TransactionType         <>s.TransactionType
    OR t.TransactionTypeDetail    <>s.TransactionTypeDetail
    OR t.ModelName                <>s.ModelName
    OR t.[Description]            <>s.[Description]
    OR t.ProductHierarchie1       <>s.ProductHierarchie1
    OR t.ProductHierarchie2       <>s.ProductHierarchie2
    OR t.ProductHierarchie3       <>s.ProductHierarchie3
    OR t.Brand                    <>s.Brand
    OR t.EOL                      <>s.EOL
    OR t.Dispatcher               <>s.Dispatcher
    OR t.Volume                   <>s.Volume
    OR t.[Length]                 <>s.[Length]
    OR t.Width                    <>s.Width
    OR t.Height                   <>s.Height
    OR t.ItemType                 <>s.ItemType
    OR t.Currency                 <>s.Currency
    OR t.TransactionDate          <>s.TransactionDate
    OR t.Quantity                 <>s.Quantity
    OR t.ItemPriceForeignCurrency <>s.ItemPriceForeignCurrency
    OR t.ItemPrice                <>s.ItemPrice
    OR t.ValueForeignCurrency     <>s.ValueForeignCurrency
    OR t.[Value]                  <>s.[Value]
    OR t.ExchangeRate             <>s.ExchangeRate
    OR t.PostingDate              <>s.PostingDate
    OR t.DocumentNo               <>s.DocumentNo
    OR t.ProcessID                <>s.ProcessID
    OR t.ProcessPosition          <>s.ProcessPosition
    OR t.MaterialReadyDate        <>s.MaterialReadyDate
    OR t.PlannedQCDate            <>s.PlannedQCDate
    OR t.PlannedETD               <>s.PlannedETD
    OR t.ETD                      <>s.ETD
    OR t.Paymentterms             <>s.Paymentterms
    OR t.Incoterms                <>s.Incoterms
    OR t.SupplierCode             <>s.SupplierCode
    OR t.CreditorsNumber          <>s.CreditorsNumber
    OR t.SupplierGroupNumber      <>s.SupplierGroupNumber
    OR t.DeliveryAdvise           <>s.DeliveryAdvise
    OR t.DueDate                  <>s.DueDate
    OR t.ETAPort                  <>s.ETAPort
    OR t.ContainerNumber          <>s.ContainerNumber
    OR t.PercentageDesposit       <>s.PercentageDesposit
    OR t.OutboundHarbour          <>s.OutboundHarbour
    OR t.InboundHarbour           <>s.InboundHarbour
    OR t.ETAWarehouse             <>s.ETAWarehouse
    OR t.BookingConfirmed         <>s.BookingConfirmed 
	OR t.ImportDutiesPlan		  <>s.ImportDutiesPlan
	OR t.SeaFreightPlan			  <>s.SeaFreightPlan
	OR t.OperationCostPlan		  <>s.OperationCostPlan
	OR t.ProcurementCostsPlan	  <>(isnull(s.ImportDutiesPlan,0)+isnull(s.SeaFreightPlan,0)+isnull(s.OperationCostPlan,0))
	OR t.ImportDutiesPlanFC		  <>s.ImportDutiesPlanFC
	OR t.SeaFreightPlanFC		  <>s.SeaFreightPlanFC
	OR t.OperationCostPlanFC	  <>s.OperationCostPlanFC
	OR t.ProcurementCostsPlanFC	  <>(isnull(s.ImportDutiesPlanFC,0)+isnull(s.SeaFreightPlanFC,0)+isnull(s.OperationCostPlanFC,0))
	OR t.ForwarderReference		  <>s.ForwarderReference
	OR t.SupplierReference	      <>s.SupplierReference
	OR t.ProcessIDCreationDate	  <>s.ProcessIDCreationDate
	OR t.ProcessIDLastChangeDate  <>s.ProcessIDLastChangeDate
	OR t.ProcessFulfilled         <>s.ProcessFulfilled
	OR t.Forwarder				  <>s.Forwarder
	OR t.DeliveryNoteStatus       <>s.DeliveryNoteStatus
	OR t.CompanyId				  <>s.CompanyId
	OR t.CommodityCode			  <>s.CommodityCode
	OR t.Plant					  <>s.Plant
	OR t.StorageLocation		  <>s.StorageLocation
	OR t.ContractNumber			  <>s.ContractNumber		 --changed
	OR t.PortOfDischarg			  <>s.PortOfDischarg		 --changed
	OR t.PortOfLoading			  <>s.PortOfLoading			 --changed
	OR t.TransportMode			  <>s.TransportMode			 --changed
THEN
UPDATE
SET t.TransactionType          =s.TransactionType
  , t.TransactionTypeDetail    =s.TransactionTypeDetail
  , t.ModelName                =s.ModelName
  , t.[Description]            =s.[Description]
  , t.ProductHierarchie1       =s.ProductHierarchie1
  , t.ProductHierarchie2       =s.ProductHierarchie2
  , t.ProductHierarchie3       =s.ProductHierarchie3
  , t.Brand                    =s.Brand
  , t.EOL                      =s.EOL
  , t.Dispatcher               =s.Dispatcher
  , t.Volume                   =s.Volume
  , t.[Length]                 =s.[Length]
  , t.Width                    =s.Width
  , t.Height                   =s.Height
  , t.ItemType                 =s.ItemType
  , t.Currency                 =s.Currency
  , t.TransactionDate          =s.TransactionDate
  , t.Quantity                 =s.Quantity
  , t.ItemPriceForeignCurrency =s.ItemPriceForeignCurrency
  , t.ItemPrice                =s.ItemPrice
  , t.ValueForeignCurrency     =s.ValueForeignCurrency
  , t.[Value]                  =s.[Value]
  , t.ExchangeRate             =s.ExchangeRate
  , t.PostingDate              =s.PostingDate
  , t.DocumentNo               =s.DocumentNo
  , t.MaterialReadyDate        =s.MaterialReadyDate
  , t.PlannedQCDate            =s.PlannedQCDate
  , t.PlannedETD               =s.PlannedETD
  , t.ETD                      =s.ETD
  , t.Paymentterms             =s.Paymentterms
  , t.Incoterms                =s.Incoterms
  , t.CreditorsName            =s.CreditorsName
  , t.SupplierCode             =s.SupplierCode
  , t.CreditorsNumber          =s.CreditorsNumber
  , t.SupplierGroupNumber      =s.SupplierGroupNumber
  , t.DeliveryAdvise           =s.DeliveryAdvise
  , t.DueDate                  =s.DueDate
  , t.ETAPort                  =s.ETAPort
  , t.ContainerNumber          =s.ContainerNumber
  , t.PercentageDesposit       =s.PercentageDesposit
  , t.OutboundHarbour          =s.OutboundHarbour
  , t.InboundHarbour           =s.InboundHarbour
  , t.PositionIdRC             =s.PositionIdRC
  , t.IsChanged                =1
  , t.LastModified             =GETDATE()
  , t.ProcessID                =s.ProcessID
  , t.ETAWarehouse             =s.ETAWarehouse
  , t.BookingConfirmed         =s.BookingConfirmed
  , t.ProcessPosition          =s.ProcessPosition
  , t.ImportDutiesPlan		   =s.ImportDutiesPlan
  , t.SeaFreightPlan		   =s.SeaFreightPlan
  , t.OperationCostPlan		   =s.OperationCostPlan
  , t.ProcurementCostsPlan	   =(isnull(s.ImportDutiesPlan,0)+isnull(s.SeaFreightPlan,0)+isnull(s.OperationCostPlan,0))
  , t.ImportDutiesPlanFC	   =s.ImportDutiesPlanFC
  , t.SeaFreightPlanFC		   =s.SeaFreightPlanFC
  , t.OperationCostPlanFC	   =s.OperationCostPlanFC
  , t.ProcurementCostsPlanFC   =(isnull(s.ImportDutiesPlanFC,0)+isnull(s.SeaFreightPlanFC,0)+isnull(s.OperationCostPlanFC,0))
  , t.ForwarderReference	   =s.ForwarderReference
  , t.SupplierReference	       =s.SupplierReference
  , t.ProcessIDCreationDate	   =s.ProcessIDCreationDate
  , t.ProcessIDLastChangeDate  =s.ProcessIDLastChangeDate
  , t.ProcessFulfilled         =s.ProcessFulfilled
  , t.Forwarder				   =s.Forwarder
  , t.DeliveryNoteStatus       =s.DeliveryNoteStatus
  , t.CompanyId				   =s.CompanyId
  , t.CommodityCode			   =s.CommodityCode
  , t.Plant					   =s.Plant
  , t.StorageLocation		   =s.StorageLocation
  , t.ContractNumber		   =s.ContractNumber		 --changed
  , t.PortOfDischarg		   =s.PortOfDischarg		 --changed
  , t.PortOfLoading			   =s.PortOfLoading			 --changed
  , t.TransportMode			   =s.TransportMode			 --changed
WHEN NOT MATCHED BY TARGET THEN
INSERT
    (CompanyId
      , ItemNo
      , TransactionType
      , TransactionTypeDetail
      , ModelName
      , [Description]
      , ProductHierarchie1
      , ProductHierarchie2
      , ProductHierarchie3
      , Brand
      , EOL
      , Dispatcher
      , Volume
      , [Length]
      , Width
      , Height
      , ItemType
      , Currency
      , TransactionDate
      , Quantity
      , ItemPriceForeignCurrency
      , ItemPrice
      , ValueForeignCurrency
      , [Value]
      , ExchangeRate
      , PostingDate
      , DocumentNo
      , PositionIdRC
      , IsChanged
      , LastModified
      , ProcessID
      , ProcessPosition
      , MaterialReadyDate
      , PlannedQCDate
      , PlannedETD
      , ETD
      , Paymentterms
      , Incoterms
      , CreditorsName
      , SupplierCode
      , CreditorsNumber
      , SupplierGroupNumber
      , DeliveryAdvise
      , DueDate
      , ETAPort
      , ContainerNumber
      , PercentageDesposit
      , OutboundHarbour
      , InboundHarbour
      , ETAWarehouse
      , BookingConfirmed
	  , ImportDutiesPlan		
	  , SeaFreightPlan		
	  , OperationCostPlan		
	  , ProcurementCostsPlan
	  , ImportDutiesPlanFC
	  , SeaFreightPlanFC
	  , OperationCostPlanFC
	  , ProcurementCostsPlanFC
      , ForwarderReference
      , SupplierReference
	  , ProcessIDCreationDate
	  , ProcessIDLastChangeDate
	  , ProcessFulfilled
	  , Forwarder
	  , DeliveryNoteStatus
	  , StorageLocation
	  , CommodityCode
	  , Plant
	  , ContractNumber
	  , PortOfDischarg
	  , PortOfLoading 
	  , TransportMode 
    )
    VALUES
    (s.CompanyId
      , s.ItemNo
      , s.TransactionType
      , s.TransactionTypeDetail
      , s.ModelName
      , s.[Description]
      , s.ProductHierarchie1
      , s.ProductHierarchie2
      , s.ProductHierarchie3
      , s.Brand
      , s.EOL
      , s.Dispatcher
      , s.Volume
      , s.[Length]
      , s.Width
      , s.Height
      , s.ItemType
      , s.Currency
      , s.TransactionDate
      , s.Quantity
      , s.ItemPriceForeignCurrency
      , s.ItemPrice
      , s.ValueForeignCurrency
      , s.[Value]
      , s.ExchangeRate
      , s.PostingDate
      , s.DocumentNo
      , s.PositionIdRC
      , 1
      , GETDATE()
      , s.ProcessID
      , s.ProcessPosition
      , s.MaterialReadyDate
      , s.PlannedQCDate
      , s.PlannedETD
      , s.ETD
      , s.Paymentterms
      , s.Incoterms
      , s.CreditorsName
      , s.SupplierCode
      , s.CreditorsNumber
      , s.SupplierGroupNumber
      , s.DeliveryAdvise
      , s.DueDate
      , s.ETAPort
      , s.ContainerNumber
      , s.PercentageDesposit
      , s.OutboundHarbour
      , s.InboundHarbour
      , s.ETAWarehouse
      , s.BookingConfirmed
	  , s.ImportDutiesPlan		
	  , s.SeaFreightPlan		
	  , s.OperationCostPlan		
	  , (isnull(s.ImportDutiesPlan,0)	+ isnull(s.SeaFreightPlan,0) + isnull(s.OperationCostPlan,0))
	  , s.ImportDutiesPlanFC		
	  , s.SeaFreightPlanFC		
	  , s.OperationCostPlanFC		
	  , (isnull(s.ImportDutiesPlanFC,0)	+ isnull(s.SeaFreightPlanFC,0) + isnull(s.OperationCostPlanFC,0))
      , s.ForwarderReference
      , s.SupplierReference
	  , s.ProcessIDCreationDate
	  , s.ProcessIDLastChangeDate
	  , s.ProcessFulfilled
	  , s.Forwarder
	  , s.DeliveryNoteStatus
	  , s.StorageLocation
	  , s.CommodityCode
	  , s.Plant
	  , s.ContractNumber
	  , s.PortOfDischarg
	  , s.PortOfLoading 
	  , s.TransportMode 
    )
;

PRINT LTRIM(CAST(GETDATE() AS NVARCHAR(20))) + ' MERGE finished'

DROP TABLE #tSAPZ_MM_LIKP_LIPS

END

