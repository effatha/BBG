DECLARE @NUM_POSTING_PERIOD as int = 5
DECLARE @NUM_POSTING_YEAR as int = 2023
/*****************************************************************************
** Delete data that may already being calculated for the same period
*****************************************************************************/

DELETE FROM [L1].[L1_FACT_F_SALES_FINANCE_RECONCILIATION] WHERE [NUM_POSTING_YEAR]=@NUM_POSTING_YEAR AND  [NUM_POSTING_PERIOD] =@NUM_POSTING_PERIOD

/*****************************************************************************
** CTE responsible for calculate for the given period the values from ACDOCA based transactions
** according to the kpi accounting matrix
*****************************************************************************/

; WITH  CTE_ACDOCA as (
	SELECT 
		   [CD_DOCUMENT_NO]  AS [CD_DOCUMENT_NO]
		  ,[NUM_POSTING_YEAR]
		  ,[NUM_POSTING_PERIOD]
		  ,SUM(ISNULL(AMT_NET_ORDER_VALUE_FI_EUR,0) )							AS AMT_NET_ORDER_VALUE_FI_EUR
		  ,SUM(ISNULL(AMT_REVENUE_MANUAL_POSTING_FI_EUR,0))						AS AMT_REVENUE_MANUAL_POSTING_FI_EUR
		  ,SUM(ISNULL(AMT_REFUNDED_ORDER_VALUE_FI_EUR,0))						AS AMT_REFUNDED_ORDER_VALUE_FI_EUR	
		  ,SUM(ISNULL(AMT_NET_PRODUCT_COST_FI_EUR,0))							AS AMT_NET_PRODUCT_COST_FI_EUR
		  ,SUM(ISNULL(AMT_FX_HEDGING_IMPACT_FI_EUR,0) )							AS AMT_FX_HEDGING_IMPACT_FI_EUR
		  ,SUM(ISNULL(AMT_STOCK_ADJUSTMENTS_FI_EUR,0) )							AS AMT_STOCK_ADJUSTMENTS_FI_EUR
		  ,SUM(ISNULL(AMT_DEMURRAGE_DETENTION_FI_EUR,0) )						AS AMT_DEMURRAGE_DETENTION_FI_EUR
		  ,SUM(ISNULL(AMT_DEADFREIGHT_FI_EUR,0) )								AS AMT_DEADFREIGHT_FI_EUR
		  ,SUM(ISNULL(AMT_KICKBACKS_FI_EUR,0) )									AS AMT_KICKBACKS_FI_EUR
		  ,SUM(ISNULL(AMT_3RD_PARTY_SERVICES_FI_EUR,0) )						AS AMT_3RD_PARTY_SERVICES_FI_EUR
		  ,SUM(ISNULL(AMT_RMA_FI_EUR,0) )										AS AMT_RMA_FI_EUR
		  ,SUM(ISNULL(AMT_SAMPLES_FI_EUR,0) )									AS AMT_SAMPLES_FI_EUR
		  ,SUM(ISNULL(AMT_DROPSHIPMENT_CEOTRA9ER_ARTIKEL_FI_EUR,0) )			AS AMT_DROPSHIPMENT_CEOTRA9ER_ARTIKEL_FI_EUR
		  ,SUM(ISNULL(AMT_INBOUND_FREIGHT_COST_FI_EUR,0) )						AS AMT_INBOUND_FREIGHT_COST_FI_EUR
		  ,SUM(ISNULL(AMT_PO_CANCELLATION_FI_EUR,0) )							AS AMT_PO_CANCELLATION_FI_EUR
		  FROM WR.WR_L1_FACT_A_SALES_ACCOUNTING_VALUE
	  WHERE 
		[NUM_POSTING_YEAR] = @NUM_POSTING_YEAR 
		AND [NUM_POSTING_PERIOD] =@NUM_POSTING_PERIOD
	 GROUP BY [CD_DOCUMENT_NO],[NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]
),
/*****************************************************************************
** CTE responsible for calculate the PL line based on sales orders data. It's not 
** limited by period, as we may have sales values recoghnize this period but not invoiced
** or invoiced but sales recognized in previous periods
*****************************************************************************/
 CTE_SALES_ORDERS as 
