WITH CTE_PURCHASING_ORDERS AS
(

    SELECT 
        CD_SOURCE = 'PURCH',
        CD_DOCUMENT_NO,CD_DOCUMENT_LINE,
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
        D_ETD_CALC      = isnull(D_ETD,DATEADD(dd,-70,D_ETA_WAREHOUSE)) , 
        D_ETA_PORT,
        AMT_ITEM_PRICE_EUR = sum(isnull(AMT_NET_PRICE_EUR,0)),
        VL_ORDER_QUANTITY    = SUM(ISNULL(VL_ITEM_ORDER_QTY,0))
        
    FROM TEST.L1_FACT_A_PURCHASING_TRANSACTIONS
    WHERE 1=1
        AND CD_COMPANY_CODE = '1000'
        AND ISNULL(CD_ITEM,'')<>''
        AND CD_PURCHASING_CATEGORY IN ('Z101','Z102','Z103','Z105','Z106')
        AND CD_GR_MESSAGE <> 'X'  ---- Document is not fulfilled
       -- AND CD_DOCUMENT_NO = '4501012402'
       AND FL_DELIVERY_COMPLETED <> 'Y'
      --  AND CD_ITEM= '10035212'
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
       isnull(D_ETD,DATEADD(dd,-70,D_ETA_WAREHOUSE)),
       D_ETA_PORT,FL_DELIVERY_COMPLETED
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
        VL_ITEM_QTY = itm.MENGE
	FROM [TEST].L0_S4HANA_2LIS_02_ITM itm
	LEFT JOIN [TEST].L0_S4HANA_Z_MM_LIKP_LIPS lips
		on itm.EBELN = lips.VGBEL
			and CAST(itm.EBELP as int) = CAST(Lips.VGPOS as int)
	LEFT JOIN [TEST].L0_S4HANA_2LIS_04_P_MATNR po
		on po.ZZ_CY_SEQNR = CONCAT(cast(itm.EBELN as bigint),CAST(itm.EBELP as int))
	LEFT JOIN [TEST].L0_S4HANA_Z_MM_LIKP_LIPS lips_kit
		on lips_kit.AUFNR = po.AUFNR
		and lips_kit.POSNR_PP = po.POSNR
    WHERE
         lips_kit.FOLAR = 'DIG' --- Intercompany Billing
            AND
        ISNULL(lips_kit.vlstk,'') NOT IN('C','')
         

),
CTE_MAIN AS(
SELECT
    po.*,
    FL_BOOKING_CONFIRMED = MAX(po.FL_BOOKING_LINE_CONFIRMED) OVER (PARTITION BY CD_DOCUMENT_NO),
    VL_OPEN_QTY = ISNULL(po.VL_ORDER_QUANTITY,0) - ISNULL(gr.VL_GR_QUANTITY_RECEIVED,0) + ISNULL(kitting.VL_ITEM_QTY,0)  
FROM CTE_PURCHASING_ORDERS po
LEFT JOIN CTE_GR_QTY gr
    on 
        gr.CD_PURCHASING_DOCUMENT_NO = po.CD_DOCUMENT_NO
        AND
        gr.CD_PURCHASING_DOCUMENT_LINE = po.CD_DOCUMENT_LINE
LEFT JOIN CTE_KITTING_PROCESS_LINES kitting
    ON kitting.CD_PURCHASING_DOCUMENT_NO = po.CD_DOCUMENT_NO
        AND
        kitting.CD_PURCHASING_DOCUMENT_LINE = po.CD_DOCUMENT_LINE
WHERE 1=1
    AND
        ISNULL(po.VL_ORDER_QUANTITY,0) - ISNULL(gr.VL_GR_QUANTITY_RECEIVED,0) + ISNULL(kitting.VL_ITEM_QTY,0)   > 0

)

SELECT *
FROM CTE_MAIN
WHERE 
FL_BOOKING_CONFIRMED = 1











--SELECT * FROM TEST.L1_FACT_A_PURCHASING_TRANSACTIONS WHERE  CD_ITEM =  '100045276'   


----    SELECT top 100
----        EBELN, EBELP,[ETENR],BUDAT,WAERS,EINDT,LIFNR,WERKS,MATNR,BWMNG,WEBRE,WEPOS,EKGRP,VLFKZ,
----        *
----    FROM [TEST].[L0_S4HANA_2LIS_02_SCL] where  ebeln = '4501020135' and ebelp = '00190'


--    SELECT top 100  
            

--    * 
--    FROM [TEST].[L0_S4HANA_2LIS_02_HDR] where  ebeln = '4501019962' and ebelp = '00190'

    

--    SELECT top 100  VL_ITEM_QUANTITY,
--    * 
--    FROM [TEST].L1_FACT_A_INBOUND_DELIVERY_NOTES 
--    where  CD_PURCHASING_DOCUMENT_NO = '4501020135' and CD_PURCHASING_DOCUMENT_LINE = '00190' and cd_stock_movement_type =109 and CD_BATCH  <> '' CD_VENDOR = '0000005100'


