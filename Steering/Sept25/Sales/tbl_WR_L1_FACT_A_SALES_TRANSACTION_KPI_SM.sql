CREATE TABLE [TEST].[WR_L1_FACT_A_SALES_TRANSACTION_KPI_SM]
(
     [ID_SALES_TRANSACTION]                         INT
	,[CD_SALES_TRANSACTION]                         VARCHAR(40)
	,[CD_SOURCE_SYSTEM]                             VARCHAR(3)
	,[CD_SALES_PROCESS_ID]                          VARCHAR(10)
	,[CD_SALES_PROCESS_LINE]                        VARCHAR(10)
	,[CD_DOCUMENT_NO]                               VARCHAR(10)
	,[CD_DOCUMENT_LINE]                             VARCHAR(6)
	,[CD_DOCUMENT_ID_REFERENCE]                     VARCHAR(10)
	,[ID_COMPANY]                                   INT
	,[D_CREATED]                                    DATE
	,[D_SALES_PROCESS]                              DATE
	,[T_CANCELLATION_REASON]                        VARCHAR(50)
	,[FL_INCIDENT]                                  CHAR(1)
	,[DT_CREATED]                                   SMALLDATETIME
	,[CD_TYPE]                                      VARCHAR(10)
	,[ID_SALES_TRANSACTION_TYPE]                    INT
	,[ID_ITEM]                                      INT
	,[ID_ITEM_PARENT]								INT	NULL
	,[CD_ITEM_TYPE]                                 VARCHAR(10)
	,[ID_SALES_CHANNEL]                             INT
	,[CD_FULFILLMENT]                               VARCHAR(16)
	,[CD_CUSTOMER]                                  VARCHAR(10)
	,T_CREATION_USERNAME	                        VARCHAR(100)	
	,[CD_MARKET_ORDER_ID]                           VARCHAR(150)
	,[CD_PAYMENT_METHOD]                            VARCHAR(50)
	,[CD_STORAGE_LOCATION]                          VARCHAR(10)
	,[T_STORAGE_LOCATION]                           VARCHAR(50)
	,[CD_COUNTRY_INVOICE]                           VARCHAR(5)
	,[CD_ZIP_INVOICE]                               VARCHAR(10)
	,[T_CITY_INVOICE]                               VARCHAR(50)
	,[CD_COUNTRY_DELIVERY]                          VARCHAR(5)
	,[CD_ZIP_DELIVERY]                              VARCHAR(10)
	,[T_CITY_DELIVERY]                              VARCHAR(50)
	,[CD_COUNTRY_ORDER]                             VARCHAR(5)
	,[CD_ZIP_ORDER]                                 VARCHAR(10)
	,[T_CITY_ORDER]                                 VARCHAR(50)
	,[CD_CUSTOMER_SERVICE_AGENT]                    VARCHAR(50)	
	,[VL_ITEM_QUANTITY]                             DECIMAL(19,6)
	,[AMT_NET_SHIPPING_REVENUE_EUR]                 DECIMAL(19,6)
	,[AMT_NET_PRICE_EUR]                            DECIMAL(19,6)
	,[AMT_NET_PRICE_FC]                             DECIMAL(19,6)
	,[AMT_SHIPPING_COST_EST_EUR]                    DECIMAL(19,6)
	,[CD_SHIPMENT_COSTS_SOURCE] VARCHAR(10)	NULL
	,[AMT_GROSS_SHIPPING_REVENUE_EUR]               DECIMAL(19,6)
	,[AMT_GROSS_SHIPPING_REVENUE_FC]                DECIMAL(19,6)
	,[AMT_GROSS_PRICE_EUR]                          DECIMAL(19,6)
	,[AMT_GROSS_PRICE_FC]                           DECIMAL(19,6)
	,[AMT_TAX_PRICE_EUR]                            DECIMAL(19,6)
	,[AMT_TAX_DISCOUNTS_EUR]                        DECIMAL(19,6)
	,[AMT_TAX_FREIGHT_EUR]                          DECIMAL(19,6)
	,[AMT_TAX_TOTAL_EUR]                            DECIMAL(19,6)
	,[AMT_TAX_TOTAL_PAYABLE_EUR]                    DECIMAL(19,6)   
    ,[AMT_TAX_OUTPUT_EUR]                           DECIMAL(19,6)  
	,[AMT_MEK_HEDGING_EUR]                          DECIMAL(19,6)
	,[AMT_GTS_MARKUP]                               DECIMAL(19,6)
	,[AMT_NET_DISCOUNT_EUR]                         DECIMAL(19,6)
	,[CD_CURRENCY]                                  VARCHAR(5)
	,[AMT_COMMERCIAL_TURNOVER_EUR]                  DECIMAL(19,6)
	,[AMT_TURNOVER_EUR]                             DECIMAL(19,6)
	,[VL_ORDER_QUANTITY]                            DECIMAL(19,6)
    ,[VL_ITEM_PARENT_QUANTITY]						DECIMAL(19,6)	
	,[AMT_VALUE_ADDED_TAX_EUR]                      DECIMAL(19,6)
	,[AMT_ORDER_DISCOUNTS_EUR]                      DECIMAL(19,6)
	,[AMT_ORDER_CHARGES_EUR]                        DECIMAL(19,6)
	,[AMT_GROSS_ORDER_VALUE_EUR]                    DECIMAL(19,6)
	,[VL_CANCELLED_ORDERS_QUANTITY_EST]             DECIMAL(19,6)
	,[VL_RETURNED_QUANTITY_EST]                     DECIMAL(19,6)
	,[AMT_CANCELLED_ORDER_VALUE_EST_EUR]            DECIMAL(19,6)
	,[VL_NET_ORDER_QUANTITY_EST]                    DECIMAL(19,6)
	,[AMT_REFUNDED_ORDER_VALUE_EST_EUR]             DECIMAL(19,6)
	,[AMT_RETURN_ORDER_VALUE_EST_EUR]               DECIMAL(19,6)
	,[AMT_NET_ORDER_VALUE_EST_EUR]                  DECIMAL(19,6)
	,[VL_REFUNDED_QUANTITY_EST]                     DECIMAL(19,6)
	,[AMT_REVENUE_EST_EUR]                          DECIMAL(19,6)
	,[VL_NET_QUANTITY_EST]                          DECIMAL(19,6)
	,[AMT_NET_PRODUCT_COST_EST_EUR]                 DECIMAL(19,6)
	,[AMT_NET_ORDER_CONTRIBUTION_EST_EUR]           DECIMAL(19,6)
	,[AMT_PC0_EUR]                                  DECIMAL(19,6)
	,[AMT_SHOP_MARKETING_EUR]                       DECIMAL(19,6)
	,[AMT_AMAZON_MARKETING_EUR]                     DECIMAL(19,6)
	,[AMT_MARKETING_MARKETPLACES_EST_EUR]           DECIMAL(19,6)
	,[AMT_COMMISSIONS_MARKETPLACES_EST_EUR]         DECIMAL(19,6)
	,[AMT_COMMISSIONS_MARKETPLACES_REFUNDS_EST_EUR] DECIMAL(19,6)
	,[AMT_PAYMENTS_FEES_EST_EUR]                    DECIMAL(19,6)
	,[AMT_REPLACEMENT_PRODUCT_COST_EST_EUR]         DECIMAL(19,6)
	,[AMT_REPLACEMENT_ORDER_QUANTITY_EST_EUR]       DECIMAL(19,6)
	,[AMT_COMMISSIONS_AMAZON_EST_EUR]               DECIMAL(19,6)
	,[AMT_COMMISSIONS_AMAZON_REFUNDS_EST_EUR]       DECIMAL(19,6)
	,[AMT_FULFILLMENT_OUTBOUND_EST_EUR]             DECIMAL(19,6)
	,[AMT_ENVIRO_REST_UNIT_FEE_EUR]                 DECIMAL(19,6)
	,[AMT_REPACKAGING_EUR]                          DECIMAL(19,6)
	,[CD_COUNTRY_GROUP_INVOICE]						VARCHAR(5)
	,[CD_COUNTRY_GROUP_DELIVERY]					VARCHAR(5)
	,[AMT_CANCELLED_ORDER_VALUE_EUR]          DECIMAL(19,6)
	,[VL_CANCELLED_ORDER_QUANTITY]            DECIMAL(19,6)
	,[AMT_NET_ORDER_VALUE_EUR]                DECIMAL(19,6)
	,[AMT_NET_ORDER_VALUE_FULL_PRICE_EUR]     DECIMAL(19,6)
	,[VL_NET_ORDER_QUANTITY]                  DECIMAL(19,6)
	,[AMT_NET_PRODUCT_COSTS_THEREOF_RETURN_MEK_EUR] DECIMAL(19,6)
	,[AMT_DEPRECIATION_EST_EUR]                     DECIMAL(19,2)
	,[D_DOCUMENT_CREATED]							DATE NULL
	,CD_BILLING_CATEGORY					  VARCHAR(3)      NULL
    ,D_BILLING_DATE							  DATE            NULL
    ,CD_BILLING_POSTING_STATUS				  VARCHAR(3)      NULL
    ,CD_PAYER								  VARCHAR(50)     NULL
    ,VL_BILLING_QUANTITY					  DECIMAL(19,6)   NULL
    ,VL_EXCHANGE_RATE						  DECIMAL(19,6)   NULL
    ,CD_SALES_DOCUMENT_NO                     VARCHAR(50)      NULL
    ,D_UPDATED								  DATE            NULL
    ,CD_REJECTION_STATUS					  VARCHAR(50)     NULL
    ,D_CANCELLATION							  DATE            NULL
	,CD_RETURN_REASON                         NVARCHAR(5)     NULL
    ,T_RETURN_REASON                          NVARCHAR(100)   NULL
	,CD_GTS_PO_NO               NVARCHAR(100)   NULL
    ,CD_GTS_PO_LINE             NVARCHAR(100)   NULL
	,[LOAD_TIMESTAMP]                         DATETIME2
	,[D_EFF_TO]                     DATE         NULL
    ,[D_EFF_DELETED]                DATE         NULL
    ,[FL_DELETED]                             VARCHAR(1)
	,[FL_SINGLE_ITEM]           VARCHAR(1)
	,[CD_CANCELLED_DOCUMENT_NO]   VARCHAR(10)	NULL
	,[CD_CANCELLED_DOCUMENT_LINE] VARCHAR(10)	NULL
	,[AMT_NET_DISCOUNT_FC]                           DECIMAL(19,6) 
    ,[AMT_TAX_OUTPUT_FC] DECIMAL(19,6)	NULL
    ,[AMT_TAX_TOTAL_PAYABLE_FC] DECIMAL(19,6)   NULL
    ,[AMT_TOTAL_NET_PRICE_EUR] DECIMAL(19,6)	NULL
    ,[AMT_TOTAL_NET_PRICE_FC] DECIMAL(19,6)	NULL
    ,[AMT_TAX_REVERSED_EUR] DECIMAL(19,6)	NULL
    ,[AMT_TAX_REVERSED_FC] DECIMAL(19,6)	NULL
	,[AMT_TOTAL_PRICE_EUR] DECIMAL(19,6)	NULL
	,[AMT_TOTAL_PRICE_FC] DECIMAL(19,6)	NULL
	,CD_PRECEDING_DOCUMENT_NO VARCHAR(10)	NULL
    ,CD_LINKED_DOCUMENT_NO VARCHAR(10)	NULL
    ,[AMT_REPACKAGING_EST_EUR]                      DECIMAL(19,6)
    ,[AMT_ENVIRO_AND_LICENSE_COST_EST_EUR]          DECIMAL(19,6)
	,AMT_NET_SHIPPING_REVENUE_FC	                DECIMAL(19,6)	NULL
	,CD_CARRIER                                     NVARCHAR(100)
	,VL_REFUND_RATE DECIMAL(19,6)	NULL					
	,VL_RETURN_RATE	DECIMAL(19,6)	NULL				
	,VL_REPLACEMENT_RATE DECIMAL(19,6)	NULL	
	,CD_REFUND_RATE_SOURCE VARCHAR(20)
    ,CD_RETURN_RATE_SOURCE VARCHAR(20)
    ,CD_REPLACEMENT_RATE_SOURCE VARCHAR(20)
	,CD_VAT_NO NVARCHAR(20)
	,AMT_TRANSPORT_DAMAGE_EUR DECIMAL(19,6)	NULL	
    ,AMT_EXTENDED_WARRANTY_EUR DECIMAL(19,6) NULL	
    ,AMT_ACCIDENTAL_DAMAGE_COVERAGE_EUR DECIMAL(19,6) NULL	
    ,AMT_IMMEDIATE_PRODUCT_EXCHANGE_EUR DECIMAL(19,6) NULL	

)
WITH
(
    DISTRIBUTION = HASH(CD_SALES_PROCESS_ID),
    HEAP
)
GO