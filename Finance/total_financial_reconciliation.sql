DECLARE @DocumentID as NVARCHAR(50) = '0403056280'
DECLARE @DocumentPosition as NVARCHAR(50) = '000100'
DECLARE @NetPriceRACCT as nvarchar(50) = '0041000000,0041001000,0041001010,0041001500,0042000002,0042001002,0042001012,0044002000,0044002100,0044003000,0044003100
									,0044003110,0044004012,0044004102'
DECLARE @NetPriceTypes as nvarchar(50) = ('F2,L2,ZF2')


---select from l1
SELECT top 10
	CD_DOCUMENT_NO, CD_DOCUMENT_LINE,AMT_NET_PRICE_EUR,*
FROM L1.L1_FACT_A_SALES_TRANSACTION
WHERE 1=1
	AND CD_DOCUMENT_NO = @DocumentID
	AND CD_DOCUMENT_LINE = @DocumentPosition

--- select from PL

SELECT top 10
	DOCUMENTNO, DocumentItemPosition,NetPrice,RevenueEst
FROM PL.PL_V_SALES_TRANSACTIONS
WHERE 1=1
	AND DOCUMENTNO = @DocumentID
	AND DocumentItemPosition = @DocumentPosition


--- select from ACDOCA

SELECT top 100 [RACCT] as AccountNumber
			  ,[KDAUF] AS DocumentNo -- key
			  ,[KDPOS] AS DocumentPosition -- key
			  ,[FKART] AS InvoiceType
			  ,[HSL]   AS Amount_Company_currency
			  ,[BLART] AS DocumentTYPE
			  ,[AWREF] As ReferenceDocumentNo
			  ,[GJAHR] AS FiscalYear
			  ,POPER AS PostingPeriod
			  ,[BELNR] AS AccountingDocumentNumber
			  ,[RASSC] AS TraderCompanyID
			  ,MSL AS Quantity
			  ,RBUKRS AS CompanyCode
			  ,CASE WHEN  NetPriceACCT.value is not null and   NetPriceTypes.value is not null
						THEN HSL ELSE 0 END NetOrderValue
			
			
		  FROM [L0].L0_S4HANA_0fi_acdoca_10 ac
		  LEFT JOIN (select value from string_split (@NetPriceRACCT,',')) NetPriceACCT
			on ac.RACCT = NetPriceACCT.value
		  LEFT JOIN (select value from string_split (@NetPriceTypes,',')) NetPriceTypes
			on ac.FKART = NetPriceTypes.value
		  Where 1 = 1
		  and FKART in('F2','L2','S1','ZF2','G2','S2','ZG2','ZG3')
		  and RBUKRS = '1000'
		  AND [GJAHR] = 2023 
		  and KDAUF = @DocumentID
		  and [KDPOS]=@DocumentPosition
		  and RLDNR = '0L'



