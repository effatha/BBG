with sage_sales as 
(

		select 
		ProcessId = belege.Vorid,
	--	buchung.periode,
		[Year] = cast(LEFT(buchung.periode,4) as int),
		[Month] = cast(RIGHT(buchung.periode,3) as int),
		Tax = SUM(CASE WHEN isnull(SollEw,0) <> 0 THEN isnull(SteuerEw,0) ELSE isnull(SteuerEw,0)*-1 END), 
		--SUM(isnull(SollEw,0))SollEwEUR ,
		--SUM(isnull(HabenEw,0))HabenEwEUR ,
		Revenue =SUM(isnull(SollEw,0))-SUM(isnull(HabenEw,0))- SUM(CASE WHEN isnull(SollEw,0) <> 0 THEN isnull(SteuerEw,0) ELSE isnull(SteuerEw,0)*-1 END)
	from [L0_FIN].[L0_SAGE_KHKBuchungsjournal] buchung
	LEFT JOIN L0.L0_SAGE_KHKVKBELEGE belege 
		ON CAST(belege.Belegnummer as nvarchar(50)) = substring (buchung.Belegnummer,6,len(buchung.Belegnummer))
		AND year(belege.Belegdatum) = year(buchung.[Belegdatum])
		AND belege.mandant = buchung.Mandant
	where 1=1 --Belegnummer=  '2022-5000550'
	--and LEFT(periode,4)	 = '2022'
			--and periode ='2021004'
			and buchung.EULand = 'GB'
			and steuercode = '66'
		--	and gegenkto in ('04320','06937')
			and Buchungstext not like 'kto%'
			and buchung.mandant  = 1
			and cast(LEFT(buchung.periode,4) as int)>=2021
	GROUP BY belege.Vorid,cast(LEFT(buchung.periode,4) as int),cast(RIGHT(buchung.periode,3) as int)


),
sage_refunds as 
(	
		select 
			SourceSystem = kpi.CD_SOURCE_SYSTEM,
			TransactionYear =YEAR(D_CREATED),
			TransactionMonth =MONTH(D_CREATED),
			OrderReference = CONCAT(YEAR(D_CREATED),'-', CD_DOCUMENT_NO),
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
	GROUP BY kpi.CD_SOURCE_SYSTEM,MONTH(D_CREATED),CONCAT(YEAR(D_CREATED),'-', CD_DOCUMENT_NO),YEAR(D_CREATED)
)
SELECT
	SourceSystem = ISNULL(sales.SourceSystem,ref.SourceSystem),
	TransactionYear = ISNULL(sales.TransactionYear,ref.TransactionYear),
	TransactionMonth = ISNULL(sales.TransactionMonth,ref.TransactionMonth),
	ProcessID = ISNULL(sales.OrderReference,ref.OrderReference),
	Revenue = ISNULL(NOV,0) - ISNULL(Refunds,0),
	Tax = ISNULL(TAX,0) - ISNULL(TaxRefund,0),
	Cogs = CASE WHEN (ISNULL(NOV,0) - ISNULL(Refunds,0)) = 0 THEN 0 ELSE ISNULL(SalesCogs,0) END

FROM sage_sales sales
FULL JOIN sage_refunds ref
	on ref.SourceSystem = sales.SourceSystem
	and ref.TransactionYear = sales.TransactionYear
	and ref.TransactionMonth = sales.TransactionMonth
	and ref.OrderReference = sales.OrderReference




	--select * from 22000005



	select  cast(RIGHT('2021001',3) as int)
	select  cast(LEFT('2021001',4) as int)