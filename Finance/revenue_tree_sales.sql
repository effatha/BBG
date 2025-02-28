DECLARE @PROCESS_ID nvarchar(50)= '0404172204'

SELECT	1
	---only ledger
	,ID_GENERAL_LEDGER					 = NULL
    ,CD_ACCOUNT_NUMBER                   = NULL
	,CD_FI_TYPE                          = NULL
	,CD_FI_DOCUMENT_NO                   = NULL
    ,CD_FI_DOCUMENT_LINE                 = NULL
	,CD_REFERENCE_PROCEDURE              = NULL
	,CD_REFERENCE_ORG_UNIT               = NULL
	,CD_REFERENCE_DOCUMENT_NO            = NULL
	,CD_REFERENCE_DOCUMENT_LINE          = NULL
	,FL_IS_REVERSING_ANOTHER_ITEM        = NULL
	,FL_IS_REVERSED                      = NULL
	,ID_COMPANY_FI_REVERSAL              = NULL
	,CD_REVERSAL_FI_DOCUMENT_NO          = NULL
	,CD_CURRENCY_COMPANY                 = NULL
	,CD_CURRENCY_GLOBAL                  = NULL
	,CD_CURRENCY_BALANCE                 = NULL
	-- only sales
	,CD_SALES_TYPE						 = sales.CD_TYPE

	-- ledger / sales
	 CD_SOURCE_SYSTEM					 = sales.CD_SOURCE_SYSTEM
    ,ID_ITEM                             = sales.ID_ITEM
	,ID_STORAGE_LOCATION				 = storage.ID_STORAGE_LOCATION
	,ID_COMPANY                          = sales.ID_COMPANY
	,NUM_POSTING_YEAR                    = YEAR(sales.D_CREATED)
    ,NUM_POSTING_PERIOD                  = MONTH(sales.D_CREATED)
	,CD_CURRENCY_TRANSACTION             = sales.CD_CURRENCY
    ,VL_QUANTITY						 = sales.VL_ITEM_QUANTITY
    ,ID_SALES_TRANSACTION                = sales.ID_SALES_TRANSACTION
	,CD_CUSTOMER                         = sales.CD_CUSTOMER



FROM L1.L1_FACT_A_SALES_TRANSACTION_KPI sales
INNER JOIN L1.[L1_DIM_A_SALES_TRANSACTION_TYPE] ttype on ttype.[ID_SALES_TRANSACTION_TYPE]=sales.[ID_SALES_TRANSACTION_TYPE]
LEFT JOIN L1.[L1_DIM_A_STORAGE_LOCATION] storage
	on storage.[CD_STORAGE_LOCATION] = sales.[CD_STORAGE_LOCATION]
WHERE 1=1
	AND sales.CD_SALES_PROCESS_ID = @PROCESS_ID
	and ttype.[CD_SALES_TRANSACTION_CATEGORY] in ('Order')