--/****** Object:  StoredProcedure [WR].[WR_TX_L1_FACT_A_SALES_TRANSACTIONS_L1_FACT_A_SALES_TRANSACTION_KPI]    Script Date: 09/12/2024 14:32:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROC [WR].[WR_TX_L1_FACT_A_SALES_TRANSACTIONS_L1_FACT_A_SALES_TRANSACTION_KPI_STEERING] AS
BEGIN

	TRUNCATE TABLE L1.L1_FACT_A_SALES_TRANSACTION_KPI_STEERING;
	

	WITH CTE_LICENSES AS (
	SELECT 
		item.[ID_ITEM]
		,[D_VALID_FROM]
		,[D_VALID_TO]
		,MAX(CASE CD_LICENSE_SUBCATEGORY WHEN 'GEMA PL'          THEN VL_LICENSE_RATE * ISNULL(PCT_LICENSE,1) END)				AS [GEMA PL] 
		,MAX(CASE CD_LICENSE_SUBCATEGORY WHEN 'AIRTAG'           THEN ISNULL(VL_LICENSE_RATE,1) * ISNULL(PCT_LICENSE,1) END)	AS AIRTAG 
		,ISNULL(MAX(CASE CD_LICENSE_SUBCATEGORY   WHEN 'VIA'              THEN VL_LICENSE_RATE * ISNULL(PCT_LICENSE,1) END),0)
		+ ISNULL(MAX(CASE CD_LICENSE_SUBCATEGORY WHEN 'Vectis'           THEN VL_LICENSE_RATE * ISNULL(PCT_LICENSE,1) END),0)	AS AMT_PRODUCT_LICENSES_EST_PRECAL_USD
		,  ISNULL(MAX(CASE CD_LICENSE_SUBCATEGORY  WHEN 'Kasettenrekorder' THEN VL_LICENSE_RATE * ISNULL(PCT_LICENSE,1) END),0)
		 + ISNULL(MAX(CASE CD_LICENSE_SUBCATEGORY WHEN 'Others'           THEN VL_LICENSE_RATE * ISNULL(PCT_LICENSE,1) END),0)
		 + ISNULL(MAX(CASE CD_LICENSE_SUBCATEGORY WHEN 'Nokia'            THEN VL_LICENSE_RATE * ISNULL(PCT_LICENSE,1) END),0)
		 + ISNULL(MAX(CASE CD_LICENSE_SUBCATEGORY WHEN 'Sisvel'           THEN VL_LICENSE_RATE * ISNULL(PCT_LICENSE,1) END),0)
		 + ISNULL(MAX(CASE CD_LICENSE_SUBCATEGORY WHEN 'CD-Rekorder'      THEN VL_LICENSE_RATE * ISNULL(PCT_LICENSE,1) END),0)
		 + ISNULL(MAX(CASE CD_LICENSE_SUBCATEGORY WHEN 'TV'               THEN VL_LICENSE_RATE * ISNULL(PCT_LICENSE,1) END),0)
		 + ISNULL(MAX(CASE CD_LICENSE_SUBCATEGORY WHEN 'MP3-Player'       THEN VL_LICENSE_RATE * ISNULL(PCT_LICENSE,1) End),0)	AS AMT_PRODUCT_LICENSES_EST_PRECAL_EUR
	FROM [L1].[L1_DIM_A_PL_ENVIRO_LICENSES] el
	LEFT JOIN L1.L1_DIM_A_ITEM item
		ON el.CD_ITEM = item.NUM_ITEM 
   	GROUP BY item.[ID_ITEM],[D_VALID_FROM],[D_VALID_TO]
   )
  ,PACKAGING_FRA as 
  ( 
  SELECT 
		cd_enviro_category
		,cd_cost_type
		,[D_VALID_FROM]
		,[D_VALID_TO]
		,MAX(CASE cd_raw_material_type   WHEN 'Other plastics excluding PVC' THEN AMT_PACKAGING_PRICE_EUR * ISNULL(VL_PACKAGING_PROPORTION_RATE,1) END)
		 + MAX(CASE cd_raw_material_type WHEN 'Other plastics including PVC' THEN AMT_PACKAGING_PRICE_EUR * ISNULL(VL_PACKAGING_PROPORTION_RATE,1) END)
		 + MAX(CASE cd_raw_material_type WHEN 'Paper'                        THEN AMT_PACKAGING_PRICE_EUR * ISNULL(VL_PACKAGING_PROPORTION_RATE,1) END)
		 + MAX(CASE cd_raw_material_type WHEN 'Rigid PE, PP or PET'          THEN AMT_PACKAGING_PRICE_EUR * ISNULL(VL_PACKAGING_PROPORTION_RATE,1) END)
		 + MAX(CASE cd_raw_material_type WHEN 'Rigid PS'                     THEN AMT_PACKAGING_PRICE_EUR * ISNULL(VL_PACKAGING_PROPORTION_RATE,1) END)
		 + MAX(CASE cd_raw_material_type WHEN 'Soft PE'                      THEN AMT_PACKAGING_PRICE_EUR * ISNULL(VL_PACKAGING_PROPORTION_RATE,1) END)	AS AMT_COST_PER_MATERIAL
		,MIN(VL_CSU_FEE) as VL_CSU_FEE
  FROM [L1].[L1_DIM_A_PL_ENVIRO_PACKAGING] el
  WHERE cd_enviro_category='PAC_FRA' and cd_cost_type='POM'	 	
  GROUP BY cd_enviro_category,cd_cost_type,[D_VALID_FROM],[D_VALID_TO]
)
, cte_rates as (
SELECT c.NUM_ITEM ItemNo,CD_ITEM_CLASS, 
		SUM([VL_ORDER_QUANTITY]+VL_REPLACEMENT_QUANTITY)[VL_ORDER_QUANTITY],
		SUM([VL_RETURN_QUANTITY])[VL_RETURN_QUANTITY],
		SUM(AMT_GROSS_ORDER_VALUE_EUR)AMT_GROSS_ORDER_VALUE_EUR,
		SUM(AMT_REFUNDS_EUR)AMT_REFUNDS_EUR,
		SUM(VL_REPLACEMENT_QUANTITY)VL_REPLACEMENT_QUANTITY
  FROM [L1].[L1_FACT_A_CLAIM_RATES] c
  inner join l1.l1_dim_a_item it on it.num_item =c.num_item
  WHERE 
	D_SALES_PROCESS BETWEEN '2024-01-01' and '2024-08-31'
	and c.num_item like '1%' and CD_ITEM_CLASS <> 'Kitting-Item'
GROUP BY c.NUM_ITEM,CD_ITEM_CLASS
),cte_rates_summary as (
SELECT *,
		ROUND(([VL_RETURN_QUANTITY]/[VL_ORDER_QUANTITY]),2) [ReturnRate],
		ROUND((AMT_REFUNDS_EUR/AMT_GROSS_ORDER_VALUE_EUR),2) RefundRate,
		ROUND((VL_REPLACEMENT_QUANTITY/[VL_ORDER_QUANTITY]),2) ReplacementRate
FROM cte_rates
WHERE
	AMT_GROSS_ORDER_VALUE_EUR > 0 
	)
,CTE_SALES_L1 AS
	(
			SELECT 
			fact.ID_SALES_TRANSACTION											as ID_SALES_TRANSACTION
			,fact.CD_SALES_TRANSACTION											AS SalesTransactionCode
			,fact.CD_SOURCE_SYSTEM												AS Source
			,CD_SALES_PROCESS_ID												AS ProcessId
			,fact.CD_SALES_PROCESS_LINE											AS ProcessIDPosition
			,CD_DOCUMENT_NO														AS DocumentNo
			,CD_DOCUMENT_LINE													AS DocumentItemPosition
			,CD_DOCUMENT_ID_REFERENCE											AS ReferenceDocumentId
			,fact.ID_COMPANY													AS CompanyId
			,fact.D_CREATED														AS TransactionDate
			,fact.D_SALES_PROCESS												AS ProcessIDDate
			,fact.D_DOCUMENT_CREATED											AS D_DOCUMENT_CREATED
			,fact.T_CANCELLATION_REASON											AS ReasonForRejections
			,fact.FL_INCIDENT													AS IncidentFlag
			,DT_CREATED															AS OrderCreationDateTime
			,CD_TYPE															AS TransactionTypeShort
			,fact.[ID_SALES_TRANSACTION_TYPE]									AS TransactionTypeID
			,fact.ID_ITEM														AS ItemID
			,fact.ID_ITEM_PARENT												AS ItemParentID
			,fact.CD_ITEM_TYPE													AS ItemType
			,fact.ID_SALES_CHANNEL												AS ChannelId
			,fact.CD_FULFILLMENT												AS Fulfillment
			,CD_CUSTOMER														AS CustomerId
			,CD_CUSTOMER_SERVICE_AGENT                                          AS CustomerServiceAgent
			,T_CREATION_USERNAME                                                AS CreatedBy
			,CD_MARKET_ORDER_ID													AS MarketplaceOrderId
			,CD_PAYMENT_METHOD													AS PaymentMethod
			,fact.CD_STORAGE_LOCATION											AS StorageLocationCode
			,ISNULL(fact.T_REVISED_LOCATION,fact.T_STORAGE_LOCATION)			AS StorageLocation
			,fact.CD_COUNTRY_INVOICE											AS InvoiceCountry
			,CD_ZIP_INVOICE														AS InvoiceZipCode
			,T_CITY_INVOICE														AS InvoiceCity
			,fact.CD_COUNTRY_DELIVERY											AS DeliveryCountry
			,CD_ZIP_DELIVERY													AS DeliveryZipCode
			,T_CITY_DELIVERY													AS DeliveryCity
			,CD_COUNTRY_ORDER													AS SalesCountry
			,CD_ZIP_ORDER														AS SalesZipCode
			,T_CITY_ORDER														AS SalesCity
			,VL_ITEM_QUANTITY													AS Quantity
			,VL_ITEM_PARENT_QUANTITY                                            AS ParentQuantity
			,AMT_NET_SHIPPING_REVENUE_EUR										AS NetShippingRevenue
			,AMT_NET_PRICE_EUR													AS NetPrice
			,AMT_NET_PRICE_FC													AS NetPriceForeignCurrency
			,AMT_SHIPPING_COST_EST_EUR											AS ShippingCostEst
			,CD_SHIPMENT_COSTS_SOURCE                                           AS ShipmentCostsSource
			,AMT_GROSS_SHIPPING_REVENUE_EUR										AS GrossShippingRevenue
			,AMT_GROSS_SHIPPING_REVENUE_FC										AS GrossShippingRevenueForeignCurrency
			,AMT_GROSS_PRICE_EUR												AS GrossPrice
			,AMT_GROSS_PRICE_FC													AS GrossPriceForeignCurrency
			,AMT_TAX_PRICE_EUR													AS TaxPrice
			,AMT_TAX_DISCOUNTS_EUR												AS TaxDiscounts
			,AMT_TAX_FREIGHT_EUR												AS TaxFreight
			,AMT_TAX_TOTAL_EUR													AS TaxTotal
			,AMT_TAX_TOTAL_PAYABLE_EUR                                          AS TaxTotalPayable
            ,AMT_TAX_OUTPUT_EUR                                                 AS TaxOutput
			,AMT_MEK_HEDGING_EUR												AS MEKHedging
			,AMT_GTS_MARKUP														AS GTSMarkup
			,fact.AMT_NET_DISCOUNT_EUR											AS Discount
			,fact.AMT_NET_DISCOUNT_FC                                           AS DiscountForeignCurrency
			,fact.CD_CURRENCY													AS Currency
			,item.NUM_ITEM
			,fact.CD_BILLING_CATEGORY	
			,fact.D_BILLING_DATE					
			,fact.CD_BILLING_POSTING_STATUS		
			,fact.CD_PAYER						
			,fact.VL_BILLING_QUANTITY			
			,fact.VL_EXCHANGE_RATE				
			,fact.CD_SALES_DOCUMENT_NO           
			,fact.D_UPDATED						
			,fact.CD_REJECTION_STATUS			
			,fact.D_CANCELLATION	
			,fact.[CD_RETURN_REASON]         
            ,fact.[T_RETURN_REASON] 
			
			--kpi parameters
			,kpi.VL_GROSS_ORDER_VALUE_PARAM										 AS VL_GROSS_ORDER_VALUE_PARAM
			,kpi.VL_CANCELLED_ORDERS_QUANTITY_EST_PARAM							 AS VL_CANCELLED_ORDERS_QUANTITY_EST_PARAM
			,kpi.VL_CANCELLED_ORDER_VALUE_EST_PARAM								 AS VL_CANCELLED_ORDER_VALUE_EST_PARAM
			,kpi.VL_NET_ORDER_QUANTITY_EST_PARAM								 AS VL_NET_ORDER_QUANTITY_EST_PARAM
			,kpi.VL_REFUNDED_ORDER_VALUE_EST_PARAM								 AS VL_REFUNDED_ORDER_VALUE_EST_PARAM
			,kpi.VL_RETURN_ORDER_VALUE_EST_PARAM								 AS VL_RETURN_ORDER_VALUE_EST_PARAM
			,kpi.VL_NET_ORDER_VALUE_EST_PARAM									 AS VL_NET_ORDER_VALUE_EST_PARAM
			,kpi.VL_RETURNED_QUANTITY_EST_PARAM									 AS VL_RETURNED_QUANTITY_EST_PARAM
			,kpi.VL_REFUNDED_QUANTITY_EST_PARAM									 AS VL_REFUNDED_QUANTITY_EST_PARAM
			,kpi.VL_NET_QUANTITY_EST_PARAM										 AS VL_NET_QUANTITY_EST_PARAM
			,kpi.VL_REVENUE_EST_PARAM											 AS VL_REVENUE_EST_PARAM
			,kpi.VL_PC0_PARAM													 AS VL_PC0_PARAM
			,kpi.VL_PC1_PARAM													 AS VL_PC1_PARAM
			,kpi.VL_PC2_PARAM													 AS VL_PC2_PARAM
			,kpi.VL_PC3_PARAM													 AS VL_PC3_PARAM
			,kpi.VL_CANCELLED_ORDER_VALUE_PARAM						
			,kpi.VL_CANCELLED_ORDER_QUANTITY_PARAM					
			,kpi.VL_NET_ORDER_VALUE_FULL_PRICE_PARAM				
			,kpi.VL_NETORDER_QUANTITY_PARAM                         
			,kpi.VL_NET_ORDER_VALUE_PARAM
			,kpi.VL_NET_PRODUCT_COSTS_THEREOF_RETURN_MEK_PARAM
			--KPI's
			,(ISNULL(VL_ITEM_QUANTITY,0) *1000) * VL_COMMERCIAL_TURNOVER_PARAM		AS CommercialTurnover
			,(ISNULL(AMT_GROSS_PRICE_EUR,0)) * VL_TURNOVER_PARAM					AS Turnover
			,(ISNULL(VL_ITEM_QUANTITY,0)   )* VL_ORDER_QUANTITY_PARAM				AS OrderQuantity
			,(ABS(ISNULL(AMT_TAX_PRICE_EUR,0))   )* VL_VALUE_ADDED_TAX_PARAM		AS ValueAddedTax
			,(ABS(ISNULL(AMT_NET_DISCOUNT_EUR,0))   )* VL_ORDER_DISCOUNTS_PARAM		AS OrderDiscounts
			,(ISNULL(AMT_NET_SHIPPING_REVENUE_EUR,0)   )* VL_ORDER_CHARGES_PARAM	AS OrderCharges
			,ISNULL(rates.RefundRate,ISNULL(ref.VL_RATE,0.1))						AS RefundRate
			,ISNULL(cll.VL_RATE,0.1)												AS CancellRate
			,ISNULL(rates.ReturnRate,ISNULL(ret.VL_RATE,0.1))						AS ReturnRate
			-- PC1 kpis
			,ISNULL(costs.AMT_DEMURRAGE_DETENTION_EUR  / dvol.VL_TOTAL_VOLUME * (fact.VL_ITEM_QUANTITY * item.VL_VOLUME),0) * kpi.VL_DEMURRAGE_DETENTION_PARAM							AS DemurrageDetention
			,ISNULL(costs.AMT_DEADFREIGHT_EUR / dvol.VL_TOTAL_VOLUME * (fact.VL_ITEM_QUANTITY * item.VL_VOLUME),0) * kpi.VL_DEAD_FREIGHT_PARAM											AS Deadfreight
			,ISNULL(costs.AMT_KICKBACKS_EUR / dvol.VL_TOTAL_VOLUME * (fact.VL_ITEM_QUANTITY * item.VL_VOLUME),0) * kpi.VL_KICK_BACKS_PARAM												AS Kickbacks
			,ISNULL(costs.AMT_3RD_PARTY_SERVICES_EUR / dvol.VL_TOTAL_VOLUME * (fact.VL_ITEM_QUANTITY * item.VL_VOLUME),0)  * kpi.VL_3RDPARTY_SERVICES_PARAM								AS [3rdPartyServices]
			,ISNULL(costs.AMT_RETURN_MERCHANDISE_AUTHORIZATION_EUR / dvol.VL_TOTAL_VOLUME * (fact.VL_ITEM_QUANTITY * item.VL_VOLUME),0)  * kpi.VL_RMA_PARAM								AS RMA
			,ISNULL(costs.AMT_SAMPLES_EUR / dvol.VL_TOTAL_VOLUME * (fact.VL_ITEM_QUANTITY * item.VL_VOLUME),0)  * kpi.VL_SAMPLES_PARAM													AS Samples
			,ISNULL(costs.AMT_OTHER_COGS_EFFECT_EST_EUR / dvol.VL_TOTAL_VOLUME * (fact.VL_ITEM_QUANTITY * item.VL_VOLUME),0)  * kpi.VL_OTHER_COGS_EFFECTS_EST_PARAM						AS OtherCOGSEffectsEst
			,ISNULL(costs.AMT_DROPSHIPMENT_CEOTRA9ER_EST_EUR / dvol.VL_TOTAL_VOLUME * (fact.VL_ITEM_QUANTITY * item.VL_VOLUME),0)  * kpi.VL_DROP_SHIPMENT_CEOTRA9ER_ARTIKEL_EST_PARAM	AS DropShipmentCEOTRA9erArtikelEst
			,ISNULL(costs.AMT_INBOUND_FREIGHT_COST_EST_EUR / dvol.VL_TOTAL_VOLUME * (fact.VL_ITEM_QUANTITY * item.VL_VOLUME),0)  * kpi.VL_INBOUND_FREIGHT_COSTS_EST_PARAM				AS InboundFreightCostsEst
			,ISNULL(costs.AMT_PO_CANCELLATION_EUR / dvol.VL_TOTAL_VOLUME * (fact.VL_ITEM_QUANTITY * item.VL_VOLUME),0)  * kpi.VL_PO_CANCELLATION_PARAM									AS POCancellation
			,ISNULL(costs.AMT_STOCK_ADJUSTMENT_EUR / dvol.VL_TOTAL_VOLUME * (fact.VL_ITEM_QUANTITY * item.VL_VOLUME),0)  * kpi.VL_DEMURRAGE_DETENTION_PARAM								AS StockAdjustment
			,ISNULL(costs.AMT_FX_HEDGING_IMPACT_EST_EUR / dvol.VL_TOTAL_VOLUME * (fact.VL_ITEM_QUANTITY * item.VL_VOLUME),0)  * kpi.VL_FX_HEDGING_IMPACT_EST_PARAM						AS FXHedgingImpactEst
			,ISNULL(costs.AMT_COGS_STOCK_VALUE_ADJUSTMENT_EST_EUR / dvol.VL_TOTAL_VOLUME * (fact.VL_ITEM_QUANTITY * item.VL_VOLUME),0)  * kpi.VL_STOCK_ADJUSTMENT_PARAM					AS COGSStockValueAdjustmentEst
			,GREATEST(
				LEAST(item.VL_VOLUME * isnull(packcost.AMT_PACKAGING_COST_M3_EUR, 0) / (CASE WHEN item.cd_unit_volume='CCM' THEN 1000000 WHEN item.cd_unit_volume='M3' THEN 1 END), (2 * packcost_max.AMT_PACKAGING_COST_M3_EUR))
				,(0.02 * packcost_min.AMT_PACKAGING_COST_M3_EUR)
				)																																										AS Packaging_PreCalc
			,GREATEST(
	            LEAST((item.VL_VOLUME * ISNULL(inbound.AMT_HANDLING_INBOUND_COST_EUR,0)) /(CASE WHEN item.cd_unit_volume='CCM' THEN 1000000 WHEN item.cd_unit_volume='M3' THEN 1 END) ,inbound_max.val_max)
	            ,inbound_min.val_min)						  AS HandlingInboundEst_PreCalc
			 , GREATEST(
	            LEAST((item.VL_VOLUME * ISNULL(transship.AMT_HANDLING_TRANS_SHIPMENTS_M3_EUR,0)) /(CASE WHEN item.cd_unit_volume='CCM' THEN 1000000 WHEN item.cd_unit_volume='M3' THEN 1 END) ,transship_max.val_max)
	            ,transship_min.val_min)						  AS HandlingTransShippmentEst_PreCalc
			,GREATEST(
				LEAST(item.VL_VOLUME * isnull(ship.AMT_HANDLING_SHIPMENTS_COST_M3_EUR, 0) / (CASE WHEN item.cd_unit_volume='CCM' THEN 1000000 WHEN item.cd_unit_volume='M3' THEN 1 END), (2 * ship_max.AMT_HANDLING_SHIPMENTS_COST_M3_EUR))
				,(0.02 * ship_min.AMT_HANDLING_SHIPMENTS_COST_M3_EUR)
				)													AS HandlingOrdersEst_PreCalc
			,ISNULL(csmanage.AMT_CS_MANAGEMENT_ITEM_EUR,0)			AS CSManagement_PreCalc
			,ISNULL(claims.AMT_CS_HANDLING_CLAIMS_ITEM_EUR,0)		AS [CS_HANDLING_CLAIMS]
			,0														AS ShopMarketing
			,NULL													AS AmazonMarketingCosts
			,item.VL_VOLUME * isnull(truckingtransship.AMT_TRUCKING_TRANS_SHIPMENTS_M3_EUR, 0) / (CASE WHEN item.cd_unit_volume='CCM' THEN 1000000 WHEN item.cd_unit_volume='M3' THEN 1 END)  AS TruckingTransShipmentEst_PreCalc
			,ISNULL(marketplaces.[PCT_MARKETING],0)					AS [PCT_MARKETING]
			,ISNULL(CM.PCT_COMMISSIONS_ORDER,0)						AS [PCT_COMMISSIONS_MARKETPLACES]
			,ISNULL(CM.PCT_COMMISSIONS_RETURN,0)					AS [PCT_COMMISSIONS_MARKETPLACES_RETURN]
			,ISNULL(PAY.PCT_PAYMENTS_ORDER, 0)						AS [PCT_PAYMENTS_ORDER]
			,ISNULL(returns.[AMT_HANDLING_RETURNS_COST_EUR],0)		AS AMT_HANDLING_RETURNS_COST_EUR
			,LEAST(item.VL_VOLUME * isnull(rent.[AMT_RENTAL_COST_M3_EUR], 0) / (CASE WHEN item.cd_unit_volume='CCM' THEN 1000000 WHEN item.cd_unit_volume='M3' THEN 1 END)
			, (2 * rent_max.[AMT_RENTAL_COST_M3_EUR])) 
																	AS WarehousingRentEst_PreCalc
			,LEAST(item.VL_VOLUME * isnull(opex.[AMT_OPEX_COST_M3_EUR], 0) / (CASE WHEN item.cd_unit_volume='CCM' THEN 1000000 WHEN item.cd_unit_volume='M3' THEN 1 END)
			, (2 * opex_max.[AMT_OPEX_COST_M3_EUR]))  
																	AS WarehousingOpexEst_PreCalc
			,ISNULL(rates.ReplacementRate,ISNULL(replacement.VL_RATE,0.1))							AS ReplacementProductCostEst_PreCal
			,ISNULL(rates.ReplacementRate,ISNULL(replacement.VL_QUANTITY_RATE,0.1))					AS ReplacementOrderQuantityEst_PreCal
	        ,dimchannel.[CD_CHANNEL_GROUP_1]						AS CD_CHANNEL_GROUP_1
	        ,c_amaz.[VL_COMMISSIONS_ORDER_RATE]						AS VL_COMMISSIONS_ORDER_RATE
			,ref.VL_RATE											AS VL_REFUND_RATE
			, CASE 
				WHEN dimchannel.CD_CHANNEL_GROUP_1='Amazon' AND fact.CD_FULFILLMENT='FBA' THEN
					((item.VL_VOLUME * ISNULL(WHFBA.AMT_FBA_WAREHOUSE_COST_M3,0)) 
						/(CASE WHEN item.cd_unit_volume='CCM' THEN 1000000 WHEN item.cd_unit_volume='M3' THEN 1 END)) 
						* WHFBA.VL_FBA_STOCK_TURNOVER_M * (1 + WHFBA.VL_RATE) * (1 + WHFBA.VL_LONG_TERM_SURCHARGE_RATE)
				ELSE NULL END										AS WarehousingFBA
			,cfm.VL_MARKETING_FIXED_COST_RATE						AS VL_MARKETING_FIXED_COST_RATE
			,GREATEST(fact.[D_EFF_FROM],kpi.[D_EFF_FROM],item.[D_EFF_FROM], replacement.[D_EFF_FROM], ref.[D_EFF_FROM], ret.[D_EFF_FROM], cll.[D_EFF_FROM],
			          costs.D_EFFECTIVE, dvol.D_EFFECTIVE, inbound.[D_EFF_FROM], transship.[D_EFF_FROM], packcost.[D_EFF_FROM], packcost_min.[D_EFF_FROM],
					  packcost_max.[D_EFF_FROM], ship.[D_EFF_FROM], ship_min.[D_EFF_FROM], ship_max.[D_EFF_FROM], claims.[D_EFF_FROM],csmanage.[D_EFF_FROM],
					  dimchannel.[D_EFF_FROM], truckingtransship.[D_EFF_FROM], marketplaces.[D_EFF_FROM],CM.[D_EFF_FROM], PAY.[D_EFF_FROM],
					  returns.[D_EFF_FROM],rent.[D_EFF_FROM],rent_max.[D_EFF_FROM],opex.[D_EFF_FROM], opex_max.[D_EFF_FROM],
					  c_amaz.[D_EFF_FROM]
					  )												AS LOAD_TIMESTAMP
			,fact.[D_EFF_TO]                                        AS [D_EFF_TO] 
	        ,fact.[D_EFF_DELETED]                                   AS [D_EFF_DELETED]
			,fact.[FL_DELETED]										AS FL_DELETED
			, CASE 
				WHEN dimchannel.T_SALES_CHANNEL='Intercompany' OR dimchannel.T_SALES_CHANNEL='Mandanten' THEN 1
				ELSE 0
				END													AS FL_Intercompany
			,(CASE when item.CD_UNIT_WEIGHT='G' then item.VL_GROSS_WEIGHT else item.VL_GROSS_WEIGHT/1000 end )
			 *kpi.VL_ENVIRO_EST_PARAM
			 *CASE WHEN dimchannel.CD_CHANNEL_GROUP_1<>'Mandanten' AND item.NUM_ITEM like '[1345]%' AND dimcomp.CD_COMPANY in ('1000','1') THEN 1 ELSE NULL END
			 *eps.AMT_PACKAGING_COST_TOTAL/1000000 as AMT_PACKAGING_COST_ES_EST_PRECALC
		    ,(CASE when item.CD_UNIT_WEIGHT='G' then item.VL_GROSS_WEIGHT else item.VL_GROSS_WEIGHT/1000 end )
			 *kpi.VL_ENVIRO_EST_PARAM
			 *CASE WHEN dimchannel.CD_CHANNEL_GROUP_1<>'Mandanten' AND item.NUM_ITEM like '[1345]%' AND dimcomp.CD_COMPANY in ('1000','1') THEN 1 ELSE NULL END
			 *epd.AMT_PACKAGING_COST_TOTAL/1000000 as AMT_PACKAGING_COST_DE_EST_PRECALC
		    ,(CASE WHEN item.CD_UNIT_WEIGHT='G' THEN item.VL_GROSS_WEIGHT ELSE item.VL_GROSS_WEIGHT/1000 END)*kpi.VL_ENVIRO_EST_PARAM*france.AMT_COST_PER_MATERIAL/1000000 as AMT_PACKAGING_COST_FRA_EST_PRECALC
			,(CASE WHEN dimchannel.CD_CHANNEL_GROUP_1<>'Mandanten' AND item.NUM_ITEM like '[13457]%' AND dimcomp.CD_COMPANY in ('1000','1') and fact.cd_Country_delivery='FR' THEN 1 ELSE NULL END) *(item.VL_GROSS_WEIGHT/1000)*0.7*(kpi.VL_ENVIRO_EST_PARAM)*(rest_abj.AMT_FEE_PER_WEIGHT)	AS AMT_ABJ_EST_EUR_PRECALC
			,(CASE WHEN dimchannel.CD_CHANNEL_GROUP_1<>'Mandanten' AND item.NUM_ITEM like '[13457]%' AND dimcomp.CD_COMPANY in ('1000','1') and fact.cd_Country_delivery='FR' THEN 1 ELSE NULL END) *kpi.VL_ENVIRO_EST_PARAM*rest_textile.AMT_FEE_PER_UNIT										AS AMT_TEXTILE_EST_EUR_PRECALC
			,(CASE WHEN dimchannel.CD_CHANNEL_GROUP_1<>'Mandanten' AND item.NUM_ITEM like '[13457]%' AND dimcomp.CD_COMPANY in ('1000','1') and fact.cd_Country_delivery='FR' THEN 1 ELSE NULL END) * furniture.AMT_TARIF_HT * kpi.VL_ENVIRO_EST_PARAM						AS AMT_TARIF_HT_FURNITURE_PRECALC
			,(CASE WHEN dimchannel.CD_CHANNEL_GROUP_1<>'Mandanten' AND item.NUM_ITEM like '[1345]%' AND dimcomp.CD_COMPANY in ('1000','1') THEN 1 ELSE NULL END) * batteries.AMT_FEE_PER_UNIT_COUNT *kpi.VL_ENVIRO_EST_PARAM AS AMT_FEE_PER_UNIT_BATTERIES_PRECALC
			,(CASE WHEN dimchannel.CD_CHANNEL_GROUP_1<>'Mandanten' AND item.NUM_ITEM like '[1345]%' AND dimcomp.CD_COMPANY in ('1000','1') THEN 1 ELSE NULL END) * batteries. AMT_FEE_PER_WEIGHT_COUNT *kpi.VL_ENVIRO_EST_PARAM AS AMT_FEE_PER_WEIGHT_BATTERIES_PRECALC
			,(CASE WHEN dimchannel.CD_CHANNEL_GROUP_1<>'Mandanten' AND item.NUM_ITEM like '[13457]%' AND dimcomp.CD_COMPANY in ('1000','1') and fact.cd_Country_delivery='FR' THEN 1 ELSE NULL END) *rest_asl.AMT_FEE_PER_UNIT * kpi.VL_ENVIRO_EST_PARAM										AS AMT_ASL_EST_EUR_PRECALC
            ,el.[GEMA PL]
            ,el.AIRTAG
            ,el.AMT_PRODUCT_LICENSES_EST_PRECAL_USD * us.VL_FX_RATE + el.AMT_PRODUCT_LICENSES_EST_PRECAL_EUR as AMT_PRODUCT_LICENSES_EST_PRECAL
			,CASE WHEN dimchannel.CD_CHANNEL_GROUP_1<>'Mandanten' AND item.NUM_ITEM like '[1345]%' AND dimcomp.CD_COMPANY in ('1000','1') THEN 1 ELSE NULL END
			*(CASE WHEN fact.cd_Country_delivery<>'DE' and item.T_PRODUCT_HIERARCHY_3 in ('Cross Trainer', 'Rowing Machine', 'Sixpack Training', 'Cardio Bikes') THEN 1 ELSE item.VL_GROSS_WEIGHT*0.7/1000 END)*rest_wee.AMT_FEE_PER_WEIGHT * rate_wee.VL_FX_RATE * VL_ENVIRO_EST_PARAM AS AMT_WEE_PRECALC
            ,kpi.VL_ENVIRO_EST_PARAM 
			,france.VL_CSU_FEE
			,cmi.INVOICECOUNTRYGROUP								AS CD_COUNTRY_GROUP_INVOICE
			,cmd.DELIVERYCOUNTRYGROUP								AS CD_COUNTRY_GROUP_DELIVERY
			,item.VL_GROSS_WEIGHT
			,rest_wee.VL_MIN_INTERVAL								AS VL_MIN_INTERVAL_WEE
			,rest_wee.VL_MAX_INTERVAL								AS VL_MAX_INTERVAL_WEE
			,er1.AMT_FEE_PER_UNIT									AS AMT_FEE_PER_UNIT_2
		    ,rest_wee.AMT_FEE_PER_UNIT								AS AMT_FEE_PER_UNIT_WEE
			,fr.VL_FX_RATE
			,us.VL_FX_RATE											AS USD_RATE
			,frsek.VL_FX_RATE										AS SEK_RATE
			,rate_wee.VL_FX_RATE                                    AS WEE_FX_RATE
			,sch.AMT_TAX_CAP_SEK
			,sch.AMT_TAX_KG_SEK
			,wee.VL_WEIGHT
			,fact.[CD_GTS_PO_NO]
			,fact.[CD_GTS_PO_LINE]
			,factor.[AMT_CORRECTION_FACTOR_ORDER]
            ,factor.[AMT_CORRECTION_FACTOR_RETURN]
            ,factor.[AMT_CORRECTION_FACTOR_REPLACEMENT]
			,[FL_SINGLE_ITEM]   
			,[CD_CANCELLED_DOCUMENT_NO]  
	        ,[CD_CANCELLED_DOCUMENT_LINE] 
			,AMT_DEPRECIATIONEST_PRECALC_EUR = depr.VL_RATE

		FROM [L1].[L1_FACT_A_SALES_TRANSACTION] fact 
		INNER JOIN L1.L1_DIM_A_SALES_TRANSACTION_TYPE ttype
			on ttype.ID_SALES_TRANSACTION_TYPE = fact.ID_SALES_TRANSACTION_TYPE
				and ttype.[CD_SALES_TRANSACTION_CATEGORY] in ('Order','OrderInvoice')
		LEFT JOIN [L1].[L1_DIM_A_SALES_TRAN_KPI_MATRIX] kpi
			ON kpi.ID_SALES_TRANSACTION_TYPE = fact.ID_SALES_TRANSACTION_TYPE
		LEFT JOIN [L1].[L1_DIM_A_ITEM] item 
			ON item.[ID_ITEM]=fact.ID_ITEM
		LEFT JOIN cte_rates_summary rates on rates.itemno = item.NUM_ITEM

		LEFT JOIN [L1].[L1_DIM_A_COMPANY] dimcomp
			 on dimcomp.ID_COMPANY=fact.ID_COMPANY
		LEFT JOIN [L0].[L0_MI_COUNTRY_MAPPING] cmi
			ON fact.CD_COUNTRY_INVOICE = cmi.COUNTRY
		LEFT JOIN [L1].[L1_DIM_A_SALES_REPLACEMENT_VALUES] replacement
			ON fact.T_PRODUCT_HIERARCHY_2 = replacement.T_PRODUCT_HIERARCHY_2
			AND cmi.INVOICECOUNTRYGROUP = replacement.[CD_COUNTRY_INVOICE_GROUP]
			AND fact.D_CREATED BETWEEN replacement.D_VALID_FROM AND replacement.D_VALID_TO
		LEFT JOIN L1.L1_DIM_A_SALES_REFUND_VALUES ref  
			on fact.D_CREATED BETWEEN ref.D_VALID_FROM AND ref.D_VALID_TO
			and cmi.INVOICECOUNTRYGROUP=ref.CD_COUNTRY_INVOICE_GROUP
			and fact.T_PRODUCT_HIERARCHY_2 =ref.[T_PRODUCT_HIERARCHY_2]
		LEFT JOIN L1.L1_DIM_A_SALES_RETURN_VALUES ret  
			on fact.D_CREATED BETWEEN ret.D_VALID_FROM AND ret.D_VALID_TO
			and cmi.INVOICECOUNTRYGROUP=ret.CD_COUNTRY_INVOICE_GROUP
			and fact.T_PRODUCT_HIERARCHY_2 =ret.T_PRODUCT_HIERARCHY_2
		LEFT JOIN L1.L1_DIM_A_ORDER_CANCELLATION_VALUES cll  
			on fact.D_CREATED BETWEEN cll.D_VALID_FROM AND cll.D_VALID_TO
			and cmi.INVOICECOUNTRYGROUP=cll.CD_COUNTRY_INVOICE_GROUP
			and fact.T_PRODUCT_HIERARCHY_2 =cll.[T_PRODUCT_HIERARCHY_2]
		LEFT JOIN L1.[L1_DIM_A_DEPRECIATION_VALUES] depr  
				on fact.D_CREATED BETWEEN depr.D_VALID_FROM AND depr.D_VALID_TO
				AND fact.T_REVISED_LOCATION = depr.T_STORAGE_LOCATION
				and item.T_PRODUCT_HIERARCHY_2 =depr.T_PRODUCT_HIERARCHY_2
		LEFT JOIN L1.L1_FACT_F_DAILY_COSTS costs
			on costs.D_EFFECTIVE = fact.D_CREATED
		LEFT JOIN L1.L1_FACT_F_DAILY_VOLUME dvol
			on dvol.D_EFFECTIVE = fact.D_CREATED
		LEFT JOIN L1.L1_DIM_A_HANDLING_INBOUND inbound
			ON fact.CD_SIZE_BRACKET = inbound.CD_SIZE_BRACKET
			AND 	ISNULL(fact.T_REVISED_LOCATION,fact.T_STORAGE_LOCATION) = inbound.T_STORAGE_LOCATION
			AND fact.D_CREATED BETWEEN inbound.D_VALID_FROM AND inbound.D_VALID_TO
		LEFT JOIN [L1].[L1_DIM_A_HANDLING_TRANSSHIP] transship
			ON fact.CD_SIZE_BRACKET = transship.CD_SIZE_BRACKET
			AND fact.CD_FULFILLMENT = transship.CD_FULFILLMENT
			AND 	ISNULL(fact.T_REVISED_LOCATION,fact.T_STORAGE_LOCATION) = transship.T_STORAGE_LOCATION
			AND fact.D_CREATED BETWEEN transship.D_VALID_FROM AND transship.D_VALID_TO
		LEFT JOIN L1.L1_DIM_A_PACKAGING_COST packcost
			ON fact.CD_SIZE_BRACKET = packcost.CD_SIZE_BRACKET
			AND fact.CD_FULFILLMENT = packcost.CD_FULFILLMENT
			AND 	ISNULL(fact.T_REVISED_LOCATION,fact.T_STORAGE_LOCATION) = packcost.T_STORAGE_LOCATION
			AND fact.D_CREATED BETWEEN packcost.D_VALID_FROM AND packcost.D_VALID_TO
		LEFT JOIN L1.L1_DIM_A_PACKAGING_COST packcost_min
			ON 'Standard-Size_Small' = packcost_min.CD_SIZE_BRACKET
			AND fact.CD_FULFILLMENT = packcost_min.CD_FULFILLMENT
			AND 	ISNULL(fact.T_REVISED_LOCATION,fact.T_STORAGE_LOCATION) = packcost_min.T_STORAGE_LOCATION
			AND fact.D_CREATED BETWEEN packcost_min.D_VALID_FROM AND packcost_min.D_VALID_TO
		LEFT JOIN L1.L1_DIM_A_PACKAGING_COST packcost_max
			ON 'Over-Size_Large' = packcost_max.CD_SIZE_BRACKET
			AND fact.CD_FULFILLMENT = packcost_max.CD_FULFILLMENT
			AND 	ISNULL(fact.T_REVISED_LOCATION,fact.T_STORAGE_LOCATION) = packcost_max.T_STORAGE_LOCATION
			AND fact.D_CREATED BETWEEN packcost_max.D_VALID_FROM AND packcost_max.D_VALID_TO
	    LEFT JOIN L1.L1_DIM_A_HANDLING_SHIPMENTS ship
			ON fact.CD_SIZE_BRACKET = ship.CD_SIZE_BRACKET
			AND fact.CD_FULFILLMENT = ship.CD_FULFILLMENT
			AND 	ISNULL(fact.T_REVISED_LOCATION,fact.T_STORAGE_LOCATION) = ship.T_STORAGE_LOCATION
			AND fact.D_CREATED BETWEEN ship.D_VALID_FROM AND ship.D_VALID_TO
		LEFT JOIN L1.L1_DIM_A_HANDLING_SHIPMENTS ship_min
			ON 'Standard-Size_Small' = ship_min.CD_SIZE_BRACKET
			AND fact.CD_FULFILLMENT = ship_min.CD_FULFILLMENT
			AND 	ISNULL(fact.T_REVISED_LOCATION,fact.T_STORAGE_LOCATION) = ship_min.T_STORAGE_LOCATION
			AND fact.D_CREATED BETWEEN ship_min.D_VALID_FROM AND ship_min.D_VALID_TO
		LEFT JOIN L1.L1_DIM_A_HANDLING_SHIPMENTS ship_max
			ON 'Over-Size_Large' = ship_max.CD_SIZE_BRACKET
			AND fact.CD_FULFILLMENT = ship_max.CD_FULFILLMENT
			AND 	ISNULL(fact.T_REVISED_LOCATION,fact.T_STORAGE_LOCATION) = ship_max.T_STORAGE_LOCATION
			AND fact.D_CREATED BETWEEN ship_max.D_VALID_FROM AND ship_max.D_VALID_TO
		LEFT JOIN [L1].[L1_DIM_A_CS_HANDLING_CLAIMS] claims
			ON fact.cd_fulfillment = claims.cd_fulfillment
			AND fact.CD_COUNTRY_DELIVERY= claims.cd_country
			AND fact.D_CREATED BETWEEN claims.D_VALID_FROM AND claims.D_VALID_TO
		LEFT JOIN (SELECT 0.02 * AMT_HANDLING_TRANS_SHIPMENTS_M3_EUR	AS val_min, D_VALID_FROM, D_VALID_TO,CD_FULFILLMENT,T_STORAGE_LOCATION  
	               FROM L1.L1_DIM_A_HANDLING_TRANSSHIP
	               WHERE CD_SIZE_BRACKET = 'Standard-Size_Small')		AS transship_min
			ON fact.CD_FULFILLMENT = transship_min.CD_FULFILLMENT 
			AND 	ISNULL(fact.T_REVISED_LOCATION,fact.T_STORAGE_LOCATION) = transship_min.T_STORAGE_LOCATION
			AND  fact.D_CREATED BETWEEN transship_min.D_VALID_FROM AND transship_min.D_VALID_TO 
	    LEFT JOIN (SELECT 2 * AMT_HANDLING_TRANS_SHIPMENTS_M3_EUR		AS val_max, D_VALID_FROM, D_VALID_TO,CD_FULFILLMENT,T_STORAGE_LOCATION  
	               FROM L1.L1_DIM_A_HANDLING_TRANSSHIP
	               WHERE CD_SIZE_BRACKET = 'Over-Size_Large')			AS transship_max
	        ON fact.CD_FULFILLMENT = transship_max.CD_FULFILLMENT 
			AND 	ISNULL(fact.T_REVISED_LOCATION,fact.T_STORAGE_LOCATION) = transship_max.T_STORAGE_LOCATION
			AND  fact.D_CREATED BETWEEN transship_max.D_VALID_FROM AND transship_max.D_VALID_TO 
		LEFT JOIN (SELECT 0.02 * AMT_HANDLING_INBOUND_COST_EUR			AS val_min, D_VALID_FROM, D_VALID_TO,T_STORAGE_LOCATION  
	               FROM L1.L1_DIM_A_HANDLING_INBOUND 
	               WHERE CD_SIZE_BRACKET = 'Standard-Size_Small')		AS inbound_min
	        ON fact.D_CREATED BETWEEN inbound_min.D_VALID_FROM AND inbound_min.D_VALID_TO 
			AND 	ISNULL(fact.T_REVISED_LOCATION,fact.T_STORAGE_LOCATION) = inbound_min.T_STORAGE_LOCATION
	    LEFT JOIN (SELECT 2 * AMT_HANDLING_INBOUND_COST_EUR				AS val_max, D_VALID_FROM, D_VALID_TO,T_STORAGE_LOCATION 
	               FROM L1.L1_DIM_A_HANDLING_INBOUND 
	               WHERE CD_SIZE_BRACKET = 'Over-Size_Large')			AS inbound_max
	        ON fact.D_CREATED BETWEEN inbound_max.D_VALID_FROM AND inbound_max.D_VALID_TO 
			AND 	ISNULL(fact.T_REVISED_LOCATION,fact.T_STORAGE_LOCATION) = inbound_max.T_STORAGE_LOCATION
		LEFT JOIN [L1].[L1_DIM_A_CS_MANAGEMENT] csmanage
			ON fact.CD_COUNTRY_DELIVERY = csmanage.CD_COUNTRY
			AND fact.D_CREATED BETWEEN csmanage.D_VALID_FROM AND csmanage.D_VALID_TO 
			AND fact.CD_FULFILLMENT = csmanage.CD_FULFILLMENT
	    --LEFT JOIN [L1].[L1_FACT_A_CAMPAIGN_COSTS] AS camp_costs
	    --    ON fact.CD_SALES_TRANSACTION = camp_costs.CD_SALES_TRANSACTION
		LEFT JOIN [L1].[L1_DIM_A_SALES_CHANNEL] dimchannel
			ON fact.ID_SALES_CHANNEL = dimchannel.ID_SALES_CHANNEL
		LEFT JOIN [L1].[L1_DIM_A_TRUCKING_TRANS_SHIPMENTS] truckingtransship
			ON fact.CD_COUNTRY_DELIVERY = truckingtransship.CD_COUNTRY_DELIVERY
			AND fact.CD_SIZE_BRACKET = truckingtransship.CD_SIZE_BRACKET
			AND fact.CD_FULFILLMENT = truckingtransship.CD_FULFILLMENT
			AND 	ISNULL(fact.T_REVISED_LOCATION,fact.T_STORAGE_LOCATION) = truckingtransship.T_STORAGE_LOCATION
			AND dimchannel.CD_CHANNEL_GROUP_1 = truckingtransship.CD_CHANNEL_GROUP_1
			AND fact.D_CREATED BETWEEN truckingtransship.D_VALID_FROM AND truckingtransship.D_VALID_TO
	    LEFT JOIN [L1].[L1_DIM_A_MARKETING_MARKETPLACES] marketplaces
			ON fact.ID_SALES_CHANNEL = marketplaces.ID_SALES_CHANNEL
			AND fact.[T_PRODUCT_HIERARCHY_1] = marketplaces.[T_PRODUCT_HIERARCHY_1]
			AND fact.[T_PRODUCT_HIERARCHY_2] = marketplaces.[T_PRODUCT_HIERARCHY_2]
			AND fact.D_CREATED BETWEEN marketplaces.D_VALID_FROM AND marketplaces.D_VALID_TO
		LEFT JOIN [L1].[L1_DIM_A_CS_COMMISSIONS_MARKETPLACES]			AS CM
			ON dimchannel.CD_CHANNEL_GROUP_2 = CM.CD_CHANNEL_GROUP_2
			AND dimchannel.CD_CHANNEL_GROUP_1 = CM.CD_CHANNEL_GROUP_1
			AND fact.T_PRODUCT_HIERARCHY_1 = CM.T_PRODUCT_HIERARCHY_1
			AND fact.T_PRODUCT_HIERARCHY_2 = CM.T_PRODUCT_HIERARCHY_2
			AND fact.D_CREATED BETWEEN CM.D_VALID_FROM AND CM.D_VALID_TO
		LEFT JOIN [L1].[L1_DIM_A_CS_PAYMENTS]							AS PAY
			ON fact.[ID_SALES_CHANNEL] = PAY.[ID_SALES_CHANNEL]
			AND fact.D_CREATED BETWEEN PAY.D_VALID_FROM AND PAY.D_VALID_TO
		LEFT JOIN [L1].[L1_DIM_A_HANDLING_RETURNS]						AS returns
			ON fact.CD_FULFILLMENT = returns.CD_FULFILLMENT
			AND fact.CD_SIZE_BRACKET = returns.CD_SIZE_BRACKET
			AND 	ISNULL(fact.T_REVISED_LOCATION,fact.T_STORAGE_LOCATION) = returns.T_STORAGE_LOCATION
			AND fact.D_CREATED BETWEEN returns.D_VALID_FROM AND returns.D_VALID_TO
		LEFT JOIN [L1].[L1_DIM_A_WAREHOUSE_RENT] rent
			ON fact.CD_SIZE_BRACKET = rent.CD_SIZE_BRACKET
			AND 	ISNULL(fact.T_REVISED_LOCATION,fact.T_STORAGE_LOCATION) = rent.T_STORAGE_LOCATION
			AND fact.CD_FULFILLMENT = rent.CD_FULFILLMENT
			AND fact.D_CREATED BETWEEN rent.D_VALID_FROM AND rent.D_VALID_TO
		LEFT JOIN [L1].[L1_DIM_A_WAREHOUSE_RENT] rent_max
			ON 'Over-Size_Large' = rent_max.CD_SIZE_BRACKET
			AND 	ISNULL(fact.T_REVISED_LOCATION,fact.T_STORAGE_LOCATION) = rent_max.T_STORAGE_LOCATION
			AND fact.CD_FULFILLMENT = rent_max.CD_FULFILLMENT
			AND fact.D_CREATED BETWEEN rent_max.D_VALID_FROM AND rent_max.D_VALID_TO
		LEFT JOIN [L1].[L1_DIM_A_WAREHOUSING_OPEX] opex
			ON fact.CD_SIZE_BRACKET = opex.CD_SIZE_BRACKET
			AND fact.CD_FULFILLMENT = opex.CD_FULFILLMENT
			AND 	ISNULL(fact.T_REVISED_LOCATION,fact.T_STORAGE_LOCATION) = opex.T_STORAGE_LOCATION
			AND fact.D_CREATED BETWEEN opex.D_VALID_FROM AND opex.D_VALID_TO
		LEFT JOIN [L1].[L1_DIM_A_WAREHOUSING_OPEX] opex_max
			ON 'Over-Size_Large' = opex_max.CD_SIZE_BRACKET
			AND fact.CD_FULFILLMENT = opex_max.CD_FULFILLMENT
			AND 	ISNULL(fact.T_REVISED_LOCATION,fact.T_STORAGE_LOCATION) = opex_max.T_STORAGE_LOCATION
			AND fact.D_CREATED BETWEEN opex_max.D_VALID_FROM AND opex_max.D_VALID_TO
		LEFT JOIN [L1].[L1_DIM_A_CS_COMMISSIONS_AMAZON] c_amaz
	        ON fact.T_PRODUCT_HIERARCHY_1 = c_amaz.T_PRODUCT_HIERARCHY_1
	        AND fact.T_PRODUCT_HIERARCHY_2 = c_amaz.T_PRODUCT_HIERARCHY_2
	        AND fact.D_CREATED BETWEEN c_amaz.D_VALID_FROM AND c_amaz.D_VALID_TO
		LEFT JOIN [L1].[L1_DIM_A_WAREHOUSING_FBA] WHFBA
			ON fact.[D_CREATED] BETWEEN WHFBA.D_VALID_FROM AND WHFBA.D_VALID_TO
			AND fact.CD_SIZE_BRACKET_FBA = WHFBA.CD_SIZE_BRACKET_FBA
		LEFT JOIN [L1].[L1_DIM_A_MARKETING_FIXED_COST] cfm
	        on fact.[D_CREATED] between cfm.D_VALID_FROM and cfm.D_VALID_TO
	        and dimchannel.[CD_CHANNEL_GROUP_1] = cfm.CD_CHANNEL_GROUP_1
		LEFT JOIN 
	      (SELECT SUM(AMT_PACKAGING_PRICE_EUR*VL_PACKAGING_PROPORTION_RATE) AS AMT_PACKAGING_COST_TOTAL
		          ,d_valid_from
				  ,d_valid_to
				  ,cd_enviro_category
				  ,cd_cost_type
           FROM [L1].[L1_DIM_A_PL_ENVIRO_PACKAGING]
           WHERE CD_COST_TYPE = 'POM' and CD_ENVIRO_CATEGORY='PAC_ES' 
           GROUP BY d_valid_from,d_valid_to,cd_enviro_category,cd_cost_type
		   ) eps
		   ON fact.D_CREATED between eps.d_valid_from and eps.d_valid_to
		   AND fact.cd_Country_delivery='ES' 
         LEFT JOIN 
	       (SELECT SUM(AMT_PACKAGING_PRICE_EUR*VL_PACKAGING_PROPORTION_RATE) AS AMT_PACKAGING_COST_TOTAL
		    ,d_valid_from
			,d_valid_to
			,cd_enviro_category
			,cd_cost_type
            FROM [L1].[L1_DIM_A_PL_ENVIRO_PACKAGING]
            WHERE CD_COST_TYPE = 'POM' and CD_ENVIRO_CATEGORY='PAC_GER' 
            GROUP BY d_valid_from,d_valid_to,cd_enviro_category,cd_cost_type
			) epd			
			ON fact.D_CREATED between epd.d_valid_from and epd.d_valid_to
			AND fact.cd_Country_delivery='DE' 
		 LEFT JOIN CTE_LICENSES el
			ON fact.ID_ITEM=el.ID_ITEM
			AND fact.D_CREATED BETWEEN el.D_VALID_FROM AND el.D_VALID_TO
		 LEFT JOIN PACKAGING_FRA france
			ON fact.D_CREATED between france.d_valid_from and france.d_valid_to
			AND fact.cd_Country_delivery='FR' 
			AND dimchannel.CD_CHANNEL_GROUP_1<>'Mandanten' 
			AND item.NUM_ITEM like '[1345]%' 
			AND (dimcomp.CD_COMPANY=1000 or dimcomp.CD_COMPANY=1)
		 LEFT JOIN [L0].[L0_MI_COUNTRY_MAPPING] cmd
			ON fact.CD_COUNTRY_DELIVERY = cmd.COUNTRY
		  --join classification for textile
		 LEFT join [L1].[L1_DIM_A_ENVIRO_CLASSIFICATION] class_textile
			ON  class_textile.cd_item=item.NUM_ITEM
			AND fact.D_CREATED between  class_textile.D_VALID_FROM AND  class_textile.D_VALID_TO 
			AND  class_textile.cd_enviro_category = 'TEXTILE'
		 --join rest for textile
		 LEFT JOIN [L1].[L1_DIM_A_PL_ENVIRO_REST] rest_textile
			ON class_textile.cd_enviro_category=rest_textile.cd_enviro_category
			AND class_textile.cd_classification_category=rest_textile.cd_classification_category
			AND fact.D_CREATED between rest_textile.D_VALID_FROM AND rest_textile.D_VALID_TO 
		   --join classification for abj
		 LEFT join [L1].[L1_DIM_A_ENVIRO_CLASSIFICATION] class_abj
			ON  class_abj.cd_item=item.NUM_ITEM
			AND fact.D_CREATED between  class_abj.D_VALID_FROM AND  class_abj.D_VALID_TO
		    AND class_abj.cd_enviro_category = 'ABJ'
		 --join rest for abj
		 LEFT JOIN 	[L1].[L1_DIM_A_PL_ENVIRO_REST] rest_abj
			ON class_abj.cd_enviro_category= rest_abj.cd_enviro_category
			AND class_abj.cd_classification_category= rest_abj.cd_classification_category
			AND fact.D_CREATED between  rest_abj.D_VALID_FROM AND  rest_abj.D_VALID_TO 
		    --join classification for ASL
		 LEFT join [L1].[L1_DIM_A_ENVIRO_CLASSIFICATION] class_asl
			ON   class_asl.cd_item=item.NUM_ITEM
			AND fact.D_CREATED between   class_asl.D_VALID_FROM AND   class_asl.D_VALID_TO 
			AND  class_asl.cd_enviro_category = 'ASL'
		 --join rest for ASL
		 LEFT JOIN [L1].[L1_DIM_A_PL_ENVIRO_REST] rest_asl
			ON class_asl.cd_enviro_category=rest_asl.cd_enviro_category
			AND class_asl.cd_classification_category=rest_asl.cd_classification_category
			AND fact.D_CREATED between rest_asl.D_VALID_FROM AND rest_asl.D_VALID_TO 	
			AND (item.VL_GROSS_WEIGHT*0.7/1000)>rest_asl.VL_MIN_INTERVAL and (item.VL_GROSS_WEIGHT*0.7/1000)<=rest_asl.VL_MAX_INTERVAL
		 --join rest for umverpackung
		 LEFT JOIN 	[L1].[L1_DIM_A_PL_ENVIRO_REST] er1			  
			ON fact.D_CREATED between er1.D_VALID_FROM AND er1.D_VALID_TO 
			AND er1.cd_enviro_category='UMVERPACKUNG'
			and fact.cd_Country_delivery in ('DE','FR','ES')
			AND dimchannel.CD_CHANNEL_GROUP_1<>'Mandanten' 
			AND (item.NUM_ITEM like '[1345]%'  AND (dimcomp.CD_COMPANY=1000 or dimcomp.CD_COMPANY=1)) 
		--join classification for wee 
		 LEFT JOIN [L1].[L1_DIM_A_ENVIRO_CLASSIFICATION] wee 
			on wee.cd_item=item.NUM_ITEM
			AND fact.D_CREATED between wee.D_VALID_FROM AND wee.D_VALID_TO 
			AND wee.cd_enviro_category  = 'WEE'
			AND fact.cd_Country_delivery=wee.cd_Country_delivery
		-- join rest for wee
		 LEFT JOIN 
			(select cd_enviro_category,cd_classification_category,D_VALID_FROM,D_VALID_TO,cd_Country_delivery,VL_MIN_INTERVAL,VL_MAX_INTERVAL,cd_currency,sum([AMT_FEE_PER_UNIT]) as AMT_FEE_PER_UNIT ,sum([AMT_FEE_PER_WEIGHT]) as AMT_FEE_PER_WEIGHT
			FROM [L1].[L1_DIM_A_PL_ENVIRO_REST]
			group by cd_enviro_category,cd_classification_category,D_VALID_FROM,D_VALID_TO,cd_Country_delivery,cd_currency,VL_MIN_INTERVAL,VL_MAX_INTERVAL
			) rest_wee
			ON wee.cd_enviro_category=rest_wee.cd_enviro_category
			AND (wee.cd_classification_category=rest_wee.cd_classification_category)
			AND fact.D_CREATED between rest_wee.D_VALID_FROM AND rest_wee.D_VALID_TO 
			AND wee.cd_Country_delivery=rest_wee.cd_Country_delivery
		    AND (CASE WHEN fact.cd_Country_delivery<>'DE' and item.T_PRODUCT_HIERARCHY_3 in ('Cross Trainer', 'Rowing Machine', 'Sixpack Training', 'Cardio Bikes') THEN 1 ELSE item.VL_GROSS_WEIGHT*0.7/1000 END)>rest_wee.VL_MIN_INTERVAL 
			AND (CASE WHEN fact.cd_Country_delivery<>'DE' and item.T_PRODUCT_HIERARCHY_3 in ('Cross Trainer', 'Rowing Machine', 'Sixpack Training', 'Cardio Bikes') THEN 1 ELSE item.VL_GROSS_WEIGHT*0.7/1000 END)<=rest_wee.VL_MAX_INTERVAL
			--join fx rate
		 LEFT JOIN [L1].[L1_FACT_F_FX_RATE] fr
			ON fact.cd_currency=fr.cd_currency
			AND Year(fact.D_CREATED)=Year(fr.D_EFFECTIVE)
			AND Month(fact.D_CREATED)=Month(fr.D_EFFECTIVE)
		 LEFT JOIN [L1].[L1_FACT_F_FX_RATE] frsek
			ON  frsek.cd_currency='SEK'
			AND Year(fact.D_CREATED)=Year(frsek.D_EFFECTIVE)
			AND Month(fact.D_CREATED)=Month(frsek.D_EFFECTIVE)
		--join fx rate for us
		LEFT JOIN [L1].[L1_FACT_F_FX_RATE] us
			ON us.cd_currency='USD'
			AND Year(fact.D_CREATED)=Year(us.D_EFFECTIVE)
			AND Month(fact.D_CREATED)=Month(us.D_EFFECTIVE)
		--join fx rate for wee currency
		LEFT JOIN [L1].[L1_FACT_F_FX_RATE] rate_wee
		    ON rest_wee.cd_currency=rate_wee.cd_currency
		    AND Year(fact.D_CREATED)=Year(rate_wee.D_EFFECTIVE)
		    AND Month(fact.D_CREATED)=Month(rate_wee.D_EFFECTIVE)
		LEFT JOIN [L1].[L1_DIM_A_PL_SWEDISH_CHEMICAL_TAX] sch
			ON substring(item.CD_COMMODITY_CODE,1,6)=sch.CD_TARRIC_NUMBER
			and fact.D_CREATED BETWEEN sch.D_VALID_FROM AND sch.D_VALID_TO
			AND (item.NUM_ITEM like '[1345]%' and (dimcomp.CD_COMPANY=1000 or dimcomp.CD_COMPANY=1)) 
			AND dimchannel.CD_CHANNEL_GROUP_1<>'Mandanten' and fact.cd_Country_delivery='SE' 
		--join batteries
		LEFT JOIN (
			SELECT item.[ID_ITEM],batteries.d_valid_from,batteries.d_valid_to,batteries.cd_enviro_category,rest_batt.cd_country_delivery,sum(AMT_FEE_PER_UNIT*VL_COUNT) as AMT_FEE_PER_UNIT_COUNT
			,sum(VL_WEIGHT*AMT_FEE_PER_WEIGHT*VL_COUNT/1000) AS AMT_FEE_PER_WEIGHT_COUNT
			 FROM [L1].[L1_DIM_A_ENVIRO_CLASSIFICATION] batteries
			 LEFT JOIN [L1].[L1_DIM_A_ITEM] item 
			 ON CAST (item.cd_item as bigint)=batteries.CD_ITEM
			 LEFT JOIN [L1].[L1_DIM_A_PL_ENVIRO_REST] rest_batt
			 ON batteries.cd_enviro_category=rest_batt.cd_enviro_category
			 AND batteries.cd_classification_category=rest_batt.cd_classification_category
			 AND batteries.d_valid_to = rest_batt.d_valid_to
			 AND batteries.VL_WEIGHT>rest_batt.VL_MIN_INTERVAL and batteries.VL_WEIGHT<=rest_batt.VL_MAX_INTERVAL
			 WHERE batteries.cd_enviro_category = 'BATTERIES'
			 GROUP BY item.[ID_ITEM],batteries.d_valid_from,batteries.d_valid_to,batteries.cd_enviro_category,rest_batt.cd_country_delivery
			 ) batteries
			ON batteries.id_item=fact.id_item
			AND fact.D_CREATED between batteries.D_VALID_FROM AND batteries.D_VALID_TO 
			AND fact.cd_Country_delivery=batteries.cd_Country_delivery 
		 -- join furniture
	    LEFT join 
			(SELECT item.[ID_ITEM],ec.d_valid_from,ec.d_valid_to,ec.cd_enviro_category,sum(AMT_TARIF_HT*VL_COUNT) as AMT_TARIF_HT 
			 FROM [L1].[L1_DIM_A_ENVIRO_CLASSIFICATION] ec 
			 LEFT JOIN [L1].[L1_DIM_A_ITEM] item 
			 ON CAST (item.cd_item as bigint)=ec.CD_ITEM
			 LEFT JOIN [L1].[L1_DIM_A_PL_ENVIRO_REST] rest_furniture
			 ON ec.cd_enviro_category=rest_furniture.cd_enviro_category
			 AND ec.cd_classification_category=rest_furniture.cd_classification_category
			 AND ec.d_valid_to = rest_furniture.d_valid_to
			 AND (item.VL_GROSS_WEIGHT*0.7/1000/VL_COUNT)>rest_furniture.VL_MIN_INTERVAL and (item.VL_GROSS_WEIGHT*0.7/1000/VL_COUNT)<=rest_furniture.VL_MAX_INTERVAL
			 WHERE ec.cd_enviro_category = 'FURNITURE' 
			 GROUP BY item.[ID_ITEM],ec.d_valid_from,ec.d_valid_to,ec.cd_enviro_category
			 ) furniture
			ON furniture.id_item=fact.ID_ITEM
			AND fact.D_CREATED between furniture.D_VALID_FROM AND furniture.D_VALID_TO  
			--join fulfillment shipping factor
		LEFT JOIN L1.L1_DIM_A_FULFILLMENT_SHIPPING_FACTOR factor
		ON fact.CD_SIZE_BRACKET = factor.CD_SIZE_BRACKET
		AND fact.CD_FULFILLMENT = factor.CD_FULFILLMENT
		AND ISNULL(fact.T_REVISED_LOCATION,fact.T_STORAGE_LOCATION) = factor.T_STORAGE_LOCATION
		AND cmd.DELIVERYCOUNTRYGROUP = factor.[CD_COUNTRY_DELIVERY_GROUP]
		AND fact.D_CREATED BETWEEN factor.D_VALID_FROM AND factor.D_VALID_TO 
		WHERE 
			(item.NUM_ITEM NOT LIKE '7%' OR ID_ITEM_PARENT IS NOT NULL )
			AND item.NUM_ITEM NOT LIKE '6%'
			AND YEAR(fact.D_CREATED) = 2024
			and fact.CD_ITEM_TYPE = 'A'
			AND CASE 
					WHEN dimchannel.T_SALES_CHANNEL='Intercompany' OR dimchannel.T_SALES_CHANNEL='Mandanten' THEN 1
				ELSE 0
				END	= 0
			AND ISNULL(fact.FL_INCIDENT,'N') = 'N'
	),
	CTE_SALES_L2 AS 
	(
		SELECT sales.*
			,(Turnover * [PCT_PAYMENTS_ORDER])																	AS Payments
			,(Turnover * [PCT_COMMISSIONS_MARKETPLACES])														AS CommissionsMarketplaces
			,(Turnover - ValueAddedTax - OrderDiscounts + OrderCharges) * VL_GROSS_ORDER_VALUE_PARAM			AS GrossOrderValue
			,(OrderQuantity * CancellRate)* VL_CANCELLED_ORDERS_QUANTITY_EST_PARAM								AS CancelledOrdersQuantityEst
			,(DemurrageDetention+Deadfreight+Kickbacks+[3rdPartyServices]+RMA+Samples+OtherCOGSEffectsEst+DropShipmentCEOTRA9erArtikelEst+InboundFreightCostsEst+POCancellation+StockAdjustment) AS COGSOperationsEst
		    ,(AMT_HANDLING_RETURNS_COST_EUR * ReturnRate)														AS HandlingReturnsOrders_calc
			,(AMT_HANDLING_RETURNS_COST_EUR * ReturnRate * 0.01)												AS HandlingRemovalsFBA_calc
	        ,CASE WHEN CD_CHANNEL_GROUP_1 = 'Amazon' then Turnover*VL_COMMISSIONS_ORDER_RATE ELSE NULL END		AS CommissionsAmazon
		FROM CTE_SALES_L1 sales
	)
	,
	CTE_SALES_L3 AS 
	(
		SELECT sales.*
				,(GrossOrderValue * CancellRate)* VL_CANCELLED_ORDER_VALUE_EST_PARAM						AS CancelledOrderValueEst
				,(OrderQuantity - CancelledOrdersQuantityEst) * VL_NET_ORDER_QUANTITY_EST_PARAM				AS NetOrderQuantityEst
				,(GrossOrderValue * RefundRate) * VL_REFUNDED_ORDER_VALUE_EST_PARAM							AS RefundedOrderValueEst
				,(PCT_MARKETING * GrossOrderValue)															AS MarketingMarketplacesEst
				,(HandlingReturnsOrders_calc + HandlingRemovalsFBA_calc)									AS HandlingReturnsEst
				,CASE WHEN CommissionsAmazon between c_amaz_ref.[VL_VALUE_FROM] and c_amaz_ref.[VL_VALUE_TO] 
				      THEN CASE WHEN c_amaz_ref.[VL_COMMISSIONS_REFUND_ABOVE_THRESHOLD] <> 0 
				                THEN (CommissionsAmazon - c_amaz_ref.[VL_COMMISSIONS_REFUND_ABOVE_THRESHOLD])*sales.RefundRate 
				                ELSE (CommissionsAmazon * c_amaz_ref.[VL_COMMISSIONS_REFUND_BELOW_THRESHOLD_RATE])*sales.RefundRate 
				           END
				      ELSE NULL
				END AS CommissionsAmazonRefunds
				,CASE 
                    WHEN (isnull(ReasonForRejections,'')  <> '' and isnull(ReasonForRejections,'') <>'Wrongly created') 
						OR CD_SOURCE_SYSTEM = 'SGE'
                     THEN (GrossOrderValue) * VL_CANCELLED_ORDER_VALUE_PARAM ELSE 0 END						AS [AMT_CANCELLED_ORDER_VALUE_EUR]
				,CASE 
                    WHEN (isnull(ReasonForRejections,'')  <> '' and isnull(ReasonForRejections,'') <>'Wrongly created') 
						OR CD_SOURCE_SYSTEM = 'SGE'
                     THEN ISNULL(Quantity,0) * VL_CANCELLED_ORDER_QUANTITY_PARAM ELSE 0 END					AS [VL_CANCELLED_ORDER_QUANTITY]

	    FROM CTE_SALES_L2 sales
	    LEFT JOIN [L1].[L1_DIM_A_CS_COMMISSIONS_AMAZON_REFUND] c_amaz_ref
	         ON TransactionDate BETWEEN c_amaz_ref.[D_VALID_FROM] AND c_amaz_ref.[D_VALID_TO]
	         AND CommissionsAmazon > c_amaz_ref.VL_VALUE_FROM 
	         AND CommissionsAmazon <= c_amaz_ref.VL_VALUE_TO 
	)
	,
	CTE_SALES_L4 AS 
	(
		SELECT sales.*
				 ,(NetOrderQuantityEst * [CS_HANDLING_CLAIMS])												AS CSHandlingClaims
				 ,(RefundedOrderValueEst * [PCT_COMMISSIONS_MARKETPLACES_RETURN])							AS CommissionsMarketplacesRefunds
				 ,(GrossOrderValue - CancelledOrderValueEst)*VL_NET_ORDER_VALUE_EST_PARAM					AS NetOrderValueEst
				 ,(NetOrderQuantityEst * RefundRate) *  VL_REFUNDED_QUANTITY_EST_PARAM						AS RefundedQuantityEst
				 ,(NetOrderQuantityEst * Packaging_PreCalc)													AS Packaging
				 ,(NetOrderQuantityEst * HandlingOrdersEst_PreCalc)											AS HandlingOrdersEst
				 ,(NetOrderQuantityEst * HandlingInboundEst_PreCalc)										AS HandlingInboundEst
				 ,(NetOrderQuantityEst * HandlingTransShippmentEst_PreCalc)									AS HandlingTransShippmentEst
				 ,(NetOrderQuantityEst * TruckingTransShipmentEst_PreCalc)									AS TruckingTransShipmentEst
				 ,(NetOrderQuantityEst * WarehousingRentEst_PreCalc)										AS WarehousingRentEst
				 ,(NetOrderQuantityEst * WarehousingOpexEst_PreCalc)										AS WarehousingOPEXEst
				 ,(NetOrderQuantityEst * ReturnRate) * VL_RETURNED_QUANTITY_EST_PARAM						AS ReturnedQuantityEst
				 ,(NetOrderQuantityEst * CSManagement_PreCalc)												AS CSManagement
				 ,(ReplacementOrderQuantityEst_PreCal * NetOrderQuantityEst)						        AS ReplacementOrderQuantityEst
				 ,(GrossOrderValue - [AMT_CANCELLED_ORDER_VALUE_EUR])										AS [AMT_NET_ORDER_VALUE_EUR]
				 ,((GrossOrderValue+OrderDiscounts) - [AMT_CANCELLED_ORDER_VALUE_EUR]) *VL_NET_ORDER_VALUE_FULL_PRICE_PARAM		AS [AMT_NET_ORDER_VALUE_FULL_PRICE_EUR]
				 ,(OrderQuantity - [VL_CANCELLED_ORDER_QUANTITY]) * VL_CANCELLED_ORDER_QUANTITY_PARAM		AS [VL_NET_ORDER_QUANTITY]

		FROM CTE_SALES_L3 sales
	)
	,
	CTE_SALES_L5 AS 
	(
		SELECT sales.*
		        ,(NetOrderValueEst * VL_MARKETING_FIXED_COST_RATE)											AS MarketingFixedCost
				,(NetOrderValueEst - RefundedOrderValueEst) * [VL_REVENUE_EST_PARAM] AS RevenueEst
				,(NetOrderQuantityEst - RefundedQuantityEst) * [VL_NET_QUANTITY_EST_PARAM] AS NetQuantityEst
				,CASE WHEN Quantity <> 0 
						THEN (((NetOrderQuantityEst - RefundedQuantityEst) * (ISNULL(MEKHedging,0)-ISNULL(GTSMarkup,0)) )/ISNULL(Quantity,1)) * [VL_NET_QUANTITY_EST_PARAM]  
						ELSE 0 END																			AS NetProductCostEst
				,ISNULL(MEKHedging,0)	* VL_NET_PRODUCT_COSTS_THEREOF_RETURN_MEK_PARAM						AS AMT_NET_PRODUCT_COSTS_THEREOF_RETURN_MEK_EUR
				,(NetOrderValueEst * ReturnRate) * VL_RETURN_ORDER_VALUE_EST_PARAM							AS ReturnOrderValueEst
				,(NetOrderQuantityEst * ShippingCostEst * AMT_CORRECTION_FACTOR_ORDER)						AS ShippingCostsInvoicedEst
				,(ReturnedQuantityEst * ShippingCostEst * AMT_CORRECTION_FACTOR_RETURN)	    				AS ShippingCostsReturnedEst
				,(ReplacementOrderQuantityEst * ShippingCostEst * AMT_CORRECTION_FACTOR_REPLACEMENT)		AS ShippingCostsReplacedEst
				,NetOrderValueEst - (CASE WHEN Quantity <> 0 
						THEN (((NetOrderQuantityEst) * (ISNULL(MEKHedging,0)-ISNULL(GTSMarkup,0)) )/ISNULL(Quantity,1)) * [VL_NET_QUANTITY_EST_PARAM]  
						ELSE 0 END)																			AS NetOrderContributionEst
				,Packaging*AMT_FEE_PER_UNIT_2																AS AMT_REPACKAGING_EST_EUR
				,AMT_ASL_EST_EUR_PRECALC * ISNULL((NetOrderQuantityEst - ReturnedQuantityEst + ReplacementOrderQuantityEst),0)			  AS AMT_ASL_EST_EUR
				,CASE WHEN (VL_ENVIRO_EST_PARAM*AMT_TAX_KG_SEK*VL_GROSS_WEIGHT*0.7/1000)> AMT_TAX_CAP_SEK
					  THEN AMT_TAX_CAP_SEK*SEK_RATE*(NetOrderQuantityEst - ReturnedQuantityEst + ReplacementOrderQuantityEst)
					  ELSE Isnull(SEK_RATE*VL_ENVIRO_EST_PARAM*VL_GROSS_WEIGHT*0.7/1000*(NetOrderQuantityEst - ReturnedQuantityEst + ReplacementOrderQuantityEst)*AMT_TAX_KG_SEK,0)
				END AS 	AMT_SWE_TAX_EST_EUR
				,AMT_DEPRECIATION_EST_EUR = ReturnedQuantityEst*AMT_DEPRECIATIONEST_PRECALC_EUR 

		FROM CTE_SALES_L4 sales
	)
	,
	CTE_SALES_L6 AS 
	(
		SELECT sales.*
				 ,(RevenueEst - NetProductCostEst - (ReplacementProductCostEst_PreCal * NetProductCostEst) - ISNULL(AMT_DEPRECIATION_EST_EUR,0)) * VL_PC0_PARAM				AS PC0
				 ,(ShippingCostsInvoicedEst+ShippingCostsReturnedEst+ShippingCostsReplacedEst)										        AS FulfillmentOutboundEst
				 ,(ReplacementProductCostEst_PreCal * NetProductCostEst)																	AS ReplacementProductCostEst
		         ,ISNULL(AMT_PACKAGING_COST_ES_EST_PRECALC *(NetOrderQuantityEst - ReturnedQuantityEst + ReplacementOrderQuantityEst),0)	AS AMT_PACKAGING_COST_ES_EST_EUR
				 ,ISNULL(AMT_PACKAGING_COST_DE_EST_PRECALC *(NetOrderQuantityEst - ReturnedQuantityEst + ReplacementOrderQuantityEst),0)	AS AMT_PACKAGING_COST_DE_EST_EUR
		         ,ISNULL(AMT_ABJ_EST_EUR_PRECALC*(NetOrderQuantityEst - ReturnedQuantityEst + ReplacementOrderQuantityEst),0)				AS AMT_ABJ_EST_EUR
			     ,(ISNULL(AMT_PACKAGING_COST_FRA_EST_PRECALC,0)+ISNULL(VL_CSU_FEE,0))*ISNULL(NetOrderQuantityEst - ReturnedQuantityEst + ReplacementOrderQuantityEst,0)  AS AMT_PACKAGING_COST_FRA_EST_EUR
				 ,(ISNULL(NetOrderQuantityEst - ReturnedQuantityEst + ReplacementOrderQuantityEst,0) * ISNULL(AMT_PRODUCT_LICENSES_EST_PRECAL,0)
				   + CASE WHEN DeliveryCountry = 'PL' THEN ISNULL(RevenueEst,0)*ISNULL([GEMA PL],0) ELSE 0 END
				   + ISNULL(NetOrderValueEst,0)*ISNULL(AIRTAG,0)
				   ) *ISNULL(VL_ENVIRO_EST_PARAM,0)
																																			AS AMT_PRODUCT_LICENSES_EST
				
				 ,ISNULL(AMT_TEXTILE_EST_EUR_PRECALC*(NetOrderQuantityEst - ReturnedQuantityEst + ReplacementOrderQuantityEst),0)			AS AMT_TEXTILE_EST_EUR
				 ,ISNULL(AMT_FEE_PER_UNIT_WEE * WEE_FX_RATE * VL_ENVIRO_EST_PARAM*(NetOrderQuantityEst - ReturnedQuantityEst + ReplacementOrderQuantityEst),0)
	                + 
                   ISNULL(AMT_WEE_PRECALC *(NetOrderQuantityEst - ReturnedQuantityEst + ReplacementOrderQuantityEst),0)
	               AS AMT_WEE_EST_EUR
				 ,AMT_TARIF_HT_FURNITURE_PRECALC * (NetOrderQuantityEst - ReturnedQuantityEst + ReplacementOrderQuantityEst)				AS AMT_TARIF_HT_FURNITURE_EST_EUR
				 ,ISNULL(AMT_FEE_PER_UNIT_BATTERIES_PRECALC*(NetOrderQuantityEst - ReturnedQuantityEst + ReplacementOrderQuantityEst),0)
	               +
                  ISNULL(AMT_FEE_PER_WEIGHT_BATTERIES_PRECALC*(NetOrderQuantityEst - ReturnedQuantityEst + ReplacementOrderQuantityEst),0)
																																			AS AMT_BATTERIES_EST_EUR																																																				
		
		FROM CTE_SALES_L5 sales
	)
	,
	CTE_SALES_L7 AS 
	(
		SELECT sales.*
				 ,(PC0 - FXHedgingImpactEst - COGSStockValueAdjustmentEst - COGSOperationsEst) * [VL_PC1_PARAM] AS PC1
		FROM CTE_SALES_L6 sales
	)
	,
	CTE_SALES_L8 AS 
	(
		SELECT sales.*
				,(ISNULL(AMT_PACKAGING_COST_DE_EST_EUR,0)+ ISNULL(AMT_PACKAGING_COST_ES_EST_EUR,0)+ ISNULL(AMT_PACKAGING_COST_FRA_EST_EUR,0) + ISNULL(AMT_ABJ_EST_EUR,0) + ISNULL(AMT_PRODUCT_LICENSES_EST,0) + ISNULL(AMT_TEXTILE_EST_EUR,0) + ISNULL(AMT_WEE_EST_EUR,0) + ISNULL(AMT_TARIF_HT_FURNITURE_EST_EUR,0) + ISNULL(AMT_BATTERIES_EST_EUR,0) + ISNULL(AMT_REPACKAGING_EST_EUR,0) + ISNULL(AMT_ASL_EST_EUR,0) + ISNULL(AMT_SWE_TAX_EST_EUR,0))	AS AMT_ENVIRO_AND_LICENSE_COST_EST_EUR
		FROM CTE_SALES_L7 sales
	)
	,
	CTE_SALES_L9 AS 
	(
		SELECT sales.*
						,CASE WHEN NUM_ITEM NOT LIKE '9%' THEN
				        (PC1 - 
						(ISNULL(HandlingInboundEst,0)+ISNULL(HandlingTransShippmentEst,0)+ISNULL(HandlingReturnsEst,0)+ISNULL(TruckingTransShipmentEst,0)+ISNULL(WarehousingFBA,0))	---FulfilmentInbound
						-ISNULL(FulfillmentOutboundEst,0)
						- (ISNULL(CommissionsMarketplaces,0)-ISNULL(CommissionsMarketplacesRefunds,0)+ISNULL(CommissionsAmazon,0)-ISNULL(CommissionsAmazonRefunds,0)) ---Commissions
						- (ISNULL(MarketingMarketplacesEst,0)+ISNULL(ShopMarketing,0)+ISNULL(AmazonMarketingCosts,0)) --Marketing Performance - still missing amazon marketing 713
						- (ISNULL(CSHandlingClaims,0)) 
						- (ISNULL(Packaging,0))
						- (ISNULL(HandlingOrdersEst,0)) 
						- (ISNULL(Payments,0)) ---stilll missing Enviromental charges
					- AMT_ENVIRO_AND_LICENSE_COST_EST_EUR) * VL_PC2_PARAM ELSE PC1 END AS PC2
		FROM CTE_SALES_L8 sales
	)
	,
	CTE_SALES_L10 AS 
	(
		SELECT sales.*
				 ,CASE WHEN NUM_ITEM NOT LIKE '9%' THEN
				 (PC2 - ISNULL(WarehousingRentEst,0) - ISNULL(WarehousingOPEXEst,0) - ISNULL(CSManagement,0)
						- ISNULL(MarketingFixedCost,0)
					)  * VL_PC3_PARAM ELSE PC1 END AS PC3		
		FROM CTE_SALES_L9 sales
	)
	INSERT INTO L1.L1_FACT_A_SALES_TRANSACTION_KPI_STEERING 
		(
		 ID_SALES_TRANSACTION
		,CD_SALES_TRANSACTION
		,CD_SOURCE_SYSTEM
		,CD_SALES_PROCESS_ID
		,CD_SALES_PROCESS_LINE
		,CD_DOCUMENT_NO
		,CD_DOCUMENT_LINE
		,CD_DOCUMENT_ID_REFERENCE
		,ID_COMPANY
		,D_CREATED
		,D_SALES_PROCESS
		,D_DOCUMENT_CREATED
		,T_CANCELLATION_REASON
		,FL_INCIDENT
		,DT_CREATED
		,CD_TYPE
		,ID_SALES_TRANSACTION_TYPE
		,ID_ITEM
		,ID_ITEM_PARENT 
		,CD_ITEM_TYPE
		,ID_SALES_CHANNEL
		,CD_FULFILLMENT
		,CD_CUSTOMER
		,CD_CUSTOMER_SERVICE_AGENT                                         
		,T_CREATION_USERNAME
		,CD_MARKET_ORDER_ID
		,CD_PAYMENT_METHOD
		,CD_STORAGE_LOCATION
		,T_STORAGE_LOCATION
		,CD_COUNTRY_INVOICE
		,CD_ZIP_INVOICE
		,T_CITY_INVOICE
		,CD_COUNTRY_DELIVERY
		,CD_ZIP_DELIVERY
		,T_CITY_DELIVERY
		,CD_COUNTRY_ORDER
		,CD_ZIP_ORDER
		,T_CITY_ORDER
		,CD_BILLING_CATEGORY	
		,D_BILLING_DATE					
		,CD_BILLING_POSTING_STATUS		
		,CD_PAYER						
		,VL_BILLING_QUANTITY			
		,VL_EXCHANGE_RATE				
		,CD_SALES_DOCUMENT_NO           
		,D_UPDATED						
		,CD_REJECTION_STATUS			
		,D_CANCELLATION
		,[CD_RETURN_REASON]         
        ,[T_RETURN_REASON] 
		,VL_ITEM_QUANTITY
		,VL_ITEM_PARENT_QUANTITY
		,AMT_NET_SHIPPING_REVENUE_EUR
		,AMT_NET_PRICE_EUR
		,AMT_NET_PRICE_FC
		,AMT_SHIPPING_COST_EST_EUR
		,CD_SHIPMENT_COSTS_SOURCE
		,AMT_GROSS_SHIPPING_REVENUE_EUR
		,AMT_GROSS_SHIPPING_REVENUE_FC
		,AMT_GROSS_PRICE_EUR
		,AMT_GROSS_PRICE_FC
		,AMT_TAX_PRICE_EUR
		,AMT_TAX_DISCOUNTS_EUR
		,AMT_TAX_FREIGHT_EUR
		,AMT_TAX_TOTAL_EUR
		,AMT_TAX_TOTAL_PAYABLE_EUR
        ,AMT_TAX_OUTPUT_EUR
		,AMT_MEK_HEDGING_EUR
		,AMT_GTS_MARKUP
		,AMT_NET_DISCOUNT_EUR
		,AMT_NET_DISCOUNT_FC                                     
		,CD_CURRENCY
		,AMT_COMMERCIAL_TURNOVER_EUR
		,AMT_TURNOVER_EUR
		,VL_ORDER_QUANTITY
		,AMT_VALUE_ADDED_TAX_EUR
		,AMT_ORDER_DISCOUNTS_EUR
		,AMT_ORDER_CHARGES_EUR
		,AMT_GROSS_ORDER_VALUE_EUR
		,VL_CANCELLED_ORDERS_QUANTITY_EST
		,VL_RETURNED_QUANTITY_EST
		,AMT_CANCELLED_ORDER_VALUE_EST_EUR
		,VL_NET_ORDER_QUANTITY_EST
		,AMT_REFUNDED_ORDER_VALUE_EST_EUR
		,AMT_RETURN_ORDER_VALUE_EST_EUR
		,AMT_NET_ORDER_VALUE_EST_EUR
		,VL_REFUNDED_QUANTITY_EST
		,AMT_REVENUE_EST_EUR
		,VL_NET_QUANTITY_EST
		,AMT_NET_PRODUCT_COST_EST_EUR
		,AMT_NET_ORDER_CONTRIBUTION_EST_EUR
		,AMT_PC0_EUR
		,AMT_DEMURRAGE_DETENTION_EUR
		,AMT_DEADFREIGHT_EUR
		,AMT_KICKBACKS_EUR
		,AMT_3RD_PARTY_SERVICES_EUR
		,AMT_RMA_EUR
		,AMT_SAMPLES_EUR
		,AMT_OTHER_COGS_EFFECTS_EST_EUR
		,AMT_DROPSHIPMENT_CEOTRA9ER_ARTIKEL_EST_EUR
		,AMT_INBOUND_FREIGHT_COST_EST_EUR
		,AMT_PO_CANCELLATION_EUR
		,AMT_STOCK_ADJUSTMENT_EUR
		,AMT_FX_HEDGING_IMPACT_EST_EUR
		,AMT_COGS_STOCK_VALUE_ADJUSTMENT_EST_EUR
		,AMT_COGS_OPERATIONS_EST_EUR
		,AMT_PC1_EUR
		,AMT_PC2_EUR
		,AMT_HANDLING_INBOUND_EST_EUR
		,AMT_HANDLING_TRANS_SHIPPMENT_EST_EUR
		,AMT_PACKAGING_EST_EUR
		,AMT_HANDLING_SHIPMENTS_EST_EUR
		,AMT_CUSTOMER_SERVICE_HANDLING_EST_EUR
		,AMT_CUSTOMER_SERVICE_OPEX_EST_EUR
		,AMT_SHOP_MARKETING_EUR
		,AMT_AMAZON_MARKETING_EUR
		,AMT_TRUCKING_TRANS_SHIPMENT_EST_EUR
		,AMT_MARKETING_MARKETPLACES_EST_EUR
		,AMT_COMMISSIONS_MARKETPLACES_EST_EUR
		,AMT_COMMISSIONS_MARKETPLACES_REFUNDS_EST_EUR
		,AMT_PAYMENTS_FEES_EST_EUR
		,AMT_HANDLING_RETURNS_EST_EUR
		,AMT_WAREHOUSING_RENT_EST_EUR
		,AMT_WAREHOUSING_OPEX_EST_EUR
		,AMT_REPLACEMENT_PRODUCT_COST_EST_EUR
		,AMT_REPLACEMENT_ORDER_QUANTITY_EST_EUR
		,AMT_COMMISSIONS_AMAZON_EST_EUR
		,AMT_COMMISSIONS_AMAZON_REFUNDS_EST_EUR
		,AMT_WAREHOUSING_FBA_EST_EUR
		,AMT_FULFILLMENT_OUTBOUND_EST_EUR
		,AMT_MARKETING_OPEX_EST_EUR
		,AMT_PACKAGING_COST_DE_EST_EUR
	    ,AMT_PACKAGING_COST_ES_EST_EUR
	    ,AMT_PACKAGING_COST_FRA_EST_EUR
		,AMT_ABJ_EST_EUR
		,AMT_PRODUCT_LICENSES_EST
		,AMT_TEXTILE_EST_EUR
		,AMT_WEE_EST_EUR
		,AMT_TARIF_HT_FURNITURE_EST_EUR
		,AMT_BATTERIES_EST_EUR
		,AMT_PC3_EUR
		,AMT_REPACKAGING_EST_EUR
		,CD_COUNTRY_GROUP_INVOICE
		,CD_COUNTRY_GROUP_DELIVERY
		,AMT_ASL_EST_EUR
		,AMT_SWE_TAX_EST_EUR
		,AMT_ENVIRO_AND_LICENSE_COST_EST_EUR
		,[AMT_CANCELLED_ORDER_VALUE_EUR]
		,[VL_CANCELLED_ORDER_QUANTITY]            
		,[AMT_NET_ORDER_VALUE_EUR]                
		,[AMT_NET_ORDER_VALUE_FULL_PRICE_EUR]     
		,[VL_NET_ORDER_QUANTITY]          
		,AMT_NET_PRODUCT_COSTS_THEREOF_RETURN_MEK_EUR
		,[CD_GTS_PO_NO]
		,[CD_GTS_PO_LINE]
	--	,LOAD_TIMESTAMP
	    --,[D_EFF_TO]
	    --,[D_EFF_DELETED]
		,FL_DELETED
		,FL_SINGLE_ITEM 
		,[CD_CANCELLED_DOCUMENT_NO]  
	    ,[CD_CANCELLED_DOCUMENT_LINE] 
		,[VL_REFUND_RATE]					  
		,[VL_RETURN_RATE]					 
		,[VL_REPLACEMENT_RATE]
		,[VL_DEPRETIATION_RATE]				  

		)
	SELECT 
	ID_SALES_TRANSACTION					  as ID_SALES_TRANSACTION
	,SalesTransactionCode					  as CD_SALES_TRANSACTION
	,Source									  as CD_SOURCE_SYSTEM
	,ProcessId								  as CD_SALES_PROCESS_ID
	,ProcessIDPosition						  as CD_SALES_PROCESS_LINE
	,DocumentNo								  as CD_DOCUMENT_NO
	,DocumentItemPosition					  as CD_DOCUMENT_LINE
	,ReferenceDocumentId					  as CD_DOCUMENT_ID_REFERENCE
	,CompanyId								  as ID_COMPANY
	,TransactionDate						  as D_CREATED
	,ProcessIDDate							  as D_SALES_PROCESS
	,D_DOCUMENT_CREATED						  as D_DOCUMENT_CREATED
	,ReasonForRejections					  as T_CANCELLATION_REASON
	,IncidentFlag							  as FL_INCIDENT
	,OrderCreationDateTime					  as DT_CREATED
	,TransactionTypeShort					  as CD_TYPE
	,TransactionTypeID						  as ID_SALES_TRANSACTION_TYPE
	,ItemID									  as ID_ITEM
	,ItemParentID							  as ID_ITEM_PARENT
	,ItemType								  as CD_ITEM_TYPE
	,ChannelId								  as ID_SALES_CHANNEL
	,Fulfillment							  as CD_FULFILLMENT
	,CustomerId								  as CD_CUSTOMER
	,CustomerServiceAgent                     as CD_CUSTOMER_SERVICE_AGENT
	,CreatedBy                                as T_CREATION_USERNAME
	,MarketplaceOrderId						  as CD_MARKET_ORDER_ID
	,PaymentMethod							  as CD_PAYMENT_METHOD
	,StorageLocationCode					  as CD_STORAGE_LOCATION
	,StorageLocation						  as T_STORAGE_LOCATION
	,InvoiceCountry							  as CD_COUNTRY_INVOICE
	,InvoiceZipCode							  as CD_ZIP_INVOICE
	,InvoiceCity							  as T_CITY_INVOICE
	,DeliveryCountry						  as CD_COUNTRY_DELIVERY
	,DeliveryZipCode						  as CD_ZIP_DELIVERY
	,DeliveryCity							  as T_CITY_DELIVERY
	,SalesCountry							  as CD_COUNTRY_ORDER
	,SalesZipCode							  as CD_ZIP_ORDER
	,SalesCity								  as T_CITY_ORDER
	,CD_BILLING_CATEGORY	
	,D_BILLING_DATE					
	,CD_BILLING_POSTING_STATUS		
	,CD_PAYER						
	,VL_BILLING_QUANTITY			
	,VL_EXCHANGE_RATE				
	,CD_SALES_DOCUMENT_NO           
	,D_UPDATED						
	,CD_REJECTION_STATUS			
	,D_CANCELLATION
	,CD_RETURN_REASON         
    ,T_RETURN_REASON 
	,Quantity								  as VL_ITEM_QUANTITY
	,ParentQuantity                           as VL_ITEM_PARENT_QUANTITY
	,NetShippingRevenue						  as AMT_NET_SHIPPING_REVENUE_EUR
	,NetPrice								  as AMT_NET_PRICE_EUR
	,NetPriceForeignCurrency				  as AMT_NET_PRICE_FC
	,ShippingCostEst						  as AMT_SHIPPING_COST_EST_EUR
	,ShipmentCostsSource                      as CD_SHIPMENT_COSTS_SOURCE
	,GrossShippingRevenue					  as AMT_GROSS_SHIPPING_REVENUE_EUR
	,GrossShippingRevenueForeignCurrency	  as AMT_GROSS_SHIPPING_REVENUE_FC
	,GrossPrice								  as AMT_GROSS_PRICE_EUR
	,GrossPriceForeignCurrency				  as AMT_GROSS_PRICE_FC
	,TaxPrice								  as AMT_TAX_PRICE_EUR
	,TaxDiscounts							  as AMT_TAX_DISCOUNTS_EUR
	,TaxFreight								  as AMT_TAX_FREIGHT_EUR
	,TaxTotal								  as AMT_TAX_TOTAL_EUR
	,TaxTotalPayable                          as AMT_TAX_TOTAL_PAYABLE_EUR
    ,TaxOutput                                as AMT_TAX_OUTPUT_EUR
	,MEKHedging								  as AMT_MEK_HEDGING_EUR
	,GTSMarkup								  as AMT_GTS_MARKUP
	,Discount								  as AMT_NET_DISCOUNT_EUR
	,DiscountForeignCurrency                  as AMT_NET_DISCOUNT_FC                                         
	,Currency								  as CD_CURRENCY
	, CASE WHEN FL_Intercompany=1 THEN Null ELSE CommercialTurnover	END					  as AMT_COMMERCIAL_TURNOVER_EUR
	, CASE WHEN FL_Intercompany=1 THEN Null ELSE Turnover END							  as AMT_TURNOVER_EUR
	, CASE WHEN FL_Intercompany=1 THEN Null ELSE OrderQuantity	END						  as VL_ORDER_QUANTITY
	, CASE WHEN FL_Intercompany=1 THEN Null ELSE ValueAddedTax	END						  as AMT_VALUE_ADDED_TAX_EUR
	, CASE WHEN FL_Intercompany=1 THEN Null ELSE OrderDiscounts	END						  as AMT_ORDER_DISCOUNTS_EUR
	, CASE WHEN FL_Intercompany=1 THEN Null ELSE OrderCharges	END						  as AMT_ORDER_CHARGES_EUR
	, CASE WHEN FL_Intercompany=1 THEN Null ELSE GrossOrderValue END					  as AMT_GROSS_ORDER_VALUE_EUR
	, CASE WHEN FL_Intercompany=1 THEN Null ELSE CancelledOrdersQuantityEst	END			  as VL_CANCELLED_ORDERS_QUANTITY_EST
	, CASE WHEN FL_Intercompany=1 THEN Null ELSE ReturnedQuantityEst END				  as VL_RETURNED_QUANTITY_EST
	, CASE WHEN FL_Intercompany=1 THEN Null ELSE CancelledOrderValueEst	END				  as AMT_CANCELLED_ORDER_VALUE_EST_EUR
	, CASE WHEN FL_Intercompany=1 THEN Null ELSE NetOrderQuantityEst END				  as VL_NET_ORDER_QUANTITY_EST
	, CASE WHEN FL_Intercompany=1 THEN Null ELSE RefundedOrderValueEst	END 			  as AMT_REFUNDED_ORDER_VALUE_EST_EUR
	, CASE WHEN FL_Intercompany=1 THEN Null ELSE ReturnOrderValueEst END				  as AMT_RETURN_ORDER_VALUE_EST_EUR
	, CASE WHEN FL_Intercompany=1 THEN Null ELSE NetOrderValueEst END					  as AMT_NET_ORDER_VALUE_EST_EUR
	, CASE WHEN FL_Intercompany=1 THEN Null ELSE RefundedQuantityEst END				  as VL_REFUNDED_QUANTITY_EST
	, CASE WHEN FL_Intercompany=1 THEN Null ELSE RevenueEst	 END						  as AMT_REVENUE_EST_EUR
	, CASE WHEN FL_Intercompany=1 THEN Null ELSE NetQuantityEst END						  as VL_NET_QUANTITY_EST
	, CASE WHEN FL_Intercompany=1 THEN Null ELSE NetProductCostEst END					  as AMT_NET_PRODUCT_COST_EST_EUR
	, CASE WHEN FL_Intercompany=1 THEN Null ELSE NetOrderContributionEst END			  as AMT_NET_ORDER_CONTRIBUTION_EST_EUR
	, CASE WHEN FL_Intercompany=1 THEN Null ELSE PC0 END								  as AMT_PC0_EUR
	, CASE WHEN FL_Intercompany=1 THEN Null ELSE DemurrageDetention END					  as AMT_DEMURRAGE_DETENTION_EUR
	, CASE WHEN FL_Intercompany=1 THEN Null ELSE Deadfreight END						  as AMT_DEADFREIGHT_EUR
	, CASE WHEN FL_Intercompany=1 THEN Null ELSE Kickbacks END							  as AMT_KICKBACKS_EUR
	, CASE WHEN FL_Intercompany=1 THEN Null ELSE [3rdPartyServices] END					  as AMT_3RD_PARTY_SERVICES_EUR
	, CASE WHEN FL_Intercompany=1 THEN Null ELSE RMA END								  as AMT_RMA_EUR
	, CASE WHEN FL_Intercompany=1 THEN Null ELSE Samples END							  as AMT_SAMPLES_EUR
	, CASE WHEN FL_Intercompany=1 THEN Null ELSE OtherCOGSEffectsEst END				  as AMT_OTHER_COGS_EFFECTS_EST_EUR
	, CASE WHEN FL_Intercompany=1 THEN Null ELSE DropShipmentCEOTRA9erArtikelEst END	  as AMT_DROPSHIPMENT_CEOTRA9ER_ARTIKEL_EST_EUR
	, CASE WHEN FL_Intercompany=1 THEN Null ELSE InboundFreightCostsEst END				  as AMT_INBOUND_FREIGHT_COST_EST_EUR
	, CASE WHEN FL_Intercompany=1 THEN Null ELSE POCancellation END						  as AMT_PO_CANCELLATION_EUR
	, CASE WHEN FL_Intercompany=1 THEN Null ELSE StockAdjustment END					  as AMT_STOCK_ADJUSTMENT_EUR
	, CASE WHEN FL_Intercompany=1 THEN Null ELSE FXHedgingImpactEst END					  as AMT_FX_HEDGING_IMPACT_EST_EUR
	, CASE WHEN FL_Intercompany=1 THEN Null ELSE COGSStockValueAdjustmentEst END		  as AMT_COGS_STOCK_VALUE_ADJUSTMENT_EST_EUR
	, CASE WHEN FL_Intercompany=1 THEN Null ELSE COGSOperationsEst END					  as AMT_COGS_OPERATIONS_EST_EUR
	, CASE WHEN FL_Intercompany=1 THEN Null ELSE PC1 END								  as AMT_PC1_EUR
	, CASE WHEN FL_Intercompany=1 THEN Null ELSE PC2 END								  as AMT_PC2_EUR
	, CASE WHEN FL_Intercompany=1 OR NUM_ITEM LIKE '9%' THEN Null ELSE HandlingInboundEst END					  as AMT_HANDLING_INBOUND_EST_EUR
	, CASE WHEN FL_Intercompany=1 OR NUM_ITEM LIKE '9%' THEN Null ELSE HandlingTransShippmentEst END			  as AMT_HANDLING_TRANS_SHIPPMENT_EST_EUR
	, CASE WHEN FL_Intercompany=1 OR NUM_ITEM LIKE '9%' THEN Null ELSE Packaging END							  as AMT_PACKAGING_EST_EUR
	, CASE WHEN FL_Intercompany=1 OR NUM_ITEM LIKE '9%' THEN Null ELSE HandlingOrdersEst END 					  as AMT_HANDLING_SHIPMENTS_EST_EUR
	, CASE WHEN FL_Intercompany=1 OR NUM_ITEM LIKE '9%' THEN Null ELSE CSHandlingClaims END					      as AMT_CUSTOMER_SERVICE_HANDLING_EST_EUR
	, CASE WHEN FL_Intercompany=1 OR NUM_ITEM LIKE '9%' THEN Null ELSE CSManagement END						      as AMT_CUSTOMER_SERVICE_OPEX_EST_EUR
	, CASE WHEN FL_Intercompany=1 OR NUM_ITEM LIKE '9%' THEN Null ELSE ShopMarketing END						  as AMT_SHOP_MARKETING_EUR
	, CASE WHEN FL_Intercompany=1 OR NUM_ITEM LIKE '9%' THEN Null ELSE AmazonMarketingCosts END				      as AMT_AMAZON_MARKETING_EUR
	, CASE WHEN FL_Intercompany=1 OR NUM_ITEM LIKE '9%' THEN Null ELSE TruckingTransShipmentEst END			      as AMT_TRUCKING_TRANS_SHIPMENT_EST_EUR
	, CASE WHEN FL_Intercompany=1 OR NUM_ITEM LIKE '9%' THEN Null ELSE MarketingMarketplacesEst END			      as AMT_MARKETING_MARKETPLACES_EST_EUR
	, CASE WHEN FL_Intercompany=1 OR NUM_ITEM LIKE '9%' THEN Null ELSE CommissionsMarketplaces END			      as AMT_COMMISSIONS_MARKETPLACES_EST_EUR
	, CASE WHEN FL_Intercompany=1 OR NUM_ITEM LIKE '9%' THEN Null ELSE CommissionsMarketplacesRefunds END		  as AMT_COMMISSIONS_MARKETPLACES_REFUNDS_EST_EUR
	, CASE WHEN FL_Intercompany=1 OR NUM_ITEM LIKE '9%' THEN Null ELSE Payments END							      as AMT_PAYMENTS_FEES_EST_EUR
	, CASE WHEN FL_Intercompany=1 OR NUM_ITEM LIKE '9%' THEN Null ELSE HandlingReturnsEst END					  as AMT_HANDLING_RETURNS_EST_EUR
	, CASE WHEN FL_Intercompany=1 OR NUM_ITEM LIKE '9%' THEN Null ELSE WarehousingRentEst END					  as AMT_WAREHOUSING_RENT_EST_EUR
	, CASE WHEN FL_Intercompany=1 OR NUM_ITEM LIKE '9%' THEN Null ELSE WarehousingOPEXEst END					  as AMT_WAREHOUSING_OPEX_EST_EUR
	, CASE WHEN FL_Intercompany=1						THEN Null ELSE ReplacementProductCostEst END			  as AMT_REPLACEMENT_PRODUCT_COST_EST_EUR
	, CASE WHEN FL_Intercompany=1						THEN Null ELSE ReplacementOrderQuantityEst END			  as AMT_REPLACEMENT_ORDER_QUANTITY_EST_EUR
	, CASE WHEN FL_Intercompany=1 OR NUM_ITEM LIKE '9%' THEN Null ELSE CommissionsAmazon END					  as AMT_COMMISSIONS_AMAZON_EST_EUR
	, CASE WHEN FL_Intercompany=1 OR NUM_ITEM LIKE '9%' THEN Null ELSE CommissionsAmazonRefunds END			      as AMT_COMMISSIONS_AMAZON_REFUNDS_EST_EUR
	, CASE WHEN FL_Intercompany=1 OR NUM_ITEM LIKE '9%' THEN Null ELSE WarehousingFBA END						  as AMT_WAREHOUSING_FBA_EST_EUR
	, CASE WHEN FL_Intercompany=1 OR NUM_ITEM LIKE '9%' THEN Null ELSE FulfillmentOutboundEst END				  as AMT_FULFILLMENT_OUTBOUND_EST_EUR
	, CASE WHEN FL_Intercompany=1 OR NUM_ITEM LIKE '9%' THEN Null ELSE MarketingFixedCost END					  as AMT_MARKETING_OPEX_EST_EUR
	, CASE WHEN FL_Intercompany=1 OR NUM_ITEM LIKE '9%' THEN Null ELSE AMT_PACKAGING_COST_DE_EST_EUR END          AS AMT_PACKAGING_COST_DE_EST_EUR
	, CASE WHEN FL_Intercompany=1 OR NUM_ITEM LIKE '9%' THEN Null ELSE AMT_PACKAGING_COST_ES_EST_EUR END          AS AMT_PACKAGING_COST_ES_EST_EUR
	, CASE WHEN FL_Intercompany=1 OR NUM_ITEM LIKE '9%' THEN Null ELSE AMT_PACKAGING_COST_FRA_EST_EUR END         AS AMT_PACKAGING_COST_FRA_EST_EUR
	, CASE WHEN FL_Intercompany=1 OR NUM_ITEM LIKE '9%' THEN Null ELSE AMT_ABJ_EST_EUR END                        AS AMT_ABJ_EST_EUR
	, CASE WHEN FL_Intercompany=1 OR NUM_ITEM LIKE '9%' THEN Null ELSE AMT_PRODUCT_LICENSES_EST	END               AS AMT_PRODUCT_LICENSES_EST
	, CASE WHEN FL_Intercompany=1 OR NUM_ITEM LIKE '9%' THEN Null ELSE AMT_TEXTILE_EST_EUR END                    AS AMT_TEXTILE_EST_EUR
	, CASE WHEN FL_Intercompany=1 OR NUM_ITEM LIKE '9%' THEN Null ELSE AMT_WEE_EST_EUR END                        AS AMT_WEE_EST_EUR
	, CASE WHEN FL_Intercompany=1 OR NUM_ITEM LIKE '9%' THEN Null ELSE AMT_TARIF_HT_FURNITURE_EST_EUR END         AS AMT_TARIF_HT_FURNITURE_EST_EUR
	, CASE WHEN FL_Intercompany=1 OR NUM_ITEM LIKE '9%' THEN Null ELSE AMT_BATTERIES_EST_EUR      END             AS AMT_BATTERIES_EST_EUR
	, CASE WHEN FL_Intercompany=1						THEN Null ELSE PC3 END								      as AMT_PC3_EUR
	, CASE WHEN FL_Intercompany=1 OR NUM_ITEM LIKE '9%' THEN Null ELSE AMT_REPACKAGING_EST_EUR END	              AS AMT_REPACKAGING_EST_EUR
	,CD_COUNTRY_GROUP_INVOICE
	,CD_COUNTRY_GROUP_DELIVERY
	,CASE WHEN FL_Intercompany=1 OR NUM_ITEM LIKE '9%' THEN Null ELSE AMT_ASL_EST_EUR END                         AS AMT_ASL_EST_EUR
	,CASE WHEN FL_Intercompany=1 OR NUM_ITEM LIKE '9%' THEN Null ELSE AMT_SWE_TAX_EST_EUR END                     AS AMT_SWE_TAX_EST_EUR
	,CASE WHEN FL_Intercompany=1 OR NUM_ITEM LIKE '9%' THEN Null ELSE AMT_ENVIRO_AND_LICENSE_COST_EST_EUR END	  AS AMT_ENVIRO_AND_LICENSE_COST_EST_EUR			
	,CASE WHEN FL_Intercompany=1 THEN Null ELSE [AMT_CANCELLED_ORDER_VALUE_EUR] END								  AS [AMT_CANCELLED_ORDER_VALUE_EUR]
	,CASE WHEN FL_Intercompany=1 THEN Null ELSE [VL_CANCELLED_ORDER_QUANTITY] END								  AS [VL_CANCELLED_ORDER_QUANTITY]            
	,CASE WHEN FL_Intercompany=1 THEN Null ELSE [AMT_NET_ORDER_VALUE_EUR] END									  AS [AMT_NET_ORDER_VALUE_EUR]                
	,CASE WHEN FL_Intercompany=1 THEN Null ELSE [AMT_NET_ORDER_VALUE_FULL_PRICE_EUR] END						  AS [AMT_NET_ORDER_VALUE_FULL_PRICE_EUR]     
	,CASE WHEN FL_Intercompany=1 THEN Null ELSE [VL_NET_ORDER_QUANTITY] END										  AS [VL_NET_ORDER_QUANTITY]     
	,CASE WHEN FL_Intercompany=1 THEN Null ELSE [AMT_NET_PRODUCT_COSTS_THEREOF_RETURN_MEK_EUR] END				  AS [AMT_NET_PRODUCT_COSTS_THEREOF_RETURN_MEK_EUR]              
	,[CD_GTS_PO_NO]
    ,[CD_GTS_PO_LINE]
--	,LOAD_TIMESTAMP							                                                                      as LOAD_TIMESTAMP
	--,GETDATE()																									  as [D_EFF_TO]	
	--,GETDATE()																						      as [D_EFF_DELETED]
	,FL_DELETED								                                                                      as FL_DELETED
	,[FL_SINGLE_ITEM]   
	,[CD_CANCELLED_DOCUMENT_NO]  
	,[CD_CANCELLED_DOCUMENT_LINE] 
	,[VL_REFUND_RATE]					  = RefundRate
	,[VL_RETURN_RATE]					  = [ReturnRate]
	,[VL_REPLACEMENT_RATE]				  = ReplacementProductCostEst_PreCal
	,[VL_DEPRETIATION_RATE]					= AMT_DEPRECIATIONEST_PRECALC_EUR
FROM CTE_SALES_L10;






END