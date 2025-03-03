USE [CT dwh 00 Meta]
GO
IF  EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'Nav Table Id' , N'SCHEMA',N'dbo', N'TABLE',N'tUserAccounts', NULL,NULL))
EXEC sys.sp_dropextendedproperty @name=N'Nav Table Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tUserAccounts'
GO
IF  EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'tUserAccounts', NULL,NULL))
EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tUserAccounts'
GO
IF  EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'Nav Table Id' , N'SCHEMA',N'dbo', N'TABLE',N'tStringCollection', NULL,NULL))
EXEC sys.sp_dropextendedproperty @name=N'Nav Table Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tStringCollection'
GO
IF  EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'tStringCollection', NULL,NULL))
EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tStringCollection'
GO
IF  EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'Nav Table Id' , N'SCHEMA',N'dbo', N'TABLE',N'tProcessingLog', NULL,NULL))
EXEC sys.sp_dropextendedproperty @name=N'Nav Table Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tProcessingLog'
GO
IF  EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'tProcessingLog', NULL,NULL))
EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tProcessingLog'
GO
IF  EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'Nav Table Id' , N'SCHEMA',N'dbo', N'TABLE',N'tExecutionLog', NULL,NULL))
EXEC sys.sp_dropextendedproperty @name=N'Nav Table Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tExecutionLog'
GO
IF  EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'tExecutionLog', NULL,NULL))
EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tExecutionLog'
GO
IF  EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'Description' , N'SCHEMA',N'dbo', N'TABLE',N'SqlServerVersions', NULL,NULL))
EXEC sys.sp_dropextendedproperty @name=N'Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SqlServerVersions'
GO
IF  EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'Description' , N'SCHEMA',N'dbo', N'TABLE',N'SqlServerVersions', N'COLUMN',N'MinorVersionName'))
EXEC sys.sp_dropextendedproperty @name=N'Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SqlServerVersions', @level2type=N'COLUMN',@level2name=N'MinorVersionName'
GO
IF  EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'Description' , N'SCHEMA',N'dbo', N'TABLE',N'SqlServerVersions', N'COLUMN',N'MajorVersionName'))
EXEC sys.sp_dropextendedproperty @name=N'Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SqlServerVersions', @level2type=N'COLUMN',@level2name=N'MajorVersionName'
GO
IF  EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'Description' , N'SCHEMA',N'dbo', N'TABLE',N'SqlServerVersions', N'COLUMN',N'ExtendedSupportEndDate'))
EXEC sys.sp_dropextendedproperty @name=N'Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SqlServerVersions', @level2type=N'COLUMN',@level2name=N'ExtendedSupportEndDate'
GO
IF  EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'Description' , N'SCHEMA',N'dbo', N'TABLE',N'SqlServerVersions', N'COLUMN',N'MainstreamSupportEndDate'))
EXEC sys.sp_dropextendedproperty @name=N'Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SqlServerVersions', @level2type=N'COLUMN',@level2name=N'MainstreamSupportEndDate'
GO
IF  EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'Description' , N'SCHEMA',N'dbo', N'TABLE',N'SqlServerVersions', N'COLUMN',N'ReleaseDate'))
EXEC sys.sp_dropextendedproperty @name=N'Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SqlServerVersions', @level2type=N'COLUMN',@level2name=N'ReleaseDate'
GO
IF  EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'Description' , N'SCHEMA',N'dbo', N'TABLE',N'SqlServerVersions', N'COLUMN',N'Url'))
EXEC sys.sp_dropextendedproperty @name=N'Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SqlServerVersions', @level2type=N'COLUMN',@level2name=N'Url'
GO
IF  EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'Description' , N'SCHEMA',N'dbo', N'TABLE',N'SqlServerVersions', N'COLUMN',N'Branch'))
EXEC sys.sp_dropextendedproperty @name=N'Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SqlServerVersions', @level2type=N'COLUMN',@level2name=N'Branch'
GO
IF  EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'Description' , N'SCHEMA',N'dbo', N'TABLE',N'SqlServerVersions', N'COLUMN',N'MinorVersionNumber'))
EXEC sys.sp_dropextendedproperty @name=N'Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SqlServerVersions', @level2type=N'COLUMN',@level2name=N'MinorVersionNumber'
GO
IF  EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'Description' , N'SCHEMA',N'dbo', N'TABLE',N'SqlServerVersions', N'COLUMN',N'MajorVersionNumber'))
EXEC sys.sp_dropextendedproperty @name=N'Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SqlServerVersions', @level2type=N'COLUMN',@level2name=N'MajorVersionNumber'
GO
IF  EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'Debug', N'COLUMN',N'tDebugInfo'))
EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Debug', @level2type=N'COLUMN',@level2name=N'tDebugInfo'
GO
IF  EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'Debug', N'COLUMN',N'nIsError'))
EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Debug', @level2type=N'COLUMN',@level2name=N'nIsError'
GO
IF  EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'Debug', N'COLUMN',N'dtDateTime'))
EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Debug', @level2type=N'COLUMN',@level2name=N'dtDateTime'
GO
IF  EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'Debug', N'COLUMN',N'tUserName'))
EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Debug', @level2type=N'COLUMN',@level2name=N'tUserName'
GO
IF  EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'Debug', N'COLUMN',N'tLoginName'))
EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Debug', @level2type=N'COLUMN',@level2name=N'tLoginName'
GO
IF  EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'Debug', N'COLUMN',N'nSPID'))
EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Debug', @level2type=N'COLUMN',@level2name=N'nSPID'
GO
IF  EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'dbo', N'TABLE',N'Debug', N'COLUMN',N'aDebugId'))
EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Debug', @level2type=N'COLUMN',@level2name=N'aDebugId'
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[parcellab].[tErrorTracking]') AND type in (N'U'))
ALTER TABLE [parcellab].[tErrorTracking] DROP CONSTRAINT IF EXISTS [DF__tErrorTracking__mdIns__4ECB04FB]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[logbase].[tWarehouseInstanceConfig]') AND type in (N'U'))
ALTER TABLE [logbase].[tWarehouseInstanceConfig] DROP CONSTRAINT IF EXISTS [DF_tWarehouseInstanceConfig_CD]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[logbase].[tWarehouseInstanceConfig]') AND type in (N'U'))
ALTER TABLE [logbase].[tWarehouseInstanceConfig] DROP CONSTRAINT IF EXISTS [DF_tWarehouseInstanceConfig_Active]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[forecast].[tPlanPriceImportJobList]') AND type in (N'U'))
ALTER TABLE [forecast].[tPlanPriceImportJobList] DROP CONSTRAINT IF EXISTS [DF_tPlanPriceImportJobList_ProcessState]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[forecast].[tPlanPriceImportJobList]') AND type in (N'U'))
ALTER TABLE [forecast].[tPlanPriceImportJobList] DROP CONSTRAINT IF EXISTS [DF_tPlanPriceImportJobList_ImportDate]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[forecast].[tImportJobList]') AND type in (N'U'))
ALTER TABLE [forecast].[tImportJobList] DROP CONSTRAINT IF EXISTS [DF_tImportJobList_ProcessState]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[forecast].[tImportJobList]') AND type in (N'U'))
ALTER TABLE [forecast].[tImportJobList] DROP CONSTRAINT IF EXISTS [DF_tImportJobList_ImportDate]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[forecast].[tAdjustmentImportJobList]') AND type in (N'U'))
ALTER TABLE [forecast].[tAdjustmentImportJobList] DROP CONSTRAINT IF EXISTS [DF_tAdjustmentImportJobList_ProcessState]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[forecast].[tAdjustmentImportJobList]') AND type in (N'U'))
ALTER TABLE [forecast].[tAdjustmentImportJobList] DROP CONSTRAINT IF EXISTS [DF_tAdjustmentImportJobList_ImportDate]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tProcessingLog]') AND type in (N'U'))
ALTER TABLE [dbo].[tProcessingLog] DROP CONSTRAINT IF EXISTS [DF__tProcessi__Start__1A14E395]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tProcessingLog]') AND type in (N'U'))
ALTER TABLE [dbo].[tProcessingLog] DROP CONSTRAINT IF EXISTS [DF__tProcessi__LogEn__1920BF5C]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tProcedureLog]') AND type in (N'U'))
ALTER TABLE [dbo].[tProcedureLog] DROP CONSTRAINT IF EXISTS [DF__tProcedur__log_t__5F691F13]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tPentahoTableMergeXtractorConfig]') AND type in (N'U'))
ALTER TABLE [dbo].[tPentahoTableMergeXtractorConfig] DROP CONSTRAINT IF EXISTS [DF__tPentahoT__Activ__61BB7BD9]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tPentahoTableMergeXtractorConfig]') AND type in (N'U'))
ALTER TABLE [dbo].[tPentahoTableMergeXtractorConfig] DROP CONSTRAINT IF EXISTS [DF__tPentahoT__isIni__60C757A0]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tPentahooxidTableMergeConfig]') AND type in (N'U'))
ALTER TABLE [dbo].[tPentahooxidTableMergeConfig] DROP CONSTRAINT IF EXISTS [DF__tPentahoo__IsAct__0B7CAB7B]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tPentahoLogbaseTableMergeConfig]') AND type in (N'U'))
ALTER TABLE [dbo].[tPentahoLogbaseTableMergeConfig] DROP CONSTRAINT IF EXISTS [DF__tPentahoL__Enabl__0D99FE17]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tPentahoGlobalTableMergeConfig]') AND type in (N'U'))
ALTER TABLE [dbo].[tPentahoGlobalTableMergeConfig] DROP CONSTRAINT IF EXISTS [DF__tPentahoG__bIsEn__30242045]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tChannelAndGroupConfigSales_BCKP]') AND type in (N'U'))
ALTER TABLE [dbo].[tChannelAndGroupConfigSales_BCKP] DROP CONSTRAINT IF EXISTS [DF__tChannelA__dtLas__4EA8A765]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tChannelAndGroupConfigSales]') AND type in (N'U'))
ALTER TABLE [dbo].[tChannelAndGroupConfigSales] DROP CONSTRAINT IF EXISTS [DF__tChannelA__dtLas__4F9CCB9E]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tAmazonMwsFbaGenerateReport]') AND type in (N'U'))
ALTER TABLE [dbo].[tAmazonMwsFbaGenerateReport] DROP CONSTRAINT IF EXISTS [DF_tAmazonMwsFbaGenerateReport_FileSaved]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[config].[tIncidentFlag]') AND type in (N'U'))
ALTER TABLE [config].[tIncidentFlag] DROP CONSTRAINT IF EXISTS [DF__tIncident__Creat__2C1E8537]
GO
/****** Object:  Table [sap].[tDocumentTypeBucketConfigPurchasing]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [sap].[tDocumentTypeBucketConfigPurchasing]
GO
/****** Object:  Table [sap].[tDocumentTypeBucketConfig]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [sap].[tDocumentTypeBucketConfig]
GO
/****** Object:  Table [sap].[tCostLineTypeConfigPurchasing]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [sap].[tCostLineTypeConfigPurchasing]
GO
/****** Object:  Table [sap].[t2LIS_03_BF_Mapping_BSTAUS]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [sap].[t2LIS_03_BF_Mapping_BSTAUS]
GO
/****** Object:  Table [parcellab].[tErrorTracking]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [parcellab].[tErrorTracking]
GO
/****** Object:  Table [logbase].[tWarehouseInstanceConfig]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [logbase].[tWarehouseInstanceConfig]
GO
/****** Object:  Table [forecast].[tPlanPriceImportJobList]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [forecast].[tPlanPriceImportJobList]
GO
/****** Object:  Table [forecast].[tImportJobList]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [forecast].[tImportJobList]
GO
/****** Object:  Table [forecast].[tAdjustmentImportJobList]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [forecast].[tAdjustmentImportJobList]
GO
/****** Object:  Table [dbo].[tUserAccounts]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[tUserAccounts]
GO
/****** Object:  Table [dbo].[tTransactionTypesConfigSAPEKBE]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[tTransactionTypesConfigSAPEKBE]
GO
/****** Object:  Table [dbo].[tTransactionTypesConfigSAP]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[tTransactionTypesConfigSAP]
GO
/****** Object:  Table [dbo].[tTransactionTypesConfigSalesOrders]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[tTransactionTypesConfigSalesOrders]
GO
/****** Object:  Table [dbo].[tTransactionTypesConfigPurchasingOrders]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[tTransactionTypesConfigPurchasingOrders]
GO
/****** Object:  Table [dbo].[tTableSizeLog]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[tTableSizeLog]
GO
/****** Object:  Table [dbo].[tStringCollection]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[tStringCollection]
GO
/****** Object:  Table [dbo].[tSAPlastChangeDatetime]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[tSAPlastChangeDatetime]
GO
/****** Object:  Table [dbo].[tSalesSAPMappingChannel]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[tSalesSAPMappingChannel]
GO
/****** Object:  Table [dbo].[tProcessingLog]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[tProcessingLog]
GO
/****** Object:  Table [dbo].[tProcedureLog]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[tProcedureLog]
GO
/****** Object:  Table [dbo].[tPentahoTransformationLog]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[tPentahoTransformationLog]
GO
/****** Object:  Table [dbo].[tPentahoTableMergeXtractorConfig]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[tPentahoTableMergeXtractorConfig]
GO
/****** Object:  Table [dbo].[tPentahoTableMergeConfig]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[tPentahoTableMergeConfig]
GO
/****** Object:  Table [dbo].[tPentahoPlentyMarketsTableMergeConfig]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[tPentahoPlentyMarketsTableMergeConfig]
GO
/****** Object:  Table [dbo].[tPentahooxidTableMergeConfig]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[tPentahooxidTableMergeConfig]
GO
/****** Object:  Table [dbo].[tPentahoOxidShopTableMergeConfig]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[tPentahoOxidShopTableMergeConfig]
GO
/****** Object:  Table [dbo].[tPentahoLogbaseTableMergeConfig]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[tPentahoLogbaseTableMergeConfig]
GO
/****** Object:  Table [dbo].[tPentahoJobLog]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[tPentahoJobLog]
GO
/****** Object:  Table [dbo].[tPentahoGlobalTableMergeConfig]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[tPentahoGlobalTableMergeConfig]
GO
/****** Object:  Table [dbo].[tOwnBrandsConfig]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[tOwnBrandsConfig]
GO
/****** Object:  Table [dbo].[tLogbaseCheckSourcesData]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[tLogbaseCheckSourcesData]
GO
/****** Object:  Table [dbo].[tItemMappingsConfig]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[tItemMappingsConfig]
GO
/****** Object:  Table [dbo].[tIncidentFlagConfig_DocumentDate]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[tIncidentFlagConfig_DocumentDate]
GO
/****** Object:  Table [dbo].[tIncidentFlagConfig]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[tIncidentFlagConfig]
GO
/****** Object:  Table [dbo].[tGlobalConfig]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[tGlobalConfig]
GO
/****** Object:  Table [dbo].[tFailedAgentStepsReported]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[tFailedAgentStepsReported]
GO
/****** Object:  Table [dbo].[tExecutionLog]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[tExecutionLog]
GO
/****** Object:  Table [dbo].[tempCustomerOrder]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[tempCustomerOrder]
GO
/****** Object:  Table [dbo].[tDocumentFlowConfigSAP]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[tDocumentFlowConfigSAP]
GO
/****** Object:  Table [dbo].[tDataLayerCheckDuplicates]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[tDataLayerCheckDuplicates]
GO
/****** Object:  Table [dbo].[tCompanyName]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[tCompanyName]
GO
/****** Object:  Table [dbo].[tChannelAndGroupConfigSales_Copy]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[tChannelAndGroupConfigSales_Copy]
GO
/****** Object:  Table [dbo].[tChannelAndGroupConfigSales_BCKP20211207]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[tChannelAndGroupConfigSales_BCKP20211207]
GO
/****** Object:  Table [dbo].[tChannelAndGroupConfigSales_BCKP]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[tChannelAndGroupConfigSales_BCKP]
GO
/****** Object:  Table [dbo].[tChannelAndGroupConfigSales]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[tChannelAndGroupConfigSales]
GO
/****** Object:  Table [dbo].[tAmazonMwsMarketplaces]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[tAmazonMwsMarketplaces]
GO
/****** Object:  Table [dbo].[tAmazonMwsFbaGenerateReport]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[tAmazonMwsFbaGenerateReport]
GO
/****** Object:  Table [dbo].[tAmazonMwsFbaConfiguration]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[tAmazonMwsFbaConfiguration]
GO
/****** Object:  Table [dbo].[SqlServerVersions]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[SqlServerVersions]
GO
/****** Object:  Table [dbo].[Query]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[Query]
GO
/****** Object:  Table [dbo].[Numbers]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[Numbers]
GO
/****** Object:  Table [dbo].[DWHCheckSources]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[DWHCheckSources]
GO
/****** Object:  Table [dbo].[Debug]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[Debug]
GO
/****** Object:  Table [dbo].[_temp_tSAP_TransactionTypeMapping]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[_temp_tSAP_TransactionTypeMapping]
GO
/****** Object:  Table [dbo].[_temp_missing_positions]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[_temp_missing_positions]
GO
/****** Object:  Table [dbo].[_temp_hb_logbase]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [dbo].[_temp_hb_logbase]
GO
/****** Object:  Table [config].[tIncidentFlag]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [config].[tIncidentFlag]
GO
/****** Object:  Table [c4po].[tWarehouseInstanceConfig]    Script Date: 09/10/2024 12:03:25 ******/
DROP TABLE IF EXISTS [c4po].[tWarehouseInstanceConfig]
GO
/****** Object:  Table [c4po].[tWarehouseInstanceConfig]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [c4po].[tWarehouseInstanceConfig](
	[WarehouseLocation] [nvarchar](40) NOT NULL,
	[Schema] [nvarchar](20) NOT NULL,
	[StorageLocationQuery] [nvarchar](255) NOT NULL,
	[LogbaseserverID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [config].[tIncidentFlag]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [config].[tIncidentFlag](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Source] [nvarchar](50) NULL,
	[IncidentDataType] [nvarchar](50) NULL,
	[CompanyId] [int] NULL,
	[ProcessId] [nvarchar](50) NULL,
	[DocumentId] [nvarchar](50) NULL,
	[DocumentNo] [nvarchar](50) NULL,
	[IncidentDate] [datetime2](7) NULL,
	[IncidentReason] [nvarchar](250) NULL,
	[CreatedBy] [nvarchar](50) NULL,
	[CreatedAt] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[_temp_hb_logbase]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[_temp_hb_logbase](
	[config] [int] IDENTITY(1,1) NOT NULL,
	[Layer] [nvarchar](150) NULL,
	[Schemaname] [nvarchar](20) NULL,
	[Tablename] [nvarchar](250) NULL,
	[LastStartTime] [datetime2](7) NULL,
	[LastEndTime] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[config] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[_temp_missing_positions]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[_temp_missing_positions](
	[belposid] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[_temp_tSAP_TransactionTypeMapping]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[_temp_tSAP_TransactionTypeMapping](
	[TransactionTypeShort] [varchar](10) NULL,
	[TransactionType] [varchar](50) NULL,
	[Type] [nvarchar](10) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Debug]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Debug](
	[aDebugId] [int] IDENTITY(1,1) NOT NULL,
	[nSPID] [smallint] NOT NULL,
	[tLoginName] [varchar](50) NULL,
	[tUserName] [varchar](50) NULL,
	[dtDateTime] [datetime] NOT NULL,
	[nIsError] [smallint] NOT NULL,
	[tDebugInfo] [nvarchar](max) NULL,
 CONSTRAINT [PK_Debug] PRIMARY KEY CLUSTERED 
(
	[aDebugId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DWHCheckSources]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DWHCheckSources](
	[aConfigID] [int] IDENTITY(1,1) NOT NULL,
	[tSourceServer] [nvarchar](50) NULL,
	[tSourceDatabase] [nvarchar](150) NULL,
	[tSourceTable] [nvarchar](150) NULL,
	[tDestinationServer] [nvarchar](150) NULL,
	[tDestinationDatabase] [nvarchar](150) NULL,
	[tDestinationTable] [nvarchar](150) NULL,
	[nRowsSource] [int] NULL,
	[nRowsDestination] [int] NULL,
	[dtLastChecked] [datetime2](7) NULL,
	[bisActive] [bit] NULL,
	[tError] [nvarchar](max) NULL,
	[tPrimaryKeyFields] [nvarchar](max) NULL,
	[tPrimaryKeyFieldsVarchar] [nvarchar](max) NULL,
	[nMissingDestEntries] [int] NULL,
	[nMissingSourceEntries] [int] NULL,
	[bisColumnIsDeletedFlagPresent] [bit] NULL,
	[DeletedFlagColumnName] [nvarchar](150) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Numbers]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Numbers](
	[Number] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Number] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Query]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Query](
	[TargetDbName] [nvarchar](50) NOT NULL,
	[TargetSchema] [nvarchar](50) NOT NULL,
	[TargetTable] [nvarchar](50) NOT NULL,
	[SourceDbName] [nvarchar](50) NOT NULL,
	[SourceServer] [nvarchar](50) NULL,
	[SourceSchema] [nvarchar](50) NOT NULL,
	[SourceTable] [nvarchar](50) NOT NULL,
	[PKField] [nvarchar](10) NOT NULL,
	[TimestampField] [nvarchar](50) NULL,
	[IsActive] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SqlServerVersions]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SqlServerVersions](
	[MajorVersionNumber] [tinyint] NOT NULL,
	[MinorVersionNumber] [smallint] NOT NULL,
	[Branch] [varchar](34) NOT NULL,
	[Url] [varchar](99) NOT NULL,
	[ReleaseDate] [date] NOT NULL,
	[MainstreamSupportEndDate] [date] NOT NULL,
	[ExtendedSupportEndDate] [date] NOT NULL,
	[MajorVersionName] [varchar](19) NOT NULL,
	[MinorVersionName] [varchar](67) NOT NULL,
 CONSTRAINT [PK_SqlServerVersions] PRIMARY KEY CLUSTERED 
(
	[MajorVersionNumber] ASC,
	[MinorVersionNumber] ASC,
	[ReleaseDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tAmazonMwsFbaConfiguration]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tAmazonMwsFbaConfiguration](
	[AccessKey] [nvarchar](100) NOT NULL,
	[MWSAuthToken] [nvarchar](100) NOT NULL,
	[ReportType] [nvarchar](100) NOT NULL,
	[SecretKey] [nvarchar](100) NOT NULL,
	[SellerId] [nvarchar](100) NOT NULL,
	[ServiceUrl] [nvarchar](100) NOT NULL,
	[SignatureMethod] [nvarchar](100) NOT NULL,
	[SignatureVersion] [nvarchar](100) NOT NULL,
	[Version] [nvarchar](100) NOT NULL,
	[RequestFrequency] [nvarchar](10) NOT NULL,
	[AmazonMwsFbaConfigurationId] [int] NOT NULL,
	[Marketplace] [nvarchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tAmazonMwsFbaGenerateReport]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tAmazonMwsFbaGenerateReport](
	[AccessKey] [nvarchar](100) NULL,
	[MWSAuthToken] [nvarchar](100) NULL,
	[ReportType] [nvarchar](100) NULL,
	[SecretKey] [nvarchar](100) NULL,
	[SellerId] [nvarchar](100) NULL,
	[ServiceUrl] [nvarchar](100) NULL,
	[SignatureMethod] [nvarchar](100) NULL,
	[SignatureVersion] [nvarchar](100) NULL,
	[Version] [nvarchar](100) NULL,
	[ReportProcessingStatus] [nvarchar](100) NULL,
	[EndDate] [datetime] NULL,
	[Scheduled] [nvarchar](100) NULL,
	[ReportRequestId] [nvarchar](100) NOT NULL,
	[SubmittedDate] [datetime] NULL,
	[StartDate] [datetime] NULL,
	[CompletedDate] [datetime] NULL,
	[GeneratedReportId] [nvarchar](100) NULL,
	[StartedProcessingDate] [datetime] NULL,
	[FileSaved] [bit] NULL,
	[FileSavedDate] [datetime] NULL,
	[Marketplace] [nvarchar](50) NULL,
	[FilePath] [nvarchar](255) NULL,
 CONSTRAINT [PK_tAmazonMwsFbaGenerateReport] PRIMARY KEY CLUSTERED 
(
	[ReportRequestId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 95, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tAmazonMwsMarketplaces]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tAmazonMwsMarketplaces](
	[AmazonMarketplace] [nvarchar](50) NULL,
	[CountryCode] [nvarchar](10) NULL,
	[AmazonMWSEndpoint] [nvarchar](100) NULL,
	[MarketplaceId] [nvarchar](30) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tChannelAndGroupConfigSales]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tChannelAndGroupConfigSales](
	[Kundengruppe] [varchar](10) NOT NULL,
	[Mandant] [smallint] NOT NULL,
	[Tag] [varchar](255) NULL,
	[Channel] [varchar](255) NULL,
	[ChannelGroupI] [varchar](255) NULL,
	[ChannelGroupII] [varchar](255) NULL,
	[ChannelNameSAP] [varchar](255) NULL,
	[dtLastModified] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[Kundengruppe] ASC,
	[Mandant] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tChannelAndGroupConfigSales_BCKP]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tChannelAndGroupConfigSales_BCKP](
	[Kundengruppe] [varchar](10) NOT NULL,
	[Mandant] [smallint] NOT NULL,
	[Tag] [varchar](255) NULL,
	[Channel] [varchar](255) NULL,
	[ChannelGroupI] [varchar](255) NULL,
	[ChannelGroupII] [varchar](255) NULL,
	[ChannelNameSAP] [varchar](255) NULL,
	[dtLastModified] [datetime2](7) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tChannelAndGroupConfigSales_BCKP20211207]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tChannelAndGroupConfigSales_BCKP20211207](
	[Kundengruppe] [varchar](10) NOT NULL,
	[Mandant] [smallint] NOT NULL,
	[Tag] [varchar](255) NULL,
	[Channel] [varchar](255) NULL,
	[ChannelGroupI] [varchar](255) NULL,
	[ChannelGroupII] [varchar](255) NULL,
	[ChannelNameSAP] [varchar](255) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tChannelAndGroupConfigSales_Copy]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tChannelAndGroupConfigSales_Copy](
	[Kundengruppe] [varchar](10) NOT NULL,
	[Mandant] [smallint] NOT NULL,
	[Tag] [varchar](255) NULL,
	[Channel] [varchar](255) NULL,
	[ChannelGroupI] [varchar](255) NULL,
	[ChannelGroupII] [varchar](255) NULL,
	[ChannelNameSAP] [varchar](255) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tCompanyName]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tCompanyName](
	[CompanyID] [smallint] NOT NULL,
	[CompanyName] [nvarchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tDataLayerCheckDuplicates]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tDataLayerCheckDuplicates](
	[SchemaName] [nvarchar](300) NULL,
	[TableName] [nvarchar](300) NULL,
	[PrimaryKey] [nvarchar](300) NULL,
	[Duplicates] [int] NULL,
	[LastChecked] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tDocumentFlowConfigSAP]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tDocumentFlowConfigSAP](
	[SourceTable] [varchar](10) NULL,
	[SourceType] [varchar](10) NULL,
	[ReferencedTable] [varchar](10) NULL,
	[ReferencedType] [nvarchar](10) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tempCustomerOrder]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tempCustomerOrder](
	[CustomerOrder] [nvarchar](50) NULL,
	[DocumentNo] [nvarchar](50) NULL,
	[DocumentID] [nvarchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tExecutionLog]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tExecutionLog](
	[mdLogId] [int] IDENTITY(1,1) NOT NULL,
	[StartDateTime] [datetime] NULL,
	[EndDateTime] [datetime] NULL,
	[Duration]  AS (datediff(minute,[StartDateTime],[EndDateTime])),
	[JobName] [varchar](255) NULL,
 CONSTRAINT [pkExecutionLog] PRIMARY KEY CLUSTERED 
(
	[mdLogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tFailedAgentStepsReported]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tFailedAgentStepsReported](
	[InstanceId] [int] NOT NULL,
	[JobId] [varchar](255) NOT NULL,
	[StepId] [int] NOT NULL,
	[ErrorEventTime] [datetime] NOT NULL,
 CONSTRAINT [pkFailedAgentStepsReported] PRIMARY KEY CLUSTERED 
(
	[InstanceId] ASC,
	[JobId] ASC,
	[StepId] ASC,
	[ErrorEventTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tGlobalConfig]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tGlobalConfig](
	[aConfigId] [int] IDENTITY(1,1) NOT NULL,
	[tConfigName] [nvarchar](150) NOT NULL,
	[tConfigValue] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[aConfigId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tIncidentFlagConfig]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tIncidentFlagConfig](
	[ProcessID] [int] NOT NULL,
	[dtCreated] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[ProcessID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tIncidentFlagConfig_DocumentDate]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tIncidentFlagConfig_DocumentDate](
	[DocumentID] [int] NOT NULL,
	[TransactionDate] [date] NOT NULL,
	[mdInsertDate] [datetime2](7) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tItemMappingsConfig]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tItemMappingsConfig](
	[MappingId] [int] NOT NULL,
	[ConditionType] [nvarchar](100) NULL,
	[SAGE_ArticlePrefix] [nvarchar](20) NULL,
	[SAGE_ArticlePrefixLength] [int] NULL,
	[SAP_ArticlePrefix] [nvarchar](20) NULL,
	[SAP_SgtScatField] [nvarchar](10) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tLogbaseCheckSourcesData]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tLogbaseCheckSourcesData](
	[Schema] [varchar](16) NULL,
	[Table] [varchar](100) NULL,
	[CountDeleted] [varchar](100) NULL,
	[CountNew] [varchar](100) NULL,
	[CountIdentical] [varchar](100) NULL,
	[CountChanged] [varchar](100) NULL,
	[CountInvalidTimestamp] [varchar](100) NULL,
	[Duplicate] [bit] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tOwnBrandsConfig]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tOwnBrandsConfig](
	[OwnBrand] [varchar](200) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[OwnBrand] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tPentahoGlobalTableMergeConfig]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tPentahoGlobalTableMergeConfig](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TargetDbName] [nvarchar](50) NOT NULL,
	[TargetSchema] [nvarchar](50) NOT NULL,
	[TargetTable] [nvarchar](50) NOT NULL,
	[SourceDbName] [nvarchar](50) NOT NULL,
	[SourceServer] [nvarchar](50) NULL,
	[SourceSchema] [nvarchar](50) NOT NULL,
	[SourceTable] [nvarchar](50) NOT NULL,
	[PKField] [nvarchar](50) NOT NULL,
	[TimestampField] [nvarchar](50) NULL,
	[bIsEnabled] [bit] NULL,
	[SourceConnection] [nvarchar](150) NULL,
	[UseIncrementalLoad] [bit] NULL,
	[ReferenceSchema] [nvarchar](50) NULL,
	[ReferenceTable] [nvarchar](50) NULL,
	[Category] [nvarchar](50) NULL,
	[CheckDeletedEntries] [bit] NULL,
 CONSTRAINT [PK_tPentahoGlobalMarketsTableMergeConfig] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tPentahoJobLog]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tPentahoJobLog](
	[ID_JOB] [int] NULL,
	[CHANNEL_ID] [varchar](255) NULL,
	[JOBNAME] [varchar](255) NULL,
	[STATUS] [varchar](15) NULL,
	[ERRORS] [bigint] NULL,
	[STARTDATE] [datetime] NULL,
	[ENDDATE] [datetime] NULL,
	[LOGDATE] [datetime] NULL,
	[DEPDATE] [datetime] NULL,
	[REPLAYDATE] [datetime] NULL,
	[LOG_FIELD] [text] NULL,
	[EXECUTING_SERVER] [varchar](255) NULL,
	[EXECUTING_USER] [varchar](255) NULL,
	[START_JOB_ENTRY] [varchar](255) NULL,
	[CLIENT] [varchar](255) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tPentahoLogbaseTableMergeConfig]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tPentahoLogbaseTableMergeConfig](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TargetDbName] [nvarchar](50) NOT NULL,
	[TargetSchema] [nvarchar](50) NOT NULL,
	[TargetTable] [nvarchar](50) NOT NULL,
	[SourceDbName] [nvarchar](50) NOT NULL,
	[SourceServer] [nvarchar](50) NULL,
	[SourceSchema] [nvarchar](50) NOT NULL,
	[SourceTable] [nvarchar](50) NOT NULL,
	[PKField] [nvarchar](10) NOT NULL,
	[TimestampField] [nvarchar](50) NULL,
	[TargetConnection] [nvarchar](50) NULL,
	[SourceConnection] [nvarchar](50) NULL,
	[IsActive] [int] NULL,
	[MarkedDeletedThreshold] [int] NULL,
	[EnableMarkDeleted] [tinyint] NOT NULL,
 CONSTRAINT [PK_tPentahoLogbaseTableMergeConfig] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tPentahoOxidShopTableMergeConfig]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tPentahoOxidShopTableMergeConfig](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TargetDbName] [nvarchar](50) NOT NULL,
	[TargetSchema] [nvarchar](50) NOT NULL,
	[TargetTable] [nvarchar](50) NOT NULL,
	[SourceDbName] [nvarchar](50) NOT NULL,
	[SourceServer] [nvarchar](50) NULL,
	[SourceSchema] [nvarchar](50) NOT NULL,
	[SourceTable] [nvarchar](50) NOT NULL,
	[PKField] [nvarchar](255) NOT NULL,
	[TimestampField] [nvarchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tPentahooxidTableMergeConfig]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tPentahooxidTableMergeConfig](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TargetDbName] [nvarchar](50) NOT NULL,
	[TargetSchema] [nvarchar](50) NOT NULL,
	[TargetTable] [nvarchar](50) NOT NULL,
	[SourceDbName] [nvarchar](50) NULL,
	[SourceSchema] [nvarchar](50) NULL,
	[SourceTable] [nvarchar](50) NOT NULL,
	[PKField] [nvarchar](10) NOT NULL,
	[TimestampField] [nvarchar](50) NULL,
	[TargetConnection] [nvarchar](50) NOT NULL,
	[SourceConnection] [nvarchar](50) NOT NULL,
	[IsActive] [int] NOT NULL,
 CONSTRAINT [PK_tPentahooxidTableMergeConfig] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tPentahoPlentyMarketsTableMergeConfig]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tPentahoPlentyMarketsTableMergeConfig](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TargetDbName] [nvarchar](50) NOT NULL,
	[TargetSchema] [nvarchar](50) NOT NULL,
	[TargetTable] [nvarchar](50) NOT NULL,
	[SourceDbName] [nvarchar](50) NOT NULL,
	[SourceServer] [nvarchar](50) NULL,
	[SourceSchema] [nvarchar](50) NOT NULL,
	[SourceTable] [nvarchar](50) NOT NULL,
	[PKField] [nvarchar](150) NOT NULL,
	[TimestampField] [nvarchar](50) NULL,
 CONSTRAINT [PK_tPentahoPlentyMarketsTableMergeConfig] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tPentahoTableMergeConfig]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tPentahoTableMergeConfig](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TargetDbName] [nvarchar](50) NOT NULL,
	[TargetServer] [nvarchar](50) NOT NULL,
	[TargetSchema] [nvarchar](50) NOT NULL,
	[TargetTable] [nvarchar](50) NOT NULL,
	[SourceDbName] [nvarchar](50) NOT NULL,
	[SourceServer] [nvarchar](50) NOT NULL,
	[SourceSchema] [nvarchar](50) NOT NULL,
	[SourceTable] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_tPentahoTableMergeConfig] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tPentahoTableMergeXtractorConfig]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tPentahoTableMergeXtractorConfig](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TargetDbName] [nvarchar](50) NOT NULL,
	[TargetServer] [nvarchar](50) NOT NULL,
	[TargetSchema] [nvarchar](50) NOT NULL,
	[TargetTable] [nvarchar](50) NOT NULL,
	[SourceDbName] [nvarchar](50) NOT NULL,
	[SourceServer] [nvarchar](50) NOT NULL,
	[SourceSchema] [nvarchar](50) NOT NULL,
	[SourceTable] [nvarchar](50) NOT NULL,
	[PrimaryKey] [nvarchar](500) NOT NULL,
	[Type] [nvarchar](20) NULL,
	[DeltaType] [nvarchar](10) NOT NULL,
	[SuperKey] [nvarchar](500) NULL,
	[isInitialLoad] [bit] NOT NULL,
	[TargetConnection] [nvarchar](50) NOT NULL,
	[SourceConnection] [nvarchar](50) NOT NULL,
	[MetaConnection] [nvarchar](50) NULL,
	[Active] [bit] NOT NULL,
	[Incremental] [bit] NULL,
 CONSTRAINT [PK_tPentahoTableMergeXtractorConfig] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UC_Target] UNIQUE NONCLUSTERED 
(
	[TargetServer] ASC,
	[TargetDbName] ASC,
	[TargetSchema] ASC,
	[TargetTable] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tPentahoTransformationLog]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tPentahoTransformationLog](
	[ID_BATCH] [int] NULL,
	[CHANNEL_ID] [varchar](255) NULL,
	[TRANSNAME] [varchar](255) NULL,
	[STATUS] [varchar](15) NULL,
	[ERRORS] [bigint] NULL,
	[STARTDATE] [datetime] NULL,
	[ENDDATE] [datetime] NULL,
	[LOGDATE] [datetime] NULL,
	[DEPDATE] [datetime] NULL,
	[REPLAYDATE] [datetime] NULL,
	[LOG_FIELD] [text] NULL,
	[LINES_READ] [bigint] NULL,
	[LINES_WRITTEN] [bigint] NULL,
	[LINES_UPDATED] [bigint] NULL,
	[LINES_INPUT] [bigint] NULL,
	[LINES_OUTPUT] [bigint] NULL,
	[LINES_REJECTED] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tProcedureLog]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tProcedureLog](
	[id_log] [int] IDENTITY(1,1) NOT NULL,
	[start_time] [datetime] NULL,
	[log_time] [datetime] NOT NULL,
	[database_id] [int] NULL,
	[object_id] [int] NULL,
	[procedure_name] [nvarchar](400) NOT NULL,
	[error_line] [int] NULL,
	[error_message] [nvarchar](max) NULL,
	[total_rows_affected] [int] NULL,
	[log_message] [nvarchar](max) NULL,
PRIMARY KEY NONCLUSTERED 
(
	[id_log] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tProcessingLog]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tProcessingLog](
	[EntryId] [int] IDENTITY(1,1) NOT NULL,
	[LogEntryType] [int] NULL,
	[PackageName] [varchar](100) NULL,
	[TaskName] [varchar](100) NULL,
	[StartDateTime] [datetime] NULL,
	[EndDateTime] [datetime] NULL,
	[RowsProcessed] [int] NULL,
	[DurationSeconds] [int] NULL,
	[Duration]  AS ([dbo].[ConvertSecondsToHours]([DurationSeconds])),
	[mdLogId] [int] NULL,
 CONSTRAINT [pkProcessingLog] PRIMARY KEY CLUSTERED 
(
	[EntryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tSalesSAPMappingChannel]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tSalesSAPMappingChannel](
	[SalesSAPMappingChannelId] [int] IDENTITY(1,1) NOT NULL,
	[ChannelID] [nvarchar](25) NULL,
	[ChannelGroupI] [nvarchar](25) NULL,
	[ChannelGroupII] [nvarchar](25) NULL,
 CONSTRAINT [PK_tSalesSAPMappingChannel] PRIMARY KEY CLUSTERED 
(
	[SalesSAPMappingChannelId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tSAPlastChangeDatetime]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tSAPlastChangeDatetime](
	[tSAPTableName] [nvarchar](100) NOT NULL,
	[MANDT] [nvarchar](3) NOT NULL,
	[LASTCHANGEDATETIME] [numeric](21, 7) NOT NULL,
 CONSTRAINT [PK_tSAPlastChangeDatetime_1] PRIMARY KEY CLUSTERED 
(
	[tSAPTableName] ASC,
	[MANDT] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tStringCollection]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tStringCollection](
	[StringCollectionId] [int] IDENTITY(1,1) NOT NULL,
	[CompanyId] [int] NOT NULL,
	[StringCollectionCode] [varchar](10) NULL,
	[LanguageCode] [char](3) NULL,
	[StringCollectionName] [varchar](30) NULL,
	[SurrogateKeyId] [int] NULL,
 CONSTRAINT [pkStringCollection] PRIMARY KEY CLUSTERED 
(
	[StringCollectionId] ASC,
	[CompanyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tTableSizeLog]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tTableSizeLog](
	[log_time] [datetime] NOT NULL,
	[dbname] [sysname] NOT NULL,
	[schemaname] [sysname] NOT NULL,
	[tablename] [sysname] NOT NULL,
	[row_count] [bigint] NULL,
	[reserved_kb] [bigint] NULL,
	[data_kb] [bigint] NULL,
	[index_size_kb] [bigint] NULL,
	[unused_kb] [bigint] NULL,
PRIMARY KEY CLUSTERED 
(
	[dbname] ASC,
	[schemaname] ASC,
	[tablename] ASC,
	[log_time] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 95, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tTransactionTypesConfigPurchasingOrders]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tTransactionTypesConfigPurchasingOrders](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TransactionTypeShort] [nvarchar](10) NOT NULL,
	[TransactionType] [nvarchar](50) NOT NULL,
	[TransactionTypeDetail] [nvarchar](100) NOT NULL,
	[TransactionTypeDefinition] [nvarchar](255) NULL,
	[Comment] [nvarchar](max) NULL,
 CONSTRAINT [PK_tTransactionTypesConfigPurchasingOrders] PRIMARY KEY CLUSTERED 
(
	[TransactionTypeShort] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tTransactionTypesConfigSalesOrders]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tTransactionTypesConfigSalesOrders](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TransactionTypeShort] [nvarchar](10) NOT NULL,
	[TransactionType] [nvarchar](50) NOT NULL,
	[TransactionTypeDetail] [nvarchar](100) NOT NULL,
	[TransactionTypeDefinition] [nvarchar](255) NULL,
	[Comment] [nvarchar](max) NULL,
 CONSTRAINT [PK_tTransactionTypesConfigSalesOrders] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tTransactionTypesConfigSAP]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tTransactionTypesConfigSAP](
	[BSART] [nvarchar](4) NOT NULL,
	[BSTYP] [nvarchar](1) NOT NULL,
	[TransactionType] [nvarchar](50) NULL,
	[TransactionTypeDetail] [nvarchar](100) NULL,
	[Comment] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tTransactionTypesConfigSAPEKBE]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tTransactionTypesConfigSAPEKBE](
	[VGABE] [nvarchar](1) NOT NULL,
	[BWART] [nvarchar](3) NULL,
	[SHKZG] [nvarchar](1) NULL,
	[TransactionType] [nvarchar](50) NULL,
	[TransactionTypeDetail] [nvarchar](100) NULL,
	[Comment] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tUserAccounts]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tUserAccounts](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[AccountType] [varchar](255) NOT NULL,
	[UserName] [varchar](255) NOT NULL,
	[PasswordEncrypted] [varbinary](max) NULL,
	[AccountDescription] [varchar](255) NULL,
 CONSTRAINT [pkUserAccounts] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [forecast].[tAdjustmentImportJobList]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [forecast].[tAdjustmentImportJobList](
	[ImportJobListId] [bigint] IDENTITY(1,1) NOT NULL,
	[ImportDate] [datetime2](7) NOT NULL,
	[ImportUser] [nvarchar](50) NOT NULL,
	[ImportFileName] [nvarchar](255) NULL,
	[ImportFileLastModification] [datetime2](7) NULL,
	[Reason] [nvarchar](255) NULL,
	[ProcessState] [int] NOT NULL,
	[ReasonForRejection] [nvarchar](max) NULL,
 CONSTRAINT [PK_tAdjustmentImportJobList] PRIMARY KEY CLUSTERED 
(
	[ImportJobListId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [forecast].[tImportJobList]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [forecast].[tImportJobList](
	[ImportJobListId] [bigint] IDENTITY(1,1) NOT NULL,
	[ImportDate] [datetime2](7) NOT NULL,
	[ImportUser] [nvarchar](50) NOT NULL,
	[ImportFileName] [nvarchar](255) NULL,
	[ImportFileLastModification] [datetime2](7) NULL,
	[Reason] [nvarchar](255) NULL,
	[ProcessState] [int] NOT NULL,
	[ReasonForRejection] [nvarchar](max) NULL,
 CONSTRAINT [PK_tImportJobList] PRIMARY KEY CLUSTERED 
(
	[ImportJobListId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [forecast].[tPlanPriceImportJobList]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [forecast].[tPlanPriceImportJobList](
	[ImportJobListId] [bigint] IDENTITY(1,1) NOT NULL,
	[ImportDate] [datetime2](7) NOT NULL,
	[ImportUser] [nvarchar](50) NOT NULL,
	[ImportFileName] [nvarchar](255) NULL,
	[ImportFileLastModification] [datetime2](7) NULL,
	[Reason] [nvarchar](255) NULL,
	[ProcessState] [int] NOT NULL,
	[ReasonForRejection] [nvarchar](max) NULL,
 CONSTRAINT [PK_tPlanPriceImportJobList] PRIMARY KEY CLUSTERED 
(
	[ImportJobListId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [logbase].[tWarehouseInstanceConfig]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [logbase].[tWarehouseInstanceConfig](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[WarehouseLocation] [nvarchar](40) NOT NULL,
	[Schema] [nvarchar](20) NOT NULL,
	[LogBaseServerKey] [int] NOT NULL,
	[Active] [bit] NOT NULL,
	[CD] [datetime] NOT NULL,
	[LeadInfoInstanceRank] [smallint] NULL,
 CONSTRAINT [PK_tWarehouseInstanceConfig] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [parcellab].[tErrorTracking]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [parcellab].[tErrorTracking](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[JobID] [int] NOT NULL,
	[Error_Code] [varchar](20) NULL,
	[mdInsertDate] [datetime2](7) NULL,
 CONSTRAINT [PK__tErrorTracking__3214EC27A932A375] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [sap].[t2LIS_03_BF_Mapping_BSTAUS]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [sap].[t2LIS_03_BF_Mapping_BSTAUS](
	[BSTAUS] [nvarchar](1) NOT NULL,
	[StockType] [nvarchar](200) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [sap].[tCostLineTypeConfigPurchasing]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [sap].[tCostLineTypeConfigPurchasing](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DocumentType] [nvarchar](50) NULL,
	[CostLineType] [nvarchar](200) NULL,
	[ExtractorName] [nvarchar](50) NULL,
	[ExtractorField] [nvarchar](50) NULL,
	[ExtractorFieldValue] [nvarchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [sap].[tDocumentTypeBucketConfig]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [sap].[tDocumentTypeBucketConfig](
	[DocumentTypeBucketConfigId] [int] IDENTITY(1,1) NOT NULL,
	[Table_Description] [nvarchar](22) NULL,
	[DocumentType] [nvarchar](10) NULL,
	[TransactionTypeDetail] [nvarchar](40) NULL,
	[TransactionTypeShort_Typ] [nvarchar](4) NULL,
	[Bucket] [nvarchar](50) NULL,
	[DocumentCategory_Description] [nvarchar](40) NULL,
	[DocumentType_Column] [nvarchar](5) NULL,
 CONSTRAINT [PK_tDocumentTypeBucketConfig] PRIMARY KEY CLUSTERED 
(
	[DocumentTypeBucketConfigId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [sap].[tDocumentTypeBucketConfigPurchasing]    Script Date: 09/10/2024 12:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [sap].[tDocumentTypeBucketConfigPurchasing](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TransactionTypeShort] [nvarchar](20) NULL,
	[TransactionType] [nvarchar](50) NULL,
	[ExtractorName] [nvarchar](30) NULL,
	[ExtractorField] [nvarchar](30) NULL,
 CONSTRAINT [PK_POConfig] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [config].[tIncidentFlag] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[tAmazonMwsFbaGenerateReport] ADD  CONSTRAINT [DF_tAmazonMwsFbaGenerateReport_FileSaved]  DEFAULT ((0)) FOR [FileSaved]
GO
ALTER TABLE [dbo].[tChannelAndGroupConfigSales] ADD  DEFAULT (getdate()) FOR [dtLastModified]
GO
ALTER TABLE [dbo].[tChannelAndGroupConfigSales_BCKP] ADD  DEFAULT (getdate()) FOR [dtLastModified]
GO
ALTER TABLE [dbo].[tPentahoGlobalTableMergeConfig] ADD  CONSTRAINT [DF__tPentahoG__bIsEn__30242045]  DEFAULT ((1)) FOR [bIsEnabled]
GO
ALTER TABLE [dbo].[tPentahoLogbaseTableMergeConfig] ADD  DEFAULT ((1)) FOR [EnableMarkDeleted]
GO
ALTER TABLE [dbo].[tPentahooxidTableMergeConfig] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[tPentahoTableMergeXtractorConfig] ADD  DEFAULT ((0)) FOR [isInitialLoad]
GO
ALTER TABLE [dbo].[tPentahoTableMergeXtractorConfig] ADD  DEFAULT ((1)) FOR [Active]
GO
ALTER TABLE [dbo].[tProcedureLog] ADD  DEFAULT (getdate()) FOR [log_time]
GO
ALTER TABLE [dbo].[tProcessingLog] ADD  DEFAULT ((0)) FOR [LogEntryType]
GO
ALTER TABLE [dbo].[tProcessingLog] ADD  DEFAULT (getdate()) FOR [StartDateTime]
GO
ALTER TABLE [forecast].[tAdjustmentImportJobList] ADD  CONSTRAINT [DF_tAdjustmentImportJobList_ImportDate]  DEFAULT (getdate()) FOR [ImportDate]
GO
ALTER TABLE [forecast].[tAdjustmentImportJobList] ADD  CONSTRAINT [DF_tAdjustmentImportJobList_ProcessState]  DEFAULT ((0)) FOR [ProcessState]
GO
ALTER TABLE [forecast].[tImportJobList] ADD  CONSTRAINT [DF_tImportJobList_ImportDate]  DEFAULT (getdate()) FOR [ImportDate]
GO
ALTER TABLE [forecast].[tImportJobList] ADD  CONSTRAINT [DF_tImportJobList_ProcessState]  DEFAULT ((0)) FOR [ProcessState]
GO
ALTER TABLE [forecast].[tPlanPriceImportJobList] ADD  CONSTRAINT [DF_tPlanPriceImportJobList_ImportDate]  DEFAULT (getdate()) FOR [ImportDate]
GO
ALTER TABLE [forecast].[tPlanPriceImportJobList] ADD  CONSTRAINT [DF_tPlanPriceImportJobList_ProcessState]  DEFAULT ((0)) FOR [ProcessState]
GO
ALTER TABLE [logbase].[tWarehouseInstanceConfig] ADD  CONSTRAINT [DF_tWarehouseInstanceConfig_Active]  DEFAULT ((1)) FOR [Active]
GO
ALTER TABLE [logbase].[tWarehouseInstanceConfig] ADD  CONSTRAINT [DF_tWarehouseInstanceConfig_CD]  DEFAULT (getdate()) FOR [CD]
GO
ALTER TABLE [parcellab].[tErrorTracking] ADD  CONSTRAINT [DF__tErrorTracking__mdIns__4ECB04FB]  DEFAULT (getdate()) FOR [mdInsertDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'PK' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Debug', @level2type=N'COLUMN',@level2name=N'aDebugId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Process ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Debug', @level2type=N'COLUMN',@level2name=N'nSPID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'current system user name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Debug', @level2type=N'COLUMN',@level2name=N'tLoginName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'database user name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Debug', @level2type=N'COLUMN',@level2name=N'tUserName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date and time of the event' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Debug', @level2type=N'COLUMN',@level2name=N'dtDateTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'indicates if the event is result of an error operation' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Debug', @level2type=N'COLUMN',@level2name=N'nIsError'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Custom messages on the event' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Debug', @level2type=N'COLUMN',@level2name=N'tDebugInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'The major version number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SqlServerVersions', @level2type=N'COLUMN',@level2name=N'MajorVersionNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'The minor version number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SqlServerVersions', @level2type=N'COLUMN',@level2name=N'MinorVersionNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'The update level of the build. CU indicates a cumulative update. SP indicates a service pack. RTM indicates Release To Manufacturer. GDR indicates a General Distribution Release. QFE indicates Quick Fix Engineering (aka hotfix).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SqlServerVersions', @level2type=N'COLUMN',@level2name=N'Branch'
GO
EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'A link to the KB article for a version.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SqlServerVersions', @level2type=N'COLUMN',@level2name=N'Url'
GO
EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'The date the version was publicly released.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SqlServerVersions', @level2type=N'COLUMN',@level2name=N'ReleaseDate'
GO
EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'The date main stream Microsoft support ends for the version.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SqlServerVersions', @level2type=N'COLUMN',@level2name=N'MainstreamSupportEndDate'
GO
EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'The date extended Microsoft support ends for the version.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SqlServerVersions', @level2type=N'COLUMN',@level2name=N'ExtendedSupportEndDate'
GO
EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'The major version name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SqlServerVersions', @level2type=N'COLUMN',@level2name=N'MajorVersionName'
GO
EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'The minor version name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SqlServerVersions', @level2type=N'COLUMN',@level2name=N'MinorVersionName'
GO
EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'A reference for SQL Server major and minor versions.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SqlServerVersions'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Log for full Execution of the Dwh-Update Process' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tExecutionLog'
GO
EXEC sys.sp_addextendedproperty @name=N'Nav Table Id', @value=N'100024' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tExecutionLog'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Logging from SSIS-Package EventHandler OnPostExecute' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tProcessingLog'
GO
EXEC sys.sp_addextendedproperty @name=N'Nav Table Id', @value=N'100032' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tProcessingLog'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Multilingual Strings' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tStringCollection'
GO
EXEC sys.sp_addextendedproperty @name=N'Nav Table Id', @value=N'100036' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tStringCollection'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table to store login information for external data sources' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tUserAccounts'
GO
EXEC sys.sp_addextendedproperty @name=N'Nav Table Id', @value=N'100040' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tUserAccounts'
GO
