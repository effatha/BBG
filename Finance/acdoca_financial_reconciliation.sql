---BUDAT
SELECT	'Result Group'
	--,DocumentNo
	--,DocumentPosition
	--,AccountNumber
	--,DocumentTYPE
	--,MovementType
	,FiscalYear
	,PostingPeriod
	,sum(NetOrderValue) NetOrderValue
	,sum(RevenueInvoiceCancellation) RevenueInvoiceCancellation

	,sum(Refunds) Refunds
	,sum(RefundInvoiceCancellation) RefundInvoiceCancellation
	, sum(Revenue_ManualPosting) Revenue_ManualPosting
	, sum(NetProductCost) NetProductCost
	, sum(COGS_FX_hedging_impact) COGS_FX_hedging_impact
	, sum(COGS_Stock_Value_adjustment)  COGS_Stock_Value_adjustment
	, sum(Demurrage_detention) Demurrage_detention
	, sum(Dead_freight) Dead_freight
	, sum(kickbacks) kickbacks
	, sum(ThirdPartyServices) ThirdPartyServices
	, sum(RMA) RMA
	, sum(Samples) Samples
	, sum(DropShipment) DropShipment
	, sum(InboundFreightCosts) InboundFreightCosts
FROM  (
 
		SELECT [RACCT] as AccountNumber
			  ,ac.[KDAUF] AS DocumentNo -- key
			  ,ac.[KDPOS] AS DocumentPosition -- key
			  ,ac.[FKART] AS InvoiceType
			  ,ac.[HSL]   AS Amount_Company_currency-- GrossPrice
			  ,ac.[BLART] AS DocumentTYPE
			  ,ac.[AWREF] As ReferenceDocumentNo
			  ,ac.[GJAHR] AS FiscalYear
			  ,ac.POPER AS PostingPeriod
			  ,ac.[BELNR] AS AccountingDocumentNumber
			  ,ac.[RASSC] AS TraderCompanyID
			  ,ac.MSL AS Quantity
			  ,ac.RBUKRS AS CompanyCode
			  ,bf.BWART AS MovementType
			  ,CASE WHEN RACCT in (   '0041000000'
									,'0041001000'
									,'0041001010'
									,'0041001500'
									,'0042000002'
									,'0042001002'
									,'0042001012'
									,'0044002000'
									,'0044002100'
									,'0044003000'
									,'0044003100'
									,'0044003110'
									,'0044004012'
									,'0044004102') 
									and   FKART in('F2','L2','ZF2')

			THEN HSL ELSE 0 END NetOrderValue
			,
			CASE WHEN RACCT in (   '0041000000'
									,'0041001000'
									,'0041001010'
									,'0041001500'
									,'0042000002'
									,'0042001002'
									,'0042001012'
									,'0044002000'
									,'0044002100'
									,'0044003000'
									,'0044003100'
									,'0044003110'
									,'0044004012'
									,'0044004102') 
									and   FKART in('S1')

			THEN HSL ELSE 0 END RevenueInvoiceCancellation
			,
			CASE WHEN RACCT in (   '0041000000'
									,'0041001000'
									,'0041001010'
									,'0041001500'
									,'0042000002'
									,'0042001002'
									,'0042001012'
									,'0044002000'
									,'0044002100'
									,'0044003000'
									,'0044003100'
									,'0044003110'
									,'0044004012'
									,'0044004102') 
									and   FKART in('G2','ZG2','ZG3')

			THEN HSL ELSE 0 END Refunds
			,CASE WHEN RACCT in (   '0041000000'
									,'0041001000'
									,'0041001010'
									,'0041001500'
									,'0042000002'
									,'0042001002'
									,'0042001012'
									,'0044002000'
									,'0044002100'
									,'0044003000'
									,'0044003100'
									,'0044003110'
									,'0044004012'
									,'0044004102') 
									and   FKART in('S2')

			THEN HSL ELSE 0 END RefundInvoiceCancellation
			,			
			CASE WHEN RACCT in (   '0041000000'
									,'0041001000'
									,'0041001010'
									,'0041001500'
									,'0042000002'
									,'0042001002'
									,'0042001012'
									,'0044002000'
									,'0044002100'
									,'0044003000'
									,'0044003100'
									,'0044003110'
									,'0044004012'
									,'0044004102') 
									and   FKART not in('G2','S2','ZG2','ZG3','F2','L2','S1','ZF2')

			THEN HSL ELSE 0 END Revenue_ManualPosting
			,
			CASE WHEN bf.MBLNR is not null 
						AND BWART in ('Z19','Z92','601','633','634')
						and   ac.BLART  in('WA','WL')

			THEN HSL ELSE 0 END NetProductCost
			,

			CASE WHEN (ac.RACCT in (   '0072011000'	,'0072511000') OR (RACCT in ('0052031000','0052531000') AND  bk.TCODE = '' )	) 
				THEN HSL ELSE 0 END COGS_FX_hedging_impact

			,
			CASE WHEN ( 
							(RACCT in ('0052031000','0052531000') AND  bk.TCODE <> '' ) 
									OR 
							(RACCT= '0051600000' AND AC.BLART NOT IN ('WA','WL') )
									OR
							(RACCT= '0051600000' AND ac.BLART = 'WA' AND BWART not in ('Z19','Z92','601','633','634'))
					)
				THEN HSL ELSE 0 END COGS_Stock_Value_adjustment
			,CASE WHEN RACCT in (   '0051905801') THEN HSL ELSE 0 END AS Demurrage_detention
			,CASE WHEN RACCT in (   '0051905802')  THEN HSL ELSE 0 END AS Dead_freight
			,CASE WHEN RACCT in (   '0051600002') AND RASSC <> '5100' THEN HSL ELSE 0 END AS kickbacks
			,CASE WHEN RACCT in (   '0065001000','0065008500') THEN HSL ELSE 0 END AS ThirdPartyServices
			,CASE WHEN RACCT in (   '0051600421')  THEN HSL ELSE 0 END AS RMA
			,CASE WHEN RACCT in (   '0052021100') THEN HSL ELSE 0 END AS Samples
			,CASE WHEN RACCT in (   '0061002000') THEN HSL ELSE 0 END AS DropShipment
			,CASE WHEN RACCT in (   '0051600300','0051600310')  THEN HSL ELSE 0 END AS InboundFreightCosts

		  FROM [L0].L0_S4HANA_0fi_acdoca_10 ac
		  LEFT JOIN L0.L0_S4HANA_2LIS_03_BF bf
			on 
				bf.[MBLNR] = ac.[AWREF] 
				AND cast(bf.ZEILE as int) = cast(ac.AWITEM as int)--- missing columns 
				AND bf.[MJAHR] = ac.GJAHR 
				and ac.RACCT = '0051600000' 
				
			LEFT JOIN L0.L0_S4HANA_BKPF bk
				on 
					bk.[BELNR] = ac.[BELNR]
					AND bk.BUKRS = ac.RBUKRS 
					AND bk.[GJAHR] = ac.GJAHR 
					
		  Where 1 = 1
			and ac.RBUKRS = '1000'
		 AND ac.[GJAHR] = 2022 
		 and ac.RLDNR = '0L'
		 --and HSL > 0
		 and poper = 4
	--	 and ac.KDAUF = '0403056280'
	--	 and ac.[KDPOS]=100
	) res
group by  FiscalYear, PostingPeriod	
	--,AccountNumber
	--,DocumentTYPE
	--,MovementType
order by FiscalYear,PostingPeriod

  ----join with 03_bf: MBLNR ; filter pn BWART: 661,662
		--select top 10 *
  --		  FROM [L0].L0_S4HANA_0fi_acdoca_10 ac
		--  where RACCT  = '0051600000'




--select top 5 racct,RLDNR,[GJAHR],RBUKRS,HSL,*  FROM [L0].L0_S4HANA_0fi_acdoca_10 ac where racct = '0065001000'  and ac.RLDNR = '0L'

--select KDPOS,*  FROM [L0].L0_S4HANA_0fi_acdoca_10 ac where KDAUF = '0401459227'