/****** Object:  View [PL].[PL_V_MARGIN_STEERING_TOOL]    Script Date: 11/12/2024 09:45:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [PL].[PL_V_MARGIN_STEERING_TOOL_CPNL24] AS 


with CTE_MKT_AMAZON AS 
(


SELECT [T_PRODUCT_HIERARCHY_4],channel.CD_CHANNEL_GROUP_3,CASE WHEN acc.CD_COUNTRY in('PL','FR','CZ','HR','IT','GB','RO','HU','ES','BG','DE','SI','SK') THEN acc.CD_COUNTRY
							  WHEN  channel.CD_CHANNEL_GROUP_3 ='CEE' then 'SK' 
							  ELSE 'INT' END Country,
	SUM((ISNULL([AMT_COST_EUR_ATT],0)+ISNULL([GOOGLE_AMT_COST_EUR_ATT],0)+ISNULL([DSP_AMT_COST_EUR_ATT],0))) MKT_AMT
FROM 
[L1].L1_FACT_A_AMAZON_ITEM_ATTRIBUTION amz
INNER JOIN L1.L1_DIM_A_ITEM it on it.ID_ITEM = amz.ID_ITEM
INNER JOIN L1.L1_DIM_A_MARKETING_ACCOUNT acc on acc.[ID_MARKETING_ACCOUNT] = amz.[ID_MARKETING_ACCOUNT]
LEFT JOIN L1.L1_DIM_A_SALES_CHANNEL channel
        on channel.[CD_SALES_CHANNEL] = acc.[CD_SALES_CHANNEL]
WHERE
 YEAR(D_CAMPAIGN) = 2024 and [T_PRODUCT_HIERARCHY_4] is not null
GROUP BY [T_PRODUCT_HIERARCHY_4],channel.CD_CHANNEL_GROUP_3,
CASE WHEN acc.CD_COUNTRY in('PL','FR','CZ','HR','IT','GB','RO','HU','ES','BG','DE','SI','SK') THEN acc.CD_COUNTRY
							  WHEN  channel.CD_CHANNEL_GROUP_3 ='CEE' then 'SK' 
							  ELSE 'INT' END
HAVING SUM((ISNULL([AMT_COST_EUR_ATT],0)+ISNULL([GOOGLE_AMT_COST_EUR_ATT],0)+ISNULL([DSP_AMT_COST_EUR_ATT],0))) >  0
),
CTE_MKT_GOOGLE AS 
(


SELECT [T_PRODUCT_HIERARCHY_4],channel.CD_CHANNEL_GROUP_3,CASE WHEN acc.CD_COUNTRY in('PL','FR','CZ','HR','IT','GB','RO','HU','ES','BG','DE','SI','SK') THEN acc.CD_COUNTRY
							  WHEN  channel.CD_CHANNEL_GROUP_3 ='CEE' then 'SK' 
							  ELSE 'INT' END Country,
	SUM(ISNULL([AMT_COST_EUR_ATT],0)) GGL_AMT
FROM 
[L1].L1_FACT_A_GOOGLE_ITEM_ATTRIBUTION amz
INNER JOIN L1.L1_DIM_A_ITEM it on it.ID_ITEM = amz.ID_ITEM
INNER JOIN L1.L1_DIM_A_MARKETING_ACCOUNT acc on acc.[ID_MARKETING_ACCOUNT] = amz.[ID_MARKETING_ACCOUNT]
LEFT JOIN L1.L1_DIM_A_SALES_CHANNEL channel
        on channel.[CD_SALES_CHANNEL] = acc.[CD_SALES_CHANNEL]
WHERE
 YEAR(D_CAMPAIGN) = 2024 and [T_PRODUCT_HIERARCHY_4] is not null
GROUP BY [T_PRODUCT_HIERARCHY_4],channel.CD_CHANNEL_GROUP_3,
CASE WHEN acc.CD_COUNTRY in('PL','FR','CZ','HR','IT','GB','RO','HU','ES','BG','DE','SI','SK') THEN acc.CD_COUNTRY
							  WHEN  channel.CD_CHANNEL_GROUP_3 ='CEE' then 'SK' 
							  ELSE 'INT' END
HAVING SUM(ISNULL([AMT_COST_EUR_ATT],0)) > 0 
),
CTE_MKT_D2C AS 
(


SELECT [T_PRODUCT_HIERARCHY_4],channel.CD_CHANNEL_GROUP_3,CASE WHEN acc.CD_COUNTRY in('PL','FR','CZ','HR','IT','GB','RO','HU','ES','BG','DE','SI','SK') THEN acc.CD_COUNTRY
							  WHEN  channel.CD_CHANNEL_GROUP_3 ='CEE' then 'SK' 
							  ELSE 'INT' END Country,
	SUM(ISNULL([AMT_COST_EUR_ATT],0)) D2C_AMT
FROM 
[L1].L1_FACT_A_D2C_PERFORMANCE_ITEM amz
INNER JOIN L1.L1_DIM_A_ITEM it on it.ID_ITEM = amz.ID_ITEM
INNER JOIN L1.L1_DIM_A_MARKETING_ACCOUNT acc on acc.[ID_MARKETING_ACCOUNT] = amz.[ID_MARKETING_ACCOUNT]
LEFT JOIN L1.L1_DIM_A_SALES_CHANNEL channel
        on channel.[CD_SALES_CHANNEL] = acc.[CD_SALES_CHANNEL]
WHERE
 YEAR(D_CAMPAIGN) = 2024 and [T_PRODUCT_HIERARCHY_4] is not null
GROUP BY [T_PRODUCT_HIERARCHY_4],channel.CD_CHANNEL_GROUP_3,
CASE WHEN acc.CD_COUNTRY in('PL','FR','CZ','HR','IT','GB','RO','HU','ES','BG','DE','SI','SK') THEN acc.CD_COUNTRY
							  WHEN  channel.CD_CHANNEL_GROUP_3 ='CEE' then 'SK' 
							  ELSE 'INT' END

HAVING SUM(ISNULL([AMT_COST_EUR_ATT],0)) > 0 

),
CTE_MKT_AMAZON_ITEM AS 
(


SELECT  it.ID_ITEM,channel.CD_CHANNEL_GROUP_3,CASE WHEN acc.CD_COUNTRY in('PL','FR','CZ','HR','IT','GB','RO','HU','ES','BG','DE','SI','SK') THEN acc.CD_COUNTRY
							  WHEN  channel.CD_CHANNEL_GROUP_3 ='CEE' then 'SK' 
							  ELSE 'INT' END Country,
	SUM((ISNULL([AMT_COST_EUR_ATT],0)+ISNULL([GOOGLE_AMT_COST_EUR_ATT],0)+ISNULL([DSP_AMT_COST_EUR_ATT],0))) MKT_AMT
FROM 
[L1].L1_FACT_A_AMAZON_ITEM_ATTRIBUTION amz
INNER JOIN L1.L1_DIM_A_ITEM it on it.ID_ITEM = amz.ID_ITEM
INNER JOIN L1.L1_DIM_A_MARKETING_ACCOUNT acc on acc.[ID_MARKETING_ACCOUNT] = amz.[ID_MARKETING_ACCOUNT]
LEFT JOIN L1.L1_DIM_A_SALES_CHANNEL channel
        on channel.[CD_SALES_CHANNEL] = acc.[CD_SALES_CHANNEL]
WHERE
 YEAR(D_CAMPAIGN) = 2024 and [T_PRODUCT_HIERARCHY_4] is null
GROUP BY it.ID_ITEM,channel.CD_CHANNEL_GROUP_3,
CASE WHEN acc.CD_COUNTRY in('PL','FR','CZ','HR','IT','GB','RO','HU','ES','BG','DE','SI','SK') THEN acc.CD_COUNTRY
							  WHEN  channel.CD_CHANNEL_GROUP_3 ='CEE' then 'SK' 
							  ELSE 'INT' END
HAVING SUM((ISNULL([AMT_COST_EUR_ATT],0)+ISNULL([GOOGLE_AMT_COST_EUR_ATT],0)+ISNULL([DSP_AMT_COST_EUR_ATT],0))) >  0

),
CTE_MKT_GOOGLE_ITEM AS 
(


SELECT  it.ID_ITEM,channel.CD_CHANNEL_GROUP_3,CASE WHEN acc.CD_COUNTRY in('PL','FR','CZ','HR','IT','GB','RO','HU','ES','BG','DE','SI','SK') THEN acc.CD_COUNTRY
							  WHEN  channel.CD_CHANNEL_GROUP_3 ='CEE' then 'SK' 
							  ELSE 'INT' END Country,
	SUM(ISNULL([AMT_COST_EUR_ATT],0)) GGL_AMT
FROM 
[L1].L1_FACT_A_GOOGLE_ITEM_ATTRIBUTION amz
INNER JOIN L1.L1_DIM_A_ITEM it on it.ID_ITEM = amz.ID_ITEM
INNER JOIN L1.L1_DIM_A_MARKETING_ACCOUNT acc on acc.[ID_MARKETING_ACCOUNT] = amz.[ID_MARKETING_ACCOUNT]
LEFT JOIN L1.L1_DIM_A_SALES_CHANNEL channel
        on channel.[CD_SALES_CHANNEL] = acc.[CD_SALES_CHANNEL]
WHERE
 YEAR(D_CAMPAIGN) = 2024 and [T_PRODUCT_HIERARCHY_4] is null
GROUP BY  it.ID_ITEM,channel.CD_CHANNEL_GROUP_3,
CASE WHEN acc.CD_COUNTRY in('PL','FR','CZ','HR','IT','GB','RO','HU','ES','BG','DE','SI','SK') THEN acc.CD_COUNTRY
							  WHEN  channel.CD_CHANNEL_GROUP_3 ='CEE' then 'SK' 
							  ELSE 'INT' END
HAVING SUM(ISNULL([AMT_COST_EUR_ATT],0)) > 0 

),
CTE_MKT_D2C_ITEM AS 
(


SELECT  it.ID_ITEM,channel.CD_CHANNEL_GROUP_3,CASE WHEN acc.CD_COUNTRY in('PL','FR','CZ','HR','IT','GB','RO','HU','ES','BG','DE','SI','SK') THEN acc.CD_COUNTRY
							  WHEN  channel.CD_CHANNEL_GROUP_3 ='CEE' then 'SK' 
							  ELSE 'INT' END Country,
	SUM(ISNULL([AMT_COST_EUR_ATT],0)) D2C_AMT
FROM 
[L1].L1_FACT_A_D2C_PERFORMANCE_ITEM amz
INNER JOIN L1.L1_DIM_A_ITEM it on it.ID_ITEM = amz.ID_ITEM
INNER JOIN L1.L1_DIM_A_MARKETING_ACCOUNT acc on acc.[ID_MARKETING_ACCOUNT] = amz.[ID_MARKETING_ACCOUNT]
LEFT JOIN L1.L1_DIM_A_SALES_CHANNEL channel
        on channel.[CD_SALES_CHANNEL] = acc.[CD_SALES_CHANNEL]
WHERE
 YEAR(D_CAMPAIGN) = 2024 and [T_PRODUCT_HIERARCHY_4] is null
GROUP BY  it.ID_ITEM,channel.CD_CHANNEL_GROUP_3,
CASE WHEN acc.CD_COUNTRY in('PL','FR','CZ','HR','IT','GB','RO','HU','ES','BG','DE','SI','SK') THEN acc.CD_COUNTRY
							  WHEN  channel.CD_CHANNEL_GROUP_3 ='CEE' then 'SK' 
							  ELSE 'INT' END
HAVING SUM(ISNULL([AMT_COST_EUR_ATT],0)) > 0 

)

, CTE_SALES AS
(
		SELECT [PRODUCTHIERARCHY4]
			  , ItemNo= b.ItemNo                     
			, ItemId = a.ItemId
			  ,ChannelGroup3= REPLACE(c.[CD_CHANNEL_GROUP_3],' ','')
			  ,Country = CASE WHEN DeliveryCountry in('PL','FR','CZ','HR','IT','GB','RO','HU','ES','BG','DE','SI','SK') THEN DeliveryCountry
							  WHEN  right (c.[CD_CHANNEL_GROUP_1], 3) ='CEE' then 'SK' 
							  ELSE 'INT' END
			  ,[24_PC0Abs]				= SUM(PC0)
			  ,[24_PC0%]				= CASE WHEN SUM(ISNULL([RevenueEst],0)) =0 THEN 0 ELSE ROUND(SUM(ISNULL(PC0,0)) / SUM(ISNULL([RevenueEst],0)),2) * 100 END
			  --,[24_SteeringMargin]			= SUM(ISNULL(PC0,0)) - 
					--						SUM((ISNULL([MarketingAmazon],0)+ISNULL([MarketingShops],0)+ISNULL([MarketingMarketplacesEst],0))) -
					--						SUM(ISNULL(CommissionsMarketplacesEst,0) - ISNULL(CommissionsMarketplacesRefundsEst,0) +ISNULL(CommissionsAmazonEst,0) - ISNULL(CommissionsAmazonRefundsEst,0)) -
					--						SUM (FulfillmentOutboundEst) -
					--						SUM(ISNULL(EnviroLicenseCostEst,0))
		      --,[24_SteeringMargin %]		= CASE WHEN SUM(ISNULL([RevenueEst],0)) =0 THEN 0 ELSE ROUND(((SUM(ISNULL(PC0,0)) - 
								--				SUM((ISNULL([MarketingAmazon],0)+ISNULL([MarketingShops],0)+ISNULL([MarketingMarketplacesEst],0))) -
								--				SUM(ISNULL(CommissionsMarketplacesEst,0) - ISNULL(CommissionsMarketplacesRefundsEst,0) +ISNULL(CommissionsAmazonEst,0) - ISNULL(CommissionsAmazonRefundsEst,0)) -
								--				SUM (FulfillmentOutboundEst)-SUM(ISNULL(EnviroLicenseCostEst,0)) ) /SUM([RevenueEst]))*100,2) END
			  ,[24_PC3Abs_WITHOUT_MKT]					= SUM(ISNULL(PC3,0))
			--  ,[24_PC3%]					= CASE WHEN SUM(ISNULL([RevenueEst],0)) =0 THEN 0 ELSE ROUND(SUM(ISNULL(PC3,0)) / SUM(ISNULL([RevenueEst],0)),2) * 100 END
			  ,[24_NetOrderQuantityEst]	= SUM([NetOrderQuantityEst])
			  ,[24_NetOrderValueEst]		= SUM([NetOrderValueEst])
			  ,[24_ASP]					= CASE WHEN SUM(ISNULL([NetOrderQuantityEst],0)) = 0 THEN 0 ELSE SUM([NetOrderValueEst]) / SUM(ISNULL([NetOrderQuantityEst],0)) END
			  ,[24_RefundedOrderValueEst]	= SUM([RefundedOrderValueEst])
			  ,[24_RevenueEst]			    = SUM([RevenueEst])
			  ,[24_GrossMargin]			= SUM(GrossOrderValue - (ISNULL(MEKHedging,0)-ISNULL(GTSMarkup,0)) * Quantity)
		--	  ,[24_Marketing]				= SUM(ISNULL([MarketingAmazon],0)+ISNULL([MarketingShops],0)+ISNULL([MarketingMarketplacesEst],0))
			  ,[24_Marketing_Maketplaces]				= SUM(ISNULL([MarketingMarketplacesEst],0))
			  ,[24_Commissions]			= SUM(ISNULL(CommissionsMarketplacesEst,0) - ISNULL(CommissionsMarketplacesRefundsEst,0) +ISNULL(CommissionsAmazonEst,0) - ISNULL(CommissionsAmazonRefundsEst,0))
			  ,[24_Enviro&License]			= SUM(ISNULL(EnviroLicenseCostEst,0))
			  ,[24_FulfillmentOutboundEst]			= SUM(ISNULL(FulfillmentOutboundEst,0))
			  ,[24_Warehouse-var]			= SUM(ISNULL(HandlingTransShippmentEst,0)+ISNULL(WarehousingFBAEst,0)+ISNULL(HandlingInboundEst,0)+ISNULL(HandlingTransShippmentEst,0)+ISNULL(HandlingShipmentsEst,0)+ISNULL(HandlingReturnsEst,0))
			  ,[24_Freight&Carrier]		= SUM(ISNULL(FulfillmentOutboundEst,0)+ISNULL(TruckingTransShipmentEst,0))
			  ,[24_PaymentsFeesEst]			= SUM(ISNULL(PaymentsFeesEst,0))
			  ,[24_PackagingEst]				= SUM(ISNULL(PackagingEst,0))
			  ,[24_CustomerService-Var]	= SUM(ISNULL(CustomerServiceOPEXEst,0))
			  ,[24_NetOrderContributionEst]=SUM(ISNULL([NetOrderContributionEst],0))
			  ,[24_Mekhedging]				= MAX([Mekhedging])
			  ,[24_ShippingCostEst]		= MAX([ShippingCostEst])
			  ,[24_Total_NOV_FAMILY]			= SUM(SUM([NetOrderValueEst])) OVER(PARTITION BY b.[PRODUCTHIERARCHY4],REPLACE(c.[CD_CHANNEL_GROUP_3],' ',''),CASE WHEN DeliveryCountry in('PL','FR','CZ','HR','IT','GB','RO','HU','ES','BG','DE','SI','SK') THEN DeliveryCountry
							  WHEN  right (c.[CD_CHANNEL_GROUP_1], 3) ='CEE' then 'SK' 
							  ELSE 'INT' END)
FROM [PL].[PL_V_SALES_TRANSACTIONS_STEERING]  as a
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
		and (d.[TransactionType] in ('Order', 'OrderInvoice'))-- or  a.transactiontypeshort = 'Marketing')
		 and isnull (IncidentFlag,0)<>'Y'
		and c.[CD_CHANNEL_GROUP_1] not in ('Intercompany', 'Mandanten')
		and c.[CD_CHANNEL_GROUP_1] is not null
		and c.[CD_CHANNEL_GROUP_1]not in ('Others')
		and  c.T_SALES_CHANNEL not in ('B2B Liquidation')
		and b.itemno is not null
	--	and	b.[PRODUCTHIERARCHY4] = 'Water Karaffe'
	----and REPLACE(c.[CD_CHANNEL_GROUP_3],' ','') = 'Amazon'
	--and CASE WHEN DeliveryCountry in('PL','FR','CZ','HR','IT','GB','RO','HU','ES','BG','DE','SI','SK') THEN DeliveryCountry
	--						  WHEN  right (c.[CD_CHANNEL_GROUP_1], 3) ='CEE' then 'SK' 
	--						  ELSE 'INT' END = 'IT'
  group by
	a.ItemId,
	b.ItemNo,[PRODUCTHIERARCHY4]
	,REPLACE(c.[CD_CHANNEL_GROUP_3],' ','')
	,CASE WHEN DeliveryCountry in('PL','FR','CZ','HR','IT','GB','RO','HU','ES','BG','DE','SI','SK') THEN DeliveryCountry
							  WHEN  right (c.[CD_CHANNEL_GROUP_1], 3) ='CEE' then 'SK' 
							  ELSE 'INT' END

)
SELECT sales.*
,[24_SteeringMargin] =	
						ISNULL([24_PC0Abs],0) 
						- ISNULL((amz.MKT_AMT * ([24_NetOrderValueEst]/[24_Total_NOV_FAMILY])),0) 
						- ISNULL([24_Marketing_Maketplaces],0) 
						- ISNULL((ggl.GGL_AMT * ([24_NetOrderValueEst]/[24_Total_NOV_FAMILY])),0) 
						- ISNULL((dc.D2C_AMT * ([24_NetOrderValueEst]/[24_Total_NOV_FAMILY])),0)
						- ISNULL(amz_item.MKT_AMT,0) - ISNULL(ggl_item.GGL_AMT,0) - ISNULL(dc_item.D2C_AMT,0)
						-[24_Commissions] - [24_FulfillmentOutboundEst] -[24_Enviro&License]

,[24_PC3Abs]			= (ISNULL([24_PC3Abs_WITHOUT_MKT],0)) 
						- ISNULL((amz.MKT_AMT * ([24_NetOrderValueEst]/[24_Total_NOV_FAMILY])),0) 
						- ISNULL((ggl.GGL_AMT * ([24_NetOrderValueEst]/[24_Total_NOV_FAMILY])),0) 
						- ISNULL((dc.D2C_AMT * ([24_NetOrderValueEst]/[24_Total_NOV_FAMILY])),0) 	
						- ISNULL(amz_item.MKT_AMT,0) - ISNULL(ggl_item.GGL_AMT,0) -  ISNULL(dc_item.D2C_AMT,0)
,[24_Marketing] =		ISNULL((amz.MKT_AMT * ([24_NetOrderValueEst]/[24_Total_NOV_FAMILY])),0) 
						+ ISNULL((ggl.GGL_AMT * ([24_NetOrderValueEst]/[24_Total_NOV_FAMILY])),0) 
						+ ISNULL((dc.D2C_AMT * ([24_NetOrderValueEst]/[24_Total_NOV_FAMILY])),0) 	
						+ ISNULL(amz_item.MKT_AMT,0) + ISNULL(ggl_item.GGL_AMT,0) +  ISNULL(dc_item.D2C_AMT,0)
,MARKETING_AMAZON = ISNULL((amz.MKT_AMT * ([24_NetOrderValueEst]/[24_Total_NOV_FAMILY])),0)  + ISNULL(amz_item.MKT_AMT,0)
,MARKETING_GOOGLE = ISNULL((ggl.GGL_AMT * ([24_NetOrderValueEst]/[24_Total_NOV_FAMILY])),0) + ISNULL(ggl_item.GGL_AMT,0)
,MARKETING_D2C =ISNULL((dc.D2C_AMT * ([24_NetOrderValueEst]/[24_Total_NOV_FAMILY])),0) 	 +  ISNULL(dc_item.D2C_AMT,0)

FROM CTE_SALES sales
LEFT JOIN CTE_MKT_AMAZON amz
	on amz.[T_PRODUCT_HIERARCHY_4] = sales.[PRODUCTHIERARCHY4]
	and sales.ChannelGroup3 = REPLACE(amz.[CD_CHANNEL_GROUP_3],' ','')
	and sales.Country = amz.Country
LEFT JOIN CTE_MKT_GOOGLE ggl
	on ggl.[T_PRODUCT_HIERARCHY_4] = sales.[PRODUCTHIERARCHY4]
	and sales.ChannelGroup3 = REPLACE(ggl.[CD_CHANNEL_GROUP_3],' ','')
	and sales.Country = ggl.Country
LEFT JOIN CTE_MKT_D2C dc
	on dc.[T_PRODUCT_HIERARCHY_4] = sales.[PRODUCTHIERARCHY4]
	and sales.ChannelGroup3 = REPLACE(dc.[CD_CHANNEL_GROUP_3],' ','')
	and sales.Country = dc.Country
LEFT JOIN CTE_MKT_AMAZON_ITEM amz_item
	on amz_item.ID_ITEM = sales.ItemId
	and sales.ChannelGroup3 = REPLACE(amz_item.[CD_CHANNEL_GROUP_3],' ','')
	and sales.Country = amz_item.Country
LEFT JOIN CTE_MKT_GOOGLE_ITEM ggl_item
	on ggl_item.ID_ITEM = sales.ItemId
	and sales.ChannelGroup3 = REPLACE(ggl_item.[CD_CHANNEL_GROUP_3],' ','')
	and sales.Country = ggl_item.Country
LEFT JOIN CTE_MKT_D2C_ITEM dc_item
	on dc_item.ID_ITEM = sales.ItemId
	and sales.ChannelGroup3 = REPLACE(dc_item.[CD_CHANNEL_GROUP_3],' ','')
	and sales.Country = dc.Country
WHERE 
	[24_Total_NOV_FAMILY] > 0




GO


