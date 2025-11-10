/****** Object:  StoredProcedure [WR].[WR_TX_PL_V_SALES_TRANSACTIONS_SM_PL_M_SALES_TRANSACTIONS_SM]    Script Date: 13/10/2025 11:38:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [WR].[WR_TX_PL_V_SALES_TRANSACTIONS_SM_PL_M_SALES_TRANSACTIONS_SM] AS
BEGIN

TRUNCATE TABLE [PL].PL_M_SALES_TRANSACTIONS_SM 


INSERT INTO [PL].PL_M_SALES_TRANSACTIONS_SM
(
	    [SalesTransactionCode]
      ,[Source]
      ,[ProcessId]
      ,[CompanyId]
      ,[TransactionDate]
      ,[ItemID]
      ,[ItemType]
      ,[ChannelId]
      ,[Fulfillment]
      ,[DeliveryCountryGroup]
      ,[MarketplaceOrderId]
      ,[PaymentMethod]
      ,[StorageLocationCode]
      ,[StorageLocation]
      ,[DeliveryCountry]
      ,[RefundRate]
      ,[ReturnRate]
      ,[ReplacementRate]
      ,[RefundRateSource]
      ,[ReturnRateSource]
      ,[ReplacementRateSource]
      ,[Quantity]
      ,[OrderQuantity]
      ,[GrossOrderValueAct]
      ,[NetShippingRevenueAct]
      ,[CancelledOrderValueEst]
      ,[NetOrderQuantityEst]
      ,[RelatedRefundValueEst]
      ,[NetOrderValueEst]
      ,[RevenueEst]
      ,[MarketingMarketplacesEst]
      ,[PaymentsFeesEst]
      ,[ShippingOutboundEst]
      ,[ElectronicWasteEst]
      ,[MEKToCustomerEst]
      ,[MEKFromCustomerEst]
      ,[MEKReplacementEst]
      ,[MEKDepretiationEst]
      ,[CogsProductEst]
      ,[MarketingCostAct]
      ,[CommissionsEst]
      ,[CommissionSalesEst]
      ,[CommissionRefundsEst]
      ,[SteeringMarginEst]
      ,[ShippingOutboundInvoicedEst]
      ,[ShippingOutboundReturnedEst]
      ,[ShippingOutboundReplacedEst]
      ,[GrossMarginEst]

)
SELECT
[SalesTransactionCode]
      ,[Source]
      ,[ProcessId]
      ,[CompanyId]
      ,[TransactionDate]
      ,[ItemID]
      ,[ItemType]
      ,[ChannelId]
      ,[Fulfillment]
      ,[DeliveryCountryGroup]
      ,[MarketplaceOrderId]
      ,[PaymentMethod]
      ,[StorageLocationCode]
      ,[StorageLocation]
      ,[DeliveryCountry]
      ,[RefundRate]
      ,[ReturnRate]
      ,[ReplacementRate]
      ,[RefundRateSource]
      ,[ReturnRateSource]
      ,[ReplacementRateSource]
      ,[Quantity]
      ,[OrderQuantity]
      ,[GrossOrderValueAct]
      ,[NetShippingRevenueAct]
      ,[CancelledOrderValueEst]
      ,[NetOrderQuantityEst]
      ,[RelatedRefundValueEst]
      ,[NetOrderValueEst]
      ,[RevenueEst]
      ,[MarketingMarketplacesEst]
      ,[PaymentsFeesEst]
      ,[ShippingOutboundEst]
      ,[ElectronicWasteEst]
      ,[MEKToCustomerEst]
      ,[MEKFromCustomerEst]
      ,[MEKReplacementEst]
      ,[MEKDepretiationEst]
      ,[CogsProductEst]
      ,[MarketingCostAct]
      ,[CommissionsEst]
      ,[CommissionSalesEst]
      ,[CommissionRefundsEst]
      ,[SteeringMarginEst]
      ,[ShippingOutboundInvoicedEst]
      ,[ShippingOutboundReturnedEst]
      ,[ShippingOutboundReplacedEst]
      ,[GrossMarginEst]
    FROM PL.PL_V_SALES_TRANSACTIONS_SM
    WHERE
        [TransactionDate] > DATEADD(MONTH, -14, EOMONTH(GETDATE()))


END

GO


