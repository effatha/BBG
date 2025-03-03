
/****************************************************************
** Load Date
** calculate for how many days we process transactions
*****************************************************************/
DECLARE @LOAD_START_DATE AS date 
SET @LOAD_START_DATE='2024-01-01'

--IF(ISNULL(@NUM_LOAD_DAYS,0) > 0 )
--    SET @LOAD_START_DATE = CAST(GETDATE () - @NUM_LOAD_DAYS as date)


;WITH CTE_SHIPP_COSTS as
(SELECT 
	    cost.item_code,
	    CASE WHEN cost.warehouse=1 THEN 'Kamp-Lintfort'
	         WHEN cost.warehouse=2 THEN 'Hoppegarten'
	         WHEN cost.warehouse=3 THEN 'Bratislava'
	         WHEN cost.warehouse=4 THEN 'Werne'
	    END warehouse,
        warehouse as warehouse_id,
	    cost.country,
		ctypes.cost_type_name as Fulfillment,
	    SUM(cost.parcel_total_cost) as main_shipping_cost
	FROM [L0].[L0_MERCURY_LOGISTIC_BUDGET_CAPO_COST] cost 
	LEFT JOIN [L0].[L0_MERCURY_LOGISTIC_BUDGET_COST_TYPES] ctypes
	ON cost.cost_type_id = ctypes.id
	WHERE 0=0
	    --AND cost.warehouse IN (1, 3, 4)
		
	GROUP BY 
	    cost.item_code,
	    cost.warehouse,
	    cost.country,
		ctypes.cost_type_name
)

INSERT INTO [TEST].[WR_L1_FACT_A_SALES_TRANSACTION_CAPO] (
	  [CD_SALES_TRANSACTION]
      ,[CD_SOURCE_SYSTEM]
      ,[CD_SALES_PROCESS_ID]
      ,[CD_SALES_PROCESS_LINE]
      ,[CD_DOCUMENT_NO]	
      ,[CD_DOCUMENT_LINE]
      ,[CD_DOCUMENT_ID_REFERENCE]
      ,[ID_COMPANY]
      ,[D_CREATED]
      ,[D_SALES_PROCESS]
      ,[DT_CREATED]
      ,[CD_TYPE]
      ,[ID_SALES_TRANSACTION_TYPE]
      ,[T_TYPE]
      ,[FL_CANCELLED] 
      ,[T_CANCELLATION_REASON]
      ,[FL_INCIDENT]
      ,[ID_ITEM]
      ,[CD_ITEM_TYPE]
      ,[CD_SIZE_BRACKET]
      ,[CD_SIZE_BRACKET_FBA]
      ,[CD_SIZE_TYPE_FBA]
      ,[T_FBA_SIZE_DETAILED]
      ,[ID_SALES_CHANNEL]
      ,[CD_FULFILLMENT]
      ,[CD_CUSTOMER]
      ,[CD_CUSTOMER_SERVICE_AGENT]
      ,[T_CREATION_USERNAME]
      ,[CD_MARKET_ORDER_ID]
      ,[CD_PAYMENT_METHOD]
      ,[CD_STORAGE_LOCATION]
      ,[ID_STORAGE_LOCATION]
      ,[T_REVISED_LOCATION]
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
      ,[VL_ITEM_QUANTITY]
      ,[AMT_NET_SHIPPING_REVENUE_EUR]
      ,[AMT_NET_PRICE_EUR]
      ,[AMT_NET_PRICE_FC]
      ,[AMT_SHIPPING_COST_EST_EUR]
	  ,AMT_SHIPPING_COST_EST_EUR_SAP
      ,[AMT_GROSS_SHIPPING_REVENUE_EUR]
      ,[AMT_GROSS_SHIPPING_REVENUE_FC]
      ,[AMT_GROSS_PRICE_EUR]
      ,[AMT_GROSS_PRICE_FC]
      ,[AMT_NET_DISCOUNT_EUR]
	  ,[AMT_TAX_DISCOUNTS_EUR]
      ,[AMT_TAX_FREIGHT_EUR]
      ,[AMT_TAX_TOTAL_EUR]
      ,[AMT_TAX_PRICE_EUR]
	  ,[AMT_MEK_HEDGING_EUR]
      ,[AMT_GTS_MARKUP]
      ,[CD_CURRENCY]
      ,[T_PRODUCT_HIERARCHY_2]
      ,[T_PRODUCT_HIERARCHY_1]
      ,[D_DOCUMENT_CREATED]
      ,[D_DOCUMENT_HEADER]
      ,[T_ORDER_REASON]
      ,D_UPDATED
      ,CD_REJECTION_STATUS
      ,D_CANCELLATION
	  ,[LOAD_TIMESTAMP]
	  ,[FL_DELETED]
)
  
SELECT 
    CONCAT (VAITM.VBELN , '#', VAITM.POSNR) as CD_SALES_TRANSACTION
	,'SAP' as [CD_SOURCE_SYSTEM]
    ,COALESCE(procid.[PRECEDINGDOCUMENT],VAITM.[VBELN]) AS [CD_SALES_PROCESS_ID]
    ,COALESCE(procid.[PRECEDINGDOCUMENTITEM],VAITM.[POSNR]) AS [CD_SALES_PROCESS_LINE]
