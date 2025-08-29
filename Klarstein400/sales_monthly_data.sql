with CTE_SALES as 
(

SELECT
	TransactionYear
	,TransactionMonth					
	,Turnover							= SUM(Turnover)
	,VAT								= SUM(ValueAddedTax)
	,NOV								= SUM(NetOrderValueEst)
	,RelatedRefundValue					= SUM(RefundedOrderValueEst)
	,Revenue							= SUM(RevenueEst)
	,FullNetProductCostSM				= SUM(FullNetProductCostSM)
	,GrossMargin						= SUM(GrossMargin)
	,[GrossMargin%]						= ABS(SUM(GrossMargin) / SUM(RevenueEst))
	,MarketingCost						= SUM(MarketingAttributionEstSM)
	,[MarketingCost%]					= ABS(SUM(MarketingAttributionEstSM) /  SUM(RevenueEst))
	,Commissions						= SUM(CommissionsEstSM)
	,[Commissions%]						= ABS(SUM(CommissionsEstSM) /  SUM(RevenueEst))
	,PaymentsFees						= SUM(PaymentsFeesEst)
	,[PaymentsFees%]					= ABS(SUM(PaymentsFeesEst) /  SUM(RevenueEst))
	,EnviroLicenseCost					= SUM(EnviroLicenseCostEst)
	,ShippingCost						= SUM(FulfillmentOutboundEst)
	,[ShippingCost%]					= ABS(SUM(FulfillmentOutboundEst) /  SUM(RevenueEst))
	,SteeringMargin						= SUM(SteeringMarginEstSM)
	,[SteeringMargin%]					= ABS(SUM(SteeringMarginEstSM) /  SUM(RevenueEst))
FROM [TEST].[PL_V_SALES_TRANSACTIONS_SM] sales
INNER JOIN PL.PL_V_ITEM it
	ON
		it.ItemId = sales.ItemId
WHERE 1=1
	AND TransactionDate>='2024-07-01'
GROUP BY
	TransactionYear,
	TransactionMonth
),
CTE_FIXED_COSTS AS 
(
	SELECT	
		[DATE],
		[COGS-Others] = SUM(CASE WHEN POSITION = 'COGS - Demurrage/Deadfreight etc' THEN [Value] ELSE  0 END),
		CustomerServiceFix = SUM(CASE WHEN POSITION = 'CustomerServiceFix' THEN [Value] ELSE  0 END),
		CustomerServiceVar = SUM(CASE WHEN POSITION = 'CustomerServiceVar' THEN [Value] ELSE  0 END),
		[Freight-Transhipment/Others] = SUM(CASE WHEN POSITION = 'Freight-Transhipment/Others' THEN [Value] ELSE  0 END),
		MarketingFix = SUM(CASE WHEN POSITION = 'MarketingFix' THEN [Value] ELSE  0 END),
		[Overheads (excl Other income/FX)] = SUM(CASE WHEN POSITION = 'Overheads (excl Other income/FX)' THEN [Value] ELSE  0 END),
		Packaging = SUM(CASE WHEN POSITION = 'Packaging' THEN [Value] ELSE  0 END),
		WarehouseFix = SUM(CASE WHEN POSITION = 'Warehouse Fix' THEN [Value] ELSE  0 END),
		WarehouseVar = SUM(CASE WHEN POSITION = 'WarehouseVar' THEN [Value] ELSE  0 END)
	FROM [TEST].[PL_V_SM_FIXED_COSTS_ESTIMATE]
	GROUP BY [Date]

)
SELECT 
	S.TransactionYear
	,TransactionMonth				
	,Turnover						
	,VAT							
	,NOV							
	,RelatedRefundValue				
	,Revenue						
	,FullNetProductCostSM			
	,GrossMargin					
	,[GrossMargin%]					
	,MarketingCost					
	,[MarketingCost%]				
	,Commissions					
	,[Commissions%]					
	,PaymentsFees					
	,[PaymentsFees%]				
	,EnviroLicenseCost				
	,ShippingCost					
	,[ShippingCost%]				
	,SteeringMargin					
	,[SteeringMargin%]	
	--fixed
	,[COGS-Others] 
	,[COGS-Others %]						= ABS([COGS-Others] / Revenue)
	,CustomerServiceFix
	,[CustomerServiceFix %]					= ABS(CustomerServiceFix / Revenue)
	,CustomerServiceVar 
	,[CustomerServiceVar %]					= ABS(CustomerServiceVar / Revenue)
	,[Freight-Transhipment/Others] 
	,[Freight-Transhipment/Others %]		= ABS([Freight-Transhipment/Others] / Revenue)
	,MarketingFix	
	,[MarketingFix %]						= ABS(MarketingFix / Revenue)
	,[Overheads (excl Other income/FX)] 
	,[Overheads (excl Other income/FX) %]	= ABS([Overheads (excl Other income/FX)] / Revenue)
	,Packaging					
	,[Packaging %]							= ABS(Packaging / Revenue)
	,WarehouseFix	
	,[WarehouseFix %]						= ABS(WarehouseFix / Revenue)
	,WarehouseVar
	,[WarehouseVar %]						= ABS(WarehouseVar /Revenue)
	,NetMargin								= SteeringMargin + [COGS-Others] + CustomerServiceFix + CustomerServiceVar + [Freight-Transhipment/Others] +
												MarketingFix + Packaging + WarehouseFix + WarehouseVar
	,[NetMargin %]							= (SteeringMargin + [COGS-Others] + CustomerServiceFix + CustomerServiceVar + [Freight-Transhipment/Others] +
												MarketingFix + Packaging + WarehouseFix + WarehouseVar) / Revenue
	, EBITDA								= SteeringMargin + [COGS-Others] + CustomerServiceFix + CustomerServiceVar + [Freight-Transhipment/Others] +
												MarketingFix + Packaging + WarehouseFix + WarehouseVar + [Overheads (excl Other income/FX)]
	, [EBITDA %]							= (SteeringMargin + [COGS-Others] + CustomerServiceFix + CustomerServiceVar + [Freight-Transhipment/Others] +
												MarketingFix + Packaging + WarehouseFix + WarehouseVar + [Overheads (excl Other income/FX)])/Revenue
	, [SM%Target]							= ABS(SteeringMargin / ([COGS-Others] + CustomerServiceFix + CustomerServiceVar + [Freight-Transhipment/Others] +
												MarketingFix + Packaging + WarehouseFix + WarehouseVar + [Overheads (excl Other income/FX)]))
