
--select * from Wilson_Backup.dbo.[ReturnOrder] where returndeliveryid =5001114535 OrderItemId in(10150914,10150498)
--
--select * from Wilson_Backup.dbo.OrderItem where  OrderId in(9129726,9127563);
--select * from Wilson_Backup.dbo.[Order] where orderid = '0407021154'--id = 9127563
--select * from Wilson.dbo.[Order] where orderid = '0407021154'--id = 9127563
--select * from Wilson.dbo.OrderItem where OrderId in(9129726);

--select * from Wilson.dbo.[ReturnOrder] where OrderItemId in(10150914,10150498)


-- affected tables:
--[Wilson].[dbo].[ReturnOrderComment]
--[Wilson].[dbo].[MaskReceiveReturn]
--[Wilson].[dbo].[ReturnInspection]
-- [Material]
--[OnOffTest]
/*********************************
** Get the affected records - RETURN ORDER 
**********************************/
DROP TABLE IF EXISTS #TempReturnOrder
CREATE TABLE #TempReturnOrder(
	[Id] [int] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[CreatedOn] [datetime2](7) NOT NULL,
	[ModifiedOn] [datetime2](7) NULL,
	[CreatedBy] [nvarchar](200) NULL,
	[ModifiedBy] [nvarchar](200) NULL,
	[ReturnAddressId] [bigint] NULL,
	[OrderItemId] [bigint] NOT NULL,
	[ArticleNumber] [nvarchar](max) NULL,
	[ReturnUserDescription] [nvarchar](max) NULL,
	[ReturnEmailAddress] [nvarchar](max) NULL,
	[ReturnMobilePhoneNumber] [nvarchar](max) NULL,
	[GeneratedTrackingNumber] [nvarchar](max) NULL,
	[ReturnTrackingNumber] [nvarchar](max) NULL,
	[Carrier] [nvarchar](max) NULL,
	[ReturnStatusId] [bigint] NULL,
	[ReturnRequestConfigId] [bigint] NOT NULL,
	[ReturnWarehouseId] [bigint] NULL,
	[ReturnOrderId] [varchar](100) NULL,
	[ReturnDeliveryId] [varchar](100) NULL,
	[ReturnShipmentNeeded] [bit] NULL,
	[ReturnLabelIdentifer] [nvarchar](max) NULL,
	[ReturnLabelFilename] [nvarchar](max) NULL,
	[DeliveryExecutionFinishDate] [datetime2](7) NULL,
	[ParentId] [bigint] NULL,
	[EsbMessageId] [nvarchar](max) NULL,
	[ReturnCompensationId] [bigint] NOT NULL,
	[ReturnOrderConsqDamage] [bit] NOT NULL,
	[ReturnOrderCoolingOff] [bit] NOT NULL,
	[ReturnRegistrationOptionId] [bigint] NOT NULL,
	[PickupWishDate] [datetime2](7) NULL,
	[IsFSR] [bit] NULL,
	[FSRDate] [datetime2](7) NULL,
	[ItemReceivedDate] [datetime2](7) NULL,
    OrderReference nvarchar(150) null,
    OrderPosition nvarchar(150) null,
    NewOrderItemId int null
)


INSERT INTO #TempReturnOrder (
    Id,
    IsDeleted,
    CreatedOn,
    ModifiedOn,
    CreatedBy,
    ModifiedBy,
    ReturnAddressId,
    OrderItemId,
    ArticleNumber,
    ReturnUserDescription,
    ReturnEmailAddress,
    ReturnMobilePhoneNumber,
    GeneratedTrackingNumber,
    ReturnTrackingNumber,
    Carrier,
    ReturnStatusId,
    ReturnRequestConfigId,
    ReturnWarehouseId,
    ReturnOrderId,
    ReturnDeliveryId,
    ReturnShipmentNeeded,
    ReturnLabelIdentifer,
    ReturnLabelFilename,
    DeliveryExecutionFinishDate,
    ParentId,
    EsbMessageId,
    ReturnCompensationId,
    ReturnOrderConsqDamage,
    ReturnOrderCoolingOff,
    ReturnRegistrationOptionId,
    PickupWishDate,
    IsFSR,
    FSRDate,
    ItemReceivedDate,
    OrderReference,
    OrderPosition
)
SELECT 
   bck.Id,
   bck.IsDeleted,
   bck.CreatedOn,
   bck.ModifiedOn,
   bck.CreatedBy,
   bck.ModifiedBy,
   bck.ReturnAddressId,
   bck.OrderItemId,
   bck.ArticleNumber,
   bck.ReturnUserDescription,
   bck.ReturnEmailAddress,
   bck.ReturnMobilePhoneNumber,
   bck.GeneratedTrackingNumber,
   bck.ReturnTrackingNumber,
   bck.Carrier,
   bck.ReturnStatusId,
   bck.ReturnRequestConfigId,
   bck.ReturnWarehouseId,
   bck.ReturnOrderId,
   bck.ReturnDeliveryId,
   bck.ReturnShipmentNeeded,
   bck.ReturnLabelIdentifer,
   bck.ReturnLabelFilename,
   bck.DeliveryExecutionFinishDate,
   bck.ParentId,
   bck.EsbMessageId,
   bck.ReturnCompensationId,
   bck.ReturnOrderConsqDamage,
   bck.ReturnOrderCoolingOff,
   bck.ReturnRegistrationOptionId,
   bck.PickupWishDate,
   bck.IsFSR,
   bck.FSRDate,
   bck.ItemReceivedDate,
   OrderReference = o.OrderId,
   OrderPosition = oi.OrderPosition
