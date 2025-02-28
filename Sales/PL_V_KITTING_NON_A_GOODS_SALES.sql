/****** Object:  View [PL].[PL_V_KITTING_BGOOD_SALES]    Script Date: 09/04/2024 10:57:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [PL].[PL_V_KITTING_NON_A_GOODS_SALES]
AS WITH CTE_B_KITTING_ORDERS AS 
(
	SELECT DISTINCT CD_SALES_PROCESS_ID
	FROM L1.L1_FACT_A_SALES_TRANSACTION fact
	INNER JOIN L1.L1_DIM_A_ITEM it on it.ID_ITEM = fact.ID_ITEM
	LEFT JOIN [L1].[L1_DIM_A_SALES_CHANNEL] dimchannel
			ON fact.ID_SALES_CHANNEL = dimchannel.ID_SALES_CHANNEL
	WHERE 
		fact.CD_TYPE IN ('ZAA','ZKE','ZAZ')
		AND ISNULL(fact.cd_item_type,'') not in ('A','')
		AND ISNULL(FL_INCIDENT,'N') = 'N' 
		AND it.NUM_ITEM like'7%'
		AND CASE 
			WHEN dimchannel.T_SALES_CHANNEL='Intercompany' OR dimchannel.T_SALES_CHANNEL='Mandanten' THEN 1
			ELSE 0
			END = 0
		AND YEAR(fact.D_CREATED) >= 2024
)

SELECT
 kpi.[CD_SALES_TRANSACTION]                         as  SalesTransactionCode
,kpi.CD_SOURCE_SYSTEM                               as  Source
,kpi.CD_SALES_PROCESS_ID                            as  ProcessId
,kpi.CD_SALES_PROCESS_LINE                          as  ProcessIDPosition
,kpi.CD_DOCUMENT_NO                                 as  DocumentNo
,kpi.CD_DOCUMENT_LINE                               as  DocumentItemPosition
,kpi.CD_DOCUMENT_ID_REFERENCE                       as  ReferenceDocumentId
,kpi.ID_COMPANY                                     as  CompanyId
,kpi.D_CREATED                                      as  TransactionDate
,kpi.D_SALES_PROCESS                                as  ProcessIDDate
,kpi.T_CANCELLATION_REASON                          as  ReasonForRejections
,kpi.FL_INCIDENT                                    as  IncidentFlag
,kpi.DT_CREATED                                     as  OrderCreationDateTime
,kpi.CD_TYPE                                        as  TransactionTypeShort
,kpi.ID_SALES_TRANSACTION_TYPE                      as  TransactionTypeID
,kpi.ID_ITEM                                        as  ItemID
,kpi.ID_ITEM_PARENT                                 as  ItemParentID
,kpi.CD_ITEM_TYPE                                   as  ItemType
,kpi.ID_SALES_CHANNEL                               as  ChannelId
,kpi.CD_FULFILLMENT                                 as  Fulfillment
,kpi.CD_CUSTOMER                                    as  CustomerId
,kpi.T_CREATION_USERNAME                            as  CreatedBy
,kpi.CD_MARKET_ORDER_ID                             as  MarketplaceOrderId
,kpi.CD_PAYMENT_METHOD                              as  PaymentMethod
,kpi.CD_STORAGE_LOCATION                            as  StorageLocationCode
,kpi.T_STORAGE_LOCATION                             as  StorageLocation
,kpi.CD_COUNTRY_INVOICE                             as  InvoiceCountry
,kpi.CD_ZIP_INVOICE                                 as  InvoiceZipCode
,kpi.T_CITY_INVOICE                                 as  InvoiceCity
,kpi.CD_COUNTRY_DELIVERY                            as  DeliveryCountry
,kpi.CD_ZIP_DELIVERY                                as  DeliveryZipCode
,kpi.T_CITY_DELIVERY                                as  DeliveryCity
,kpi.CD_COUNTRY_ORDER                               as  SalesCountry
,kpi.CD_ZIP_ORDER                                   as  SalesZipCode
,kpi.T_CITY_ORDER                                   as  SalesCity
,kpi.CD_CUSTOMER_SERVICE_AGENT                      as  CustomerServiceAgent
,kpi.VL_ITEM_QUANTITY                               as  Quantity
,kpi.AMT_NET_SHIPPING_REVENUE_EUR                   as  NetShippingRevenue
,kpi.AMT_NET_PRICE_EUR                              as  NetPrice
,kpi.AMT_NET_PRICE_FC                               as  NetPriceForeignCurrency
,kpi.AMT_SHIPPING_COST_EST_EUR                      as  ShippingCostEst
,kpi.AMT_GROSS_SHIPPING_REVENUE_EUR                 as  GrossShippingRevenue
,kpi.AMT_GROSS_SHIPPING_REVENUE_FC                  as  GrossShippingRevenueForeignCurrency
,kpi.AMT_GROSS_PRICE_EUR                            as  GrossPrice
,kpi.AMT_GROSS_PRICE_FC                             as  GrossPriceForeignCurrency
,kpi.AMT_TAX_PRICE_EUR                              as  TaxPrice
,kpi.AMT_TAX_DISCOUNTS_EUR                          as  TaxDiscounts
,kpi.AMT_TAX_FREIGHT_EUR                            as  TaxFreight
,kpi.AMT_TAX_TOTAL_EUR                              as  TaxTotal
,kpi.AMT_MEK_HEDGING_EUR                            as  MEKHedging
,kpi.AMT_GTS_MARKUP                                 as  GTSMarkup
,kpi.AMT_NET_DISCOUNT_EUR                           as  Discount
,kpi.CD_CURRENCY                                    as  Currency
,kpi.AMT_COMMERCIAL_TURNOVER_EUR                    as  CommercialTurnover
,kpi.AMT_TURNOVER_EUR                               as  Turnover
,kpi.VL_ORDER_QUANTITY                              as  OrderQuantity
,kpi.AMT_VALUE_ADDED_TAX_EUR                        as  ValueAddedTax
,kpi.AMT_ORDER_DISCOUNTS_EUR                        as  OrderDiscounts
,kpi.AMT_ORDER_CHARGES_EUR                          as  OrderCharges
,kpi.AMT_GROSS_ORDER_VALUE_EUR                      as  GrossOrderValue
,kpi.VL_CANCELLED_ORDERS_QUANTITY_EST               as  CancelledOrdersQuantityEst
,kpi.VL_RETURNED_QUANTITY_EST                       as  ReturnedQuantityEst 
,kpi.AMT_CANCELLED_ORDER_VALUE_EST_EUR              as  CancelledOrderValueEst
,kpi.VL_NET_ORDER_QUANTITY_EST                      as  NetOrderQuantityEst
,kpi.AMT_REFUNDED_ORDER_VALUE_EST_EUR               as  RefundedOrderValueEst
,kpi.AMT_RETURN_ORDER_VALUE_EST_EUR                 as  ReturnOrderValueEst
,kpi.AMT_NET_ORDER_VALUE_EST_EUR                    as  NetOrderValueEst
,kpi.VL_REFUNDED_QUANTITY_EST                       as  RefundedQuantityEst
,kpi.AMT_REVENUE_EST_EUR                            as  RevenueEst
,kpi.VL_NET_QUANTITY_EST                            as  NetQuantityEst
,kpi.AMT_NET_PRODUCT_COST_EST_EUR                   as  NetProductCostEst
,kpi.AMT_NET_ORDER_CONTRIBUTION_EST_EUR				AS NetOrderContributionEst
,kpi.AMT_PC0_EUR                                    as  PC0
,kpi.AMT_DEMURRAGE_DETENTION_EUR                    as  DemurrageDetention
,kpi.AMT_DEADFREIGHT_EUR                            as  Deadfreight
,kpi.AMT_KICKBACKS_EUR                              as  Kickbacks
,kpi.AMT_3RD_PARTY_SERVICES_EUR                     as  [3rdPartyServices]
,kpi.AMT_RMA_EUR                                    as  RMA
,kpi.AMT_SAMPLES_EUR                                as  Samples
,kpi.AMT_OTHER_COGS_EFFECTS_EST_EUR                 as  OtherCOGSEffectsEst
,kpi.AMT_DROPSHIPMENT_CEOTRA9ER_ARTIKEL_EST_EUR     as  DropShipmentCEOTRA9erArtikelEst
,kpi.AMT_INBOUND_FREIGHT_COST_EST_EUR               as  InboundFreightCostsEst
,kpi.AMT_PO_CANCELLATION_EUR                        as  POCancellation
,kpi.AMT_STOCK_ADJUSTMENT_EUR                       as  StockAdjustment
,kpi.AMT_FX_HEDGING_IMPACT_EST_EUR                  as  FXHedgingImpactEst
,kpi.AMT_COGS_STOCK_VALUE_ADJUSTMENT_EST_EUR        as  COGSStockValueAdjustmentEst
,kpi.AMT_COGS_OPERATIONS_EST_EUR                    as  COGSOperationsEst
,kpi.AMT_PC1_EUR                                    as  PC1
,kpi.AMT_PC2_EUR                                    as  PC2
,kpi.AMT_HANDLING_INBOUND_EST_EUR                   as  HandlingInboundEst
,kpi.AMT_HANDLING_TRANS_SHIPPMENT_EST_EUR           as  HandlingTransShippmentEst
,kpi.AMT_PACKAGING_EST_EUR                          as  PackagingEst
,kpi.AMT_HANDLING_SHIPMENTS_EST_EUR                 as  HandlingShipmentsEst
,kpi.AMT_CUSTOMER_SERVICE_HANDLING_EST_EUR          as  CustomerServiceHandlingEst
,kpi.AMT_CUSTOMER_SERVICE_OPEX_EST_EUR              as  CustomerServiceOPEXEst
,kpi.AMT_SHOP_MARKETING_EUR                         as  MarketingShops
,kpi.AMT_AMAZON_MARKETING_EUR                       as  MarketingAmazon
,kpi.AMT_TRUCKING_TRANS_SHIPMENT_EST_EUR            as  TruckingTransShipmentEst
,kpi.AMT_MARKETING_MARKETPLACES_EST_EUR             as  MarketingMarketplacesEst
,kpi.AMT_COMMISSIONS_MARKETPLACES_EST_EUR           as  CommissionsMarketplacesEst
,kpi.AMT_COMMISSIONS_MARKETPLACES_REFUNDS_EST_EUR   as  CommissionsMarketplacesRefundsEst
,kpi.AMT_PAYMENTS_FEES_EST_EUR                      as  PaymentsFeesEst
,kpi.AMT_HANDLING_RETURNS_EST_EUR                   as  HandlingReturnsEst
,kpi.AMT_WAREHOUSING_RENT_EST_EUR                   as  WarehousingRentEst
,kpi.AMT_WAREHOUSING_OPEX_EST_EUR                   as  WarehousingOPEXEst
,kpi.AMT_REPLACEMENT_PRODUCT_COST_EST_EUR           as  ReplacementProductCostEst
,kpi.AMT_REPLACEMENT_ORDER_QUANTITY_EST_EUR         as  ReplacementOrderQuantityEst
,kpi.AMT_COMMISSIONS_AMAZON_EST_EUR                 as  CommissionsAmazonEst
,kpi.AMT_COMMISSIONS_AMAZON_REFUNDS_EST_EUR         as  CommissionsAmazonRefundsEst
,kpi.AMT_WAREHOUSING_FBA_EST_EUR                    as  WarehousingFBAEst
,kpi.AMT_FULFILLMENT_OUTBOUND_EST_EUR               as  FulfillmentOutboundEst
,kpi.AMT_MARKETING_OPEX_EST_EUR                     as  MarketingOPEXEst
,kpi.AMT_PACKAGING_COST_DE_EST_EUR                  as  EnvPackagingDEEst
,kpi.AMT_PACKAGING_COST_ES_EST_EUR                  as  EnvPackagingESEst
,kpi.AMT_PACKAGING_COST_FRA_EST_EUR                 as  EnvPackagingFRAEst
,kpi.AMT_ABJ_EST_EUR                                as  EnvABJEst
,kpi.AMT_PRODUCT_LICENSES_EST                       as  EnvProductLicensesEst
,kpi.AMT_TEXTILE_EST_EUR                            as  EnvTextileEst
,kpi.AMT_WEE_EST_EUR                                as  EnvWEEEst
,kpi.AMT_TARIF_HT_FURNITURE_EST_EUR                 as  EnvFurnitureEst
,kpi.AMT_BATTERIES_EST_EUR                          as  EnvBatteriesEst
,kpi.AMT_PC3_EUR                                    as  PC3
,kpi.AMT_REPACKAGING_EST_EUR						AS  EnvRePackagingEst
,kpi.CD_COUNTRY_GROUP_INVOICE						AS	InvoiceCountryGroup 
,kpi.CD_COUNTRY_GROUP_DELIVERY						AS	DeliveryCountryGroup
,kpi.AMT_ASL_EST_EUR								AS	EnvASLEst
,kpi.AMT_SWE_TAX_EST_EUR							AS  EnvSweChemTaxEst
,kpi.[AMT_ENVIRO_AND_LICENSE_COST_EST_EUR]			AS  EnviroLicenseCostEst
,kpi.[DT_DWH_UPDATED]                               AS  LastModified
FROM 
	L1.L1_FACT_A_SALES_TRANSACTION_KPI kpi
INNER JOIN CTE_B_KITTING_ORDERS kit 
	on kit.CD_SALES_PROCESS_ID = kpi.CD_SALES_PROCESS_ID
WHERE 
	
	kpi.CD_TYPE IN ('ZAA','ZKE','ZAZ');
GO


