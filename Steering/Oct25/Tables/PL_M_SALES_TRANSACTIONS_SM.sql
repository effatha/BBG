/****** Object:  Table [PL].[PL_M_SALES_TRANSACTIONS_SM]    Script Date: 13/10/2025 11:45:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [PL].[PL_M_SALES_TRANSACTIONS_SM]
(
	[SalesTransactionCode] [varchar](250) NULL,
	[Source] [varchar](10) NULL,
	[ProcessId] [varchar](10) NULL,
	[CompanyId] [int] NULL,
	[TransactionDate] [date] NULL,
	[ItemID] [int] NULL,
	[ItemType] [varchar](10) NULL,
	[ChannelId] [int] NULL,
	[Fulfillment] [varchar](16) NULL,
	[DeliveryCountryGroup] [varchar](10) NULL,
	[MarketplaceOrderId] [varchar](150) NULL,
	[PaymentMethod] [varchar](50) NULL,
	[StorageLocationCode] [varchar](10) NULL,
	[StorageLocation] [varchar](50) NULL,
	[DeliveryCountry] [varchar](5) NULL,
	[RefundRate] [decimal](19, 6) NULL,
	[ReturnRate] [decimal](19, 6) NULL,
	[ReplacementRate] [decimal](19, 6) NULL,
	[RefundRateSource] [varchar](20) NULL,
	[ReturnRateSource] [varchar](20) NULL,
	[ReplacementRateSource] [varchar](20) NULL,
	[Quantity] [decimal](19, 6) NULL,
	[OrderQuantity] [decimal](19, 6) NULL,
	[GrossOrderValueAct] [decimal](19, 6) NULL,
	[NetShippingRevenueAct] [decimal](19, 6) NULL,
	[CancelledOrderValueEst] [decimal](21, 6) NULL,
	[NetOrderQuantityEst] [decimal](19, 6) NULL,
	[RelatedRefundValueEst] [decimal](21, 6) NULL,
	[NetOrderValueEst] [decimal](19, 6) NULL,
	[RevenueEst] [decimal](19, 6) NULL,
	[MarketingMarketplacesEst] [decimal](19, 6) NULL,
	[PaymentsFeesEst] [decimal](21, 6) NULL,
	[ShippingOutboundEst] [decimal](21, 6) NULL,
	[ElectronicWasteEst] [decimal](21, 6) NULL,
	[MEKToCustomerEst] [decimal](21, 2) NULL,
	[MEKFromCustomerEst] [decimal](19, 2) NULL,
	[MEKReplacementEst] [decimal](21, 2) NULL,
	[MEKDepretiationEst] [decimal](21, 2) NULL,
	[CogsProductEst] [decimal](21, 2) NULL,
	[MarketingCostAct] [decimal](38, 4) NULL,
	[CommissionsEst] [decimal](21, 2) NULL,
	[CommissionSalesEst] [decimal](21, 2) NULL,
	[CommissionRefundsEst] [decimal](19, 2) NULL,
	[SteeringMarginEst] [decimal](23, 2) NULL,
	[ShippingOutboundInvoicedEst] [decimal](21, 2) NULL,
	[ShippingOutboundReturnedEst] [decimal](21, 2) NULL,
	[ShippingOutboundReplacedEst] [decimal](21, 2) NULL,
	[GrossMarginEst] [decimal](19, 2) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO


