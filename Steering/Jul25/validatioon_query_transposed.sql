DECLARE @YEAR as INT = 2025
DECLARE @MONTH as INT = 1

;with CTE_smpnl as
(
SELECT 
    'SMPnL' AS [Type],
    CAST(SUM(GrossOrderValue) AS DECIMAL(18,6)) AS GrossOrderValue,
    CAST(SUM(NetOrderValueEst) AS DECIMAL(18,6)) AS NetOrderValue,
    CAST(SUM(ABS(RefundedOrderValueEst)) AS DECIMAL(18,6)) AS RefundOrderValue,
    CAST(SUM(ABS(RefundedOrderValueEst)) / NULLIF(SUM(GrossOrderValue), 0) AS DECIMAL(18,6)) AS [Refund %],

    CAST(SUM(ABS(FullNetProductCostSM)) AS DECIMAL(18,6)) AS FullNetProductCostSM,
    CAST(SUM(ABS(FullNetProductCostSM)) / NULLIF(SUM(NetOrderValueEst), 0) AS DECIMAL(18,6)) AS [NetProductCost %],

    CAST(SUM(ABS(RevenueEst)) AS DECIMAL(18,6)) AS Revenue,

    CAST(SUM(ABS(FulfillmentOutboundEst)) AS DECIMAL(18,6)) AS ShippingCost,
    CAST(SUM(ABS(FulfillmentOutboundEst)) / NULLIF(SUM(NetOrderValueEst), 0) AS DECIMAL(18,6)) AS [ShippingCost %],

    CAST(SUM(ABS(MarketingAttributionEstSM)) AS DECIMAL(18,6)) AS Marketing,
    CAST(SUM(ABS(MarketingAttributionEstSM)) / NULLIF(SUM(NetOrderValueEst), 0) AS DECIMAL(18,6)) AS [Marketing %],

    CAST(SUM(ABS(CommissionsEstSM)) AS DECIMAL(18,6)) AS Commissions,
    CAST(SUM(ABS(CommissionsEstSM)) / NULLIF(SUM(NetOrderValueEst), 0) AS DECIMAL(18,6)) AS [Commissions %],

    CAST(SUM(EnviroLicenseCostEst) AS DECIMAL(18,6)) AS EnviroLicenseCostEst,
    CAST(SUM(EnviroLicenseCostEst) / NULLIF(SUM(NetOrderValueEst), 0) AS DECIMAL(18,6)) AS [EnviroLicenseCostEst %],

    CAST(SUM(GrossMargin) AS DECIMAL(18,6)) AS GrossMargin,
    CAST(SUM(GrossMargin) / NULLIF(SUM(RevenueEst), 0) AS DECIMAL(18,6)) AS [GrossMargin %],

    CAST(SUM(SteeringMarginEstSM) AS DECIMAL(18,6)) AS SteeringMargin,
    CAST(SUM(SteeringMarginEstSM) / NULLIF(SUM(RevenueEst), 0) AS DECIMAL(18,6)) AS [SteeringMargin %]
FROM [TEST].[PL_V_SALES_TRANSACTIONS_SM]
WHERE TRANSACTIOnYEAR = @YEAR
  AND TransactionMonth = @MONTH
  AND DeliveryCountryGroup = 'INT'

),
CTE_PLAN AS (
SELECT 
    'Plan' AS [Type],
  CAST(SUM(ABS(GrossOrderValue)) AS DECIMAL(18,6)) AS GrossOrderValue,
CAST(SUM(ABS(NetOrderValueEst)) AS DECIMAL(18,6)) AS NetOrderValue,
CAST(SUM(ABS(RefundedOrderValueEst)) AS DECIMAL(18,6)) AS RefundOrderValue,
CAST(SUM(ABS(RefundedOrderValueEst)) / NULLIF(SUM(ABS(GrossOrderValue)), 0) AS DECIMAL(18,6)) AS [Refund %],

CAST(SUM(ABS(NetProductCostsPlanEurSM)) AS DECIMAL(18,6)) AS FullNetProductCostSM,
CAST(SUM(ABS(NetProductCostsPlanEurSM)) / NULLIF(SUM(ABS(NetOrderValueEst)), 0) AS DECIMAL(18,6)) AS [NetProductCost %],

CAST(SUM(ABS(RevenueEst)) AS DECIMAL(18,6)) AS Revenue,

CAST(SUM(ABS(FulfillmentOutboundEst)) AS DECIMAL(18,6)) AS ShippingCost,
CAST(SUM(ABS(FulfillmentOutboundEst)) / NULLIF(SUM(ABS(NetOrderValueEst)), 0) AS DECIMAL(18,6)) AS [ShippingCost %],

CAST(SUM(ABS(MarketingAttributionPlanEurSM)) AS DECIMAL(18,6)) AS Marketing,
CAST(SUM(ABS(MarketingAttributionPlanEurSM)) / NULLIF(SUM(ABS(NetOrderValueEst)), 0) AS DECIMAL(18,6)) AS [Marketing %],

CAST(SUM(ABS(CommissionsPlanEurSM)) AS DECIMAL(18,6)) AS Commissions,
CAST(SUM(ABS(CommissionsPlanEurSM)) / NULLIF(SUM(ABS(NetOrderValueEst)), 0) AS DECIMAL(18,6)) AS [Commissions %],

CAST(SUM(ABS(EnviroLicenseCostEst)) AS DECIMAL(18,6)) AS EnviroLicenseCostEst,
CAST(SUM(ABS(EnviroLicenseCostEst)) / NULLIF(SUM(ABS(NetOrderValueEst)), 0) AS DECIMAL(18,6)) AS [EnviroLicenseCostEst %],

CAST(SUM(ABS(GrossMarginPlanSM)) AS DECIMAL(18,6)) AS GrossMargin,
CAST(SUM(ABS(GrossMarginPlanSM)) / NULLIF(SUM(ABS(RevenueEst)), 0) AS DECIMAL(18,6)) AS [GrossMargin %],

CAST(SUM(ABS(SteeringMarginPlanSM)) AS DECIMAL(18,6)) AS SteeringMargin,
CAST(SUM(ABS(SteeringMarginPlanSM)) / NULLIF(SUM(ABS(RevenueEst)), 0) AS DECIMAL(18,6)) AS [SteeringMargin %]

FROM [TEST].PL_V_BUSINESS_PLAN_KPI_SM
WHERE TargetYear = @YEAR
  AND TargetMonth = @MONTH
  AND Country = 'INT'


)
SELECT 
    smp.MetricName,
    --smp.Value AS SMPnL_Value,
    --pln.Value AS Plan_Value,
    [Plan] =  CASE 
        WHEN pln.MetricName LIKE '%[%]%' THEN FORMAT(pln.Value, 'P2')  
        ELSE FORMAT(pln.Value, 'N2')                                 
    END,
    [SMPnL] =  CASE 
        WHEN smp.MetricName LIKE '%[%]%' THEN FORMAT(smp.Value, 'P2')   
        ELSE FORMAT(smp.Value, 'N2')                                 
    END 
