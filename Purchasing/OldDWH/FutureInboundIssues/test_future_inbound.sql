SELECT *
  FROM [CT dwh 03 Intelligence].[dbo].[vFutureInbound] -- 4799
  WHERE
  Processid = '4501021607'

  10035622

---first table to be populated
SELECT * INTO tFactPurchasingOrdersTransactionsVerticalSAPbck20251123 FROM [CT dwh 03 Intelligence].[dbo].[tFactPurchasingOrdersTransactionsVerticalSAP] WHERE  Processid = '4501006552' and itemno = 10034106

SELECT TOP 10 * from [CT dwh 03 Intelligence].dbo.vFactPurchasingOrdersTransactionsSAP 
WHERE  Processid = '4501021607' and itemno = 10035622

--delivery schedules for Purchase Order items
SELECT MENGE,EINDT,* FROM [CT dwh 01 Stage].dbo.tSAP_EKET WHERE EBELN = '4501021607' and EBELP = '00170'
-- delivery scheddules, confirmations
SELECT MENGE,* FROM [CT dwh 01 Stage].dbo.tSAP_EKES WHERE EBELN = '4501004920' and EBELP = '00170'

SELECT MENGE,* FROM [CT dwh 01 Stage].dbo.tSAP_EKPO WHERE EBELN = '4501021607' and EBELP = '00130'

and cast(matnr as int) = '10035160'
 [dbo].[vSAP_EKBE]









--PO history
SELECT BWART,MENGE,BUDAT,BLDAT,* FROM [CT dwh 01 Stage].dbo.tSAP_EKBE WHERE EBELN = '4501006552' and EBELP = '00170'

SELECT BWART,MENGE,BUDAT,BLDAT,* 
FROM [CT dwh 01 Stage].dbo.tSAP_EKBE_HIST 
WHERE EBELN = '4501004920' and EBELP = '00130'

SELECT top 10 * from  [CT dwh 01 Stage].dbo.tSAP_Z_MM_EKBE_FullLoad WHERE EBELN = '4501004920' and EBELP = '00130'

select * from purch.vFactVertical where processid = '4501021607'

SELECT TOP 10 *
FROM [CT dwh 00 Meta].[dbo].[tTransactionTypesConfigSAPEKBE]