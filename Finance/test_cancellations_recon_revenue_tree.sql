---- CANCELLATION DEBUG
----  Orders previous to curennt and previous period get cancelled. Reconciliation is only refreshing current and previous period
----= Exclude incidents from rev tree

with cte_revenue as (
SELECT 
--	CD_SOURCE_SYSTEM,
	CD_SALES_ORDER_NO,
	NUM_POSTING_PERIOD,
	SUM(AMT_CANCELLED_ORDER_VALUE_EUR)AMT_CANCELLED_ORDER_VALUE_EUR,
	SUM(VL_CANCELLED_ORDER_QUANTITY) VL_CANCELLED_ORDER_QUANTITY
FROM [L1_FIN].[L1_FACT_A_FINANCE_TRANSACTIONS_KPI] 
WHERE 1=1
--	AND NUM_POSTING_PERIOD = 2
	AND NUM_POSTING_YEAR = 2024
	AND ISNULL(FL_INCIDENT,'N') = 'N'
	AND (AMT_CANCELLED_ORDER_VALUE_EUR <> 0 OR VL_CANCELLED_ORDER_QUANTITY<> 0)
GROUP BY 
	NUM_POSTING_PERIOD
	,NUM_POSTING_YEAR
	,CD_SALES_ORDER_NO
--	,CD_SOURCE_SYSTEM
),
cte_recon as (
SELECT 
--CD_SOURCE_SYSTEM,
NUM_POSTING_PERIOD,
CD_DOCUMENT_NO,
SUM(AMT_CANCELLED_ORDER_VALUE_ACT_EUR)AMT_CANCELLED_ORDER_VALUE_ACT_EUR,
SUM(VL_CANCELLED_ORDERS_QUANTITY_ACT) VL_CANCELLED_ORDERS_QUANTITY_ACT
FROM [L1_FIN].[L1_FACT_F_SALES_FINANCE_RECONCILIATION]  
WHERE 1=1
--	AND NUM_POSTING_PERIOD = 2
	AND NUM_POSTING_YEAR = 2024
	AND (AMT_CANCELLED_ORDER_VALUE_ACT_EUR <> 0 OR VL_CANCELLED_ORDERS_QUANTITY_ACT <> 0)
GROUP BY 
	NUM_POSTING_PERIOD
	,NUM_POSTING_YEAR
	,CD_DOCUMENT_NO
--	,CD_SOURCE_SYSTEM
)

SELECT 
	NUM_POSTING_PERIOD = ISNULL(rev.NUM_POSTING_PERIOD,rec.NUM_POSTING_PERIOD),
	CD_DOCUMENT_NO = ISNULL(rev.CD_SALES_ORDER_NO,rec.CD_DOCUMENT_NO),
	REV_CancelledValue = rev.AMT_CANCELLED_ORDER_VALUE_EUR,
	REC_CancelledValue = rec.AMT_CANCELLED_ORDER_VALUE_ACT_EUR,
	REV_CancelledQTY = rev.VL_CANCELLED_ORDER_QUANTITY,
	REC_CancelledQTY = rec.VL_CANCELLED_ORDERS_QUANTITY_ACT
FROM cte_revenue rev
FULL JOIN cte_recon rec
	on rev.CD_SALES_ORDER_NO = rec.CD_DOCUMENT_NO
	and rev.NUM_POSTING_PERIOD = rec.NUM_POSTING_PERIOD
WHERE 
	ABS(ISNULL(rev.VL_CANCELLED_ORDER_QUANTITY,0) - ISNULL(rec.VL_CANCELLED_ORDERS_QUANTITY_ACT,0)) >0

--SELECT top 10 *FROM [L1_FIN].[L1_FACT_F_SALES_FINANCE_RECONCILIATION]  where AMT_CANCELLED_ORDER_VALUE_ACT_EUR > 0

--SELECT top 10 *FROM [L1_FIN].[L1_FACT_F_SALES_FINANCE_RECONCILIATION]  where CD_DOCUMENT_NO = '0406992773'
--SELECT top 10 *FROM [L1_FIN].[L1_FACT_A_FINANCE_TRANSACTIONS_KPI]  where CD_SALES_ORDER_NO = '0406992773'
--SELECT top 10 *FROM [L1].[L1_FACT_A_SALES_TRANSACTION]  where CD_DOCUMENT_NO = '0406992773'

-------------------------
--- GTS MARGIN --- Added to the sprint ; 
-------------------------
SELECT top 10 * FROM [L1_FIN].[L1_FACT_A_FINANCE_TRANSACTIONS_KPI] where [AMT_NET_PRODUCT_COST_EUR] > 0


-------------------------
--- CEOTRA B2B --- already in the sprint and will include the PMP0 for 1001
-------------------------
SELECT top 10 * FROM [L1_FIN].[L1_FACT_A_FINANCE_TRANSACTIONS_KPI] where [AMT_NET_PRODUCT_COST_EUR] > 0


