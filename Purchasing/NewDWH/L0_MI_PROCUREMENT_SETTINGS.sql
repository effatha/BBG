CREATE TABLE [L0].[L0_MI_PROCUREMENT_SETTINGS]
(
	[SETTING_NAME] [nvarchar](150) NULL,
	[VALUE] decimal(19,2) NULL,
	[DESCRIPTION] [nvarchar](500) NULL,
	[LOAD_TIMESTAMP] [datetime2](7) NULL
)
WITH
(
	DISTRIBUTION = REPLICATE,
	HEAP
)
GO

select * from [L0].[L0_MI_PROCUREMENT_SETTINGS]
INSERT INTO [L0].[L0_MI_PROCUREMENT_SETTINGS](SETTING_NAME,VALUE,DESCRIPTION,LOAD_TIMESTAMP)
SELECT 'LandingCostsPaymentDays',16,'Number of days after EATWH the payment mus be made','2025-08-13'
UNION SELECT 'LandingCosts',0.16,'16 % flat assumption of teh full Purchasing Order','2025-08-13'
UNION SELECT 'ProdLeadTime',70,'Production lead time default in days. To use whe the field is missing from item master data','2025-08-13'
UNION SELECT 'ETAPortDateNumberDays',14,'Number of days to use to calculate EETA port date. ETAWahrehouse -N Days','2025-08-13'
UNION SELECT 'ETDTransit',70,'Number of days to use to calculate ETD (Transit Days). ETAWahrehouse -N Days','2025-08-13'

