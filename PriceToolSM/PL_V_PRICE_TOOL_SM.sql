ALTER VIEW [PL].PL_V_PRICE_TOOL_SM
AS
	WITH CTE_MAIN_DATA AS (
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
	-- 											 
	,VL_ITEM_QUANTITY_FIRST_YEAR				 AS   QtyFirstYear
	,VL_ITEM_QUANTITY_6M						 AS	  QtyFC6Months
	,VL_ITEM_QUANTITY_12M						 AS	  QtyFC12Months
	,[AMT_NET_ORDER_VALUE_FIRST_YEAR_FC_EUR] 	 AS   NetOrderValueFirstYearFC
	,[AMT_NET_ORDER_VALUE_6M_FC_EUR]			 AS	  NetOrderValue6MFC
	,[AMT_NET_ORDER_VALUE_12M_FC_EUR] 			 AS   NetOrderValue12MFC
	,[AMT_REVENUE_FIRST_YEAR_FC_EUR] 			 AS	  RevenueFirstYearFC
	,[AMT_REVENUE_6M_FC_EUR] 					 AS   Revenue6MFC
	,[AMT_REVENUE_12M_FC_EUR]					 AS   Revenue12MFC
	,[AMT_STEERING_MARGIN_FIRST_YEAR_FC_EUR] 	 AS	  SteeringMarginFirstYearFC
	,[AMT_STEERING_MARGIN_6M_FC_EUR]			 AS   SteeringMargin6MYearFC
	,[AMT_STEERING_MARGIN_12M_FC_EUR]			 AS   SteeringMargin12MYearFC
	,Rank() over(partition by [CD_ITEM],CD_CHANNEL_GROUP_3,CD_COUNTRY_GROUP order by DT_DWH_CREATED desc) AS LastVersion
	FROM [L1].[L1_FACT_F_PRICE_TOOL_SM] kpi
	) 
	SELECT
	*
	FROM CTE_MAIN_DATA
	WHERE 
		LastVersion = 1






--select * from [PL].PL_V_PRICE_TOOL_SM


--select * from  L1.[L1_FACT_F_PRICE_TOOL_SM] 


--select * from  L0.L0_MI_PRICE_TOOL_SM order by load_timestamp 
	SELECT  ISNULL(MAX([DT_DWH_CREATED]),'2025-01-01') FROM [L1].[L1_FACT_F_PRICE_TOOL_SM]

		DECLARE @MAXLOAD_DATE as  datetime2(7)

	SELECT @MAXLOAD_DATE = ISNULL(MAX([DT_DWH_CREATED]),'2025-01-01') FROM [L1].[L1_FACT_F_PRICE_TOOL_SM]

	select *,@MAXLOAD_DATE from  L0.L0_MI_PRICE_TOOL_SM where load_timestamp > @MAXLOAD_DATE