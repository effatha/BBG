/***********************************************
** CANCELLED DOCUMENT --- VAKON (AFTER MAY 23)
**Example:0404642690
** The ROCANCEL = 'R' doesn't belong to the business key, therefore when a record is extracted with that value, the DWH assumes that is that last status of the record(reversed value)
** When doing the calculation, for non-cancelled orders, we can simply ignore this value, as it was deleted,
** but for cancelled orders we need to take in account these values to have the order initial values. (only consider the rocancel='R' WHEN vaitm.abgru <> '')
*************************************************/
DECLARE @DOCUMENTNO  as nvarchar(50) = '0403068362'
SELECT  ROCANCEL,VBELN, POSNR,KSCHL,KWERT FROM [L0].[L0_S4HANA_2LIS_11_VAKON] 
where VBELN = @DOCUMENTNO AND KSCHL IN ('PCIP','ZMWI','ZMWS','TTX1','ZPRM')
ORDER BY VBELN ,POSNR,KSCHL

SELECT CD_DOCUMENT_NO, CD_DOCUMENT_LINE,AMT_GROSS_PRICE_EUR,AMT_TAX_PRICE_EUR,*  FROM L1.L1_FACT_A_SALES_TRANSACTION SALES WHERE CD_DOCUMENT_NO = @DOCUMENTNO

SELECT * FROM L0.L0_S4HANA_2LIS_11_VAITM WHERE VBELN = @DOCUMENTNO






/***********************************************
** CANCELLED DOCUMENT --- PRCD_ELEMENTS (BEFORE MAY 23)
**Example:0404642690
** The ROCANCEL = 'R' doesn't belong to the business key, therefore when a record is extracted with that value, the DWH assumes that is that last status of the record(reversed value)
** When the extractor gets reinited the first 'Full load' comes without any cancelled pricing condition (rocancel='R'),
** so to calculate values for cancelled orders we need to look into the PRCD table
*************************************************/










---0404642690  --- gov with rocancel R  => value comes as negative for cancelled orders, so we have to consider that value to calculate gross price for cancelled positions and then multiply by -1,

--SELECT TOP 10 KNUMV, * FROM [L0].[L0_S4HANA_PRCD_ELEMENTS]
--WHERE 
--	KNUMV = (SELECT  DISTINCT KNUMV FROM L0.L0_S4HANA_VBAK WHERE VBELN = @DOCUMENTNO)




--select *  FROM L1.L1_FACT_A_SALES_TRANSACTION_KPI sales where cd_document_no = '0402113085'


SELECT top 10 ROCANCEL,VBELN, POSNR,KSCHL,KWERT,AUGRU,ABGRU,KINAK,*
select distinct ABSTA
FROM [L0].[L0_S4HANA_2LIS_11_VAKON]
WHERE 
--ERDAT <='2023-04-01' and 
auart in ('ZAA','ZAZ','ZKE') and rocancel = 'R' --AND ABSTA = '' 
--and LOAD_TIMESTAMP< '2023-05-03'
and vbeln ='0404642690'
and vbeln = '0403068362'

and KSCHL = 'ZPRM' 


SELECT * FROM L1.L1_FACT_A_SALES_TRANSACTION WHERE CD_DOCUMENT_NO IN ('0404642690','0403068362')
SELECT * FROM L0.L0_S4HANA_2LIS_11_VAHDR WHERE VBELN IN ('0404642690','0403068362')
SELECT * FROM L0.L0_S4HANA_2LIS_11_VAITM WHERE VBELN IN ('0404642690','0403068362')



SELECT * FROM L0.L0_S4HANA_2LIS_11_VAITM where abgru<>'' and erdat >='2023-06-1'

select distinct ROCANCEL
FROM [L0].[L0_S4HANA_2LIS_11_VAKON] where vbeln = '0404469621'
