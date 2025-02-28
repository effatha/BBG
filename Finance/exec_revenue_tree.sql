/**********************************
** RELOAD STOCK MOVEMENT
***********************************/
EXEC WR.WR_TX_L0_S4HANA_2LIS_03_BF_L1_FACT_A_STOCK_MOVEMENT
EXEC WR.WR_SP_SRG_L1_FACT_A_STOCK_MOVEMENT
EXEC WR.WR_HIST_FULL_L1_FACT_A_STOCK_MOVEMENT
--select top 10 * from  [L1].[L1_FACT_A_STOCK_MOVEMENT] where CD_BATCH is not null

/**********************************
** General Ledger
***********************************/
EXEC WR_FIN.WR_TX_L0_S4HANA_ACDOCA_L1_FACT_A_GENERAL_LEDGER
EXEC WR_FIN.[WR_SP_SRG_L1_FACT_A_GENERAL_LEDGER]
EXEC WR_FIN.WR_HIST_FULL_L1_FACT_A_GENERAL_LEDGER

SELECT COUNT(*) FROM [WR_FIN].[WR_L1_FACT_A_GENERAL_LEDGER] 
SELECT COUNT(*) FROM [L1_FIN].[L1_FACT_A_GENERAL_LEDGER] 
-- TRUNCATE TABLE [L1_FIN].[L1_FACT_A_GENERAL_LEDGER] 
/**********************************
** RELOAD ACDOCA MATRIX
***********************************/
EXEC WR.WR_TX_L0_MI_ACDOCAKPIMATRIX_L1_DIM_A_FINANCE_KPI_MATRIX
EXEC WR.WR_SP_SRG_L1_DIM_A_FINANCE_KPI_MATRIX
EXEC WR.WR_HIST_FULL_L1_DIM_A_FINANCE_KPI_MATRIX

with cte_dup as (
SELECT * 
FROM [WR_FIN].WR_L1_DIM_A_FINANCE_TRAN_KPI_MATRIX
GROUP BY CD_FINANCE_TRAN_KPI_MATRIX
HAVING COUNT(*)>1
)
DELETE m FROM [WR].WR_L1_DIM_A_FINANCE_TRAN_KPI_MATRIX m join cte_dup dup on dup.CD_FINANCE_TRAN_KPI_MATRIX = m.CD_FINANCE_TRAN_KPI_MATRIX
where m.[VL_REVENUE_PARAM]  is null
--TRUNCATE TABLE [WR].[WR_SRG_L1_DIM_A_FINANCE_TRAN_KPI_MATRIX]
/**********************************
** RELOAD SALES FINANCE KPI
***********************************/
--TRUNCATE TABLE [WR_FIN].[WR_L1_FACT_A_FINANCE_TRANSACTIONS_KPI] 
select month(D_CREATED),sum(amt_net_order_value_est_EUR) from L1.L1_FACT_A_SALES_TRANSACTION_KPI where year(D_CREATED) = 2023 group by month(D_CREATED) order by 1

DECLARE @nMonth as int  = 1

WHILE (@nMonth <= 12)
BEGIN
	print 'start month['+cast(@nMonth as nvarchar(50))+']'

	EXEC WR_FIN.WR_TX_L1_FACT_A_SALES_TRANSACTIONS_L1_FACT_A_FINANCIAL_TRANSACTION_KPI @NUM_YEAR =2023,@NUM_PERIOD =@nMonth
	EXEC WR_FIN.WR_HIST_FULL_L1_FACT_A_FINANCIAL_TRANSACTIONS_KPI

	print 'end month['+cast(@nMonth as nvarchar(50))+']'

	SET @nMonth = @nMonth+1
END

/**********************************
** RELOAD ACDOCA FINANCE KPI
***********************************/
--TRUNCATE TABLE [WR_FIN].[WR_L1_FACT_A_FINANCE_TRANSACTIONS_KPI] 

select  num_posting_period,cd_dataset,max(DT_DWH_CREATED) 
from [L1_FIN].[L1_FACT_A_FINANCE_TRANSACTIONS_KPI] 
where cd_dataset = 'GENERAL LEDGER'
GROUP BY num_posting_period,cd_dataset 
order by 1

DECLARE @nMonth as int  = 9

WHILE (@nMonth <= 12) 
BEGIN

	print 'start month['+cast(@nMonth as nvarchar(50))+']'

	EXEC WR_FIN.WR_TX_L1_FACT_A_GENERAL_LEDGER_L1_FACT_A_FINANCIAL_TRANSACTION_KPI @NUM_YEAR =2023,@NUM_PERIOD =@nMonth
	EXEC WR_FIN.WR_HIST_FULL_L1_FACT_A_FINANCIAL_TRANSACTIONS_KPI

	print 'end month['+cast(@nMonth as nvarchar(50))+']'

	SET @nMonth = @nMonth+1

