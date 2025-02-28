
CREATE VIEW PL.PL_V_FORECAST_CPNL as
    
	SELECT
			ForecastCode = [CD_FORECAST] 
           ,ForecastDate = [D_FORECAST]
           ,ItemId = [ID_ITEM]
           ,ItemType = [CD_ITEM_TYPE]
           ,ChannelGroup3 = [CD_CHANNEL_GROUP_3]
           ,ReasonCode = [CD_REASON_CODE]
           ,ReasomComment = [T_REASON_COMMENT]
           ,CountryGroup = [CD_COUNTRY_GROUP]
           ,ForecastQuantity = [VL_QUANTITY]
           ,PlanPrice = [AMT_PLAN_PRICE_EUR]
           ,MEK = [AMT_MEK_HEDGING_EUR]
           ,GTSMarkup = [AMT_GTS_MARKUP_EUR]
           ,ShipmentCostEst = [AMT_SHIPPING_COST_EST_EUR]
           ,ReturnRate = [VL_RETURN_RATE]
           ,RefundRate = [VL_REFUND_RATE]
           ,ReplacementValueRate = [VL_REPLACEMENT_RATE]
           ,ReplacementQtyRate = [VL_REPLACEMENT_QUANTITY_RATE]
           ,DepreciationRate = [VL_DEPRECIATION_RATE]
           ,CancellationRate = [VL_CANCELLATION_RATE]
           ,CommissionsRate = [VL_COMMISSIONS_RATE]
           ,MarketingRate = [VL_MARKETING_RATE]
           ,Turnover = [AMT_TURNOVER_EUR]
           ,CancelledOrderQuantity = [VL_CANCELLED_ORDER_QUANTITY]
           ,CancelledOrderValue = [AMT_CANCELLED_ORDER_VALUE_EUR]
           ,NetOrderValue = [AMT_NET_ORDER_VALUE_EST]
           ,NetOrderQuantityEst = [VL_NET_ORDER_QUANTITY_EST]
           ,RefundOrderValueESt = [AMT_REFUNDED_ORDER_VALUE_EST]
           ,RefundQuantityEst = [VL_REFUNDED_QUANTITY_EST]
           ,Commissions = [AMT_COMMISSIONS_EUR]
           ,CommissionsRefunds = [AMT_COMMISSIONS_REFUNDS_EUR]
           ,Marketing = [AMT_MARKETING_EUR]
           ,ReplacementOrderQuantityEst = [AMT_REPLACEMENT_ORDER_QUANTITY_EST]
           ,NetProductCost = [AMT_NET_PRODUCT_COST_EST]
           ,ShippmentCostInvoiced = [AMT_SHIPPING_COSTS_INVOICED_EST]
           ,ShippmentCostReturned = [AMT_SHIPPING_COSTS_RETURNED_EST]
           ,ShippmentCostReplaced = [AMT_SHIPPING_COSTS_REPLACED_EST]
           ,RevenueEst = [AMT_REVENUE_EST_EUR]
		FROM TEST.L1_FACT_A_FORECAST_CPNL







SELECT 
	
FROM PL.PL_V_FORECAST_CPNL fc
LEFT JOIN L0.L0_MI_COST_DELAY_FACTOR depreciation_delay
	on getdate() between depreciation_delay.validfrom and depreciation_delay.ValidTo
