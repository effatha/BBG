/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [row_id]
      ,[version]
      ,[valid_from]
      ,[valid_to]
      ,[VBELN]
      ,[BESTK]
      ,[FKSAK]
      ,[FKSTK]
      ,[GBSTK]
      ,[is_current]
      ,[is_deleted]
      ,[LFGSK]
      ,[LFSTK]
      ,[VBTYP]
  FROM [CT dwh 02 Data].[dbo].[tSAP2LIS_11_VASTH]
  where VBELN = '0405867185'



  SELECT VBELN, 
  CASE 
        WHEN GBSTK = 'C' THEN 'Order Processing Complete'
        WHEN GBSTK = 'A' THEN 'Order Processing Active'
        ELSE 'Order Processing'
    END AS OrderProcessingStatus,
    CASE 
        WHEN LFSTK = 'C' THEN 'Delivery Processing Complete'
        WHEN LFSTK = 'A' THEN 'Delivery Processing Active'
        ELSE 'Delivery Processing'
    END AS DeliveryProcessingStatus,
    CASE 
        WHEN FKSTK = 'C' THEN 'Invoicing Complete'
        WHEN FKSTK = 'A' THEN 'Invoicing Active'
        ELSE 'Invoicing'
    END AS InvoicingStatus
    --CASE 
    --    WHEN BSTA = 'C' THEN 'Accounting Complete'
    --    WHEN BSTA = 'A' THEN 'Accounting Active'
    --    ELSE 'Accounting'
    --END AS AccountingStatus
    FROM [CT dwh 02 Data].[dbo].[tSAP2LIS_11_VASTH]
	  where VBELN = '0405867185'
	  and is_current= 1


SELECT 
    VBAK.VBELN AS SalesOrder,
    VBUK.GBSTK AS OrderProcessingStatus
    --LIKP.WBSTA AS DeliveryProcessingStatus,
    --VBRK.FKSTA AS InvoicingStatus,
    --BSID.BSTA AS AccountingStatus,
    --CASE 
    --    WHEN VBUK.GBSTK = 'C' THEN 'Order Complete'
    --    WHEN VBUK.GBSTK = 'A' THEN 'Order Active'
    --    ELSE 'Order In Process'
    --END AS OverallOrderStatus,
    --CASE 
    --    WHEN (SELECT COUNT(*) FROM VBUK WHERE VBELN = VBAK.VBELN AND GBSTK = 'B') > 0 THEN 'Issues Present'
    --    ELSE 'No Issues'
    --END AS OrderIssues
FROM 
    [CT dwh 02 Data].[dbo].[tSAP2LIS_11_VAHDR] vbak
JOIN [CT dwh 02 Data].[dbo].[tSAP2LIS_11_VASTH] VBUK ON VBAK.VBELN = VBUK.VBELN
JOIN [CT dwh 02 Data].[dbo].[tSAP2LIS_12_VCHDR] LIKP ON VBAK.VBELN = LIKP.VBELN
JOIN [CT dwh 02 Data].[dbo].[tSAP2LIS_13_VDHDR] VBRK ON VBAK.VBELN = VBRK.VBELN
--JOIN tSAPZ_FI_BSEG_BKPF BSID ON VBAK.VBELN = BSID.VBELN
	  where vbak.VBELN = '0405867185'


	  


select * FROM tSAP2LIS_11_VAITM where vbeln = '0405867184' and is_current = 1
select *   FROM [CT dwh 02 Data].[dbo].[tSAP2LIS_11_VASTH] where vbeln = '0405867184' and is_current = 1
select *   FROM [CT dwh 01 Stage].[dbo].[tSAP_2LIS_11_VASTI] where vbeln = '0405866944' --and is_current = 1

select WBSTA,* FROM tSAP2LIS_12_VCITM where vbeln = '3005780325'  and is_current = 1

select * FROM tSAP2LIS_13_VDITM where vbeln = '4005694493'  and is_current = 1
select ZZ_FKSTO,* FROM tSAP2LIS_13_VDHDR where vbeln = '4005694493'  and is_current = 1