----

Maciej said we have GTS in SAP from 2024, but it might be better to take it from LucaNet due to some consolidation effects. 
We don't' have GTS in Financial transaction. Is it on purpose excluded, so we take the revenue from LN? 


select distinct [ConsolidationElementName]
FROM [L0_FIN].[L0_LUCANET_READ_FACTS] LCN 


9905 - Berlin Brands Group BidCo GmbH
-----
--Why does only BidCo have full 2023 data in LucaNet? Is it same in LucaNet? Other entities have data only from Sept 2023
---


select NUM_POSTING_PERIOD, CD_COMPANY,
SUM(AMT_REVENUE_MANUAL_POSTING_FI_EUR)AMT_REVENUE_MANUAL_POSTING_FI_EUR, 
SUM(AMT_NET_PRODUCT_COST_FI_EUR)
from L1_FIN.L1_FACT_A_SALES_ACCOUNTING_VALUE 
where CD_SOURCE_SYSTEM = 'LCN'
and num_posting_year = 2023
GROUP BY NUM_POSTING_PERIOD ,CD_COMPANY
order by 1

;WITH CTE_LAST_LOAD AS (

	SELECT AdjustmentLevelID,PeriodID,category,MAX(LOAD_TIMESTAMP)LOAD_TIMESTAMP
	FROM [L0_FIN].[L0_LUCANET_READ_FACTS] LCN 
--	WHERE LOAD_TIMESTAMP > @MAX_LOAD_TIMESTAMP
	GROUP BY AdjustmentLevelID,PeriodID,category

)  
,
CTE_ALL_DIRECT_NODES_ACCOUNTS as (

	select Distinct accountid from  test.lucanet_acounts where direct_reference = 1
),
CTE_KPI_ACCOUNTS as (SELECT 
	DISTINCT lcn.*
FROM test.lucanet_acounts lcn
where (direct_reference = 1 or accountid not in (select accountid from CTE_ALL_DIRECT_NODES_ACCOUNTS))
)
,
 cte_lucanet as (
SELECT 
	CONCAT ('LCN','#',cast(lcn.ConsolidationElementID as nvarchar(20)),'#',cast(lcn.AdjustmentLevelID as nvarchar(20)),'#',year(cast(lcn.periodid+'-01' as date)),
			'#',month(cast(lcn.periodid+'-01' as date)))								  AS CD_SALES_ACCOUNTING_VALUE
    ,'LCN'			  																  AS CD_SOURCE_SYSTEM
	,YEAR(cast(lcn.periodid+'-01' as date))												  AS NUM_POSTING_YEAR
	,MONTH(cast(lcn.periodid+'-01' as date))											  AS NUM_POSTING_PERIOD
	,SUBSTRING(lcn.[ConsolidationElementName],1,4)										  AS CD_COMPANY
	,LCN.[LedgerName]																	  AS T_LEDGER_NAME
	,SUM(CASE WHEN account.kpi = 'Revenue' THEN  ([Value]/100.00) ELSE 0 END )			  AS AMT_REVENUE_MANUAL_POSTING_FI_EUR
	,SUM(CASE WHEN account.kpi = 'COGS' THEN  ([Value]/100.00) ELSE 0 END )	 			  AS AMT_NET_PRODUCT_COST_FI_EUR
    ,MAX(LCN.LOAD_TIMESTAMP)														  AS LOAD_TIMESTAMP
FROM [L0_FIN].[L0_LUCANET_READ_FACTS] LCN 
INNER JOIN CTE_KPI_ACCOUNTS account on account.AccountID = lcn.accountid 
INNER JOIN L0_FIN.L0_MI_LUCANET_MATRIX matrix
	on matrix.[AUDITID] = lcn.AdjustmentLevelID
	and (cast(periodid+'-01' as date)) between validfrom and validto 
INNER JOIN CTE_LAST_LOAD l on l.AdjustmentLevelID = lcn.AdjustmentLevelID and l.PeriodID = lcn.PeriodID and lcn.LOAD_TIMESTAMP >=l.LOAD_TIMESTAMP
	and l.category = lcn.category
GROUP BY lcn.ConsolidationElementID,lcn.AdjustmentLevelID,lcn.periodid,lcn.[ConsolidationElementName],LCN.[LedgerName]
)
select NUM_POSTING_PERIOD, CD_COMPANY,
SUM(AMT_REVENUE_MANUAL_POSTING_FI_EUR)AMT_REVENUE_MANUAL_POSTING_FI_EUR, 
SUM(AMT_NET_PRODUCT_COST_FI_EUR)
from cte_lucanet
where CD_SOURCE_SYSTEM = 'LCN'
and num_posting_year = 2023
GROUP BY NUM_POSTING_PERIOD ,CD_COMPANY
order by 1



select top 10 * from  L0_FIN.L0_MI_LUCANET_MATRIX where validfrom>= '2023-01-01'