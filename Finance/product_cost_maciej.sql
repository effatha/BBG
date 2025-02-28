WITH CTE_SALES_ORDERS as 
(
SELECT 
	DocumentNo = CASE WHEN TransactionTypeShort in   ('ZRBI','ZREM','ZRSD','ZRET','ZGA1','ZGA2','ZGK','ZKR') THEN ReferenceDocumentId ELSE DocumentNo END,
	DocumentType = TransactionTypeShort,
	PostingPeriod = MONTH(TransactionDate),
	FiscalYear = YEAR(TransactionDate),
	SalesDate = TransactionDate,
	NetProductCost_ACTUAL = sum(CASE WHEN TransactionTypeShort in ('ZAA','ZAZ','ZKE','ZSD2') THEN MEKHedging - [GTSMarkup] ELSE 0 END),
	NetProductCost_ACTUAL_ONLY_GTS = sum(CASE WHEN TransactionTypeShort in ('ZAA','ZAZ','ZKE','ZSD2') THEN [GTSMarkup] ELSE 0 END)
FROM PL.PL_V_SALES_TRANSACTIONS PL
WHERE SOURCE = 'SAP'
GROUP BY --DocumentNo
		CASE WHEN TransactionTypeShort in   ('ZRBI','ZREM','ZRSD','ZRET','ZGA1','ZGA2','ZGK','ZKR') THEN ReferenceDocumentId ELSE DocumentNo END
		,MONTH(TransactionDate),YEAR(TransactionDate),TransactionDate,TransactionTypeShort
)
, ACDOCA_COSTS as 
(
	SELECT
	AccountNumber					=	RACCT
	,DocumentNo						=	acdoca.[KDAUF]
--	,DocumentPosition				=	acdoca.[KDPOS]
	,DocumentType					=	acdoca.BLART
	,MovementType					=	BWART
	,FI_DATE						=	acdoca.BUDAT
	,FiscalYear						=	acdoca.[GJAHR]
	,PostingPeriod					=	acdoca.[POPER]
	,NetProductCost					=	SUM( CASE WHEN  mov.MBLNR is not null AND mov.BWART in ('Z19','Z92','601','633','634')	and  acdoca.BLART  in('WA','WL')	THEN HSL * ISNULL(KPI.NetProductCost,0) ELSE 0 END)
FROM L0.L0_S4HANA_0FI_ACDOCA_10 acdoca 
INNER JOIN L0.L0_MI_SALESACCOUNTINGMATRIX kpi
	ON kpi.AccountNumber =acdoca.RACCT
LEFT JOIN L0.L0_S4HANA_2LIS_03_BF mov
			ON	mov.[MBLNR] = acdoca.[AWREF] 
				AND CAST(mov.ZEILE AS INT) = CAST(acdoca.AWITEM AS INT)
				AND mov.[MJAHR] = acdoca.GJAHR 
				and acdoca.RACCT = '0051600000' 
LEFT JOIN L0.L0_S4HANA_BKPF accountHeader
				ON 	accountHeader.[BELNR] = acdoca.[BELNR]
					AND accountHeader.BUKRS = acdoca.RBUKRS 
					AND accountHeader.[GJAHR] = acdoca.GJAHR 
WHERE 1 = 1
	AND acdoca.RBUKRS = '1000'
	AND acdoca.RLDNR = '0L'
	and acdoca.GJAHR = 2023 
	and acdoca.poper = 5
GROUP BY 
	acdoca.[KDAUF],acdoca.[GJAHR],acdoca.[POPER], acdoca.BLART, BWART,RACCT,acdoca.FKART,acdoca.BUDAT
)

SELECT
	ac.AccountNumber,
	ac.DocumentNo,
	ac.DocumentType,
	ac.MovementType,
	ac.FI_DATE as BillingDate,
	ac.NetProductCost AS AMT_NET_PRODUCT_COST_FI,
	s.SalesDate,
	s.DocumentType AS TransactionType
	,AMT_NET_PRODUCT_COST_ACTUAL_INVOICED_IN_PERIOD =		CASE WHEN (ac.FiscalYear > s.FiscalYear) OR (ac.FiscalYear = s.FiscalYear and ac.PostingPeriod > s.PostingPeriod) 
																THEN s.NetProductCost_ACTUAL 
															ELSE 0 END
	,AMT_NET_PRODUCT_COST_ACTUAL_PRIOR_PERIODS	=			CASE WHEN (ac.FiscalYear < s.FiscalYear) OR (ac.FiscalYear = s.FiscalYear and ac.PostingPeriod < s.PostingPeriod) 
																THEN s.NetProductCost_ACTUAL 
															ELSE 0 END
FROM ACDOCA_COSTS ac
INNER JOIN  CTE_SALES_ORDERS s
	on ac.DocumentNo = s.DocumentNo



	1.552.693

	444.915.718