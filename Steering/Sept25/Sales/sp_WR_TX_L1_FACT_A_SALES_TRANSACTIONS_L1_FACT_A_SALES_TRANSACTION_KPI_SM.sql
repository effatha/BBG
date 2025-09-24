CREATE PROC WR.[WR_TX_L1_FACT_A_SALES_TRANSACTIONS_L1_FACT_A_SALES_TRANSACTION_KPI_SM]
-- =============================================  
-- Author:      Helder Barbosa
-- Create Date: 2025-09-14
-- Description: Populates L1_FACT_A_SALES_TRANSACTION_KPI
-- 2025-09-14   v1:HBarbosa      :  initial version

-- ============================================= 
AS
BEGIN
	DECLARE @LOAD_START_DATE AS date 

	SET @LOAD_START_DATE = CAST(GETDATE () -1 as date)

	TRUNCATE TABLE [WR].[WR_L1_FACT_A_SALES_TRANSACTION_KPI_SM] 



;WITH CTE_ENVIRO as 
    (
	        SELECT 
				ID_ITEM,
				CD_COUNTRY_DELIVERY,
				NUM_YEAR,
				CD_CURRENCY,
				AMT_FEE_PER_UNIT = sum(AMT_FEE_PER_UNIT) 
			FROM [L1].[L1_DIM_A_ENVIRO_REST_UNIT_FEES]
            GROUP BY ID_ITEM,CD_COUNTRY_DELIVERY,NUM_YEAR,CD_CURRENCY
    )
