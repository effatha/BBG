SELECT top 10 
    CD_GENERAL_LEDGER =                     CONCAT(acdoca.RLDNR,'#',acdoca.RBUKRS,'#',acdoca.GJAHR,'#',acdoca.BELNR,'#',acdoca.DOCLN)
    ,CD_SOURCE_SYSTEM						= 'SAP'
    ,CD_LEDGER                              = acdoca.RLDNR
    ,ID_COMPANY                             = company.ID_COMPANY -- acdoca.RBUKRS
    ,NUM_POSTING_YEAR                       = acdoca.GJAHR
    ,CD_FI_DOCUMENT_NO                      = acdoca.BELNR
    ,CD_FI_DOCUMENT_LINE                    = acdoca.DOCLN
    ,CD_FI_TYPE                             = acdoca.RMVCT
    ,CD_REFERENCE_PROCEDURE                 = acdoca.AWTYP
    ,CD_REFERENCE_ORG_UNIT                  = acdoca.AWORG
    ,CD_REFERENCE_DOCUMENT_NO               = acdoca.AWREF
    ,CD_REFERENCE_DOCUMENT_LINE             = acdoca.AWITEM
    ,FL_IS_REVERSING_ANOTHER_ITEM           = acdoca.XREVERSING
    ,FL_IS_REVERSED                         = acdoca.XREVERSED
    ,ID_COMPANY_FI_REVERSAL                 = company_reversal.ID_COMPANY --acdoca.AWORG_REV
    ,CD_REVERSAL_FI_DOCUMENT_NO             = acdoca.AWREF_REV
    ,CD_CURRENCY_TRANSACTION                = acdoca.RWCUR
    ,CD_CURRENCY_COMPANY                    = acdoca.RHCUR
    ,CD_CURRENCY_GLOBAL                     = acdoca.RKCUR
    ,CD_CURRENCY_BALANCE                    = acdoca.RTCUR
    ,CD_UNIT                                = acdoca.RUNIT
    ,CD_ACCOUNT_NUMBER                      = acdoca.RACCT
    ,CD_PROFIT_CENTER                       = acdoca.PRCTR
    ,CD_CONTROLLING_AREA                    = acdoca.KOKRS
    ,CD_SEGMENT                             = acdoca.SEGMENT
    ,CD_PROFIT_CENTER_PARTNER               = acdoca.PPRCTR
    ,CD_TRADING_PARTNER                     = acdoca.RASSC
    ,AMT_AMOUNT_BALANCE                     = acdoca.TSL
    ,AMT_AMOUNT_TRANSACTION                 = acdoca.WSL
    ,AMT_AMOUNT_COMPANY                     = acdoca.HSL
    ,AMT_AMOUNT_GLOBAL                      = acdoca.KSL
    ,VL_QUANTITY                            = acdoca.MSL
    ,VL_QUANTITY_INVENTORY                  = acdoca.LBKUM
    ,NUM_POSTING_PERIOD                     = acdoca.POPER
    ,CD_FISCAL_YEAR_VARIANT                 = acdoca.PERIV
    ,D_FI_POSTING                           = acdoca.BUDAT
    ,D_FI_CREATED                           = acdoca.BLDAT
    ,CD_DOCUMENT_TYPE_FI                    = acdoca.BLART
    ,CD_POSTING_KEY                         = acdoca.BSCHL
    ,CD_FI_DOCUMENT_LINE_CATEGORY           = acdoca.LINETYPE
    ,CD_TRANSACTION_KEY                     = acdoca.KTOSL
    ,DT_FI_TIMESTAMP                        = acdoca.TIMESTAMP
    ,CD_OBJECT_ORIGIN                       = acdoca.RHOART
    ,CD_GL_ACCOUNT_TYPE                     = acdoca.GLACCOUNT_TYPE
    ,CD_CHART_OF_ACCOUNTS                   = acdoca.KTOPL
    ,CD_ACCOUNT_NUMBER_ALTERNATIVE          = acdoca.LOKKT
    ,CD_CHART_OF_ACCOUNTS_ALTERNATIVE       = acdoca.KTOP2
    ,CD_PURCHASING_DOCUMENT_NO              = acdoca.EBELN
    ,ID_SALES_TRANSACTION                   = sales.[ID_SALES_TRANSACTION] --- KDAUF AND KDPOS
    ,ID_ITEM                                = item.ID_ITEM --acdoca.MATNR
    ,ID_STORAGE_LOCATION                    = storage.[ID_STORAGE_LOCATION] ---acdoca.WERKS
    ,CD_SUPPLIER                            = acdoca.LIFNR
    ,CD_CUSTOMER                            = acdoca.KUNNR
    ,CD_ACCOUNT_TYPE                        = acdoca.KOART
    ,CD_SPECIAL_GL_INDICATOR                = acdoca.UMSKZ
    ,CD_TAX_CODE                            = acdoca.MWSKZ
    ,D_CLEARING_DATE                        = acdoca.AUGDT
    ,CD_CLEARING_DOCUMENT_NO                = acdoca.AUGBL
    ,CD_ITEM_VALUATION_TYPE                 = acdoca.BWTAR
    ,ID_STORAGE_LOCATION_VALUATION          = storage_valuation.[ID_STORAGE_LOCATION]--acdoca.BWKEY
    ,CD_ORIGIN_PROCESS_CATEGORY             = acdoca.MLPTYP
    ,CD_OBJECT_NUMBER                       = acdoca.OBJNR
    ,CD_ACCOUNT_NUMBER_OFFSETTING           = acdoca.GKONT
    ,CD_ACCOUNT_TYPE_OFFSETTING             = acdoca.GKOAR
    ,CD_OBJECT_CLASS                        = acdoca.SCOPE
    ,CD_ACCOUNT_NUMBER_ASSIGMENT            = acdoca.ACCAS
    ,CD_OBJECT_TYPE                         = acdoca.ACCASTY
    ,CD_OPERATING_CONCERN                   = acdoca.ERKRS
    ,CD_CONTROLLING_DOCUMENT_NO             = acdoca.CO_BELNR
    ,ID_SALES_TRANSACTION_TYPE              = type_fi.ID_SALES_TRANSACTION_TYPE--acdoca.FKART
    ,ID_COMPANY_SALES                       = company_sales.ID_COMPANY_SALES --acdoca.VKORG
    ,CD_DIVISION                            = acdoca.SPART
    ,CD_ITEM_GROUP                          = acdoca.MATKL
    ,CD_CUSTOMER_GROUP                      = acdoca.KDGRP
  --  ,[ID_SALES_CHANNEL]                     = channel.ID_SALES_CHANNEL 