--    SELECT VGPOS,LFIMG,POTIM,WBSTK,BESTK,*
--    FROM [TEST].[L0_S4HANA_Z_MM_LIKP_LIPS]
--    where  VGBEL = '4501020135' and VGPOS = '000190'

--    SELECT top 10 *
--    FROM L0.L0_S4HANA_2LIS_03_BF
--    WHERE   ZZ_VBELN_IM in ('0180743301')
--    and ZZ_VBELP_IM in ('900004')
--       UNION
--     SELECT top 10 *
--    FROM L0.L0_S4HANA_2LIS_03_BF
--    WHERE  --MBLNR = '5105661774'
--    EBELN = '4501020135' and EBELP = 190
    
--    ZZ_VBELN_IM in ('0180743302')
--    and ZZ_VBELP_IM in ('900003')

--000190	0180743301	900004 ---6
--000190	0180743301	000040
--000190	0180743302	900003----64
--000190	0180743302	000030

--)
--select top 1000 *
-- FROM [TEST].[L0_S4HANA_Z_MM_LIKP_LIPS] where VGBEL = '4501018257' and VGPOS = '000190'
-- vbeln = '0180736235' and POSNR = '900001'

--    SELECT top 100 *
--    FROM L0.L0_S4HANA_2LIS_03_BF-- where ebeln = '4501018257' and ebelp= '00190'
    
--    WHERE 
--        ZZ_VBELN_IM = '0180736244' and ebelp= '00010'




--    SELECT top 100
--        EBELN, EBELP,[ETENR],BUDAT,WAERS,EINDT,LIFNR,WERKS,MATNR,BWMNG,WEBRE,WEPOS,EKGRP,VLFKZ,
--       *
--    FROM [TEST].[L0_S4HANA_2LIS_02_SCL] where  ebeln = '000001004564'



--select 
--*
--,rank() over (partition by BookingConfirmed,ful.[ItemNo] order by ful.ETAWarehouse,ful.ETD,ful.ProcessId) as rank
--from(
----SELECT
----  'purchasetransaction' as [source]
----  ,ProcessId
----  ,CASE WHEN OrderDocumentType='UB' THEN -1 ELSE BookingConfirmed END BookingConfirmed
----  ,CASE WHEN LEFT(ItemNo,2)='11' THEN '10' ELSE LEFT(ItemNo,2) END + RIGHT(ItemNo,6) [ItemNo]
----  ,CASE WHEN OrderDocumentType = 'UB' THEN 'Stock in Transfer' ELSE CASE WHEN BookingConfirmed = -1 THEN 'Booking is confirmed' ELSE 'Booking NOT Confirmed' END END [BookingStatus]
----  ,cast(CASE
----    WHEN ETAWarehouse<=CAST(GETDATE()-1 as date)
---- THEN DATEADD(dd,11,CAST(GETDATE()-1 as date))
---- ELSE ETAWarehouse
---- END as date) ETAWarehouse
----      ,[ETD]
----      ,isnull([ETD],DATEADD(dd,-70,ETAWarehouse)) [calc_ETD]
----      ,[ETAPort]
---- ,sum(isnull(OrderValue,0))/sum(ISNULL(OrderQuantity,0)) OrderItemPrice
----   ,SUM(ISNULL(OrderQuantity,0)) - SUM(ISNULL(StockReceiptQuantity,0)) [Open_QTY]
----  FROM [CT dwh 03 Intelligence].[dbo].[vFactPurchasingOrdersTransactions]
----  WHERE CompanyId=1000
----  AND ItemNo IS NOT NULL
----  AND ItemNo <> ''
----  AND OrderDocumentNo IS NOT NULL
----  AND ISNULL(ItemProcessFulfilled,0)=0
----  AND ISNULL(ProcessFulfilled,0)=0
----  AND OrderDocumentType IN (
------  'UB',					--stock in transfer
---- 'Z101',
---- 'Z102',
---- 'Z103',
---- 'Z105',				--direct to FBA shipment
---- 'Z106'					--direct to FBA shipment
---- )
------ and BookingConfirmed=-1
----  --and ProcessId='4501018791'
----  --and itemno=10034227
----  GROUP BY
----  ProcessId
----  ,CASE WHEN OrderDocumentType='UB' THEN -1 ELSE BookingConfirmed END
----,CASE WHEN LEFT(ItemNo,2)='11' THEN '10' ELSE LEFT(ItemNo,2) END + RIGHT(ItemNo,6)
----,CASE WHEN OrderDocumentType = 'UB' THEN 'Stock in Transfer' ELSE CASE WHEN BookingConfirmed = -1 THEN 'Booking is confirmed' ELSE 'Booking NOT Confirmed' END END
----,ETAWarehouse
----       ,[ETD]
----      ,[ETAPort]
----HAVING SUM(ISNULL(OrderQuantity,0)) - SUM(ISNULL(StockReceiptQuantity,0))>0
--union all 
--SELECT  
--'kitting delivery note' as [source]
--,header.[ProcessId]
--,'-1' as BookingConfirmed
--,CASE WHEN LEFT(header.itemno,2)='11' THEN '10' ELSE LEFT(header.itemno,2) END + RIGHT(header.itemno,6) [ItemNo]
--,'Booking is confirmed' as [BookingStatus]
--,header.[ETAWareHouse]
--,header.[ETD]
--,isnull(header.[ETD],DATEADD(dd,-70,header.ETAWarehouse)) [calc_ETD]
--,header.[ETAport]
----,header.[ItemPriceForeignCurrency]
--,header.[ItemPrice] as OrderItemPrice
--,header.[Quantity] as [Open_QTY]
----,header.[ValueForeignCurrency]
----,header.[Value]
--FROM [CT dwh 03 Intelligence].[purch].[vFactVertical] header
-----------------relevant ProcessIDs---------------
--inner join(
--SELECT  
--[ProcessId]
--FROM [CT dwh 03 Intelligence].[purch].[vFactVertical] vert
----------------ProcessID to ProductionOrder---------------
--left join(
--select 
--documentno
--from [CT dwh 03 Intelligence].[purch].[vFactVertical] 
--where transactiontypedetail = 'Inbound Delivery Movement' 
--and documentno <>'' 
--group by documentno
--)doc on vert.[DeliveryNo]=doc.documentno
----------------find ProductionOrder in Logistics temp---------------
--left join (
--select 
--[DeliveryNumber]
--FROM [CT dwh 03 Intelligence].[dbo].[tDeliveryNotesLogisticsTemp]
--WHERE [DeliveryType]='DIG'
--AND DeliveryDistributionStatus<>'C'
--AND DeliveryDistributionStatus<>''
--AND ISNULL([ProductionOrderNo],'') <>''
--AND Quantity>0
--group by [DeliveryNumber]
--)dn on dn.DeliveryNumber = vert.[DeliveryNo]
--where 1=1
--and [DeliveryNo] not in (
--'0180000065',
--'0180002585',
--'0180002802',
--'0180003066',
--'0180003238',
--'0180004280',
--'0180009887',
--'0180014055',
--'0180016232',
--'0180043979',
--'0180051574',
--'0180062747',
--'0180063445',
--'0180078056',
--'0180291365',
--'0180330105',
--'0180349397',
--'0180356147',
--'0180364826',
--'0180398085')  -- incident
--and [TransactionTypeDetail]='ProductionOrder'
--and dn.DeliveryNumber is not null
--group by 
--[ProcessId]
--)relevant on relevant.ProcessId=header.ProcessId
--where header.[TransactionTypeDetail] ='Order'
--and header.[ETAWareHouse] != '0001-01-01'
--and left(header.itemno,2)='11'
----and header.ProcessId='4501019466'
--)ful


