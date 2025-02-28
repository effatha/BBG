---- RELATED REFUNDS
;with CTE_PROCESSID_VALUES AS (
	
	SELECT 
		ProcessID,ProcessIDPosition,ItemID,ChannelId,Fulfillment,
		---Value Tax in Sage is positive and in sap  is negative. for the math to work we need to invert the signal if the tax is from sage order
		GrossOrderValue =	SUM(GrossOrderValue),
--		NetOrderValue =	SUM(NetOrderValue),
		ItemQty = SUM(OrderQuantity)
		FROM [PL].[PL_V_SALES_TRANSACTIONS] pl
		INNER JOIN  PL.PL_V_SALES_TRANSACTION_TYPE typ on typ.TransactionTypeID= pl.TransactionTypeID
		AND TransactionType in ('Order')
	where 1=1
	AND	source = 'SAP'
	and ISNULL(IncidentFlag,'N') = 'N'
	--and YEAR(TransactionDate) = 2023 
	GROUP BY ProcessID,ItemID,ChannelId,Fulfillment,ProcessIDPosition

)
, cte_related_refunds AS (
SELECT 
	 sales.CD_SALES_PROCESS_ID
	 ,sales.D_SALES_PROCESS
	 ,sales.D_CREATED
	,fact.ID_ITEM
--	,VL_QUANTITY
--	,AMT_AMOUNT_COMPANY
	--,fact.D_FI_POSTING
	--,fact.D_FI_CREATED
	,sales.CD_DOCUMENT_NO
	,sales.CD_DOCUMENT_LINE
	,[AMT_REFUNDS_EUR]																= SUM(fact.AMT_AMOUNT_COMPANY * isnull(matrix.[VL_REFUNDS_PARAM],0))
	,[VL_REFUNDS_QTY]																= SUM(fact.VL_QUANTITY * isnull(matrix.[VL_REFUNDS_PARAM],0))
	,[AMT_REFUNDS_WITHOUT_RETURNS_EUR]												= SUM(fact.AMT_AMOUNT_COMPANY * isnull(matrix.[VL_REFUNDS_THEREOF_RETURN_AVOIDANCE_CREDITS_PARAM],0))
	,[VL_REFUNDS_WITHOUT_RETURNS_QTY]												= SUM(fact.VL_QUANTITY * isnull(matrix.[VL_REFUNDS_THEREOF_RETURN_AVOIDANCE_CREDITS_PARAM],0))
	,[AMT_REFUNDS_WITH_RETURNS_EUR]													= SUM(fact.AMT_AMOUNT_COMPANY * isnull(matrix.[VL_REFUNDS_THEREOF_CREDIT_NOTES_RETURNS_PARAM],0))
	,[VL_REFUNDS_WITH_RETURNS_QTY]													= SUM(fact.VL_QUANTITY * isnull(matrix.[VL_REFUNDS_THEREOF_CREDIT_NOTES_RETURNS_PARAM],0))
	,[VL_REPLACEMENT_QTY]															= SUM(fact.VL_QUANTITY * isnull(matrix.[VL_NET_PRODUCT_COSTS_THEREOF_REPLACEMENT_MEK_PARAM],0))
FROM L1_FIN.L1_FACT_A_GENERAL_LEDGER fact
	LEFT JOIN [L1].[L1_DIM_A_SALES_TRANSACTION_TYPE] fkart
		ON fkart.ID_SALES_TRANSACTION_TYPE = fact.ID_SALES_TRANSACTION_TYPE
	LEFT JOIN L1.L1_FACT_A_SALES_TRANSACTION sales on sales.[ID_SALES_TRANSACTION] =  fact.[ID_SALES_TRANSACTION]
	LEFT JOIN [L1].[L1_FACT_A_STOCK_MOVEMENT] stock
		ON stock.CD_DOCUMENT_NO = fact.CD_REFERENCE_DOCUMENT_NO
			AND cast(stock.CD_DOCUMENT_LINE as int) = CAST(fact.CD_REFERENCE_DOCUMENT_LINE as int)
			AND cast(stock.NUM_POSTING_YEAR as nvarchar(10))= fact.CD_REFERENCE_ORG_UNIT
	INNER JOIN [L1].[L1_DIM_A_FINANCE_TRAN_KPI_MATRIX] matrix
		ON matrix.CD_ACCOUNT_NUMBER = fact.CD_ACCOUNT_NUMBER
			AND (CONCAT(matrix.CD_TRANSACTION_TYPE_FI ,'#FKART')  =fkart.[CD_SALES_TRANSACTION_TYPE]  OR (matrix.CD_TRANSACTION_TYPE_FI IS NULL ))
			AND (ISNULL(matrix.CD_DOCUMENT_TYPE_FI,'') = ISNULL(fact.CD_DOCUMENT_TYPE_FI,'') OR matrix.CD_DOCUMENT_TYPE_FI IS NULL)
			AND (ISNULL(matrix.CD_STOCK_MOVEMENT_TYPE,'') = isnull(stock.CD_STOCK_MOVEMENT_TYPE,'') OR matrix.CD_STOCK_MOVEMENT_TYPE IS NULL)
			AND (
					(matrix.FL_HAS_TCODE = 'Y' AND isnull(CD_TRANSACTION_CODE,'')<> '') 
					OR  
					(matrix.FL_HAS_TCODE = 'N' AND isnull(CD_TRANSACTION_CODE,'')= '')
				
					OR matrix.FL_HAS_TCODE IS NULL
				)
			AND (matrix.[CD_TRANSACTION_TYPE_SALES] = sales.CD_TYPE OR matrix.[CD_TRANSACTION_TYPE_SALES] is null)

	WHERE 1=1
		--	AND fact.NUM_POSTING_YEAR = 2023
		--	AND fact.NUM_POSTING_PERIOD = 11
			--AND matrix.[VL_REFUNDS_PARAM] = 1
			AND (matrix.[VL_NET_PRODUCT_COSTS_THEREOF_REPLACEMENT_MEK_PARAM]=1 OR matrix.[VL_REFUNDS_PARAM]=1)
		--	AND sales.CD_SALES_PROCESS_ID = '0404197619'
	GROUP BY
		sales.CD_DOCUMENT_NO,
		--CD_FI_DOCUMENT_LINE,
		fact.ID_ITEM,
		--fact.VL_QUANTITY,
		--fact.AMT_AMOUNT_COMPANY,
		--fact.D_FI_POSTING,
		--fact.D_FI_CREATED,
		sales.CD_SALES_PROCESS_ID,
		sales.D_SALES_PROCESS,
		sales.D_created,
		sales.CD_DOCUMENT_LINE
),
cte_returns as
(
	SELECT KDAUF,KDPOS,count(*) ReturnQTY
  FROM L0.L0_S4HANA_2LIS_03_BF bf
	where 
		bf.BWART = '657'
	GROUP BY KDAUF,KDPOS
)

