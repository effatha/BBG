-- Declare date range
DECLARE @StartDate DATE = '2026-01-01';  -- Adjust start
DECLARE @EndDate DATE = '2026-12-01';    -- Adjust end
DECLARE @CurrentMonth DATE = @StartDate;

-- Variables to track time
DECLARE @StartTime DATETIME2;
DECLARE @EndTime DATETIME2;
DECLARE @DurationMs INT;

-- Loop through each month
WHILE @CurrentMonth <= @EndDate
BEGIN
    PRINT 'Running for month: ' + CONVERT(VARCHAR(7), @CurrentMonth, 120);

    SET @StartTime = SYSDATETIME();

    EXEC [TEST].[WR_TX_L1_FACT_F_BUSINESS_PLAN_L1_FACT_F_BUSINESS_PLAN_KPI_SM] 
    --EXEC [TEST].[WR_TX_L0_MI_BUSINESS_PLAN_L1_FACT_F_BUSINESS_PLAN_SM] --@MonthDate = '2025-01-01'
        @MonthDate = @CurrentMonth;

    SET @EndTime = SYSDATETIME();

    SET @DurationMs = DATEDIFF(MILLISECOND, @StartTime, @EndTime);

    PRINT 'Duration: ' + CAST(@DurationMs AS VARCHAR) + ' ms';
    PRINT '--------------------------------------------------';

    -- Go to next month
    SET @CurrentMonth = DATEADD(MONTH, 1, @CurrentMonth);
END
