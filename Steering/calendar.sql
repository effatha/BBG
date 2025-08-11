
-- For PostgreSQL/MySQL, use:
-- DROP TABLE IF EXISTS Calendar;


-- 1. Create the Calendar Table
CREATE TABLE PL.PL_M_CALENDAR (
    DateId INT NOT NULL,
    FullDate DATE NOT NULL ,
    DayOfMonth INT NOT NULL,
    Month INT NOT NULL,
    MonthName NVARCHAR(20) NOT NULL,
    Year INT NOT NULL

)
WITH
(
    DISTRIBUTION = REPLICATE, -- Replicated tables are good for smaller dimension tables (under 2GB compressed)
    HEAP -- Use HEAP initially, then convert to Clustered Columnstore after data load if desired
);
GO -- For SQL Server


-- 2. Populate the Calendar Table
-- Define the date range for population
DECLARE @StartDate DATE = '2024-01-01';
DECLARE @EndDate DATE = '2026-12-31';
DECLARE @CurrentDate DATE = @StartDate;

-- For PostgreSQL/MySQL, use:
-- SET @StartDate = '2020-01-01';
-- SET @EndDate = '2030-12-31';


-- Use a Common Table Expression (CTE) to generate a series of dates
WHILE @CurrentDate <= @EndDate
BEGIN
INSERT INTO PL.PL_M_CALENDAR (
    DateId,
    FullDate,
    DayOfMonth,
    Month,
    MonthName,
    Year
)
 SELECT
        CAST(FORMAT(@CurrentDate, 'yyyyMMdd') AS INT) AS DateKey,
        @CurrentDate AS FullDate,
        DAY(@CurrentDate) AS DayOfMonth,
        MONTH(@CurrentDate) AS Month,
        DATENAME(month, @CurrentDate) AS MonthName,
        YEAR(@CurrentDate) AS Year

    SET @CurrentDate = DATEADD(day, 1, @CurrentDate);
END;

