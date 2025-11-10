/****** Object:  View [PL].[PL_V_BUSINESS_PLAN_KPI_SM]    Script Date: 13/10/2025 11:47:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [PL].[PL_V_BUSINESS_PLAN_KPI_SM] AS (
	SELECT
	   TargetDate					= D_TARGET
	  ,ItemId						= kpi.[ID_ITEM]                          
	  ,ItemBusinessPlanId			= [ID_ITEM_BUSINESS_PLAN]
	  ,ChannelGroup3				= CD_CHANNEL_GROUP_3
	  ,PlanPrice					= [AMT_PLAN_PRICE_EUR]               
	  ,Quantity						= VL_ITEM_QUANTITY                            
	  ,Fulfillment					= CD_FULFILLMENT
	  ,StorageLocation				= T_REVISED_LOCATION
	  ,Country						= CASE
											WHEN CD_COUNTRY_GROUP IN('FR','DE','IT','ES','GB','INT','NL') THEN CD_COUNTRY_GROUP
											ELSE 'CEE' END
	  ,CountryGroup						= CD_COUNTRY_GROUP
	---kpi--QTY
	,NetOrderQuantityFC				= VL_NET_ORDER_QUANTITY
	,RefundedQuantityFC				= VL_REFUNDED_QUANTITY_FC  * -1
	,ReturnedQuantityFC				= VL_RETURNED_QUANTITY_FC
	,ReplacedQuantityFC				= VL_REPLACEMENT_QUANTITY_FC
	--KPI's Amount
	,NetOrderValueFC					= AMT_NET_ORDER_VALUE_FC_EUR
	,RefundedOrderValueFC				= AMT_REFUNDED_ORDER_VALUE_FC_EUR	* -1
	,RevenueFC							= AMT_REVENUE_FC_EUR
	,ShippingOutboundFC					= AMT_SHIPPING_OUTBOUND_FC_EUR * -1
	,PaymentsFeesFC						= AMT_PAYMENTS_FEES_FC_EUR * -1
	,EnviroRestUnitFC					= AMT_ENVIRO_REST_UNIT_FEE_EUR * -1
	,RepackagingFC						= AMT_REPACKAGING_FC_EUR * -1
	,ElectronicWasteEst					= AMT_ENVIRO_AND_LICENSE_COST_FC_EUR		 * -1	
	--- final
	,MekToCustomerFC					= [AMT_MEK_TO_CUSTOMER_FC_EUR] * -1
	,MEKFromCustomerFC					= [AMT_MEK_FROM_CUSTOMER_FC_EUR]
	,MEKReplacementFC					= [AMT_MEK_REPLACEMENT_FC_EUR] * -1
	,MEKDepreciationFC					= [AMT_MEK_DEPRECIATION_FC_EUR] * -1
	,MarketingCostFC					= [AMT_MARKETING_COST_EUR] * -1
	,CommissionsFC						= [AMT_COMMISSIONS_FC_EUR] * -1
	,CommissionsSaleFC					= [AMT_COMMISSIONS_SALE_FC_EUR] * -1
	,CommissionsRefundsFC				= [AMT_COMMISSIONS_REFUNDS_FC_EUR]
	,SteeringMarginFC					= [AMT_STEERING_MARGIN_FC_EUR]
	,CogsProductFC						= [AMT_FULL_NET_PRODUCT_COST_FC_EUR] * -1
	,[ShippingOutboundInvoicedFC]				= [AMT_SHIPPING_COSTS_INVOICED_FC_EUR] * -1
	,[ShippingOutboundReturnedFC]				= [AMT_SHIPPING_COSTS_RETURNED_FC_EUR] * -1
	,[ShippingOutboundReplacedFC]				= [AMT_SHIPPING_COSTS_REPLACED_FC_EUR] * -1
	,GrossMarginFC					= ISNULL(AMT_REVENUE_FC_EUR,0) - ISNULL([AMT_FULL_NET_PRODUCT_COST_FC_EUR],0)
	FROM [L1].[L1_FACT_F_BUSINESS_PLAN_KPI_SM] kpi
	LEFT JOIN L1.L1_DIM_A_ITEM it on it.ID_ITEM = kpi.ID_ITEM



);
GO