(

	SELECT 
		 			CASE WHEN TransactionTypeShort in   ('ZRBI','ZREM','ZRSD','ZRET','ZGA1','ZGA2','ZGK','ZKR') and isnull(ReferenceDocumentId,'') <> '' AND ReferenceDocumentId like '14%' THEN  ReferenceDocumentId  
			  WHEN TransactionTypeShort in   ('ZRBI','ZREM','ZRSD','ZRET','ZGA1','ZGA2','ZGK','ZKR') and isnull(ReferenceDocumentId,'') = '' THEN   DocumentNo 
				ELSE DocumentNo END																														AS [CD_DOCUMENT_NO]
		,MONTH(vahdr.ERDAT)																																AS [NUM_POSTING_PERIOD]
		,YEAR(vahdr.ERDAT)																																AS [NUM_POSTING_YEAR]
		--NOV
		,SUM( CASE WHEN isnull(ReasonForRejections,'')  = '' 
									THEN pl.GrossOrderValue  ELSE 0 END)																				AS [AMT_NET_ORDER_VALUE_ACT_EUR]
		,sum(NetOrderValueEst)																															AS [AMT_NET_ORDER_VALUE_EST_EUR]
		--REFUNDS
		,sum(CASE WHEN TransactionTypeShort in  ('ZRBI','ZREM','ZRSD','ZRET','ZGA1','ZGA2','ZGK','ZKR') THEN NetPrice ELSE 0 END)						AS [AMT_REFUNDED_ORDER_VALUE_ACT_EUR]
		,sum(RefundedOrderValueEst)																														AS [AMT_REFUNDED_ORDER_VALUE_EST_EUR]
		--PRODUCT COST
		,sum(CASE WHEN TransactionTypeShort in ('ZAA','ZAZ','ZKE','ZSD2') THEN MEKHedging - [GTSMarkup] ELSE 0 END)										AS [AMT_NET_PRODUCT_COST_ACT_EUR]
		,sum(NetProductCostEst)																															AS [AMT_NET_PRODUCT_COST_EST_EUR]
		,sum(CASE WHEN TransactionTypeShort in ('ZAA','ZAZ','ZKE','ZSD2') THEN [GTSMarkup] ELSE 0 END)													AS [AMT_NET_PRODUCT_COST_GTS_ACT]
		-- PC1 Lines																																	
		,SUM(FXHedgingImpactEst)																														AS [AMT_FX_HEDGING_IMPACT_EST_EUR]
		,SUM(COGSStockValueAdjustmentEst)																												AS [AMT_STOCK_ADJUSTMENTS_EST_EUR]
		,SUM(DemurrageDetention)																														AS [AMT_DEMURRAGE_DETENTION_EST_EUR]
		,SUM(Deadfreight)																																AS [AMT_DEADFREIGHT_EST_EUR]
		,SUM(Kickbacks)																																	AS [AMT_KICKBACKS_EST_EUR]
		,SUM([3rdPartyServices])																														AS [AMT_3RD_PARTY_SERVICES_EST_EUR]
		,SUM(RMA)																																		AS [AMT_RMA_EST_EUR]
		,SUM(Samples)																																	AS [AMT_SAMPLES_EST_EUR]
		,SUM(DropShipmentCEOTRA9erArtikelEst)																											AS [AMT_DROPSHIPMENT_CEOTRA9ER_ARTIKEL_EST_EUR]
		,SUM(InboundFreightCostsEst)																													AS [AMT_INBOUND_FREIGHT_COST_EST_EUR]
		,SUM(POCancellation)																															AS [AMT_PO_CANCELLATION_EST_EUR]
		--- first pl LINES							  
		,SUM(Turnover)																																	AS [AMT_TURNOVER_EUR]
		,SUM( CASE WHEN  ReasonForRejections <>'Wrongly created' THEN pl.OrderQuantity  ELSE 0 END)														AS [VL_ORDER_QUANTITY]
		,SUM(ValueAddedTax)																																AS [AMT_VALUE_ADDED_TAX_EUR]
		,SUM(OrderDiscounts)																															AS [AMT_NET_DISCOUNT_EUR]
		,SUM(OrderCharges)																																AS [AMT_ORDER_CHARGES_EUR]
		,SUM(GrossOrderValue)																															AS [AMT_GROSS_ORDER_VALUE_EUR]
		,SUM( CASE WHEN  isnull(ReasonForRejections,'')  <> '' and ReasonForRejections <>'Wrongly created' THEN pl.OrderQuantity  ELSE 0 END)			AS [VL_CANCELLED_ORDERS_QUANTITY_ACT]
		,SUM(CancelledOrdersQuantityEst)																												AS [VL_CANCELLED_ORDERS_QUANTITY_EST]	
		,SUM( CASE WHEN  isnull(ReasonForRejections,'')  <> '' and ReasonForRejections <>'Wrongly created' THEN pl.GrossOrderValue  ELSE 0 END)			AS [AMT_CANCELLED_ORDER_VALUE_ACT_EUR]
		,SUM(CancelledOrderValueEst)																													AS [AMT_CANCELLED_ORDER_VALUE_EST_EUR]
		,SUM( CASE WHEN  isnull(ReasonForRejections,'')  = '' THEN pl.OrderQuantity  ELSE 0 END)														AS [VL_NET_ORDER_QUANTITY_ACT]
		,SUM(NetOrderQuantityEst)																														AS [VL_NET_ORDER_QUANTITY_EST]
FROM PL.PL_V_SALES_TRANSACTIONS PL
INNER JOIN L0.L0_S4HANA_2LIS_11_VAHDR vahdr
	on vahdr.VBELN  = pl.DocumentNo 
	 
WHERE SOURCE = 'SAP'
GROUP BY 
			CASE WHEN TransactionTypeShort in   ('ZRBI','ZREM','ZRSD','ZRET','ZGA1','ZGA2','ZGK','ZKR') and isnull(ReferenceDocumentId,'') <> '' AND ReferenceDocumentId like '14%' THEN  ReferenceDocumentId 
			  WHEN TransactionTypeShort in   ('ZRBI','ZREM','ZRSD','ZRET','ZGA1','ZGA2','ZGK','ZKR') and isnull(ReferenceDocumentId,'') = '' THEN   DocumentNo 
				ELSE DocumentNo END	
				,MONTH(vahdr.ERDAT),YEAR(vahdr.ERDAT)
)

