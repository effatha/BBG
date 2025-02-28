/****** Script for SelectTopNRows command from SSMS  ******/
SELECT  [id] as workspace_id
	      ,[name] as workspace_name

      --,[isReadOnly]
      --,[isOnDedicatedCapacity]
      --,[capacityId]
      --,[capacityMigrationStatus]
      --,[defaultDatasetStorageFormat]
      ,[description] as workspace_description
      --,[type]
      --,[state]
      --,[hasWorkspaceLevelSettings]
      --,[users]
      --,[reports]
      --,[dashboards]
      --,[datasets]
      ,[report_id]
      ,[report_name]
      ,[report_dataset_id]
      ,[dataset_id]
      ,[dataset_name]
      ,[dataset_configured_by]
  FROM [Alerts].[dbo].[pbi_metadata_workspaces]