--    ,VAITM.[VBELN] AS [CD_DOCUMENT_ID]
--    ,procid.[VBELV] AS [CD_SALES_PROCESS_ID]
    ,VAITM.[VBELN] AS [CD_DOCUMENT_NO]
    ,VAITM.[POSNR] AS [CD_DOCUMENT_LINE]
	,VAITM.VGBEL AS [CD_DOCUMENT_ID_REFERENCE]
	,wr_company.ID_COMPANY AS [ID_COMPANY]
	,VAITM.ERDAT AS [D_CREATED]
    ,COALESCE(VAITM2.ERDAT, VAITM.ERDAT) AS [D_SALES_PROCESS]
	,CAST(VAITM.ERDAT AS DATETIME) + CAST(CONCAT(SUBSTRING(VAITM.ERZET, 1, 2), ':', SUBSTRING(VAITM.ERZET, 3, 2), ':', SUBSTRING(VAITM.ERZET, 5, 2)) AS DATETIME) AS [DT_CREATED]
    ,VAITM.[AUART]  AS [CD_TYPE]
	,wr_sales_transaction_type.ID_SALES_TRANSACTION_TYPE AS [ID_SALES_TRANSACTION_TYPE]
	, Null AS [T_TYPE]
    , COALESCE('X', VAITM.[AUGRU], 'X') AS [FL_CANCELLED] 
	, tReject.BEZEI AS [T_CANCELLATION_REASON]
    ,CASE
	    WHEN tReject.BEZEI	='Wrongly created' OR incident.DOCUMENTNO IS NOT NULL THEN 'Y'
		ELSE 'N'
	 END			AS [FL_INCIDENT]
	, srgitem.ID_ITEM AS [ID_ITEM]
	, VAITM.[ZZ_SGT_RCAT] AS [CD_ITEM_TYPE]
    ,sizebracket.CD_SIZE_BRACKET as CD_SIZE_BRACKET
    ,sizebracket_fba.[CD_SIZE_BRACKET_FBA]
    ,sizebracket_fba.[CD_SIZE_TYPE_FBA]
    ,sizebracket_fba.[T_FBA_SIZE_DETAILED]
	,wr_sales_channel.ID_SALES_CHANNEL AS [ID_SALES_CHANNEL]
	, CASE
		WHEN VAITM.VKBUR like '60%'
			THEN 'FBA'
		WHEN VAITM.LPRIO='01'
			THEN 'PBM'
		ELSE 'FBM'
	END AS [CD_FULFILLMENT]
	, VAITM.[KUNNR] AS [CD_CUSTOMER]
    , csa.ACTIVEDIRECTORY as CD_CUSTOMER_SERVICE_AGENT
	, VAITM.ERNAM AS [T_CREATION_USERNAME]
	, VAITM.BSTKD AS [CD_MARKET_ORDER_ID]
	, VAITM.[ZTERM] AS [CD_PAYMENT_METHOD]
	, VAITM.[LGORT] AS [CD_STORAGE_LOCATION]
    , storkey.ID_STORAGE_LOCATION AS [ID_STORAGE_LOCATION]
    , stor1.STORAGELOCATION     AS [T_REVISED_LOCATION]
	, stor.TXTMD AS [T_STORAGE_LOCATION]
	, VBPARE.LAND1 AS [CD_COUNTRY_INVOICE]
	, CUSTRE.PSTLZ AS [CD_ZIP_INVOICE]
	, CUSTRE.ORT01 AS [CD_CITY_INVOICE]
	, VBPAWE.LAND1 AS [CD_COUNTRY_DELIVERY]
	, CUSTWE.PSTLZ AS [CD_ZIP_DELIVERY]
	, CUSTWE.ORT01 AS [T_CITY_DELIVERY]
	, VBPAAG.LAND1 AS [CD_COUNTRY_ORDER]
	, CUSTAG.PSTLZ AS [CD_ZIP_ORDER]
	, CUSTAG.ORT01 AS [T_CITY_ORDER]
	, VAITM.KWMENG AS [VL_ITEM_QUANTITY]
	, CASE WHEN ISNULL(VAKON.AMT_NET_SHIPPING_REVENUE_EUR,0) = 0   THEN ISNULL(PRCD.AMT_NET_SHIPPING_REVENUE_EUR  ,0) ELSE VAKON.AMT_NET_SHIPPING_REVENUE_EUR   END AS AMT_NET_SHIPPING_REVENUE_EUR   
	, CASE WHEN ISNULL(VAKON.AMT_NET_PRICE_EUR,0) = 0              THEN ISNULL(PRCD.AMT_NET_PRICE_EUR             ,0) ELSE VAKON.AMT_NET_PRICE_EUR              END AS AMT_NET_PRICE_EUR              
	, CASE WHEN ISNULL(VAKON.AMT_NET_PRICE_FC,0) = 0               THEN ISNULL(PRCD.AMT_NET_PRICE_FC              ,0) ELSE VAKON.AMT_NET_PRICE_FC               END AS AMT_NET_PRICE_FC               
	, CASE WHEN VAITM.VKBUR like '60%' THEN ISNULL(ship_cost_fba.main_shipping_cost,0)
           WHEN VAITM.LPRIO='01' THEN ISNULL(ship_cost.main_shipping_cost,ship_cost_fbm.main_shipping_cost) 
           ELSE ISNULL(ship_cost.main_shipping_cost,0) 
           END AS AMT_SHIPPING_COST_EST_EUR
	, CASE WHEN ISNULL(VAKON.AMT_SHIPPING_COST_EST_EUR,0) = 0      THEN ISNULL(PRCD.AMT_SHIPPING_COST_EST_EUR     ,0) ELSE VAKON.AMT_SHIPPING_COST_EST_EUR      END AS AMT_SHIPPING_COST_EST_EUR
    , CASE WHEN ISNULL(VAKON.AMT_GROSS_SHIPPING_REVENUE_EUR,0) = 0 THEN ISNULL(PRCD.AMT_GROSS_SHIPPING_REVENUE_EUR,0) ELSE VAKON.AMT_GROSS_SHIPPING_REVENUE_EUR END AS AMT_GROSS_SHIPPING_REVENUE_EUR 
	, CASE WHEN ISNULL(VAKON.AMT_GROSS_SHIPPING_REVENUE_FC,0) = 0  THEN ISNULL(PRCD.AMT_GROSS_SHIPPING_REVENUE_FC ,0) ELSE VAKON.AMT_GROSS_SHIPPING_REVENUE_FC  END AS AMT_GROSS_SHIPPING_REVENUE_FC  
	, CASE WHEN ISNULL(VAKON.AMT_GROSS_PRICE_EUR,0) = 0            THEN ISNULL(PRCD.AMT_GROSS_PRICE_EUR           ,0) ELSE VAKON.AMT_GROSS_PRICE_EUR            END AS AMT_GROSS_PRICE_EUR            
	, CASE WHEN ISNULL(VAKON.AMT_GROSS_PRICE_FC,0) = 0             THEN ISNULL(PRCD.AMT_GROSS_PRICE_FC            ,0) ELSE VAKON.AMT_GROSS_PRICE_FC             END AS AMT_GROSS_PRICE_FC             
	, CASE WHEN ISNULL(VAKON.AMT_NET_DISCOUNT_EUR,0) = 0           THEN ISNULL(PRCD.AMT_NET_DISCOUNT_EUR          ,0) ELSE VAKON.AMT_NET_DISCOUNT_EUR           END AS AMT_NET_DISCOUNT_EUR           
	, CASE WHEN ISNULL(VAKON.AMT_TAX_DISCOUNTS_EUR,0) = 0          THEN ISNULL(PRCD.AMT_TAX_DISCOUNTS_EUR         ,0) ELSE VAKON.AMT_TAX_DISCOUNTS_EUR          END AS AMT_TAX_DISCOUNTS_EUR          
    , CASE WHEN ISNULL(VAKON.AMT_TAX_FREIGHT_EUR,0) = 0            THEN ISNULL(PRCD.AMT_TAX_FREIGHT_EUR           ,0) ELSE VAKON.AMT_TAX_FREIGHT_EUR            END AS AMT_TAX_FREIGHT_EUR            
    , CASE WHEN ISNULL(VAKON.AMT_TAX_TOTAL_EUR,0) = 0              THEN ISNULL(PRCD.AMT_TAX_TOTAL_EUR             ,0) ELSE VAKON.AMT_TAX_TOTAL_EUR              END AS AMT_TAX_TOTAL_EUR              
    , CASE WHEN ISNULL(VAKON.AMT_TAX_PRICE_EUR,0) = 0              THEN ISNULL(PRCD.AMT_TAX_PRICE_EUR             ,0) ELSE VAKON.AMT_TAX_PRICE_EUR              END AS AMT_TAX_PRICE_EUR              
    , CASE WHEN ISNULL(VAKON.AMT_MEK_HEDGING_EUR,0) = 0            THEN ISNULL(PRCD.AMT_MEK_HEDGING_EUR           ,0) ELSE VAKON.AMT_MEK_HEDGING_EUR            END as AMT_MEK_HEDGING_EUR   
    , CASE WHEN ISNULL(VAKON.AMT_MEK_HEDGING_EUR,0) = 0 OR GTS.GTSMARKUPRATES IS NULL THEN ISNULL(PRCD.AMT_MEK_HEDGING_EUR           ,0) ELSE VAKON.AMT_MEK_HEDGING_EUR            END 
      / (1+ ISNULL(L0_MI_OTHER_DELIVERY_COSTSRATES.OTHERDELIVERYRELATEDCOSTSRATES,0)) 
      / (1+ CASE WHEN GTS.GTSMARKUPRATES < 0 THEN 0 ELSE ISNULL(GTS.GTSMARKUPRATES,0) END) * CASE WHEN GTS.GTSMARKUPRATES < 0 THEN 0 ELSE ISNULL(GTS.GTSMARKUPRATES,0) END 
   AS AMT_GTS_MARKUP
	, VAITM.WAERK AS CD_CURRENCY
    , ph2.VTEXT as T_PRODUCT_HIERARCHY_2
    , ph1.VTEXT as T_PRODUCT_HIERARCHY_1
    , VAHDR.ERDAT AS D_DOCUMENT_CREATED
    , VAHDR.ERDAT AS D_DOCUMENT_HEADER
    , prt.Bezei   AS T_ORDER_REASON
    , vaitm.AEDAT AS D_UPDATED
    , vaitm.ABSTA AS CD_REJECTION_STATUS
    , cdpos.UDATE AS D_CANCELLATION


	, GREATEST(VAITM.LOAD_TIMESTAMP, cust.LOAD_TIMESTAMP, tReject.LOAD_TIMESTAMP, VAKON.LOAD_TIMESTAMP, stor.LOAD_TIMESTAMP, 
			   VBPARE.LOAD_TIMESTAMP, VBPAWE.LOAD_TIMESTAMP, VBPAAG.LOAD_TIMESTAMP, VAHDR.LOAD_TIMESTAMP, PRCD.LOAD_TIMESTAMP) AS LOAD_TIMESTAMP
	,CASE WHEN VAITM.[ROCANCEL] = 'X' THEN 'Y' ELSE 'N' END AS [FL_DELETED]
  FROM [L0].[L0_S4HANA_2LIS_11_VAITM] VAITM
  LEFT JOIN [L0].[L0_MI_GTS_MARKUP_RATES] GTS
	ON CAST(VAITM.MATNR AS INT) = GTS.ITEMNO
        AND VAITM.ERDAT between GTS.VALID_FROM and GTS.VALID_TO
	LEFT JOIN [L0].[L0_S4HANA_0customer_attr] cust 
		ON VAITM.KUNNR=cust.KUNNR
	LEFT JOIN L0.L0_S4HANA_0REASON_REJ_TEXT tReject 
		ON VAITM.ABGRU=tReject.ABGRU AND tReject.SPRAS='E'
    LEFT JOIN (
        SELECT 
        VAKON.VBELN,
        VAKON.POSNR,
        MAX(VAKON.LOAD_TIMESTAMP) as LOAD_TIMESTAMP,
        SUM(CASE 
                WHEN VAKON.KSCHL = 'ZNFS' 
                THEN CASE 
                          WHEN  VAKON.WAERK = 'EUR'
                          THEN VAKON.KWERT
                          WHEN VAKON.KURSK > 0
                          THEN VAKON.KWERT * VAKON.KURSK
                          WHEN VAKON.KURSK < 0
                          THEN VAKON.KWERT / ABS(VAKON.KURSK)
                     END
             ELSE 0
             END * CASE WHEN VAKON.ROCANCEL = 'R' AND VAKON.AUART in ('ZAA','ZAZ','ZKE')and v.ABGRU<> '' THEN -1 ELSE 1 END
             ) as AMT_NET_SHIPPING_REVENUE_EUR,
        SUM(CASE 
                WHEN VAKON.KSCHL = 'NTPS' 
                THEN CASE 
                          WHEN  VAKON.WAERK = 'EUR'
                          THEN VAKON.KWERT
                          WHEN VAKON.KURSK > 0
                          THEN VAKON.KWERT * VAKON.KURSK
                          WHEN VAKON.KURSK < 0
                          THEN VAKON.KWERT / ABS(VAKON.KURSK)
                     END
             ELSE 0
             END * CASE WHEN VAKON.ROCANCEL = 'R' AND VAKON.AUART in ('ZAA','ZAZ','ZKE')and v.ABGRU<> '' THEN -1 ELSE 1 END) as AMT_NET_PRICE_EUR ,
        SUM(CASE 
        WHEN VAKON.KSCHL = 'NTPS'
        THEN VAKON.KWERT
        ELSE 0
        END * CASE WHEN VAKON.ROCANCEL = 'R' AND VAKON.AUART in ('ZAA','ZAZ','ZKE')and v.ABGRU<> '' THEN -1 ELSE 1 END) as AMT_NET_PRICE_FC,
        SUM(CASE 
                WHEN VAKON.KSCHL in ('ZZU2') AND VAKON.KINAK='' 
                    THEN CASE 
                        WHEN  VAKON.WAERK = 'EUR' AND ABS(VAKON.KWERT) < 10000 --- To remove high values from data source erros from the shipment costs. will be replaced
                            THEN VAKON.KWERT
                        WHEN VAKON.KURSK > 0 AND ABS(VAKON.KWERT) < 10000 --- To remove high values from data source erros from the shipment costs. will be replaced
                            THEN VAKON.KWERT * VAKON.KURSK
                        WHEN VAKON.KURSK < 0 AND ABS(VAKON.KWERT) < 10000 --- To remove high values from data source erros from the shipment costs. will be replaced
                            THEN VAKON.KWERT / ABS(VAKON.KURSK)
                          END
                 ELSE 0
            END 
            * 
            CASE 
                WHEN VAKON.ROCANCEL = 'R' AND VAKON.AUART in ('ZAA','ZAZ','ZKE')and v.ABGRU<> ''
                    THEN -1 
                ELSE 1 
            END) AS AMT_SHIPPING_COST_EST_EUR,
        SUM(CASE 
                WHEN VAKON.KSCHL = 'ZZU3' 
                THEN CASE 
                          WHEN  VAKON.WAERK = 'EUR'
                          THEN VAKON.KWERT
                          WHEN VAKON.KURSK > 0
                          THEN VAKON.KWERT * VAKON.KURSK
                          WHEN VAKON.KURSK < 0
                          THEN VAKON.KWERT / ABS(VAKON.KURSK)
                     END
             ELSE 0
             END * CASE WHEN VAKON.ROCANCEL = 'R' AND VAKON.AUART in ('ZAA','ZAZ','ZKE') and v.ABGRU<> '' THEN -1 ELSE 1 END) as AMT_GROSS_SHIPPING_REVENUE_EUR ,
        SUM(CASE 
        WHEN VAKON.KSCHL = 'ZZU3' AND VAKON.WAERK != 'EUR'
        THEN VAKON.KWERT
        ELSE 0
        END * CASE WHEN VAKON.ROCANCEL = 'R' AND VAKON.AUART in ('ZAA','ZAZ','ZKE')and v.ABGRU<> '' THEN -1 ELSE 1 END) as AMT_GROSS_SHIPPING_REVENUE_FC,
        CASE
       	WHEN (SUM(CASE
       			WHEN VAKON.KSCHL ='ZPRM' AND VAKON.KINAK='' THEN
       				CASE
       					WHEN VAKON.WAERK = 'EUR' THEN VAKON.KWERT
       					WHEN VAKON.KURSK > 0 THEN VAKON.KWERT * VAKON.KURSK
       					WHEN VAKON.KURSK < 0 THEN VAKON.KWERT / ABS(VAKON.KURSK)
       				END
       		 ELSE 0
       		 END 	  
       		 * CASE WHEN VAKON.ROCANCEL = 'R' AND VAKON.AUART in ('ZAA','ZAZ','ZKE')and v.ABGRU<> '' THEN -1 ELSE 1
       		 END)) = 0  -- Check if ZPRM is null  
           THEN (SUM(CASE
       			WHEN VAKON.KSCHL = 'ZPR0' AND VAKON.KINAK='' THEN
       				CASE
       					WHEN VAKON.WAERK = 'EUR' THEN VAKON.KWERT
       					WHEN VAKON.KURSK > 0 THEN VAKON.KWERT * VAKON.KURSK
       					WHEN VAKON.KURSK < 0 THEN VAKON.KWERT / ABS(VAKON.KURSK)
       				END
       			ELSE 0
       		  END 	  
       				* CASE WHEN VAKON.ROCANCEL = 'R' AND VAKON.AUART in ('ZAA','ZAZ','ZKE')and v.ABGRU<> '' THEN -1 ELSE 1
       		  END))	-- In case ZPRM si null use sum of ZPR0	
       	ELSE (SUM(CASE
       			WHEN VAKON.KSCHL ='ZPRM' AND VAKON.KINAK='' THEN
       				CASE
       					WHEN VAKON.WAERK = 'EUR' THEN VAKON.KWERT
       					WHEN VAKON.KURSK > 0 THEN VAKON.KWERT * VAKON.KURSK
       					WHEN VAKON.KURSK < 0 THEN VAKON.KWERT / ABS(VAKON.KURSK)
       				END
       		 ELSE 0
       		 END 	  
       		 * CASE WHEN VAKON.ROCANCEL = 'R' AND VAKON.AUART in ('ZAA','ZAZ','ZKE')and v.ABGRU<> '' THEN -1 ELSE 1
       		 END)) -- else use ZPRM sum in case it is not 0
       	END as AMT_GROSS_PRICE_EUR ,
         CASE
	            WHEN (SUM((CASE
	            				WHEN VAKON.KSCHL ='ZPRM' AND VAKON.KINAK='' THEN VAKON.KWERT
	            				ELSE 0
	            			END) 		
	            		* CASE WHEN VAKON.ROCANCEL = 'R' AND VAKON.AUART in ('ZAA','ZAZ','ZKE')and v.ABGRU<> '' THEN -1 ELSE 1 END))=0
	            THEN (SUM((CASE
	            				WHEN VAKON.KSCHL ='ZPR0' AND VAKON.KINAK='' THEN VAKON.KWERT
	            				ELSE 0
	            			END) 		
	            		* CASE WHEN VAKON.ROCANCEL = 'R' AND VAKON.AUART in ('ZAA','ZAZ','ZKE')and v.ABGRU<> '' THEN -1 ELSE 1 END))
	            ELSE SUM((CASE
	            				WHEN VAKON.KSCHL ='ZPRM' AND VAKON.KINAK=''  THEN VAKON.KWERT
	            				ELSE 0
	            			END) 		
	            		* CASE WHEN VAKON.ROCANCEL = 'R' AND VAKON.AUART in ('ZAA','ZAZ','ZKE')and v.ABGRU<> '' THEN -1 ELSE 1 END) 
        END as AMT_GROSS_PRICE_FC,
        SUM(CASE 
                WHEN VAKON.KSCHL in ('ZRAK', 'ZRB1','ZRB3','ZRB4','ZRAP','ZRAV','ZRAW','ZRB2','ZRRP', 'ZMW2')  
                THEN CASE 
                          WHEN  VAKON.WAERK = 'EUR'
                          THEN VAKON.KWERT 
                          WHEN VAKON.KURSK > 0
                          THEN VAKON.KWERT * VAKON.KURSK 
                          WHEN VAKON.KURSK < 0
                          THEN VAKON.KWERT / ABS(VAKON.KURSK) 
                     END
             ELSE 0
             END * CASE WHEN VAKON.ROCANCEL = 'R' AND VAKON.AUART in ('ZAA','ZAZ','ZKE')and v.ABGRU<> '' THEN -1 ELSE 1 END) as AMT_NET_DISCOUNT_EUR,
        SUM(CASE 
                WHEN VAKON.KSCHL in ( 'ZMW2')  
                THEN CASE 
                          WHEN  VAKON.WAERK = 'EUR'
                          THEN VAKON.KWERT 
                          WHEN VAKON.KURSK > 0
                          THEN VAKON.KWERT * VAKON.KURSK 
                          WHEN VAKON.KURSK < 0
                          THEN VAKON.KWERT / ABS(VAKON.KURSK) 
                     END
             ELSE 0
             END * CASE WHEN VAKON.ROCANCEL = 'R' AND VAKON.AUART in ('ZAA','ZAZ','ZKE')and v.ABGRU<> '' THEN -1 ELSE 1 END) as AMT_TAX_DISCOUNTS_EUR,
        SUM(CASE 
                WHEN VAKON.KSCHL in ( 'ZMWF')  
                THEN CASE 
                          WHEN  VAKON.WAERK = 'EUR'
                          THEN VAKON.KWERT 
                          WHEN VAKON.KURSK > 0
                          THEN VAKON.KWERT * VAKON.KURSK 
                          WHEN VAKON.KURSK < 0
                          THEN VAKON.KWERT / ABS(VAKON.KURSK) 
                     END
             ELSE 0
             END * CASE WHEN VAKON.ROCANCEL = 'R' AND VAKON.AUART in ('ZAA','ZAZ','ZKE')and v.ABGRU<> '' THEN -1 ELSE 1 END) as AMT_TAX_FREIGHT_EUR,
        SUM(CASE 
                WHEN VAKON.KSCHL in ( 'ZMWS')  
                THEN CASE 
                          WHEN  VAKON.WAERK = 'EUR'
                          THEN VAKON.KWERT 
                          WHEN VAKON.KURSK > 0
                          THEN VAKON.KWERT * VAKON.KURSK 
                          WHEN VAKON.KURSK < 0
                          THEN VAKON.KWERT / ABS(VAKON.KURSK) 
                     END
             ELSE 0
             END * CASE WHEN VAKON.ROCANCEL = 'R' AND VAKON.AUART in ('ZAA','ZAZ','ZKE')and v.ABGRU<> '' THEN -1 ELSE 1 END) as AMT_TAX_TOTAL_EUR,
        SUM(CASE 
                WHEN VAKON.KSCHL in ( 'ZMWI')  
                THEN CASE 
                          WHEN  VAKON.WAERK = 'EUR'
                          THEN VAKON.KWERT 
                          WHEN VAKON.KURSK > 0
                          THEN VAKON.KWERT * VAKON.KURSK 
                          WHEN VAKON.KURSK < 0
                          THEN VAKON.KWERT / ABS(VAKON.KURSK) 
                     END
             ELSE 0
             END * CASE WHEN VAKON.ROCANCEL = 'R' AND VAKON.AUART in ('ZAA','ZAZ','ZKE')and v.ABGRU<> '' THEN -1 ELSE 1 END) as AMT_TAX_PRICE_EUR,
        SUM(CASE 
                WHEN VAKON.KSCHL in ( 'PCIP')  
                THEN CASE 
                          WHEN  VAKON.WAERK = 'EUR'
                          THEN VAKON.KWERT 
                          WHEN VAKON.KURSK > 0
                          THEN VAKON.KWERT * VAKON.KURSK 
                          WHEN VAKON.KURSK < 0
                          THEN VAKON.KWERT / ABS(VAKON.KURSK) 
                     END
             ELSE 0
             END * CASE WHEN VAKON.ROCANCEL = 'R' AND VAKON.AUART in ('ZAA','ZAZ','ZKE')and v.ABGRU<> '' THEN -1 ELSE 1 END) as AMT_MEK_HEDGING_EUR
    FROM  L0.L0_S4HANA_2LIS_11_VAKON VAKON
        INNER JOIN L0.L0_S4HANA_2LIS_11_VAITM v
		on v.VBELN = vakon.VBELN and v.POSNR = vakon.POSNR
        WHERE 	(VAKON.ROCANCEL <> 'R' AND  v.ABGRU= '') OR (VAKON.ROCANCEL = 'R' AND  v.ABGRU<> '')
    group by VAKON.VBELN,VAKON.POSNR
    ) VAKON
    ON VAITM.VBELN = VAKON.VBELN AND VAITM.POSNR = VAKON.POSNR