--SELECT TOP 100 
--itm.EBELN,
--ITM.EBELP,
--ITM.MENGE,
--ITM.MATNR,
--lips.VBELN,
--lips.POSNR,
--lips.LFIMG,
--lips.lifnr,
--po.AUFNR,
--po.MATNR,
--lips_kit.VBELN,
--lips_kit.POSNR,
--bf.MBLNR,
--lips.FOLAR,
--lips_kit.*
--FROM [TEST].L0_S4HANA_2LIS_02_ITM itm
--LEFT JOIN [TEST].L0_S4HANA_Z_MM_LIKP_LIPS lips
--    on itm.EBELN = lips.VGBEL
--        and CAST(itm.EBELP as int) = CAST(Lips.VGPOS as int)
--LEFT JOIN [TEST].L0_S4HANA_2LIS_04_P_MATNR po
--    on po.ZZ_CY_SEQNR = CONCAT(cast(itm.EBELN as bigint),CAST(itm.EBELP as int))
--LEFT JOIN [TEST].L0_S4HANA_Z_MM_LIKP_LIPS lips_kit
--    on lips_kit.AUFNR = po.AUFNR
--    and lips_kit.POSNR_PP = po.POSNR
--LEFT JOIN L0.L0_S4HANA_2LIS_03_BF bf
--    on bf.ZZ_VBELN_IM =lips_kit.Vbeln 
--    and bf.ZZ_VBELP_IM = lips_kit.POSNR
--LEFT JOIN L0.L0_S4HANA_Z_BOM_DATA bom
--    on CAST(bom.MATNR as bigint) = LEFT(CAST(itm.MATNR as int),2) + RIGHT(CAST(itm.MATNR as int),6)

--WHERE
--    -- lips.CHARG <> ''
--    -- AND
--     lips_kit.FOLAR = 'DIG' --- Intercompany Billing
--     AND
--     ISNULL(lips_kit.vlstk,'') NOT IN('C','')

--AND
--    itm.EBELN = '4501020042'
--    AND
--    CAST(itm.MATNR as BIGINT) = '11032568'
--    --CAST(itm.EBELP as int) = 190




