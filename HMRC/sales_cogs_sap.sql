 WITH
 cte_gts_items as 
(
	SELECT 
	DISTINCT ITEMNO 
	FROM [L0].[L0_MI_GTS_MARKUP_RATES]  
	WHERE
	GTSMARKUPRATES> 0

), cte_revenue as (
 
 SELECT
	PostingYear,
	PostingPeriod,
	ProcessID,
	RevenueAct = SUM(ISNULL(Revenue,0)-ISNULL(RevenueThereofWarrantyProvision,0)) * -1,
	NetProductCostAct =(SUM(NetProductCost) - SUM(ISNULL(fin.NetProductCost,0) / (1+ ISNULL(0.16,0)) /(1+ CASE WHEN GTS.ItemNo is not null THEN 0.08 ELSE 0 END) * CASE WHEN GTS.ItemNo is not null THEN 0.08 ELSE 0 END))*-1,
	FullNetProductCostAct = SUM(NetProductCost)  * -1,
	GrossMarginAct = (SUM(Revenue)-SUM(ISNULL(RevenueThereofWarrantyProvision,0)) + ((SUM(NetProductCost) - SUM(ISNULL(fin.NetProductCost,0) / (1+ ISNULL(0.16,0)) /(1+ CASE WHEN GTS.ItemNo is not null THEN 0.08 ELSE 0 END) * CASE WHEN GTS.ItemNo is not null THEN 0.08 ELSE 0 END))))*-1
	
 FROM 
 [PL_FIN].[PL_V_FINANCIAL_TRANSACTIONS] fin
 Left join pl.pl_v_sales_channel ch 
	on ch.ChannelId = fin.SalesChannelId
 Left join pl.pl_v_item it 
	on it.ItemId = fin.ItemId
 LEFT JOIN [PL].[PL_M_COUNTRY_GROUP] cmi
			ON fin.DeliveryCountry = cmi.Country
 LEFT JOIN Pl.PL_V_COMPANY c on fin.CompanyID = c.CompanyID
 LEFT JOIN cte_gts_items gts on gts.ItemNo = it.itemno
  WHERE
	PostingYear >= 2022
	--AND
	--PostingPeriod = 1
	and companycode in ('1000')
	and 	ISNULL(account,'0') not in ('0042001020','0041001500','0041000002','0042000000')
	and DeliveryCountry = 'GB'
	and ChannelGroup1 not in ('Intercompany','ManualPostings')
 GROUP BY	
 PostingYear,
 PostingPeriod,
ProcessID
)
,cte_process_id as 
(
	select distinct CD_SALES_PROCESS_ID, CD_DOCUMENT_NO FROM L1.L1_FACT_A_SALES_TRANSACTION
),
cte_tax as (
	select 
		NUM_POSTING_YEAR,
		NUM_POSTING_PERIOD,
		CD_SALES_PROCESS_ID,
		--CD_REFERENCE_DOCUMENT_NO,
		sum(AMT_AMOUNT_COMPANY) TaxAmount
	FROM L1_FIN.L1_FACT_A_GENERAL_LEDGER fact
	left join cte_process_id pr on pr.CD_DOCUMENT_NO = CD_REFERENCE_DOCUMENT_NO
	where CD_ACCOUNT_NUMBER in ('0022000005')
	and NUM_POSTING_YEAR >= 2022
	--and NUM_POSTING_PERIOD = 1
	and CD_CURRENCY_TRANSACTION = 'GBP'
	group by 
		--CD_REFERENCE_DOCUMENT_NO, 
		NUM_POSTING_YEAR,
		NUM_POSTING_PERIOD,
		CD_SALES_PROCESS_ID
)

select
	PostingYear = ISNULL(rev.PostingYear,t.NUM_POSTING_YEAR),
	PostingPeriod = ISNULL(rev.PostingPeriod,t.NUM_POSTING_PERIOD),
	ProcessID = ISNULL(rev.ProcessID,t.CD_SALES_PROCESS_ID),
	NeProductCost = Isnull(NetProductCostAct,0),
	Revenue = ISNULL(RevenueAct,0),
	Tax = ISNULL(TaxAmount,0)
from cte_revenue rev
FULL JOIN cte_tax t
	on t.NUM_POSTING_YEAR = rev.PostingYear
	and  t.NUM_POSTING_PERIOD = rev.PostingPeriod
	and  t.CD_SALES_PROCESS_ID = rev.ProcessID
--where ISNULL(TaxAmount,0) <> 0





--and cast(CD_FI_DOCUMENT_NO as bigint) = 9409934436
--and CD_COUNTRY_DELIVERY in ('GB')
--and sales.cd_sales_process_id = '0407035963'

--select top 10 * from
--L1.L1_FACT_A_SALES_TRANSACTION sales 
--where d_created = '2025-01-10' and CD_COUNTRY_DELIVERY in ('GB') and cd_type in ('ZAA')


--select * FROM L0_FIN.L0_S4HANA_0FI_ACDOCA_10 acdoca 
--where  	acdoca.RLDNR = '0L'
--and RACCT = '0022000005'
--and BELNR = '9409934436'



select sum(steeringmarginest)steeringmarginest,sum(revenueest)revenueest,sum(steeringmarginest) / sum(revenueest) [SM%]
from pl.pl_v_sales_transactions_sm
where
	channel = 'klarstein.de'
	and transactiondate>='2025-12-01'

select sum(steeringmargin)steeringmarginest from pl.PL_V_MARKETING_COSTS_SM
where
	channelid =1848
	and transactiondate>='2025-12-01'



	select * from pl.pl_v_sales_channel where channel = 'klarstein.de'