-- Storage location
	LEFT JOIN [L0].[L0_S4HANA_0STOR_LOC_TEXT] stor ON stor.LGORT=VAITM.LGORT
    AND stor.WERKS=VAITM.WERKS
-- Storage location v2
    LEFT JOIN [L0].[L0_MI_STORAGE_LOCATION] stor1 
            ON stor1.STORAGELOCATIONCODE=VAITM.LGORT
             AND stor1.COMPANYCODE=VAITM.WERKS
             AND stor1.Source = 'SAP'
-- Storage Location Surrogation Key
    LEFT JOIN [WR].WR_SRG_L1_DIM_A_STORAGE_LOCATION storkey 
            ON  storkey.CD_STORAGE_LOCATION = VAITM.LGORT
                AND storkey.CD_SOURCE_SYSTEM = 'SAP'
                AND storkey.CD_COMPANY_CODE = VAITM.WERKS
-- Invoice address
    LEFT JOIN (SELECT VBELN, KUNNR, LAND1,LOAD_TIMESTAMP, ROW_NUMBER() OVER (PARTITION BY VBELN ORDER BY POSNR DESC) as rownum FROM L0.L0_S4HANA_Z_SD_VBPA_V2
			WHERE PARVW='RE') VBPARE ON VAITM.VBELN = VBPARE.VBELN and VBPARE.rownum=1
    LEFT JOIN [L0].[L0_S4HANA_0customer_attr] CUSTRE ON VBPARE.KUNNR=CUSTRE.KUNNR
