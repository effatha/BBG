;with cte_max as(
	Select ? as maxdate
	
)
select

BF.MBLNR AS MaterialDocNo
,BF.ZEILE AS MaterialDocItemNo
,LIPS.POSNR AS DocumentItemPosition
,LIPS.VBELN AS DocumentNo
,BF.MJAHR AS MaterialDocYear
,BF.BSTAUS AS ItemCategory
,'Inbound Delivery Movement'	AS TransactionTypeDetail
,BF.BWART AS MovementTypeTransactionTypeShort 
,LIPS.VBTYP AS SDDocCategroyTransactionTypeShort
,BF.MENGE AS Quantity
,BF.EBELN AS ProcessId 
,BF.EBELP AS PurchaseOrderLineItemNo
, 'unknown'	AS SupplierGroupNumber
, 'unknown'	AS SupplierGroupName
, 'unknown'	AS SupplierName
,BF.LIFNR AS SupplierNumber
, 'unknown'	AS SupplierCode
,SUBSTRING(BF.MATNR, PATINDEX('%[^0]%',BF.MATNR), LEN(BF.MATNR)) AS ItemNo
,BF.dmbtr AS Value
--,BF.BWTAR AS ItemValuationType 
--,BF.CHARG AS ItemBatch
,CAST(FORMAT(BF.BUDAT,'yyyyMMdd') AS INT) AS TransactionDateDimCalendarID
,BF.WERKS AS Plant 
,BF.LGORT AS StorageLocation
,BF.BUKRS AS CompanyCode
--,'unknown' AS CompanyName
--,'1000' AS CompanyCodeItem
--,'CT' AS CompanyNameItem
--,BF.SGT_SCAT AS ItemSegment
--,BF.BSTAUS AS ItemCategory 
--,mlips.LFART AS DeliveryType
--,mlips.Description as DeliveryType_Description
, CAST(FORMAT(LIPS.LFDAT,'yyyyMMdd') AS INT) AS PostingDateDimCalendarID
, LIPS.Inco2 AS Incoterms
--,LIPS.MATKL AS ItemGroup
,CAST(FORMAT(LIPS.AEDAT ,'yyyyMMdd') AS INT) AS DeliveryChangeDateDimCalendarID
,LIPS.BOLNR AS BillOfLading
,LIPS.TRAID AS TransportId
,CAST(FORMAT(LIPS.BLDAT,'yyyyMMdd') AS INT) AS  DeliveryDateDimCalendarID
,LIPS.VGBEL AS ReferenceId
,LIPS.EAN11 AS EANUPC
,BF.BWTAR AS ItemValuationType
,'unknown'	AS ItemValuationTypeDescription
,'unknown'	AS ItemCategoryDescription 
,BF.CHARG AS ItemBatch
,'unknown'	AS ItemBatchDescription 
,LIPS.LFART AS DeliveryTypeTransactionTypeShort 
--,'unknown'	AS DeliveryTypeDescription 
,LIPS.TRATY AS TransportType
,'unknown'	AS TransportTypeDescription
,bf.SHKZG as  DebitCreditIndicator
,bf.SOBKZ as SpecialStockIndicator 
,bf.ZZ_SALK3 as StockValue
,bf.GRUND AS StockDamageReasonCode 
from dbo.tSAP2LIS_03_BF as BF with (nolock)
left join dbo.tSAPZ_MM_LIKP_LIPS as LIPS with (nolock)
on LIPS.VBELN = BF.ZZ_VBELN_IM
and LIPS .POSNR = BF.ZZ_VBELP_IM
and LIPS.is_current=1
CROSS JOIN cte_max as cmax
WHERE BF.is_current = 1
AND
	(	
	(
			(		BF.valid_from				> cmax.maxdate
				OR	LIPS.valid_from			> cmax.maxdate
			)
			AND 0 = ${Loading_Type} -- Incremental Load
		)
		OR 
		(
			1 = ${Loading_Type} -- Full Load
		)
)

--and BF.MBLNR='5000051359'
--and BF.ZEILE ='0001'
--and BF.MJAHR='2024'
--AND BF.BSTAUS ='A'
--and LIPS.POSNR='900001'
