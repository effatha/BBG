/****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
  FROM [CT dwh 03 Intelligence].[purch].[tDimPurchaser]



  ALTER TABLE [CT dwh 03 Intelligence].[purch].[tDimPurchaser] ADD DisponentName nvarchar(50) null

  update p set DisponentName = EKNAM
  from [CT dwh 03 Intelligence].[purch].[tDimPurchaser] p
  INNER JOIN [CT dwh 01 Stage].[dbo].[tSAP_T024] disponent
  on p.[Disponent] = [EKGRP]


  select * from 