-- Delivery address
	LEFT JOIN (SELECT VBELN, KUNNR, LAND1,LOAD_TIMESTAMP, ROW_NUMBER() OVER (PARTITION BY VBELN ORDER BY POSNR DESC) as rownum FROM L0.L0_S4HANA_Z_SD_VBPA_V2
			WHERE PARVW='WE') VBPAWE ON VAITM.VBELN = VBPAWE.VBELN and VBPAWE.rownum=1
	LEFT JOIN [L0].[L0_S4HANA_0customer_attr] CUSTWE ON VBPAWE.KUNNR = CUSTWE.KUNNR
-- Order address
	LEFT JOIN (SELECT VBELN, KUNNR, LAND1,LOAD_TIMESTAMP, ROW_NUMBER() OVER (PARTITION BY VBELN ORDER BY POSNR DESC) as rownum FROM L0.L0_S4HANA_Z_SD_VBPA_V2
			WHERE PARVW='AG') VBPAAG ON VAITM.VBELN = VBPAAG.VBELN and VBPAAG.rownum=1
	LEFT JOIN [L0].[L0_S4HANA_0customer_attr] CUSTAG ON VBPAAG.KUNNR = CUSTAG.KUNNR
-- Customer service agent
    LEFT JOIN (SELECT VBELN, KUNNR, LOAD_TIMESTAMP, ROW_NUMBER() OVER (PARTITION BY VBELN ORDER BY POSNR DESC) as rownum FROM L0.L0_S4HANA_Z_SD_VBPA_V2
			WHERE PARVW='Z1') VBPAZ1 ON VAITM.VBELN = VBPAZ1.VBELN and VBPAZ1.rownum=1
    LEFT JOIN [L0].[L0_MI_CUSTOMER_SERVICE_AGENTS] csa  ON TRY_PARSE(VBPAZ1.KUNNR AS INT) = csa.USERNAMEOXID
-- Item ID from Surrogation table
	LEFT JOIN [WR].[WR_SRG_L1_DIM_A_ITEM] srgitem ON srgitem.CD_SOURCE_SYSTEM='SAP' AND srgitem.CD_ITEM=VAITM.MATNR
--Marketplace Order ID
	LEFT JOIN [L0].[L0_S4HANA_2LIS_11_VAHDR] VAHDR ON VAHDR.VBELN=VAITM.VBELN
-- ID Sales Channel
	LEFT JOIN [WR].[WR_SRG_L1_DIM_A_SALES_CHANNEL] wr_sales_channel 
		ON VAITM.[VKBUR]=wr_sales_channel.CD_SALES_CHANNEL AND wr_sales_channel.CD_SOURCE_SYSTEM='SAP'
-- Join Sales Channel to get ChannelCountry
LEFT JOIN [L1].[L1_DIM_A_SALES_CHANNEL] channel_groups
	ON channel_groups.cd_sales_channel = VAITM.[VKBUR]
	AND channel_groups.cd_source_system = 'SAP'
