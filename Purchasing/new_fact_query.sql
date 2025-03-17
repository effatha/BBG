SELECT TOP 10
    -- Header Fields
    HDR.EBELN AS CD_DOCUMENT_NO,                 -- Purchasing Document Number
    HDR.BSTYP AS CD_DOCUMENT_TYPE,               -- Document Type Code
    TYP.[TRANSACTIONTYPE] AS T_DOCUMENT_TYPE,    -- Document Type
    HDR.BSART AS CD_PURCHASING_CATEGORY,         -- Purchasing Document Category
   -- HDR.BUKRS AS CD_COMPANY_CODE,                -- Company Code
    HDR.BEDAT AS D_CREATED,                      -- Document Date (Transaction Date)
    HDR.BUDAT AS D_POSTING,                      -- Posting Date (Transaction Date)
    HDR.ZZKONNR AS CD_OUTLINE_AGREEMENT,          -- Outline Agreement
    HDR.KNUMV AS CD_PRICING_DOCUMENT_NO,        -- Can be linked to a specific pricing conditions records in KONV
    HDR.ZZ_WEAKT AS CD_GR_MESSAGE,               -- Good movement receipt types Message
    HDR.ZZ_ZBD1T AS CD_PAYMENT_IN_DISCOUNT_DAYS, -- number of days for the first cash discount period
    HDR.ZZ_ZTERM as CD_PAYMENT_TERM,             -- Payment terms code The actual terms are stored in T052 (Payment Terms Table), which can be joined using ZTERM.
    HDR.ZZDPDAT AS D_DOWN_PAYMENT,               -- Down payment due date
    HDR.ZZDPPER AS PERC_DOWN_PAYMENT,              -- Down payment percentage
    HDR.ZZDPFIX As AMT_FIXED_DOWN_PAYMENT_FC,      -- Down Payment fix amount
    HDR.ZZ_AEDAT AS D_LAST_CHANGED,               -- Last change to the document,
    HDR.KDATB   AS D_VALIDITY_START,               -- Start date of the validity of teh aggrement
    HDR.KDATE   AS D_VALIDITY_END,               -- END date of the validity of teh aggrement
    HDR.LOEKZ   AS FL_DOCUMENT_DELETION,        -- Delettion indication for the whole document
    HDR.ZZFORWARDER_REF AS CD_FORWARDER_REFERENCE, -- 
    HDR.ZZSUPPLIER_REF AS CD_SUPPLIER_REFERENCE,  -- Supplier Reference
    HDR.ZZETA AS D_ETA_PORT,                     -- ETA PORT
    HDR.ZZETD AS D_ETD,                     -- ETD
    HDR.ZZTRANSPORT_MODE AS CD_TRANSPORT_MODE,   -- Transport Mode
    HDR.ZZPORT_OF_LOADING   AS CD_PORT_OF_LOADING, -- Port of Loading
    HDR.ZZPORT_OF_DISCHARG AS CD_PORT_OF_DISCHARGE, -- Port of discharge
    -- Item Fields
    ITM.EBELP AS CD_DOCUMENT_LINE,              -- Item Number of Purchasing Document
    ITM.MATNR AS CD_ITEM,                       -- Material Number
    ITM.WERKS AS CD_PLANT,                      -- Plant
    ITM.LGORT AS CD_STORAGE_LOCATION,           -- Storage Location
    ITM.MENGE AS VL_ITEM_ORDER_QTY,             -- Item Order Quantity
    ITM.MEINS AS CD_ITEM_ORDER_UNIT,            -- Order Unit
    ITM.WAERS AS CD_CURRENCY,                   -- Currency
    ITM.WKURS AS VL_EXCHANGE_RATE ,               -- Currency FX (maybe some transformation is needed WHEN ITM.WKURS < 0	THEN (1 / ABS(ITM.WKURS))	ELSE ABS(ITM.WKURS)	)
    ITM.NETPR AS AMT_NET_PRICE_EUR,           -- Net Price in FC (theere's also ZZ_NETPR)
    ITM.PEINH AS NUM_PRICE_UNIT,          -- Price Unit
    ITM.NETWR AS AMT_NET_PRICE_FC,           -- Net Order Value TOTAL (maybe we need to split by total quantity)
    ITM.LIFNR AS CD_VENDOR,               -- Vendor
    ITM.BUKRS AS CD_COMPANY_CODE,         -- Company Code
    ITM.EKGRP AS CD_PURCHASING_GROUP,     -- Purchasing Group
    ITM.EKORG AS CD_PURCHASING_ORG,        -- Purchasing Organization
    ITM.EFFWR AS CD_EFFECTIVE_VALUE ,       -- EffectiveValue
    ITM.KTMNG AS VL_ITEM_COMMITTED_QTY,     -- quantity that has been committed or scheduled for fulfillment. can differ from original order qty
    ITM.ZZ_INCO1 AS CD_INCOTERMS,           -- International Commercial Terms
    ITM.ZZ_INCO2_L AS CD_INCOTERMS_L1,
    ITM.ZZ_INCO3_L AS CD_INCOTERMS_L2,
    ITM.BRTWR     AS AMT_GROSS_PRICE_FC,
    ITM.LOEKZ   AS FL_DOCUMENT_LINE_DELETION,        -- Delettion indication for the a position of the  document
    ITM.ZCONTRACT_REFERENCE  AS CD_CONTRACT_REFERENCE, --- contract Reference
    ITM.ZMM_MRD             AS D_ITEM_READY_DATE,
    ITM.ZZ_DPTYP            AS CD_DOWN_PAYMENT_CATEGORY, --- Down payment category
    ITM.ZZ_DPDAT AS D_LINE_DOWN_PAYMENT,               --  LINE Down payment due date
    ITM.ZZ_DPPCT AS PERC_LINE_DOWN_PAYMENT,              -- LINE Down payment percentage
    ITM.ZZ_DPAMT As AMT__LINE_FIXED_DOWN_PAYMENT_FC,      -- LINE Down Payment fix amount
    ITM.KONNR AS CD_CONTRACT_NUMBER,                    -- maybe its a duplicated date point (see CD_OUTLINE_AGREEMENT)
    ITM.ZMM_IM_READY_DATE    AS D_IM_READY,                  -- Ready for Goods Movement (inventory management)
    ITM.BSAKZ       AS CD_CONFIRMATION_CONTROL_TYPE,        -- Posting Indicator for Subsequent Settlement in SAP.
    ITM.LLIEF       AS CD_GOODS_SUPPLIER,                    -- Subcontractor  supplier  code
    ITM.ZZ_AEDAT AS D_LINE_LAST_CHANGED,               -- Last change to the document
    ITM.ZMM_QC_DATE AS D_QUALITY_CONTROL,       --     Quality Control Inspection Date, indicating when a material underwent or is scheduled for quality inspection.
    ITM.INFNR   AS CD_INFO_RECORD,      -- ITM.INFNR
    ITM.ZMM_ETD AS D_LINE_ETD,      -- ETD on a item level
    1
FROM TEST.L0_S4HANA_2LIS_02_HDR HDR
INNER JOIN TEST.[L0_S4HANA_2LIS_02_ITM] ITM
    ON HDR.EBELN = ITM.EBELN
LEFT JOIN [TEST].[L0_MI_TRANSACTION_TYPE] TYP 
    ON TYP.[TRANSACTIONTYPESHORT] = HDR.BSTYP
        AND TYP.[SOURCETYPE] = 'BSTYP'

WHERE 1=1
--AND HDR.EBELN = '4601016972'
ORDER BY
    HDR.BEDAT 


  --  select * from [TEST].[L0_MI_TRANSACTION_TYPE] where [SOURCETYPE] = 'BSTYP'