
;WITH cte_max as(
	Select ? as maxdate
	
)



SELECT 
	EBELN											AS ProcessId --PK
	--, EBELN											AS DocumentNo 	
	, EBELP											AS DocumentItemPosition -- PK 	
	, ZEKKN											AS AccountAssignmentNo 	-- PK 	
	, VGABE											AS SDDocCategoryTransactionTypeShort 	-- PK -- Dimension
	, GJAHR											AS MaterialDocumentYear 	-- should not come from [CT dwh 03 Intelligence].[dim].[tDimCalendar] as defined in the ticket --> fact -- PK
	, BELNR											AS MaterialDocumentNo 	-- PK
	, BUZEI											AS MaterialDocumentItemNo -- PK
	, 'POTransactions'								AS TransactionTypeDetail	
	, BEWTP											AS POHistoryCategoryShort -- new Dimension	
	, CAST(FORMAT(BUDAT,'yyyyMMdd') AS INT)         AS TransactionDateDimCalendarID	 	-- Dimension
	, MENGE											AS Quantity 	
	, BWART											AS TransactionTypeShort 	-- Dimension
	, DMBTR											AS [Value] 	
	, WRBTR											AS ValueForeignCurrency 	
	, WAERS											AS Currency 	
	, AREWR											AS ValueForeignCurrencyGRIR 	
	, SHKZG											AS DebitCreditIndicator
	, WERKS											AS Plant -- Dimension
	, WAERS010 										AS DocumentCurrency
FROM [CT dwh 02 Data].[dbo].[tSAPZ_MM_EKBE] AS EKBE WITH (NOLOCK)
CROSS JOIN cte_max as cmax 
WHERE 1 = 1
	AND is_current = 1

AND

	(	
	(
			EKBE.valid_from				>= cmax.maxdate
			AND 0 = ${Loading_Type} -- Incremental Load
		)
		OR 
		(
			1 = ${Loading_Type} -- Full Load
		))















