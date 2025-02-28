
ALTER VIEW [PL].[PL_V_MARGIN_STEERING_TOOL_DETAIL] AS 

SELECT 
       it.[ItemNo] 
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
  INNER JOIN PL.PL_V_ITEM it  on it.ItemId = kpi.ItemID

  where
	 TargetYear = 2025
	 and quantity> 0
	 and [RevenueEst] <> 0 
  GROUP BY 
	it.[ItemNo]
	,ItemDescription
	,ProductHierarchy1
	,ProductHierarchy2
	,[StorageLocation]
	,[Country]
	,[ChannelGroup3]  
	,[ItemStatusMI]
	  ,ItemCluster
GO

ALTER view  [PL].[PL_V_MARGIN_STEERING_TOOL] AS

WITH cte_sales as
(

		SELECT
			   ItemNo= b.ItemNo                        
			  ,ChannelGroup3= REPLACE(c.[CD_CHANNEL_GROUP_3],' ','')
			  ,Country = CASE WHEN DeliveryCountry in('PL','FR','CZ','HR','IT','GB','RO','HU','ES','BG','DE','SI','SK') THEN DeliveryCountry
							  WHEN  right (c.[CD_CHANNEL_GROUP_1], 3) ='CEE' then 'SK' 
							  ELSE 'INT' END
			  ,[24_PC0Abs]				= SUM(PC0)
			  ,[24_PC0%]				= CASE WHEN SUM(ISNULL([RevenueEst],0)) =0 THEN 0 ELSE ROUND(SUM(ISNULL(PC0,0)) / SUM(ISNULL([RevenueEst],0)),2) * 100 END
			  ,[24_SteeringMargin]			= SUM(ISNULL(PC0,0)) - 
											SUM((ISNULL([MarketingAmazon],0)+ISNULL([MarketingShops],0)+ISNULL([MarketingMarketplacesEst],0))) -
											SUM(ISNULL(CommissionsMarketplacesEst,0) - ISNULL(CommissionsMarketplacesRefundsEst,0) +ISNULL(CommissionsAmazonEst,0) - ISNULL(CommissionsAmazonRefundsEst,0)) -
											SUM (FulfillmentOutboundEst) -
											SUM(ISNULL(EnviroLicenseCostEst,0))
		      ,[24_SteeringMargin %]		= CASE WHEN SUM(ISNULL([RevenueEst],0)) =0 THEN 0 ELSE ROUND(((SUM(ISNULL(PC0,0)) - 
												SUM((ISNULL([MarketingAmazon],0)+ISNULL([MarketingShops],0)+ISNULL([MarketingMarketplacesEst],0))) -
												SUM(ISNULL(CommissionsMarketplacesEst,0) - ISNULL(CommissionsMarketplacesRefundsEst,0) +ISNULL(CommissionsAmazonEst,0) - ISNULL(CommissionsAmazonRefundsEst,0)) -
												SUM (FulfillmentOutboundEst)-SUM(ISNULL(EnviroLicenseCostEst,0)) ) /SUM([RevenueEst]))*100,2) END
			  ,[24_PC3Abs]					= SUM(ISNULL(PC3,0))
			  ,[24_PC3%]					= CASE WHEN SUM(ISNULL([RevenueEst],0)) =0 THEN 0 ELSE ROUND(SUM(ISNULL(PC3,0)) / SUM(ISNULL([RevenueEst],0)),2) * 100 END
			  ,[24_NetOrderQuantityEst]	= SUM([NetOrderQuantityEst])
			  ,[24_NetOrderValueEst]		= SUM([NetOrderValueEst])
			  ,[24_ASP]					= CASE WHEN SUM(ISNULL([NetOrderQuantityEst],0)) = 0 THEN 0 ELSE SUM([NetOrderValueEst]) / SUM(ISNULL([NetOrderQuantityEst],0)) END
			  ,[24_RefundedOrderValueEst]	= SUM([RefundedOrderValueEst])
			  ,[24_RevenueEst]			    = SUM([RevenueEst])
			  ,[24_GrossMargin]			= SUM(GrossOrderValue - (ISNULL(MEKHedging,0)-ISNULL(GTSMarkup,0)) * Quantity)
			  ,[24_Marketing]				= SUM(ISNULL([MarketingAmazon],0)+ISNULL([MarketingShops],0)+ISNULL([MarketingMarketplacesEst],0))
			  ,[24_Commissions]			= SUM(ISNULL(CommissionsMarketplacesEst,0) - ISNULL(CommissionsMarketplacesRefundsEst,0) +ISNULL(CommissionsAmazonEst,0) - ISNULL(CommissionsAmazonRefundsEst,0))
			  ,[24_Enviro&License]			= SUM(ISNULL(EnviroLicenseCostEst,0))
			  ,[24_Warehouse-var]			= SUM(ISNULL(HandlingTransShippmentEst,0)+ISNULL(WarehousingFBAEst,0)+ISNULL(HandlingInboundEst,0)+ISNULL(HandlingTransShippmentEst,0)+ISNULL(HandlingShipmentsEst,0)+ISNULL(HandlingReturnsEst,0))
			  ,[24_Freight&Carrier]		= SUM(ISNULL(FulfillmentOutboundEst,0)+ISNULL(TruckingTransShipmentEst,0))
			  ,[24_PaymentsFeesEst]			= SUM(ISNULL(PaymentsFeesEst,0))
			  ,[24_PackagingEst]				= SUM(ISNULL(PackagingEst,0))
			  ,[24_CustomerService-Var]	= SUM(ISNULL(CustomerServiceOPEXEst,0))
			  ,[24_NetOrderContributionEst]=SUM(ISNULL([NetOrderContributionEst],0))
			  ,[24_Mekhedging]				= MAX([Mekhedging])
			  ,[24_ShippingCostEst]		= MAX([ShippingCostEst])
FROM [PL].[PL_V_SALES_TRANSACTIONS] as a
  left join [L1].[L1_DIM_A_SALES_CHANNEL] as c
  on a.ChannelId = c.ID_SALES_CHANNEL
   left join [PL].[PL_V_ITEM] as b
   on b.itemid = a.itemid
   left join [PL].[PL_V_ITEM_business_plan] as bs
   on bs.itemNo = b.itemNo
  left join  [PL].[PL_V_SALES_TRANSACTION_TYPE] as d
  on a.transactiontypeid=d.[TransactionTypeid]
 
	WHERE 1=1
		AND YEAR(TransactionDate) = 2024
		and (d.[TransactionType] in ('Order', 'OrderInvoice') or  a.transactiontypeshort = 'Marketing')
		 and isnull (IncidentFlag,0)<>'Y'
		and c.[CD_CHANNEL_GROUP_1] not in ('Intercompany', 'Mandanten')
		and c.[CD_CHANNEL_GROUP_1] is not null
		and c.[CD_CHANNEL_GROUP_1]not in ('Others')
		and  c.T_SALES_CHANNEL not in ('B2B Liquidation')
		and b.itemno is not null
  group by

	b.ItemNo
	,REPLACE(c.[CD_CHANNEL_GROUP_3],' ','')
	,CASE WHEN DeliveryCountry in('PL','FR','CZ','HR','IT','GB','RO','HU','ES','BG','DE','SI','SK') THEN DeliveryCountry
							  WHEN  right (c.[CD_CHANNEL_GROUP_1], 3) ='CEE' then 'SK' 
							  ELSE 'INT' END


)

