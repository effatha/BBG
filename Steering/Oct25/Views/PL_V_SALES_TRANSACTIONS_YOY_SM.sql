/****** Object:  View [PL].[PL_V_SALES_TRANSACTIONS_YOY_SM]    Script Date: 13/10/2025 11:48:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [PL].[PL_V_SALES_TRANSACTIONS_YOY_SM] AS SELECT
       TransactionYear                    = YEAR([TransactionDate])
      ,TransactionMonth                   = MONTH([TransactionDate])
    --  ,[Quantity]                         = SUM(ISNULL([Quantity],0))
      --,[OrderQuantity]                    = SUM(ISNULL([OrderQuantity],0))
      --,[GrossOrderValueAct]               = SUM(ISNULL([GrossOrderValueAct],0))
      --,[NetShippingRevenueAct]            = SUM(ISNULL([NetShippingRevenueAct],0))
      --,[CancelledOrderValueEst]           = SUM(ISNULL([CancelledOrderValueEst],0))
      --,[NetOrderQuantityEst]              = SUM(ISNULL([NetOrderQuantityEst],0))
      --,[RelatedRefundValueEst]            = SUM(ISNULL([RelatedRefundValueEst],0))
      --,[NetOrderValueEst]                 = SUM(ISNULL([NetOrderValueEst],0))
      --,[RevenueEst]                       = SUM(ISNULL([RevenueEst],0))
      --,[MarketingMarketplacesEst]         = SUM(ISNULL([MarketingMarketplacesEst],0))
      --,[PaymentsFeesEst]                  = SUM(ISNULL([PaymentsFeesEst],0))
      --,[ShippingOutboundEst]              = SUM(ISNULL([ShippingOutboundEst],0))
      --,[ElectronicWasteEst]               = SUM(ISNULL([ElectronicWasteEst],0))
      --,[MEKToCustomerEst]                 = SUM(ISNULL([MEKToCustomerEst],0))
      --,[MEKFromCustomerEst]               = SUM(ISNULL([MEKFromCustomerEst],0))
      --,[MEKReplacementEst]                = SUM(ISNULL([MEKReplacementEst],0))
      --,[MEKDepretiationEst]               = SUM(ISNULL([MEKDepretiationEst],0))
      --,[CogsProductEst]                   = SUM(ISNULL([CogsProductEst],0))
      --,[MarketingCostAct]                 = SUM(ISNULL([MarketingCostAct],0))
      --,[CommissionsEst]                   = SUM(ISNULL([CommissionsEst],0))
      --,[CommissionSalesEst]               = SUM(ISNULL([CommissionSalesEst],0))
      --,[CommissionRefundsEst]             = SUM(ISNULL([CommissionRefundsEst],0))
      ,[SteeringMarginEst]                = SUM(ISNULL([SteeringMarginEst],0))
      --,[ShippingOutboundInvoicedEst]      = SUM(ISNULL([ShippingOutboundInvoicedEst],0))
      --,[ShippingOutboundReturnedEst]      = SUM(ISNULL([ShippingOutboundReturnedEst],0))
      --,[ShippingOutboundReplacedEst]      = SUM(ISNULL([ShippingOutboundReplacedEst],0))
      --,[GrossMarginEst]                   = SUM(ISNULL([GrossMarginEst],0))
    FROM PL.PL_V_SALES_TRANSACTIONS_SM
    WHERE
        [TransactionDate] >='2024-01-01'
    GROUP BY 
        YEAR([TransactionDate]),
        MONTH([TransactionDate]);
GO


