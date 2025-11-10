with cte_new as (
 SELECT Processid,
     SUM(GrossOrderValueAct)GrossOrderValue,
    SUM(NetOrderValueEst)NetOrderValue,
 --   SUM(GrossMarginEst)GrossMarginEst,
 --   SUM(MarketingCostAct)MarketingCostAct,
	--SUM(CommissionsEst)CommissionsEst,
	--SUM(ElectronicWasteEst)ElectronicWasteEst,
	SUM(ShippingOutboundEst)ShippingOutboundEst
	--SUM(PaymentsFeesEst)PaymentsFeesEst,
	--SUM(SteeringMarginEst)SteeringMarginEst
	
  FROM [PL].[PL_V_SALES_TRANSACTIONS_SM] sm
  LEFT JOIN pl.pl_v_item it 
	on it.itemid = sm.itemid
  where
	YEAR(TransactionDate) = 2025
  Group By Processid
  )
 -------AGAINST BACKUP 
 -- ,cte_old as (

 -- SELECT 
	--Processid,
 --   SUM(NetOrderValueEst)NetOrderValue,
 ----   SUM(GrossMargin)GrossMarginEst,
 ----   SUM(Isnull(MarketingAmazon,0) + Isnull(Marketingshops,0) + ISNULL(MarketingmarketplacesEst,0))MarketingEst,
	----SUM(ISNULL(MarketingAttributionEstSM,0))MarketingCostAct,
	----SUM(CommissionsEstSM)CommissionsEst,
	----SUM(EnviroLicenseCostEst)ElectronicWasteEst,
	--SUM(FulfillmentOutboundEst)ShippingOutboundEst
	----SUM(PaymentsFeesEst)PaymentsFeesEst,
	----SUM(SteeringMarginEstSM)SteeringMarginEst
	
 -- FROM [TEST].[PL_V_SALES_TRANSACTIONS_SM] sm
 -- LEFT JOIN pl.pl_v_item it 
	--on it.itemid = sm.itemid
 -- where
	
	--YEAR(TransactionDate) = 2025
	--	AND
	--MONTH(TransactionDate)= 3
 -- Group By Processid
 --   ),

 ------AGAINST CPNL
,cte_old as
	(
	
	
  SELECT Processid,
	GrossOrderValue = SUM(GrossOrderValue),
	NetOrderValueEst = SUM(NetOrderValueEst)
    --SUM(MarketingMarketplacesEst)MarketingMarketplacesEst,
    --SUM(MarketingAmazon) + SUM(MarketingShops) MarketingCostAct
  FROM [PL].[PL_V_SALES_TRANSACTIONS] sm
  where
	
	YEAR(TransactionDate) = 2025
	AND
	ISNULL(IncidentFlag,'N') = 'N'
	
  Group By Processid
 --order by 1

	
	
	)
	SELECT 
		Processid = ISNULL(n.ProcessId,o.ProcessId)
		
		,New_GrossOrderValue = ISNULL(n.GrossOrderValue,0)
		,Old_GrossOrderValue = ISNULL(o.GrossOrderValue,0)
		,Diff_GrossOrderValue = ISNULL(n.GrossOrderValue,0) -  ISNULL(o.GrossOrderValue,0)

		--,New_NetOrderValue = ISNULL(n.NetOrderValue,0)
		--,Old_NetOrderValue = ISNULL(o.NetOrderValue,0)
		--,Diff_NetOrderValue = ISNULL(n.NetOrderValue,0) -  ISNULL(o.NetOrderValue,0)
		--,New_ShippingOutboundEst = ISNULL(n.ShippingOutboundEst,0)
		--,Old_ShippingOutboundEst = ISNULL(o.ShippingOutboundEst,0)
		--,Diff_ShippingOutboundEst = ISNULL(n.ShippingOutboundEst,0) -  ISNULL(o.ShippingOutboundEst,0)

	FROM cte_new n
	FULL JOIN cte_old o
		on o.Processid = n.processid
	WHERE
		ABS(ISNULL(n.GrossOrderValue,0) - ISNULL(o.GrossOrderValue,0)) > 1
	ORDER BY 
		(abs(ISNULL(n.GrossOrderValue,0)) - abs(ISNULL(o.GrossOrderValue,0))) asc




 --SELECT
 --ItemNo,
 --DeliveryCountry,
 --   SUM(NetOrderValueEst)NetOrderValue,
	--SUM(NetOrderQuantityEst)NetOrderQuantityEst,
 ----   SUM(GrossMarginEst)GrossMarginEst,
 ----   SUM(MarketingCostAct)MarketingCostAct,
	----SUM(CommissionsEst)CommissionsEst,
	----SUM(ElectronicWasteEst)ElectronicWasteEst,
	--SUM(ShippingOutboundEst)ShippingOutboundEst,
	----SUM(PaymentsFeesEst)PaymentsFeesEst,
	----SUM(SteeringMarginEst)SteeringMarginEst
	--Shipcostunit = SUM(ShippingOutboundEst)/SUM(NetOrderQuantityEst),
	--ratio = SUM(ShippingOutboundEst)/SUM(NetOrderValueEst)
 -- FROM [PL].[PL_V_SALES_TRANSACTIONS_SM] sm
 -- LEFT JOIN pl.pl_v_item it 
	--on it.itemid = sm.itemid
 -- where
	
	--YEAR(TransactionDate) = 2025
	----	AND
	----MONTH(TransactionDate)= 3
	----AND
	----Quantity > 1
	--and 
	--NetOrderValueEst >0
	----and
	----DeliveryCountryGroup = 'INT'
 -- Group By 
 -- --Processid,
 -- ItemNo,
 -- DeliveryCountry
 -- having SUM(NetOrderValueEst) > 0 --and SUM(ShippingOutboundEst)/SUM(NetOrderValueEst) <-1
 -- order by 5 asc



 --SELECT CD_COUNTRY_DELIVERY, count(distinct CD_SALES_PROCESS_ID)
 --FROM 
 --L11.L1_FACT_A_SALES_TRANSACTION_KPI_SM
 --GROUP BY CD_COUNTRY_DELIVERY



 --SELECT DISTINCT CD_COUNTRY FROM [L1].L1_FACT_A_D2C_PERFORMANCE_ITEM



 --select top 10  * from pl.pl_v_item 