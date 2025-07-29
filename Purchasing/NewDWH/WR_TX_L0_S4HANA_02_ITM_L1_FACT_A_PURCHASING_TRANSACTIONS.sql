/******************************
** Name: Gets the SAP purchasing data 
** Auth: [Helder Barbosa]
** Date: 01/03/2025
**************************
** Change History
**************************
** PR   Date		 Author			Description 
** --   --------	 -------		------------------------------------
** 1	01/03/2025	Hbarbosa	     Initial Script
*/
 

 --TEST.WR_TX_L0_S4HANA_02_ITM_L1_FACT_A_PURCHASING_TRANSACTIONS @NUM_LOAD_DAYS = 0

ALTER PROCEDURE TEST.WR_TX_L0_S4HANA_02_ITM_L1_FACT_A_PURCHASING_TRANSACTIONS @NUM_LOAD_DAYS INT
AS
BEGIN

/****************************************************************
** Load Date
** calculate for how many days we process transactions
*****************************************************************/
DECLARE @LOAD_START_DATE AS date 

IF(ISNULL(@NUM_LOAD_DAYS,0) > 0 )
    SET @LOAD_START_DATE = CAST(GETDATE () - @NUM_LOAD_DAYS as date)


TRUNCATE TABLE TEST.L1_FACT_A_PURCHASING_TRANSACTIONS --WHERE DT_DWH_CREATED>=@LOAD_START_DATE


