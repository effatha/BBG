with cte_max as(
	Select ? as maxdate
	
)
SELECT DISTINCT 
CAST(FORMAT(ACDOCA.BUDAT,'yyyyMMdd') AS INT) AS InvoicePaidDateDimCalendarId
,ACDOCA.AWREF AS InvoiceNoPaid
,ACDOCA.DOCLN as AccountingDocItemNo
,ACDOCA.RBUKRS AS CompanyCode
,'Invoice Payment'	AS TransactionTypeDetail
,'unknown' AS TransactionTypeShort 
,ACDOCA.KSL AS InvoicePaidAmountGlobalCurr
, ACDOCA.WSL AS InvoicePaidAmountTransCurr
, ACDOCA.HSL AS InvoicePaidAmountCompCurr
,ACDOCA.RLDNR AS Ledger --dimension? data layer filter is applied ='0L'
 --purch.tdimcompany
,ACDOCA.BTTYPE AS BusinesTransactionType --dimension? data layer filter is applied ='RMRP', is it same transaction type in the config table? (meta,
,ACDOCA.AUGBL AS ClearingDocNo
,ACDOCA.GKONT AS OffsetAcctNo
,ACDOCA.WERKS AS Plant --new dimension purch.tdimplant, plantname?
,INV.EBELN AS PurchasingDocNo
FROM [CT dwh 02 Data].[dbo].[tSAP0FI_ACDOCA_10] AS ACDOCA WITH (NOLOCK)
INNER JOIN [CT dwh 02 Data].[dbo].tSAP2LIS_06_INV AS INV WITH (NOLOCK)
ON ACDOCA.AWREF = INV.BELNR -- with the join condition no match
AND INV.is_current=1
AND INV.RBSTAT='5'
AND INV.ebeln <> ''
CROSS JOIN cte_max as cmax
WHERE 1=1
AND ACDOCA.RLDNR = '0L'
AND ACDOCA.RBUKRS IN ('1000','5100')
AND ACDOCA.BTTYPE ='RMRP'
AND (ACDOCA.AUGBL BETWEEN '2000000000' and '2009999999' or ACDOCA.AUGBL BETWEEN '1500000000' and '1599999999')
AND RIGHT(ACDOCA.GKONT,8)='21120000'
AND ACDOCA.is_current=1
AND
	(	
	(
			(		ACDOCA.valid_from				> cmax.maxdate
				OR	INV.valid_from			> cmax.maxdate
			)
			AND 0 = ${Loading_Type} -- Incremental Load
		)
		OR 
		(
			1 = ${Loading_Type} -- Full Load
		)
)