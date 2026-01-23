with sage_sales as 
(

	select 
			SourceSystem = kpi.CD_SOURCE_SYSTEM,
			TransactionYear =YEAR(D_CREATED),
			TransactionMonth =MONTH(D_CREATED),
			ProcessId = CD_SALES_PROCESS_ID,
			NOV = SUM(AMT_NET_ORDER_VALUE_EUR),
			TAX = SUM(AMT_VALUE_ADDED_TAX_EUR) ,
			SalesCogs = SUM(CASE WHEN (AMT_NET_ORDER_VALUE_EUR > 0) THEN ISNULL([AMT_MEK_HEDGING_EUR],0)-  ISNULL(AMT_GTS_MARKUP,0) ELSE 0 END)
	from l1.l1_fact_a_sales_transaction_KPI kpi
	Left join l1.l1_dim_a_sales_channel ch on kpi.id_sales_channel = ch.id_sales_channel
	where 
		YEAR(D_CREATED) >= 2021
		AND
		kpi.CD_SOURCE_SYSTEM = 'SGE'
		AND
		CD_COUNTRY_DELIVERY = 'GB'
		AND
		ID_COMPANY = 43 ---- mandant 1
		AND ISNULL(FL_INCIDENT,'N') = 'N'
		and ch.CD_CHANNEL_GROUP_1 not in ('Intercompany', 'Mandanten')

	GROUP BY kpi.CD_SOURCE_SYSTEM,MONTH(D_CREATED),CD_SALES_PROCESS_ID,YEAR(D_CREATED)


),
sage_refunds as 
(	
		select 
			SourceSystem = kpi.CD_SOURCE_SYSTEM,
			TransactionYear =YEAR(D_CREATED),
			TransactionMonth =MONTH(D_CREATED),
			ProcessId = CD_SALES_PROCESS_ID,
			Refunds = SUM(amt_net_price_eur),
			TaxRefund =SUM([AMT_TAX_PRICE_EUR])
	from l1.l1_fact_a_sales_transaction_KPI kpi
	Left join l1.l1_dim_a_sales_channel ch on kpi.id_sales_channel = ch.id_sales_channel
	where 
		YEAR(D_CREATED) >= 2021
		AND
		kpi.CD_SOURCE_SYSTEM = 'SGE'
		AND
		CD_COUNTRY_DELIVERY = 'GB'
		AND
		ID_COMPANY = 43 ---- mandant 1
		AND ISNULL(FL_INCIDENT,'N') = 'N'
		and ch.CD_CHANNEL_GROUP_1 not in ('Intercompany', 'Mandanten')
		AND cd_type IN ('VCA','VCC','VCD','VCE','VCF','VCG','VCJ','VCM','VCP','VCR',	'VCV','VCX','VFG','VFL')
	GROUP BY kpi.CD_SOURCE_SYSTEM,MONTH(D_CREATED),CD_SALES_PROCESS_ID,YEAR(D_CREATED)
), cte_final as (
SELECT
	SourceSystem = ISNULL(sales.SourceSystem,ref.SourceSystem),
	TransactionYear = ISNULL(sales.TransactionYear,ref.TransactionYear),
	TransactionMonth = ISNULL(sales.TransactionMonth,ref.TransactionMonth),
	ProcessID = ISNULL(sales.ProcessID,ref.ProcessID),
	Revenue = ISNULL(NOV,0) - ISNULL(Refunds,0),
	Tax = ISNULL(TAX,0) - ISNULL(TaxRefund,0),
	Cogs = CASE WHEN (ISNULL(NOV,0) - ISNULL(Refunds,0)) = 0 THEN 0 ELSE ISNULL(SalesCogs,0) END

FROM sage_sales sales
FULL JOIN sage_refunds ref
	on ref.SourceSystem = sales.SourceSystem
	and ref.TransactionYear = sales.TransactionYear
	and ref.TransactionMonth = sales.TransactionMonth
	and ref.ProcessID = sales.ProcessID
	)

	select * from cte_final where cogs <> 0



	--select * from 22000005