-- Process ID
	LEFT JOIN [L0].[L0_S4HANA_Z_SD_VBFA] procid 
		ON procid.SUBSEQUENTDOCUMENT=VAITM.VBELN AND procid.SUBSEQUENTDOCUMENTITEM=VAITM.POSNR AND procid.PRECEDINGDOCUMENTCATEGORY = 'C'
    LEFT JOIN [L0].[L0_S4HANA_2LIS_11_VAITM] VAITM2
		ON procid.PRECEDINGDOCUMENT = VAITM2.VBELN
		AND procid.PRECEDINGDOCUMENTITEM = VAITM2.POSNR
    LEFT JOIN (
        SELECT
        PRCD_ELEMENTS_CALC.VBELN,
        PRCD_ELEMENTS_CALC.POSNR,
        MAX(LOAD_TIMESTAMP) as LOAD_TIMESTAMP,
        SUM(CASE 
                WHEN PRCD_ELEMENTS_CALC.KSCHL = 'ZNFS' 
                THEN CASE 
                          WHEN  PRCD_ELEMENTS_CALC.WAERK = 'EUR'
                          THEN PRCD_ELEMENTS_CALC.KWERT
                          WHEN PRCD_ELEMENTS_CALC.KURSK > 0
                          THEN PRCD_ELEMENTS_CALC.KWERT * PRCD_ELEMENTS_CALC.KURSK
                          WHEN PRCD_ELEMENTS_CALC.KURSK < 0
                          THEN PRCD_ELEMENTS_CALC.KWERT / ABS(PRCD_ELEMENTS_CALC.KURSK)
                     END
             ELSE 0
             END
             ) as AMT_NET_SHIPPING_REVENUE_EUR,
        SUM(CASE 
                WHEN PRCD_ELEMENTS_CALC.KSCHL = 'NTPS' 
                THEN CASE 
                          WHEN  PRCD_ELEMENTS_CALC.WAERK = 'EUR'
                          THEN PRCD_ELEMENTS_CALC.KWERT
                          WHEN PRCD_ELEMENTS_CALC.KURSK > 0
                          THEN PRCD_ELEMENTS_CALC.KWERT * PRCD_ELEMENTS_CALC.KURSK
                          WHEN PRCD_ELEMENTS_CALC.KURSK < 0
                          THEN PRCD_ELEMENTS_CALC.KWERT / ABS(PRCD_ELEMENTS_CALC.KURSK)
                     END
             ELSE 0
             END) as AMT_NET_PRICE_EUR ,
        SUM(CASE 
        WHEN PRCD_ELEMENTS_CALC.KSCHL = 'NTPS'
        THEN PRCD_ELEMENTS_CALC.KWERT
        ELSE 0
        END) as AMT_NET_PRICE_FC,
        SUM(CASE 
                WHEN PRCD_ELEMENTS_CALC.KSCHL in ('ZZU2') AND PRCD_ELEMENTS_CALC.KINAK='' 
                    THEN CASE 
                        WHEN  PRCD_ELEMENTS_CALC.WAERK = 'EUR'  AND ABS(PRCD_ELEMENTS_CALC.KWERT) < 10000
                            THEN PRCD_ELEMENTS_CALC.KWERT
                        WHEN PRCD_ELEMENTS_CALC.KURSK > 0  AND ABS(PRCD_ELEMENTS_CALC.KWERT) < 10000
                            THEN PRCD_ELEMENTS_CALC.KWERT * PRCD_ELEMENTS_CALC.KURSK
                        WHEN PRCD_ELEMENTS_CALC.KURSK < 0  AND ABS(PRCD_ELEMENTS_CALC.KWERT) < 10000
                            THEN PRCD_ELEMENTS_CALC.KWERT / ABS(PRCD_ELEMENTS_CALC.KURSK)
                          END
                 ELSE 0
            END) AS AMT_SHIPPING_COST_EST_EUR,
        SUM(CASE 
                WHEN PRCD_ELEMENTS_CALC.KSCHL = 'ZZU3' 
                THEN CASE 
                          WHEN  PRCD_ELEMENTS_CALC.WAERK = 'EUR'
                          THEN PRCD_ELEMENTS_CALC.KWERT
                          WHEN PRCD_ELEMENTS_CALC.KURSK > 0
                          THEN PRCD_ELEMENTS_CALC.KWERT * PRCD_ELEMENTS_CALC.KURSK
                          WHEN PRCD_ELEMENTS_CALC.KURSK < 0
                          THEN PRCD_ELEMENTS_CALC.KWERT / ABS(PRCD_ELEMENTS_CALC.KURSK)
                     END
             ELSE 0
             END) as AMT_GROSS_SHIPPING_REVENUE_EUR ,
        SUM(CASE 
        WHEN PRCD_ELEMENTS_CALC.KSCHL = 'ZZU3' AND PRCD_ELEMENTS_CALC.WAERK != 'EUR'
        THEN PRCD_ELEMENTS_CALC.KWERT
        ELSE 0
        END) as AMT_GROSS_SHIPPING_REVENUE_FC,
        CASE
        	WHEN
        		(SUM(CASE
        				WHEN PRCD_ELEMENTS_CALC.KSCHL='ZPRM' AND PRCD_ELEMENTS_CALC.KINAK='W'
        				THEN
        					CASE
        					  WHEN  PRCD_ELEMENTS_CALC.WAERK = 'EUR'
        					  THEN PRCD_ELEMENTS_CALC.KWERT
        					  WHEN PRCD_ELEMENTS_CALC.KURSK > 0
        					  THEN PRCD_ELEMENTS_CALC.KWERT * PRCD_ELEMENTS_CALC.KURSK
        					  WHEN PRCD_ELEMENTS_CALC.KURSK < 0
        					  THEN PRCD_ELEMENTS_CALC.KWERT / ABS(PRCD_ELEMENTS_CALC.KURSK)
        					END
        				ELSE 0
        		END))=0
        	THEN
        		SUM(CASE
        				WHEN PRCD_ELEMENTS_CALC.KSCHL='ZPR0' AND PRCD_ELEMENTS_CALC.KINAK='W'
        				THEN
        					CASE
        					  WHEN  PRCD_ELEMENTS_CALC.WAERK = 'EUR'
        					  THEN PRCD_ELEMENTS_CALC.KWERT
        					  WHEN PRCD_ELEMENTS_CALC.KURSK > 0
        					  THEN PRCD_ELEMENTS_CALC.KWERT * PRCD_ELEMENTS_CALC.KURSK
        					  WHEN PRCD_ELEMENTS_CALC.KURSK < 0
        					  THEN PRCD_ELEMENTS_CALC.KWERT / ABS(PRCD_ELEMENTS_CALC.KURSK)
        					END
        				ELSE 0
        		 END)
        	ELSE
        		(SUM(CASE
                        WHEN PRCD_ELEMENTS_CALC.KSCHL='ZPRM' AND PRCD_ELEMENTS_CALC.KINAK='W'
                        THEN CASE
                                  WHEN  PRCD_ELEMENTS_CALC.WAERK = 'EUR'
                                  THEN PRCD_ELEMENTS_CALC.KWERT
                                  WHEN PRCD_ELEMENTS_CALC.KURSK > 0
                                  THEN PRCD_ELEMENTS_CALC.KWERT * PRCD_ELEMENTS_CALC.KURSK
                                  WHEN PRCD_ELEMENTS_CALC.KURSK < 0
                                  THEN PRCD_ELEMENTS_CALC.KWERT / ABS(PRCD_ELEMENTS_CALC.KURSK)
                             END
                     ELSE 0
                     END))
        END  as AMT_GROSS_PRICE_EUR,
	    CASE
        WHEN 
        	(SUM(CASE 
        			WHEN PRCD_ELEMENTS_CALC.KSCHL ='ZPRM'  AND PRCD_ELEMENTS_CALC.KINAK='W' THEN PRCD_ELEMENTS_CALC.KWERT
        			ELSE 0
        			END))=0
        THEN
        	SUM(CASE 
        			WHEN PRCD_ELEMENTS_CALC.KSCHL ='ZPR0' AND PRCD_ELEMENTS_CALC.KINAK='W' THEN PRCD_ELEMENTS_CALC.KWERT
        			ELSE 0
        			END)				
        ELSE 
        	SUM(CASE 
        				WHEN PRCD_ELEMENTS_CALC.KSCHL ='ZPRM'  AND PRCD_ELEMENTS_CALC.KINAK='W' THEN PRCD_ELEMENTS_CALC.KWERT
        				ELSE 0
        				END)
        END as AMT_GROSS_PRICE_FC,
        SUM(CASE 
                WHEN PRCD_ELEMENTS_CALC.KSCHL in ('ZRAK', 'ZRB1','ZRB3','ZRB4','ZRAP','ZRAV','ZRAW','ZRB2','ZRRP', 'ZMW2')  
                THEN CASE 
                          WHEN  PRCD_ELEMENTS_CALC.WAERK = 'EUR'
                          THEN PRCD_ELEMENTS_CALC.KWERT 
                          WHEN PRCD_ELEMENTS_CALC.KURSK > 0
                          THEN PRCD_ELEMENTS_CALC.KWERT 
                          WHEN PRCD_ELEMENTS_CALC.KURSK < 0
                          THEN PRCD_ELEMENTS_CALC.KWERT / ABS(PRCD_ELEMENTS_CALC.KURSK) 
                     END
             ELSE 0
             END) as AMT_NET_DISCOUNT_EUR,
        SUM(CASE 
                WHEN PRCD_ELEMENTS_CALC.KSCHL in ( 'ZMW2')  
                THEN CASE 
                          WHEN  PRCD_ELEMENTS_CALC.WAERK = 'EUR'
                          THEN PRCD_ELEMENTS_CALC.KWERT 
                          WHEN PRCD_ELEMENTS_CALC.KURSK > 0
                          THEN PRCD_ELEMENTS_CALC.KWERT * PRCD_ELEMENTS_CALC.KURSK 
                          WHEN PRCD_ELEMENTS_CALC.KURSK < 0
                          THEN PRCD_ELEMENTS_CALC.KWERT / ABS(PRCD_ELEMENTS_CALC.KURSK) 
                     END
             ELSE 0
             END) as AMT_TAX_DISCOUNTS_EUR,
        SUM(CASE 
                WHEN PRCD_ELEMENTS_CALC.KSCHL in ( 'ZMWF')  
                THEN CASE 
                          WHEN  PRCD_ELEMENTS_CALC.WAERK = 'EUR'
                          THEN PRCD_ELEMENTS_CALC.KWERT 
                          WHEN PRCD_ELEMENTS_CALC.KURSK > 0
                          THEN PRCD_ELEMENTS_CALC.KWERT * PRCD_ELEMENTS_CALC.KURSK 
                          WHEN PRCD_ELEMENTS_CALC.KURSK < 0
                          THEN PRCD_ELEMENTS_CALC.KWERT / ABS(PRCD_ELEMENTS_CALC.KURSK) 
                     END
             ELSE 0
             END) as AMT_TAX_FREIGHT_EUR,
        SUM(CASE 
                WHEN PRCD_ELEMENTS_CALC.KSCHL in ( 'ZMWS')  
                THEN CASE 
                          WHEN  PRCD_ELEMENTS_CALC.WAERK = 'EUR'
                          THEN PRCD_ELEMENTS_CALC.KWERT 
                          WHEN PRCD_ELEMENTS_CALC.KURSK > 0
                          THEN PRCD_ELEMENTS_CALC.KWERT * PRCD_ELEMENTS_CALC.KURSK 
                          WHEN PRCD_ELEMENTS_CALC.KURSK < 0
                          THEN PRCD_ELEMENTS_CALC.KWERT / ABS(PRCD_ELEMENTS_CALC.KURSK) 
                     END
             ELSE 0
             END) as AMT_TAX_TOTAL_EUR,
        SUM(CASE 
                WHEN PRCD_ELEMENTS_CALC.KSCHL in ( 'ZMWI')  
                THEN CASE 
                          WHEN  PRCD_ELEMENTS_CALC.WAERK = 'EUR'
                          THEN PRCD_ELEMENTS_CALC.KWERT 
                          WHEN PRCD_ELEMENTS_CALC.KURSK > 0
                          THEN PRCD_ELEMENTS_CALC.KWERT * PRCD_ELEMENTS_CALC.KURSK 
                          WHEN PRCD_ELEMENTS_CALC.KURSK < 0
                          THEN PRCD_ELEMENTS_CALC.KWERT / ABS(PRCD_ELEMENTS_CALC.KURSK) 
                     END
             ELSE 0
             END) as AMT_TAX_PRICE_EUR,
        SUM(CASE 
                WHEN PRCD_ELEMENTS_CALC.KSCHL in ( 'PCIP')  
                THEN CASE 
                          WHEN  PRCD_ELEMENTS_CALC.WAERK = 'EUR'
                            THEN PRCD_ELEMENTS_CALC.KWERT 
                          WHEN PRCD_ELEMENTS_CALC.WAERS = 'EUR' AND ABS(KWERT_K) > 0
							THEN PRCD_ELEMENTS_CALC.KWERT_K
                          WHEN PRCD_ELEMENTS_CALC.KURSK > 0
                            THEN PRCD_ELEMENTS_CALC.KWERT * PRCD_ELEMENTS_CALC.KURSK 
                          WHEN PRCD_ELEMENTS_CALC.KURSK < 0
                            THEN PRCD_ELEMENTS_CALC.KWERT / ABS(PRCD_ELEMENTS_CALC.KURSK) 
                     END
             ELSE 0
             END) as AMT_MEK_HEDGING_EUR
    FROM  (SELECT VBAK.VBELN as VBELN
                ,PRCD_ELEMENTS.[KNUMV]
                ,PRCD_ELEMENTS.[KPOSN] as POSNR
                ,PRCD_ELEMENTS.WAERK as WAERK
                ,PRCD_ELEMENTS.WAERS as WAERS
                ,PRCD_ELEMENTS.KKURS as KURSK
                ,PRCD_ELEMENTS.KWERT as KWERT
                ,PRCD_ELEMENTS.KWERT_K as KWERT_K
                ,PRCD_ELEMENTS.KSCHL as KSCHL
                ,VBAK.AUART
                ,PRCD_ELEMENTS.KINAK as KINAK
                ,GREATEST(PRCD_ELEMENTS.LOAD_TIMESTAMP, VBAK.LOAD_TIMESTAMP ) as LOAD_TIMESTAMP
           FROM [L0].[L0_S4HANA_PRCD_ELEMENTS] PRCD_ELEMENTS
                INNER JOIN L0.L0_S4HANA_VBAK VBAK 
                ON PRCD_ELEMENTS.KNUMV = VBAK.KNUMV
           WHERE EXISTS ( SELECT 1 FROM L0.L0_S4HANA_2LIS_11_VAITM VAITM WHERE VBAK.VBELN = VAITM.VBELN )
                and NOT EXISTS ( SELECT 1 FROM L0.L0_S4HANA_2LIS_11_VAKON VAKON WHERE VBAK.VBELN = VAKON.VBELN )
        ) PRCD_ELEMENTS_CALC
    group by VBELN,POSNR
    ) PRCD
    ON PRCD.VBELN = VAITM.VBELN AND PRCD.POSNR = VAITM.POSNR
    LEFT JOIN [WR].[WR_SRG_L1_DIM_A_SALES_TRANSACTION_TYPE] wr_sales_transaction_type 
        ON wr_sales_transaction_type.CD_SALES_TRANSACTION_TYPE = CONCAT(VAITM.AUART,'#AUART')
        AND wr_sales_transaction_type.CD_SOURCE_SYSTEM = 'SAP'
    LEFT JOIN  [L0].[L0_MI_OTHER_DELIVERY_COSTSRATES] L0_MI_OTHER_DELIVERY_COSTSRATES
        ON VAITM.ERDAT between L0_MI_OTHER_DELIVERY_COSTSRATES.VALID_FROM and L0_MI_OTHER_DELIVERY_COSTSRATES.VALID_TO
    LEFT JOIN [WR].[WR_SRG_L1_DIM_A_COMPANY] wr_company 
        ON VAITM.BUKRS = wr_company.CD_COMPANY 
        AND wr_company.CD_SOURCE_SYSTEM = 'SAP'
    LEFT JOIN [WR].[WR_TMP_CD_SIZE_BRACKET] sizebracket 
        ON VAITM.MATNR = sizebracket.MATNR
    LEFT JOIN [WR].[WR_TMP_CD_SIZE_BRACKET_FBA] sizebracket_fba
        ON VAITM.MATNR = sizebracket_fba.MATNR
    LEFT JOIN L0.L0_S4HANA_0MATERIAL_ATTR material
        ON VAITM.MATNR = material.MATNR
    LEFT JOIN L0.L0_S4HANA_0ORD_REASON_TEXT prt
        ON VAHDR.AUGRU = prt.AUGRU AND prt.SPRAS = 'E'
    LEFT JOIN L0.L0_S4HANA_0PROD_HIER_TEXT ph1 
        ON  SUBSTRING(material.PRDHA,0,4) = ph1.PRODH AND ph1.SPRAS = 'E'
    LEFT JOIN L0.L0_S4HANA_0PROD_HIER_TEXT ph2
        ON SUBSTRING(material.PRDHA,0,10) = ph2.PRODH AND ph2.SPRAS = 'E'
    --shipping cost without FBA
    LEFT JOIN CTE_SHIPP_COSTS ship_cost
        ON CAST(VAITM.MATNR AS BIGINT) = ship_cost.Item_code
        AND VBPAWE.LAND1=ship_cost.country
	    AND stor1.STORAGELOCATION=ship_cost.warehouse
		AND ship_cost.Fulfillment  != 'FBA'
        AND CASE
		WHEN VAITM.VKBUR like '60%'
			THEN 'FBA'
		WHEN VAITM.LPRIO='01'
			THEN 'PBM'
		ELSE 'FBM'
	END = ship_cost.Fulfillment 
    --fallback for PBM shipping cost
    LEFT JOIN CTE_SHIPP_COSTS ship_cost_fbm
	ON CAST(VAITM.MATNR AS BIGINT) = ship_cost_fbm.Item_code
        AND VBPAWE.LAND1=ship_cost_fbm.country
	    AND stor1.STORAGELOCATION=ship_cost_fbm.warehouse
        AND ship_cost_fbm.Fulfillment = 'FBM'
    --shipping cost FBA
    LEFT JOIN CTE_SHIPP_COSTS ship_cost_fba
  	    ON CAST(VAITM.MATNR AS BIGINT) = ship_cost_fba.Item_code
        AND (
                (channel_groups.CD_CHANNEL_COUNTRY <> 'GB' AND channel_groups.CD_CHANNEL_COUNTRY=ship_cost_fba.country )
                OR
                (channel_groups.CD_CHANNEL_COUNTRY = 'GB' AND VBPAWE.LAND1=ship_cost_fba.country)
               )
        AND (
				(channel_groups.CD_CHANNEL_COUNTRY <> 'GB' AND ship_cost_fba.warehouse_id=2 )
				OR
				(channel_groups.CD_CHANNEL_COUNTRY = 'GB' AND ship_cost_fba.warehouse_id=1)
			)
        AND ship_cost_fba.Fulfillment = 'FBA'
		AND CASE WHEN VAITM.VKBUR like '60%'
			    THEN 'FBA' END = ship_cost_fba.Fulfillment 
    ---Cancellation Date
    LEFT JOIN 
    (
        SELECT 	OBJECTID, [TABKEY],UDATE,RANK() OVER(partition by OBJECTID,SUBSTRING([TABKEY],14,6) order by CHANGENR asc) rk
            FROM L0.L0_S4HANA_Z_MM_CDHDR_CDPOS_V 
        where FNAME = 'ABGRU' AND TABNAME = 'VBAP' and ISNULL(VALUE_OLD,'') = '' and ISNULL(VALUE_NEW,'') <> ''
    )
    
    cdpos
        ON 
            cdpos.OBJECTID = vaitm.VBELN
            AND SUBSTRING(cdpos.[TABKEY],14,6) =vaitm.POSNR
            AND rk = 1
    --Incident Flag
    LEFT JOIN [L0].[L0_MI_INCIDENT_MAPPING] incident
    ON incident.SOURCE = 'SAP'
    AND incident.COMPANYCODE = wr_company.CD_COMPANY
    AND incident.DOCUMENTNO = cast(vaitm.VBELN as bigint)
    AND incident.TRANSACTIONDATE = vaitm.ERDAT
    WHERE 
		(  
            @LOAD_START_DATE IS NULL
            OR
            CASE WHEN VAITM.ZZ_CPD_UPDAT = 0 THEN VAITM.ERDAT  ELSE CAST(LEFT(VAITM.ZZ_CPD_UPDAT,8) as date) END >= @LOAD_START_DATE

        )


