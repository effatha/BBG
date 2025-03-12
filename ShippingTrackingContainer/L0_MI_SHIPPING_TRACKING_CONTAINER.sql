CREATE TABLE L0.L0_MI_SHIPPING_TRACKING_CONTAINER
(
	[AUFTRAGSNUMMER] VARCHAR(250),
	[IMP_EXP] VARCHAR(250),
	[CTR] VARCHAR(250),
	[TYPE] VARCHAR(250),
	[GROSSWEIGHT] VARCHAR(250),
	[NETTO_WEIGHT] VARCHAR(250),
	[PORT] VARCHAR(250),
	[TERMINAL] VARCHAR(250),
	[DROP_DEPOT] VARCHAR(250),
	[VESSEL] VARCHAR(250),
	[ETA] VARCHAR(250),
	[CUSTOMER] VARCHAR(250),
	[ACCOUNT] VARCHAR(250),
	[BOOKINGNO] VARCHAR(250),
	[TURNOUT_NR] VARCHAR(250),
	[MODALITY] VARCHAR(250),
	[BARGENAME] VARCHAR(250),
	[ABNAHME_SEEHAFEN] VARCHAR(250),
	[MAIN_VOYAGE_LOAD_DATE] VARCHAR(250),
	[MAIN_VOYAGE_LOAD_TIME] VARCHAR(250),
	[ALT_ARRIVAL_DUISBURG] VARCHAR(250),
	[ARRIVAL_DUISBURG] VARCHAR(250),
	[VOYAGE_EXPARRDATE] VARCHAR(250),
	[VOYAGE_EXPARRTIME] VARCHAR(250),
	[ON_TERM] VARCHAR(250),
	[VORAUSSICHTLICH_IN_B_NEN] VARCHAR(250),
	[EINGANGSTAG_B_NEN] VARCHAR(250),
	[ARRIVAL_B_NEN] VARCHAR(250),
	[REMARKS2] VARCHAR(250),
	[STOP_DATE] VARCHAR(250),
	[STOP_TIME] VARCHAR(250),
	[LADEREFERENZ] VARCHAR(250),
	[TRUCKSTOP] VARCHAR(250),
	[LOAD_TIMESTAMP]      datetime2


)
WITH (
    DISTRIBUTION = REPLICATE,
    HEAP
)



--INSERT INTO [MD].[MD_L0_LOAD_LIST]
--           ([TableName]
--           ,[SchemaName]
--           ,[FolderPath]
--           ,[Is_Active]
--           ,[EntityName]
--           ,[KeyColumns]
--           ,[PipelineLastRun])
--     VALUES
--           ('L0_MI_SHIPPING_TRACKING_CONTAINER'
--           ,'L0'
--           ,'https://stbbgdwhweudev01.dfs.core.windows.net/curated/curated/file/excel_upload_v2/purchasing/shippingcontainertrackingarchive_xlsx/bookinglines_2025_02_25t08263'
--           ,1
--           ,'PURCH'
--           ,'LOAD_TIMESTAMP,AUFTRAGSNUMMER,CTR'
--           ,'2025-03-03')

--update [MD].[MD_L0_LOAD_LIST] set [FolderPath] = 'https://stbbgdwhweudev01.dfs.core.windows.net/curated/curated/file/excel_upload_v2/purchasing/shippingcontainertrackingarchive_xlsx/bookinglines_2025_02_25t08263' WHERE TableName = 'L0_MI_SHIPPING_TRACKING_CONTAINER'

GO


