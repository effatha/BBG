DECLARE @DocumentID as NVARCHAR(50) = ''
DECLARE @DocumentPosition as NVARCHAR(50) = ''
DECLARE @FiscalYear as int = 2022
DECLARE @FiscalPeriod as int = 03

IF OBJECT_ID('tempdb..#kpi_matrix') IS NOT NULL
BEGIN
    DROP TABLE #kpi_matrix
END

CREATE TABLE #kpi_matrix
(
	AccountNumber nvarchar(50),
	NetOrderValue smallint default(0),
	Refunds smallint default(0),
	Revenue_ManualPosting smallint default(0),
	NetProductCost smallint default(0),
	COGS_FX_hedging_impact smallint default(0),
	COGS_Stock_Value_adjustment smallint default(0),
	Demurrage_detention smallint default(0),
	Dead_freight smallint default(0),
	kickbacks smallint default(0),
	ThirdPartyServices smallint default(0),
	Samples smallint default(0),
	DropShipment smallint default(0),
	InboundFreightCosts smallint default(0),
	RMA smallint default(0)


)
---NetOrderValue / Refunds / Revenue Manual Posting
INSERT INTO #kpi_matrix (AccountNumber,NetOrderValue,Refunds,Revenue_ManualPosting) VALUES ('0041000000',1,1,1)
INSERT INTO #kpi_matrix (AccountNumber,NetOrderValue,Refunds,Revenue_ManualPosting) VALUES ('0041001000',1,1,1)
INSERT INTO #kpi_matrix (AccountNumber,NetOrderValue,Refunds,Revenue_ManualPosting) VALUES ('0041001010',1,1,1)
INSERT INTO #kpi_matrix (AccountNumber,NetOrderValue,Refunds,Revenue_ManualPosting) VALUES ('0041001500',1,1,1)
INSERT INTO #kpi_matrix (AccountNumber,NetOrderValue,Refunds,Revenue_ManualPosting) VALUES ('0042000002',1,1,1)
INSERT INTO #kpi_matrix (AccountNumber,NetOrderValue,Refunds,Revenue_ManualPosting) VALUES ('0042001012',1,1,1)
INSERT INTO #kpi_matrix (AccountNumber,NetOrderValue,Refunds,Revenue_ManualPosting) VALUES ('0044002000',1,1,1)
INSERT INTO #kpi_matrix (AccountNumber,NetOrderValue,Refunds,Revenue_ManualPosting) VALUES ('0044002100',1,1,1)
INSERT INTO #kpi_matrix (AccountNumber,NetOrderValue,Refunds,Revenue_ManualPosting) VALUES ('0044003000',1,1,1)
INSERT INTO #kpi_matrix (AccountNumber,NetOrderValue,Refunds,Revenue_ManualPosting) VALUES ('0044003100',1,1,1)
INSERT INTO #kpi_matrix (AccountNumber,NetOrderValue,Refunds,Revenue_ManualPosting) VALUES ('0044003110',1,1,1)
INSERT INTO #kpi_matrix (AccountNumber,NetOrderValue,Refunds,Revenue_ManualPosting) VALUES ('0044004012',1,1,1)
INSERT INTO #kpi_matrix (AccountNumber,NetOrderValue,Refunds,Revenue_ManualPosting) VALUES ('0044004102',1,1,1)
---COGS_FX_hedging_impact
INSERT INTO #kpi_matrix (AccountNumber,COGS_FX_hedging_impact) VALUES ('0072011000',1)
INSERT INTO #kpi_matrix (AccountNumber,COGS_FX_hedging_impact) VALUES ('0072511000',1)
INSERT INTO #kpi_matrix (AccountNumber,COGS_FX_hedging_impact,COGS_Stock_Value_adjustment) VALUES ('0052031000',1,1)
INSERT INTO #kpi_matrix (AccountNumber,COGS_FX_hedging_impact,COGS_Stock_Value_adjustment) VALUES ('0052531000',1,1)
---COGS_Stock_Value_adjustment
--INSERT INTO #kpi_matrix (AccountNumber,COGS_Stock_Value_adjustment) VALUES ('0052031000',1)
--INSERT INTO #kpi_matrix (AccountNumber,COGS_Stock_Value_adjustment) VALUES ('0052531000',1)
INSERT INTO #kpi_matrix (AccountNumber,COGS_Stock_Value_adjustment,NetProductCost) VALUES ('0051600000',1)
---Demurrage_detention
INSERT INTO #kpi_matrix (AccountNumber,Demurrage_detention) VALUES ('0051905801',1)
---Dead_freight
INSERT INTO #kpi_matrix (AccountNumber,Dead_freight) VALUES ('0051905802',1)
---kickbacks
INSERT INTO #kpi_matrix (AccountNumber,kickbacks) VALUES ('0051600002',1)
---ThirdPartyServices
INSERT INTO #kpi_matrix (AccountNumber,ThirdPartyServices) VALUES ('0065001000',1)
INSERT INTO #kpi_matrix (AccountNumber,ThirdPartyServices) VALUES ('0065008500',1)
---RMA
INSERT INTO #kpi_matrix (AccountNumber,RMA) VALUES ('0051600421',1)
---Samples
INSERT INTO #kpi_matrix (AccountNumber,Samples) VALUES ('0052021100',1)
---DropShipment
INSERT INTO #kpi_matrix (AccountNumber,DropShipment) VALUES ('0061002000',1)
---InboundFreightCosts
INSERT INTO #kpi_matrix (AccountNumber,InboundFreightCosts) VALUES ('0051600300',1)
INSERT INTO #kpi_matrix (AccountNumber,InboundFreightCosts) VALUES ('0051600310',1)

