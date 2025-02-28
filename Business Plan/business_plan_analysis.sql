SELECT
	[Source] = 'Business Plan',
	[MonthPlan] = D_TARGET,
	L1 = itemBS.T_PRODUCT_HIERARCHY_1_BUSINESS_PLAN,
	EOL_NL = itemBS.T_PRODUCT_HIERARCHY_2_BUSINESS_PLAN,
	ABCCluster = itemBS.CD_ITEM_CLUSTER_BUSINESS_PLAN,
	Channel = CD_CHANNEL_GROUP_3,
	Country = CD_COUNTRY_GROUP,
	Quantity = SUM(VL_NET_ORDER_QUANTITY),
	NOV = SUM(AMT_NET_ORDER_VALUE_EST_EUR),
	ASP = CASE WHEN SUM(AMT_NET_ORDER_VALUE_EST_EUR) = 0 or SUM(VL_NET_ORDER_QUANTITY) = 0 THEN 0 ELSE SUM(AMT_NET_ORDER_VALUE_EST_EUR)/SUM(VL_NET_ORDER_QUANTITY) END,
	PC1 = SUM(AMT_PC1_EST_EUR)
FROM [L1].[L1_FACT_F_BUSINESS_PLAN_KPI] fact 
LEFT JOIN [L1].[L1_DIM_A_ITEM] item 
		ON item.[ID_ITEM]=fact.ID_ITEM
LEFT JOIN [L1].[L1_DIM_A_ITEM_BUSINESS_PLAN] itemBS
	ON itemBS.[ID_ITEM_BUSINESS_PLAN]=fact.[ID_ITEM_BUSINESS_PLAN]
GROUP BY 
	D_TARGET,
	itemBS.T_PRODUCT_HIERARCHY_1_BUSINESS_PLAN,
	itemBS.T_PRODUCT_HIERARCHY_2_BUSINESS_PLAN,
	itemBS.CD_ITEM_CLUSTER_BUSINESS_PLAN,
	CD_CHANNEL_GROUP_3,
	CD_COUNTRY_GROUP

UNION



SELECT
	[Source] = 'Actuals',
	[MonthPlan] = DATEADD(MONTH, DATEDIFF(MONTH, 0, TransactionDate), 0),
	L1 = ISNULL(bs.T_PRODUCT_HIERARCHY_1_BUSINESS_PLAN,b.T_PRODUCT_HIERARCHY_1),
	EOL_NL = ISNULL(bs.T_PRODUCT_HIERARCHY_2_BUSINESS_PLAN,ISNULL(CASE  WHEN T_MI_ITEM_STATUS=  '-1' THEN 'EOL' ELSE T_MI_ITEM_STATUS END, CASE  WHEN CD_STATUS_PLANT = 'Z5'THEN 'EOL'  ELSE CD_STATUS_PLANT END)),
	ABCCluster = ISNULL(bs.CD_ITEM_CLUSTER_BUSINESS_PLAN,b.[CD_ITEM_CLUSTER]),
	Channel = c.CD_CHANNEL_GROUP_3,
	Country = case   when right (c.[CD_CHANNEL_GROUP_1], 3) ='CEE' and DeliveryCountry in ('BG','CZ','HR','HU','PL','RO','SI','SK') then DeliveryCountry 
					WHEN right (c.[CD_CHANNEL_GROUP_1], 3) ='CEE' and DeliveryCountry not in ('BG','CZ','HR','HU','PL','RO','SI','SK') THEN 'SK'
					when DeliveryCountry in ('DE','FR','IT','ES','GB') then DeliveryCountry
				else 'INT' end,
	Quantity = SUM(NetOrderQuantityEst),
	NOV = SUM(NetOrderValueEst),
	ASP = CASE WHEN SUM(NetOrderValueEst) = 0 or SUM(NetOrderQuantityEst) = 0 THEN 0 ELSE SUM(NetOrderValueEst)/SUM(NetOrderQuantityEst) END,
	PC1 = SUM(PC1)

FROM [PL].[PL_V_SALES_TRANSACTIONS] as a
  left join [L1].[L1_DIM_A_SALES_CHANNEL] as c
  on a.ChannelId = c.ID_SALES_CHANNEL
   left join [L1].[L1_DIM_A_ITEM] as b
   on b.[ID_ITEM] = a.itemid
   left join [L1].[L1_DIM_A_ITEM_BUSINESS_PLAN] as bs
   on bs.NUM_ITEM = b.NUM_ITEM
  left join  [PL].[PL_V_SALES_TRANSACTION_TYPE] as d
  on a.transactiontypeid=d.[TransactionTypeid]
 
	WHERE 1=1
		AND TransactionDate between '2023-01-01' and '2024-09-30'
		and (d.[TransactionType] in ('Order', 'OrderInvoice') )--or  a.transactiontypeshort = 'Marketing')
		 and isnull (IncidentFlag,0)<>'Y'
		and c.[CD_CHANNEL_GROUP_1] not in ('Intercompany', 'Mandanten')
		and c.[CD_CHANNEL_GROUP_1] is not null
		and c.[CD_CHANNEL_GROUP_1]not in ('Others')
		and  c.T_SALES_CHANNEL not in ('B2B Liquidation')

  group by
  ISNULL(bs.T_PRODUCT_HIERARCHY_1_BUSINESS_PLAN,b.T_PRODUCT_HIERARCHY_1)
  --,bs.T_PRODUCT_HIERARCHY_2_BUSINESS_PLAN
  ,ISNULL(bs.T_PRODUCT_HIERARCHY_2_BUSINESS_PLAN,ISNULL(CASE  WHEN T_MI_ITEM_STATUS=  '-1' THEN 'EOL' ELSE T_MI_ITEM_STATUS END, CASE  WHEN CD_STATUS_PLANT = 'Z5'THEN 'EOL'  ELSE CD_STATUS_PLANT END))
 -- ,bs.CD_ITEM_CLUSTER_BUSINESS_PLAN
 ,ISNULL(bs.CD_ITEM_CLUSTER_BUSINESS_PLAN,b.[CD_ITEM_CLUSTER])
  ,c.[CD_CHANNEL_GROUP_3]
	,case   when right (c.[CD_CHANNEL_GROUP_1], 3) ='CEE' and DeliveryCountry in ('BG','CZ','HR','HU','PL','RO','SI','SK') then DeliveryCountry 
			WHEN right (c.[CD_CHANNEL_GROUP_1], 3) ='CEE' and DeliveryCountry not in ('BG','CZ','HR','HU','PL','RO','SI','SK') THEN 'SK'
			when DeliveryCountry in ('DE','FR','IT','ES','GB') then DeliveryCountry
		else 'INT' end
	,c.CD_CHANNEL_GROUP_3
	,DATEADD(MONTH, DATEDIFF(MONTH, 0, TransactionDate), 0)
	

