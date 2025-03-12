
;WITH cte_max as(
	Select ? as maxdate
	
)
,cte_src
AS(
SELECT DISTINCT HDR.EBELN,ITM.EBELP,SCN.EBTYP, SCN.SCLDT,SCN.OPNQTY, CASE WHEN SCN.EBTYP='Z3' THEN cast(format([CNFDT],'yyyyMMdd') as int) ELSE NULL END AS BookingConfirmedZ3DeliveryDate, CASE WHEN SCN.EBTYP='Z3' THEN cast(format([ZZ_ERDAT],'yyyyMMdd') as int) ELSE NULL END AS BookingConfirmedZ3CreationDate
FROM [CT dwh 00 Meta].[SAP].[tDocumentTypeBucketConfigPurchasing] AS Config WITH (NOLOCK) 
INNER JOIN [CT dwh 02 Data].[dbo].[tSAP2LIS_02_HDR] AS HDR WITH (NOLOCK)
	ON Config.[TransactionTypeShort] = HDR.BSTYP
	AND HDR.is_current = 1
INNER JOIN [CT dwh 02 Data].[dbo].[tSAP2LIS_02_ITM] AS ITM WITH (NOLOCK)
	ON HDR.EBELN = ITM.EBELN
	AND ITM.valid_to = '22000101'
LEFT JOIN [CT dwh 02 Data].[dbo].[tSAP0VENDOR_TEXT] AS TEXT WITH (NOLOCK)
    ON ITM.LIFNR = TEXT.LIFNR
	AND TEXT.is_current=1
LEFT JOIN [CT dwh 02 Data].[dbo].[tSAP2LIS_02_SCN] AS SCN WITH (NOLOCK)
	ON HDR.EBELN = SCN.EBELN
	AND ITM.EBELP = SCN.EBELP
	AND ITM.EBELN=SCN.EBELN					
	AND SCN.is_current = 1
),
cte_Z2
AS(SELECT EBELN,EBELP, OPNQTY,-1 AS BookingConfirmedZ2, 0 AS BookingConfirmedZ3, SCLDT,BookingConfirmedZ3DeliveryDate,BookingConfirmedZ3CreationDate FROM cte_src WHERE EBTYP='Z2'),
  
cte_Z3
AS(SELECT EBELN,EBELP,OPNQTY, 0 AS BookingConfirmedZ2, -1 AS BookingConfirmedZ3, SCLDT ,BookingConfirmedZ3DeliveryDate,BookingConfirmedZ3CreationDate FROM cte_src WHERE EBTYP='Z3'),
cte_Z23
AS(SELECT EBELN,EBELP, OPNQTY,0 AS BookingConfirmedZ2, 0 AS BookingConfirmedZ3,  SCLDT ,BookingConfirmedZ3DeliveryDate,BookingConfirmedZ3CreationDate FROM cte_src WHERE EBTYP NOT IN ('Z3','Z2') OR EBTYP is null)
,cte_BookingConfirmedunion as (
SELECT EBELN,EBELP,OPNQTY,BookingConfirmedZ2,BookingConfirmedZ3, SCLDT,BookingConfirmedZ3DeliveryDate,BookingConfirmedZ3CreationDate
FROM cte_Z2
UNION
SELECT EBELN,EBELP,OPNQTY,BookingConfirmedZ2,BookingConfirmedZ3, SCLDT,BookingConfirmedZ3DeliveryDate,BookingConfirmedZ3CreationDate
FROM cte_Z3
UNION
SELECT EBELN,EBELP,OPNQTY,BookingConfirmedZ2,BookingConfirmedZ3,  SCLDT,BookingConfirmedZ3DeliveryDate,BookingConfirmedZ3CreationDate
FROM cte_Z23)
,cte_BookingConfirmed
AS(
SELECT EBELN,EBELP,MIN(OPNQTY) as OPNQTY,MIN(BookingConfirmedZ2) as BookingConfirmedZ2,MIN(BookingConfirmedZ3) as BookingConfirmedZ3, max(SCLDT) AS SCLDT,MIN(BookingConfirmedZ3DeliveryDate) AS BookingConfirmedZ3DeliveryDate,MIN(BookingConfirmedZ3CreationDate) AS BookingConfirmedZ3CreationDate FROM cte_BookingConfirmedunion group by EBELN,EBELP

)

