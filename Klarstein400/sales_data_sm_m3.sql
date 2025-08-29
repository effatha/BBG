with CTE_SALES as 
(

SELECT
	 ItemId					
	,Turnover							= SUM(Turnover)
	,VAT								= SUM(ValueAddedTax)
	,NOQ								= SUM(NetOrderQuantityEst)
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
WHERE 1=1
	AND TransactionDate>='2025-01-01'
GROUP BY
	ItemId
HAVING SUM(NetOrderValueEst) > 0
),
CTE_STOCK AS (
	select 
		ItemNo,
		TotalQuantity = SUM(TotalQuantity)
	FROM pl.PL_V_DETAILED_STOCK 
	WHERE 1=1
		AND 
		StockType IN ('PHYSICAL STOCK','InTransit','CONSIGNMENT STOCK')
	GROUP BY ItemNo

),
CTE_FC_SALES AS (
	SELECT ItemNo, SUM(Quantity)Quantity
	FROM PL.PL_V_BUSINESS_PLAN bs 
	INNER JOIN PL.PL_V_ITEM it
		on 
			it.ItemId = bs.ItemId
	WHERE
		 DATEFROMPARTS(TargetYear,TargetMonth,1)> EOMONTH(DATEADD(Month,-1,getdate()))
		 AND
		 NetOrderValueBusinessPlan >0 
	GROUP BY it.itemno
			
)

SELECT 
	ItemNo					= it.ItemNo
	,L1						= it.ProductHierarchy1
	,L2						= it.ProductHierarchy2
	,L3						= it.ProductHierarchy3
	,ItemStatus				= it.ItemStatus
	,ItemCluster			= it.ItemCluster
	,ItemVolumeM3			= it.Volume / CASE WHEN it.UnitVolume='CCM' THEN 1000000 WHEN it.UnitVolume='M3' THEN 1 END
	,ASP					= sales.NOV / sales.NOQ
	,NOQ					= sales.NOQ
	,NOV					= sales.NOV		
	,RelatedRefundValue		= sales.RelatedRefundValue
	,RefundRate				= FORMAT(RelatedRefundValue / NOV,'P2')
	,SteeringMargin			= sales.SteeringMargin
	,[SteeringMargin%]		= FORMAT([SteeringMargin%],'P2')
	,UnitSteeringMargin		= [SteeringMargin%] * (sales.NOV / sales.NOQ)--ASP
	,TotalVolumeM3			= (it.Volume / CASE WHEN it.UnitVolume='CCM' THEN 1000000 WHEN it.UnitVolume='M3' THEN 1 END) * NOQ
	,SteeringMarginPerM3	= sales.SteeringMargin / ((it.Volume / CASE WHEN it.UnitVolume='CCM' THEN 1000000 WHEN it.UnitVolume='M3' THEN 1 END) * NOQ)
	,Totalstock				= ISNULL(st.TotalQuantity,0)
	,FCSalesEnd26			= ISNULL(fc.Quantity,0)
	,MEK					= mek.MEKHedging
	,ItemMEKperM3			= mek.MEKHedging * (it.Volume / CASE WHEN it.UnitVolume='CCM' THEN 1000000 WHEN it.UnitVolume='M3' THEN 1 END)

FROM CTE_SALES sales
INNER JOIN PL.PL_V_ITEM it
	ON
		it.ItemId = sales.ItemId
LEFT JOIN CTE_STOCK st 
	ON st.ItemNo = it.ItemNo
LEFT JOIN CTE_FC_SALES fc
	on fc.ItemNo = it.ItemNo
LEFT JOIN PL.PL_V_LAST_MEK mek 
	on mek.ItemNo = it.ItemNO



