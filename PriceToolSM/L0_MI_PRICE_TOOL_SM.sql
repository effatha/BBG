DROP TABLE  [L0].L0_MI_PRICE_TOOL_SM
CREATE TABLE [L0].L0_MI_PRICE_TOOL_SM
(
	ITEMNO VARCHAR (50) NULL,
	PLANPRICE DECIMAL(19,4) NULL,
	MEK DECIMAL(19,4) NULL,
	SHIPPINGCOST  DECIMAL(19,4) NULL,		
	--PLANPRICE VARCHAR (50) NULL,
	--MEK VARCHAR (50) NULL,
	--SHIPPINGCOST  VARCHAR (50) NULL,
	COUNTRY  	VARCHAR (50) NULL,
	CHANNELGROUP3 VARCHAR (50) NULL,	
	L1	VARCHAR (150) NULL,
	L2	VARCHAR (150) NULL,
	L3  VARCHAR (150) NULL,
	L4  VARCHAR (150) NULL,
	--SMTARGET  VARCHAR (150) NULL,
	SMTARGET  DECIMAL(19,4) NULL,

	[LOAD_TIMESTAMP] DATETIME2(7) NULL
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
	--Lengh_CM,
	--Width_CM,
	--Height_CM,
	--WEIGHT_G,
	--Volume_CCM,
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

TRUNCATE TABLE [L0].L0_MI_PRICE_TOOL_SM

