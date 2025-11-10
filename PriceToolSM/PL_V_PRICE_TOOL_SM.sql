CREATE VIEW [PL].PL_V_PRICE_TOOL_SM
AS (
	SELECT
	   PriceDate					= [D_PRICE]
	  ,ItemNo						= [CD_ITEM]
	  ,L1							=T_L1
	  ,L2							=T_L2
	  ,L3							=T_L3
	  ,L4							=T_L4
	  ,ChannelGroup3				= CD_CHANNEL_GROUP_3
	  ,PlanPrice					= [AMT_PLAN_PRICE_EUR]               
	  ,Quantity						= VL_ITEM_QUANTITY                            
	  ,Fulfillment					= CD_FULFILLMENT
	  ,StorageLocation				= T_STORAGE_LOCATION
	  ,Country						= CD_COUNTRY_GROUP
	  ,RefundRate					= [VL_REFUND_RATE]
	  ,ReturnRate					= [VL_RETURN_RATE]
	  ,ReplacementRate				= [VL_REPLACEMENT_RATE]
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
	,CogsProductFC						= [AMT_FULL_NET_PRODUCT_COST_FC_EUR] * -1
	,[ShippingOutboundInvoicedFC]				= [AMT_SHIPPING_COSTS_INVOICED_FC_EUR] * -1
	,[ShippingOutboundReturnedFC]				= [AMT_SHIPPING_COSTS_RETURNED_FC_EUR] * -1
	,[ShippingOutboundReplacedFC]				= [AMT_SHIPPING_COSTS_REPLACED_FC_EUR] * -1
	,GrossMarginFC					= ISNULL(AMT_REVENUE_FC_EUR,0) - ISNULL([AMT_FULL_NET_PRODUCT_COST_FC_EUR],0)
	,SteeringMarginFC					= [AMT_STEERING_MARGIN_FC_EUR]
	,[SM %]							= PCT_SM_ORIGINAL
	,[SMTarget %]					= PCT_SM_TARGET
	,[ExpectedPlanPriceSMTarget]	= AMT_SM_TARGET_PLAN_PRICE_EUR

	FROM [L1].[L1_FACT_F_PRICE_TOOL_SM] kpi



);
GO


