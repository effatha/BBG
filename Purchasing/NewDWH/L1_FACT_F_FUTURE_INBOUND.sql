-----The BookingConfirmed field is set to the processid level. if only one of the items in the PO has a good receipt, the whole booking is confirmed. There is a bug in the c
--- current process in the old dwh that wrongly classifies a booking has confirmed. the issue being that its using the table EKES to look for Z3 documents, but does check thequantity if teh quantity has beeng cancelled/reversedthe bookings stays as confimed.
-- in this approach we only use the ITM extractor, and only looking for records that have ot been reversed 9rocancel <> 'R'

--CREATE VIEW TEST.PL_V_FUTURE_INBOUND
--AS
/****** Object:  View [TEST].[PL_V_FUTURE_INBOUND]    Script Date: 21/07/2025 16:09:58 ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO

ALTER VIEW [TEST].[PL_V_FUTURE_INBOUND] as
WITH CTE_PURCHASING_ORDERS AS
(
    SELECT 
        CD_SOURCE = 'PURCH',
        CD_DOCUMENT_NO,
        CD_DOCUMENT_LINE,
        FL_BOOKING_LINE_CONFIRMED = CASE 
                                    WHEN CD_PURCHASING_CATEGORY='UB' THEN 1 
                                    WHEN FL_BOOKING_CONFIRMED_Z2='Y' OR  FL_BOOKING_CONFIRMED_Z3 = 'Y' THEN 1 
                                    ELSE 0 END,
       NUM_ITEM =             CASE 
                                    WHEN LEFT(CAST(CD_ITEM as int),2)='11' THEN '10' 
                                    ELSE LEFT(CAST(CD_ITEM as int),2) END 
                                    + RIGHT(CAST(CD_ITEM as int),6) ,
       T_BOOKING_STATUS = CASE 
                                    WHEN CD_PURCHASING_CATEGORY='UB' THEN 'Stock in Transfer' 
                                    WHEN FL_BOOKING_CONFIRMED_Z2='Y' OR  FL_BOOKING_CONFIRMED_Z3 = 'Y' THEN 'Booking is confirmed' 
                                    ELSE 'Booking NOT Confirmed' END,
        D_ETA_WAREHOUSE = cast(CASE
                                    WHEN D_ETA_WAREHOUSE<=CAST(GETDATE()-1 as date) THEN DATEADD(dd,11,CAST(GETDATE()-1 as date))
                                 ELSE D_ETA_WAREHOUSE
                                 END
                                as date),
        D_ETD,
   --     D_ETD_CALC      = isnull(D_ETD,DATEADD(dd,-70,D_ETA_WAREHOUSE)) , 
        D_ETA_PORT,
        AMT_ITEM_PRICE_EUR = sum(isnull(AMT_NET_PRICE_EUR,0)),
        VL_ORDER_QUANTITY    = SUM(ISNULL(VL_ITEM_ORDER_QTY,0))
        
    FROM TEST.L1_FACT_A_PURCHASING_TRANSACTIONS s
    LEFT JOIN L0.L0_S4HANA_0STOR_LOC_TEXT st 
        on st.werks = s.CD_PLANT and st.LGORT = s.CD_STORAGE_LOCATION
    WHERE 1=1
        AND CD_COMPANY_CODE = '1000'
        AND ISNULL(CD_ITEM,'')<>''
        AND CD_PURCHASING_CATEGORY IN ('Z101','Z102','Z103','Z105','Z106')
        AND CD_GR_MESSAGE <> 'X'  ---- Document is not fulfilled
        --AND CD_DOCUMENT_NO = '4501016431'
       AND (FL_DELIVERY_COMPLETED <> 'Y' OR (FL_DELIVERY_COMPLETED <> 'N' AND st.TXTMD like 'Kitting%') )
      --  AND CAST(CD_ITEM as int)= '10046212'
    GROUP BY 
        CD_DOCUMENT_NO,
        CD_DOCUMENT_LINE,
        CASE 
            WHEN CD_PURCHASING_CATEGORY='UB' THEN 1 
            WHEN FL_BOOKING_CONFIRMED_Z2='Y' OR  FL_BOOKING_CONFIRMED_Z3 = 'Y' THEN 1
        ELSE 0 END,
        CASE 
            WHEN LEFT(CAST(CD_ITEM as int),2)='11' THEN '10' 
        ELSE LEFT(CAST(CD_ITEM as int),2) END + RIGHT(CAST(CD_ITEM as int),6),
         CASE 
                                    WHEN CD_PURCHASING_CATEGORY='UB' THEN 'Stock in Transfer' 
                                    WHEN FL_BOOKING_CONFIRMED_Z2='Y' OR  FL_BOOKING_CONFIRMED_Z3 = 'Y' THEN 'Booking is confirmed' 
                                    ELSE 'Booking NOT Confirmed' END,
        cast(CASE
                                    WHEN D_ETA_WAREHOUSE<=CAST(GETDATE()-1 as date) THEN DATEADD(dd,11,CAST(GETDATE()-1 as date))
                                 ELSE D_ETA_WAREHOUSE
                                 END
                                as date),

       D_ETD,
       --isnull(D_ETD,DATEADD(dd,-70,D_ETA_WAREHOUSE)),
       D_ETA_PORT,FL_DELIVERY_COMPLETED,D_ETA_WAREHOUSE
),cte_confirmed as (
    SELECT
        *,
          D_ETD_CALC      = isnull(D_ETD,DATEADD(dd,-70,D_ETA_WAREHOUSE)) , 
        FL_BOOKING_CONFIRMED = MAX(FL_BOOKING_LINE_CONFIRMED) OVER (PARTITION BY CD_DOCUMENT_NO)

    FROM  CTE_PURCHASING_ORDERS
),
CTE_GR_QTY AS
(
    SELECT 
    CD_PURCHASING_DOCUMENT_NO,
    CD_PURCHASING_DOCUMENT_LINE,
    VL_GR_QUANTITY_RECEIVED = SUM(ISNULL(VL_GR_QUANTITY_RECEIVED,0))
    FROM TEST.L1_FACT_A_INBOUND_DELIVERY_NOTES 
    where 1=1
    GROUP BY CD_PURCHASING_DOCUMENT_NO,CD_PURCHASING_DOCUMENT_LINE
)
,
CTE_KITTING_PROCESS_LINES AS
(
	SELECT DISTINCT 
		CD_PURCHASING_DOCUMENT_NO	= itm.EBELN,
		CD_PURCHASING_DOCUMENT_LINE = itm.EBELP,
        VL_ITEM_QTY = CASE WHEN ISNULL(lips_kit.vlstk,'') IN('C') THEN itm.MENGE ELSE 0 END
	FROM [L0].L0_S4HANA_2LIS_02_ITM itm
	LEFT JOIN [L0].L0_S4HANA_Z_MM_LIKP_LIPS lips
		on itm.EBELN = lips.VGBEL
			and CAST(itm.EBELP as int) = CAST(Lips.VGPOS as int)
	LEFT JOIN [L0].L0_S4HANA_2LIS_04_P_MATNR po
		on po.ZZ_CY_SEQNR = CONCAT(cast(itm.EBELN as bigint),CAST(itm.EBELP as int))
	LEFT JOIN [L0].L0_S4HANA_Z_MM_LIKP_LIPS lips_kit
		on lips_kit.AUFNR = po.AUFNR
		and lips_kit.POSNR_PP = po.POSNR
    WHERE
         lips_kit.FOLAR = 'DIG' --- Intercompany Billing
            AND
            ISNULL(itm.ROCANCEL,'')<>'R'
     -- AND  ISNULL(lips_kit.vlstk,'') NOT IN('C','')
        and    ISNULL(lips_kit.vlstk,'') NOT IN('')


),
CTE_MAIN AS(
SELECT
    po.*,
    VL_OPEN_QTY = CASE WHEN kitting.VL_ITEM_QTY is not null THEN ISNULL(po.VL_ORDER_QUANTITY,0) - ISNULL(kitting.VL_ITEM_QTY,0)  
                    ELSE ISNULL(po.VL_ORDER_QUANTITY,0) - ISNULL(gr.VL_GR_QUANTITY_RECEIVED,0)   END
FROM cte_confirmed po
LEFT JOIN CTE_GR_QTY gr
    on 
        gr.CD_PURCHASING_DOCUMENT_NO = po.CD_DOCUMENT_NO
        AND
        gr.CD_PURCHASING_DOCUMENT_LINE = po.CD_DOCUMENT_LINE
LEFT JOIN CTE_KITTING_PROCESS_LINES kitting
    ON kitting.CD_PURCHASING_DOCUMENT_NO = po.CD_DOCUMENT_NO
        AND
        cast(kitting.CD_PURCHASING_DOCUMENT_LINE as int) =  cast(po.CD_DOCUMENT_LINE as int)
WHERE 1=1
AND CASE WHEN kitting.VL_ITEM_QTY is not null THEN ISNULL(po.VL_ORDER_QUANTITY,0) - ISNULL(kitting.VL_ITEM_QTY,0)  
                    ELSE ISNULL(po.VL_ORDER_QUANTITY,0) - ISNULL(gr.VL_GR_QUANTITY_RECEIVED,0)   END > 0

)

SELECT 
 --   CD_SOURCE,
 --   CD_DOCUMENT_NO,
 ----   CD_DOCUMENT_LINE,
 ----   FL_BOOKING_LINE_CONFIRMED,
 --   NUM_ITEM,
 --   T_BOOKING_STATUS = CASE WHEN FL_BOOKING_CONFIRMED = 1 THEN 'Booking is confirmed' ELSE 'Booking NOT Confirmed' END,
 --   D_ETA_WAREHOUSE = MIN(D_ETA_WAREHOUSE),
 --   D_ETD = MIN(D_ETD),
 --   D_ETD_CALC = MIN(D_ETD_CALC),
 --   D_ETA_PORT = MIN(D_ETA_PORT),
 --   AMT_ITEM_PRICE_EUR = SUM(AMT_ITEM_PRICE_EUR),
 --   VL_ORDER_QUANTITY = SUM(VL_ORDER_QUANTITY),
 --   FL_BOOKING_CONFIRMED ,
 --   VL_OPEN_QTY     = SUM(VL_OPEN_QTY)
    Source = CD_SOURCE,
    ProcessId = CD_DOCUMENT_NO,
    ItemNo = NUM_ITEM,
    BookingStatus =  CASE WHEN FL_BOOKING_CONFIRMED = 1 THEN 'Booking is confirmed' ELSE 'Booking NOT Confirmed' END,
    ETAWarehouse =  MIN(D_ETA_WAREHOUSE),
    ETD =  MIN(D_ETD),
    Calc_ETD = MIN(D_ETD_CALC),
    ETAPort = MIN(D_ETA_PORT),
    OrderItemPrice = SUM(AMT_ITEM_PRICE_EUR),
    Open_QTY = SUM(VL_OPEN_QTY),
    [rank] = RANK() OVER (PARTITION BY NUM_ITEM ORDER BY MIN(D_ETA_WAREHOUSE))
FROM CTE_MAIN
WHERE 1=1
AND 
    D_ETA_WAREHOUSE >= CAST(GETDATE() as date)
   AND YEAR(D_ETD_CALC)>= YEAR(GETDATE())
--AND CD_DOCUMENT_NO = '4501016431'
--AND NUM_ITEM = '10046128'
--FL_BOOKING_CONFIRMED = 1
GROUP BY 
CD_SOURCE,
CD_DOCUMENT_NO,
--FL_BOOKING_LINE_CONFIRMED,
NUM_ITEM,
--T_BOOKING_STATUS,
FL_BOOKING_CONFIRMED

--select * from TEST.PL_V_FUTURE_INBOUND where FL_BOOKING_CONFIRMED = 1






