
SELECT distinct f.ChannelGroup3,Channel
	--GrossOrderValue			= SUM(GrossOrderValue),
	--NetOrderValue			= SUM(NetOrderValueEst),
	--RefundOrderValue		= SUM(abs(RefundedOrderValueEst)),
	----[Refund %]				= SUM(Abs(RefundedOrderValueEst)) / SUM(GrossOrderValue),
	--FullNetProductCostSM	= SUM(abs(FullNetProductCostSM))
	--[NetProductCost %]		=  SUM(abs(FullNetProductCostSM)) / SUM(NetOrderValueEst)
	--Revenue = SUM(abs(RevenueEst)),
	--ShippingCost = SUM(abs(FulfillmentOutboundEst)),
	--[ShippingCost %] = SUM(abs(FulfillmentOutboundEst))/ SUM(NetOrderValueEst),
	--Marketing = SUM(abs(MarketingAttributionEstSM)),
	--[Marketing %] = SUM(abs(MarketingAttributionEstSM))/ SUM(NetOrderValueEst),
	--Commissions = SUM(abs(CommissionsEstSM)),
	--[Commissions %] = SUM(abs(CommissionsEstSM))/ SUM(NetOrderValueEst),
	--EnviroLicenseCostEst = SUM(EnviroLicenseCostEst),
	--[EnviroLicenseCostEst %] = SUM(EnviroLicenseCostEst)/ SUM(NetOrderValueEst),
	--GrossMargin = SUM(GrossMargin),
	--[GrossMargin %]= SUM(GrossMargin)/ SUM(RevenueEst),
	--SteeringMargin = SUM(SteeringMarginEstSM),
	--[SteeringMargin %] = SUM(SteeringMarginEstSM)/ SUM(RevenueEst)
FROM 
	[TEST].[PL_V_SALES_TRANSACTIONS_SM] f
	inner join pl.pl_v_sales_channel c on c.channelid = f.channelid
WHERE 
	TRANSACTIOnYEAR = 2025
	--AND TransactionMonth = 11
--	AND DeliveryCountryGroup = 'DE'
	and f.channelgroup3= 'Others'
GROUP BY TransactionMonth,f.ChannelGroup3,Channel

SELECT 'Plan',TargetYear,
	GrossOrderValue = SUM(GrossOrderValue),
	NetOrderquantity = SUM(NetOrderquantityEst),
	NetOrderValue = SUM(NetOrderValueEst),
	RefundOrderValue = SUM(ABS(RefundedOrderValueEst)),
	[Refund %] = SUM(Abs(RefundedOrderValueEst)) / SUM(GrossOrderValue),
	FullNetProductCostSM = SUM(abs(NetProductCostsPlanEurSM)),
	[NetProductCost %] =  SUM(abs(NetProductCostsPlanEurSM)) / SUM(NetOrderValueEst),
	Revenue = SUM((RevenueEst)),
	ShippingCost = SUM(abs(FulfillmentOutboundEst)),
	[ShippingCost %] = SUM(abs(FulfillmentOutboundEst))/ SUM(NetOrderValueEst),
	Marketing = SUM(abs(MarketingAttributionPlanEurSM)),
	[Marketing %] = SUM(abs(MarketingAttributionPlanEurSM))/ SUM(NetOrderValueEst),
	Commissions = SUM(abs(CommissionsPlanEurSM)),
	[Commissions %] = SUM(abs(CommissionsPlanEurSM))/ SUM(NetOrderValueEst),
	EnviroLicenseCostEst = SUM(EnviroLicenseCostEst),
	[EnviroLicenseCostEst %] = SUM(EnviroLicenseCostEst)/ SUM(NetOrderValueEst),
	GrossMargin = SUM(GrossMarginPlanSM),
	[GrossMargin %]= SUM(GrossMarginPlanSM)/ SUM(RevenueEst),
	SteeringMargin = SUM(SteeringMarginPlanSM),
	[SteeringMargin %] = SUM(SteeringMarginPlanSM)/ SUM(RevenueEst)
FROM 
	[TEST].PL_V_BUSINESS_PLAN_KPI_SM
	
WHERE 
	TargetYear = 2026
	--AND TargetMonth = 2
	--AND Country ='DE'
	--and channelgroup3= 'Shop WE'

GROUP BY TargetYear--,ChannelGroup3

Select distinct TargetDAte
FROM 
	[TEST].PL_V_BUSINESS_PLAN_KPI_SM
order by 1


with bp_global as (
	
	SELECT CD_CHANNEL_GROUP_3, D_TARGET,SUM(AMT_TARGET_NET_ORDER_VALUE_EUR) BP_NOV,SUM(VL_ITEM_QUANTITY) BP_NOQ
	FROM [L1].[L1_FACT_F_BUSINESS_PLAN] bs
	GROUP BY CD_CHANNEL_GROUP_3, D_TARGET
)


SELECT 
	bp.CD_CHANNEL_GROUP_3,
	bp.D_TARGET,
	bp.BP_NOV,
	fc.NOV,
	FCNOVFactor = (NOV-BP_NOV)/NOV ,
	bp.BP_NOQ,
	fc.NOQ,
	FCNOQFactor = CASE 
					WHEN 
						CASE WHEN ISNULL(NOQ,0) > 0 THEN (NOQ-BP_NOQ)/NOQ ELSE (NOV-BP_NOV)/NOV END IS NULL THEN 0  
					ELSE 
						CASE WHEN ISNULL(NOQ,0) > 0 THEN (NOQ-BP_NOQ)/NOQ ELSE (NOV-BP_NOV)/NOV END
                    END
  FROM bp_global bp
LEFT JOIN [L0].[L0_MI_BL_FORECAST_TARGETS] fc
	on REPLACE(fc.CHANNELGROUP3,' ','') = REPLACE(bp.CD_CHANNEL_GROUP_3,' ','')
	and cast(fc.TARGETMONTH as date) = bp.D_TARGET
where bp.D_TARGET = '2026-01-01'