SELECT  
	   kpi.[ItemNo]
      ,kpi.[ItemDescription]
      ,kpi.[ProductHierarchy1]
      ,kpi.[ProductHierarchy2]
	  ,kpi.[ItemStatusMI]
	  ,kpi.ItemCluster
      ,kpi.[ChannelGroup3]
      ,kpi.[Country]
      ,kpi.[PC0Abs]
      ,kpi.[PC0%]
      ,kpi.[SteeringMargin]
      ,kpi.[SteeringMargin %]
      ,kpi.[PC3Abs]
      ,kpi.[PC3%]
      ,kpi.[RefundRate]
      ,kpi.[ReturnRate]
      ,kpi.[ReplacementRate]
      ,kpi.[NetOrderQuantityEst]
      ,kpi.[NetOrderValueEst]
      ,kpi.[ASP]
      ,kpi.[RefundedOrderValueEst]
      ,kpi.[RevenueEst]
      ,kpi.[GrossMargin]
      ,kpi.[Marketing]
      ,kpi.[Commissions]
      ,kpi.[Enviro&License]
      ,kpi.[Warehouse-var]
      ,kpi.[Freight&Carrier]
      ,kpi.[PaymentsFeesEst]
      ,kpi.[PackagingEst]
      ,kpi.[CustomerService-Var]
      ,kpi.[NetOrderContributionEst]
      ,kpi.[Mekhedging]
      ,kpi.[ShippingCostEst]