FROM CTE_SALES s
LEFT JOIN CTE_FIXED_COSTS f
	on f.date = DATEFROMPARTS(TransactionYear,TransactionMOnth,01)
order by TransactionYear,TransactionMonth









SELECT
	TransactionYear
	,TransactionMonth					
	,Country							= DeliveryCountryGroup
	,ChannelGroup3					= ch.ChannelGroup3
	,L1									= it.ProductHierarchy1
	,L2									= it.ProductHierarchy2
	,Turnover							= SUM(Turnover)
	,VAT								= SUM(ValueAddedTax)
	,NOV								= SUM(NetOrderValueEst)
	,RelatedRefundValue					= SUM(RefundedOrderValueEst)
	,Revenue							= SUM(RevenueEst)
	,FullNetProductCostSM				= SUM(FullNetProductCostSM)
	,GrossMargin						= SUM(GrossMargin)
	,[GrossMargin%]						= ABS(SUM(GrossMargin) / SUM(RevenueEst))
	,MarketingCost						= SUM(MarketingAttributionEstSM)
	,[MarketingCost%]					= ABS(SUM(MarketingAttributionEstSM) /  SUM(RevenueEst))
	,Commissions						= SUM(CommissionsEstSM)
	,[Commissions%]						= ABS(SUM(CommissionsEstSM) /  SUM(RevenueEst))
	,PaymentsFees						= SUM(PaymentsFeesEst)
	,[PaymentsFees%]					= ABS(SUM(PaymentsFeesEst) /  SUM(RevenueEst))
	,EnviroLicenseCost					= SUM(EnviroLicenseCostEst)
	,ShippingCost						= SUM(FulfillmentOutboundEst)
	,[ShippingCost%]					= ABS(SUM(FulfillmentOutboundEst) /  SUM(RevenueEst))
	,SteeringMargin						= SUM(SteeringMarginEstSM)
	,[SteeringMargin%]					= ABS(SUM(SteeringMarginEstSM) /  SUM(RevenueEst))
FROM [TEST].[PL_V_SALES_TRANSACTIONS_SM] sales
INNER JOIN PL.PL_V_ITEM it
	ON
		it.ItemId = sales.ItemId
LEFT JOIN PL.PL_V_SALES_CHANNEL ch
	ON
		ch.ChannelId = sales.ChannelId
WHERE 1=1
	AND TransactionDate>='2024-07-01'
GROUP BY
	TransactionYear,
	TransactionMonth,
	DeliveryCountryGroup,
	ch.ChannelGroup3,
	ProductHierarchy1,
	ProductHierarchy2
HAVING SUM(RevenueEst) >0
order by TransactionYear,TransactionMonth
