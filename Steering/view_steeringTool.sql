---- CAlculate on year 
ALTER VIEW PL.PL_V_MARGIN_STEERING_TOOL AS
SELECT 
       [ItemNo] 
	  ,ItemDescription
	  ,ProductHierarchy1
	  ,ProductHierarchy2
      ,[ChannelGroup3]
	  ,[Country]
	  ,[PC0Est] = SUM(ISNULL([PC0Est],0))
	  ,[PC0%] = ROUND((SUM(ISNULL([PC0Est],0))/SUM([RevenueEst])) *100,2)
	  ,SteeringMargin = SUM(ISNULL([PC0Est],0)) - 
						SUM((ISNULL([MarketingAmazon],0)+ISNULL([MarketingShops],0)+ISNULL([MarketingMarketplacesEst],0))) -
						SUM(ISNULL(CommissionsMarketplacesEst,0) - ISNULL(CommissionsMarketplacesRefundsEst,0) +ISNULL(CommissionsAmazonEst,0) - ISNULL(CommissionsAmazonRefundsEst,0)) -
						SUM (FulfillmentOutboundEst) 
	  ,[SteeringMargin %] = ROUND(((SUM(ISNULL([PC0Est],0)) - 
						SUM((ISNULL([MarketingAmazon],0)+ISNULL([MarketingShops],0)+ISNULL([MarketingMarketplacesEst],0))) -
						SUM(ISNULL(CommissionsMarketplacesEst,0) - ISNULL(CommissionsMarketplacesRefundsEst,0) +ISNULL(CommissionsAmazonEst,0) - ISNULL(CommissionsAmazonRefundsEst,0)) -
						SUM (FulfillmentOutboundEst) ) /SUM([RevenueEst]))*100,2)
	  ,[PC3Est] = SUM(ISNULL([PC3Est],0))				
	  ,[PC3%]= ROUND((SUM(ISNULL([PC3Est],0)) / SUM([NetOrderValueEst]))* 100,2)
	  ,[ASP] =	SUM(ISNULL([NetOrderValueEst],0)) / SUM(ISNULL([NetOrderQuantityEst],0))
      ,[NetOrderQuantityEst] =	ROUND(SUM([NetOrderQuantityEst]),0)
      ,[NetOrderValueEst] =		 SUM([NetOrderValueEst])
      ,[RefundedOrderValueEst]  = SUM([NetOrderValueEst])
	  ,[RefundRate] = 0.10
	  ,[ReturnRate] = 0.10
      ,[RevenueEst] =  SUM([NetOrderValueEst])
	  ,GrossMargin = SUM(GrossOrderValue - (ISNULL(MEKHedging,0)-ISNULL(GTSMarkup,0)) * Quantity)


--      ,[PC1Est] --- 3.3% of PC0
	  ,Marketing = SUM(ISNULL([MarketingAmazon],0)+ISNULL([MarketingShops],0)+ISNULL([MarketingMarketplacesEst],0))
	  ,Commissions = SUM(ISNULL(CommissionsMarketplacesEst,0) - ISNULL(CommissionsMarketplacesRefundsEst,0) +ISNULL(CommissionsAmazonEst,0) - ISNULL(CommissionsAmazonRefundsEst,0))
	  ,PaymentsFeesEst = SUM(ISNULL(PaymentsFeesEst,0))
	  ,[Enviro&License] = SUM(ISNULL(EnviroLicenseCostEst,0))
	  ,[Warehouse-var]=SUM(ISNULL(HandlingTransShippmentEst,0)+ISNULL(WarehousingFBAEst,0)+ISNULL(HandlingInboundEst,0)+ISNULL(HandlingTransShippmentEst,0)+ISNULL(HandlingShipmentsEst,0)+ISNULL(HandlingReturnsEst,0))
	  ,[Freight&Carrier] = SUM(ISNULL(FulfillmentOutboundEst,0)+ISNULL(TruckingTransShipmentEst,0))
	  ,PackagingEst = SUM(ISNULL(PackagingEst,0))
	  ,[CustomerService-Var] = SUM(ISNULL(CSManagement,0))
	 
     
      ,[NetOrderContributionEst]=SUM(ISNULL([NetOrderContributionEst],0))
	  ,[Quantity] =		SUM([Quantity])
      ,[Mekhedging] =	MAX([Mekhedging])
	  ,[ShippingCostEst] =		MAX([ShippingCostEst])

  FROM [PL].[PL_V_BUSINESS_PLAN_KPI] kpi
  INNER JOIN PL.PL_V_ITEM it  on it.ItemId = kpi.ItemID
  where
	 TargetYear = 2025
	 and quantity> 0
  GROUP BY 
	it.[ItemNo]
	,ItemDescription
	,ProductHierarchy1
	,ProductHierarchy2
	,[StorageLocation]
	,[Country]
	,[ChannelGroup3]