,
SUM(CASE WHEN SteeringMargin > 0 THEN ABS([NetOrderValueEst]) ELSE 0 END ) OVER (partition by kpi.[ItemNo]) PositiveSteeringNOV,
SUM([NetOrderValueEst]) OVER (partition by kpi.[ItemNo]) ItemTotalNOV,
ROUND(SUM(CASE WHEN SteeringMargin > 0 THEN ABS([NetOrderValueEst]) ELSE 0 END ) OVER (partition by kpi.[ItemNo]) / SUM([NetOrderValueEst]) OVER (partition by kpi.[ItemNo]),2)*100 [PositiveSM %],
----PC3
SUM(CASE WHEN PC3Abs > 0 THEN ABS([NetOrderValueEst]) ELSE 0 END ) OVER (partition by kpi.[ItemNo]) PositivePC3,
--SUM([NetOrderValueEst]) OVER (partition by [ItemNo]) ItemTotalNOV,
ROUND(SUM(CASE WHEN PC3Abs > 0 THEN ABS([NetOrderValueEst]) ELSE 0 END ) OVER (partition by kpi.[ItemNo]) / SUM([NetOrderValueEst]) OVER (partition by kpi.[ItemNo]),2)*100 [PositivePC3 %]
,SteeringCluster = CASE	WHEN (ROUND(SUM(CASE WHEN SteeringMargin > 0 THEN ABS(SteeringMargin) ELSE 0 END ) OVER (partition by kpi.[ItemNo]) / SUM([NetOrderValueEst]) OVER (partition by kpi.[ItemNo]),2)*100) = 1 THEN 'Good'
						WHEN (ROUND(SUM(CASE WHEN SteeringMargin < 0 THEN ABS(SteeringMargin) ELSE 0 END ) OVER (partition by kpi.[ItemNo]) / SUM([NetOrderValueEst]) OVER (partition by kpi.[ItemNo]),2)*100) <= 0.1 THEN 'Good'
						WHEN (ROUND(SUM(CASE WHEN SteeringMargin < 0 THEN ABS(SteeringMargin) ELSE 0 END ) OVER (partition by kpi.[ItemNo]) / SUM([NetOrderValueEst]) OVER (partition by kpi.[ItemNo]),2)*100) <= 0.3 THEN 'Check'
						WHEN (ROUND(SUM(CASE WHEN SteeringMargin < 0 THEN ABS(SteeringMargin) ELSE 0 END ) OVER (partition by kpi.[ItemNo]) / SUM([NetOrderValueEst]) OVER (partition by kpi.[ItemNo]),2)*100) <= 0.5 THEN 'Cut'
						ELSE '' END


	  ,sales.[24_PC0Abs]
      ,sales.[24_PC0%]
      ,sales.[24_SteeringMargin]
      ,sales.[24_SteeringMargin %]
      ,sales.[24_PC3Abs]
      ,sales.[24_PC3%]
      ,sales.[24_NetOrderQuantityEst]
      ,sales.[24_NetOrderValueEst]
      ,sales.[24_ASP]
      ,sales.[24_RefundedOrderValueEst]
      ,sales.[24_RevenueEst]
      ,sales.[24_GrossMargin]
      ,sales.[24_Marketing]
      ,sales.[24_Commissions]
      ,sales.[24_Enviro&License]
      ,sales.[24_Warehouse-var]
      ,sales.[24_Freight&Carrier]
      ,sales.[24_PaymentsFeesEst]
      ,sales.[24_PackagingEst]
      ,sales.[24_CustomerService-Var]
      ,sales.[24_NetOrderContributionEst]
      ,sales.[24_Mekhedging]
      ,sales.[24_ShippingCostEst]
	  ,[24_PositiveSteeringNOV] = SUM(CASE WHEN [24_SteeringMargin] > 0 THEN ABS([24_NetOrderValueEst]) ELSE 0 END ) OVER (partition by kpi.[ItemNo])
	  ,[24_ItemTotalNOV]		= SUM([24_NetOrderValueEst]) OVER (partition by kpi.[ItemNo])
	  ,[24_PositiveSM %]		= ROUND(SUM(CASE WHEN [24_SteeringMargin] > 0 THEN ABS([24_NetOrderValueEst]) ELSE 0 END ) OVER (partition by kpi.[ItemNo]) / SUM([24_NetOrderValueEst]) OVER (partition by kpi.[ItemNo]),2)*100
	  ,[24_PositivePC3]			= SUM(CASE WHEN [24_PC3Abs] > 0 THEN ABS([24_NetOrderValueEst]) ELSE 0 END ) OVER (partition by kpi.[ItemNo])
