DECLARE @YEAR as int = 2024
DECLARE @MONTH as int = 1

DROP TABLE #OpenDocuments

CREATE TABLE #OpenDocuments(
	PostingYear int,
	PostingPeriod int,
	CustomerReference nvarchar(50),
	BillingDocumentNo nvarchar(50),
	BillingType nvarchar(50),
	PositionText nvarchar(50),
	Amount decimal(19,6),
	Currency nvarchar(50),
	SalesOrder  nvarchar(50),
	SalesTurnover  nvarchar(50),
	SalesQty  int,
	SalesOffice nvarchar(150),
	Fulfillment nvarchar(150),
	AmazonAmount decimal(19,6),
	AmazonQty INT,
	PossibleProblem  nvarchar(150)
) 



INSERT INTO #OpenDocuments 
(
PostingYear,
PostingPeriod,
CustomerReference,
BillingDocumentNo,
BillingType,
PositionText,
Amount,
Currency
)

SELECT 
	PostingYear = NUM_POSTING_YEAR,
	PostingPeriod = NUM_POSTING_PERIOD,
	CustomerReference = acdoca.ZUONR,
	BillingDocumentNo = CD_FI_DOCUMENT_NO,
	BillingType = CD_DOCUMENT_TYPE_FI,
	PositionText = acdoca.SGTXT,
	Amount = AMT_AMOUNT_TRANSACTION,
	Currency = CD_CURRENCY_TRANSACTION
FROM L1_FIN.L1_FACT_A_GENERAL_LEDGER fact
INNER JOIN L1.L1_DIM_A_COMPANY cp on cp.ID_COMPANY = fact.ID_COMPANY
INNER JOIN L0_FIN.L0_S4HANA_0FI_ACDOCA_10 acdoca
	on 
		acdoca.RLDNR = fact.CD_LEDGER 
		and acdoca.RBUKRS = cp.CD_COMPANY
		and acdoca.GJAHR = fact.NUM_POSTING_YEAR 
		and acdoca.BELNR = fact.CD_FI_DOCUMENT_NO 
		and acdoca.DOCLN = fact.CD_FI_DOCUMENT_LINE 
WHERE 
	1=1
	AND NUM_POSTING_YEAR = @YEAR
	AND NUM_POSTING_PERIOD = @MONTH
	--AND CD_FI_DOCUMENT_NO = '1404680301'
	AND CD_DOCUMENT_TYPE_FI in ('DM','RR')
	AND ISNULL(D_CLEARING_DATE,'') = ''
	AND fact.cd_account_number = '0012100000'
	AND fact.cd_customer = '0000132315'


-------------------------------------------
-- SALES INFO
---------------------------------------------
;with cte_sales as (

	SELECT CD_SALES_PROCESS_ID,CD_MARKET_ORDER_ID, SUM(AMT_TURNOVER_EUR)  AMT_TURNOVER_EUR, SUM(VL_ORDER_QUANTITY)VL_ORDER_QUANTITY, MIN(CD_FULFILLMENT)CD_FULFILLMENT, MIN(ch.T_SALES_CHANNEL)T_SALES_CHANNEL
	FROM L1.L1_FACT_A_SALES_TRANSACTION_KPI kpi
	LEFT JOIN L1.L1_DIM_A_SALES_CHANNEL ch on ch.ID_SALES_CHANNEL = kpi.ID_SALES_CHANNEL
	where 
		kpi.CD_TYPE IN('ZKE')
	GROUP BY CD_MARKET_ORDER_ID,CD_SALES_PROCESS_ID
)



UPDATE od
	SET 
	SalesOrder = sales.CD_SALES_PROCESS_ID,
	SalesTurnover = sales.AMT_TURNOVER_EUR,
	SalesQty = sales.VL_ORDER_QUANTITY,
	SalesOffice = sales.T_SALES_CHANNEL,
	Fulfillment = sales.CD_FULFILLMENT
FROM #OpenDocuments od
INNER JOIN cte_sales sales
	on REPLACE(sales.CD_MARKET_ORDER_ID,'-','') = CustomerReference




-------------------------------------------
-- Amazon Info
---------------------------------------------

UPDATE od
	SET 
	AmazonAmount = amz.[AMT_ECOMMERCE_ITEM_TURNOVER_FC],
	AmazonQty = amz.CNT_QUANTITY
FROM #OpenDocuments od
INNER JOIN L1.L1_FACT_A_AMAZON_ORDER_DAILY amz on REPLACE(amz.CD_AMAZON_ORDER,'-','') = CustomerReference






-------------------------------------------
-- Possible Reason
---------------------------------------------

UPDATE od
	SET PossibleProblem = CASE 
							WHEN SalesOrder IS NULL THEN 'Invoice missing' 
							WHEN abs(Amount) <> abs(AmazonAmount) THEN 'Invoice wrong (< payment)' 
							ELSE NULL END
FROM #OpenDocuments od


--	select top 100 * from #OpenDocuments where Positiontext = 'AMAZ_ORDER_PRINCIPAL'




----
--NOTES: Check split shipments
-- Add all the documents related to the same assigment number of the open documents
-- CN Fields sparated from the sales
----


select distinct T_AMOUNT from L1.L1_FACT_A_AMAZON_SETTLEMENT_REPORT where ORDER_ID = '405-4649419-5599505'