IF OBJECT_ID('tempdb..#reconciliation') IS NOT NULL
BEGIN
    DROP TABLE #reconciliation
END

CREATE TABLE #reconciliation
(
	FiscalYear int
	,FiscalPeriod int
	,KPI nvarchar(50)
	,FI_ACTUALS decimal(19,6)
	,FI_MANUAL_POSTINGS decimal(19,6)
	,INVOICE_CANCELLATION decimal(19,6)
	,SALES_PROXY_VALUE decimal(19,6)
	,SALES_ACTUAL_VALUE decimal(19,6)
	,SALES_ORDER_PREVIOUS_PERIOD decimal(19,6)
	,SALES_ORDER_NEXT_PERIOD decimal(19,6)

	 
)

INSERT INTO #reconciliation (FiscalYear,FiscalPeriod,KPI)
SELECT @FiscalYear,@FiscalPeriod,'NetOrderValue'


--;with cte_acdoca as (

SELECT 

	 FiscalYear						=	acdoca.[GJAHR]
	,PostingPeriod					=	acdoca.[POPER]
	,NetOrderValue					=	SUM( CASE WHEN  acdoca.FKART in('F2','L2','ZF2') THEN HSL * ISNULL(KPI.NetOrderValue,0) END)
	,RevenueInvoiceCancellation		=	SUM( CASE WHEN  acdoca.FKART in('S1') THEN HSL * ISNULL(KPI.NetOrderValue,0) END)
	,Refunds						=	SUM( CASE WHEN  acdoca.FKART in('G2','ZG2','ZG3') THEN HSL * ISNULL(KPI.Refunds,0) END)
	,RefundInvoiceCancellation		=	SUM( CASE WHEN  acdoca.FKART in('S2') THEN HSL * ISNULL(KPI.Refunds,0) END)
	,Revenue_ManualPosting			=	SUM( CASE WHEN  acdoca.FKART not in('G2','S2','ZG2','ZG3','F2','L2','S1','ZF2','CBRE') THEN HSL * ISNULL(KPI.Revenue_ManualPosting,0) END	)
	,NetProductCost					=	SUM( CASE WHEN  mov.MBLNR is not null AND mov.BWART in ('Z19','Z92','601','633','634')	and  acdoca.BLART  in('WA','WL')	THEN HSL * ISNULL(KPI.NetProductCost,0) ELSE 0 END)
	,COGS_FX_hedging_impact			= 	SUM( CASE WHEN (acdoca.RACCT in ('0072011000','0072511000') OR (acdoca.RACCT in ('0052031000','0052531000') AND  accountHeader.TCODE = '' )	)  THEN HSL * ISNULL(KPI.COGS_FX_hedging_impact,0) ELSE 0 END)
	,COGS_Stock_Value_adjustment	=	SUM( CASE WHEN ( 
										 			(acdoca.RACCT in ('0052031000','0052531000') AND  accountHeader.TCODE <> '' ) 
										 					OR 
										 			(acdoca.RACCT= '0051600000' AND acdoca.BLART NOT IN ('WA','WL') )
										 					OR
										 			(acdoca.RACCT= '0051600000' AND acdoca.BLART = 'WA' AND BWART not in ('Z19','Z92','601','633','634'))
										 	) THEN HSL * ISNULL(KPI.COGS_FX_hedging_impact,0) ELSE 0 END )
	,Demurrage_detention			=   SUM( HSL * ISNULL(KPI.COGS_FX_hedging_impact,0))
	,Dead_freight					=   SUM( HSL * ISNULL(KPI.Dead_freight,0))
	,kickbacks						=   SUM( CASE WHEN RASSC <> '5100' THEN HSL * ISNULL(KPI.kickbacks,0) ELSE 0 END)
	,ThirdPartyServices				=   SUM( HSL * ISNULL(KPI.ThirdPartyServices,0))
	,RMA							=   SUM( HSL * ISNULL(KPI.RMA,0))
	,Samples						=   SUM( HSL * ISNULL(KPI.Samples,0))
	,DropShipment					=   SUM( HSL * ISNULL(KPI.DropShipment,0))
	,InboundFreightCosts			=   SUM( HSL * ISNULL(KPI.InboundFreightCosts,0))
	,SalesPreviousPeriod			=	SUM(CASE WHEN pl.TransactionDate<acdoca.budat AND MONTH(pl.TransactionDate) <> MONTH(acdoca.BUDAT) THEN pl.GrossOrderValue ELSE 0 END)
	,SalesNextPeriod				=	SUM(CASE WHEN pl.TransactionDate>acdoca.budat AND MONTH(pl.TransactionDate) <> MONTH(acdoca.BUDAT) THEN pl.GrossOrderValue ELSE 0 END)
	,SalesActual					=	SUM(pl.GrossOrderValue)
	,SalesPr						=	

FROM L0.L0_S4HANA_0FI_ACDOCA_10 acdoca 
INNER JOIN #kpi_matrix kpi
	ON kpi.AccountNumber =acdoca.RACCT
LEFT JOIN L0.L0_S4HANA_2LIS_03_BF mov
			on  
				mov.[MBLNR] = acdoca.[AWREF] 
				AND cast(mov.ZEILE as int) = cast(acdoca.AWITEM as int)
				AND mov.[MJAHR] = acdoca.GJAHR 
				and acdoca.RACCT = '0051600000' 
LEFT JOIN L0.L0_S4HANA_BKPF accountHeader
				on 
					accountHeader.[BELNR] = acdoca.[BELNR]
					AND accountHeader.BUKRS = acdoca.RBUKRS 
					AND accountHeader.[GJAHR] = acdoca.GJAHR 
LEFT JOIN PL.PL_V_SALES_TRANSACTIONS PL
			on 
				pl.DocumentNo = acdoca.KDAUF
				AND	pl.DocumentItemPosition = acdoca.KDPOS
				AND Source = 'SAP'
WHERE 1 = 1
	AND acdoca.RBUKRS = '1000'
	--AND acdoca.[GJAHR] = @FiscalYear 
	--AND acdoca.POPER = @FiscalPeriod 
	AND acdoca.KDAU = @DocumentID
	AND acdoca.RLDNR = '0L'
GROUP BY 
	acdoca.[GJAHR],acdoca.[POPER]

)
, cte_sales_cancellation as (
	SELECT
		CD_DOCUMENT_NO, 
		CD_DOCUMENT_LINE,
		GrossOrderValue = sum(((AMT_GROSS_PRICE_EUR) - (AMT_TAX_PRICE_EUR) - (AMT_NET_DISCOUNT_EUR) + (AMT_NET_SHIPPING_REVENUE_EUR))) , 
		CancelledValue = sum(CASE WHEN isnull(T_CANCELLATION_REASON,'') not in ('','Wrongly created') THEN (((AMT_GROSS_PRICE_EUR) - (AMT_TAX_PRICE_EUR) - (AMT_NET_DISCOUNT_EUR) + (AMT_NET_SHIPPING_REVENUE_EUR))) ELSE 0 END)  
	FROM L1.L1_FACT_A_SALES_TRANSACTION fact
	WHERE 
		CD_TYPE in ('ZAA','ZKE','ZAZ')
	--	AND MONTH(D_CREATED) = 3
	--	AND YEAR(D_CREATED) = 2022
		AND CD_DOCUMENT_NO = @DocumentID
		AND CD_DOCUMENT_LINE = @DocumentPosition
	--	AND 
	--Group by CD_DOCUMENT_NO,CD_DOCUMENT_LINE
		





		select *
		FROM L0.L0_S4HANA_0FI_ACDOCA_10 acdoca 
		where 
			racct = '0041001000'
			and AWRef = '0090184510'