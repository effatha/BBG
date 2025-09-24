/****** Object:  View [TEST].[PL_V_SALES_TRANSACTIONS_SM]    Script Date: 10/07/2025 15:24:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [TEST].[PL_V_SALES_TRANSACTIONS_SM] AS SELECT
 [CD_SALES_TRANSACTION]                         as  SalesTransactionCode
,CD_SALES_PROCESS_ID                            as  ProcessId
,ID_COMPANY                                     as  CompanyId
---,ID_DATE										as TransactiondateID --- link to calendar
,D_CREATED                                      as  TransactionDate
,ID_ITEM                                        as  ItemID
,CD_ITEM_TYPE                                   as  ItemType
,s.ID_SALES_CHANNEL                             as  ChannelId
,s.CD_FULFILLMENT                               as  Fulfillment
,CD_MARKET_ORDER_ID                             as  MarketplaceOrderId
,CD_PAYMENT_METHOD                              as  PaymentMethod
--,CD_STORAGE_LOCATION                            as  StorageLocationCode
--,T_STORAGE_LOCATION                             as  StorageLocation
--,CD_COUNTRY_INVOICE                             as  InvoiceCountry
--,CD_ZIP_INVOICE                                 as  InvoiceZipCode
--,T_CITY_INVOICE                                 as  InvoiceCity
,CD_COUNTRY_DELIVERY                            as  DeliveryCountry
--,CD_ZIP_DELIVERY                                as  DeliveryZipCode
--,T_CITY_DELIVERY                                as  DeliveryCity
--,CD_COUNTRY_ORDER                               as  SalesCountry
--,CD_ZIP_ORDER                                   as  SalesZipCode
--,T_CITY_ORDER                                   as  SalesCity
--,CD_CUSTOMER_SERVICE_AGENT                      as  CustomerServiceAgent
,VL_ITEM_QUANTITY                               as  Quantity
--,AMT_NET_SHIPPING_REVENUE_EUR                   as  NetShippingRevenue
--,AMT_NET_PRICE_EUR                              as  NetPrice
--,AMT_NET_PRICE_FC                               as  NetPriceForeignCurrency
--,AMT_SHIPPING_COST_EST_EUR                      as  ShippingCostEst
--,CD_SHIPMENT_COSTS_SOURCE                       AS  ShipmentCostsSource
--,AMT_GROSS_SHIPPING_REVENUE_EUR                 as  GrossShippingRevenue
--,AMT_GROSS_SHIPPING_REVENUE_FC                  as  GrossShippingRevenueForeignCurrency
--,AMT_GROSS_PRICE_EUR                            as  GrossPrice
--,AMT_GROSS_PRICE_FC                             as  GrossPriceForeignCurrency
--,AMT_TAX_PRICE_EUR                              as  TaxPrice
--,AMT_TAX_DISCOUNTS_EUR                          as  TaxDiscounts
--,AMT_TAX_FREIGHT_EUR                            as  TaxFreight
--,AMT_TAX_TOTAL_EUR                              as  TaxTotal
--,AMT_MEK_HEDGING_EUR                            as  MEKHedging
--,AMT_GTS_MARKUP                                 as  GTSMarkup
--,AMT_NET_DISCOUNT_EUR                           as  Discount
--,CD_CURRENCY                                    as  Currency
--,AMT_COMMERCIAL_TURNOVER_EUR                    as  CommercialTurnover
--,AMT_TURNOVER_EUR                               as  Turnover
,VL_ORDER_QUANTITY                              as  OrderQuantity
--,AMT_VALUE_ADDED_TAX_EUR                       * -1 as  ValueAddedTax
--,AMT_ORDER_DISCOUNTS_EUR                        as  OrderDiscounts
--,AMT_ORDER_CHARGES_EUR                          as  OrderCharges
,AMT_GROSS_ORDER_VALUE_EUR                      as  GrossOrderValueAct
--,VL_CANCELLED_ORDERS_QUANTITY_EST          * -1 as  CancelledOrdersQuantityEst
--,VL_RETURNED_QUANTITY_EST                       as  ReturnedQuantityEst 
,AMT_CANCELLED_ORDER_VALUE_EST_EUR          * -1    as  CancelledOrderValueEst
,VL_NET_ORDER_QUANTITY_EST                      as  NetOrderQuantityEst
,AMT_REFUNDED_ORDER_VALUE_EST_EUR           * -1    as  RelatedRefundValueEst
--,AMT_RETURN_ORDER_VALUE_EST_EUR                 as  ReturnOrderValueEst
,AMT_NET_ORDER_VALUE_EST_EUR                    as  NetOrderValueEst
--,VL_REFUNDED_QUANTITY_EST                    * -1   as  RefundedQuantityEst
,AMT_REVENUE_EST_EUR                            as  RevenueEst
--,VL_NET_QUANTITY_EST                            as  NetQuantityEst
--,AMT_NET_ORDER_CONTRIBUTION_EST_EUR				AS NetOrderContributionEst

,AMT_MARKETING_MARKETPLACES_EST_EUR             as  MarketingMarketplacesEst--- discuss this in a broad meeting

--,AMT_COMMISSIONS_MARKETPLACES_EST_EUR           as  CommissionsMarketplacesEst
--,AMT_COMMISSIONS_MARKETPLACES_REFUNDS_EST_EUR   as  CommissionsMarketplacesRefundsEst
,AMT_PAYMENTS_FEES_EST_EUR                     *-1 as  PaymentsFeesEst  --- does this applies to refund as well (currently beeing calculated based on revenue)
--,AMT_REPLACEMENT_PRODUCT_COST_EST_EUR           as  ReplacementProductCostEst
--,AMT_REPLACEMENT_ORDER_QUANTITY_EST_EUR         as  ReplacementOrderQuantityEst
--,AMT_COMMISSIONS_AMAZON_EST_EUR                 as  CommissionsAmazonEst
--,AMT_COMMISSIONS_AMAZON_REFUNDS_EST_EUR         as  CommissionsAmazonRefundsEst
,AMT_FULFILLMENT_OUTBOUND_EST_EUR           * -1    as  [ShippingOutboundEst] --- replaced
,AMT_ENVIRO_AND_LICENSE_COST_EST_EUR         * -1   as  ElectronicWasteEst --- replaced
,CD_COUNTRY_GROUP_INVOICE						AS	InvoiceCountryGroup 
--,CASE WHEN CD_COUNTRY_DELIVERY in('PL','FR','CZ','HR','IT','GB','RO','HU','ES','BG','DE','SI','SK','NL') THEN CD_COUNTRY_DELIVERY
--							  WHEN  right (ch.[CD_CHANNEL_GROUP_1], 3) ='CEE' then 'SK' 
--							  ELSE 'INT' END						AS	DeliveryCountryGroup
,VL_REFUND_RATE 					            AS  RefundRate
,VL_RETURN_RATE				                    AS  ReturnRate
,VL_REPLACEMENT_RATE                            AS  ReplacementRate
,CD_REFUND_RATE_SOURCE							AS  RefundRateSource
,CD_RETURN_RATE_SOURCE							AS  ReturnRateSource
,CD_REPLACEMENT_RATE_SOURCE						AS  ReplacementRateSource

---- REMOVE THE SM Suffixes
,AMT_MEK_TO_CUSTOMER_EST_EUR 				 * -1   AS	MEKToCustomerEst
,AMT_MEK_FROM_CUSTOMER_EST_EUR						AS	MEKFromCustomerEst
,AMT_MEK_REPLACEMENT_EST_EUR 				 * -1   AS  MEKReplacementEst
,AMT_MEK_DEPRECIATION_EST_EUR 				 * -1   AS	MEKDepretiationEst
,AMT_FULL_NET_PRODUCT_COST_EST_EUR			*-1    AS	CogsProductEst

,AMT_MARKETING_COST_EUR						* -1   AS  MarketingCostAct
,AMT_COMMISSIONS_EST_EUR					 * -1   AS	CommissionsEst
,AMT_COMMISSIONS_SALE_EST_EUR				 * -1   AS	CommissionSalesEst
,AMT_COMMISSIONS_REFUNDS_EST_EUR					AS  CommissionRefundsEst
,AMT_STEERING_MARGIN_EST_EUR				    AS  SteeringMarginEst
,AMT_SHIPPING_COST_INVOICED_EST				* -1	AS	ShipingOutboundInvoicedEst
,AMT_SHIPPING_COST_RETURNED_EST				* -1	AS	ShipingOutboundReturnedEst
,AMT_SHIPPING_COST_REPLACED_EST				* -1	AS	ShipingOutboundReplacedEst
,AMT_GROSS_MARGIN_EST_EUR						AS	GrossMarginEst
,ISNULL(CD_COUNTRY_GROUP_DELIVERY,'INT')						AS DeliveryCountryGroup
ch.CD_CHANNEL_GROUP_3					AS ChannelGroup3
FROM TEST.L1_FACT_A_SALES_TRANSACTION_KPI_SM s
LEFT JOIN L1.L1_DIM_A_SALES_CHANNEL ch on ch.ID_SALES_CHANNEL = s.ID_SALES_CHANNEL
WHERE
	ch.CD_CHANNEL_GROUP_3 not in ('Others')
GO