SELECT
      HDR.EBELN															AS ProcessId							
	, HDR.EBELN															AS DocumentNo				
    , ITM.EBELP															AS PositionId		
	, HDR.BUKRS															AS CompanyCode						
	, HDR.EKORG															AS PurchasingOrganizationCode
	, CAST(NULL AS NVARCHAR)											AS PurchasingOrganizationName
	, CAST(FORMAT(HDR.BEDAT,'yyyyMMdd') AS INT)							AS TransactionDateDimCalendarID			
	, ITM.MENGE															AS Quantity							
	, CAST(ITM.netwr/IIF(ITM.menge=0,1,ITM.menge) AS MONEY)				AS ItemPriceForeignCurrency		
	, CAST(ITM.NETPR AS MONEY)										AS ItemPrice					
	, SUBSTRING(ITM.MATNR, PATINDEX('%[^0]%', ITM.MATNR), LEN(ITM.MATNR))	AS ItemNo							
	, CAST(CASE																									
		WHEN ITM.WKURS < 0	THEN (1 / ABS(ITM.WKURS))															
			ELSE ABS(ITM.WKURS)																					
	  END AS DECIMAL(30, 20))											AS ExchangeRate							
	, HDR.WAERS															AS Currency								
	, FW_FS.Forwarder													AS Forwarder
	, HDR.ZZFORWARDER_REF												AS ForwarderReferenceNumber			
	, CAST(FORMAT(ITM.ZMM_MRD,'yyyyMMdd') AS INT)						AS MaterialReadyDateDimCalendarId		
	, 0					AS PlannedQCDateDimCalendarId			
	, 0						AS PlannedETDDimCalendarId				
	, HDR.ZZ_ZTERM														AS PaymenttermsCode						
	, CAST(NULL AS NVARCHAR)											AS PercentageDesposit
	, CAST(NULL AS NVARCHAR)											AS Incoterms
	, 0																	AS DueDateDimCalendarId
	, 0																	AS ProcessIdCreationDateDimCalendarId	
	, CAST(FORMAT(HDR.BUDAT,'yyyyMMdd') AS INT)							AS PostingDateDimCalendarId
	, ITM.LGORT															AS StorageLocation					
	, ITM.WERKS															AS Plant							
	, CAST( CASE
		WHEN Incident.Id IS NOT NULL THEN 1
			ELSE 0
	  END AS bit)														AS IncidentFlag
	, Incident.IncidentReason											AS IncidentReason
	, Config.TransactionType											AS TransactionTypeDetail
	, Config.TransactionTypeShort										AS TransactionTypeShort
	, HDR.BSART															AS SDDocCategroyTransactionTypeShort
	, ITM.LIFNR 														AS SupplierNumber
	, CAST(NULL AS NVARCHAR)														AS SupplierName
	, CAST(NULL AS NVARCHAR)											AS SupplierCode
	, CAST(NULL AS NVARCHAR)											AS SupplierGroupNumber
	, CAST(NULL AS NVARCHAR)											AS SupplierGroupName
	, HDR.ZZSUPPLIER_REF 												AS SupplierReference			
	, CAST(NULL AS NVARCHAR)											AS ETDDelayReason
	, CAST(NULL AS NVARCHAR)											AS QCDDelayReason
	, CAST(NULL AS NVARCHAR)											AS MRDDelayReason
	, CAST(NULL AS NVARCHAR)											AS Warehouse
	, 0																	AS TransactionDateDimTimeId
	, 0																	AS MaterialReadyDateDimTimeId
	, 0																	AS PlannedQCDateDimTimeId
	, 0																	AS PlannedETDDimTimeId
	, 0																	AS DueDateDimTimeId
	, 0																	AS ProcessIdCreationDateDimTimeId
	, 0																	AS ProcessIdLastChangeDateDimTimeId
	, 0																	AS PostingDateDimTimeId
	, 0																	AS ETAWarehouseDimTimeId
	, 0																	AS ProcessIdLastChangeDateDimCalendarId
	, CAST(FORMAT(HDR.ZZETA,'yyyyMMdd') AS INT)							AS ETAPortDimCalendarId	
	, CAST(FORMAT(SCL.EINDT	,'yyyyMMdd') AS INT)						AS ETAWarehouseDimCalendarId
	, ITM.KNUMV															AS DocumentConditionNo
	, ITM.ZZ_DPTYP 														AS DownPaymentCategory				
	, CAST(FORMAT(ITM.ZZ_DPDAT,'yyyyMMdd') AS INT)						AS DownPaymentDueDateDimCalendarId					
	, ITM.ZZ_DPAMT 														AS DownPaymentAmount	
	, ITM.ZZ_DPPCT														AS DownPaymentPercentage	
	, ITM.KONNR															AS ContractNumber	
	, HDR.ZZTRANSPORT_MODE												AS TransportMode 
	, TRA.[TEXT]														AS TransportModeDescription	
	, HDR.ZZPORT_OF_LOADING												AS PortOfLoading 
	, HDR.ZZPORT_OF_DISCHARG											AS PortOfDischarge	
	, ITM.EKGRP															AS PurchasingGroup
	, CAST(FORMAT(ITM.ZMM_IM_READY_DATE,'yyyyMMdd') AS INT)				AS IMReadyDateDimCalendarId
	, ITM.BSAKZ															AS ConfirmationControlType 		
	, ITM.LLIEF															AS GoodsSupplier 
	, CASE WHEN ITM.is_deleted = 1 THEN 'L' ELSE ITM.LOEKZ END			AS DeletionIndicator
	,CAST(CASE WHEN HDR.ZZ_WEAKT = 'X' THEN 1 ELSE 0 END  AS BIT)                    AS ProcessFulfilled
	, CAST(LEFT (HDR.[ZZ_LASTCHANGEDATETIME],8) AS INT)					AS HeaderChangeDateDimCalendarID
	, CAST([ZZ_LASTCHANGEDATETIME]%1000000 AS INT)						AS HeaderChangeDateDimTimeID	
	, CAST(FORMAT(ITM.ZZ_AEDAT,'yyyyMMdd') AS INT)						AS ItemChangeDateDimCalendarId
	, CAST(ITM.NETWR	AS DECIMAL(19, 4))														AS [ValueForeignCurrency]
	, CAST(ABS(ITM.NETPR * ITM.MENGE) AS MONEY)										AS [Value]							
    , CAST(FORMAT(HDR.ZZETD,'yyyyMMdd') AS INT)						AS ETDDateDimCalendarId
	, CAST(FORMAT(ITM.ZMM_QC_DATE,'yyyyMMdd') AS INT)					AS QCDateDimCalendarId
	, CAST(SCN.BookingConfirmedZ2 AS NVARCHAR) AS BookingConfirmedZ2
	, CAST(SCN.BookingConfirmedZ3 AS NVARCHAR) AS BookingConfirmedZ3
	, SCN.BookingConfirmedZ3CreationDate AS BookingConfirmedZ3CreationDimDateID
	, SCN.BookingConfirmedZ3DeliveryDate AS BookingConfirmedZ3DeliveryDimDateID	
	, ITM.INFNR AS InfoRecordNumber		
    , ATTR.ALTKN AS Creditornumber
	, CAST(ISNULL(FORMAT(ITM.ZMM_ETD,'yyyyMMdd'), 0) AS INT)				AS ETDPositionLevelDimCalendarId
    , ITM.ZCONTRACT_REFERENCE                                               AS Contract_Reference
