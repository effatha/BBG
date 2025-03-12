;With cte_EKBZ AS
( SELECT BELNR
		,BUZEI
		,KSCHL
		,CASE WHEN BEWTP in( 'M' ,'P') THEN (CASE WHEN SHKZG = 'S' THEN ISNULL(DMBTR,0) ELSE ISNULL(DMBTR,0) * -1 END )
			  WHEN BEWTP = 'K' THEN  CASE WHEN SHKZG = 'S' THEN ISNULL(AREWR,0) ELSE ISNULL(AREWR,0) * -1 END 
			  ELSE 0 END Cost
		,WRBTR
FROM [CT dwh 02 Data].dbo.tSAPZ_MM_EKBZ WITH(NOLOCK)
WHERE is_current = 1 )
, cte_CostLine AS
( 
SELECT BELNR
		,BUZEI
		,SUM(CASE WHEN CLType.[CostLineType] = 'ProcurementCosts' THEN ISNULL(WRBTR,0) END) as ProcurementCostsLC
		,SUM(CASE WHEN CLType.[CostLineType] = 'ImportDuties' THEN ISNULL(WRBTR,0) END) as ImportDutiesLC
		,SUM(CASE WHEN CLType.[CostLineType] = 'SeaFreight' THEN ISNULL(WRBTR,0) END) as SeaFreightLC
		,SUM(CASE WHEN CLType.[CostLineType] = 'OperationCost' THEN ISNULL(WRBTR,0) END) as OperationCostLC
		,SUM(CASE WHEN CLType.[CostLineType] = 'ProcurementCosts' THEN Cost	END) as ProcurementCostsGlobal
		,SUM(CASE WHEN CLType.[CostLineType] = 'ImportDuties' THEN Cost END) as ImportDutiesGlobal
		,SUM(CASE WHEN CLType.[CostLineType] = 'SeaFreight' THEN Cost END) as SeaFreightGlobal
		,SUM(CASE WHEN CLType.[CostLineType] = 'OperationCost' THEN Cost END) as OperationCostGlobal
FROM cte_EKBZ EKBZ
INNER JOIN [CT dwh 00 Meta].[SAP].[tCostLineTypeConfigPurchasing] CLType WITH(NOLOCK)
	ON CLType.[ExtractorFieldValue] = EKBZ.KSCHL
WHERE CLType.[DocumentType] = 'Invoice'
GROUP BY BELNR, BUZEI
)
, cte_INV AS 
(
select * from [CT dwh 02 Data].[dbo].[tSAP2LIS_06_INV] where RBSTAT = '5' and is_current=1 and ebeln <> '' 
union all
select * from [CT dwh 02 Data].[dbo].[tSAP2LIS_06_INV] a where RBSTAT = 'A' and is_current=1 and ebeln <> '' and not exists( 
select 1 from [CT dwh 02 Data].[dbo].[tSAP2LIS_06_INV] b where RBSTAT = '5' and is_current=1 and ebeln <> '' and a.BELNR = b.BELNR and a.buzei = b.buzei) 
)


