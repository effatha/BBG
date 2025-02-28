IF NOT EXISTS (SELECT * FROM sys.external_file_formats WHERE name = 'SynapseDeltaFormat') 
	CREATE EXTERNAL FILE FORMAT [SynapseDeltaFormat] 
	WITH ( FORMAT_TYPE = DELTA)
GO

IF NOT EXISTS (SELECT * FROM sys.external_data_sources WHERE name = 'presentation-layer') 
	CREATE EXTERNAL DATA SOURCE [presentation-layer] 
	WITH (
		LOCATION = 'abfss://presentation-layer@stbbgdwhweuprd01.dfs.core.windows.net' 
	)
GO

CREATE EXTERNAL TABLE PL.PL_V_ITEM (
	[ItemId] int,
	[ItemNo] int,
	[Source] nvarchar(4000),
	[ItemType] nvarchar(4000),
	[ItemClass] nvarchar(4000),
	[IndustrySector] nvarchar(4000),
	[ItemGroup] nvarchar(4000),
	[Unit] nvarchar(4000),
	[GrossWeight] numeric(19,6),
	[NetWeight] numeric(19,6),
	[UnitWeight] nvarchar(4000),
	[Volume] numeric(19,6),
	[UnitVolume] nvarchar(4000),
	[TransportationGroup] nvarchar(4000),
	[Division] nvarchar(4000),
	[EAN] nvarchar(4000),
	[EANCategory] nvarchar(4000),
	[Length] numeric(19,6),
	[Width] numeric(19,6),
	[Height] numeric(19,6),
	[UnitDimension] nvarchar(4000),
	[BatchManagement] nvarchar(4000),
	[XPlantMatlStatus] nvarchar(4000),
	[ItemStatus] nvarchar(4000),
	[QualFFreeGoodsDis] nvarchar(4000),
	[GenItemCatGrp] nvarchar(4000),
	[SegmentationStructure] nvarchar(4000),
	[SegmentationStrategy] nvarchar(4000),
	[SegmentationStatus] nvarchar(4000),
	[ProductHierarchyCode] nvarchar(4000),
	[ProductHierarchy4] nvarchar(4000),
	[ProductHierarchy3] nvarchar(4000),
	[ProductHierarchy2] nvarchar(4000),
	[ProductHierarchy1] nvarchar(4000),
	[MABrandSage] nvarchar(4000),
	[MAEarnUpRelevantSage] nvarchar(4000),
	[EOLSage] nvarchar(4000),
	[CatManSage] nvarchar(4000),
	[PurchaserSage] nvarchar(4000),
	[PMSage] nvarchar(4000),
	[SupplierSage] nvarchar(4000),
	[SizeBracket] nvarchar(4000),
	[FBASizeBracket] nvarchar(4000),
	[FBASizeType] nvarchar(4000),
	[FBASizeDetailed] nvarchar(4000),
	[Brand] nvarchar(4000),
	[ItemDescription] nvarchar(4000),
	[ItemLaunchDate] datetime2(7),
	[ItemStatusMI] nvarchar(4000),
	[ReasonItemChange] nvarchar(4000),
	[ListingStatus] nvarchar(4000),
	[ItemCluster] nvarchar(4000),
	[Liquidation] nvarchar(4000),
	[NewLaunchCluster] nvarchar(4000),
	[NewLaunchDate] datetime2(7),
	[SalesTeam] nvarchar(4000)
	)
	WITH (
	LOCATION = 'presentation-layer/PL_V_ITEM/',
	DATA_SOURCE = [presentation-layer],
	FILE_FORMAT = [SynapseDeltaFormat]
	)
GO

DROP EXTERNAL TABLE dbo.PL_V_ITEM


SELECT TOP 100 * FROM PL.PL_V_ITEM
GO