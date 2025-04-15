 DROP TABLE TEST.L1_FACT_A_PURCHASING_TRANSACTIONS
CREATE TABLE TEST.L1_FACT_A_PURCHASING_TRANSACTIONS (
    -- Document Header Fields
    CD_DOCUMENT_NO VARCHAR(10) NOT NULL,                -- Purchasing Document Number (Primary Key with Item)
    CD_DOCUMENT_TYPE VARCHAR(4),                        -- Document Type Code
    T_DOCUMENT_TYPE VARCHAR(50),                        -- Document Type Description
    CD_PURCHASING_CATEGORY VARCHAR(4),                  -- Purchasing Document Category
    CD_COMPANY_CODE VARCHAR(4),                         -- Company Code
    D_CREATED DATE,                                     -- Document Date
    D_POSTING DATE,                                     -- Posting Date
    CD_OUTLINE_AGREEMENT VARCHAR(10),                   -- Outline Agreement
    CD_PRICING_DOCUMENT_NO VARCHAR(10),                 -- Pricing Document Number
    CD_GR_MESSAGE VARCHAR(2),                           -- Goods Movement Receipt Type Message
    CD_PAYMENT_IN_DISCOUNT_DAYS INT,                    -- Discount Period Days
    CD_PAYMENT_TERM VARCHAR(4),                         -- Payment Terms Code
    D_DOWN_PAYMENT DATE,                                -- Down Payment Due Date
    PERC_DOWN_PAYMENT DECIMAL(5,2),                     -- Down Payment Percentage
    AMT_FIXED_DOWN_PAYMENT_FC DECIMAL(18,2),            -- Fixed Down Payment Amount
    D_LAST_CHANGED DATE,                                -- Last Change Date
    D_VALIDITY_START DATE,                              -- Agreement Validity Start
    D_VALIDITY_END DATE,                                -- Agreement Validity End
    FL_DOCUMENT_DELETION CHAR(1),                       -- Document Deletion Flag
    CD_FORWARDER_REFERENCE VARCHAR(50),                 -- Forwarder Reference
    CD_SUPPLIER_REFERENCE VARCHAR(50),                  -- Supplier Reference
    D_ETA_PORT DATE,                                    -- Estimated Time of Arrival at Port
    D_ETD DATE,                                         -- Estimated Time of Departure
    CD_TRANSPORT_MODE VARCHAR(10),                      -- Transport Mode
    CD_PORT_OF_LOADING VARCHAR(50),                     -- Port of Loading
    CD_PORT_OF_DISCHARGE VARCHAR(50),                   -- Port of Discharge
    -- Item Fields
    CD_DOCUMENT_LINE INT NOT NULL,                      -- Item Number of PO (Primary Key with Document No)
    CD_ITEM VARCHAR(18),                                -- Material Number
    CD_PLANT VARCHAR(4),                                -- Plant
    CD_STORAGE_LOCATION VARCHAR(4),                     -- Storage Location
    VL_ITEM_ORDER_QTY DECIMAL(18,3),                    -- Ordered Quantity
    CD_ITEM_ORDER_UNIT VARCHAR(3),                      -- Order Unit
    CD_CURRENCY VARCHAR(3),                             -- Currency
    VL_EXCHANGE_RATE DECIMAL(12,6),                     -- Exchange Rate
    AMT_NET_PRICE_EUR DECIMAL(18,2),                    -- Net Price in EUR
    NUM_PRICE_UNIT INT,                                 -- Price Unit
    AMT_NET_PRICE_FC DECIMAL(18,2),                     -- Net Order Value (Total)
    CD_VENDOR VARCHAR(10),                              -- Vendor
    CD_PURCHASING_GROUP VARCHAR(3),                     -- Purchasing Group
    CD_PURCHASING_ORG VARCHAR(4),                       -- Purchasing Organization
    CD_EFFECTIVE_VALUE DECIMAL(18,2),                   -- Effective Value
    VL_ITEM_COMMITTED_QTY DECIMAL(18,3),                -- Committed Quantity
    CD_INCOTERMS VARCHAR(10),                           -- Incoterms
    CD_INCOTERMS_L1 VARCHAR(50),                        -- Incoterms Level 1
    CD_INCOTERMS_L2 VARCHAR(50),                        -- Incoterms Level 2
    AMT_GROSS_PRICE_FC DECIMAL(18,2),                   -- Gross Price in FC
    FL_DOCUMENT_LINE_DELETION CHAR(1),                  -- Line Item Deletion Flag
    CD_CONTRACT_REFERENCE VARCHAR(150),                  -- Contract Reference
    D_ITEM_READY_DATE DATE,                             -- Item Ready Date
    CD_DOWN_PAYMENT_CATEGORY VARCHAR(10),               -- Down Payment Category
    D_LINE_DOWN_PAYMENT DATE,                           -- Line Down Payment Due Date
    PERC_LINE_DOWN_PAYMENT DECIMAL(5,2),                -- Line Down Payment Percentage
    AMT_LINE_FIXED_DOWN_PAYMENT_FC DECIMAL(18,2),       -- Line Fixed Down Payment Amount
    CD_CONTRACT_NUMBER VARCHAR(20),                     -- Contract Number (Duplication of Outline Agreement?)
    D_IM_READY DATE,                                    -- Inventory Ready for Movement
    CD_CONFIRMATION_CONTROL_TYPE VARCHAR(4),            -- Confirmation Control Type
    CD_GOODS_SUPPLIER VARCHAR(10),                      -- Subcontractor Supplier Code
    D_LINE_LAST_CHANGED DATE,                           -- Last Change Date for Line
    D_QUALITY_CONTROL DATE,                             -- Quality Control Inspection Date
    CD_INFO_RECORD VARCHAR(10),                         -- Info Record Number
    D_LINE_ETD DATE ,                                   -- Estimated Time of Departure (Item Level)
    FL_DELIVERY_COMPLETED VARCHAR(1),                   --     Delivery Completed Indicator (X = yes)
    ----SCN
    FL_BOOKING_CONFIRMED VARCHAR(1),                    -- Booking Confirmed Y/N
    FL_BOOKING_CONFIRMED_Z2 VARCHAR(1),                    -- Booking Confirmed Y/N
    FL_BOOKING_CONFIRMED_Z3 VARCHAR(1),                    -- Booking Confirmed Y/N
    D_CREATED_BOOKING_CONFIRMED_Z3 DATE,                   -- Creation date of the booking comfirmed line
    D_DELIVERY_BOOKING_CONFIRMED_Z3 DATE,                   -- Delivery date of the booking comfirmed line
    --- SCL 
    D_ETA_WAREHOUSE DATE,                                    -- Estimated Time of Arrival at warehouse

    DT_DWH_CREATED smalldatetime NOT NULL,
	DT_DWH_UPDATED smalldatetime NOT NULL
)
    