SELECT 	
		 INV.BELNR														AS DocumentNo
		,INV.BUZEI														AS PositionId
		,INV.EBELN														AS ProcessId --PurchaseOrderNo
		,INV.EBELP														AS ReferencePositionId --PurchaseOrderLineItemNo
		,CONVERT(bigint, INV.EBELN)										AS ReferenceId
		,INV.BUKRS														AS CompanyCode
		,CAST(FORMAT(INV.BUDAT,'yyyyMMdd') AS INT)						AS DateDimCalendarID
		,INV.MENGE 														as Quantity
		,CAST(INV.NETPR AS MONEY) 										as ItemPriceForeignCurrency
		--,CAST(INV.NETPR *  CASE
		--				WHEN INV.KURSF < 0	THEN (1 / ABS(INV.KURSF))	
		--					ELSE ABS(INV.KURSF)	
		--		   END AS MONEY)										AS ItemPrice
		,CAST(CASE WHEN INV.KURSF < 0 THEN (INV.NETPR/(CASE WHEN INV.KURSF = 0 THEN 1 ELSE ABS(INV.KURSF) END)) 
			  ELSE ISNULL(INV.NETPR,0) * ABS(ISNULL(INV.KURSF,0)) 
			  END AS MONEY)												AS ItemPrice
		,CAST(ABS(INV.NETPR * INV.MENGE) AS MONEY)						AS ValueForeignCurrency
		--,CAST(INV.WRBTR AS MONEY)										AS Value Old Value
		--,CAST(INV.NETPR*INV.MENGE*INV.KURSF	AS MONEY)					AS Value
        ,CAST((INV.MENGE)*CAST(CASE WHEN INV.KURSF < 0 THEN (INV.NETPR/(CASE WHEN INV.KURSF = 0 THEN 1 ELSE ABS(INV.KURSF) END)) 
			  ELSE ISNULL(INV.NETPR,0) * ABS(ISNULL(INV.KURSF,0)) 
			  END AS MONEY)	AS MONEY)					                 AS Value
		,CONVERT(nvarchar(50), Cast(INV.MATNR as bigint))					AS ItemNo
		,CAST(CASE																									
			WHEN INV.KURSF < 0	THEN (1 / ABS(INV.KURSF))															
				ELSE ABS(INV.KURSF)																					
		  END AS DECIMAL(30, 20))										AS ExchangeRate								-- ##### Im Ticket ####
		,CAST( CASE
			WHEN Incident.Id IS NOT NULL THEN 1
				ELSE 0
			 END AS bit)												AS IncidentFlag
		,Incident.IncidentReason										AS IncidentReason
		,INV.WAERS														AS Currency	
		,CAST(NULL AS NVARCHAR)											AS CreditorName
		,INV.LIFNR 														AS CreditorNumber
		,CAST(NULL AS smallint)												AS Warehouse
		,'Invoice'														AS TransactionTypeDetail
		,INV.BLART														AS TransactionTypeShort
		,INV.KONNR														AS ContractNumber
		,0																AS ETAWarehouseDimCalendarId
		,0																AS ETAWarehouseDimTimeId
		,CostLine.ProcurementCostsLC
		,CostLine.ImportDutiesLC
		,CostLine.SeaFreightLC
		,CostLine.OperationCostLC
		,CostLine.ProcurementCostsGlobal
		,CostLine.ImportDutiesGlobal
		,CostLine.SeaFreightGlobal
		,CostLine.OperationCostGlobal
		,INV.RBSTAT														AS Status
		,INV.STBLG														AS ReversalDocumentNo
		,CAST(FORMAT(INV.BLDAT,'yyyyMMdd') AS INT)														AS DimDocumentDateid
		,CAST(FORMAT(INV.ZFBDT,'yyyyMMdd') AS INT)														AS DimPaymentBasedateid
		,INV.ZBD1T														AS PaymentTerms
		,CAST(FORMAT(DATEADD(day,INV.ZBD1T,INV.ZFBDT),'yyyyMMdd') AS INT)								AS DimPaymentDuedateid
		,INV.IVTYP														AS ReversalNo
		,INV.XBLNR 														AS InvoiceReference
		/*** tSap_Z_SD_DD07T as Dim***/
		--,DD07T.DDTEXT													AS ReversalText -- TEXT als Dimensions Info wird zu Nummer in der Dimension 
		--,DD07T.[DOMNAME]												AS ReversalNAME 
       -- ,DD07T.[DDLANGUAGE]												AS ReversalLanguage 
		
FROM cte_INV INV WITH(NOLOCK)
LEFT JOIN cte_CostLine CostLine WITH(NOLOCK)
ON INV.BELNR = CostLine.BELNR and CAST(INV.BUZEI AS INT) = CAST(CostLine.BUZEI AS INT)
LEFT JOIN [CT dwh 00 Meta].[config].[tIncidentFlag] AS Incident WITH (NOLOCK)
	ON INV.EBELN = Incident.ProcessID
    AND INV.BUKRS = Incident.CompanyID
    AND Incident.[Source] = 'SAP'
	AND incident.IncidentDataType = 'Purchasing'
--LEFT JOIN [CT dwh 03 Intelligence].[dbo].[tMappingIncidentSageSapProcessID] AS Incident WITH (NOLOCK)
--	ON INV.EBELN = Incident.ProcessID
--   AND INV.BUKRS = Incident.CompanyID
--   AND Incident.[Source] = 'SAP'

--LEFT JOIN [CT dwh 01 Stage].[dbo].[tSAP_Z_SD_DD07T] AS DD07T
--	ON INV.IVTYP = DD07T.DOMVALUE_L and DD07T.DOMNAME = 'IVTYP'
WHERE 1 = 1
and 
(
	(
		INV.valid_from > CAST(? as Datetime)
		AND 0 = ${Loading_Type} -- Incremental Load
	)
	OR
	(
		1 = ${Loading_Type}-- Full Load
	)
)