FROM L0.L0_S4HANA_0FI_ACDOCA_10 acdoca 
--LEFT JOIN  [WR].[WR_SRG_L1_DIM_A_SALES_CHANNEL] channel
--	on channel.[CD_SOURCE_SYSTEM] = 'SAP'
--		AND channel.[CD_SALES_CHANNEL] = acdoca.VKBUR_PA 
LEFT JOIN WR.WR_SRG_L1_DIM_A_COMPANY company
	on acdoca.RBUKRS = company.CD_COMPANY
	and company.CD_SOURCE_SYSTEM = 'SAP'
LEFT JOIN WR.WR_SRG_L1_DIM_A_COMPANY company_reversal
	on acdoca.AWORG_REV = company_reversal.CD_COMPANY
	and company_reversal.CD_SOURCE_SYSTEM = 'SAP'
LEFT JOIN WR.WR_SRG_L1_DIM_A_COMPANY company_sales
	on acdoca.VKORG = company_sales.CD_COMPANY
	and company_sales.CD_SOURCE_SYSTEM = 'SAP'
LEFT JOIN [WR].[WR_SRG_L1_FACT_A_SALES_TRANSACTION] sales
	on sales.[CD_SALES_TRANSACTION] = CONCAT (acdoca.KDAUF , '#', acdoca.KDPOS)
	and sales.CD_SOURCE_SYSTEM = 'SAP'
LEFT JOIN [WR].[WR_SRG_L1_DIM_A_ITEM] item 
	on item.CD_SOURCE_SYSTEM = 'SAP'
		and item.CD_ITEM = acdoca.MATNR
LEFT JOIN  [WR].[WR_SRG_L1_DIM_A_STORAGE_LOCATION] storage 
	on storage.CD_SOURCE_SYSTEM = 'SAP'
		and storage.[CD_STORAGE_LOCATION] = acdoca.WERKS
		and storage.[CD_COMPANY_CODE] = acdoca.RBUKRS
LEFT JOIN  [WR].[WR_SRG_L1_DIM_A_STORAGE_LOCATION] storage_valuation 
	on storage_valuation.CD_SOURCE_SYSTEM = 'SAP'
		and storage_valuation.[CD_STORAGE_LOCATION] = acdoca.BWKEY
		and storage_valuation.[CD_COMPANY_CODE] = acdoca.RBUKRS
LEFT JOIN [WR].[WR_SRG_L1_DIM_A_SALES_TRANSACTION_TYPE] type_fi 
	on type_fi.CD_SOURCE_SYSTEM = 'SAP'
		and type_fi.[CD_SALES_TRANSACTION_TYPE] = CONCAT(acdoca.FKART ,'#FKART')
WHERE 1 = 1
	AND acdoca.RLDNR = '0L'
