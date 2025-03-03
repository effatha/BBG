

SELECT
	--
	SnapshotDate
	NetOrderQuantity,
	NetOrderValue,
	NetOrderQuantityPlanned,
	NetOrderValuePlanned,
	TotalNumberOfItems,
	ItemsWithNegativePC3Est,
	TotalItemsBucket1,
	TotalItemsStartBucket1
	TotalItemsBucket2,
	TotalItemsStartBucket2
	TotalItemsBucket3,
	TotalItemsStartBucket3
	TotalItemsBucket4,
	TotalItemsStartBucket4,
	NLItemsWithDelayedETD,
	NLPC3Est,
	NLPC3Planned,
	UnrelatedRefundRate,
	TotalNumberSuppliers,
	NumberSupplliersWithUpdatedGPC,
	NOVShareNonPaidChannels,
	NetOrderValueAmazon,
	NetOrderValueB2B,
	NetOrderValueCEE,
	NetOrderValueShopWE,
	NetOrderValueMarketplacesWE,
	NetOrderValueAmazon_LY,
	NetOrderValueB2B_LY,
	NetOrderValueCEE_LY,
	NetOrderValueShopWE_LY,
	NetOrderValueMarketplacesWE_LY,
	TotalFreightCostCarriers,
	TotalFreightHighCostCarriers,
	MonthlyCarrierClaims,
	ContactRateCustomerService,
	ContactRateCustomerService_LY
FROM PL.PL_V_COMPANY_OKR


ALTER VIEW PL.PL_V_COMPANY_OKR
AS
	SELECT
	SnapshotDate = '2025-08-01',
	NetOrderQuantity = 34505,
	NetOrderValue = 3553257,
	NetOrderQuantityPlanned = 42115,
	NetOrderValuePlanned = 4021618,
	TotalNumberOfItems = 5500,
	ItemsWithNegativePC3Est = 1500,
	TotalItemsBucket1 = 1000,
	TotalItemsStartBucket1 = 1000,
	TotalItemsBucket2 = 1000,
	TotalItemsStartBucket2= 1000,
	TotalItemsBucket3 = 1000,
	TotalItemsStartBucket3= 1000,
	TotalItemsBucket4 = 1000,
	TotalItemsStartBucket4 = 1000,
	NLItemsWithDelayedETD = 100,
	NLPC3Est = 350000,
	NLPC3Planned = 300000,
	UnrelatedRefundRate= 0.9,
	TotalNumberSuppliers= 1200,
	NumberSupplliersWithUpdatedGPC = 100,
	NOVShareNonPaidChannels = 0.15,
	NetOrderValueAmazon = 1289885,
	NetOrderValueB2B =15272,
	NetOrderValueCEE = 1059403,
	NetOrderValueShopWE =804670,
	NetOrderValueMarketplacesWE =384027,
	NetOrderValueAmazon_LY = 1289885 +20000,
	NetOrderValueB2B_LY  = 15272+20000,
	NetOrderValueCEE_LY  = 1059403+20000,
	NetOrderValueShopWE_LY  = 804670+20000,
	NetOrderValueMarketplacesWE_LY  = 384027+20000,
	TotalFreightCostCarriers  = 2000000,
	TotalFreightHighCostCarriers  = 900000,
	MonthlyCarrierClaims  = 120,
	ContactRateCustomerService  = 10,
	ContactRateCustomerService_LY  = 15



	UNION
		SELECT
	SnapshotDate = '2025-09-01',
	NetOrderQuantity = 34505 + 1000,
	NetOrderValue = 3553257 + 10000,
	NetOrderQuantityPlanned = 42115 + 1000,
	NetOrderValuePlanned = 4021618 + 10000,
	TotalNumberOfItems = 5500,
	ItemsWithNegativePC3Est = 1505,
	TotalItemsBucket1 = 1000,
	TotalItemsStartBucket1 = 1000,
	TotalItemsBucket2 = 1000,
	TotalItemsStartBucket2= 1000,
	TotalItemsBucket3 = 1000,
	TotalItemsStartBucket3= 1000,
	TotalItemsBucket4 = 1000,
	TotalItemsStartBucket4 = 1000,
	NLItemsWithDelayedETD = 100,
	NLPC3Est = 350000,
	NLPC3Planned = 301000,
	UnrelatedRefundRate= 0.9,
	TotalNumberSuppliers= 1200,
	NumberSupplliersWithUpdatedGPC = 100,
	NOVShareNonPaidChannels = 0.15,
	NetOrderValueAmazon = 1289885,
	NetOrderValueB2B =15272,
	NetOrderValueCEE = 1059403,
	NetOrderValueShopWE =804670,
	NetOrderValueMarketplacesWE =384027,
	NetOrderValueAmazon_LY = 1289885 +30000,
	NetOrderValueB2B_LY  = 15272+30000,
	NetOrderValueCEE_LY  = 1059403+30000,
	NetOrderValueShopWE_LY  = 804670+30000,
	NetOrderValueMarketplacesWE_LY  = 384027+30000,
	TotalFreightCostCarriers  = 2000000,
	TotalFreightHighCostCarriers  = 900000,
	MonthlyCarrierClaims  = 120,
	ContactRateCustomerService  = 10,
	ContactRateCustomerService_LY  = 15