INSERT INTO [L1].[L1_FACT_F_SALES_FINANCE_RECONCILIATION]
 (
             [CD_DOCUMENT_NO]
		    ,[NUM_POSTING_YEAR]
            ,[NUM_POSTING_PERIOD]
		   ---FIRTSL PL LINES
			,[AMT_TURNOVER_EUR] 					  
			,[VL_ORDER_QUANTITY] 				  
			,[AMT_VALUE_ADDED_TAX_EUR]
			,[AMT_NET_DISCOUNT_EUR]
			,[AMT_ORDER_CHARGES_EUR] 			  
			,[AMT_GROSS_ORDER_VALUE_EUR]
			,[VL_CANCELLED_ORDERS_QUANTITY_ACT]
			,[VL_CANCELLED_ORDERS_QUANTITY_EST]		  
			,[AMT_CANCELLED_ORDER_VALUE_ACT_EUR] 		  
			,[AMT_CANCELLED_ORDER_VALUE_EST_EUR]			  
			,[VL_NET_ORDER_QUANTITY_ACT] 			  
			,[VL_NET_ORDER_QUANTITY_EST] 
			---NOV
           ,[AMT_NET_ORDER_VALUE_FI_EUR]
           ,[AMT_NET_ORDER_VALUE_ACT_EUR_INVOICED_IN_PERIOD]
           ,[AMT_NET_ORDER_VALUE_ACT_EUR_PRIOR_PERIODS]
           ,[AMT_NET_ORDER_VALUE_ACT_EUR_NOT_INVOICED]
           ,[AMT_NET_ORDER_VALUE_EST_EUR]
			-- REFUNDS
		   ,[AMT_REFUNDED_ORDER_VALUE_FI_EUR]
		   ,[AMT_REFUNDED_ORDER_VALUE_ACT_EUR_INVOICED_IN_PERIOD]
		   ,[AMT_REFUNDED_ORDER_VALUE_ACT_EUR_PRIOR_PERIODS]
		   ,[AMT_REFUNDED_ORDER_VALUE_ACT_EUR_NOT_INVOICED]
		   ,[AMT_REFUNDED_ORDER_VALUE_EST_EUR]
		   --REVENUE
		   ,[AMT_REVENUE_MANUAL_POSTING_FI_EUR]
		   --NET PRODUCT COST WITH GTS
		   ,[AMT_NET_PRODUCT_COST_FI_EUR]
		   --NET PRODUCT COST
		   ,[AMT_NET_PRODUCT_COST_ACT_EUR_INVOICED_IN_PERIOD]
		   ,[AMT_NET_PRODUCT_COST_ACT_EUR_PRIOR_PERIODS]
		   ,[AMT_NET_PRODUCT_COST_ACT_EUR_NOT_INVOICED]
		   ,[AMT_NET_PRODUCT_COST_EST_EUR]
		   --NET PRODUCT COST ONLY GTS
		   ,[AMT_NET_PRODUCT_COST_GTS_ACT_INVOICED_IN_PERIOD]
		   ,[AMT_NET_PRODUCT_COST_GTS_ACT_PRIOR_PERIODS]
		   ,[AMT_NET_PRODUCT_COST_GTS_ACT_NOT_INVOICED]
		   --PC1 Lines 
		   ,[AMT_FX_HEDGING_IMPACT_FI_EUR]
		   ,[AMT_STOCK_ADJUSTMENTS_FI_EUR]
		   ,[AMT_DEMURRAGE_DETENTION_FI_EUR]
		   ,[AMT_DEADFREIGHT_FI_EUR]
		   ,[AMT_KICKBACKS_FI_EUR]
		   ,[AMT_3RD_PARTY_SERVICES_FI_EUR]
		   ,[AMT_RMA_FI_EUR]
		   ,[AMT_SAMPLES_FI_EUR]
		   ,[AMT_DROPSHIPMENT_CEOTRA9ER_ARTIKEL_FI_EUR]
		   ,[AMT_INBOUND_FREIGHT_COST_FI_EUR]
		   ,[AMT_PO_CANCELLATION_FI_EUR]
		   ,[AMT_FX_HEDGING_IMPACT_EST_EUR]
		   ,[AMT_STOCK_ADJUSTMENTS_EST_EUR]
		   ,[AMT_DEMURRAGE_DETENTION_EST_EUR]
		   ,[AMT_DEADFREIGHT_EST_EUR]
		   ,[AMT_KICKBACKS_EST_EUR]
		   ,[AMT_3RD_PARTY_SERVICES_EST_EUR]
		   ,[AMT_RMA_EST_EUR]
		   ,[AMT_SAMPLES_EST_EUR]
		   ,[AMT_DROPSHIPMENT_CEOTRA9ER_ARTIKEL_EST_EUR]
		   ,[AMT_INBOUND_FREIGHT_COST_EST_EUR]
		   ,[AMT_PO_CANCELLATION_EST_EUR]
           ,[DT_DWH_CREATED]
           ,[DT_DWH_UPDATED]
) -- end insert
/*****************************************************************************
** FIRST SELECT. It gets all the PL lines from accounting fact table and match 
** the correspondent values from the sales.
*****************************************************************************/
SELECT 
	ac.[CD_DOCUMENT_NO]
	,ac.[NUM_POSTING_YEAR]
	,ac.[NUM_POSTING_PERIOD]
	   ---FIRSL PL LINES
	,sales.[AMT_TURNOVER_EUR] 					  
	,sales.[VL_ORDER_QUANTITY] 				  
	,sales.[AMT_VALUE_ADDED_TAX_EUR] 			  
	,sales.[AMT_NET_DISCOUNT_EUR] 		  
	,sales.[AMT_ORDER_CHARGES_EUR] 			  
	,sales.[AMT_GROSS_ORDER_VALUE_EUR] 			  
	,sales.[VL_CANCELLED_ORDERS_QUANTITY_ACT] 	  
	,sales.[VL_CANCELLED_ORDERS_QUANTITY_EST] 		  
	,sales.[AMT_CANCELLED_ORDER_VALUE_ACT_EUR] 		  
	,sales.[AMT_CANCELLED_ORDER_VALUE_EST_EUR] 			  
	,sales.[VL_NET_ORDER_QUANTITY_ACT] 			  
	,sales.[VL_NET_ORDER_QUANTITY_EST] 
	---NOV
	,ac.[AMT_NET_ORDER_VALUE_FI_EUR] * -1																						AS [AMT_NET_ORDER_VALUE_FI_EUR]
	,CASE WHEN ac.[NUM_POSTING_YEAR] = sales.NUM_POSTING_YEAR and ac.[NUM_POSTING_PERIOD] = sales.NUM_POSTING_PERIOD 
				THEN sales.[AMT_NET_ORDER_VALUE_ACT_EUR]	ELSE 0 END															AS [AMT_NET_ORDER_VALUE_ACT_EUR_INVOICED_IN_PERIOD]
	,CASE WHEN (ac.[NUM_POSTING_YEAR] > sales.NUM_POSTING_YEAR) OR (ac.[NUM_POSTING_YEAR] = sales.NUM_POSTING_YEAR 
					and ac.[NUM_POSTING_PERIOD] > sales.NUM_POSTING_PERIOD) THEN sales.[AMT_NET_ORDER_VALUE_ACT_EUR] ELSE 0 END	AS [AMT_NET_ORDER_VALUE_ACT_EUR_PRIOR_PERIODS]
	,CASE WHEN (ac.[NUM_POSTING_YEAR] < sales.NUM_POSTING_YEAR) OR (ac.[NUM_POSTING_YEAR] = sales.NUM_POSTING_YEAR 
				and ac.[NUM_POSTING_PERIOD] < sales.NUM_POSTING_PERIOD) THEN sales.[AMT_NET_ORDER_VALUE_ACT_EUR] ELSE 0 END		AS [AMT_NET_ORDER_VALUE_ACT_EUR_NOT_INVOICED] --- This should be zero here as we are only retrieving acdoca data for the period. Its here as a precaution
	,[AMT_NET_ORDER_VALUE_EST_EUR]
	-- REFUNDS
	,ac.AMT_REFUNDED_ORDER_VALUE_FI_EUR
	,CASE WHEN ac.[NUM_POSTING_YEAR] = sales.[NUM_POSTING_YEAR] and ac.[NUM_POSTING_PERIOD] = sales.[NUM_POSTING_PERIOD] 
		THEN CASE WHEN abs(ac.AMT_REFUNDED_ORDER_VALUE_FI_EUR) > 0 
		THEN sales.[AMT_REFUNDED_ORDER_VALUE_ACT_EUR] ELSE 0 END *-1	ELSE 0 END												AS [AMT_REFUNDED_ORDER_VALUE_ACT_EUR_INVOICED_IN_PERIOD]

	,CASE WHEN (ac.[NUM_POSTING_YEAR] > sales.[NUM_POSTING_YEAR]) OR 
		(ac.[NUM_POSTING_YEAR] = sales.[NUM_POSTING_YEAR] and ac.[NUM_POSTING_PERIOD] > sales.[NUM_POSTING_PERIOD]) 
		THEN CASE WHEN abs(ac.AMT_REFUNDED_ORDER_VALUE_FI_EUR) > 0 THEN sales.[AMT_REFUNDED_ORDER_VALUE_ACT_EUR] ELSE 0 END *-1 
		ELSE 0 END																												AS [AMT_REFUNDED_ORDER_VALUE_ACT_EUR_PRIOR_PERIODS]			
    ,CASE WHEN (ac.[NUM_POSTING_YEAR] < sales.[NUM_POSTING_YEAR])		
			OR (ac.[NUM_POSTING_YEAR] = sales.[NUM_POSTING_YEAR] and ac.[NUM_POSTING_PERIOD] < sales.[NUM_POSTING_PERIOD]) 
		THEN CASE WHEN abs(ac.AMT_REFUNDED_ORDER_VALUE_FI_EUR) > 0 THEN sales.[AMT_REFUNDED_ORDER_VALUE_ACT_EUR] ELSE 0 END *-1
			ELSE 0 END																											AS [AMT_REFUNDED_ORDER_VALUE_ACT_EUR_NOT_INVOICED]
	,sales.[AMT_REFUNDED_ORDER_VALUE_EST_EUR]

	---REVENUE
	,ac.[AMT_REVENUE_MANUAL_POSTING_FI_EUR]
	--NET PRODUCT COST WITH GTS
	,ac.AMT_NET_PRODUCT_COST_FI_EUR
	--NET PRODUCT COST
	,CASE WHEN ac.[NUM_POSTING_YEAR] = sales.[NUM_POSTING_YEAR] and ac.[NUM_POSTING_PERIOD] = sales.[NUM_POSTING_PERIOD] 
			THEN sales.[AMT_NET_PRODUCT_COST_ACT_EUR] ELSE 0 END																AS [AMT_NET_PRODUCT_COST_ACT_EUR_INVOICED_IN_PERIOD]
	,CASE WHEN (ac.[NUM_POSTING_YEAR] > sales.[NUM_POSTING_YEAR]) OR (ac.[NUM_POSTING_YEAR] = sales.[NUM_POSTING_YEAR] 
						and ac.[NUM_POSTING_PERIOD] > sales.[NUM_POSTING_PERIOD]) 
			THEN sales.[AMT_NET_PRODUCT_COST_ACT_EUR] ELSE 0 END																AS [AMT_NET_PRODUCT_COST_ACT_EUR_PRIOR_PERIODS]
	,CASE WHEN (ac.[NUM_POSTING_YEAR] < sales.[NUM_POSTING_YEAR]) OR (ac.[NUM_POSTING_YEAR] = sales.[NUM_POSTING_YEAR] 
					and ac.[NUM_POSTING_PERIOD] < sales.[NUM_POSTING_PERIOD]) 
			THEN sales.[AMT_NET_PRODUCT_COST_ACT_EUR] ELSE 0 END																AS [AMT_NET_PRODUCT_COST_ACT_EUR_NOT_INVOICED]
	,sales.AMT_NET_PRODUCT_COST_EST_EUR
	--NET PRODUCT COST ONLY GTS
	,CASE WHEN ac.[NUM_POSTING_YEAR] = sales.[NUM_POSTING_YEAR] and ac.[NUM_POSTING_PERIOD] = sales.[NUM_POSTING_PERIOD] 
				THEN sales.[AMT_NET_PRODUCT_COST_GTS_ACT] ELSE 0 END															AS [AMT_NET_PRODUCT_COST_GTS_ACT_INVOICED_IN_PERIOD]
	,CASE WHEN (ac.[NUM_POSTING_YEAR] > sales.[NUM_POSTING_YEAR]) 
				OR (ac.[NUM_POSTING_YEAR] = sales.[NUM_POSTING_YEAR] and ac.[NUM_POSTING_PERIOD] > sales.[NUM_POSTING_PERIOD]) 
				THEN sales.[AMT_NET_PRODUCT_COST_GTS_ACT] 	ELSE 0 END															AS [AMT_NET_PRODUCT_COST_GTS_ACT_PRIOR_PERIODS]
	,CASE WHEN (ac.[NUM_POSTING_YEAR] < sales.[NUM_POSTING_YEAR]) 
			OR (ac.[NUM_POSTING_YEAR] = sales.[NUM_POSTING_YEAR] and ac.[NUM_POSTING_PERIOD] < sales.[NUM_POSTING_PERIOD]) 
				THEN sales.[AMT_NET_PRODUCT_COST_GTS_ACT] ELSE 0 END															AS [AMT_NET_PRODUCT_COST_GTS_ACT_NOT_INVOICED]
	  --PC1 Lines 
	,[AMT_FX_HEDGING_IMPACT_FI_EUR]
	,[AMT_STOCK_ADJUSTMENTS_FI_EUR]
	,[AMT_DEMURRAGE_DETENTION_FI_EUR]
	,[AMT_DEADFREIGHT_FI_EUR]
	,[AMT_KICKBACKS_FI_EUR]
	,[AMT_3RD_PARTY_SERVICES_FI_EUR]
	,[AMT_RMA_FI_EUR]
	,[AMT_SAMPLES_FI_EUR]
	,[AMT_DROPSHIPMENT_CEOTRA9ER_ARTIKEL_FI_EUR]
	,[AMT_INBOUND_FREIGHT_COST_FI_EUR]
	,[AMT_PO_CANCELLATION_FI_EUR]
	,[AMT_FX_HEDGING_IMPACT_EST_EUR]
	,[AMT_STOCK_ADJUSTMENTS_EST_EUR]
	,[AMT_DEMURRAGE_DETENTION_EST_EUR]
	,[AMT_DEADFREIGHT_EST_EUR]
	,[AMT_KICKBACKS_EST_EUR]
	,[AMT_3RD_PARTY_SERVICES_EST_EUR]
	,[AMT_RMA_EST_EUR]
	,[AMT_SAMPLES_EST_EUR]
	,[AMT_DROPSHIPMENT_CEOTRA9ER_ARTIKEL_EST_EUR]
	,[AMT_INBOUND_FREIGHT_COST_EST_EUR]
	,[AMT_PO_CANCELLATION_EST_EUR]
	,sysdatetime() as [DT_DWH_CREATED]
	,sysdatetime() as [DT_DWH_UPDATED]