FROM 
    (SELECT * FROM CTE_smpnl) AS s
UNPIVOT 
    (Value FOR MetricName IN (
        GrossOrderValue, 
        NetOrderValue, 
        RefundOrderValue, 
        [Refund %], 
        FullNetProductCostSM, 
        [NetProductCost %], 
        Revenue, 
        [ShippingCost], 
        [ShippingCost %], 
        [Marketing], 
        [Marketing %], 
        [Commissions], 
        [Commissions %], 
        [EnviroLicenseCostEst], 
        [EnviroLicenseCostEst %],
        [GrossMargin], 
        [GrossMargin %], 
        [SteeringMargin],
        [SteeringMargin %]
    )) AS smp
INNER JOIN
    (SELECT * FROM CTE_PLAN) AS p
UNPIVOT 
    (Value FOR MetricName IN (
        GrossOrderValue,
        NetOrderValue,
        RefundOrderValue, 
        [Refund %], 
        FullNetProductCostSM, 
        [NetProductCost %], 
        Revenue,
        [ShippingCost], 
        [ShippingCost %], 
        [Marketing],
        [Marketing %], 
        [Commissions],
        [Commissions %], 
        [EnviroLicenseCostEst],
        [EnviroLicenseCostEst %],
        [GrossMargin],
        [GrossMargin %], 
        [SteeringMargin],
        [SteeringMargin %]
    )) AS pln
    ON smp.MetricName = pln.MetricName;

    select * from L0.[L0_MI_BUSINESS_PLAN_MARKETING_RATES] where month = '2025-01-01'

    --select top 10 * 
    --from  [TEST].L1_FACT_F_BUSINESS_PLAN_KPI_SM 
    --WHERe
    --    d_TARGET = '2025-01-01'
    --    and cd_channel_group_3 = 'MarketplacesWe'
    --    and cd_country_group = 'INT'
    --    and AMT_COMMISSIONS_MARKETPLACES_EUR  > 