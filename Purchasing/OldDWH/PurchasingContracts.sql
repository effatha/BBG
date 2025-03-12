

;with cte_max as(
	Select ? as maxdate
	
)

 SELECT
	 HDR.EBELN																  	AS ContractNumber
	, ITM.EBELP																	AS PositionId
    , Config.TransactionType											        AS TransactionTypeDetail
	, Config.[TransactionTypeShort]										        AS TransactionTypeShort
    , HDR.ZZKONNR															    AS OutlineAgreement
	, ITM.EFFWR																	AS EffectiveValue
    , ITM.KTMNG                                                                 AS ContractPositionQuantity
	, HDR.EKORG																	AS PurchasingOrganizationCode -- new Dimension 
	, cast(null as nvarchar(50))												AS PurchasingOrganizationName 	
	, ITM.ZZ_INCO1																AS Incoterms -- new Dimension
	, ITM.ZZ_INCO2_L															AS IncotermsLocation1 -- new Dimension
	, ITM.ZZ_INCO3_L															AS IncotermsLocation2 -- new Dimension
	, HDR.KNUMV																	AS DocConditionNo
	, ITM.LGORT																	AS StorageLocation -- Dimension
	, HDR.LIFNR																	AS Vendor --Dimension
  
	--, ITM.MATKL																	AS MaterialGroup -- should come from purch.tDimItem																	
	, SUBSTRING(ITM.MATNR, PATINDEX('%[^0]%', ITM.MATNR), LEN(ITM.MATNR)) 		AS ItemNo -- necessary for lookup with purch.tDimItem
	, ITM.NETPR																	AS NetOrderPrice
    ,  ITM.ZZ_NETPR																	AS NetOrderPriceForeignCurrency
	--, HDR.RESWK																	AS SupplyingPlant -- Dimension
	, ATTR.STAWN															    AS CommodityCode -- should come from purch.tDimItem
	--, ITM.VOLEH																	AS VolumeUnit -- should come from purch.tDimItem or Fact?
	, ITM.VOLUM																	AS Volume -- should come from purch.tDimItem or Fact?
	, HDR.WAERS																	AS Currency
	, HDR.ZZ_WEAKT																AS GRMessage
	, ITM.WERKS																	AS Plant -- new dimension
	, HDR.WKURS																	AS ExchangeRate
	, HDR.ZZ_ZBD1T																AS PaymentIn 
	, HDR.ZZ_ZTERM																AS PaymentTerms -- dimension
	, ITM.BRGEW																	AS GrossWeight -- should come from purch.tDimItem or Fact?
	, ITM.BRTWR                                                                 AS GrossOrderValue
	, HDR.BSTYP                                                                 AS PurchDocCategory
	, HDR.BUKRS																	AS CompanyCode -- necessary for lookup with purch.tDimItem / purch.tDimCompany
	--, HDR.ZZDPTYP															    AS DownPaymentCatg -- ?? dimension ?? / ZZDPTYP?
	, CAST(FORMAT(HDR.ZZDPDAT,'yyyyMMdd') AS INT)								AS DownPaymentDueDateDimCalendarId -- dimension
	, CAST(FORMAT(HDR.ZZ_AEDAT,'yyyyMMdd') AS INT)								AS CreationDateDimCalendarId -- dimension
	, CAST(FORMAT(HDR.BEDAT,'yyyyMMdd') AS INT)									AS DocumentDateDimCalendarId -- dimension
	, CAST(FORMAT(HDR.KDATB,'yyyyMMdd') AS INT)									AS ValiditiyStartDateDimCalendarId -- dimension
	, CAST(FORMAT(HDR.KDATE,'yyyyMMdd') AS INT)									AS ValiditiyEndDateDimCalendarId -- dimension
	--, ITM.SGT_SCAT																AS StockSegment -- necessary for lookup with purch.tDimItem
	, HDR.LOEKZ																	AS DeletionIndicator
    , ITM.LOEKZ	                                                                AS ContractPositionDeletionIndicator
	, HDR.ZZDPPER																AS DownPaymentPercentage
	, HDR.ZZDPFIX																AS DownPaymentAmount
    , ITM.ZCONTRACT_REFERENCE                                                   AS Contract_Reference

FROM [CT dwh 00 Meta].[SAP].[tDocumentTypeBucketConfigPurchasing] AS Config WITH (NOLOCK) 
INNER JOIN [CT dwh 02 Data].[dbo].[tSAP2LIS_02_HDR] AS HDR WITH (NOLOCK)
ON Config.[TransactionTypeShort] = HDR.BSTYP
AND HDR.is_current = 1

INNER JOIN [CT dwh 02 Data].[dbo].[tSAP2LIS_02_ITM] AS ITM WITH (NOLOCK)
	ON HDR.EBELN = ITM.EBELN
	AND ITM.is_current =1
	ANd HDR.BSTYP = ITM.BSTYP
LEFT JOIN [CT dwh 02 Data].[dbo].[tSAP0MAT_PLANT_ATTR] AS ATTR WITH (NOLOCK)
	ON ATTR.MATNR = ITM.MATNR
	AND ATTR.WERKS = ITM.WERKS
	AND ATTR.is_current = 1
CROSS JOIN cte_max as cmax
WHERE 1 = 1
	AND HDR.is_current = 1		
	AND Config.TransactionType = 'Contract'
	AND
	(	
	(
			(		HDR.valid_from				> cmax.maxdate
				
				OR	ITM.CD			> cmax.maxdate
				OR	ATTR.valid_from			> cmax.maxdate
			)
			AND 0 = ${Loading_Type} -- Incremental Load
		)
		OR 
		(
			1 = ${Loading_Type} -- Full Load
		)
)