;WITH cte_src AS
(
   SELECT 
            DISTINCT EBELN,
                     EBELP,
                     EBTYP, 
                     SCLDT,
                     OPNQTY, 
                     BookingConfirmedZ3DeliveryDate = CASE WHEN SCN.EBTYP='Z3' THEN TRY_CONVERT(date,[CNFDT]) ELSE NULL END, 
                     BookingConfirmedZ3CreationDate = CASE WHEN SCN.EBTYP='Z3' THEN TRY_CONVERT(date,[ZZ_ERDAT]) ELSE NULL END
            FROM  [L0].[L0_S4HANA_2LIS_02_SCN] SCN
),
cte_Z2
    AS(
        SELECT 
            EBELN,
            EBELP, 
            OPNQTY,
            -1 AS BookingConfirmedZ2, 
            0 AS BookingConfirmedZ3, 
            SCLDT,
            BookingConfirmedZ3DeliveryDate,
            BookingConfirmedZ3CreationDate 
            FROM cte_src WHERE EBTYP='Z2'
            ),
  
    cte_Z3
    AS(SELECT EBELN,EBELP,OPNQTY, 0 AS BookingConfirmedZ2, -1 AS BookingConfirmedZ3, SCLDT ,BookingConfirmedZ3DeliveryDate,BookingConfirmedZ3CreationDate FROM cte_src WHERE EBTYP='Z3'),
    cte_Z23
    AS(SELECT EBELN,EBELP, OPNQTY,0 AS BookingConfirmedZ2, 0 AS BookingConfirmedZ3,  SCLDT ,BookingConfirmedZ3DeliveryDate,BookingConfirmedZ3CreationDate FROM cte_src WHERE EBTYP NOT IN ('Z3','Z2') OR EBTYP is null)
    ,cte_BookingConfirmedunion as (
    SELECT EBELN,EBELP,OPNQTY,BookingConfirmedZ2,BookingConfirmedZ3, SCLDT,BookingConfirmedZ3DeliveryDate,BookingConfirmedZ3CreationDate
    FROM cte_Z2
    UNION
    SELECT EBELN,EBELP,OPNQTY,BookingConfirmedZ2,BookingConfirmedZ3, SCLDT,BookingConfirmedZ3DeliveryDate,BookingConfirmedZ3CreationDate
    FROM cte_Z3
    UNION
    SELECT EBELN,EBELP,OPNQTY,BookingConfirmedZ2,BookingConfirmedZ3,  SCLDT,BookingConfirmedZ3DeliveryDate,BookingConfirmedZ3CreationDate
    FROM cte_Z23)
    ,cte_BookingConfirmed
    AS(
    SELECT EBELN,EBELP,MIN(OPNQTY) as OPNQTY,MIN(BookingConfirmedZ2) as BookingConfirmedZ2,MIN(BookingConfirmedZ3) as BookingConfirmedZ3, max(SCLDT) AS SCLDT,MIN(BookingConfirmedZ3DeliveryDate) AS BookingConfirmedZ3DeliveryDate,MIN(BookingConfirmedZ3CreationDate) AS BookingConfirmedZ3CreationDate FROM cte_BookingConfirmedunion group by EBELN,EBELP




), 
CTE_BOOKING_CONFIRMED AS
(
SELECT EBELN,EBELP,MIN(OPNQTY) as OPNQTY,MIN(BookingConfirmedZ2) as BookingConfirmedZ2,MIN(BookingConfirmedZ3) as BookingConfirmedZ3, max(SCLDT) AS SCLDT,MIN(BookingConfirmedZ3DeliveryDate) AS BookingConfirmedZ3DeliveryDate,MIN(BookingConfirmedZ3CreationDate) AS BookingConfirmedZ3CreationDate FROM cte_BookingConfirmedunion group by EBELN,EBELP
)

   INSERT INTO TEST.L1_FACT_A_PURCHASING_TRANSACTIONS (
        CD_DOCUMENT_NO,
        CD_DOCUMENT_TYPE,
        T_DOCUMENT_TYPE, 
        CD_PURCHASING_CATEGORY, 
        CD_COMPANY_CODE,
        D_CREATED,
        D_POSTING, 
        CD_OUTLINE_AGREEMENT, 
        CD_PRICING_DOCUMENT_NO, 
        CD_GR_MESSAGE,
        CD_PAYMENT_IN_DISCOUNT_DAYS,
        CD_PAYMENT_TERM,
        D_DOWN_PAYMENT,
        PERC_DOWN_PAYMENT, 
        AMT_FIXED_DOWN_PAYMENT_FC,
        D_LAST_CHANGED,
        D_VALIDITY_START,
        D_VALIDITY_END,
        FL_DOCUMENT_DELETION,
        CD_FORWARDER_REFERENCE, 
        CD_SUPPLIER_REFERENCE, 
        D_ETA_PORT,
        D_ETD, 
        CD_TRANSPORT_MODE,
        CD_PORT_OF_LOADING, 
        CD_PORT_OF_DISCHARGE, 
        CD_DOCUMENT_LINE,
        CD_ITEM, 
        CD_PLANT,
        CD_STORAGE_LOCATION, 
        VL_ITEM_ORDER_QTY, 
        CD_ITEM_ORDER_UNIT, 
        CD_CURRENCY,
        VL_EXCHANGE_RATE, 
        AMT_NET_PRICE_EUR,
        NUM_PRICE_UNIT,
        AMT_NET_PRICE_FC, 
        CD_VENDOR, 
        CD_PURCHASING_GROUP,
        CD_PURCHASING_ORG,
        CD_EFFECTIVE_VALUE, 
        VL_ITEM_COMMITTED_QTY,
        CD_INCOTERMS,
        CD_INCOTERMS_L1,
        CD_INCOTERMS_L2, 
        AMT_GROSS_PRICE_FC, 
        FL_DOCUMENT_LINE_DELETION,
        CD_CONTRACT_REFERENCE,
        D_ITEM_READY_DATE, 
        CD_DOWN_PAYMENT_CATEGORY,
        D_LINE_DOWN_PAYMENT,
        PERC_LINE_DOWN_PAYMENT, 
        AMT_LINE_FIXED_DOWN_PAYMENT_FC,
        CD_CONTRACT_NUMBER,
        D_IM_READY,
        CD_CONFIRMATION_CONTROL_TYPE,
        CD_GOODS_SUPPLIER,
        D_LINE_LAST_CHANGED,
        D_QUALITY_CONTROL,
        CD_INFO_RECORD,
        D_LINE_ETD,
        FL_BOOKING_CONFIRMED_Z2,
        FL_BOOKING_CONFIRMED_Z3,
        D_CREATED_BOOKING_CONFIRMED_Z3,
        D_DELIVERY_BOOKING_CONFIRMED_Z3,
        D_ETA_WAREHOUSE,
        FL_DELIVERY_COMPLETED,
        DT_DWH_CREATED,
        DT_DWH_UPDATED

    )
    SELECT 
        HDR.EBELN,
        HDR.BSTYP,
        TYP.TRANSACTIONTYPE, 
        HDR.BSART,
        HDR.BUKRS,
        D_CREATED = CASE WHEN HDR.BEDAT = '00000000' THEN NULL ELSE HDR.BEDAT END,
        D_POSTING = CASE WHEN HDR.BUDAT = '00000000' THEN NULL ELSE HDR.BUDAT END, 
        HDR.ZZKONNR, 
        HDR.KNUMV, 
        HDR.ZZ_WEAKT,
        HDR.ZZ_ZBD1T, 
        HDR.ZZ_ZTERM, 
        D_DOWN_PAYMENT = CASE WHEN HDR.ZZDPDAT = '00000000' THEN NULL ELSE HDR.ZZDPDAT END, 
        HDR.ZZDPPER, 
        HDR.ZZDPFIX, 
        D_LAST_CHANGED = CASE WHEN HDR.ZZ_AEDAT = '00000000' THEN NULL ELSE HDR.ZZ_AEDAT END ,
        D_VALIDITY_START = CASE WHEN HDR.KDATB = '00000000' THEN NULL ELSE HDR.KDATB END , 
        D_VALIDITY_END = CASE WHEN HDR.KDATE = '00000000' THEN NULL ELSE HDR.KDATE END , 
        HDR.LOEKZ,
        HDR.ZZFORWARDER_REF, 
        HDR.ZZSUPPLIER_REF, 
        D_ETA_PORT = CASE WHEN HDR.ZZETA = '00000000' THEN NULL ELSE HDR.ZZETA END, 
        D_ETD = CASE WHEN HDR.ZZETD = '00000000' THEN NULL ELSE HDR.ZZETD END , 
        HDR.ZZTRANSPORT_MODE,
        HDR.ZZPORT_OF_LOADING,
        HDR.ZZPORT_OF_DISCHARG,
        ITM.EBELP,
        ITM.MATNR,
        ITM.WERKS,
        ITM.LGORT,
        ITM.MENGE,
        ITM.MEINS,
        ITM.WAERS, 
        CASE 
            WHEN ITM.WKURS < 0 THEN (1 / ABS(ITM.WKURS))
            ELSE ABS(ITM.WKURS)
        END AS VL_EXCHANGE_RATE, 
        ITM.NETPR, 
        ITM.PEINH, 
        ITM.NETWR, 
        ITM.LIFNR, 
        ITM.EKGRP, 
        ITM.EKORG, 
        ITM.EFFWR, 
        ITM.KTMNG, 
        ITM.ZZ_INCO1, 
        ITM.ZZ_INCO2_L, 
        ITM.ZZ_INCO3_L, 
        ITM.BRTWR, 
        ITM.LOEKZ,
        ITM.ZCONTRACT_REFERENCE, 
        ITM.ZMM_MRD, 
        ITM.ZZ_DPTYP, 
        ITM.ZZ_DPDAT,
        ITM.ZZ_DPPCT,
        ITM.ZZ_DPAMT, 
        ITM.KONNR, 
        ITM.ZMM_IM_READY_DATE,
        ITM.BSAKZ, 
        ITM.LLIEF, 
        ITM.ZZ_AEDAT,
        ITM.ZMM_QC_DATE,
        ITM.INFNR,
        ITM.ZMM_ETD,
        FL_BOOKING_CONFIRMED_Z2 = CASE WHEN BookingConfirmedZ2 = -1 THEN 'Y' ELSE 'N' END,
        FL_BOOKING_CONFIRMED_Z3 = CASE WHEN BookingConfirmedZ3 = -1 THEN 'Y' ELSE 'N' END,
        D_CREATED_BOOKING_CONFIRMED_Z3  =  SCN.BookingConfirmedZ3CreationDate,
        D_DELIVERY_BOOKING_CONFIRMED_Z3  =  SCN.BookingConfirmedZ3DeliveryDate,
        D_ETA_WAREHOUSE = SCL.EINDT,
        FL_DELIVERY_COMPLETED = CASE WHEN ISNULL(ITM.ELIKZ,'') = 'X' THEN 'Y' ELSE 'N' END,
        GETDATE(),
        GETDATE()
    FROM [L0].L0_S4HANA_2LIS_02_HDR HDR
    INNER JOIN L0.L0_S4HANA_2LIS_02_ITM ITM
        ON HDR.EBELN = ITM.EBELN
    LEFT JOIN TEST.L0_MI_TRANSACTION_TYPE TYP 
        ON TYP.TRANSACTIONTYPESHORT = HDR.BSTYP
        AND TYP.SOURCETYPE = 'BSTYP'
    LEFT JOIN CTE_BOOKING_CONFIRMED SCN
        ON 
            SCN.EBELN = ITM.EBELN
            AND
            SCN.EBELP = ITM.EBELP
    LEFT JOIN [L0].[L0_S4HANA_2LIS_02_SCL] SCL
        ON 
            SCL.EBELN = ITM.EBELN
            AND
            SCL.EBELP = ITM.EBELP
    
    WHERE 1=1
    AND
        ISNULL(itm.ROCANCEL,'') <> 'R'
		--AND (  
  --          @LOAD_START_DATE IS NULL
  --          OR
  --          LEAST(ITM.ZZ_AEDAT,ITM.BEDAT,HDR.BEDAT,HDR.ZZ_AEDAT) >= @LOAD_START_DATE

  --          )



 

