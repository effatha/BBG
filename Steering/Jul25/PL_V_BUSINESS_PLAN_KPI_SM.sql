/****** Object:  View [TEST].[PL_V_BUSINESS_PLAN_KPI_SM]    Script Date: 24/07/2025 11:59:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [TEST].[PL_V_BUSINESS_PLAN_KPI_SM] AS (
	SELECT
	   SnapshotDate					= D_SNAPSHOT                         
	  ,TargetMonth					= MONTH([D_TARGET])
	  ,TargetYear					= YEAR([D_TARGET])
	  ,ItemId						= kpi.[ID_ITEM]                          
	  ,ItemBusinessPlanId			= [ID_ITEM_BUSINESS_PLAN]
	  ,ChannelGroup3				= CASE WHEN [CD_CHANNEL_GROUP_3] = 'ShopWe' THEN 'Shop WE'
											WHEN [CD_CHANNEL_GROUP_3] = 'MarketplacesWE' THEN 'Marketplaces WE'
											ELSE [CD_CHANNEL_GROUP_3] END
	  ,PlanPrice					= [AMT_PLAN_PRICE_EUR]               
	  ,Quantity						= VL_ITEM_QUANTITY                 
	  ,Mekhedging					= [AMT_MEK_HEDGING_EUR]              
	  ,GtsMarkup					= [AMT_GTS_MARKUP_EUR]               
	  ,CompanyId					= ID_COMPANY
	  ,TargetDate					= D_TARGET
	  ,Fulfillment					= CD_FULFILLMENT
	  ,StorageLocation				= T_REVISED_LOCATION
	  ,Country						= CASE
											WHEN CD_COUNTRY_GROUP IN('FR','DE','IT','ES','GB','INT') THEN CD_COUNTRY_GROUP
											WHEN CD_COUNTRY_GROUP IN('NL') THEN 'INT'
											ELSE 'CEE' END
	  ,Currency						= CD_CURRENCY
	  ,ShippingCostEst				= AMT_SHIPPING_COST_EST_EUR
	---kpi--QTY
	,CancelledOrdersQuantityEst			= VL_CANCELLED_ORDERS_QUANTITY_EST
	,NetOrderQuantityEst				= VL_NET_ORDER_QUANTITY
	,RefundedQuantityEst				= VL_REFUNDED_QUANTITY_EST  * -1
	,ReturnedQuantityEst				= VL_RETURNED_QUANTITY_EST
	,ReplacedQuantityEst				= VL_REPLACEMENT_QUANTITY_EST
	--KPI's Amount
	,GrossOrderValue					= AMT_GROSS_ORDER_VALUE_EUR
	,CancelledOrderValueEst				= AMT_CANCELLED_ORDER_VALUE_EST_EUR * -1
	,NetOrderValueEst					= AMT_NET_ORDER_VALUE_EST_EUR
	,RefundedOrderValueEst				= AMT_REFUNDED_ORDER_VALUE_EST_EUR	* -1
	,RevenueEst							= AMT_REVENUE_EST_EUR
	,DepreciationEst					= AMT_DEPRECIATION_EST_EUR
	,NetProductCostEst					= NULL--AMT_NET_PRODUCT_COST_EST_EUR
	,PC0Est								= NULL --AMT_PC0_EST_EUR
	,DemurrageDetention					= NULL --AMT_DEMURRAGE_DETENTION_EUR
	,Deadfreight						= NULL --AMT_DEADFREIGHT_EUR
	,Kickbacks							= NULL --AMT_KICKBACKS_EUR
	,[3rdPartyServices]					= NULL --AMT_3RD_PARTY_SERVICES_EUR
	,RMA								= NULL --AMT_RETURN_MERCHANDISE_AUTHORIZATION_EUR
	,Samples							= NULL --AMT_SAMPLES_EUR
	,OtherCOGSEffectsEst				= NULL --AMT_OTHER_COGS_EFFECT_EST_EUR
	,DropShipmentCEOTRA9erArtikelEst	= NULL --AMT_DROPSHIPMENT_CEOTRA9ER_EST_EUR
	,InboundFreightCostsEst				= NULL --AMT_INBOUND_FREIGHT_COST_EST_EUR
	,POCancellation						= NULL --AMT_PO_CANCELLATION_EUR
	,StockAdjustment					= NULL --AMT_STOCK_ADJUSTMENT_EUR
	,FXHedgingImpactEst					= NULL --AMT_FX_HEDGING_IMPACT_EST_EUR
	,COGSStockValueAdjustmentEst		= NULL --AMT_COGS_STOCK_VALUE_ADJUSTMENT_EST_EUR
	,COGSOperationsEst					= NULL --AMT_COGS_OPERATIONS_EST
	,PC1Est								= NULL --AMT_PC1_EST_EUR
	,PackagingEst						= NULL --AMT_PACKAGING_EUR
	,HandlingInboundEst					= NULL --AMT_HANDLING_INBOUND_EST_EUR
	,HandlingTransShippmentEst			= NULL --AMT_HANDLING_TRANS_SHIPPMENT_EST_EUR
	,TruckingTransShipmentEst			= NULL --AMT_TRUCKING_TRANS_SHIPMENT_EST_EUR
	,HandlingReturnsEst					= NULL --AMT_HANDLING_RETURNS_EST_EUR
	,WarehousingFBAEst					= NULL --AMT_WAREHOUSING_FBA_EUR
	,FulfillmentOutboundEst				= AMT_FULFILLMENT_OUTBOUND_EST_EUR * -1
	,CommissionsMarketplacesEst			= NULL --AMT_COMMISSIONS_MARKETPLACES_EUR
	,CommissionsMarketplacesRefundsEst  = NULL --AMT_COMMISSIONS_MARKETPLACES_REFUNDS_EUR
	,MarketingMarketplacesEst			= NULL --AMT_MARKETING_MARKETPLACES_EST_EUR
	,CommissionsAmazonEst				= NULL --AMT_COMMISSIONS_AMAZON_EUR
	,CommissionsAmazonRefundsEst		= NULL --AMT_COMMISSIONS_AMAZON_REFUNDS_EUR
	,MarketingShops						= NULL --AMT_SHOP_MARKETING_EUR
	,PaymentsFeesEst					= AMT_PAYMENTS_EUR * -1
	,MarketingAmazon					= NULL --AMT_AMAZON_MARKETING_COSTS_EUR
	,EnviroRestUnitFee					= AMT_ENVIRO_REST_UNIT_FEE_EUR * -1
	,Repackaging						= AMT_REPACKAGING_EUR * -1
	,EnviroLicenseCostEst				= [AMT_ENVIRO_AND_LICENSE_COST_EST_EUR]		 * -1	
	,PC2Est								= NULL --AMT_PC2_EST_EUR
	,WarehousingRentEst					= NULL --AMT_WAREHOUSING_RENT_EST_EUR
	,WarehousingOPEXEst					= NULL --AMT_WAREHOUSING_OPEX_EST_EUR
	,MarketingOPEXEst					= 0
	,HandlingShipmentsEst				= NULL --AMT_HANDLING_ORDERS_EST_EUR
	,CSManagement						= NULL --AMT_CS_MANAGEMENT_EST_EUR
	,CustomerServiceHandlingEst			= NULL --AMT_CS_HANDLING_CLAIMS_EUR
	,CustomerServiceOPEXEst				= NULL --AMT_CS_MANAGEMENT_EST_EUR
	,PC3Est								= NULL --AMT_PC3_EST_EUR
	,NetOrderContributionEst			= AMT_NET_ORDER_CONTRIBUTION_EST_EUR
	--- final
	,ExcludeB2B							= CASE WHEN [CD_CHANNEL_GROUP_3] = 'B2B' AND cd_MA_BRAND NOT IN ('FreshBaby') THEN 'No' ELSE 'Yes' END
	,LastUpdated						= kpi.[DT_DWH_UPDATED]
	,MekToCustomerPlanEurSM				= AMT_MEK_TO_CUSTOMER_PLAN_EUR_SM * -1
	,MEKFromCustomerPlanEurSM			= AMT_MEK_FROM_CUSTOMER_PLAN_EUR_SM
	,MEKReplacementPlanEurSM			= AMT_MEK_REPLACEMENT_PLAN_EUR_SM * -1
	,MEKDepreciationPlanEurSM			= AMT_MEK_DEPRECIATION_PLAN_EUR_SM * -1
	,MarketingAttributionPlanEurSM		= AMT_MARKETING_ATTRIBUTION_PLAN_EUR_SM * -1
	,CommissionsPlanEurSM				= AMT_COMMISSIONS_PLAN_EUR_SM * -1
	,CommissionsSalePlanEurSM			= AMT_COMMISSIONS_SALE_PLAN_EUR_SM * -1
	,CommissionsRefundsPlanEurSM		= AMT_COMMISSIONS_REFUNDS_PLAN_EUR_SM
	,SteeringMarginPlanSM				= AMT_STEERING_MARGIN_PLAN_EUR_SM
	,NetProductCostsPlanEurSM			= AMT_FULL_NET_PRODUCT_COST_PLAN_EUR_SM * -1
	,ShippingInvoicedPlanSM				= AMT_SHIPPING_COST_INVOICED_PLAN_SM * -1
	,ShippingReturnedPlanSM				= AMT_SHIPPING_COST_RETURNED_PLAN_SM * -1
	,ShippingReplacedPlanSM				= AMT_SHIPPING_COST_REPLACED_PLAN_SM * -1
	,GrossMarginPlanSM					= ISNULL(AMT_REVENUE_EST_EUR,0) - ISNULL(AMT_FULL_NET_PRODUCT_COST_PLAN_EUR_SM,0)
	FROM TEST.[L1_FACT_F_BUSINESS_PLAN_KPI_SM] kpi
	LEFT JOIN L1.L1_DIM_A_ITEM it on it.ID_ITEM = kpi.ID_ITEM



);
GO