FROM [Wilson_backup].[dbo].[ReturnOrder] bck
LEFT JOIN [Wilson_backup].[dbo].[OrderItem] oi
    on oi.Id = bck.OrderItemId
LEFT JOIN [Wilson_backup].[dbo].[Order] o
    on o.Id = oi.OrderId
LEFT JOIN  [Wilson].[dbo].[ReturnOrder] prod
    on prod.Id = bck.id
WHERE
    prod.id is null
	and bck.returndeliveryid =5001114535

/************************************************************
** updates it to new orderitemid associated to orderreference
**************************************************************/

UPDATE t
    SET NewOrderItemId = oi.Id
FROM #TempReturnOrder t
INNER JOIN Wilson.dbo.[order] o
    on o.OrderId = t.OrderReference
INNER JOIN Wilson.dbo.[OrderItem] oi
    on oi.OrderId = o.Id and oi.OrderPosition = t.OrderPosition


--SELECT * from #TempReturnOrder where  returndeliveryid =5001114535


/*********************************
** Get the affected records - RETURN ORDER COMMENTS
**********************************/

DROP TABLE IF EXISTS #tempReturnOrderComment

CREATE TABLE #tempReturnOrderComment
(
	[Id] [bigint]  NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[CreatedOn] [datetime2](7) NOT NULL,
	[ModifiedOn] [datetime2](7) NULL,
	[CreatedBy] [nvarchar](200) NULL,
	[ModifiedBy] [nvarchar](200) NULL,
	[ReturnOrderId] [bigint] NOT NULL,
	[CommentText] [nvarchar](max) NULL,
)

INSERT INTO #tempReturnOrderComment (Id, IsDeleted,[CreatedOn],ModifiedOn,CreatedBy,ModifiedBy,ReturnOrderId,CommentText)
SELECT bck.Id, bck.IsDeleted,bck.CreatedBy,bck.ModifiedOn,bck.CreatedBy,bck.ModifiedBy,bck.ReturnOrderId,bck.CommentText
FROM Wilson_Backup.dbo.ReturnOrderComment bck
LEFT JOIN Wilson.dbo.ReturnOrderComment prod   
    on prod.Id = bck.id
