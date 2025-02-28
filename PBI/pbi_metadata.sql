/****** Script for SelectTopNRows command from SSMS  ******/
SELECT distinct name worspace_name,report_id,report_name--, dataset_id,dataset_name
  FROM [Alerts].[dbo].[pbi_metadata_workspaces]
  where [dataset_configured_by] like 'n.k%'