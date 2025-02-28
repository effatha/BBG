TRUNCATE TABLE TEST.L1_FACT_A_CLAIM_RATES




---- RELATED REFUNDS
;with CTE_PROCESSID_VALUES AS (
	
	SELECT 
		ProcessID,
		ProcessIDPosition = cast(ProcessIDPosition/100 as int),
		ProcessIdDate,
		ItemID = ISNULL(ItemParentID,ItemID),
		ChannelId,
		Fulfillment,
		DeliveryCountry,
		GrossOrderValue =	SUM(GrossOrderValue),
		ItemQty = SUM(OrderQuantity)
		FROM [PL].[PL_V_SALES_TRANSACTIONS] pl
		INNER JOIN  PL.PL_V_SALES_TRANSACTION_TYPE typ on typ.TransactionTypeID= pl.TransactionTypeID
		AND TransactionType in ('Order')
	where 1=1
	AND	source = 'SAP'
	and ISNULL(IncidentFlag,'N') = 'N'
	and ISNULL(ReasonForRejections,'')=''
	GROUP BY ProcessID,ISNULL(ItemParentID,ItemID),ChannelId,Fulfillment,cast(ProcessIDPosition/100 as int),DeliveryCountry,ProcessIdDate

)
, cte_related_refunds AS (
SELECT 
	 sales.CD_SALES_PROCESS_ID
	 ,sales.D_SALES_PROCESS
	 ,CD_SALES_PROCESS_LINE = cast(sales.CD_SALES_PROCESS_LINE / 100  as int)
	 ,sales.D_CREATED
	,fact.ID_ITEM
	,fact.D_FI_POSTING
	,sales.CD_DOCUMENT_NO
	,sales.CD_DOCUMENT_LINE
	,sales.CD_TYPE
	,fact.[CD_REFERENCE_DOCUMENT_NO]
	,fact.[CD_REFERENCE_DOCUMENT_LINE]
	,CD_FI_DOCUMENT_NO
	,CD_FI_DOCUMENT_LINE
	,[AMT_REFUNDS_EUR]																= SUM(fact.AMT_AMOUNT_COMPANY * isnull(matrix.[VL_REFUNDS_PARAM],0))
	,[VL_REFUNDS_QTY]																= SUM(fact.VL_QUANTITY * isnull(matrix.[VL_REFUNDS_PARAM],0))
	,[VL_REPLACEMENT_QTY]															= SUM(fact.VL_QUANTITY * isnull(matrix.[VL_NET_PRODUCT_COSTS_THEREOF_REPLACEMENT_MEK_PARAM],0))
FROM L1_FIN.L1_FACT_A_GENERAL_LEDGER fact
	LEFT JOIN [L1].[L1_DIM_A_SALES_TRANSACTION_TYPE] fkart
		ON fkart.ID_SALES_TRANSACTION_TYPE = fact.ID_SALES_TRANSACTION_TYPE
	LEFT JOIN L1.L1_FACT_A_SALES_TRANSACTION sales on sales.[ID_SALES_TRANSACTION] =  fact.[ID_SALES_TRANSACTION]
	LEFT JOIN [L1].[L1_FACT_A_STOCK_MOVEMENT] stock
		ON stock.CD_DOCUMENT_NO = fact.CD_REFERENCE_DOCUMENT_NO
			AND cast(stock.CD_DOCUMENT_LINE as int) = CAST(fact.CD_REFERENCE_DOCUMENT_LINE as int)
			AND cast(stock.NUM_POSTING_YEAR as nvarchar(10))= fact.CD_REFERENCE_ORG_UNIT
	INNER JOIN [L1_FIN].[L1_DIM_A_FINANCE_TRAN_KPI_MATRIX] matrix
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
			AND (matrix.CD_MSR_RETURNS_REASON = sales.CD_RETURN_REASON OR matrix.CD_MSR_RETURNS_REASON is null)

	WHERE 1=1
			AND (matrix.[VL_NET_PRODUCT_COSTS_THEREOF_REPLACEMENT_MEK_PARAM]=1 OR matrix.[VL_REFUNDS_PARAM]=1)
	GROUP BY
		sales.CD_DOCUMENT_NO,
		fact.ID_ITEM,
		fact.D_FI_POSTING,
		sales.CD_SALES_PROCESS_ID,
		sales.D_SALES_PROCESS,
		sales.D_created,
		sales.CD_DOCUMENT_LINE,
		sales.CD_TYPE,
		cast(sales.CD_SALES_PROCESS_LINE / 100  as int),
			fact.[CD_REFERENCE_DOCUMENT_NO]
	,fact.[CD_REFERENCE_DOCUMENT_LINE]
	,CD_FI_DOCUMENT_NO
	,CD_FI_DOCUMENT_LINE
),
cte_returns as
(
	SELECT KDAUF,KDPOS = Cast(KDPOS/100 as int),count(*) ReturnQTY
  FROM L0.L0_S4HANA_2LIS_03_BF bf
	where 
		bf.BWART = '657'
	GROUP BY KDAUF,Cast(KDPOS/100 as int)
)
INSERT INTO  TEST.L1_FACT_A_CLAIM_RATES
(
	
	ProcessId 		
	,ProcessIDLine
	,DocumentNo						
	,DocumentType 					
	,DocumentLine	
	,FIDocumentNo
	,FIDocumentLine
	,RefDocumentNo
	,RefDocumentLine
	,OrderDate 						
	,DocumentDate	
	,PostingDate
	,DeliveryCountry				
	,ItemId 	
	,ItemNo
	,ChannelId						
	,Fulfillment					
	,GrossOrderValue				
	,ItemQty						
	,RefundValue 					
	,RefundQty 						
	,ReplacementQty 				
	,ReturnQty 						
	,IsFullRefund 					
	,IsExcessRefund					
)
SELECT
	ProcessId = process.ProcessID ,
	ProcessIDLine = process.ProcessIDPosition ,
	DocumentNo= rel_ref.CD_DOCUMENT_NO,
	DocumentType = CD_TYPE,
	DocumentLine= rel_ref.CD_DOCUMENT_LINE,
	FIDocumentNo = rel_ref.CD_FI_DOCUMENT_NO,
	FIDocumentLine = rel_ref.CD_FI_DOCUMENT_LINE,
	RefDocumentNo = rel_ref.[CD_REFERENCE_DOCUMENT_NO],
	RefDocumentLine = rel_ref.[CD_REFERENCE_DOCUMENT_LINE],
	OrderDate = ProcessIdDate,
	DocumentDate =  rel_ref.D_CREATED,
	PostingDate	 = D_FI_POSTING,
	DeliveryCountry,
	ItemId = ISNULL(rel_ref.ID_ITEM,process.ItemID),
	ItemNo = it.ItemNo,
	ChannelId,
	Fulfillment,
	GrossOrderValue,
	ItemQty,
	RefundValue = [AMT_REFUNDS_EUR],
	RefundQty = [VL_REFUNDS_QTY],
	ReplacementQty = [VL_REPLACEMENT_QTY],
	ReturnQty =	ReturnQTY,
	IsFullRefund = CASE WHEN SUM([VL_REFUNDS_QTY]) over(partition by ProcessId,process.ProcessIDPosition) <> 0  AND ABS((SUM([AMT_REFUNDS_EUR]) over(partition by ProcessId,process.ProcessIDPosition)) - ( SUM(GrossOrderValue) over(partition by ProcessId,process.ProcessIDPosition))/((SUM([VL_REFUNDS_QTY]) over(partition by ProcessId,process.ProcessIDPosition) ))) <1 THEN 'Y' ELSE 'N' END,
	IsExcessRefund = CASE WHEN SUM([VL_REFUNDS_QTY]) over(partition by ProcessId,process.ProcessIDPosition) <> 0  AND  (( SUM(GrossOrderValue) over(partition by ProcessId,process.ProcessIDPosition)/((SUM([VL_REFUNDS_QTY]) over(partition by ProcessId,process.ProcessIDPosition))))-(SUM([AMT_REFUNDS_EUR]) over(partition by ProcessId,process.ProcessIDPosition))) < -1 THEN 'Y' ELSE 'N' END
FROM CTE_PROCESSID_VALUES process
LEFT JOIN  cte_related_refunds rel_ref
	on process.ProcessID = CD_SALES_PROCESS_ID
		AND process.ItemId = ID_ITEM 
		AND ProcessIDPosition = CD_SALES_PROCESS_LINE
LEFT JOIN cte_returns ret on ret.KDAUF = rel_ref.CD_DOCUMENT_NO and ret.KDPOS = cast(CD_DOCUMENT_LINE/100 as int)
Left JOIN PL.PL_V_ITEM it on it.ItemID = ISNULL(rel_ref.ID_ITEM,process.ItemID)