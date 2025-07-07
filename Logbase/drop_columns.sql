SELECT TOP (1000) [Name]
      ,[AbsenderId]
      ,[Prologisname]
      ,[IgnoreTrackingNumber]
      ,[EscapeOrderNumber]
      ,[CustomerOrder]
      ,[CarrierService]
      ,[AutoDimension]
      ,[WAScan]
      ,[SAPNummer]
      ,[Aktiv]
      ,[UserAend]
      ,[UserNeu]
      ,[ZeitAend]
      ,[ZeitNeu]
  FROM [CT dwh 01 Stage].[alicante].[tWMS_Carrier]


 
ALTER TABLE [CT dwh 01 Stage].[alicante].[tWMS_Carrier] DROP COLUMN [ErpName]
ALTER TABLE [CT dwh 01 Stage].[alicante].[tWMS_Carrier] DROP COLUMN [PlugRottbeck]
ALTER TABLE [CT dwh 01 Stage].[alicante].[tWMS_Carrier] DROP COLUMN [MultiRottbeck]
ALTER TABLE [CT dwh 01 Stage].[alicante].[tWMS_Carrier] DROP COLUMN [NachnahmeRottbeck]
ALTER TABLE [CT dwh 01 Stage].[alicante].[tWMS_Carrier] DROP COLUMN [Rottbeck]
ALTER TABLE [CT dwh 01 Stage].[alicante].[tWMS_Carrier] DROP COLUMN [SAPRottbeck]
ALTER TABLE [CT dwh 01 Stage].[alicante].[tWMS_Carrier] DROP COLUMN [SAPRottbeck]

ALTER TABLE [CT dwh 01 Stage].[bratislava].[tWMS_Carrier] DROP COLUMN [ErpName]
ALTER TABLE [CT dwh 01 Stage].[bratislava].[tWMS_Carrier] DROP COLUMN [PlugRottbeck]
ALTER TABLE [CT dwh 01 Stage].[bratislava].[tWMS_Carrier] DROP COLUMN [MultiRottbeck]
ALTER TABLE [CT dwh 01 Stage].[bratislava].[tWMS_Carrier] DROP COLUMN [NachnahmeRottbeck]
ALTER TABLE [CT dwh 01 Stage].[bratislava].[tWMS_Carrier] DROP COLUMN [Rottbeck]
ALTER TABLE [CT dwh 01 Stage].[bratislava].[tWMS_Carrier] DROP COLUMN [SAPRottbeck]
ALTER TABLE [CT dwh 01 Stage].[bratislava].[tWMS_Carrier] DROP COLUMN [SAPRottbeck]


ALTER TABLE [CT dwh 01 Stage].[kali].[tWMS_Carrier] DROP COLUMN [ErpName]
ALTER TABLE [CT dwh 01 Stage].[kali].[tWMS_Carrier] DROP COLUMN [PlugRottbeck]
ALTER TABLE [CT dwh 01 Stage].[kali].[tWMS_Carrier] DROP COLUMN [MultiRottbeck]
ALTER TABLE [CT dwh 01 Stage].[kali].[tWMS_Carrier] DROP COLUMN [NachnahmeRottbeck]
ALTER TABLE [CT dwh 01 Stage].[kali].[tWMS_Carrier] DROP COLUMN [Rottbeck]
ALTER TABLE [CT dwh 01 Stage].[kali].[tWMS_Carrier] DROP COLUMN [SAPRottbeck]
ALTER TABLE [CT dwh 01 Stage].[kali].[tWMS_Carrier] DROP COLUMN [SAPRottbeck]

ALTER TABLE [CT dwh 01 Stage].[werne].[tWMS_Carrier] DROP COLUMN [ErpName]
ALTER TABLE [CT dwh 01 Stage].[werne].[tWMS_Carrier] DROP COLUMN [PlugRottbeck]
ALTER TABLE [CT dwh 01 Stage].[werne].[tWMS_Carrier] DROP COLUMN [MultiRottbeck]
ALTER TABLE [CT dwh 01 Stage].[werne].[tWMS_Carrier] DROP COLUMN [NachnahmeRottbeck]
ALTER TABLE [CT dwh 01 Stage].[werne].[tWMS_Carrier] DROP COLUMN [Rottbeck]
ALTER TABLE [CT dwh 01 Stage].[werne].[tWMS_Carrier] DROP COLUMN [SAPRottbeck]
ALTER TABLE [CT dwh 01 Stage].[werne].[tWMS_Carrier] DROP COLUMN [SAPRottbeck]

[werne].[tWMS_Carrier]


SELECT distinct TargetSchema
  FROM [CT dwh 00 Meta].[dbo].[tPentahoLogbaseTableMergeConfig]
  where 
			1=1
			AND TargetDbName = 'CT dwh 01 Stage'
            and IsActive = 1