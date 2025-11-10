/****** Object:  View [PL].[PL_V_SALES_TRANSACTIONS_SM]    Script Date: 13/10/2025 11:48:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [PL].[PL_V_SALES_TRANSACTIONS_SM] AS with cte_mkt_cost as (
	SELECT
		 ID_SALES_TRANSACTION
		,SUM(AMT_MKT_COST_EUR) AS AMT_MARKETING_COST_EUR
	FROM L1.L1_FACT_A_SALES_TRANSACTION_MKT_KPI_SM
	GROUP BY ID_SALES_TRANSACTION
)

	
SELECT
	 [CD_SALES_TRANSACTION]								as  SalesTransactionCode
	,s.CD_SOURCE_SYSTEM									AS	Source
	,CD_SALES_PROCESS_ID								as  ProcessId
	,ID_COMPANY											as  CompanyId
	,D_CREATED											as  TransactionDate
	,ID_ITEM											as  ItemID
	,CD_ITEM_TYPE										as  ItemType
	,s.ID_SALES_CHANNEL									as  ChannelId
	,s.CD_FULFILLMENT									as  Fulfillment
	,CD_COUNTRY_GROUP_DELIVERY							AS	DeliveryCountryGroup 
	,CD_MARKET_ORDER_ID									as  MarketplaceOrderId
	,CD_PAYMENT_METHOD									as  PaymentMethod
	,CD_STORAGE_LOCATION								as  StorageLocationCode
	,T_STORAGE_LOCATION									as  StorageLocation
	,CD_COUNTRY_DELIVERY								as  DeliveryCountry
	,VL_REFUND_RATE 									AS  RefundRate
	,VL_RETURN_RATE										AS  ReturnRate
	,VL_REPLACEMENT_RATE								AS  ReplacementRate
	,CD_REFUND_RATE_SOURCE								AS  RefundRateSource
	,CD_RETURN_RATE_SOURCE								AS  ReturnRateSource
	,CD_REPLACEMENT_RATE_SOURCE							AS  ReplacementRateSource
	,VL_ITEM_QUANTITY									as  Quantity
	,VL_ORDER_QUANTITY									as  OrderQuantity
	,AMT_GROSS_ORDER_VALUE_EUR							as  GrossOrderValueAct
	,AMT_NET_SHIPPING_REVENUE_EUR						as	NetShippingRevenueAct
	,AMT_CANCELLED_ORDER_VALUE_EST_EUR          * -1    as  CancelledOrderValueEst
	,VL_NET_ORDER_QUANTITY_EST							as  NetOrderQuantityEst
	,AMT_REFUNDED_ORDER_VALUE_EST_EUR           * -1    as  RelatedRefundValueEst
	,AMT_NET_ORDER_VALUE_EST_EUR		                as  NetOrderValueEst
	,AMT_REVENUE_EST_EUR		                        as  RevenueEst
	,AMT_MARKETING_MARKETPLACES_EST_EUR				* -1	as  MarketingMarketplacesEst--- discuss this in a broad meeting
	,AMT_PAYMENTS_FEES_EST_EUR                  * -1	as  PaymentsFeesEst  --- does this applies to refund as well (currently beeing calculated based on revenue)
	,AMT_SHIPPING_OUTBOUND_EST_EUR				 * -1   as  ShippingOutboundEst --- replaced
	,AMT_ELECTRONIC_WASTE_EST_EUR				* -1	as  ElectronicWasteEst --- replaced
	---- REMOVE THE SM Suffixes
	,AMT_MEK_TO_CUSTOMER_EST_EUR 				 * -1   AS	MEKToCustomerEst
	,AMT_MEK_FROM_CUSTOMER_EST_EUR						AS	MEKFromCustomerEst
	,AMT_MEK_REPLACEMENT_EST_EUR 				 * -1   AS  MEKReplacementEst
	,AMT_MEK_DEPRECIATION_EST_EUR 				 * -1   AS	MEKDepretiationEst
	,AMT_FULL_NET_PRODUCT_COST_EST_EUR			 * -1   AS	CogsProductEst

	,(ISNULL(AMT_MARKETING_COST_EUR,0) + ISNULL(AMT_MARKETING_MARKETPLACES_EST_EUR,0))						 * -1   AS  MarketingCostAct
	,AMT_COMMISSIONS_EST_EUR					 * -1   AS	CommissionsEst
	,AMT_COMMISSIONS_SALE_EST_EUR				 * -1   AS	CommissionSalesEst
	,AMT_COMMISSIONS_REFUNDS_EST_EUR					AS  CommissionRefundsEst
	,(ISNULL(AMT_STEERING_MARGIN_EST_EUR,0) - ISNULL(AMT_MARKETING_COST_EUR,0) - ISNULL(AMT_MARKETING_MARKETPLACES_EST_EUR,0))		AS  SteeringMarginEst
	,AMT_SHIPPING_COST_INVOICED_EST_EUR				* -1	AS	ShippingOutboundInvoicedEst
	,AMT_SHIPPING_COST_RETURNED_EST_EUR				* -1	AS	ShippingOutboundReturnedEst
	,AMT_SHIPPING_COST_REPLACED_EST_EUR				* -1	AS	ShippingOutboundReplacedEst
	,AMT_GROSS_MARGIN_EST_EUR								AS	GrossMarginEst
FROM L1.L1_FACT_A_SALES_TRANSACTION_KPI_SM s
LEFT JOIN L1.L1_DIM_A_SALES_CHANNEL ch on ch.ID_SALES_CHANNEL = s.ID_SALES_CHANNEL
LEFT JOIN cte_mkt_cost mkt on mkt.ID_SALES_TRANSACTION = s.ID_SALES_TRANSACTION
WHERE
	ch.CD_CHANNEL_GROUP_3 not in ('Others')
	
UNION ALL

SELECT 
	 [CD_SALES_TRANSACTION]				as  SalesTransactionCode
	,CD_SOURCE_SYSTEM					AS	Source
	,NULL								as  ProcessId
	,NULL								as  CompanyId
	,D_CREATED							as  TransactionDate
	,ID_ITEM							as  ItemID
	,'A'								as  ItemType
	,ID_SALES_CHANNEL					as  ChannelId
	,NULL								as  Fulfillment
	,CD_COUNTRY_GROUP					AS	DeliveryCountryGroup 
	,NULL								as  MarketplaceOrderId
	,NULL								as  PaymentMethod
	,NULL								as  StorageLocationCode
	,NULL								as  StorageLocation
	,NULL								as  DeliveryCountry
	,NULL 								AS  RefundRate
	,NULL								AS  ReturnRate
	,NULL								AS  ReplacementRate
	,NULL								AS  RefundRateSource
	,NULL								AS  ReturnRateSource
	,NULL								AS  ReplacementRateSource
	,NULL								AS  Quantity
	,NULL								AS  OrderQuantity
	,NULL								as  GrossOrderValueAct
	,NULL								as	NetShippingRevenueAct
	,NULL								as  CancelledOrderValueEst
	,NULL								as  NetOrderQuantityEst
	,NULL								as  RelatedRefundValueEst
	,NULL								as  NetOrderValueEst
	,NULL		                        as  RevenueEst
	,NULL								as  MarketingMarketplacesEst
	,NULL								as  PaymentsFeesEst 
	,NULL							    as  ShippingOutboundEst 
	,NULL								as  ElectronicWasteEst 
	,NULL 								AS	MEKToCustomerEst
	,NULL								AS	MEKFromCustomerEst
	,NULL 								AS  MEKReplacementEst
	,NULL 								AS	MEKDepretiationEst
	,NULL								AS	CogsProductEst
	,AMT_MKT_COST_EUR			* -1	AS  MarketingCostAct
	,NULL								AS	CommissionsEst
	,NULL								AS	CommissionSalesEst
	,NULL								AS  CommissionRefundsEst
	,AMT_MKT_COST_EUR			* -1	AS  SteeringMarginEst
	,NULL								AS	ShipingOutboundInvoicedEst
	,NULL								AS	ShipingOutboundReturnedEst
	,NULL								AS	ShipingOutboundReplacedEst
	,NULL								AS	GrossMarginEst
FROM L1.L1_FACT_A_SALES_TRANSACTION_MKT_KPI_SM s
WHERE ID_SALES_TRANSACTION IS NULL;
GO