where 
    prod.id  is null
    and bck.ReturnOrderId in (Select Id from #TempReturnOrder)



/**********************************************
** Get the affected records - MaskReceiveReturn
***********************************************/

DROP TABLE IF EXISTS #tempMaskReceiveReturn

CREATE TABLE #tempMaskReceiveReturn
(
	[Id] [bigint]  NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[CreatedOn] [datetime2](7) NOT NULL,
	[ModifiedOn] [datetime2](7) NULL,
	[CreatedBy] [nvarchar](200) NULL,
	[ModifiedBy] [nvarchar](200) NULL,
	[ReturnOrderId] [bigint] NOT NULL,
	[EAN] [nvarchar](max) NULL,
	[SerialNumber] [nvarchar](max) NULL,
	[OnOffTestId] [bigint] NOT NULL,
	[PackageContentCondition] [bit] NOT NULL,
	[ReceiverComments] [nvarchar](max) NULL,
	[IsCompleted] [bit] NOT NULL,
	[MaterialId] [bigint] NOT NULL,
	[ReturnInspectionConditionCodeId] [bigint] NULL,
	[ReturnInspectionSubCondition] [smallint] NULL

)
INSERT INTO #tempMaskReceiveReturn
(

	[Id] ,
	[IsDeleted] ,
	[CreatedOn] ,
	[ModifiedOn] ,
	[CreatedBy] ,
	[ModifiedBy],
	[ReturnOrderId] ,
	[EAN] ,
	[SerialNumber] ,
	[OnOffTestId] ,
	[PackageContentCondition] ,
	[ReceiverComments] ,
	[IsCompleted] ,
	[MaterialId] ,
	[ReturnInspectionConditionCodeId] ,
	[ReturnInspectionSubCondition] 

)

SELECT 
	bck.[Id] ,
	bck.[IsDeleted] ,
	bck.[CreatedOn] ,
	bck.[ModifiedOn] ,
	bck.[CreatedBy] ,
	bck.[ModifiedBy],
	bck.[ReturnOrderId] ,
	bck.[EAN] ,
	bck.[SerialNumber] ,
	bck.[OnOffTestId] ,
	bck.[PackageContentCondition] ,
	bck.[ReceiverComments] ,
	bck.[IsCompleted] ,
	bck.[MaterialId] ,
	bck.[ReturnInspectionConditionCodeId] ,
	bck.[ReturnInspectionSubCondition] 
FROM Wilson_Backup.dbo.MaskReceiveReturn bck
LEFT JOIN Wilson.dbo.MaskReceiveReturn prod   
    on prod.Id = bck.id
where 
    prod.id  is null
    and bck.ReturnOrderId in (Select Id from #TempReturnOrder)

/**********************************************
** Get the affected records - [ReturnInspection]
***********************************************/

DROP TABLE IF EXISTS #tempReturnInspection

CREATE TABLE #tempReturnInspection
(
	[Id] [bigint] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[CreatedOn] [datetime2](7) NOT NULL,
	[ModifiedOn] [datetime2](7) NULL,
	[CreatedBy] [nvarchar](200) NULL,
	[ModifiedBy] [nvarchar](200) NULL,
	[ReturnOrderId] [bigint] NOT NULL,
	[ReturnInspectionActionId] [bigint] NOT NULL,
	[ReturnInspectionCompensationId] [bigint] NOT NULL,
	[ReturnInspectionConditionCodeId] [bigint] NOT NULL,
	[ReturnInspectionSaveId] [bigint] NOT NULL,
	[UserComment] [nvarchar](500) NULL,
	[EsbMessageId] [nvarchar](50) NULL

)
INSERT INTO #tempReturnInspection
(

	[Id] 
	,[IsDeleted]
    ,[CreatedOn]
    ,[ModifiedOn]
    ,[CreatedBy]
    ,[ModifiedBy]
    ,[ReturnOrderId]
    ,[ReturnInspectionActionId]
    ,[ReturnInspectionCompensationId]
    ,[ReturnInspectionConditionCodeId]
    ,[ReturnInspectionSaveId]
    ,[UserComment]
    ,[EsbMessageId]

)

SELECT 
     bck.[Id] 
	,bck.[IsDeleted]
    ,bck.[CreatedOn]
    ,bck.[ModifiedOn]
    ,bck.[CreatedBy]
    ,bck.[ModifiedBy]
    ,bck.[ReturnOrderId]
    ,bck.[ReturnInspectionActionId]
    ,bck.[ReturnInspectionCompensationId]
    ,bck.[ReturnInspectionConditionCodeId]
    ,bck.[ReturnInspectionSaveId]
    ,bck.[UserComment]
    ,bck.[EsbMessageId]
FROM Wilson_Backup.dbo.ReturnInspection bck
LEFT JOIN Wilson.dbo.ReturnInspection prod   
    on prod.Id = bck.id
where 
    prod.id  is null
    and bck.ReturnOrderId in (Select Id from #TempReturnOrder)



SELECT * FROM #TempReturnOrder
SELECT * FROM #tempReturnOrderComment
SELECT * FROM #tempMaskReceiveReturn
SELECT * FROM #tempReturnInspection

/************************************************************
** Restore it into original tables
**************************************************************/
-- SET IDENTITY_INSERT [ReturnOrder] ON;
--- returnorder
INSERT INTO Wilson.dbo.ReturnOrder (
    Id,
    IsDeleted,
    CreatedOn,
    ModifiedOn,
    CreatedBy,
    ModifiedBy,
    ReturnAddressId,
    OrderItemId,
    ArticleNumber,
    ReturnUserDescription,
    ReturnEmailAddress,
    ReturnMobilePhoneNumber,
    GeneratedTrackingNumber,
    ReturnTrackingNumber,
    Carrier,
    ReturnStatusId,
    ReturnRequestConfigId,
    ReturnWarehouseId,
    ReturnOrderId,
    ReturnDeliveryId,
    ReturnShipmentNeeded,
    ReturnLabelIdentifer,
    ReturnLabelFilename,
    DeliveryExecutionFinishDate,
    ParentId,
    EsbMessageId,
    ReturnCompensationId,
    ReturnOrderConsqDamage,
    ReturnOrderCoolingOff,
    ReturnRegistrationOptionId,
    PickupWishDate,
    IsFSR,
    FSRDate,
    ItemReceivedDate
)
SELECT 
   bck.Id,
   bck.IsDeleted,
   bck.CreatedOn,
   bck.ModifiedOn,
   bck.CreatedBy,
   bck.ModifiedBy,
   bck.ReturnAddressId,
   OrderItemId = bck.NewOrderItemId,
   bck.ArticleNumber,
   bck.ReturnUserDescription,
   bck.ReturnEmailAddress,
   bck.ReturnMobilePhoneNumber,
   bck.GeneratedTrackingNumber,
   bck.ReturnTrackingNumber,
   bck.Carrier,
   bck.ReturnStatusId,
   bck.ReturnRequestConfigId,
   bck.ReturnWarehouseId,
   bck.ReturnOrderId,
   bck.ReturnDeliveryId,
   bck.ReturnShipmentNeeded,
   bck.ReturnLabelIdentifer,
   bck.ReturnLabelFilename,
   bck.DeliveryExecutionFinishDate,
   bck.ParentId,
   bck.EsbMessageId,
   bck.ReturnCompensationId,
   bck.ReturnOrderConsqDamage,
   bck.ReturnOrderCoolingOff,
   bck.ReturnRegistrationOptionId,
   bck.PickupWishDate,
   bck.IsFSR,
   bck.FSRDate,
   bck.ItemReceivedDate
FROM #tempReturnOrder bck

-- SET IDENTITY_INSERT [ReturnOrder] OFF;

--- returnorderComment
-- SET IDENTITY_INSERT [ReturnOrderComment] ON;


INSERT INTO Wilson.dbo.ReturnOrderComment
(
    Id,
    IsDeleted,
    [CreatedOn],
    ModifiedOn,
    CreatedBy,
    ModifiedBy,
    ReturnOrderId,
    CommentText
   )
SELECT 
    Id,
    IsDeleted,
    [CreatedOn],
    ModifiedOn,
    CreatedBy,
    ModifiedBy,
    ReturnOrderId,
    CommentText
FROM #tempReturnOrderComment bck

-- SET IDENTITY_INSERT [ReturnOrderComment] OFF;

--- MaskReceiveReturn
-- SET IDENTITY_INSERT [MaskReceiveReturn] ON;

INSERT INTO Wilson.dbo.MaskReceiveReturn
(

	[Id] ,
	[IsDeleted] ,
	[CreatedOn] ,
	[ModifiedOn] ,
	[CreatedBy] ,
	[ModifiedBy],
	[ReturnOrderId] ,
	[EAN] ,
	[SerialNumber] ,
	[OnOffTestId] ,
	[PackageContentCondition] ,
	[ReceiverComments] ,
	[IsCompleted] ,
	[MaterialId] ,
	[ReturnInspectionConditionCodeId] ,
	[ReturnInspectionSubCondition] 

)

SELECT 
	bck.[Id] ,
	bck.[IsDeleted] ,
	bck.[CreatedOn] ,
	bck.[ModifiedOn] ,
	bck.[CreatedBy] ,
	bck.[ModifiedBy],
	bck.[ReturnOrderId] ,
	bck.[EAN] ,
	bck.[SerialNumber] ,
	bck.[OnOffTestId] ,
	bck.[PackageContentCondition] ,
	bck.[ReceiverComments] ,
	bck.[IsCompleted] ,
	bck.[MaterialId] ,
	bck.[ReturnInspectionConditionCodeId] ,
	bck.[ReturnInspectionSubCondition] 
FROM #tempMaskReceiveReturn bck

-- SET IDENTITY_INSERT [MaskReceiveReturn] OFF;

--- ReturnInspection
-- SET IDENTITY_INSERT [ReturnInspection] ON;

INSERT INTO Wilson.dbo.ReturnInspection
(

	[Id] 
	,[IsDeleted]
    ,[CreatedOn]
    ,[ModifiedOn]
    ,[CreatedBy]
    ,[ModifiedBy]
    ,[ReturnOrderId]
    ,[ReturnInspectionActionId]
    ,[ReturnInspectionCompensationId]
    ,[ReturnInspectionConditionCodeId]
    ,[ReturnInspectionSaveId]
    ,[UserComment]
    ,[EsbMessageId]

)

SELECT 
     bck.[Id] 
	,bck.[IsDeleted]
    ,bck.[CreatedOn]
    ,bck.[ModifiedOn]
    ,bck.[CreatedBy]
    ,bck.[ModifiedBy]
    ,bck.[ReturnOrderId]
    ,bck.[ReturnInspectionActionId]
    ,bck.[ReturnInspectionCompensationId]
    ,bck.[ReturnInspectionConditionCodeId]
    ,bck.[ReturnInspectionSaveId]
    ,bck.[UserComment]
    ,bck.[EsbMessageId]
FROM #tempReturnInspection bck



-- SET IDENTITY_INSERT [ReturnInspection] OFF;
