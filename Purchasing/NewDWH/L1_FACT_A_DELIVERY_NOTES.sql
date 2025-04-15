DROP TABLE TEST.L1_FACT_A_INBOUND_DELIVERY_NOTES
CREATE TABLE TEST.L1_FACT_A_INBOUND_DELIVERY_NOTES (

    CD_DELIVERY_NO VARCHAR(50) NOT NULL,          -- Delivery Number
    CD_DELIVERY_LINE INT NOT NULL,              -- Delivery Position
    CD_PURCHASING_DOCUMENT_NO VARCHAR(50),      -- PO Number
    CD_PURCHASING_DOCUMENT_LINE INT,            -- PO Position
    CD_PRODUCTION_ORDER_NO VARCHAR(50),         -- Production Order Number
    CD_DELIVERY_STATUS VARCHAR(5),              -- Delivery Distribution Status
    CD_STOCK_MOVEMENT_TYPE VARCHAR(5),          -- Movement Code
    CD_MOVEMENT_TYPE VARCHAR(5),                -- Movement Type
    CD_DELIVERY_TYPE VARCHAR(5),                -- Delivery Type
    CD_PURCHASING_DOCUMENT_TYPE VARCHAR(5),     -- Purchasing Document Type
    CD_SUB_DELIVERY_TYPE VARCHAR(5),            -- Delivery Sub Type
    CD_TRANSPORT_TYPE VARCHAR(5),               -- Transport Type
    CD_CONTAINER_ID VARCHAR(50),                -- Container ID
    VL_ITEM_QUANTITY DECIMAL(18,3),             -- Item Quantity
    CD_UNIT VARCHAR(5),                         -- Unit
    CD_SHIPPING_RECEIVING_POINT VARCHAR(50),    -- Shipping/Receiving Point
    CD_STORAGE_LOCATION VARCHAR(10),            -- Storage Location
    CD_PROFIT_CENTRE VARCHAR(50),               -- Profit Centre
    CD_ITEM INT,                                -- Delivery Item Number
    CD_ITEM_PARENT INT,                         -- Delivery Item Number
    CD_BATCH VARCHAR(20),                       -- Batch
    CD_VOLUME_UNIT VARCHAR(5),                  -- Volume Unit
    CD_VOLUME DECIMAL(18,3),                    -- Volume
    CD_MATERIAL_GROUP VARCHAR(10),              -- Material Group
    DT_CREATED DATETIME2,                        -- Delivery Creation Date
    D_CREATED DATE,                              -- Delivery Creation Date
    D_DELIVERY DATE,                            -- Delivery Date
    D_POSTING DATE,                             -- Billing Date
    CD_VENDOR VARCHAR(50),                      -- Vendor
    CD_INCOTERMS_L1 VARCHAR(50),                -- Incoterms Level 1
    CD_INCOTERMS_L2 VARCHAR(50),                -- Incoterms Level 2
    CD_OUTBOUND_HARBOUR VARCHAR(50),            -- Outbound Harbour
    CD_INBOUND_HARBOUR VARCHAR(50),             -- Inbound Harbour
    CD_STORAGE_LOCATION_1 VARCHAR(50),          -- Additional Storage Location
    CD_INBOUND_STORAGE_LOCATION VARCHAR(50),    -- Inbound Storage Location
    CD_TYPE VARCHAR(5),                         -- Item Type
    FL_DELETETION VARCHAR(1),                   -- Deleteion Indicator
    CD_GR_STATUS VARCHAR(1),                    -- Good Receipt Status -- A- Partially delivered; B - Fully delivered; C - Delivery completed (delivery final); D-Overdelivered
    VL_GR_QUANTITY_RECEIVED DECIMAL(18,4),      -- Items received

	DT_DWH_CREATED smalldatetime NOT NULL,
	DT_DWH_UPDATED smalldatetime NOT NULL
)