END


/**********************************
** RELOAD LUCANET
***********************************/
--TRUNCATE TABLE [WR_FIN].[WR_L1_FACT_A_FINANCE_TRANSACTIONS_KPI] 

select distinct num_posting_period from [WR_FIN].[WR_L1_FACT_A_FINANCE_TRANSACTIONS_KPI] 

DECLARE @nMonth as int  = 1

WHILE (@nMonth <= 12)
BEGIN

	print 'start month['+cast(@nMonth as nvarchar(50))+']'

	EXEC WR_FIN.WR_TX_L1_FACT_SALES_ACCOUNTING_LUCANET_L1_FACT_A_FINANCIAL_TRANSACTION_KPI @NUM_YEAR =2023,@NUM_PERIOD =@nMonth
	EXEC WR_FIN.WR_HIST_FULL_L1_FACT_A_FINANCIAL_TRANSACTIONS_KPI

	print 'end month['+cast(@nMonth as nvarchar(50))+']'

	SET @nMonth = @nMonth+1

END


SELECT cd_dataset,num_posting_period,max(DT_DWH_CREATED)
FROM  [L1_FIN].[L1_FACT_A_FINANCE_TRANSACTIONS_KPI] 
GROUP BY cd_dataset,num_posting_period

num_posting_period = 1 and CD_BATCH IS NOT NULL
  --where [CD_DATASET] = 'GENERAL LEDGER'



  select count(*) from WR.WR_L1_FACT_A_GENERAL_LEDGER 
WHERE NUM_POSTING_YEAR = 2023 AND NUM_POSTING_PERIOD = 1

select distinct NUM_POSTING_PERIOD from WR.WR_L1_FACT_A_GENERAL_LEDGER where NUM_POSTING_YEAR = 2023

SELECT  NUM_POSTING_PERIOD,SUM(AMT_NET_PRODUCT_COSTS_THEREOF_RETURN_MEK_EUR)AMT_NET_PRODUCT_COSTS_THEREOF_RETURN_MEK_EUR
FROM L1_FIN.[L1_FACT_A_FINANCE_TRANSACTIONS_KPI]
GROUP BY  NUM_POSTING_PERIOD
ORDER BY 1


SELECT TOP 10 *
FROM L1_FIN.[L1_FACT_A_FINANCE_TRANSACTIONS_KPI]
WHERE [AMT_NET_PRODUCT_COSTS_THEREOF_RETURN_AFTER_DEVALUATION_EUR] <> 0 AND NUM_POSTING_YEAR = 2023


SELECT count(*)
FROM L1_FIN.[L1_FACT_A_FINANCE_TRANSACTIONS_KPI] where num_posting_period = 11
WHERE CD_FI_DOCUMENT_NO = '6301453721'



SELECT  *
FROM L1.L1_FACT_A_SALES_TRANSACTION_KPI 
WHERE
	CD_DOCUMENT_NO = '6301453721'


	--select *  FROM [L0_FIN].[L0_S4HANA_0fi_acdoca_10] acdoca where AWREF = '4918013270'
	--select *  FROM [L0].[L0_S4HANA_2LIS_03_BF] acdoca where AWREF = '4918013270'

	select AWREF,AWITEM,*  FROM [L0_FIN].[L0_S4HANA_0fi_acdoca_10] acdoca where AWREF = '4912788651' and rldnr='0L' and racct like '00516%'

	select *  FROM [L0].[L0_S4HANA_2LIS_03_BF] where MBLNR = '4912788651' and zeile = 1



SELECT  POPER,mseg_charg.CHARG,mseg_re.BWART,acdoca.FKART,acdoca.BLART,acdoca.BWTAR, SUM(HSL)HSL,SUM(MSL)MSL
FROM [L0_FIN].[L0_S4HANA_0fi_acdoca_10] acdoca
INNER JOIN [L0].[L0_S4HANA_2LIS_03_BF] mseg_re
	on acdoca.AWREF = mseg_re.MBLNR
		AND cast(acdoca.AWITEM as int) = cast(mseg_re.zeile as int)
		and acdoca.GJAHR = mseg_re.[MJAHR]
		and acdoca.RACCT = '0051600000'
