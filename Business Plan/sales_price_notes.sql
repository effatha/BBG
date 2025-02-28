
L0.L0_MI_SALES_PRICE_VOUCHERS
	- Itemno
	- Country
	- ChannelGroup3
	- Voucher_PERC	
	- Voucher_Value
	- StartDate
	- EndDate

L0.L0_MI_CHANNEL_PRICE_LISTS
	- ChannelGroup3,
	- channelgroup2 -
	- Country 
	- ListID
 

 L1.L1_FACT_F_SALES_PRICE
 PL_V_SALES_PRICE

SELECT
	D_PRICE							= 0 --- day calculation
	,ID_ITEM						= 0 --- ID item dim 
	,ID_ITEM_BUSINESS_PLAN			= 0 ---- id item business plan
	,CD_CHANNEL_GROUP_2				= 0
	,CD_CHANNEL_GROUP_3				= 0
	,CD_COUNTRY_GROUP				= 0 --- DE;IT;FR:ES;UK; INT; CEE- SK; 
	,AMT_MEK_HEDGING_EUR			= 0 ---  MEK (MBEW table;BWTAR  100)
	,AMT_BUSINESS_PLAN_PRICE_EUR	= 0 -- plan price
	,AMT_BUSINESS_PLAN_VAT_EUR		= 0 ---- VAT table (INT - FR(22%))
	,ID_PRICE_LIST					= 0 --  ListID
	,AMT_PRICE_LIST_EUR				= 0 --  Value of the price list  converted to eur using the FX rate table (look: WR_TX_SAGE_KHKPreislistenArtikel_L1_FACT_F_PRICING_LIST_COST_EST)
	,AMT_PRICE_LIST_FC				= 0 -- Value of the price list 
	,AMT_PRICE_LIST_VAT_EUR			= 0 --- VAT over EUR value
	,AMT_PRICE_LIST_VAT_FC			= 0 --- VAT over list value FC
	,AMT_NET_DISCOUNTS_EUR			= 0 ;--- CASE WHEN Voucher_PERC then AMT_PRICE_LIST_EUR * Voucher_PERC ELSE Voucher_Value END
	,AMT_L30_NET_ORDER_VALUE_EST	= 0 -- Last 30 days NOV from sales transactions
	,AMT_L30_NET_ORDER_QTY_EST		= 0 -- AMT_L30_NET_ORDER_QTY_EST
	,AMT_REVENUE_EST_EUR			= 0 -- Sales transaction
	,AMT_PC0_EST					= 0
	,AMT_PC1_EST					= 0
	,AMT_PC2_EST					= 0
	,AMT_PC3_EST					= 0
	,AMT_NET_ORDER_CONTRIBUTION_EUR = 0
	,FL_PRICE_BELOW_MEK_THRESHOLD	= 0 ; --- CASE WHEN MEK/ListPrice > 0.5 THEN 'Y' ELSE 'N' END
FROM 
L0.L0_MI_CHANNEL_PRICE_LISTS
LEFT JOIN KHKPREISLISTARTIKEL
LEFT JOIN ITEM
LEFT JOIN ITEMBS
LEFT JOIN SALES_TRANSACTIONS
LEFT JOIN BUSINESS PLAN