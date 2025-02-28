/****** Object:  View [PL].[PL_V_MARGIN_STEERING_TOOL]    Script Date: 11/12/2024 09:48:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [PL].[PL_V_MARGIN_STEERING_TOOL] AS
WITH cte_sales as
(

		SELECT
			   ItemNo= ItemNo                        
			  ,ChannelGroup3
			  ,Country 
			  ,[24_PC0Abs]				
			  ,[24_PC0%]				= CASE WHEN (ISNULL([24_RevenueEst],0)) =0 THEN 0 ELSE ROUND((ISNULL([24_PC0Abs],0)) / (ISNULL([24_RevenueEst],0)),2) * 100 END
			  ,[24_SteeringMargin]
		      ,[24_SteeringMargin %]		= CASE WHEN (ISNULL([24_RevenueEst],0)) =0 THEN 0 ELSE ROUND((ISNULL([24_SteeringMargin],0)) / (ISNULL([24_RevenueEst],0)),2) * 100 END
			  ,[24_PC3Abs]					
			  ,[24_PC3%]					= CASE WHEN (ISNULL([24_RevenueEst],0)) =0 THEN 0 ELSE ROUND((ISNULL([24_PC3Abs],0)) / (ISNULL([24_RevenueEst],0)),2) * 100 END
			  ,[24_NetOrderQuantityEst]	
			  ,[24_NetOrderValueEst]		
			  ,[24_ASP]					
			  ,[24_RefundedOrderValueEst]	
			  ,[24_RevenueEst]			   
			  ,[24_GrossMargin]			
			  ,[24_Marketing]				
			  ,[24_Commissions]			
			  ,[24_Enviro&License]			
			  ,[24_FulfillmentOutboundEst]		
			  ,[24_Warehouse-var]			
			  ,[24_Freight&Carrier]		
			  ,[24_PaymentsFeesEst]		
			  ,[24_PackagingEst]			
			  ,[24_CustomerService-Var]
			  ,[24_NetOrderContributionEst]
			  ,[24_Mekhedging]			
			  ,[24_ShippingCostEst]		
			  ,[24_Marketing_Amazon] = [MARKETING_AMAZON]
			  ,[24_Marketing_Google] = [MARKETING_GOOGLE]
			  ,[24_Marketing_D2C] = [MARKETING_D2C]
FROM [PL].[PL_V_MARGIN_STEERING_TOOL_CPNL24]


)

SELECT  
	   kpi.[ItemNo]
	  ,kpi.NotSAPItem
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
	  ,kpi.FulfillmentOutboundEst
      ,kpi.[Warehouse-var]
      ,kpi.[Freight&Carrier]
      ,kpi.[PaymentsFeesEst]
      ,kpi.[PackagingEst]
      ,kpi.[CustomerService-Var]
      ,kpi.[NetOrderContributionEst]
      ,kpi.[Mekhedging]
      ,kpi.[ShippingCostEst]


,
SUM(CASE WHEN [SteeringMargin %] > 25 THEN ABS([NetOrderValueEst]) ELSE 0 END ) OVER (partition by kpi.[ItemNo]) PositiveSteeringNOV,
SUM([NetOrderValueEst]) OVER (partition by kpi.[ItemNo]) ItemTotalNOV,
ROUND(SUM(CASE WHEN [SteeringMargin %] > 25 THEN ABS([NetOrderValueEst]) ELSE 0 END ) OVER (partition by kpi.[ItemNo]) / SUM([NetOrderValueEst]) OVER (partition by kpi.[ItemNo]),2)*100 [PositiveSM %],
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
	  ,sales.[24_FulfillmentOutboundEst]
      ,sales.[24_Warehouse-var]
      ,sales.[24_Freight&Carrier]
      ,sales.[24_PaymentsFeesEst]
      ,sales.[24_PackagingEst]
      ,sales.[24_CustomerService-Var]
      ,sales.[24_NetOrderContributionEst]
      ,sales.[24_Mekhedging]
      ,sales.[24_ShippingCostEst]
	  ,[24_PositiveSteeringNOV] = SUM(CASE WHEN [24_SteeringMargin %] > 25 THEN ABS([24_NetOrderValueEst]) ELSE 0 END ) OVER (partition by kpi.[ItemNo])
	  ,[24_ItemTotalNOV]		= SUM([24_NetOrderValueEst]) OVER (partition by kpi.[ItemNo])
	  ,[24_PositiveSM %]		= ROUND(SUM(CASE WHEN [24_SteeringMargin %] > 25 THEN ABS([24_NetOrderValueEst]) ELSE 0 END ) OVER (partition by kpi.[ItemNo]) / SUM([24_NetOrderValueEst]) OVER (partition by kpi.[ItemNo]),2)*100
	  ,[24_PositivePC3]			= SUM(CASE WHEN [24_PC3Abs] > 0 THEN ABS([24_NetOrderValueEst]) ELSE 0 END ) OVER (partition by kpi.[ItemNo])
--SUM([NetOrderValueEst]) OVER (partition by [ItemNo]) ItemTotalNOV,
	  ,[24_PositivePC3 %] = ROUND(SUM(CASE WHEN [24_PC3Abs] > 0 THEN ABS([24_NetOrderValueEst]) ELSE 0 END ) OVER (partition by kpi.[ItemNo]) / SUM([24_NetOrderValueEst]) OVER (partition by kpi.[ItemNo]),2)*100 
 --,[24_SteeringCluster] = CASE		WHEN (ROUND(SUM(CASE WHEN [24_SteeringMargin] > 0 THEN ABS([24_SteeringMargin]) ELSE 0 END ) OVER (partition by kpi.[ItemNo]) / SUM([24_NetOrderValueEst]) OVER (partition by kpi.[ItemNo]),2)*100) = 1 THEN 'Good'	
	--					WHEN (ROUND(SUM(CASE WHEN [24_SteeringMargin] < 0 THEN ABS([24_SteeringMargin]) ELSE 0 END ) OVER (partition by kpi.[ItemNo]) / SUM([24_NetOrderValueEst]) OVER (partition by kpi.[ItemNo]),2)*100) <= 0.1 THEN 'Good'
	--					WHEN (ROUND(SUM(CASE WHEN [24_SteeringMargin] < 0 THEN ABS([24_SteeringMargin]) ELSE 0 END ) OVER (partition by kpi.[ItemNo]) / SUM([24_NetOrderValueEst]) OVER (partition by kpi.[ItemNo]),2)*100) <= 0.3 THEN 'Check'
	--					WHEN (ROUND(SUM(CASE WHEN [24_SteeringMargin] < 0 THEN ABS([24_SteeringMargin]) ELSE 0 END ) OVER (partition by kpi.[ItemNo]) / SUM([24_NetOrderValueEst]) OVER (partition by kpi.[ItemNo]),2)*100) <= 0.5 THEN 'Cut'
	--					ELSE '' END
	,[24_Marketing_Amazon] 
	,[24_Marketing_Google] 
	,[24_Marketing_D2C] 
FROM [PL].[PL_V_MARGIN_STEERING_TOOL_DETAIL] kpi
LEFT JOIN cte_sales sales 
		on sales.ItemNo = kpi.[ItemNo] 
		and sales.ChannelGroup3 = kpi.[ChannelGroup3]
		and sales.Country = kpi.Country;
GO