LEFT JOIN [L0].[L0_S4HANA_2LIS_03_BF] mseg_charg
	on mseg_re.MBLNR = mseg_charg.MBLNR
--		AND mseg_re.zeile = mseg_charg.zeile
		AND mseg_re.KDAUF = mseg_charg.KDAUF
		AND mseg_re.KDPOS = mseg_charg.KDPOS
		AND mseg_charg.CHARG <> 'RE'
		AND mseg_re.CHARG = 'RE'
  WHERE 
	acdoca.GJAHR = 2023
	AND 
	acdoca.RLDNR = '0L'
	AND
	acdoca.RBUKRS = '1000'

GROUP BY POPER,mseg_charg.CHARG,mseg_re.BWART,acdoca.FKART,acdoca.BLART,acdoca.BWTAR




SELECT SUM(ISNULL(AMT_NET_PRODUCT_COSTS_THEREOF_RETURN_MEK_EUR,0)) 
FROM L1.L1_FACT_A_SALES_TRANSACTION_KPI 
WHERE YEAR(D_CREATED )=2023 AND CD_TYPE IN ('G2','CBRE','ZG2','ZG3','S2') and MONTH(D_CREATED )=11



sELECT * FROM L0.L0_S4HANA_2LIS_13_VDKON WHERE VBELN = '6301453721' and POSNR ='000010'


SELECT TOP 10 AMT_NET_PRODUCT_COSTS_THEREOF_RETURN_MEK_EUR
FROM L1_FIN.[L1_FACT_A_FINANCE_TRANSACTIONS_KPI]
WHERE CD_SALES_ORDER_NO ='6301453721'


SELECT CD_BATCH, sum([AMT_NET_PRODUCT_COSTS_THEREOF_RETURN_AFTER_DEVALUATION_EUR])
FROM L1_FIN.[L1_FACT_A_FINANCE_TRANSACTIONS_KPI] f
INNER JOIN L1.L1_DIM_A_ITEM item on item.ID_ITEM = f.ID_ITEM
WHERE
 num_posting_year = 2023 and num_posting_period = 11
Group by CD_BATCH


select top 
FROM L1_FIN.[L1_FACT_A_FINANCE_TRANSACTIONS_KPI] f



select * from L1.[L1_FACT_A_STOCK_MOVEMENT] where CD_DOCUMENT_NO = '4918013270' order by cd_document_line
select * from WR.[WR_L1_FACT_A_STOCK_MOVEMENT] where CD_DOCUMENT_NO = '4918013270' order by cd_document_line


SELECT 
    CD_STOCK_MOVEMENT						=  CONCAT(stock.MBLNR,'#',stock.ZEILE,'#',stock.MJAHR,'#',stock.BSTAUS)
    ,CD_SOURCE_SYSTEM						= 'SAP'
	,CD_DOCUMENT_NO							= stock.MBLNR
	,CD_DOCUMENT_LINE						= stock.ZEILE
	,ID_ITEM                                = item.ID_ITEM 
	,CD_STOCK_MOVEMENT_TYPE					= stock.BWART
	,CD_STOCK_CATEGORY						= stock.BSTAUS
	,D_CREATED								= stock.BLDAT
	,NUM_POSTING_YEAR						= stock.MJAHR
	,CD_BATCH								= stock.CHARG
	,CD_BATCH_DEVALUATION					= ISNULL(mseg_charg.CHARG,stock.CHARG)
	,D_FI_POSTING							= stock.BUDAT
    ,LOAD_TIMESTAMP							= GETDATE()
FROM L0.L0_S4HANA_2LIS_03_BF stock 
LEFT JOIN [WR].[WR_SRG_L1_DIM_A_ITEM] item 
	on item.CD_SOURCE_SYSTEM = 'SAP'
		and item.CD_ITEM = stock.MATNR
LEFT JOIN [L0].[L0_S4HANA_2LIS_03_BF] mseg_charg
	on stock.MBLNR = mseg_charg.MBLNR
--		AND mseg_re.zeile = mseg_charg.zeile
		AND stock.KDAUF = mseg_charg.KDAUF
		AND stock.KDPOS = mseg_charg.KDPOS
		AND mseg_charg.CHARG <> 'RE'
WHERE 1 = 1
    and stock.MBLNR = '4918013270' and item.ID_ITEM = 21532









SELECT TOP 10 *
FROM L1_FIN.[L1_FACT_A_FINANCE_TRANSACTIONS_KPI]
where cd_document_no =''




SELECT TOP 10 *
FROM L1.[L1_FACT_A_SALES_TRANSACTION_KPI]
where cd_document_no ='1400429877'