,CTE_SALES_L1 AS
	(
			SELECT 
				ID_SALES_TRANSACTION								= fact.ID_SALES_TRANSACTION				
				,CD_SALES_TRANSACTION								= fact.CD_SALES_TRANSACTION										
				,CD_SOURCE_SYSTEM									= fact.CD_SOURCE_SYSTEM											
				,CD_SALES_PROCESS_ID																	
				,CD_SALES_PROCESS_LINE								= fact.CD_SALES_PROCESS_LINE										
				,CD_DOCUMENT_NO													
				,CD_DOCUMENT_LINE												
				,CD_DOCUMENT_ID_REFERENCE										
				,ID_COMPANY											= fact.ID_COMPANY												
				,D_CREATED											= fact.D_CREATED													
				,D_SALES_PROCESS									= fact.D_SALES_PROCESS											
				,D_DOCUMENT_CREATED									= fact.D_DOCUMENT_CREATED										
				,T_CANCELLATION_REASON								= fact.T_CANCELLATION_REASON										
				,FL_INCIDENT										= fact.FL_INCIDENT												
				,DT_CREATED														
				,CD_TYPE														
				,[ID_SALES_TRANSACTION_TYPE]						= fact.[ID_SALES_TRANSACTION_TYPE]								
				,ID_ITEM											= fact.ID_ITEM													
				,ID_ITEM_PARENT										= fact.ID_ITEM_PARENT											
				,CD_ITEM_TYPE										= fact.CD_ITEM_TYPE												
				,ID_SALES_CHANNEL									= fact.ID_SALES_CHANNEL											
				,CD_FULFILLMENT										= fact.CD_FULFILLMENT											
				,CD_CUSTOMER													
				,CD_CUSTOMER_SERVICE_AGENT                                      
				,T_CREATION_USERNAME                                            
				,CD_MARKET_ORDER_ID												
				,CD_PAYMENT_METHOD												
				,CD_STORAGE_LOCATION								= fact.CD_STORAGE_LOCATION										
				,T_STORAGE_LOCATION									= ISNULL(fact.T_REVISED_LOCATION,fact.T_STORAGE_LOCATION)		
				,CD_COUNTRY_INVOICE									= fact.CD_COUNTRY_INVOICE										
				,CD_ZIP_INVOICE													
				,T_CITY_INVOICE													
				,CD_COUNTRY_DELIVERY								= fact.CD_COUNTRY_DELIVERY										
				,CD_ZIP_DELIVERY									= fact.CD_ZIP_DELIVERY			
				,T_CITY_DELIVERY									= fact.T_CITY_DELIVERY		
				,CD_COUNTRY_ORDER									= fact.CD_COUNTRY_ORDER			
				,CD_ZIP_ORDER										= fact.CD_ZIP_ORDER			
				,T_CITY_ORDER										= fact.T_CITY_ORDER			
				,VL_ITEM_QUANTITY									= fact.VL_ITEM_QUANTITY			
				,VL_ITEM_PARENT_QUANTITY                            = fact.VL_ITEM_PARENT_QUANTITY            
				,AMT_NET_SHIPPING_REVENUE_EUR						= fact.AMT_NET_SHIPPING_REVENUE_EUR			
				,AMT_NET_PRICE_EUR									= fact.AMT_NET_PRICE_EUR			
				,AMT_NET_PRICE_FC									= fact.AMT_NET_PRICE_FC 			
				,AMT_SHIPPING_COST_EST_EUR							= fact.AMT_SHIPPING_COST_EST_EUR		
				,CD_SHIPMENT_COSTS_SOURCE                           = fact.CD_SHIPMENT_COSTS_SOURCE             
				,AMT_GROSS_SHIPPING_REVENUE_EUR						= fact.AMT_GROSS_SHIPPING_REVENUE_EUR			
				,AMT_GROSS_SHIPPING_REVENUE_FC						= fact.AMT_GROSS_SHIPPING_REVENUE_FC			
				,AMT_GROSS_PRICE_EUR								= fact.AMT_GROSS_PRICE_EUR			
				,AMT_GROSS_PRICE_FC									= fact.AMT_GROSS_PRICE_FC			
				,AMT_TAX_PRICE_EUR									= fact.AMT_TAX_PRICE_EUR			
				,AMT_TAX_DISCOUNTS_EUR								= fact.AMT_TAX_DISCOUNTS_EUR			
				,AMT_TAX_FREIGHT_EUR								= fact.AMT_TAX_FREIGHT_EUR			
				,AMT_TAX_TOTAL_EUR									= fact.AMT_TAX_TOTAL_EUR			
				,AMT_TAX_TOTAL_PAYABLE_EUR                          = fact.AMT_TAX_TOTAL_PAYABLE_EUR            
				,AMT_TAX_TOTAL_PAYABLE_FC                           = fact.AMT_TAX_TOTAL_PAYABLE_FC            
				,AMT_TAX_OUTPUT_EUR                                 = fact.AMT_TAX_OUTPUT_EUR           
				,AMT_TAX_OUTPUT_FC                                  = fact.AMT_TAX_OUTPUT_FC            
				,AMT_MEK_HEDGING_EUR								= fact.AMT_MEK_HEDGING_EUR			
				,AMT_GTS_MARKUP										= fact.AMT_GTS_MARKUP			
				,AMT_NET_DISCOUNT_EUR								= fact.AMT_NET_DISCOUNT_EUR		
				,AMT_NET_DISCOUNT_FC                                = fact.AMT_NET_DISCOUNT_FC       
				,CD_CURRENCY										= CD_CURRENCY	
				,NUM_ITEM											= item.NUM_ITEM
				,CD_BILLING_CATEGORY								= fact.CD_BILLING_CATEGORY	
				,D_BILLING_DATE										= fact.D_BILLING_DATE					
				,CD_BILLING_POSTING_STATUS							= fact.CD_BILLING_POSTING_STATUS		
				,CD_PAYER											= fact.CD_PAYER						
				,VL_BILLING_QUANTITY								= fact.VL_BILLING_QUANTITY			
				,VL_EXCHANGE_RATE									= fact.VL_EXCHANGE_RATE				
				,CD_SALES_DOCUMENT_NO								= fact.CD_SALES_DOCUMENT_NO           
				,D_UPDATED											= fact.D_UPDATED						
				,CD_REJECTION_STATUS								= fact.CD_REJECTION_STATUS			
				,D_CANCELLATION										= fact.D_CANCELLATION	
				,[CD_RETURN_REASON]									= fact.[CD_RETURN_REASON]         
				,[T_RETURN_REASON]									= fact.[T_RETURN_REASON] 
				,AMT_TOTAL_NET_PRICE_EUR							= fact.AMT_TOTAL_NET_PRICE_EUR
				,AMT_TOTAL_NET_PRICE_FC								= fact.AMT_TOTAL_NET_PRICE_FC
				,AMT_TAX_REVERSED_EUR								= fact.AMT_TAX_REVERSED_EUR
				,AMT_TAX_REVERSED_FC								= fact.AMT_TAX_REVERSED_FC
				,AMT_TOTAL_PRICE_EUR								= fact.AMT_TOTAL_PRICE_EUR
				,AMT_TOTAL_PRICE_FC									= fact.AMT_TOTAL_PRICE_FC
				,CD_PRECEDING_DOCUMENT_NO							= fact.CD_PRECEDING_DOCUMENT_NO 
				,CD_LINKED_DOCUMENT_NO								= fact.CD_LINKED_DOCUMENT_NO 
				,AMT_NET_SHIPPING_REVENUE_FC						= fact.AMT_NET_SHIPPING_REVENUE_FC
				,CD_CARRIER											= fact.CD_CARRIER
				,VL_REFUND_RATE										= fact.VL_REFUND_RATE 					
				,VL_RETURN_RATE										= fact.VL_RETURN_RATE					
        		,VL_REPLACEMENT_RATE								= fact.VL_REPLACEMENT_RATE 	
				,CD_REFUND_RATE_SOURCE								= fact.CD_REFUND_RATE_SOURCE 
				,CD_RETURN_RATE_SOURCE								= fact.CD_RETURN_RATE_SOURCE 
				,CD_REPLACEMENT_RATE_SOURCE							= fact.CD_REPLACEMENT_RATE_SOURCE 
			
				--kpi parameters
				,VL_GROSS_ORDER_VALUE_PARAM							= kpi.VL_GROSS_ORDER_VALUE_PARAM
				,VL_CANCELLED_ORDERS_QUANTITY_EST_PARAM				= kpi.VL_CANCELLED_ORDERS_QUANTITY_EST_PARAM
				,VL_CANCELLED_ORDER_VALUE_EST_PARAM					= kpi.VL_CANCELLED_ORDER_VALUE_EST_PARAM
				,VL_NET_ORDER_QUANTITY_EST_PARAM					= kpi.VL_NET_ORDER_QUANTITY_EST_PARAM
				,VL_REFUNDED_ORDER_VALUE_EST_PARAM					= kpi.VL_REFUNDED_ORDER_VALUE_EST_PARAM
				,VL_RETURN_ORDER_VALUE_EST_PARAM					= kpi.VL_RETURN_ORDER_VALUE_EST_PARAM
				,VL_NET_ORDER_VALUE_EST_PARAM						= kpi.VL_NET_ORDER_VALUE_EST_PARAM
				,VL_RETURNED_QUANTITY_EST_PARAM						= kpi.VL_RETURNED_QUANTITY_EST_PARAM
				,VL_REFUNDED_QUANTITY_EST_PARAM						= kpi.VL_REFUNDED_QUANTITY_EST_PARAM
				,VL_NET_QUANTITY_EST_PARAM							= kpi.VL_NET_QUANTITY_EST_PARAM
				,VL_REVENUE_EST_PARAM								= kpi.VL_REVENUE_EST_PARAM
				,VL_PC0_PARAM										= kpi.VL_PC0_PARAM
				,VL_CANCELLED_ORDER_VALUE_PARAM						= kpi.VL_CANCELLED_ORDER_VALUE_PARAM
				,VL_CANCELLED_ORDER_QUANTITY_PARAM					= kpi.VL_CANCELLED_ORDER_QUANTITY_PARAM	
				,VL_NET_ORDER_VALUE_FULL_PRICE_PARAM				= kpi.VL_NET_ORDER_VALUE_FULL_PRICE_PARAM	
				,VL_NETORDER_QUANTITY_PARAM							= kpi.VL_NETORDER_QUANTITY_PARAM    
				,VL_NET_ORDER_VALUE_PARAM							= kpi.VL_NET_ORDER_VALUE_PARAM
				,VL_NET_PRODUCT_COSTS_THEREOF_RETURN_MEK_PARAM		= kpi.VL_NET_PRODUCT_COSTS_THEREOF_RETURN_MEK_PARAM

				--KPI's
				,AMT_COMMERCIAL_TURNOVER_EUR							= (ISNULL(VL_ITEM_QUANTITY,0) *1000) * VL_COMMERCIAL_TURNOVER_PARAM		
				,AMT_TURNOVER_AMT										= (ISNULL(AMT_GROSS_PRICE_EUR,0)) * VL_TURNOVER_PARAM	
			,(ISNULL(VL_ITEM_QUANTITY,0)   )* VL_ORDER_QUANTITY_PARAM				AS OrderQuantity
			,(ABS(ISNULL(AMT_TAX_PRICE_EUR,0))   )* VL_VALUE_ADDED_TAX_PARAM		AS ValueAddedTax
			,(ABS(ISNULL(AMT_NET_DISCOUNT_EUR,0))   )* VL_ORDER_DISCOUNTS_PARAM		AS OrderDiscounts
			,(ISNULL(AMT_NET_SHIPPING_REVENUE_EUR,0)   )* VL_ORDER_CHARGES_PARAM	AS OrderCharges
			,ISNULL(fact.VL_REFUND_RATE,rrr.VL_REFUND_RATE)											AS RefundRate
			,ISNULL(cll.VL_RATE,0)													AS CancellRate
			,ISNULL(fact.VL_RETURN_RATE,rrr.VL_RETURN_RATE)											AS ReturnRate
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
			,ISNULL(fact.VL_REPLACEMENT_RATE,rrr.VL_REPLACEMENT_RATE)							AS ReplacementProductCostEst_PreCal
			,ISNULL(fact.VL_REPLACEMENT_RATE,rrr.VL_REPLACEMENT_RATE)					AS ReplacementOrderQuantityEst_PreCal
	        ,dimchannel.[CD_CHANNEL_GROUP_1]						AS CD_CHANNEL_GROUP_1
			,dimchannel.[CD_CHANNEL_GROUP_3]						AS CD_CHANNEL_GROUP_3

	        ,c_amaz.[VL_COMMISSIONS_ORDER_RATE]						AS VL_COMMISSIONS_ORDER_RATE
			, CASE 
				WHEN dimchannel.CD_CHANNEL_GROUP_1='Amazon' AND fact.CD_FULFILLMENT='FBA' THEN
					((item.VL_VOLUME * ISNULL(WHFBA.AMT_FBA_WAREHOUSE_COST_M3,0)) 
						/(CASE WHEN item.cd_unit_volume='CCM' THEN 1000000 WHEN item.cd_unit_volume='M3' THEN 1 END)) 
						* WHFBA.VL_FBA_STOCK_TURNOVER_M * (1 + WHFBA.VL_RATE) * (1 + WHFBA.VL_LONG_TERM_SURCHARGE_RATE)
				ELSE NULL END										AS WarehousingFBA
			,cfm.VL_MARKETING_FIXED_COST_RATE						AS VL_MARKETING_FIXED_COST_RATE
			,GREATEST(fact.[D_EFF_FROM],kpi.[D_EFF_FROM],item.[D_EFF_FROM], cll.[D_EFF_FROM],
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
		
			,cmi.INVOICECOUNTRYGROUP								AS CD_COUNTRY_GROUP_INVOICE
			,cmd.DELIVERYCOUNTRYGROUP								AS CD_COUNTRY_GROUP_DELIVERY
			,item.VL_GROSS_WEIGHT
			,fr.VL_FX_RATE
			,fact.[CD_GTS_PO_NO]
			,fact.[CD_GTS_PO_LINE]
			,factor.[AMT_CORRECTION_FACTOR_ORDER]
            ,factor.[AMT_CORRECTION_FACTOR_RETURN]
            ,factor.[AMT_CORRECTION_FACTOR_REPLACEMENT]
			,[FL_SINGLE_ITEM]   
			,[CD_CANCELLED_DOCUMENT_NO]  
	        ,[CD_CANCELLED_DOCUMENT_LINE] 
			,env.AMT_FEE_PER_UNIT * COALESCE(enviro_rate.VL_FX_RATE, 1)* kpi.VL_ENVIRO_EST_PARAM AS EnviroRestUnitFee_PreCalc
            ,repack.AMT_FEE_PER_UNIT * COALESCE(enviro_rate.VL_FX_RATE, 1) * 0.025 * kpi.VL_ENVIRO_EST_PARAM AS Repackaging_PreCalc
			,fact.T_PRODUCT_HIERARCHY_2
			FROM [L1].[L1_FACT_A_SALES_TRANSACTION] fact 
		LEFT JOIN [L1].[L1_DIM_A_SALES_TRAN_KPI_MATRIX] kpi
			ON kpi.ID_SALES_TRANSACTION_TYPE = fact.ID_SALES_TRANSACTION_TYPE
		LEFT JOIN [L1].[L1_DIM_A_ITEM] item 
			ON item.[ID_ITEM]=fact.ID_ITEM
		LEFT JOIN [L1].[L1_DIM_A_COMPANY] dimcomp
			 on dimcomp.ID_COMPANY=fact.ID_COMPANY
		LEFT JOIN [L0].[L0_MI_COUNTRY_MAPPING] cmi
			ON fact.CD_COUNTRY_INVOICE = cmi.COUNTRY
		LEFT JOIN L1.L1_DIM_A_ORDER_CANCELLATION_VALUES cll  
			on fact.D_CREATED BETWEEN cll.D_VALID_FROM AND cll.D_VALID_TO
			and cmi.INVOICECOUNTRYGROUP=cll.CD_COUNTRY_INVOICE_GROUP
			and fact.T_PRODUCT_HIERARCHY_2 =cll.[T_PRODUCT_HIERARCHY_2]
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
			AND dimchannel.CD_CHANNEL_COUNTRY = c_amaz.CD_CHANNEL_COUNTRY
	        AND fact.D_CREATED BETWEEN c_amaz.D_VALID_FROM AND c_amaz.D_VALID_TO
		LEFT JOIN [L1].[L1_DIM_A_WAREHOUSING_FBA] WHFBA
			ON fact.[D_CREATED] BETWEEN WHFBA.D_VALID_FROM AND WHFBA.D_VALID_TO
			AND fact.CD_SIZE_BRACKET_FBA = WHFBA.CD_SIZE_BRACKET_FBA
		LEFT JOIN [L1].[L1_DIM_A_MARKETING_FIXED_COST] cfm
	        on fact.[D_CREATED] between cfm.D_VALID_FROM and cfm.D_VALID_TO
	        and dimchannel.[CD_CHANNEL_GROUP_1] = cfm.CD_CHANNEL_GROUP_1
	    LEFT JOIN [L0].[L0_MI_COUNTRY_MAPPING] cmd
			ON fact.CD_COUNTRY_DELIVERY = cmd.COUNTRY
					--join fx rate
		 LEFT JOIN [L1].[L1_FACT_F_FX_RATE] fr
			ON fact.cd_currency=fr.cd_currency
			AND Year(fact.D_CREATED)=Year(fr.D_EFFECTIVE)
			AND Month(fact.D_CREATED)=Month(fr.D_EFFECTIVE)
			--join fulfillment shipping factor
		LEFT JOIN L1.L1_DIM_A_FULFILLMENT_SHIPPING_FACTOR factor
		ON fact.CD_SIZE_BRACKET = factor.CD_SIZE_BRACKET
		AND fact.CD_FULFILLMENT = factor.CD_FULFILLMENT
		AND ISNULL(fact.T_REVISED_LOCATION,fact.T_STORAGE_LOCATION) = factor.T_STORAGE_LOCATION
		AND cmd.DELIVERYCOUNTRYGROUP = factor.[CD_COUNTRY_DELIVERY_GROUP]
		AND fact.D_CREATED BETWEEN factor.D_VALID_FROM AND factor.D_VALID_TO 
		--join enviro
		LEFT JOIN  CTE_ENVIRO env
        ON fact.ID_ITEM = env.ID_ITEM
        AND fact.CD_COUNTRY_DELIVERY = env.CD_COUNTRY_DELIVERY
       -- AND YEAR(fact.D_CREATED) = env.NUM_YEAR
		--join enviro for repackacing
		LEFT JOIN [L1].[L1_DIM_A_ENVIRO_REST_UNIT_FEES] repack
        ON fact.ID_ITEM = repack.ID_ITEM
        AND fact.CD_COUNTRY_DELIVERY = repack.CD_COUNTRY_DELIVERY
     --   AND YEAR(fact.D_CREATED) = repack.NUM_YEAR
		AND repack.CD_ENVIRO_CATEGORY = 'Packaging'
		--join fx rate for enviro
		LEFT JOIN [L1].[L1_FACT_F_FX_RATE] enviro_rate
			ON env.cd_currency=enviro_rate.cd_currency
			AND Year(fact.D_CREATED)=Year(enviro_rate.D_EFFECTIVE)
			AND Month(fact.D_CREATED)=Month(enviro_rate.D_EFFECTIVE)

		LEFT JOIN [L1].[L1_FACT_A_NOV_CLAIM_RATES] rrr
			ON rrr.id_item = fact.ID_ITEM
			AND fact.D_CREATED BETWEEN rrr.d_valid_from and rrr.d_valid_to
			AND (rrr.CD_COUNTRY_INVOICE_GROUP is null OR rrr.CD_COUNTRY_INVOICE_GROUP = cmi.INVOICECOUNTRYGROUP)
			AND (rrr.CD_COUNTRY_DELIVERY IS null OR rrr.CD_COUNTRY_DELIVERY = fact.CD_COUNTRY_DELIVERY)
			AND (rrr.CD_CHANNEL_GROUP_3 is null OR REPLACE(rrr.CD_CHANNEL_GROUP_3,' ','') = REPLACE(dimchannel.CD_CHANNEL_GROUP_3,' ',''))   
		WHERE 
			(item.NUM_ITEM NOT LIKE '7%' OR ID_ITEM_PARENT IS NOT NULL )
			AND item.NUM_ITEM NOT LIKE '6%'
			AND fact.D_CREATED>=@LOAD_START_DATE
			AND fact.CD_TYPE IN ('ZAA','ZKE','ZAZ')
			--AND fact.D_CREATED >= '2024-01-01'
			and isnull (FL_INCIDENT,'N')<>'Y'
			and dimchannel.CD_CHANNEL_GROUP_1 not in ('Intercompany', 'Mandanten')
			and dimchannel.CD_CHANNEL_GROUP_1 is not null
		 
	),
	CTE_SALES_L2 AS 
	(
		SELECT sales.*
			,(Turnover * [PCT_COMMISSIONS_MARKETPLACES])														AS CommissionsMarketplaces
			,(Turnover - ValueAddedTax - OrderDiscounts + OrderCharges) * VL_GROSS_ORDER_VALUE_PARAM			AS GrossOrderValue
			,(OrderQuantity * CancellRate)* VL_CANCELLED_ORDERS_QUANTITY_EST_PARAM								AS CancelledOrdersQuantityEst
			,(DemurrageDetention+Deadfreight+Kickbacks+[3rdPartyServices]+RMA+Samples+OtherCOGSEffectsEst+DropShipmentCEOTRA9erArtikelEst+InboundFreightCostsEst+POCancellation+StockAdjustment) AS COGSOperationsEst
		    ,(AMT_HANDLING_RETURNS_COST_EUR * ReturnRate)														AS HandlingReturnsOrders_calc
			,(AMT_HANDLING_RETURNS_COST_EUR * ReturnRate * 0.01)												AS HandlingRemovalsFBA_calc
	        ,CASE WHEN CD_CHANNEL_GROUP_1 = 'Amazon' then Turnover*VL_COMMISSIONS_ORDER_RATE ELSE NULL END		AS CommissionsAmazon
			,(ISNULL(Turnover,0) - ISNULL(OrderDiscounts,0) + ISNULL(OrderCharges,0)) AS TurnoverWithDiscounts  
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
				,(NetOrderQuantityEst - ReturnedQuantityEst+ReplacementOrderQuantityEst)*EnviroRestUnitFee_PreCalc as EnviroRestUnitFee
				,(NetOrderQuantityEst - ReturnedQuantityEst+ReplacementOrderQuantityEst)*Repackaging_PreCalc as Repackaging
		FROM CTE_SALES_L4 sales
	)
	,
	CTE_SALES_L6 AS 
	(
		SELECT sales.*
				,(RevenueEst * [PCT_PAYMENTS_ORDER])																	AS Payments

				 ,(RevenueEst - NetProductCostEst - ((ReplacementProductCostEst_PreCal * NetProductCostEst))) * VL_PC0_PARAM				AS PC0
				 ,(ShippingCostsInvoicedEst+ShippingCostsReturnedEst+ShippingCostsReplacedEst)										        AS FulfillmentOutboundEst
				 ,(ReplacementProductCostEst_PreCal * NetProductCostEst)																	AS ReplacementProductCostEst
				 ,ISNULL(EnviroRestUnitFee,0)+ISNULL(Repackaging,0)                                                                         AS AMT_ENVIRO_AND_LICENSE_COST_EST_EUR
				
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
						,CASE WHEN NUM_ITEM NOT LIKE '9%' THEN
				        (PC1 - 
						(ISNULL(HandlingInboundEst,0)+ISNULL(HandlingTransShippmentEst,0)+ISNULL(HandlingReturnsEst,0)+ISNULL(TruckingTransShipmentEst,0)+ISNULL(WarehousingFBA,0))	---FulfilmentInbound
						-ISNULL(FulfillmentOutboundEst,0)
						- (ISNULL(CommissionsMarketplaces,0)-ISNULL(CommissionsMarketplacesRefunds,0)+ISNULL(CommissionsAmazon,0)-ISNULL(CommissionsAmazonRefunds,0)) ---Commissions
						- (ISNULL(MarketingMarketplacesEst,0)+ISNULL(ShopMarketing,0)+ISNULL(AmazonMarketingCosts,0)) --Marketing Performance - still missing amazon marketing 713
						- (ISNULL(CSHandlingClaims,0)) 
						- (ISNULL(Packaging,0))
						- (ISNULL(HandlingOrdersEst,0)) 
						- (ISNULL(Payments,0)) 
					- ISNULL(EnviroRestUnitFee,0)
					- ISNULL(Repackaging,0)) * VL_PC2_PARAM ELSE PC1 END AS PC2
		FROM CTE_SALES_L7 sales
	)
	,
	CTE_SALES_L09 AS 
	(
		SELECT sales.*
				 ,CASE WHEN NUM_ITEM NOT LIKE '9%' THEN
				 (PC2 - ISNULL(WarehousingRentEst,0) - ISNULL(WarehousingOPEXEst,0) - ISNULL(CSManagement,0)
						- ISNULL(MarketingFixedCost,0)
					)  * VL_PC3_PARAM ELSE PC1 END AS PC3		
		FROM CTE_SALES_L8 sales
	),



		CTE_SALES_L10 AS 
	(
		SELECT 	sales.*
		,AMT_MEK_TO_CUSTOMER_EST_EUR			= CASE WHEN Quantity <> 0 
													THEN (((NetOrderQuantityEst) * (ISNULL(MEKHedging,0)-ISNULL(GTSMarkup,0)) )/ISNULL(Quantity,1)) * [VL_NET_QUANTITY_EST_PARAM]  
													ELSE 0 END	
		,AMT_MEK_FROM_CUSTOMER_EST_EUR			= CASE WHEN Quantity <> 0 
													THEN (((ReturnedQuantityEst) * (ISNULL(MEKHedging,0)-ISNULL(GTSMarkup,0)) )/ISNULL(Quantity,1)) * [VL_NET_QUANTITY_EST_PARAM]  
													ELSE 0 END	
		,AMT_MEK_REPLACEMENT_EST_EUR			= CASE WHEN Quantity <> 0 
													THEN (((ReplacementOrderQuantityEst) * (ISNULL(MEKHedging,0)-ISNULL(GTSMarkup,0)) )/ISNULL(Quantity,1)) * [VL_NET_QUANTITY_EST_PARAM]  
													ELSE 0 END
		,AMT_MEK_DEPRECIATION_EST_EUR 			= CASE WHEN Quantity <> 0 
													THEN (((ReturnedQuantityEst * dep.VL_RATE) * (ISNULL(MEKHedging,0)-ISNULL(GTSMarkup,0)) )/ISNULL(Quantity,1)) * [VL_NET_QUANTITY_EST_PARAM]  
													ELSE 0 END
		,AMT_MARKETING_ATTRIBUTION_EST_EUR		= NetOrderValueEst * mkt.MARKETINGRATE
		,AMT_COMMISSIONS_SALE_EST_EUR			= ISNULL(CommissionsMarketplaces,0) + ISNULL(CommissionsAmazon,0)
		,AMT_COMMISSIONS_REFUNDS_EST_EUR		= ISNULL(CommissionsAmazonRefunds,0)+ISNULL(CommissionsMarketplacesRefunds,0)
		,AMT_COMMISSIONS_EST_EUR				= (ISNULL(CommissionsMarketplaces,0)-ISNULL(CommissionsMarketplacesRefunds,0)+ISNULL(CommissionsAmazon,0)-ISNULL(CommissionsAmazonRefunds,0))

		FROM CTE_SALES_L09 sales
		LEFT JOIN [L0].[L0_MI_BUSINESS_PLAN_MARKETING_RATES] mkt
		on REPLACE(mkt.[CHANNELGROUP3],' ','') = REPLACE(sales.[CD_CHANNEL_GROUP_3],' ','')
			and MONTH(sales.TransactionDate) = MONTH(mkt.[MONTH])
			and YEAR(sales.TransactionDate) = YEAR(mkt.[MONTH])
		LEFT JOIN [L1].[L1_DIM_A_DEPRECIATION_VALUES] dep
			on sales.TransactionDate between dep.D_VALID_FROM and dep.D_VALID_TO
				AND dep.T_PRODUCT_HIERARCHY_2 = sales.T_PRODUCT_HIERARCHY_2
				and dep.T_STORAGE_LOCATION = sales.StorageLocation

	),
	CTE_SALES_L11 AS 
	(
		SELECT sales.*,

		AMT_FULL_NET_PRODUCT_COST_EST_EUR =  ISNULL(AMT_MEK_TO_CUSTOMER_EST_EUR,0) - ISNULL(AMT_MEK_FROM_CUSTOMER_EST_EUR,0) + ISNULL(AMT_MEK_REPLACEMENT_EST_EUR,0) +ISNULL(AMT_MEK_DEPRECIATION_EST_EUR,0) ,
		AMT_STEERING_MARGIN_EST_EUR =  ISNULL(RevenueEst,0)
					- (ISNULL(AMT_MEK_TO_CUSTOMER_EST_EUR,0) - ISNULL(AMT_MEK_FROM_CUSTOMER_EST_EUR,0) + ISNULL(AMT_MEK_REPLACEMENT_EST_EUR,0) +ISNULL(AMT_MEK_DEPRECIATION_EST_EUR,0)) -- Net product Costs
					- ISNULL(AMT_MARKETING_ATTRIBUTION_EST_EUR,0) 
					- ISNULL(AMT_COMMISSIONS_EST_EUR,0) 
					- ISNULL(Payments,0) 
					- ISNULL(EnviroRestUnitFee,0)
					- ISNULL(Repackaging,0)
					- ISNULL(FulfillmentOutboundEst,0),   ----(ShippingCostsInvoicedEst+ShippingCostsReturnedEst+ShippingCostsReplacedEst)
		[AMT_GROSS_MARGIN_EST_EUR] = ISNULL(RevenueEst,0)
					- (
							ISNULL(AMT_MEK_TO_CUSTOMER_EST_EUR,0) - ISNULL(AMT_MEK_FROM_CUSTOMER_EST_EUR,0) + ISNULL(AMT_MEK_REPLACEMENT_EST_EUR,0) +ISNULL(AMT_MEK_DEPRECIATION_EST_EUR,0)
							)
		FROM CTE_SALES_L10 sales 
	
	
	)
	INSERT INTO  [TEST].[L1_FACT_A_SALES_TRANSACTION_KPI_SM]
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
		,AMT_TAX_TOTAL_PAYABLE_FC
        ,AMT_TAX_OUTPUT_EUR
		,AMT_TAX_OUTPUT_FC
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
		,AMT_PC3_EUR
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
		,CD_COUNTRY_GROUP_INVOICE
		,CD_COUNTRY_GROUP_DELIVERY
		,AMT_ENVIRO_REST_UNIT_FEE_EUR
	    ,AMT_REPACKAGING_EUR
		,[AMT_CANCELLED_ORDER_VALUE_EUR]
		,[VL_CANCELLED_ORDER_QUANTITY]            
		,[AMT_NET_ORDER_VALUE_EUR]                
		,[AMT_NET_ORDER_VALUE_FULL_PRICE_EUR]     
		,[VL_NET_ORDER_QUANTITY]          
		,AMT_NET_PRODUCT_COSTS_THEREOF_RETURN_MEK_EUR
		,[CD_GTS_PO_NO]
		,[CD_GTS_PO_LINE]
		--,LOAD_TIMESTAMP
	    ,[D_EFF_TO]
	    ,[D_EFF_DELETED]
		,D_EFF_FROM
		,FL_DELETED
		,FL_SINGLE_ITEM 
		,[CD_CANCELLED_DOCUMENT_NO]  
	    ,[CD_CANCELLED_DOCUMENT_LINE] 
		,AMT_TOTAL_NET_PRICE_EUR
		,AMT_TOTAL_NET_PRICE_FC
		,AMT_TAX_REVERSED_EUR
		,AMT_TAX_REVERSED_FC
		,AMT_TOTAL_PRICE_EUR
		,AMT_TOTAL_PRICE_FC
		,CD_PRECEDING_DOCUMENT_NO 
        ,CD_LINKED_DOCUMENT_NO 
		,AMT_ENVIRO_AND_LICENSE_COST_EST_EUR
		,AMT_NET_SHIPPING_REVENUE_FC
        ,CD_CARRIER
		,VL_REFUND_RATE 					
	    ,VL_RETURN_RATE					
	    ,VL_REPLACEMENT_RATE 	
		,CD_REFUND_RATE_SOURCE 
        ,CD_RETURN_RATE_SOURCE 
        ,CD_REPLACEMENT_RATE_SOURCE 
		,AMT_MEK_TO_CUSTOMER_EST_EUR 
		,AMT_MEK_FROM_CUSTOMER_EST_EUR
		,AMT_MEK_REPLACEMENT_EST_EUR 
		,AMT_MEK_DEPRECIATION_EST_EUR 
		,AMT_MARKETING_ATTRIBUTION_EST_EUR
		,AMT_COMMISSIONS_EST_EUR
		,AMT_COMMISSIONS_SALE_EST_EUR
		,AMT_COMMISSIONS_REFUNDS_EST_EUR
		,AMT_STEERING_MARGIN_EST_EUR
		,AMT_FULL_NET_PRODUCT_COST_EST_EUR
		,AMT_SHIPPING_COST_INVOICED_EST 
		,AMT_SHIPPING_COST_RETURNED_EST 
		,AMT_SHIPPING_COST_REPLACED_EST 
		,AMT_GROSS_MARGIN_EST_EUR
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
	,TaxTotalPayableForeignCurrency           as AMT_TAX_TOTAL_PAYABLE_FC
    ,TaxOutput                                as AMT_TAX_OUTPUT_EUR
	,TaxOutputForeignCurrency                 as AMT_TAX_OUTPUT_FC
	,MEKHedging								  as AMT_MEK_HEDGING_EUR
	,GTSMarkup								  as AMT_GTS_MARKUP
	,Discount								  as AMT_NET_DISCOUNT_EUR
	,DiscountForeignCurrency                  as AMT_NET_DISCOUNT_FC                                         
	,Currency								  as CD_CURRENCY
	, CASE WHEN FL_Intercompany=1 THEN Null ELSE CommercialTurnover	END					  as AMT_COMMERCIAL_TURNOVER_EUR
	, CASE WHEN FL_Intercompany=1 THEN Null ELSE TurnoverWithDiscounts END							  as AMT_TURNOVER_EUR
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
	, CASE WHEN FL_Intercompany=1 THEN Null ELSE PC3 END								  as AMT_PC3_EUR
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
	,CD_COUNTRY_GROUP_INVOICE
	,CD_COUNTRY_GROUP_DELIVERY
	,CASE WHEN FL_Intercompany=1 OR NUM_ITEM LIKE '9%' THEN Null ELSE EnviroRestUnitFee END	                      AS AMT_ENVIRO_REST_UNIT_FEE_EUR
	,CASE WHEN FL_Intercompany=1 OR NUM_ITEM LIKE '9%' THEN Null ELSE Repackaging END	                          AS AMT_REPACKAGING_EUR
	,CASE WHEN FL_Intercompany=1 THEN Null ELSE [AMT_CANCELLED_ORDER_VALUE_EUR] END								  AS [AMT_CANCELLED_ORDER_VALUE_EUR]
	,CASE WHEN FL_Intercompany=1 THEN Null ELSE [VL_CANCELLED_ORDER_QUANTITY] END								  AS [VL_CANCELLED_ORDER_QUANTITY]            
	,CASE WHEN FL_Intercompany=1 THEN Null ELSE [AMT_NET_ORDER_VALUE_EUR] END									  AS [AMT_NET_ORDER_VALUE_EUR]                
	,CASE WHEN FL_Intercompany=1 THEN Null ELSE [AMT_NET_ORDER_VALUE_FULL_PRICE_EUR] END						  AS [AMT_NET_ORDER_VALUE_FULL_PRICE_EUR]     
	,CASE WHEN FL_Intercompany=1 THEN Null ELSE [VL_NET_ORDER_QUANTITY] END										  AS [VL_NET_ORDER_QUANTITY]     
	,CASE WHEN FL_Intercompany=1 THEN Null ELSE [AMT_NET_PRODUCT_COSTS_THEREOF_RETURN_MEK_EUR] END				  AS [AMT_NET_PRODUCT_COSTS_THEREOF_RETURN_MEK_EUR]              
	,[CD_GTS_PO_NO]
    ,[CD_GTS_PO_LINE]
--	,LOAD_TIMESTAMP							                                                                      as LOAD_TIMESTAMP
	,cast(getdate()	as date)																								  as [D_EFF_TO]	
	,cast(getdate()	as date)																						      as [D_EFF_DELETED]
	,cast(getdate()	as date)																						      as [D_EFF_FROM]
	,FL_DELETED								                                                                      as FL_DELETED
	,[FL_SINGLE_ITEM]   
	,[CD_CANCELLED_DOCUMENT_NO]  
	,[CD_CANCELLED_DOCUMENT_LINE]
	,AMT_TOTAL_NET_PRICE_EUR
	,AMT_TOTAL_NET_PRICE_FC
	,AMT_TAX_REVERSED_EUR
	,AMT_TAX_REVERSED_FC
	,AMT_TOTAL_PRICE_EUR
	,AMT_TOTAL_PRICE_FC
	,CD_PRECEDING_DOCUMENT_NO 
    ,CD_LINKED_DOCUMENT_NO 
	,CASE WHEN FL_Intercompany=1 OR NUM_ITEM LIKE '9%' THEN Null ELSE AMT_ENVIRO_AND_LICENSE_COST_EST_EUR END AMT_ENVIRO_AND_LICENSE_COST_EST_EUR
	,CASE WHEN FL_Intercompany=1 OR NUM_ITEM LIKE '9%' THEN Null ELSE AMT_NET_SHIPPING_REVENUE_FC END AMT_NET_SHIPPING_REVENUE_FC
    ,CD_CARRIER
	,CASE WHEN FL_Intercompany=1 THEN Null ELSE VL_REFUND_RATE 	     END AS 	VL_REFUND_RATE			
	,CASE WHEN FL_Intercompany=1 THEN Null ELSE VL_RETURN_RATE	     END AS     VL_RETURN_RATE				
	,CASE WHEN FL_Intercompany=1 THEN Null ELSE VL_REPLACEMENT_RATE  END AS     VL_REPLACEMENT_RATE 
	,CD_REFUND_RATE_SOURCE 
    ,CD_RETURN_RATE_SOURCE 
    ,CD_REPLACEMENT_RATE_SOURCE 
		,AMT_MEK_TO_CUSTOMER_EST_EUR 
		,AMT_MEK_FROM_CUSTOMER_EST_EUR
		,AMT_MEK_REPLACEMENT_EST_EUR 
		,AMT_MEK_DEPRECIATION_EST_EUR 
		,AMT_MARKETING_ATTRIBUTION_EST_EUR
		,AMT_COMMISSIONS_EST_EUR
		,AMT_COMMISSIONS_SALE_EST_EUR
		,AMT_COMMISSIONS_REFUNDS_EST_EUR 
		,AMT_STEERING_MARGIN_EST_EUR
		,AMT_FULL_NET_PRODUCT_COST_EST_EUR
		,ShippingCostsInvoicedEst
		,ShippingCostsReturnedEst
		,ShippingCostsReplacedEst
		,AMT_GROSS_MARGIN_EST_EUR

FROM CTE_SALES_L11



END-- PROC