--SUM([NetOrderValueEst]) OVER (partition by [ItemNo]) ItemTotalNOV,
	  ,[24_PositivePC3 %] = ROUND(SUM(CASE WHEN [24_PC3Abs] > 0 THEN ABS([24_NetOrderValueEst]) ELSE 0 END ) OVER (partition by kpi.[ItemNo]) / SUM([24_NetOrderValueEst]) OVER (partition by kpi.[ItemNo]),2)*100 
 ,[24_SteeringCluster] = CASE		WHEN (ROUND(SUM(CASE WHEN [24_SteeringMargin] > 0 THEN ABS([24_SteeringMargin]) ELSE 0 END ) OVER (partition by kpi.[ItemNo]) / SUM([24_NetOrderValueEst]) OVER (partition by kpi.[ItemNo]),2)*100) = 1 THEN 'Good'	
						WHEN (ROUND(SUM(CASE WHEN [24_SteeringMargin] < 0 THEN ABS([24_SteeringMargin]) ELSE 0 END ) OVER (partition by kpi.[ItemNo]) / SUM([24_NetOrderValueEst]) OVER (partition by kpi.[ItemNo]),2)*100) <= 0.1 THEN 'Good'
						WHEN (ROUND(SUM(CASE WHEN [24_SteeringMargin] < 0 THEN ABS([24_SteeringMargin]) ELSE 0 END ) OVER (partition by kpi.[ItemNo]) / SUM([24_NetOrderValueEst]) OVER (partition by kpi.[ItemNo]),2)*100) <= 0.3 THEN 'Check'
						WHEN (ROUND(SUM(CASE WHEN [24_SteeringMargin] < 0 THEN ABS([24_SteeringMargin]) ELSE 0 END ) OVER (partition by kpi.[ItemNo]) / SUM([24_NetOrderValueEst]) OVER (partition by kpi.[ItemNo]),2)*100) <= 0.5 THEN 'Cut'
						ELSE '' END
FROM [PL].[PL_V_MARGIN_STEERING_TOOL_DETAIL] kpi
LEFT JOIN cte_sales sales 
		on sales.ItemNo = kpi.[ItemNo] 
		and sales.ChannelGroup3 = kpi.[ChannelGroup3]
		and sales.Country = kpi.Country