/****************************************************************
** KITTING ITEMS LOGIC
** For SAP the logic of kitting is split, the revenue is connected 
**      to the main element while the cogs are assigned to the subpositions.
**  As the subpositions will be filtered out in kpi calculation we need to aggreggate the cost values 
** into the main position
*****************************************************************/



;WITH CTE_KITTING AS (
	SELECT 
			CD_DOCUMENT_NO,
			(TRY_CAST (CD_DOCUMENT_LINE AS INT) / 100) MainPosition,
			SUM([AMT_MEK_HEDGING_EUR])[AMT_MEK_HEDGING_EUR],
			SUM([AMT_GTS_MARKUP])[AMT_GTS_MARKUP]
		FROM WR.WR_L1_FACT_A_SALES_TRANSACTION fact
		INNER JOIN L1.L1_DIM_A_ITEM it
			on it.ID_ITEM = fact.ID_ITEM
	WHERE 	
	 fact.cd_source_system = 'SAP'
	AND it.NUM_ITEM like '7%'
	GROUP BY CD_DOCUMENT_NO, TRY_CAST (CD_DOCUMENT_LINE AS INT) / 100
)

UPDATE 	wr
	SET 
		wr.[AMT_MEK_HEDGING_EUR]= k.[AMT_MEK_HEDGING_EUR],
		wr.[AMT_GTS_MARKUP] = k.[AMT_GTS_MARKUP]