FROM [CT dwh 00 Meta].[SAP].[tDocumentTypeBucketConfigPurchasing] AS Config WITH (NOLOCK) 
INNER JOIN [CT dwh 02 Data].[dbo].[tSAP2LIS_02_HDR] AS HDR WITH (NOLOCK)
	ON Config.[TransactionTypeShort] = HDR.BSTYP
	AND HDR.is_current = 1
INNER JOIN [CT dwh 02 Data].[dbo].[tSAP2LIS_02_ITM] AS ITM WITH (NOLOCK)
	ON HDR.EBELN = ITM.EBELN
	AND ITM.valid_to = '22000101'
LEFT JOIN [CT dwh 02 Data].[dbo].[tSAP0VEN_COMPC_ATTR] AS ATTR WITH (NOLOCK)
    ON ATTR.LIFNR = ITM.LIFNR 
	AND ATTR.BUKRS= ITM.BUKRS
	AND ATTR.is_current=1
LEFT JOIN [CT dwh 02 Data].[dbo].[tSAP2LIS_02_SCL] AS SCL WITH (NOLOCK)
    ON SCL.EBELN = HDR.EBELN
	AND SCL.EBELP= ITM.EBELP
	AND SCL.is_current=1
    --AND SCL.NOSCL =1
LEFT JOIN cte_BookingConfirmed AS SCN WITH (NOLOCK)
	ON HDR.EBELN = SCN.EBELN
	AND ITM.EBELP = SCN.EBELP
LEFT JOIN (
	SELECT [EBELN]
      	,[TEXT_EKPA_LIFN2] as Forwarder
  	FROM [CT dwh 02 Data].[dbo].[tSAPZ_MM_EKPA] WITH (NOLOCK)
  	WHERE [PARVW] = 'FS'
	AND is_current = 1) AS FW_FS
	ON HDR.EBELN = FW_FS.EBELN
--LEFT JOIN [CT dwh 03 Intelligence].[dbo].[tMappingIncidentSageSapProcessID] AS Incident WITH (NOLOCK)
--	ON HDR.EBELN = Incident.ProcessID
--   AND HDR.EKORG = Incident.CompanyID
--   AND Incident.[Source] = 'SAP'
LEFT JOIN [CT dwh 00 Meta].[config].[tIncidentFlag] AS Incident WITH (NOLOCK)
	ON HDR.EBELN = Incident.ProcessID
    AND HDR.EKORG = Incident.CompanyID
    AND Incident.[Source] = 'SAP'
	AND incident.IncidentDataType = 'Purchasing'
LEFT JOIN [CT dwh 02 Data].[dbo].[tSAPZMM_TRANSPORT_MT] TRA WITH(NOLOCK)
	ON HDR.ZZTRANSPORT_MODE = TRA.TRANSPORT_MODE
	AND	TRA.is_current = 1
CROSS JOIN cte_max as cmax
WHERE 1 = 1
	AND Config.TransactionType = 'Order'
--AND HDR.EBELN = '4501001908' --AND ITM.EBELP='00010'
AND

	(	
	(
			(		HDR.valid_from				> cmax.maxdate
				OR	ITM.CD			> cmax.maxdate
				OR	TRA.valid_from				> cmax.maxdate	
				OR	ATTR.valid_from				> cmax.maxdate	
				OR	SCL.valid_from				> cmax.maxdate
			)
			AND 0 = ${Loading_Type} -- Incremental Load
		)
		OR 
		(
			1 = ${Loading_Type} -- Full Load
		)
)
