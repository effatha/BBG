/****** Object:  View [TEST].[PL_V_SALES_TRANSACTIONS_SM]    Script Date: 10/07/2025 15:24:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [TEST].[PL_V_SALES_TRANSACTIONS_SM] AS SELECT
 [CD_SALES_TRANSACTION]                         as  SalesTransactionCode
,s.CD_SOURCE_SYSTEM                               as  Source
,CD_SALES_PROCESS_ID                            as  ProcessId
,CD_SALES_PROCESS_LINE                          as  ProcessIDPosition
,CD_DOCUMENT_NO                                 as  DocumentNo
,CD_DOCUMENT_LINE                               as  DocumentItemPosition
,CD_DOCUMENT_ID_REFERENCE                       as  ReferenceDocumentId
,ID_COMPANY                                     as  CompanyId
,D_CREATED                                      as  TransactionDate
,YEAR(D_CREATED)                                as  TransactionYear
,MONTH(D_CREATED)                               as  TransactionMonth
,D_SALES_PROCESS                                as  ProcessIDDate
,T_CANCELLATION_REASON                          as  ReasonForRejections
,FL_INCIDENT                                    as  IncidentFlag
,DT_CREATED                                     as  OrderCreationDateTime
,CD_TYPE                                        as  TransactionTypeShort
,ID_SALES_TRANSACTION_TYPE                      as  TransactionTypeID
,ID_ITEM                                        as  ItemID
,ID_ITEM_PARENT                                 as  ItemParentID
,CD_ITEM_TYPE                                   as  ItemType
,s.ID_SALES_CHANNEL                               as  ChannelId
,s.CD_FULFILLMENT                                 as  Fulfillment
,CD_CUSTOMER                                    as  CustomerId
,T_CREATION_USERNAME                            as  CreatedBy
,CD_MARKET_ORDER_ID                             as  MarketplaceOrderId
,CD_PAYMENT_METHOD                              as  PaymentMethod
,CD_STORAGE_LOCATION                            as  StorageLocationCode
,T_STORAGE_LOCATION                             as  StorageLocation
,CD_COUNTRY_INVOICE                             as  InvoiceCountry
,CD_ZIP_INVOICE                                 as  InvoiceZipCode
,T_CITY_INVOICE                                 as  InvoiceCity
,CD_COUNTRY_DELIVERY                            as  DeliveryCountry
,CD_ZIP_DELIVERY                                as  DeliveryZipCode
,T_CITY_DELIVERY                                as  DeliveryCity
,CD_COUNTRY_ORDER                               as  SalesCountry
,CD_ZIP_ORDER                                   as  SalesZipCode
,T_CITY_ORDER                                   as  SalesCity
,CD_CUSTOMER_SERVICE_AGENT                      as  CustomerServiceAgent
,VL_ITEM_QUANTITY                               as  Quantity
,AMT_NET_SHIPPING_REVENUE_EUR                   as  NetShippingRevenue
,AMT_NET_PRICE_EUR                              as  NetPrice
,AMT_NET_PRICE_FC                               as  NetPriceForeignCurrency
,AMT_SHIPPING_COST_EST_EUR                      as  ShippingCostEst
,CD_SHIPMENT_COSTS_SOURCE                       AS  ShipmentCostsSource
,AMT_GROSS_SHIPPING_REVENUE_EUR                 as  GrossShippingRevenue
,AMT_GROSS_SHIPPING_REVENUE_FC                  as  GrossShippingRevenueForeignCurrency
,AMT_GROSS_PRICE_EUR                            as  GrossPrice
,AMT_GROSS_PRICE_FC                             as  GrossPriceForeignCurrency
,AMT_TAX_PRICE_EUR                              as  TaxPrice
,AMT_TAX_DISCOUNTS_EUR                          as  TaxDiscounts
,AMT_TAX_FREIGHT_EUR                            as  TaxFreight
,AMT_TAX_TOTAL_EUR                              as  TaxTotal
,AMT_MEK_HEDGING_EUR                            as  MEKHedging
,AMT_GTS_MARKUP                                 as  GTSMarkup
,AMT_NET_DISCOUNT_EUR                           as  Discount
,CD_CURRENCY                                    as  Currency
,AMT_COMMERCIAL_TURNOVER_EUR                    as  CommercialTurnover
,AMT_TURNOVER_EUR                               as  Turnover
,VL_ORDER_QUANTITY                              as  OrderQuantity
,AMT_VALUE_ADDED_TAX_EUR                       * -1 as  ValueAddedTax
,AMT_ORDER_DISCOUNTS_EUR                        as  OrderDiscounts
,AMT_ORDER_CHARGES_EUR                          as  OrderCharges
,AMT_GROSS_ORDER_VALUE_EUR                      as  GrossOrderValue
,VL_CANCELLED_ORDERS_QUANTITY_EST          * -1     as  CancelledOrdersQuantityEst
,VL_RETURNED_QUANTITY_EST                       as  ReturnedQuantityEst 
,AMT_CANCELLED_ORDER_VALUE_EST_EUR          * -1    as  CancelledOrderValueEst
,VL_NET_ORDER_QUANTITY_EST                      as  NetOrderQuantityEst
,AMT_REFUNDED_ORDER_VALUE_EST_EUR           * -1    as  RefundedOrderValueEst
,AMT_RETURN_ORDER_VALUE_EST_EUR                 as  ReturnOrderValueEst
,AMT_NET_ORDER_VALUE_EST_EUR                    as  NetOrderValueEst
,VL_REFUNDED_QUANTITY_EST                    * -1   as  RefundedQuantityEst
,AMT_REVENUE_EST_EUR                            as  RevenueEst
,VL_NET_QUANTITY_EST                            as  NetQuantityEst
,AMT_NET_PRODUCT_COST_EST_EUR                   as  NetProductCostEst
,AMT_NET_ORDER_CONTRIBUTION_EST_EUR				AS NetOrderContributionEst
,AMT_PC0_EUR                                    as  PC0
,AMT_DEMURRAGE_DETENTION_EUR                    as  DemurrageDetention
,AMT_DEADFREIGHT_EUR                            as  Deadfreight
,AMT_KICKBACKS_EUR                              as  Kickbacks
,AMT_3RD_PARTY_SERVICES_EUR                     as  [3rdPartyServices]
,AMT_RMA_EUR                                    as  RMA
,AMT_SAMPLES_EUR                                as  Samples
,AMT_OTHER_COGS_EFFECTS_EST_EUR                 as  OtherCOGSEffectsEst
,AMT_DROPSHIPMENT_CEOTRA9ER_ARTIKEL_EST_EUR     as  DropShipmentCEOTRA9erArtikelEst
,AMT_INBOUND_FREIGHT_COST_EST_EUR               as  InboundFreightCostsEst
,AMT_PO_CANCELLATION_EUR                        as  POCancellation
,AMT_STOCK_ADJUSTMENT_EUR                       as  StockAdjustment
,AMT_FX_HEDGING_IMPACT_EST_EUR                  as  FXHedgingImpactEst
,AMT_COGS_STOCK_VALUE_ADJUSTMENT_EST_EUR        as  COGSStockValueAdjustmentEst
,AMT_COGS_OPERATIONS_EST_EUR                    as  COGSOperationsEst
,AMT_PC1_EUR                                    as  PC1
,AMT_PC2_EUR                                    as  PC2
,AMT_HANDLING_INBOUND_EST_EUR                   as  HandlingInboundEst
,AMT_HANDLING_TRANS_SHIPPMENT_EST_EUR           as  HandlingTransShippmentEst
,AMT_PACKAGING_EST_EUR                          as  PackagingEst
,AMT_HANDLING_SHIPMENTS_EST_EUR                 as  HandlingShipmentsEst
,AMT_CUSTOMER_SERVICE_HANDLING_EST_EUR          as  CustomerServiceHandlingEst
,AMT_CUSTOMER_SERVICE_OPEX_EST_EUR              as  CustomerServiceOPEXEst
,AMT_SHOP_MARKETING_EUR                         as  MarketingShops
,AMT_AMAZON_MARKETING_EUR                       as  MarketingAmazon
,AMT_TRUCKING_TRANS_SHIPMENT_EST_EUR            as  TruckingTransShipmentEst
,AMT_MARKETING_MARKETPLACES_EST_EUR             as  MarketingMarketplacesEst
,AMT_COMMISSIONS_MARKETPLACES_EST_EUR           as  CommissionsMarketplacesEst
,AMT_COMMISSIONS_MARKETPLACES_REFUNDS_EST_EUR   as  CommissionsMarketplacesRefundsEst
,AMT_PAYMENTS_FEES_EST_EUR                     *-1 as  PaymentsFeesEst
,AMT_HANDLING_RETURNS_EST_EUR                   as  HandlingReturnsEst
,AMT_WAREHOUSING_RENT_EST_EUR                   as  WarehousingRentEst
,AMT_WAREHOUSING_OPEX_EST_EUR                   as  WarehousingOPEXEst
,AMT_REPLACEMENT_PRODUCT_COST_EST_EUR           as  ReplacementProductCostEst
,AMT_REPLACEMENT_ORDER_QUANTITY_EST_EUR         as  ReplacementOrderQuantityEst
,AMT_COMMISSIONS_AMAZON_EST_EUR                 as  CommissionsAmazonEst
,AMT_COMMISSIONS_AMAZON_REFUNDS_EST_EUR         as  CommissionsAmazonRefundsEst
,AMT_WAREHOUSING_FBA_EST_EUR                    as  WarehousingFBAEst
,AMT_FULFILLMENT_OUTBOUND_EST_EUR           * -1    as  FulfillmentOutboundEst
,AMT_MARKETING_OPEX_EST_EUR                     as  MarketingOPEXEst
,AMT_PC3_EUR                                    as  PC3
,AMT_ENVIRO_AND_LICENSE_COST_EST_EUR         * -1   as  EnviroLicenseCostEst
,AMT_ENVIRO_REST_UNIT_FEE_EUR                * -1   as  EnviroRestUnitFee
,AMT_REPACKAGING_EUR                         * -1   as  Repackaging
,CD_COUNTRY_GROUP_INVOICE						AS	InvoiceCountryGroup 
--,CASE WHEN CD_COUNTRY_DELIVERY in('PL','FR','CZ','HR','IT','GB','RO','HU','ES','BG','DE','SI','SK','NL') THEN CD_COUNTRY_DELIVERY
--							  WHEN  right (ch.[CD_CHANNEL_GROUP_1], 3) ='CEE' then 'SK' 
--							  ELSE 'INT' END						AS	DeliveryCountryGroup
,AMT_DEPRECIATION_EST_EUR                       AS  DepreciationEst
,T_RETURN_REASON                                AS  ReturnReason
,CD_GTS_PO_NO									AS	GTSPurchasingNo
,CD_GTS_PO_LINE									AS	GTSPurchasingItemPosition
,[FL_SINGLE_ITEM]                               AS  SingleItem
,[CD_CANCELLED_DOCUMENT_NO]                     AS  CancelledDocumentNo
,[CD_CANCELLED_DOCUMENT_LINE]                   AS  CancelledDocumentLine
,CD_PRECEDING_DOCUMENT_NO                       AS  PrecedingDocumentNumber
,CD_LINKED_DOCUMENT_NO                          AS  LinkedDocumentNumber
,[FL_DELETED]                                   AS  Deleted
,[CD_CARRIER]                                   AS  Carrier 
,AMT_NET_ORDER_VALUE_EUR                        AS  NetOrderValue
,AMT_CANCELLED_ORDER_VALUE_EUR					AS  CancelledOrderValue
,VL_ITEM_PARENT_QUANTITY						AS  ItemParentQuantity
,VL_REFUND_RATE 					            AS  RefundRate
,VL_RETURN_RATE				                    AS  ReturnRate
,VL_REPLACEMENT_RATE                            AS  ReplacementRate
,CD_REFUND_RATE_SOURCE							AS  RefundRateSource
,CD_RETURN_RATE_SOURCE							AS  ReturnRateSource
,CD_REPLACEMENT_RATE_SOURCE						AS  ReplacementRateSource
,D_CANCELLATION									AS  CancellationDate
,AMT_MEK_TO_CUSTOMER_EST_EUR 				 * -1   AS	MekToCustomerEstSM
,AMT_MEK_FROM_CUSTOMER_EST_EUR				    AS	MekFromCustomerEstSM
,AMT_MEK_REPLACEMENT_EST_EUR 				 * -1   AS  MekReplacementEstSMSM
,AMT_MEK_DEPRECIATION_EST_EUR 				 * -1   AS	MekDepretiationEstSM
,AMT_MARKETING_ATTRIBUTION_EST_EUR			 * -1   AS  MarketingAttributionEstSM
,AMT_COMMISSIONS_EST_EUR					 * -1   AS	CommissionsEstSM
,AMT_COMMISSIONS_SALE_EST_EUR				 * -1   AS	CommissionSalesEstSM
,AMT_COMMISSIONS_REFUNDS_EST_EUR		        AS  CommissionRefundsEstSM
,AMT_STEERING_MARGIN_EST_EUR				    AS  SteeringMarginEstSM
,AMT_FULL_NET_PRODUCT_COST_EST_EUR			*-1    AS	FullNetProductCostSM
,AMT_SHIPPING_COST_INVOICED_EST				* -1	AS	ShippingCostsInvoicedEst
,AMT_SHIPPING_COST_RETURNED_EST				* -1	AS	ShippingCostsReturnedEst
,AMT_SHIPPING_COST_REPLACED_EST				* -1	AS	ShippingCostsReplacedEst
,AMT_GROSS_MARGIN_EST_EUR						AS	GrossMargin
,ISNULL(CD_COUNTRY_GROUP_DELIVERY,'INT')						AS DeliveryCountryGroup
,SMComment  = CASE WHEN ISNULL(AMT_MEK_HEDGING_EUR,0) between 0 and 0.3 THEN 'Issue  - MEK not available'
				   WHEN ISNULL(AMT_SHIPPING_COST_EST_EUR,0) between 0 and 0.5 THEN 'Issue - Shipping cost not available'
				   WHEN REPLACE(ch.CD_CHANNEL_GROUP_1,' ','') in ('MarketplacesWE',',MarketplacesCEE','Amazon') and ISNULL(AMT_COMMISSIONS_EST_EUR,0) = 0  THEN 'Issue - Commissions not available'
				   WHEN  ISNULL(AMT_MARKETING_ATTRIBUTION_EST_EUR,0) = 0  THEN 'Issue - Marketing Cost not available'
				   WHEN ISNULL(AMT_SHIPPING_COST_EST_EUR,0)/ISNULL(AMT_NET_ORDER_VALUE_EST_EUR,0) >= 0.5 THEN 'Issue - Shipping cost too High' 

				   ELSE 'OK' END,
ch.CD_CHANNEL_GROUP_3					AS ChannelGroup3
FROM TEST.L1_FACT_A_SALES_TRANSACTION_KPI_SM s
LEFT JOIN L1.L1_DIM_A_SALES_CHANNEL ch on ch.ID_SALES_CHANNEL = s.ID_SALES_CHANNEL;
GO


