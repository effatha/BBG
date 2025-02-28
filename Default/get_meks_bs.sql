 DECLARE @sql as nvarchar(max) = 'INSERT INTO [L0].[L0_MI_BUSINESS_PLAN_MEK_OVERRIDE] ([ITEMNO],[MEK],[VALUATIONDATE],[MEK_SOURCE],[LOAD_TIMESTAMP]) SELECT '
SELECT [ItemNo]
      ,[MEK_Plan_YoY]
      ,[MEK_Hedging]
      ,[Final MEK Hedging]
	  ,[Final MEK Hedging] * 1.15 TotalMEK
	  ,CONCAT(@sql,cast(itemno as nvarchar(10)),',',cast([Final MEK Hedging] * 1.15  as nvarchar(10)),',''2025-01-16'',''SAP PO'',''2025-01-16','''')
  FROM [CT dwh 03 Intelligence].[dbo].[tArticleFinalMEK]
  where
  
  itemno in (

'10046870',
'10046869',
'10046867',
'10046875',
'10046868',
'10046874',
'10046873',
'10047105',
'10046871',
'10046872',
'10046862',
'10046864',
'10047103',
'10047102',
'10047101',
'10047104',
'10046863',
'10047106',
'10046588',
'10046585',
'10046586',
'10046584',
'10046582',
'10046603',
'10046587',
'10046583',
'10046580',
'10046579',
'10046602',
'10046601',
'10046577',
'10046576',
'10046578',
'10046569',
'10046600',
'10046913',
'10046916'
)		
  
  
  
