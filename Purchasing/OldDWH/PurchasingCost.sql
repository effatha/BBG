
;WITH cte_max as(
	Select ? as maxdate
	
)


SELECT 
EBELN	AS ProcessID
--,EBELN	AS  DocumentNo						
,EBELP	AS DocumentItemPosition				
,STUNR	AS StepNumber	 
,ZAEHK	AS [Counter]		
,VGABE AS	SDDocCategroyTransactionTypeShort
--,GJAHR AS TransactionYear
,BELNR AS	MaterialDocumentNo	
,BUZEI AS	MaterialDocumentItemNo	
,CAST(FORMAT(BUDAT,'yyyyMMdd') AS INT)  AS TransactionDateDimCalendarID
,'PurchaseCost'	 AS TransactionTypeDetail
,KSCHL AS	TransactionTypeShort
,BEWTP AS	POHistoryCategoryShort	

,MENGE AS	Quantity					
,DMBTR AS	[Value]						
,WRBTR AS	ValueForeignCurrency		
,WAERS AS	Currency					
,AREWR AS	ValueForeignCurrencyGRIR	 
,SHKZG AS	DebitCreditIndicator
,CAST(FORMAT(CPUDT,'yyyyMMdd') AS INT) AS PurchaseCostCreationDateDimCalendarID
,CAST(CPUTM AS int) AS	PurchaseCostCreationDateDimTimeID	
,BWTAR AS	ItemValuationType		
,AREWW AS	ValueForeignCurrencyGRIRClearing	
--,WKURS AS	ExchangeRate
, CAST(CASE																									
		WHEN WKURS < 0	THEN (1 / ABS(WKURS))															
			ELSE ABS(WKURS)																					
	  END AS DECIMAL(30, 20))											AS ExchangeRate	
,WAERS003 AS DocumentCurrency					
FROM [CT dwh 02 Data].[dbo].[tSAPZ_MM_EKBZ] as EKBZ WITH (NOLOCK)
cross join cte_max as cmax




WHERE 1 = 1

AND EKBZ.is_current=1
AND EKBZ.is_deleted=0

AND

	(	
	(
			EKBZ.valid_from				>= cmax.maxdate
			AND 0 = ${Loading_Type} -- Incremental Load
		)
		OR 
		(
			1 = ${Loading_Type} -- Full Load
		))









