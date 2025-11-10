/****** Object:  View [PL].[PL_V_FINANCE_SM]    Script Date: 13/10/2025 11:47:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [PL].[PL_V_FINANCE_SM] AS with mkt_fin as 
 (
	
 
  select 
		PostingYear = GJAHR,
		PostingPeriod = POPER,
		ChannelGroup3 = CASE WHEN RACCT = '0063106720' THEN 'Amazon' 
							 WHEN RACCT in ('0063106702','0063106714') THEN 'ShopWE' 
							 WHEN RACCT in ('0063106705') THEN 'MarketplacesWE' 
							ELSE 'Others' END,
		CountryGroup = 'DE',
		MarketingAmazon = SUM(CASE WHEN RACCT = '0063106720' THEN isnull(HSL,0) ELSE 0 END),
		MarketingShopWE = SUM(CASE WHEN RACCT = '0063106702' THEN isnull(HSL,0) ELSE 0 END),
		MarketingMarketplaces = SUM(CASE WHEN RACCT = '0063106705' THEN isnull(HSL,0) ELSE 0 END),
		MarketingIntercompany = SUM(CASE WHEN RACCT = '0063106714' THEN isnull(HSL,0) ELSE 0 END)
  from  [L0_FIN].L0_S4HANA_0FI_ACDOCA_10 
  where RACCT in ('0063106720','0063106702','0063106705','0063106714')
  and RLDNR = '0L'
  AND GJAHR in('2025','2024')
  --AND POPER = '6'
  GROUP BY 
 GJAHR,POPER,CASE WHEN RACCT = '0063106720' THEN 'Amazon' 
							 WHEN RACCT in ('0063106702','0063106714') THEN 'ShopWE' 
							 WHEN RACCT in ('0063106705') THEN 'MarketplacesWE' 
							ELSE 'Others' END
 ),cte_mkt_cee as
 (
  SELECT
		PostingYear = YEAR([DATE]),
		PostingPeriod = MONTH([DATE]),
		ChannelGroup3 = 'CEE',
		CountryGroup = 'CEE',
		MarketingCostSK = SUM([value])
  FROM [Test].[L0_MI_SM_FIX_COST_ESTIMATE]
  where [POSITION] = 'MarketingFinanceSK'
  GROUP BY YEAR([DATE]),MONTH([DATE])
 
 
 )
 ,
 cte_fin as 
 (
 SELECT
	PostingYear,
	PostingPeriod,
	ChannelGroup3 = ISNULL(ChannelGroup3,'Others'),
	CountryGroup = ISNULL(cmi.COUNTRYGROUP,'DE'),
	GrossOrderValueAct = SUM(GrossOrderValue),
	CancelledOrderValueAct = SUM(CancelledOrderValue) * -1,
	NetOrderValueAct = SUM(NetOrderValue) ,--SUM(NetOrderValue),
	ManualCancellationsAct =SUM(ISNULL(NetOrderValue,0)+ ISNULL(InvoicedOrderValue,0)) * - 1,
	InvoicedOrderValueAct = SUM(InvoicedOrderValue) * -1,--SUM(NetOrderValue),
	UnrelatedRefundsAct = SUM(Refunds) * -1,
	RevenueAct = SUM(Revenue) * -1,
	RevenueThereofRevenueSDAct = SUM(RevenueThereofRevenueSD) * -1,
	RevenueThereofWarrantyProvisionAct = SUM(RevenueThereofWarrantyProvision) * -1,
	OtherRevenueAct = SUM(Isnull(Revenue,0) - (isnull(RevenueThereofRevenueSD,0)+ISNULL(RevenueThereofWarrantyProvision,0))) * -1,
	NetProductCostAct = SUM(NetProductCost)  * -1,
	GrossMarginAct = (SUM(Revenue) + SUM(NetProductCost))*-1
 FROM 
 [PL_FIN].[PL_V_FINANCIAL_TRANSACTIONS] fin
 Left join pl.pl_v_sales_channel ch 
	on ch.ChannelId = fin.SalesChannelId
 LEFT JOIN [L0].[L0_MI_COUNTRY_GROUP] cmi
			ON fin.DeliveryCountry = cmi.COUNTRY
 LEFT JOIN Pl.PL_V_COMPANY c on fin.CompanyID = c.CompanyID
  WHERE
	PostingYear >= 2024
	and companycode in ('1000', '1001', '3000', '3001')
 GROUP BY	
 PostingYear,
 PostingPeriod,
 ISNULL(ChannelGroup3,'Others'),
 ISNULL(cmi.COUNTRYGROUP,'DE')


),
 cte_sales_sm as 
 (
	Select 
		TransactionYear = YEAR([TransactionDate]),
		TransactionMonth = MONTH([TransactionDate])								 ,
		[DeliveryCountryGroup] ,
		ChannelGroup3,
		[CommissionsEst]				 = SUM([CommissionsEst])				 ,
		[CommissionSalesEst]			 = SUM([CommissionSalesEst])			 ,
		[CommissionRefundsEst]			 = SUM([CommissionRefundsEst])			 ,
		[ShippingOutboundInvoicedEst]	 = SUM([ShippingOutboundInvoicedEst])	 ,
		[ShippingOutboundReturnedEst]	 = SUM([ShippingOutboundReturnedEst])	 ,
		[ShippingOutboundReplacedEst]	 = SUM([ShippingOutboundReplacedEst])	 ,
		[ShippingOutboundEst]			 = SUM([ShippingOutboundEst])			 ,
		[ElectronicWasteEst]			 = SUM([ElectronicWasteEst])			 ,
		[PaymentsFeesEst]				 = SUM([PaymentsFeesEst])
	From pl.Pl_V_SALES_TRANSACTIONS_SM sm
	 Left join pl.pl_v_sales_channel ch 
	on ch.ChannelId = sm.ChannelId
	WHERE
		YEAR([TransactionDate])>= 2024
	GROUP BY 
		YEAR([TransactionDate]),
		MONTH([TransactionDate]),
		[DeliveryCountryGroup],
		ChannelGroup3
 
 
 )
SELECT
	fin.*,
	MarketingCostAct					=  (ISNULL(MarketingAmazon + MarketingShopWE + MarketingMarketplaces ,0) *-1)  +ISNULL( MarketingCostSK,0),										 
	[CommissionsEst]				 = [CommissionsEst]					 ,
	[CommissionSalesEst]			 = [CommissionSalesEst]				 ,
	[CommissionRefundsEst]			 = [CommissionRefundsEst]			 ,
	[ShippingOutboundInvoicedEst]	 = [ShippingOutboundInvoicedEst]	 ,
	[ShippingOutboundReturnedEst]	 = [ShippingOutboundReturnedEst]	 ,
	[ShippingOutboundReplacedEst]	 = [ShippingOutboundReplacedEst]	 ,
	[ShippingOutboundEst]			 = [ShippingOutboundEst]			 ,
	[ElectronicWasteEst]			 = [ElectronicWasteEst]				 ,
	[PaymentsFeesEst]				 = [PaymentsFeesEst]				 ,
	[SteeringMarginFIEst]			 = ISNULL(GrossMarginAct,0) - ISNULL(MarketingAmazon + MarketingShopWE + MarketingMarketplaces ,0) +ISNULL( MarketingCostSK,0)
										+ ISNULL([CommissionsEst],0)+ ISNULL([ShippingOutboundEst],0)+ ISNULL([ElectronicWasteEst],0)+ISNULL([PaymentsFeesEst],0)
 from cte_fin fin

 LEFT JOIN cte_sales_sm sales 
	on 
		sales.TransactionYear = fin.PostingYear
		and
		sales.TransactionMonth = fin.PostingPeriod
		and
		sales.ChannelGroup3 = fin.ChannelGroup3
		and
		sales.[DeliveryCountryGroup] = fin.CountryGroup

 LEFT JOIN mkt_fin mkt_fin 
	on 
		mkt_fin.PostingYear  = fin.PostingYear
		and
		mkt_fin.PostingPeriod = fin.PostingPeriod
		and
		mkt_fin.ChannelGroup3 = fin.ChannelGroup3
		and
		mkt_fin.CountryGroup = fin.CountryGroup
 LEFT JOIN cte_mkt_cee mkt_cee
	ON
		mkt_cee.PostingYear  = fin.PostingYear
		and
		mkt_cee.PostingPeriod = fin.PostingPeriod
		and
		mkt_cee.ChannelGroup3 = fin.ChannelGroup3
		and
		mkt_cee.CountryGroup = fin.CountryGroup;
GO


