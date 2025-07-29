
	DECLARE @timezone_offset  INT = (
	SELECT
		SUBSTRING(current_utc_offset, 2, 2)  
	FROM sys.time_zone_info
	WHERE name = 'Central Europe Standard Time'
	);

	DECLARE @current_date DATETIME = DATEADD(hour, @timezone_offset, GETUTCDATE());

	--DELETE FROM L1.L1_FACT_A_SALES_TRANSACTION_KPI_ARCHIVE WHERE YEAR([D_CREATED]) = 2020

	INSERT INTO L1.L1_FACT_A_SALES_TRANSACTION_KPI_ARCHIVE
	(
	[ID_SALES_TRANSACTION]                         
	,[CD_SALES_TRANSACTION]                         
	,[CD_SOURCE_SYSTEM]                             
	,[CD_SALES_PROCESS_ID]                          
	,[CD_SALES_PROCESS_LINE]                        
	,[CD_DOCUMENT_NO]                               
	,[CD_DOCUMENT_LINE]                             
	,[CD_DOCUMENT_ID_REFERENCE]                     
	,[ID_COMPANY]                                   
	,[D_CREATED]                                    
	,[D_SALES_PROCESS]     
	,[D_DOCUMENT_CREATED]	
	,[T_CANCELLATION_REASON]                        
	,[FL_INCIDENT]                                  
	,[DT_CREATED]                                   
	,[CD_TYPE]                                      
	,[ID_SALES_TRANSACTION_TYPE]                    
	,[ID_ITEM]       
	,[ID_ITEM_PARENT]                                      
	,[CD_ITEM_TYPE]                                 
	,[ID_SALES_CHANNEL]                             
	,[CD_FULFILLMENT]                               
	,[CD_CUSTOMER] 
	,[CD_CUSTOMER_SERVICE_AGENT]
	,[T_CREATION_USERNAME]
	,[CD_MARKET_ORDER_ID]                           
	,[CD_PAYMENT_METHOD]                            
	,[CD_STORAGE_LOCATION]                          
	,[T_STORAGE_LOCATION]                           
	,[CD_COUNTRY_INVOICE]                           
	,[CD_ZIP_INVOICE]                               
	,[T_CITY_INVOICE]                               
	,[CD_COUNTRY_DELIVERY]                          
	,[CD_ZIP_DELIVERY]                              
	,[T_CITY_DELIVERY]                              
	,[CD_COUNTRY_ORDER]                             
	,[CD_ZIP_ORDER]                                 
	,[T_CITY_ORDER]    
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
	,[VL_ITEM_QUANTITY]        
	,[VL_ITEM_PARENT_QUANTITY]                             
	,[AMT_NET_SHIPPING_REVENUE_EUR]                 
	,[AMT_NET_PRICE_EUR]                            
	,[AMT_NET_PRICE_FC]                             
	,[AMT_SHIPPING_COST_EST_EUR]       
	,[CD_SHIPMENT_COSTS_SOURCE]
	,[AMT_GROSS_SHIPPING_REVENUE_EUR]               
	,[AMT_GROSS_SHIPPING_REVENUE_FC]                
	,[AMT_GROSS_PRICE_EUR]                          
	,[AMT_GROSS_PRICE_FC]                           
	,[AMT_TAX_PRICE_EUR]                            
	,[AMT_TAX_DISCOUNTS_EUR]                        
	,[AMT_TAX_FREIGHT_EUR]                          
	,[AMT_TAX_TOTAL_EUR]  
	,[AMT_TAX_TOTAL_PAYABLE_EUR]
	,[AMT_TAX_TOTAL_PAYABLE_FC]
    ,[AMT_TAX_OUTPUT_EUR]
	,[AMT_TAX_OUTPUT_FC]
	,[AMT_MEK_HEDGING_EUR]                          
	,[AMT_GTS_MARKUP]                               
	,[AMT_NET_DISCOUNT_EUR]   
	,[AMT_NET_DISCOUNT_FC]
	,[CD_CURRENCY]                                  
	,[AMT_COMMERCIAL_TURNOVER_EUR]                  
	,[AMT_TURNOVER_EUR]                             
	,[VL_ORDER_QUANTITY]                            
	,[AMT_VALUE_ADDED_TAX_EUR]                      
	,[AMT_ORDER_DISCOUNTS_EUR]                      
	,[AMT_ORDER_CHARGES_EUR]                        
	,[AMT_GROSS_ORDER_VALUE_EUR]                    
	,[VL_CANCELLED_ORDERS_QUANTITY_EST]             
	,[VL_RETURNED_QUANTITY_EST]                     
	,[AMT_CANCELLED_ORDER_VALUE_EST_EUR]            
	,[VL_NET_ORDER_QUANTITY_EST]                    
	,[AMT_REFUNDED_ORDER_VALUE_EST_EUR]             
	,[AMT_RETURN_ORDER_VALUE_EST_EUR]               
	,[AMT_NET_ORDER_VALUE_EST_EUR]                  
	,[VL_REFUNDED_QUANTITY_EST]                     
	,[AMT_REVENUE_EST_EUR]                          
	,[VL_NET_QUANTITY_EST]                          
	,[AMT_NET_PRODUCT_COST_EST_EUR]       
	,[AMT_NET_ORDER_CONTRIBUTION_EST_EUR]
	,[AMT_PC0_EUR]                                  
	,[AMT_DEMURRAGE_DETENTION_EUR]                  
	,[AMT_DEADFREIGHT_EUR]                          
	,[AMT_KICKBACKS_EUR]                            
	,[AMT_3RD_PARTY_SERVICES_EUR]                   
	,[AMT_RMA_EUR]                                  
	,[AMT_SAMPLES_EUR]                              
	,[AMT_OTHER_COGS_EFFECTS_EST_EUR]               
	,[AMT_DROPSHIPMENT_CEOTRA9ER_ARTIKEL_EST_EUR]   
	,[AMT_INBOUND_FREIGHT_COST_EST_EUR]             
	,[AMT_PO_CANCELLATION_EUR]                      
	,[AMT_STOCK_ADJUSTMENT_EUR]                     
	,[AMT_FX_HEDGING_IMPACT_EST_EUR]                
	,[AMT_COGS_STOCK_VALUE_ADJUSTMENT_EST_EUR]      
	,[AMT_COGS_OPERATIONS_EST_EUR]                  
	,[AMT_PC1_EUR]                                  
	,[AMT_PC2_EUR]                                  
	,[AMT_HANDLING_INBOUND_EST_EUR]                 
	,[AMT_HANDLING_TRANS_SHIPPMENT_EST_EUR]         
	,[AMT_PACKAGING_EST_EUR]                        
	,[AMT_HANDLING_SHIPMENTS_EST_EUR]               
	,[AMT_CUSTOMER_SERVICE_HANDLING_EST_EUR]        
	,[AMT_CUSTOMER_SERVICE_OPEX_EST_EUR]            
	,[AMT_SHOP_MARKETING_EUR]                       
	,[AMT_AMAZON_MARKETING_EUR]                      
	,[AMT_TRUCKING_TRANS_SHIPMENT_EST_EUR]          
	,[AMT_MARKETING_MARKETPLACES_EST_EUR]           
	,[AMT_COMMISSIONS_MARKETPLACES_EST_EUR]         
	,[AMT_COMMISSIONS_MARKETPLACES_REFUNDS_EST_EUR] 
	,[AMT_PAYMENTS_FEES_EST_EUR]                    
	,[AMT_HANDLING_RETURNS_EST_EUR]                 
	,[AMT_WAREHOUSING_RENT_EST_EUR]                 
	,[AMT_WAREHOUSING_OPEX_EST_EUR]                 
	,[AMT_REPLACEMENT_PRODUCT_COST_EST_EUR]         
	,[AMT_REPLACEMENT_ORDER_QUANTITY_EST_EUR]       
	,[AMT_COMMISSIONS_AMAZON_EST_EUR]               
	,[AMT_COMMISSIONS_AMAZON_REFUNDS_EST_EUR]       
	,[AMT_WAREHOUSING_FBA_EST_EUR]                  
	,[AMT_FULFILLMENT_OUTBOUND_EST_EUR]             
	,[AMT_MARKETING_OPEX_EST_EUR] 
	,[AMT_PC3_EUR]	
	,[AMT_ENVIRO_REST_UNIT_FEE_EUR] 
	,[AMT_REPACKAGING_EUR]                         
	,[CD_COUNTRY_GROUP_INVOICE]
	,[CD_COUNTRY_GROUP_DELIVERY]
	,[AMT_CANCELLED_ORDER_VALUE_EUR]          
	,[VL_CANCELLED_ORDER_QUANTITY]            
	,[AMT_NET_ORDER_VALUE_EUR]                
	,[AMT_NET_ORDER_VALUE_FULL_PRICE_EUR]     
	,[VL_NET_ORDER_QUANTITY]     
	,[AMT_NET_PRODUCT_COSTS_THEREOF_RETURN_MEK_EUR]
	,[CD_RETURN_REASON]         
    ,[T_RETURN_REASON]
	,[CD_GTS_PO_NO]
    ,[CD_GTS_PO_LINE]
    ,[D_EFF_FROM]
	,[D_EFF_TO]
	,[D_EFF_DELETED]
	,[DT_DWH_CREATED]
	,[DT_DWH_UPDATED]
	,[FL_DELETED]
	,[FL_SINGLE_ITEM]   
	,[CD_CANCELLED_DOCUMENT_NO]  
	,[CD_CANCELLED_DOCUMENT_LINE] 
	,[AMT_TOTAL_NET_PRICE_EUR]
    ,[AMT_TOTAL_NET_PRICE_FC]
    ,[AMT_TAX_REVERSED_EUR]
    ,[AMT_TAX_REVERSED_FC] 
	,[AMT_TOTAL_PRICE_EUR]
	,[AMT_TOTAL_PRICE_FC]
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
	)
	SELECT
	[ID_SALES_TRANSACTION]                         
	,[CD_SALES_TRANSACTION]                         
	,[CD_SOURCE_SYSTEM]                             
	,[CD_SALES_PROCESS_ID]                          
	,[CD_SALES_PROCESS_LINE]                        
	,[CD_DOCUMENT_NO]                               
	,[CD_DOCUMENT_LINE]                             
	,[CD_DOCUMENT_ID_REFERENCE]                     
	,[ID_COMPANY]                                   
	,[D_CREATED]                                    
	,[D_SALES_PROCESS]  
	,[D_DOCUMENT_CREATED]
	,[T_CANCELLATION_REASON]                        
	,[FL_INCIDENT]                                  
	,[DT_CREATED]                                   
	,[CD_TYPE]                                      
	,[ID_SALES_TRANSACTION_TYPE]                    
	,[ID_ITEM]       
	,[ID_ITEM_PARENT]                                      
	,[CD_ITEM_TYPE]                                 
	,[ID_SALES_CHANNEL]                             
	,[CD_FULFILLMENT]                               
	,[CD_CUSTOMER]
	,[CD_CUSTOMER_SERVICE_AGENT]
	,[T_CREATION_USERNAME]
	,[CD_MARKET_ORDER_ID]                           
	,[CD_PAYMENT_METHOD]                            
	,[CD_STORAGE_LOCATION]                          
	,[T_STORAGE_LOCATION]                           
	,[CD_COUNTRY_INVOICE]                           
	,[CD_ZIP_INVOICE]                               
	,[T_CITY_INVOICE]                               
	,[CD_COUNTRY_DELIVERY]                          
	,[CD_ZIP_DELIVERY]                              
	,[T_CITY_DELIVERY]                              
	,[CD_COUNTRY_ORDER]                             
	,[CD_ZIP_ORDER]                                 
	,[T_CITY_ORDER]  
	,CD_BILLING_CATEGORY	
	,D_BILLING_DATE					
	,CD_BILLING_POSTING_STATUS		
	,CD_PAYER						
	,ROUND(VL_BILLING_QUANTITY							 ,2)		
	,ROUND(VL_EXCHANGE_RATE								 ,2)		
	,CD_SALES_DOCUMENT_NO           
	,D_UPDATED						
	,CD_REJECTION_STATUS			
	,D_CANCELLATION
	,ROUND([VL_ITEM_QUANTITY]                            ,2)    
	,ROUND([VL_ITEM_PARENT_QUANTITY]                     ,2)         
	,ROUND([AMT_NET_SHIPPING_REVENUE_EUR]		         ,2)	
	,ROUND([AMT_NET_PRICE_EUR]                           ,2)          
	,ROUND([AMT_NET_PRICE_FC]                            ,2)          
	,ROUND([AMT_SHIPPING_COST_EST_EUR]                   ,2) 
	,[CD_SHIPMENT_COSTS_SOURCE]
	,ROUND([AMT_GROSS_SHIPPING_REVENUE_EUR]              ,2)          
	,ROUND([AMT_GROSS_SHIPPING_REVENUE_FC]               ,2)          
	,ROUND([AMT_GROSS_PRICE_EUR]                         ,2)          
	,ROUND([AMT_GROSS_PRICE_FC]                          ,2)          
	,ROUND([AMT_TAX_PRICE_EUR]                           ,2)          
	,ROUND([AMT_TAX_DISCOUNTS_EUR]                       ,2)          
	,ROUND([AMT_TAX_FREIGHT_EUR]                         ,2)          
	,ROUND([AMT_TAX_TOTAL_EUR]                           ,2)   
	,ROUND([AMT_TAX_TOTAL_PAYABLE_EUR]					 ,2) 	
	,ROUND([AMT_TAX_TOTAL_PAYABLE_FC]					 ,2) 
    ,ROUND([AMT_TAX_OUTPUT_EUR]                          ,2) 
	,ROUND([AMT_TAX_OUTPUT_FC]                           ,2) 
	,ROUND([AMT_MEK_HEDGING_EUR]                         ,2)          
	,ROUND([AMT_GTS_MARKUP]                              ,2)          
	,ROUND([AMT_NET_DISCOUNT_EUR]                        ,2)      
	,ROUND([AMT_NET_DISCOUNT_FC]                         ,2)    
	,[CD_CURRENCY]       
	,ROUND([AMT_COMMERCIAL_TURNOVER_EUR]                 ,2)          
	,ROUND([AMT_TURNOVER_EUR]                            ,2)          
	,ROUND([VL_ORDER_QUANTITY]                           ,2)          
	,ROUND([AMT_VALUE_ADDED_TAX_EUR]                     ,2)          
	,ROUND([AMT_ORDER_DISCOUNTS_EUR]                     ,2)          
	,ROUND([AMT_ORDER_CHARGES_EUR]                       ,2)          
	,ROUND([AMT_GROSS_ORDER_VALUE_EUR]                   ,2)          
	,ROUND([VL_CANCELLED_ORDERS_QUANTITY_EST]            ,2)         
	,ROUND([VL_RETURNED_QUANTITY_EST]                    ,2)         
	,ROUND([AMT_CANCELLED_ORDER_VALUE_EST_EUR]           ,2)          
	,ROUND([VL_NET_ORDER_QUANTITY_EST]                   ,2)          
	,ROUND([AMT_REFUNDED_ORDER_VALUE_EST_EUR]            ,2)          
	,ROUND([AMT_RETURN_ORDER_VALUE_EST_EUR]              ,2)          
	,ROUND([AMT_NET_ORDER_VALUE_EST_EUR]                 ,2)                
	,ROUND([VL_REFUNDED_QUANTITY_EST]                    ,2)          
	,ROUND([AMT_REVENUE_EST_EUR]                         ,2)          
	,ROUND([VL_NET_QUANTITY_EST]                         ,2)          
	,ROUND([AMT_NET_PRODUCT_COST_EST_EUR]                ,2)
	,ROUND([AMT_NET_ORDER_CONTRIBUTION_EST_EUR]	         ,2)
	,ROUND([AMT_PC0_EUR]                                 ,2)          
	,ROUND([AMT_DEMURRAGE_DETENTION_EUR]                 ,2)          
	,ROUND([AMT_DEADFREIGHT_EUR]                         ,2)          
	,ROUND([AMT_KICKBACKS_EUR]                           ,2)          
	,ROUND([AMT_3RD_PARTY_SERVICES_EUR]                  ,2)          
	,ROUND([AMT_RMA_EUR]                                 ,2)          
	,ROUND([AMT_SAMPLES_EUR]                             ,2)          
	,ROUND([AMT_OTHER_COGS_EFFECTS_EST_EUR]              ,2)          
	,ROUND([AMT_DROPSHIPMENT_CEOTRA9ER_ARTIKEL_EST_EUR]  ,2) 
	,ROUND([AMT_INBOUND_FREIGHT_COST_EST_EUR]            ,2) 
	,ROUND([AMT_PO_CANCELLATION_EUR]                     ,2) 
	,ROUND([AMT_STOCK_ADJUSTMENT_EUR]                    ,2) 
	,ROUND([AMT_FX_HEDGING_IMPACT_EST_EUR]               ,2) 
	,ROUND([AMT_COGS_STOCK_VALUE_ADJUSTMENT_EST_EUR]     ,2) 
	,ROUND([AMT_COGS_OPERATIONS_EST_EUR]                 ,2) 
	,ROUND([AMT_PC1_EUR]                                 ,2) 
	,ROUND([AMT_PC2_EUR]                                 ,2) 
	,ROUND([AMT_HANDLING_INBOUND_EST_EUR]                ,2) 
	,ROUND([AMT_HANDLING_TRANS_SHIPPMENT_EST_EUR]        ,2) 
	,ROUND([AMT_PACKAGING_EST_EUR]                       ,2) 
	,ROUND([AMT_HANDLING_SHIPMENTS_EST_EUR]              ,2) 
	,ROUND([AMT_CUSTOMER_SERVICE_HANDLING_EST_EUR]       ,2) 
	,ROUND([AMT_CUSTOMER_SERVICE_OPEX_EST_EUR]           ,2) 
	,ROUND([AMT_SHOP_MARKETING_EUR]                      ,2) 
	,ROUND([AMT_AMAZON_MARKETING_EUR]                    ,2)  
	,ROUND([AMT_TRUCKING_TRANS_SHIPMENT_EST_EUR]         ,2) 
	,ROUND([AMT_MARKETING_MARKETPLACES_EST_EUR]          ,2) 
	,ROUND([AMT_COMMISSIONS_MARKETPLACES_EST_EUR]        ,2) 
	,ROUND([AMT_COMMISSIONS_MARKETPLACES_REFUNDS_EST_EUR],2) 
	,ROUND([AMT_PAYMENTS_FEES_EST_EUR]                   ,2) 
	,ROUND([AMT_HANDLING_RETURNS_EST_EUR]                ,2) 
	,ROUND([AMT_WAREHOUSING_RENT_EST_EUR]                ,2) 
	,ROUND([AMT_WAREHOUSING_OPEX_EST_EUR]                ,2) 
	,ROUND([AMT_REPLACEMENT_PRODUCT_COST_EST_EUR]        ,2) 
	,ROUND([AMT_REPLACEMENT_ORDER_QUANTITY_EST_EUR]      ,2) 
	,ROUND([AMT_COMMISSIONS_AMAZON_EST_EUR]              ,2) 
	,ROUND([AMT_COMMISSIONS_AMAZON_REFUNDS_EST_EUR]      ,2) 
	,ROUND([AMT_WAREHOUSING_FBA_EST_EUR]                 ,2) 
	,ROUND([AMT_FULFILLMENT_OUTBOUND_EST_EUR]            ,2) 
	,ROUND([AMT_MARKETING_OPEX_EST_EUR] 				 ,2)
	,ROUND([AMT_PC3_EUR]      							 ,2)
	,ROUND([AMT_ENVIRO_REST_UNIT_FEE_EUR]                ,2)
	,ROUND([AMT_REPACKAGING_EUR] 						 ,2)
	,[CD_COUNTRY_GROUP_INVOICE]					
	,[CD_COUNTRY_GROUP_DELIVERY]					
	,ROUND([AMT_CANCELLED_ORDER_VALUE_EUR]          	 ,2)
	,ROUND([VL_CANCELLED_ORDER_QUANTITY]            	 ,2)
	,ROUND([AMT_NET_ORDER_VALUE_EUR]                	 ,2)
	,ROUND([AMT_NET_ORDER_VALUE_FULL_PRICE_EUR]     	 ,2)
	,ROUND([VL_NET_ORDER_QUANTITY]         				 ,2)
	,ROUND([AMT_NET_PRODUCT_COSTS_THEREOF_RETURN_MEK_EUR],2)
	,[CD_RETURN_REASON]         
    ,[T_RETURN_REASON] 
	,[CD_GTS_PO_NO]
    ,[CD_GTS_PO_LINE]
    ,LOAD_TIMESTAMP as [D_EFF_FROM]
	,[D_EFF_TO]
	,[D_EFF_DELETED]
	,@current_date as [DT_DWH_CREATED]
	,@current_date as [DT_DWH_UPDATED]
	,[FL_DELETED]
	,[FL_SINGLE_ITEM]   
	,[CD_CANCELLED_DOCUMENT_NO]  
	,[CD_CANCELLED_DOCUMENT_LINE] 
	,ROUND([AMT_TOTAL_NET_PRICE_EUR]                    ,2)
    ,ROUND([AMT_TOTAL_NET_PRICE_FC]						,2)
    ,ROUND([AMT_TAX_REVERSED_EUR]						,2)
    ,ROUND([AMT_TAX_REVERSED_FC] 						,2)
	,ROUND(AMT_TOTAL_PRICE_EUR                          ,2) 
	,ROUND(AMT_TOTAL_PRICE_FC							,2)
	,CD_PRECEDING_DOCUMENT_NO 
    ,CD_LINKED_DOCUMENT_NO 
	,ROUND(AMT_ENVIRO_AND_LICENSE_COST_EST_EUR          ,2)
	,ROUND(AMT_NET_SHIPPING_REVENUE_FC                  ,2)
    ,CD_CARRIER
	,ROUND(VL_REFUND_RATE 								,2)				
	,ROUND(VL_RETURN_RATE	                            ,2)				
	,ROUND(VL_REPLACEMENT_RATE 	                        ,2)
	,CD_REFUND_RATE_SOURCE 
    ,CD_RETURN_RATE_SOURCE 
    ,CD_REPLACEMENT_RATE_SOURCE 
	FROM WR.WR_L1_FACT_A_SALES_TRANSACTION_KPI s;

