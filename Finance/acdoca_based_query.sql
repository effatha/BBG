DELETE FROM WR.WR_L1_FACT_A_SALES_ACCOUNTING_VALUE;

INSERT INTO WR.WR_L1_FACT_A_SALES_ACCOUNTING_VALUE (
     CD_SALES_ACCOUNTING_VALUE                   
    ,CD_SOURCE_SYSTEM                            
    ,CD_DOCUMENT_NO                              
    ,CD_DOCUMENT_LINE                            
    ,NUM_POSTING_YEAR                            
    ,NUM_POSTING_PERIOD                          
    ,AMT_NET_ORDER_VALUE_FI_EUR                  
    ,AMT_REVENUE_CANCELLATION_ACT_EUR            
    ,AMT_REFUNDED_ORDER_VALUE_FI_EUR             
    ,AMT_REFUNDED_ORDER_VALUE_CANCELLATION_FI_EUR
    ,AMT_REVENUE_MANUAL_POSTING_FI_EUR            
    ,AMT_NET_PRODUCT_COST_FI_EUR                  
    ,AMT_FX_HEDGING_IMPACT_FI_EUR                 
    ,AMT_STOCK_ADJUSTMENTS_FI_EUR                 
    ,AMT_DEMURRAGE_DETENTION_FI_EUR               
    ,AMT_DEADFREIGHT_FI_EUR                       
    ,AMT_KICKBACKS_FI_EUR                         
    ,AMT_3RD_PARTY_SERVICES_FI_EUR                
    ,AMT_RMA_FI_EUR                               
    ,AMT_SAMPLES_FI_EUR                           
    ,AMT_DROPSHIPMENT_CEOTRA9ER_ARTIKEL_FI_EUR    
    ,AMT_INBOUND_FREIGHT_COST_FI_EUR       
	,AMT_OTHER_COSTS_EFFECTS_FI_EUR
	,AMT_PO_CANCELLATION_FI_EUR
    ,LOAD_TIMESTAMP                             
)
  
SELECT 
	CD_SALES_ACCOUNTING_VALUE		=	CONCAT (acdoca.[KDAUF] , '#', acdoca.[KDPOS], '#',acdoca.[GJAHR], '#',acdoca.[POPER] )
	,CD_SOURCE_SYSTEM				=	'SAP'
	,DocumentNo						=	acdoca.[KDAUF]
	,DocumentPosition				=	acdoca.[KDPOS]
	,PostingYear					=	acdoca.[GJAHR]
	,PostingPeriod					=	acdoca.[POPER]
	,NetOrderValue					=	SUM( CASE WHEN  acdoca.FKART in('F2','L2','ZF2','S1') THEN HSL * ISNULL(KPI.NetOrderValue,0) END)
	,RevenueInvoiceCancellation		=	SUM( CASE WHEN  acdoca.FKART in('S1') THEN HSL * ISNULL(KPI.NetOrderValue,0) END)
	,Refunds						=	SUM( CASE WHEN  acdoca.FKART in('G2','ZG2','ZG3','CBRE','S2') OR (RACCT = '0044008000' and FKART='' and acdoca.KDAUF='') THEN HSL * ISNULL(KPI.Refunds,0) END)
	,RefundInvoiceCancellation		=	SUM( CASE WHEN  acdoca.FKART in('S2') THEN HSL * ISNULL(KPI.Refunds,0) END)
	,Revenue_ManualPosting			=	SUM( CASE WHEN  acdoca.FKART not in('G2','S2','ZG2','ZG3','F2','L2','S1','ZF2','CBRE') THEN HSL * ISNULL(KPI.Revenue_ManualPosting,0) END	)
	,NetProductCost					=	SUM( CASE WHEN  mov.MBLNR is not null AND mov.BWART in ('Z19','Z92','601','633','634')	and  acdoca.BLART  in('WA','WL')	THEN HSL * ISNULL(KPI.NetProductCost,0) ELSE 0 END)
	,COGS_FX_hedging_impact			= 	SUM( CASE WHEN	acdoca.RACCT  in ('0072011000','0072511000') OR (acdoca.RACCT in ('0052031000','0052531000') AND  accountHeader.TCODE = '' )  THEN HSL * ISNULL(KPI.COGS_FX_hedging_impact,0) ELSE 0 END)
	,COGS_Stock_Value_adjustment	=	SUM( CASE WHEN ( 
										 			(acdoca.RACCT in ('0052031000','0052531000') AND  accountHeader.TCODE <> '' ) 
										 					OR 
										 			(acdoca.RACCT = '0051600000' AND acdoca.BLART NOT IN ('WA','WL') )
										 					OR
										 			(acdoca.RACCT = '0051600000' AND acdoca.BLART  IN ('WA','WL') AND BWART not in ('Z19','Z92','601','633','634'))
										 	) THEN HSL * ISNULL(KPI.COGS_Stock_Value_adjustment,0) ELSE 0 END )
	,Demurrage_detention			=   SUM( HSL * ISNULL(KPI.Demurrage_detention,0))
	,Dead_freight					=   SUM( HSL * ISNULL(KPI.Dead_freight,0))
	,kickbacks						=   SUM( CASE WHEN RASSC <> '5100' THEN HSL * ISNULL(KPI.kickbacks,0) ELSE 0 END)
	,ThirdPartyServices				=   SUM( HSL * ISNULL(KPI.ThirdPartyServices,0))
	,RMA							=   SUM( HSL * ISNULL(KPI.RMA,0))
	,Samples						=   SUM( HSL * ISNULL(KPI.Samples,0))
	,DropShipment					=   SUM( HSL * ISNULL(KPI.DropShipment,0))
	,InboundFreightCosts			=   SUM( HSL * ISNULL(KPI.InboundFreightCosts,0))
	,OtherCOGSEffects				=	SUM( HSL * ISNULL(KPI.OtherCOGSEffects,0))
	,POCancellation					=	SUM( HSL * ISNULL(KPI.POCancellation,0))
	,MAX(acdoca.LOAD_TIMESTAMP) as LOAD_TIMESTAMP
FROM L0.L0_S4HANA_0FI_ACDOCA_10 acdoca 
INNER JOIN L0.L0_MI_SALESACCOUNTINGMATRIX kpi
	ON CAST(kpi.AccountNumber AS BIGINT) =CAST(acdoca.RACCT AS BIGINT)
LEFT JOIN L0.L0_S4HANA_2LIS_03_BF mov
			ON	mov.[MBLNR] = acdoca.[AWREF] 
				AND cast(mov.ZEILE as int)  = cast(acdoca.AWITEM  as int)
				AND mov.[MJAHR] = acdoca.GJAHR 
				and acdoca.RACCT = '0051600000'
LEFT JOIN L0.L0_S4HANA_BKPF accountHeader
				ON 	accountHeader.[BELNR] = acdoca.[BELNR]
					AND accountHeader.BUKRS = acdoca.RBUKRS 
					AND accountHeader.[GJAHR] = acdoca.GJAHR 
WHERE 1 = 1
	AND acdoca.RBUKRS = '1000'
	AND acdoca.RLDNR = '0L'
GROUP BY 
	acdoca.[KDAUF],acdoca.[KDPOS],acdoca.[GJAHR],acdoca.[POPER]