FROM CTE_ACDOCA ac
LEFT JOIN CTE_SALES_ORDERS sales
	on sales.[CD_DOCUMENT_NO] = ac.[CD_DOCUMENT_NO]


UNION

/*****************************************************************************
** SECOND SELECT. It gets all the PL lines from sales data  
** of the period, which don't have a match in FI
*****************************************************************************/
SELECT 
	sales.[CD_DOCUMENT_NO]
	,sales.[NUM_POSTING_YEAR]
	,sales.[NUM_POSTING_PERIOD]
	   ---FIRSL PL LINES
	,sales.[AMT_TURNOVER_EUR] 					  
	,sales.[VL_ORDER_QUANTITY] 				  
	,sales.[AMT_VALUE_ADDED_TAX_EUR] 			  
	,sales.[AMT_NET_DISCOUNT_EUR] 		  
	,sales.[AMT_ORDER_CHARGES_EUR] 			  
	,sales.[AMT_GROSS_ORDER_VALUE_EUR] 			  
	,sales.[VL_CANCELLED_ORDERS_QUANTITY_ACT] 	  
	,sales.[VL_CANCELLED_ORDERS_QUANTITY_EST] 		  
	,sales.[AMT_CANCELLED_ORDER_VALUE_ACT_EUR] 		  
	,sales.[AMT_CANCELLED_ORDER_VALUE_EST_EUR] 			  
	,sales.[VL_NET_ORDER_QUANTITY_ACT] 			  
	,sales.[VL_NET_ORDER_QUANTITY_EST] 
	---NOV
	,0																		AS AMT_NET_ORDER_VALUE_FI_EUR
	,0																		AS AMT_NET_ORDER_VALUE_ACT_EUR_INVOICED_IN_PERIOD
	,0																		AS AMT_NET_ORDER_VALUE_ACT_EUR_PRIOR_PERIODS
	,sales.[AMT_NET_ORDER_VALUE_ACT_EUR]									AS AMT_NET_ORDER_VALUE_ACT_EUR_NOT_INVOICED
	,AMT_NET_ORDER_VALUE_EST_EUR
	--REFUNDS
	,0																		AS AMT_REFUNDED_ORDER_VALUE_FI_EUR
	,0																		AS AMT_REFUNDED_ORDER_VALUE_ACT_EUR_INVOICED_IN_PERIOD
	,0																		AS AMT_REFUNDED_ORDER_VALUE_ACT_EUR_PRIOR_PERIODS
	,0																		AS AMT_REFUNDED_ORDER_VALUE_ACT_EUR_NOT_INVOICED
	,AMT_REFUNDED_ORDER_VALUE_EST_EUR
	--REVENUE
	,[AMT_REVENUE_MANUAL_POSTING_FI_EUR]
	--NET PRODUCT COST WITH GTS
	,0																		AS AMT_NET_PRODUCT_COST_FI_EUR
    --NET PRODUCT COST
	,0																		AS AMT_NET_PRODUCT_COST_ACT_EUR_INVOICED_IN_PERIOD
	,0																		AS AMT_NET_PRODUCT_COST_ACT_EUR_PRIOR_PERIODS
	,[AMT_NET_PRODUCT_COST_ACT_EUR]											AS AMT_NET_PRODUCT_COST_ACT_EUR_NOT_INVOICED
	,[AMT_NET_PRODUCT_COST_EST_EUR]
	 --NET PRODUCT COST ONLY GTS
	,0																		AS AMT_NET_PRODUCT_COST_GTS_ACT_INVOICED_IN_PERIOD
	,0																		AS AMT_NET_PRODUCT_COST_GTS_ACT_PRIOR_PERIODS
	,[AMT_NET_PRODUCT_COST_GTS_ACT]											AS AMT_NET_PRODUCT_COST_GTS_ACT_NOT_INVOICED
	 --PC1 Lines
	,0																		AS [AMT_FX_HEDGING_IMPACT_FI_EUR]
	,0																		AS [AMT_STOCK_ADJUSTMENTS_FI_EUR]
	,0																		AS [AMT_DEMURRAGE_DETENTION_FI_EUR]
	,0																		AS [AMT_DEADFREIGHT_FI_EUR]
	,0																		AS [AMT_KICKBACKS_FI_EUR]
	,0																		AS [AMT_3RD_PARTY_SERVICES_FI_EUR]
	,0																		AS [AMT_RMA_FI_EUR]
	,0																		AS [AMT_SAMPLES_FI_EUR]
	,0																		AS [AMT_DROPSHIPMENT_CEOTRA9ER_ARTIKEL_FI_EUR]
	,0																		AS [AMT_INBOUND_FREIGHT_COST_FI_EUR]
	,0																		AS [AMT_PO_CANCELLATION_FI_EUR]
	,[AMT_FX_HEDGING_IMPACT_EST_EUR]
	,[AMT_STOCK_ADJUSTMENTS_EST_EUR]
	,[AMT_DEMURRAGE_DETENTION_EST_EUR]
	,[AMT_DEADFREIGHT_EST_EUR]
	,[AMT_KICKBACKS_EST_EUR]
	,[AMT_3RD_PARTY_SERVICES_EST_EUR]
	,[AMT_RMA_EST_EUR]
	,[AMT_SAMPLES_EST_EUR]
	,[AMT_DROPSHIPMENT_CEOTRA9ER_ARTIKEL_EST_EUR]
	,[AMT_INBOUND_FREIGHT_COST_EST_EUR]
	,[AMT_PO_CANCELLATION_EST_EUR]
	,sysdatetime()															as [DT_DWH_CREATED]
	,sysdatetime()															as [DT_DWH_UPDATED]
FROM CTE_SALES_ORDERS sales
LEFT JOIN CTE_ACDOCA acdoca
	on sales.[CD_DOCUMENT_NO] = acdoca.[CD_DOCUMENT_NO]
WHERE 
	acdoca.[CD_DOCUMENT_NO] is null
	AND sales.NUM_POSTING_YEAR = @NUM_POSTING_YEAR 
	AND sales.NUM_POSTING_PERIOD = @NUM_POSTING_PERIOD 








 -- wr.WR_TX_L1_FACT_SALES_ACCOUNTING__L1_FACT_F_SALES_FINANCE_RECONCILIATION @NUM_POSTING_YEAR=2023,@NUM_POSTING_PERIOD=5