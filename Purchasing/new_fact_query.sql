SELECT TOP 10
    -- Header Fields
    HDR.EBELN AS CD_DOCUMENT_NO,                 -- Purchasing Document Number
    HDR.BSTYP AS CD_DOCUMENT_TYPE,               -- Document Type Code
    TYP.[TRANSACTIONTYPE] AS T_DOCUMENT_TYPE,    -- Document Type
    HDR.BSART AS CD_PURCHASING_CATEGORY,         -- Purchasing Document Category
 --   HDR.LIFNR AS CD_VENDOR_NO,                   -- Vendor Number
    HDR.BUKRS AS CD_COMPANY_CODE,                -- Company Code
    HDR.BEDAT AS D_CREATED,                      -- Document Date (Transaction Date)
--   HDR.EKORG AS CD_PURCHASING_ORG,              -- Purchasing Organization
--    HDR.EKGRP AS CD_PURCHASING_GROUP,            -- Purchasing Group

    -- Item Fields
    ITM.EBELP AS CD_DOCUMENT_LINE,              -- Item Number of Purchasing Document
    ITM.MATNR AS CD_ITEM,                       -- Material Number
    ITM.WERKS AS CD_PLANT,                      -- Plant
    ITM.LGORT AS CD_STORAGE_LOCATION,           -- Storage Location
    ITM.MENGE AS VL_ITEM_ORDER_QTY,             -- Item Order Quantity
    ITM.MEINS AS CD_ITEM_ORDER_UNIT,            -- Order Unit
    ITM.WAERS AS CD_CURRENCY,                   -- Currency
    ITM.NETPR AS AMT_NET_PRICE_FC,           -- Net Price
    ITM.PEINH AS NUM_PRICE_UNIT,          -- Price Unit
 --  ITM.BPRME AS CD_ORDER_PRICE_UNIT,     -- Order Price Unit
    ITM.NETWR AS AMT_NET_VALUE,           -- Net Order Value
    ITM.LIFNR AS CD_VENDOR,               -- Vendor
    ITM.BUKRS AS CD_COMPANY_CODE,         -- Company Code
    ITM.EKGRP AS CD_PURCHASING_GROUP,     -- Purchasing Group
    ITM.EKORG AS CD_PURCHASING_ORG        -- Purchasing Organization

FROM L0.[L0_S4HANA_2LIS_02_HDR] HDR
INNER JOIN L0.[L0_S4HANA_2LIS_02_ITM] ITM
    ON HDR.EBELN = ITM.EBELN
LEFT JOIN [L0].[L0_MI_TRANSACTION_TYPE] TYP 
    ON TYP.[TRANSACTIONTYPESHORT] = HDR.BSTYP
        AND TYP.[SOURCETYPE] = 'BSTYP'

WHERE 
HDR.EBELN = '4601016972'
ORDER BY
    HDR.BEDAT 