SELECT 
	ProcessId = CD_SALES_PROCESS_ID,
	DocumentNo= rel_ref.CD_DOCUMENT_NO,
	DocumentLine= rel_ref.CD_DOCUMENT_LINE,
	OrderDate = D_SALES_PROCESS,
	DocumentDate =  rel_ref.D_CREATED,
	ItemId = ID_ITEM,
	ChannelId,
	Fulfillment,
	GrossOrderValue,
	ItemQty,
	RefundValue = [AMT_REFUNDS_EUR],
	RefundQty = [VL_REFUNDS_QTY],
	ReplacementQty = [VL_REPLACEMENT_QTY],
	ReturnQty =	ReturnQTY,
	IsFullRefund = CASE WHEN ABS([AMT_REFUNDS_EUR] - GrossOrderValue) <1 THEN 1 ELSE 0 END,
	IsExcessRefund = CASE WHEN ABS([AMT_REFUNDS_EUR] - GrossOrderValue) >1 THEN 1 ELSE 0 END

FROM CTE_PROCESSID_VALUES process
LEFT JOIN  cte_related_refunds rel_ref
	on process.ProcessID = CD_SALES_PROCESS_ID
		AND process.ItemId = ID_ITEM 
		AND ProcessIDPosition = CD_DOCUMENT_LINE
LEFT JOIN cte_returns ret on ret.KDAUF = rel_ref.CD_DOCUMENT_NO and ret.KDPOS = CD_DOCUMENT_LINE
where D_SALES_PROCESS>='2024-01-01' or rel_ref.D_CREATED>= '2024-01-01'
	--rel_ref.CD_SALES_PROCESS_ID = '0403332491'






