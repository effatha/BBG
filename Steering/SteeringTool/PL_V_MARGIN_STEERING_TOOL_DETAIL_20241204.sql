/****** Object:  View [PL].[PL_V_MARGIN_STEERING_TOOL_DETAIL]    Script Date: 04/12/2024 17:07:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [PL].[PL_V_MARGIN_STEERING_TOOL_DETAIL] AS SELECT 
       ItemNo = ISNULL(it.[ItemNo],itbs.[ItemNo] )
	  ,NotSAPItem = CASE WHEN it.[ItemNo] IS NOT NULL THEN 'N' ELSE 'Y' END
	  ,it.ItemDescription
	  ,it.ProductHierarchy1
	  ,it.ProductHierarchy2
	  ,[ItemStatusMI]
	  ,ItemCluster
      ,kpi.[ChannelGroup3]
	  ,kpi.[Country]
	  ,[PC0Abs] = SUM(ISNULL([PC0Est],0))
	  ,[PC0%] = ROUND((SUM(ISNULL([PC0Est],0))/SUM(ISNULL([RevenueEst],0))) *100,2)
	  ,SteeringMargin = SUM(ISNULL([PC0Est],0)) - 
						SUM((ISNULL([MarketingAmazon],0)+ISNULL([MarketingShops],0)+ISNULL([MarketingMarketplacesEst],0))) -
						SUM(ISNULL(CommissionsMarketplacesEst,0) - ISNULL(CommissionsMarketplacesRefundsEst,0) +ISNULL(CommissionsAmazonEst,0) - ISNULL(CommissionsAmazonRefundsEst,0)) -
						SUM (FulfillmentOutboundEst) -
						SUM(ISNULL(EnviroLicenseCostEst,0))
	  ,[SteeringMargin %] = ROUND(((SUM(ISNULL([PC0Est],0)) - 
						SUM((ISNULL([MarketingAmazon],0)+ISNULL([MarketingShops],0)+ISNULL([MarketingMarketplacesEst],0))) -
						SUM(ISNULL(CommissionsMarketplacesEst,0) - ISNULL(CommissionsMarketplacesRefundsEst,0) +ISNULL(CommissionsAmazonEst,0) - ISNULL(CommissionsAmazonRefundsEst,0)) -
						SUM (FulfillmentOutboundEst)-SUM(ISNULL(EnviroLicenseCostEst,0)) ) /SUM([RevenueEst]))*100,2)
	  ,[PC3Abs] = SUM(ISNULL([PC3Est],0))				
	  ,[PC3%]= ROUND((SUM(ISNULL([PC3Est],0)) / SUM([RevenueEst]))* 100,2)
	  ,[RefundRate] = MAX(RefundRate)
	  ,[ReturnRate] = MAX([ReturnRate])
	  ,[ReplacementRate] = MAX([ReplacementRate])
      ,[NetOrderQuantityEst] =	ROUND(SUM([NetOrderQuantityEst]),0)
      ,[NetOrderValueEst] =		 SUM([NetOrderValueEst])
	  ,[ASP] =	SUM(ISNULL([NetOrderValueEst],0)) / SUM(ISNULL([NetOrderQuantityEst],0))
	  ,[RefundedOrderValueEst]  = SUM([RefundedOrderValueEst])
      ,[RevenueEst] =  SUM([RevenueEst])
	  ,GrossMargin = SUM(GrossOrderValue - (ISNULL(MEKHedging,0)-ISNULL(GTSMarkup,0)) * Quantity)
	  ,Marketing = SUM(ISNULL([MarketingAmazon],0)+ISNULL([MarketingShops],0)+ISNULL([MarketingMarketplacesEst],0))
	  ,Commissions = SUM(ISNULL(CommissionsMarketplacesEst,0) - ISNULL(CommissionsMarketplacesRefundsEst,0) +ISNULL(CommissionsAmazonEst,0) - ISNULL(CommissionsAmazonRefundsEst,0))
	  ,[Enviro&License] = SUM(ISNULL(EnviroLicenseCostEst,0))
	  ,FulfillmentOutboundEst = SUM(ISNULL(FulfillmentOutboundEst,0))
	  ,[Warehouse-var]=SUM(ISNULL(HandlingTransShippmentEst,0)+ISNULL(WarehousingFBAEst,0)+ISNULL(HandlingInboundEst,0)+ISNULL(HandlingTransShippmentEst,0)+ISNULL(HandlingShipmentsEst,0)+ISNULL(HandlingReturnsEst,0))
	  ,[Freight&Carrier] = SUM(ISNULL(FulfillmentOutboundEst,0)+ISNULL(TruckingTransShipmentEst,0))
	  ,PaymentsFeesEst = SUM(ISNULL(PaymentsFeesEst,0))
	  ,PackagingEst = SUM(ISNULL(PackagingEst,0))
	  ,[CustomerService-Var] = SUM(ISNULL(CSManagement,0))
      ,[NetOrderContributionEst]=SUM(ISNULL([NetOrderContributionEst],0))
	  --,[Quantity] =		SUM([Quantity])
      ,[Mekhedging] =	MAX([Mekhedging])
	  ,[ShippingCostEst] =		MAX([ShippingCostEst])

  FROM [PL].[PL_V_BUSINESS_PLAN_STEERING_KPI] kpi
  LEFT JOIN PL.PL_V_ITEM it  on it.ItemId = kpi.ItemID
  LEFT JOIN PL.PL_V_ITEM_BUSINESS_PLAN itbs  on itbs.[ItemBusinessPlanId] = kpi.[ItemBusinessPlanId]

  where
	 TargetYear = 2025
	 and quantity> 0
	 and [RevenueEst] <> 0 
  GROUP BY 
	 ISNULL(it.[ItemNo],itbs.[ItemNo] )
	 , it.[ItemNo]
	,ItemDescription
	,ProductHierarchy1
	,ProductHierarchy2
	,[StorageLocation]
	,[Country]
	,[ChannelGroup3]  
	,[ItemStatusMI]
	  ,ItemCluster;
GO


