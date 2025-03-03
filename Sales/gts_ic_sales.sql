with
CTE_GTS_PO AS
(
	SELECT gts.[PRECEDINGDOCUMENT],gts.[PRECEDINGDOCUMENTITEM],gts.[SUBSEQUENTDOCUMENT], gts.[SUBSEQUENTDOCUMENTITEM], rk = rank() over (partition by gts.[PRECEDINGDOCUMENT],gts.[PRECEDINGDOCUMENTITEM] order by LastChangeDT desc)
	FROM L0.L0_S4HANA_2LIS_11_VAITM vaitm
	INNER JOIN L0.L0_S4HANA_Z_SD_VBFA gts 
		on gts.[PRECEDINGDOCUMENT] = vaitm.VBELN 
			AND
			gts.[PRECEDINGDOCUMENTITEM] = vaitm.POSNR
			AND
			[SUBSEQUENTDOCUMENTCATEGORY] = 'V'
	INNER JOIN  L0.L0_S4HANA_2LIS_02_ITM itm on itm.EBELN = gts.[SUBSEQUENTDOCUMENT] and cast(itm.EBELP as int)= cast(gts.[SUBSEQUENTDOCUMENTITEM] as int) and itm.LOEKZ <> 'L'
	WHERE
		vaitm.AUART = 'ZIOR'
	Group by gts.[PRECEDINGDOCUMENT],gts.[PRECEDINGDOCUMENTITEM],gts.[SUBSEQUENTDOCUMENT], gts.[SUBSEQUENTDOCUMENTITEM],LastChangeDT
)

  
SELECT 
   fact.CD_MARKET_ORDER_ID PurchasingNo, cd_document_no SalesDocumentNo,cd_document_line SalesDocumentLinePosition,gts_po.[SUBSEQUENTDOCUMENT] GTSPurchasingNo, gts_po.[SUBSEQUENTDOCUMENTITEM] GTSPurchasingLinePosition
  FROM [L1].[L1_FAcT_A_SALES_TRANSACTION] fact

	LEFT JOIN CTE_GTS_PO gts_po on fact.CD_DOCUMENT_NO = gts_po.[PRECEDINGDOCUMENT] AND fact.CD_DOCUMENT_LINE = gts_po.[PRECEDINGDOCUMENTITEM] and gts_po.rk=1
	WHERE CD_TYPE in ('ZIOR') and D_CREATED>='2024-06-01'
  --  WHERE 
		--(  
  --          @LOAD_START_DATE IS NULL
  --          OR
  --          CASE WHEN VAITM.ZZ_CPD_UPDAT = 0 THEN VAITM.ERDAT  ELSE CAST(LEFT(VAITM.ZZ_CPD_UPDAT,8) as date) END >= @LOAD_START_DATE

  --      )






