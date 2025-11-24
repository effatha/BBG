--DROP TABLE [L0].[L0_MI_PRICE_TOOL_SM]
CREATE TABLE [L0].[L0_MI_PRICE_TOOL_SM]
(
	[ITEMNO] [varchar](50) NULL,
	[PLANPRICE] [decimal](19, 4) NULL,
	[MEK] [decimal](19, 4) NULL,
	[SHIPPINGCOST] [decimal](19, 4) NULL,
	[COUNTRY] [varchar](50) NULL,
	[CHANNELGROUP3] [varchar](50) NULL,
	[L1] [varchar](150) NULL,
	[L2] [varchar](150) NULL,
	[L3] [varchar](150) NULL,
	[L4] [varchar](150) NULL,
	[SMTARGET] [decimal](19, 4) NULL,
	[MONTHCALCULATION] datetime NULL,
	[QtyFirstYear] [decimal](19, 4) NULL,
	[QtyFC6Months] [decimal](19, 4) NULL,
	[QtyFC12Months] [decimal](19, 4) NULL,
	[REFUNDRATE] [decimal](19, 4) NULL,
	[RETURNRATE] [decimal](19, 4) NULL,
	[REPLACEMENTRATE] [decimal](19, 4) NULL,
	[MARKETINGRATE] [decimal](19, 4) NULL,
	[LOAD_TIMESTAMP] [datetime2](7) NULL

)
WITH
(
	DISTRIBUTION = REPLICATE,
	HEAP
)
GO



)
WITH
(
	DISTRIBUTION = REPLICATE,
	HEAP
)
GO

INSERT INTO [L0].L0_MI_PRICE_TOOL_SM
(
	ItemNo,
	PlanPrice,
	MEK,
	ShippingCost,
	Country,
	ChannelGroup3,
	L1,
	L2,
	L3,
	L4,
	SMTARGET,
	[LOAD_TIMESTAMP]
)


SELECT 
	ItemNo,
	PlanPrice = 246.300000, 
	MEK = 75.01,
	--Lengh_CM= 40.5,
	--Width_CM = 34.10,
	--Height_CM = 29.90,
	--WEIGHT_G = GrossWeight,
	--Volume_CCM = Volume,
	ShippingCost = 4.096,
	Country = 'DE',
	ChannelGroup3 = 'ShopWE',
	L1 = ProductHierarchy1,
	L2 = ProductHierarchy2,
	L3 = ProductHierarchy3,
	L4 = ProductHierarchy4,
	SMTARGET = 0.30,
	[LOAD_TIMESTAMP] = getdate()
FROM pl.pl_v_item 
where itemno = '10000164'

UNION

SELECT 
	10000000+ItemNo,
	--PlanPrice = 128.95, ---244.73
	PlanPrice = 246.30,
	MEK = 75.01,
	--Lengh_CM= 40.5,
	--Width_CM = 34.10,
	--Height_CM = 29.90,
	--WEIGHT_G = GrossWeight,
	--Volume_CCM = Volume,
	ShippingCost = 4.096,
	Country = 'DE',
	ChannelGroup3 = 'ShopWE',
	L1 = ProductHierarchy1,
	L2 = ProductHierarchy2,
	L3 = ProductHierarchy3,
	L4 = ProductHierarchy4,
	SMTARGET = 0.30,
	[LOAD_TIMESTAMP] = getdate()
FROM pl.pl_v_item 
where itemno = '10000164'



select * 
from [L0].L0_MI_PRICE_TOOL_SM


WR.WR_TX_L1_FACT_F_PRICE_TOOL_SM  

----rates on 4 decimal places
SELECT * FROM [PL].PL_V_PRICE_TOOL_SM



SELECT * FROM [L1].[L1_FACT_F_PRICE_TOOL_SM]


SELECT * FROM [L0].L0_MI_PRICE_TOOL_SM

Truncate table [L0].L0_MI_PRICE_TOOL_SM