ALTER VIEW PL.PL_V_BL_SALES
AS


with CTE_SALES_LY as
(

SELECT 
    TransactionDate
    ,TransactionDateNY = DATEADD(YEAR,1,TransactionDate)
    ,TransactionYear = Year(TransactionDate) 
    ,TransactionMonth = Month (TransactionDate) 
    ,b.ItemNo
    ,SetSKU = z.ItemNo
    ,ItemParentQuantity = sum(ItemParentQuantity)
    ,a.ItemType
    ,channelid = case when c.Channel in ('elektronik-guenstig','elektronik-star','elektr-star-discount','elektr-superguenstig','klarstein.deutschlan','ur.deal') Then 'eBayDE'
                      when c.Channel in ('hifi-tower','Hifi-Tower IE','hifi-tower.ie','hifi-tower-deals') THEN 'eBayUK' 
                      ELSE c.Channel  END 
    ,c.[ChannelGroup1]
    ,c.[ChannelGroup3]
    ,Fulfillment
    ,SalesCountry = case 
                        when right (c.[ChannelGroup1], 3) ='CEE' then 'SK'
                        when DeliveryCountry in ('DE','FR','IT','ES','GB') then DeliveryCountry
                        else 'INT' end
    ,ChannelGroup3B = case when c.[ChannelGroup1] = 'Amazon' then CONCAT(COALESCE(c.[ChannelGroup1],'OTHERS'),' ',FULFILLMENT) else c.[ChannelGroup1] end 
    ,[NetOrderValueEstLY]                         = sum (NetOrderValueEst)
  FROM [PL].[PL_V_SALES_TRANSACTIONS] as a
  LEFT JOIN [PL].[PL_V_SALES_CHANNEL] as c
    ON a.channelid = c.channelid
  LEFT JOIN [PL].[PL_V_ITEM] as b
    ON b.itemid = a.itemid
  LEFT JOIN [PL].[PL_V_ITEM] as z
    ON z.itemid = a.ItemParentID
  LEFT JOIN  [PL].[PL_V_SALES_TRANSACTION_TYPE] as d
    ON a.transactiontypeid=d.[TransactionTypeid]
  WHERE 1=1
   AND TransactionYear = YEAR(GETDATE()-1) -1
   AND TransactionDate < CAST(DATEADD(YEAR,-1,getdate()) as date)
   AND (d.[TransactionType] in ('Order', 'OrderInvoice') or  a.transactiontypeshort = 'Marketing')
   AND isnull (IncidentFlag,'N')<>'Y'
   AND c.ChannelGroup1 not in ('Intercompany', 'Mandanten')
   AND c.ChannelGroup1 is not null
  -- AND  TransactionMONTH = 6
 GROUP BY
   TransactionDate
    ,Year(TransactionDate) 
    ,Month (TransactionDate) 
    ,b.ItemNo
    ,z.ItemNo
    ,a.ItemType
    ,case when c.Channel in ('elektronik-guenstig','elektronik-star','elektr-star-discount','elektr-superguenstig','klarstein.deutschlan','ur.deal') Then 'eBayDE'
            when c.Channel in ('hifi-tower','Hifi-Tower IE','hifi-tower.ie','hifi-tower-deals') THEN 'eBayUK' 
            ELSE c.Channel  END 
    ,c.[ChannelGroup1]
    ,c.[ChannelGroup3]
    ,Fulfillment
    ,case when right (c.[ChannelGroup1], 3) ='CEE' then 'SK'
          when DeliveryCountry in ('DE','FR','IT','ES','GB') then DeliveryCountry
          else 'INT' end
    ,case when c.[ChannelGroup1] = 'Amazon' then CONCAT(COALESCE(c.[ChannelGroup1],'OTHERS'),' ',FULFILLMENT) else c.[ChannelGroup1] end
HAVING sum(NetOrderValueEst) > 0
), 
CTE_SALES_TY AS (


SELECT 
    TransactionDate
    ,TransactionYear = Year(TransactionDate) 
    ,TransactionMonth = Month (TransactionDate) 
    ,b.ItemNo
    ,SetSKU = z.ItemNo
    ,ItemParentQuantity = sum(ItemParentQuantity)
    ,a.ItemType
    ,channelid = case when c.Channel in ('elektronik-guenstig','elektronik-star','elektr-star-discount','elektr-superguenstig','klarstein.deutschlan','ur.deal') Then 'eBayDE'
                      when c.Channel in ('hifi-tower','Hifi-Tower IE','hifi-tower.ie','hifi-tower-deals') THEN 'eBayUK' 
                      ELSE c.Channel  END 
    ,c.[ChannelGroup1]
    ,c.[ChannelGroup3]
    ,Fulfillment
    ,SalesCountry = case 
                        when right (c.[ChannelGroup1], 3) ='CEE' then 'SK'
                        when DeliveryCountry in ('DE','FR','IT','ES','GB') then DeliveryCountry
                        else 'INT' end
    ,ChannelGroup3B = case when c.[ChannelGroup1] = 'Amazon' then CONCAT(COALESCE(c.[ChannelGroup1],'OTHERS'),' ',FULFILLMENT) else c.[ChannelGroup1] end 
    ,Turnover                                   = sum(Turnover)
    ,[OrderQuantity]                            = sum ([OrderQuantity])
    ,[NetOrderValueEst]                         = sum (NetOrderValueEst)
    ,[NetOrderQuantityEst]                      = sum ([NetOrderQuantityEst])
    ,[NetShippingRevenue]                       = sum ([NetShippingRevenue])
    ,[RefundedOrderValueEst]                    = sum ([RefundedOrderValueEst]) 
    ,[RevenueEst]                               = sum ([revenueEst])
    ,[NetProductCostEst]                        = sum ([NetProductCostEst])
    ,[FXHedgingImpactEst]                       = sum ([FXHedgingImpactEst])
    ,[COGSStockValueAdjustmentEst]              = sum ([COGSStockValueAdjustmentEst])
    ,[COGSOperationsEst]                        = sum ([COGSOperationsEst])
    ,[MarketingShops]                           = sum ([MarketingShops])
    ,[MarketingAmazon]                          = sum ([MarketingAmazon]) 
    ,[MarketingMarketplacesEst]                 = sum ([MarketingMarketplacesEst])
    ,[CommissionsMarketplacesEst]               = sum ([CommissionsMarketplacesEst])
    ,[CommissionsMarketplacesRefundsEst]        = sum ([CommissionsMarketplacesRefundsEst])
    ,[NetOrderContributionEst]                  = sum ([NetOrderContributionEst])- sum(GTSMarkup)
    ,[PC0]                                      = sum ([PC0]) 
    ,[PC1]                                      = sum ([PC1])
    ,[PC2]                                      = sum ([PC2])
    ,[PC3]                                      = sum ([PC3])
    ,CommissionsAmazonEst                       = sum ([CommissionsAmazonEst])
    ,CommissionsAmazonRefundsEst                = sum ([CommissionsAmazonRefundsEst])
    ,MarketingOPEXEst                           = sum(MarketingOPEXEst)  
  FROM [PL].[PL_V_SALES_TRANSACTIONS] as a
  LEFT JOIN [PL].[PL_V_SALES_CHANNEL] as c
    ON a.channelid = c.channelid
  LEFT JOIN [PL].[PL_V_ITEM] as b
    ON b.itemid = a.itemid
  LEFT JOIN [PL].[PL_V_ITEM] as z
    ON z.itemid = a.ItemParentID
  LEFT JOIN  [PL].[PL_V_SALES_TRANSACTION_TYPE] as d
    ON a.transactiontypeid=d.[TransactionTypeid]
  WHERE 1=1
   AND TransactionYear = YEAR(GETDATE()-1)
   AND (d.[TransactionType] in ('Order', 'OrderInvoice') or  a.transactiontypeshort = 'Marketing')
   AND isnull (IncidentFlag,'N')<>'Y'
   AND c.ChannelGroup1 not in ('Intercompany', 'Mandanten')
   AND c.ChannelGroup1 is not null
  -- AND  TransactionMONTH = 6
 
 GROUP BY
   TransactionDate
    ,Year(TransactionDate) 
    ,Month (TransactionDate) 
    ,b.ItemNo
    ,z.ItemNo
    ,a.ItemType
    ,case when c.Channel in ('elektronik-guenstig','elektronik-star','elektr-star-discount','elektr-superguenstig','klarstein.deutschlan','ur.deal') Then 'eBayDE'
            when c.Channel in ('hifi-tower','Hifi-Tower IE','hifi-tower.ie','hifi-tower-deals') THEN 'eBayUK' 
            ELSE c.Channel  END 
    ,c.[ChannelGroup1]
    ,c.[ChannelGroup3]
    , Fulfillment
    ,case when right (c.[ChannelGroup1], 3) ='CEE' then 'SK'
          when DeliveryCountry in ('DE','FR','IT','ES','GB') then DeliveryCountry
          else 'INT' end
    ,case when c.[ChannelGroup1] = 'Amazon' then CONCAT(COALESCE(c.[ChannelGroup1],'OTHERS'),' ',FULFILLMENT) else c.[ChannelGroup1] end
)
SELECT 
     TransactionDate                        = ISNULL(TY.TransactionDate,LY.TransactionDateNY)
    ,TransactionYear                        = ISNULL(TY.TransactionYear,YEAR(LY.TransactionDateNY))
    ,TransactionMonth                       = ISNULL(TY.TransactionMonth,MONTH(LY.TransactionDateNY))
    ,ItemNo                                 = ISNULL(TY.ItemNo,LY.ItemNo)
    ,SetSKU                                 = ISNULL(TY.SetSKU,LY.SetSKU)
    ,ItemParentQuantity                     = ISNULL(TY.ItemParentQuantity,LY.ItemParentQuantity)
    ,ItemType                               = ISNULL(TY.ItemType,LY.ItemType)
    ,channelid                              = ISNULL(TY.channelid,LY.channelid) 
    ,[ChannelGroup1]                        = ISNULL(TY.[ChannelGroup1],LY.[ChannelGroup1])
    ,[ChannelGroup3]                        = ISNULL(TY.[ChannelGroup3],LY.[ChannelGroup3])
    ,Fulfillment                            = ISNULL(TY.Fulfillment,LY.Fulfillment)
    ,SalesCountry                           = ISNULL(TY.SalesCountry,LY.SalesCountry)  
    ,ChannelGroup3B                         = ISNULL(TY.ChannelGroup3B,LY.ChannelGroup3B) 
    ,Turnover                               = ISNULL(TY.Turnover,0)                                  
    ,[OrderQuantity]                        = ISNULL(TY.[OrderQuantity],0)                           
    ,[NetOrderValueEst]                     = ISNULL(TY.[NetOrderValueEst],0)                        
    ,[NetOrderQuantityEst]                  = ISNULL(TY.[NetOrderQuantityEst],0)                     
    ,[NetShippingRevenue]                   = ISNULL(TY.[NetShippingRevenue],0)                      
    ,[RefundedOrderValueEst]                = ISNULL(TY.[RefundedOrderValueEst],0)                   
    ,[RevenueEst]                           = ISNULL(TY.[RevenueEst],0)                              
    ,[NetProductCostEst]                    = ISNULL(TY.[NetProductCostEst],0)                      
    ,[FXHedgingImpactEst]                   = ISNULL(TY.[FXHedgingImpactEst],0)                      
    ,[COGSStockValueAdjustmentEst]          = ISNULL(TY.[COGSStockValueAdjustmentEst],0)
    ,[COGSOperationsEst]                    = ISNULL(TY.[COGSOperationsEst],0)                       
    ,[MarketingShops]                       = ISNULL(TY.[MarketingShops],0)                          
    ,[MarketingAmazon]                      = ISNULL(TY.[MarketingAmazon],0)                         
    ,[MarketingMarketplacesEst]             = ISNULL(TY.[MarketingMarketplacesEst],0) 
    ,[CommissionsMarketplacesEst]           = ISNULL(TY.[CommissionsMarketplacesEst],0)              
    ,[CommissionsMarketplacesRefundsEst]    = ISNULL(TY.[CommissionsMarketplacesRefundsEst],0)
    ,[NetOrderContributionEst]              = ISNULL(TY.[NetOrderContributionEst],0)                 
    ,[PC0]                                  = ISNULL(TY.[PC0],0)                                     
    ,[PC1]                                  = ISNULL(TY.[PC1],0)                                    
    ,[PC2]                                  = ISNULL(TY.[PC2],0)                                     
    ,[PC3]                                  = ISNULL(TY.[PC3],0)                                     
    ,CommissionsAmazonEst                   = ISNULL(TY.CommissionsAmazonEst,0)
    ,CommissionsAmazonRefundsEst            = ISNULL(TY.CommissionsAmazonRefundsEst,0)
    ,MarketingOPEXEst                       = ISNULL(TY.MarketingOPEXEst,0)                          
    ,[NetOrderValueEstLY]                   = ISNULL(LY.[NetOrderValueEstLY],0)
FROM CTE_SALES_TY TY
FULL JOIN CTE_SALES_LY LY
    ON 
        TY.TransactionDate = LY.TransactionDateNY
        AND
        TY.ItemNo = LY.ItemNo
        AND
        TY.SetSKU = LY.SetSKU
        AND
        TY.ItemType = LY.ItemType
        AND
        TY.channelid = LY.channelid
        AND
        TY.[ChannelGroup1] = LY.[ChannelGroup1]
        AND
        TY.[ChannelGroup3] = LY.[ChannelGroup3]
        AND
        TY.Fulfillment = LY.Fulfillment
        AND
        TY.ChannelGroup3B = LY.ChannelGroup3B