END;

--select * from TEST.L0_S4HANA_2LIS_02_HDR HDR where ebeln = '4501018783'
--select distinct LOAD_TIMESTAMP
--from TEST.L0_S4HANA_2LIS_02_ITM HDR 
--where ebeln = '4501018783'
--select * from TEST.L0_S4HANA_2LIS_02_ITM_FULL HDR where ebeln = '4501018783'
--2025-03-18 11:26:18.0000000



--SELECT itm.ebeln,itm.ebelp,itm.[LOEKZ]

--UPDATE SET 
--FROM  TEST.L0_S4HANA_2LIS_02_ITM itm
--LEFT JOIN TEST.L0_S4HANA_2LIS_02_ITM_FULL f
--    on f.ebeln =itm.ebeln 
--    and 
--       itm.ebelp =itm.ebelp
--WHERE 
--    itm.LOAD_TIMESTAMP = '2025-03-18 11:26:18.0000000'
--    and 
--    f.ebeln is null
--    and ISNULL(itm.ROCANCEL,'') = ''
--    and ISNULL(itm.[LOEKZ],'') <> 'X'



--with cte_itm as (
 

--)

--SELECT * INTO TEST.L0_S4HANA_2LIS_02_ITM FROM L0.L0_S4HANA_2LIS_02_ITM
--SELECT * 
--from
--TEST.L0_S4HANA_2LIS_02_ITM 
--where ebeln = '4501018257' and ebelp = '00190'