FROM [TEST].[WR_L1_FACT_A_SALES_TRANSACTION_CAPO] wr
INNER JOIN CTE_KITTING k
	on k.CD_DOCUMENT_NO = wr.CD_DOCUMENT_NO
	AND (k.MainPosition *100 ) = TRY_CAST(wr.CD_DOCUMENT_LINE AS INT)
	AND wr.cd_source_system = 'SAP'
WHERE 
    TRY_CAST(wr.CD_DOCUMENT_LINE AS INT) >0

/****************************************************************
** SET ITEMS LOGIC
** For SAP the logic of set's is split, the revenue is connected 
**      to the main element while the cogs are assigned to the subpositions.
**  As the main element will be filtered out in kpi calculation we need to split the revenue values 
** into the subpositions according with the cost share
*****************************************************************/
;WITH CTE_SET_ORDERS AS (
    ---used to filter down the necessary documents to update (only the ones withn set items (starting with 6) 
    SELECT
		 
			CD_DOCUMENT_NO
			,(TRY_CAST (CD_DOCUMENT_LINE AS INT) / 100) AS CD_DOCUMENT_LINE
			,it.NUM_ITEM 
			,SUM(sum(CASE WHEN NUM_ITEM like'6%' THEN 0 ELSE AMT_MEK_HEDGING_EUR END)) OVER(PARTITION BY fact.CD_DOCUMENT_NO,(TRY_CAST (CD_DOCUMENT_LINE AS INT) / 100) )  AS AMT_TOTAL_MEK
			,SUM(CASE WHEN NUM_ITEM like '6%' THEN AMT_NET_PRICE_EUR ELSE 0 END) AS AMT_TOTAL_NET_PRICE_EUR
			,SUM(CASE WHEN NUM_ITEM like '6%' THEN AMT_NET_SHIPPING_REVENUE_EUR ELSE 0 END) AS AMT_TOTAL_NET_SHIPPING_REVENUE_EUR
			,SUM(CASE WHEN NUM_ITEM like '6%' THEN AMT_GROSS_PRICE_EUR ELSE 0 END) AS AMT_TOTAL_GROSS_PRICE_EUR
			,SUM(CASE WHEN NUM_ITEM like '6%' THEN AMT_TAX_PRICE_EUR ELSE 0 END) AS AMT_TOTAL_TAX_PRICE_EUR
			,SUM(CASE WHEN NUM_ITEM like '6%' THEN AMT_NET_DISCOUNT_EUR ELSE 0 END) AS AMT_TOTAL_NET_DISCOUNT_EUR
    FROM [TEST].[WR_L1_FACT_A_SALES_TRANSACTION_CAPO] fact
    INNER JOIN L1.L1_DIM_A_ITEM it
			on it.ID_ITEM = fact.ID_ITEM
    WHERE 
        fact.CD_SOURCE_SYSTEM = 'SAP' 
	    AND CD_TYPE in ('ZAA','ZAZ','ZKE') 
	GROUP BY fact.cd_document_no,it.NUM_ITEM,(TRY_CAST (CD_DOCUMENT_LINE AS INT) / 100)
)
,
CTE_UPDATED_SETS AS
(
--Apply the window functions for the distribution of the revenue from teh main item to the componest by cost share and the quantity by qty share
SELECT 
fact.CD_DOCUMENT_NO,
	fact.CD_DOCUMENT_LINE,
    ID_ITEM_PARENT = MIN(CASE WHEN it.NUM_ITEM like '6%' THEN fact.ID_ITEM ELSE NULL END) OVER (PARTITION BY fact.CD_DOCUMENT_NO,(TRY_CAST (fact.CD_DOCUMENT_LINE AS INT) / 100)), 
	AMT_NET_SHIPPING_REVENUE_EUR = 
							CASE 
									WHEN it.NUM_ITEM like '6%' THEN AMT_NET_SHIPPING_REVENUE_EUR 
											ELSE ord.AMT_TOTAL_NET_SHIPPING_REVENUE_EUR * (SUM(AMT_MEK_HEDGING_EUR) OVER (PARTITION BY fact.CD_DOCUMENT_NO,fact.CD_DOCUMENT_LINE) / ord.AMT_TOTAL_MEK) END,	
	AMT_NET_PRICE_EUR = CASE WHEN it.NUM_ITEM like '6%' THEN AMT_NET_PRICE_EUR ELSE ord.AMT_TOTAL_NET_PRICE_EUR * SUM(AMT_MEK_HEDGING_EUR) OVER (PARTITION BY fact.CD_DOCUMENT_NO,fact.CD_DOCUMENT_LINE) / ord.AMT_TOTAL_MEK END,	
	AMT_GROSS_PRICE_EUR	= CASE WHEN it.NUM_ITEM like '6%' THEN AMT_GROSS_PRICE_EUR ELSE ord.AMT_TOTAL_GROSS_PRICE_EUR * (SUM(AMT_MEK_HEDGING_EUR) OVER (PARTITION BY fact.CD_DOCUMENT_NO,fact.CD_DOCUMENT_LINE)) / ord.AMT_TOTAL_MEK END,	
	AMT_TAX_PRICE_EUR = CASE WHEN it.NUM_ITEM like '6%' THEN AMT_TAX_PRICE_EUR ELSE ord.AMT_TOTAL_TAX_PRICE_EUR * SUM(AMT_MEK_HEDGING_EUR) OVER (PARTITION BY fact.CD_DOCUMENT_NO,fact.CD_DOCUMENT_LINE) /ord.AMT_TOTAL_MEK END,	
	AMT_NET_DISCOUNT_EUR = CASE WHEN it.NUM_ITEM like '6%' THEN AMT_NET_DISCOUNT_EUR ELSE ord.AMT_TOTAL_NET_DISCOUNT_EUR * SUM(AMT_MEK_HEDGING_EUR) OVER (PARTITION BY fact.CD_DOCUMENT_NO,fact.CD_DOCUMENT_LINE) / ord.AMT_TOTAL_MEK END,
	VL_ITEM_PARENT_QUANTITY = CASE WHEN it.NUM_ITEM like '6%' THEN VL_ITEM_QUANTITY ELSE
							(	
							SUM(CASE WHEN it.NUM_ITEM like '6%' THEN VL_ITEM_QUANTITY ELSE 0 END) OVER (PARTITION BY fact.CD_DOCUMENT_NO,(TRY_CAST (fact.CD_DOCUMENT_LINE AS INT) / 100))
							)
							* 
							(SUM(VL_ITEM_QUANTITY) OVER(PARTITION BY fact.CD_DOCUMENT_NO,fact.CD_DOCUMENT_LINE )/
							SUM(CASE WHEN it.NUM_ITEM NOT LIKE '6%' THEN VL_ITEM_QUANTITY ELSE 0 END) OVER (PARTITION BY fact.CD_DOCUMENT_NO,(TRY_CAST (fact.CD_DOCUMENT_LINE AS INT) / 100))
							)														
						END
FROM [TEST].[WR_L1_FACT_A_SALES_TRANSACTION_CAPO] fact
INNER JOIN L1.L1_DIM_A_ITEM it
			on it.ID_ITEM = fact.ID_ITEM
INNER JOIN CTE_SET_ORDERS ord on 
		ord.CD_DOCUMENT_NO = fact.CD_DOCUMENT_NO 
		AND (TRY_CAST (fact.CD_DOCUMENT_LINE AS INT) / 100) = ord.CD_DOCUMENT_LINE
	AND ord.AMT_TOTAL_MEK <> 0 AND ord.NUM_ITEM like '6%'
 )
 , CTE_SHIPP_COSTS as
(SELECT 
	    cost.item_code,cost.item_element,
	    CASE WHEN cost.warehouse=1 THEN 'Kamp-Lintfort'
	         WHEN cost.warehouse=2 THEN 'Hoppegarten'
	         WHEN cost.warehouse=3 THEN 'Bratislava'
	         WHEN cost.warehouse=4 THEN 'Werne'
	    END warehouse,
        warehouse as warehouse_id,
	    cost.country,
		ctypes.cost_type_name as Fulfillment,
	    SUM(cost.parcel_total_cost) as main_shipping_cost
	FROM [L0].[L0_MERCURY_LOGISTIC_BUDGET_CAPO_COST] cost 
	LEFT JOIN [L0].[L0_MERCURY_LOGISTIC_BUDGET_COST_TYPES] ctypes
	ON cost.cost_type_id = ctypes.id
	WHERE 0=0
	    --AND cost.warehouse IN (1, 3, 4)
		and item_code like '6%'
		
	GROUP BY 
	    cost.item_code,cost.item_element,
	    cost.warehouse,
	    cost.country,
		ctypes.cost_type_name
)

UPDATE fact
SET 

	ID_ITEM_PARENT = setitem.ID_ITEM_PARENT, 
	AMT_NET_SHIPPING_REVENUE_EUR = setitem.AMT_NET_SHIPPING_REVENUE_EUR,	
	AMT_NET_PRICE_EUR = setitem.AMT_NET_PRICE_EUR,
	AMT_GROSS_PRICE_EUR	= setitem.AMT_GROSS_PRICE_EUR,
	AMT_TAX_PRICE_EUR = setitem.AMT_TAX_PRICE_EUR,
	AMT_NET_DISCOUNT_EUR = setitem.AMT_NET_DISCOUNT_EUR,
    VL_ITEM_PARENT_QUANTITY = setitem.VL_ITEM_PARENT_QUANTITY,
	AMT_SHIPPING_COST_EST_EUR = CASE WHEN fact.cd_fulfillment = 'FBA' THEN ISNULL(ship_cost_fba.main_shipping_cost,0)
							   WHEN fact.cd_fulfillment = 'PBM' THEN ISNULL(ship_cost.main_shipping_cost,ship_cost_fbm.main_shipping_cost) 
							   ELSE ISNULL(ship_cost.main_shipping_cost,0) 
							   END
FROM [TEST].[WR_L1_FACT_A_SALES_TRANSACTION_CAPO] fact
INNER JOIN CTE_UPDATED_SETS setitem
	on setitem.CD_DOCUMENT_NO = fact.CD_DOCUMENT_NO
	AND setitem.CD_DOCUMENT_LINE = fact.CD_DOCUMENT_LINE
INNER JOIN L1.L1_DIM_A_ITEM it
			on it.ID_ITEM = fact.ID_ITEM
INNER JOIN L1.L1_DIM_A_ITEM itparent
			on itparent.ID_ITEM = setitem.ID_ITEM_PARENT
LEFT JOIN [L1].[L1_DIM_A_SALES_CHANNEL] channel_groups
	ON channel_groups.id_sales_channel = fact.id_sales_channel

LEFT JOIN CTE_SHIPP_COSTS ship_cost
        ON 
			itparent.NUM_ITEM = ship_cost.Item_code
			AND
			it.NUM_ITEM = ship_cost.item_element
        AND fact.CD_COUNTRY_DELIVERY=ship_cost.country
	    AND fact.[T_REVISED_LOCATION]=ship_cost.warehouse
		AND ship_cost.Fulfillment  != 'FBA'
        AND fact.cd_fulfillment =ship_cost.Fulfillment 
    --fallback for PBM shipping cost
 LEFT JOIN CTE_SHIPP_COSTS ship_cost_fbm
	ON 
			itparent.NUM_ITEM = ship_cost_fbm.Item_code
			AND
			it.NUM_ITEM = ship_cost_fbm.item_element
        AND fact.CD_COUNTRY_DELIVERY=ship_cost_fbm.country
	    AND fact.[T_REVISED_LOCATION]=ship_cost_fbm.warehouse
        AND ship_cost_fbm.Fulfillment = 'FBM'
    --shipping cost FBA
 LEFT JOIN CTE_SHIPP_COSTS ship_cost_fba
	ON
  	    itparent.NUM_ITEM = ship_cost.Item_code
			AND
		it.NUM_ITEM = ship_cost.item_element

        AND (
                (channel_groups.CD_CHANNEL_COUNTRY <> 'GB' AND channel_groups.CD_CHANNEL_COUNTRY=ship_cost_fba.country )
                OR
                (channel_groups.CD_CHANNEL_COUNTRY = 'GB' AND fact.CD_COUNTRY_DELIVERY=ship_cost_fba.country)
               )
        AND (
				(channel_groups.CD_CHANNEL_COUNTRY <> 'GB' AND ship_cost_fba.warehouse_id=2 )
				OR
				(channel_groups.CD_CHANNEL_COUNTRY = 'GB' AND ship_cost_fba.warehouse_id=1)
			)
        AND ship_cost_fba.Fulfillment = 'FBA'
		AND fact.cd_fulfillment = ship_cost_fba.Fulfillment

