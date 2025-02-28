---  L0_FIN.L0_S4HANA_0FI_ACDOCA_10 acdoca   SGTXT is the field with the position text - AMAZ_ORDER_PRICIPAL

--select top 10 * from l1_fin.L1_FACT_A_FINANCE_TRANSACTIONS_KPI where  cd_fi_document_no ='9404594744'

--select top 10 * from l1.L1_FACT_A_sales_transaction where ID_SALES_TRANSACTION = 9838107

--select top 10 
--	InvoiceNo = kpi.cd_fi_document_no,
--	Currency = kpi.CD_CURRENCY_BALANCE,
--	SalesDocumentNo = sales.CD_DOCUMENT_NO,
--	SalesProcessID = sales.CD_SALES_PROCESS_ID,
--	SalesGrossPrice = sales.AMT_GROSS_PRICE_FC,
--	SalesCurrency = sales.CD_CURRENCY,
--	CustomerReference = kpi.CD_MARKET_ORDER_ID,
--	Fulfillment = kpi.CD_FULFILLMENT,
--	SalesOffice = ch.T_SALES_CHANNEL,
--	SalesQty = sales.VL_ITEM_QUANTITY,
--	FiQty = kpi.VL_QUANTITY,
--	kpi.ID_SALES_TRANSACTION,* 
--from l1_fin.L1_FACT_A_FINANCE_TRANSACTIONS_KPI kpi
--LEFT JOIN 
--LEFT JOIN l1.L1_FACT_A_sales_transaction sales
--	on kpi.ID_SALES_TRANSACTION = sales.ID_SALES_TRANSACTION
--LEFT JOIN l1.l1_DIM_A_SALES_CHANNEL ch on ch.ID_SALES_CHANNEL = sales.ID_SALES_CHANNEL
--where cd_fi_document_no ='9404594744'


--9404594744 --- cd_fi_document_no




SELECT top 100 
	NUM_POSTING_PERIOD,
	NUM_POSTING_YEAR,
	CD_FI_DOCUMENT_NO,
	CD_FI_DOCUMENT_LINE,
	CD_DOCUMENT_TYPE_FI,
	D_CLEARING_DATE,
	AMT_AMOUNT_TRANSACTION,
	CD_CURRENCY_TRANSACTION,
	AMT_AMOUNT_BALANCE,
	CD_CURRENCY_BALANCE,
	CD_CLEARING_DOCUMENT_NO,
	acdoca.SGTXT,
	acdoca.ZUONR,
	bkpf.XBLNR,
	acdoca.BSCHL,
	acdoca.RACCT,
	acdoca.ZUONR,
	acdoca.*
FROM L1_FIN.L1_FACT_A_GENERAL_LEDGER fact
INNER JOIN L1.L1_DIM_A_COMPANY cp on cp.ID_COMPANY = fact.ID_COMPANY
INNER JOIN L0_FIN.L0_S4HANA_0FI_ACDOCA_10 acdoca
	on 
		acdoca.RLDNR = fact.CD_LEDGER 
		and acdoca.RBUKRS = cp.CD_COMPANY
		and acdoca.GJAHR = fact.NUM_POSTING_YEAR 
		and acdoca.BELNR = fact.CD_FI_DOCUMENT_NO 
		and acdoca.DOCLN = fact.CD_FI_DOCUMENT_LINE 
LEFT JOIN L0_FIN.L0_S4HANA_Z_FI_BKPF bkpf
	on 	 bkpf.BUKRS = acdoca.RBUKRS
	and bkpf.GJAHR = acdoca.GJAHR
    and bkpf.BELNR = acdoca.BELNR	
WHERE 1=1
	--AND YEAR(D_FI_CREATED) = 2022
	--AND CD_FI_DOCUMENT_NO = '1403229595'
	and acdoca.Zuonr = '40891097394427513' 

--1405790673

--0108101968
--0102855245

--	---ZFI_AMAZON


--select * 
--FROM L0_FIN.L0_S4HANA_0FI_ACDOCA_10 acdoca 
--where BELNR = '0108101968'

--select * from L0.L0_S4HANA_2LIS_03_BF where MBLNR ='1405790673'



40
11

0011999998
0012100000





SELECT 
	PostingYear = NUM_POSTING_YEAR,
	PostingPeriod = NUM_POSTING_PERIOD,
	BillingDocumentNo = CD_FI_DOCUMENT_NO,
	BillingType = CD_DOCUMENT_TYPE_FI,
	ClearingDate = D_CLEARING_DATE,
	ClearingNo = CD_CLEARING_DOCUMENT_NO
	AMT_AMOUNT_TRANSACTION,
	CD_CURRENCY_TRANSACTION,
	AMT_AMOUNT_BALANCE,
	CD_CURRENCY_BALANCE,
	,
FROM L1_FIN.L1_FACT_A_GENERAL_LEDGER fact
INNER JOIN L1.L1_DIM_A_COMPANY cp on cp.ID_COMPANY = fact.ID_COMPANY
INNER JOIN L0_FIN.L0_S4HANA_0FI_ACDOCA_10 acdoca
	on 
		acdoca.RLDNR = fact.CD_LEDGER 
		and acdoca.RBUKRS = cp.CD_COMPANY
		and acdoca.GJAHR = fact.NUM_POSTING_YEAR 
		and acdoca.BELNR = fact.CD_FI_DOCUMENT_NO 
		and acdoca.DOCLN = fact.CD_FI_DOCUMENT_LINE 
LEFT JOIN L0_FIN.L0_S4HANA_Z_FI_BKPF bkpf
	on 	 bkpf.BUKRS = acdoca.RBUKRS
	and bkpf.GJAHR = acdoca.GJAHR
    and bkpf.BELNR = acdoca.BELNR	
WHERE 1=1
	--AND YEAR(D_FI_CREATED) = 2022
	AND CD_FI_DOCUMENT_NO = '1403229595'