--SELECT * 
--from
--TEST.L0_S4HANA_Z_MM_LIKP_LIPS 
--where 
--    VBELN= '0180736234'  and POSNR in ('900001','000010')

--SELECT * 
--from
--TEST.L0_S4HANA_Z_MM_LIKP_LIPS 
--where 
--    VBELN= '0180736244'  and POSNR in ('000020','000010')


--SELECT top 10 STLAN,* 
--from
--TEST.L0_S4HANA_2LIS_04_P_MATNR 
--where 
--    AUFNR= '000001004564'--  and POSNR in ('000020','000010')



--	SELECT 
--		CD_DELIVERY_DOCUMENT_NO = bf.ZZ_VBELN_IM,
--		CD_DELIVERY_DOCUMENT_LINE = bf.ZZ_VBELP_IM,
--		VL_GR_QTY = SUM(ISNULL(MENGE,0) * ISNULL(VL_MULTIPLIER,0))
--    FROM L0.L0_S4HANA_2LIS_03_BF bf
--	INNER JOIN TEST.[L0_MI_STOCK_INDICATOR] stck
--		ON stck.BWART = bf.BWART 
--			AND bf.SHKZG = stck.SHKZG
--    WHERE  1=1
--	--MBLNR = '5105661774'
--    --EBELN = '4501020135' and EBELP = 190
--	GROUP BY bf.ZZ_VBELN_IM, bf.ZZ_VBELP_IM