with 

cte_purchase_transactions as 
(
    SELECT
        'purchasetransaction' AS [source],
		po.CompanyId,
        po.ProcessId,
		po.OrderDocumentNo,
		po.ItemProcessFulfilled,
		po.ProcessFulfilled,
		po.OrderDocumentType,
        ForwarderReference,
        Dispatcher,
        ETD,
        ETAPort,
        CASE WHEN OrderDocumentType = 'UB' THEN -1 ELSE BookingConfirmed END AS BookingConfirmed,
        CASE WHEN LEFT(po.ItemNo, 2) = '11' THEN '10' ELSE LEFT(po.ItemNo, 2) END + RIGHT(po.ItemNo, 6) AS [ItemNo],
        CASE WHEN OrderDocumentType = 'UB' THEN 'Stock in Transfer' ELSE CASE WHEN BookingConfirmed = -1 THEN 'Booking is confirmed' ELSE 'Booking NOT Confirmed' END END AS [BookingStatus],
        ETAWarehouse,
		[Currency],
		[CreditorsNumber],
        [CreditorsName],
		[SupplierGroupNumber],
        [SupplierReference],
		StockReceiptQuantity,
		Deliverynotestatus,
		OrderQuantity
    FROM [CT dwh 03 Intelligence].[dbo].[vFactPurchasingOrdersTransactions]  po with(nolock)

),

cte_contract_reference as 
(
	SELECT [ProcessId]
      ,CASE WHEN LEFT(ItemNo, 2) = '11' THEN '10' ELSE LEFT(ItemNo, 2) END + RIGHT(ItemNo, 6) AS [ItemNo]
	  ,[InfoRecordNumber]
      ,[ContractReference]
	  ,sum([ItemPriceForeignCurrency]) [ItemPriceForeignCurrency]
      ,sum([ItemPrice]) [ItemPrice]
	  ,sum(Quantity) Quantity
	FROM [CT dwh 03 Intelligence].[purch].[vFactVertical] with(nolock)
	where 1=1
		  and TransactionTypeDetail='Order'
		  and isnull([ItemProcessFulfilled], 0) = 0
		  and isnull([ProcessFulfilled], 0) = 0
		  and PurchasingOrganizationCode=1000
	group by 
	   [ProcessId]
      ,CASE WHEN LEFT(ItemNo, 2) = '11' THEN '10' ELSE LEFT(ItemNo, 2) END + RIGHT(ItemNo, 6)
      ,[ContractReference]
	  ,[InfoRecordNumber]

),
cte_delivery_notes as 
(
			SELECT DISTINCT
                [DeliveryNumber],
                [DeliveryPosition],
                [PONo],
                [POPosition],
                [ProductionOrderNo],
                [DeliveryDistributionStatus],
                [MovementCode],
                [MovementType],
                [DeliveryType],
                [DeliverySubType],
                [TransportType],
                [ContainerId],
                [Quantity],
                [StorageLocation1],
                [DeliveryItemNo],
                [Batch],
                [MaterialGroup],
                [DeliveryCreationDate],
                [DeliveryDate]
            FROM
                [CT dwh 03 Intelligence].[dbo].[tDeliveryNotesLogisticsTemp] a with(nolock)
            WHERE
                [DeliveryType] = 'DIG'
                AND DeliveryDistributionStatus <> 'C'
                AND ISNULL([ProductionOrderNo], '') <> ''
                AND a.Quantity > 0

),
cte_bom_item_kitting as 
(
            SELECT
                [ItemNo],
                [BOMComponent],
                [Quantity]
            FROM
                [CT dwh 03 Intelligence].[purch].[vDimBOMItem] with(nolock)
            WHERE
                itemno LIKE '1%'
                AND [BOMComponent] LIKE '7%'
                AND [Plant] = 1000

),
cte_process_mapping as 
(
			SELECT
                CASE WHEN vert.[DeliveryNo] IN (
                    '0180000065', '0180002585', '0180002802', '0180003066', '0180003238', 
                    '0180004280', '0180009887', '0180014055', '0180016232', '0180043979', 
                    '0180051574', '0180062747', '0180063445', '0180078056', '0180291365', 
                    '0180330105', '0180349397', '0180356147', '0180364826', '0180398085'
                ) THEN 'incident' ELSE vert.[ProcessId] END AS [ProcessId],
                kit.itemno AS [ItemNo],
                vert.[DeliveryNo]
            FROM
                [CT dwh 03 Intelligence].[purch].[vFactVertical] vert with(nolock)
            LEFT JOIN cte_bom_item_kitting kit  with(nolock) ON vert.ItemNo = kit.[BOMComponent] 
            WHERE
                vert.[TransactionTypeDetail] = 'ProductionOrder'
            GROUP BY
                vert.[ProcessId],
                kit.itemno,
                vert.[DeliveryNo]
),
cte_vertical as
(

            SELECT
                [SourceName],
                '10' + RIGHT([ItemNo], 6) AS itemno,
                [ProcessId],
                [ItemPriceForeignCurrency],
                [ItemPrice],
                [BookingConfirmed],
                [ETAWareHouse],
				CreditorNumber,
				CreditorName,
                [ETD],
				[ETAport],
				[InfoRecordNumber],
				[ContractReference],
				currency,
				[SupplierGroupNumber],
				[SupplierReference],
			  sum(Quantity) Quantity
            FROM
                [CT dwh 03 Intelligence].[purch].[vFactVertical] with(nolock)
            WHERE
                [TransactionTypeDetail] = 'Order'
                AND [ETAWareHouse] != '0001-01-01'
			group by 
				[SourceName],
                '10' + RIGHT([ItemNo], 6),
                [ProcessId],
                --[Quantity],
                [ItemPriceForeignCurrency],
                [ItemPrice],
                [BookingConfirmed],
                [ETAWareHouse],
				CreditorNumber,
				CreditorName,
                [ETD],
				[ETAport],
				[InfoRecordNumber],
				[ContractReference],
				currency,
				[SupplierGroupNumber],
				[SupplierReference]

),
cte_second_union as
(

        SELECT 
            DeliveryNumber AS Delivery,
            ProductionOrderNo,
            CASE WHEN DeliveryNumber IN (
                SELECT DeliveryNumber
                FROM [CT dwh 03 Intelligence].[dbo].[tDeliveryNotesLogisticsTemp]
                WHERE productionorderno <> '' AND DeliveryDistributionStatus <> 'C' AND deliverynumber IN (
                    SELECT documentno
                    FROM [CT dwh 03 Intelligence].[purch].[vFactVertical]
                    WHERE transactiontypedetail = 'Inbound Delivery Movement' AND documentno <> ''
                )
            ) THEN 'C' ELSE DeliveryDistributionStatus END AS 'DeliveryNoteStatus',
            TransportType,
            ContainerId AS Containernumber,
            SUM(dn.Quantity) AS QTY,
            StorageLocation1 AS [StorageLocation],
            DeliveryItemNo AS ItemNo,
            CASE WHEN DeliveryDate = DeliveryCreationDate THEN DATEADD(dd, 40, DeliveryCreationDate) ELSE DeliveryDate END AS [ETA WH],
            DeliveryDate AS [Delivery_Date],
            DeliveryCreationDate AS [Document_created_on],
            kit.ItemNo AS [main kitting item],
            SUM(kit.[Quantity]) AS 'picking QTY',
            SUM(dn.Quantity) / SUM(kit.[Quantity]) AS [main kitting item quantity],
            CASE WHEN CASE WHEN DeliveryDate = DeliveryCreationDate THEN DATEADD(dd, 40, DeliveryCreationDate) ELSE DeliveryDate END < GETDATE() THEN GETDATE() + 10 ELSE CASE WHEN DeliveryDate = DeliveryCreationDate THEN DATEADD(dd, 40, DeliveryCreationDate) ELSE DeliveryDate END END AS [adj. ETA WH],
            vertical.[ETAWareHouse] AS [ETAWareHouse],
            vertical.ProcessId,
			vertical.ETAport,
			vertical.ETD,
			vertical.Quantity,
			vertical.ContractReference,
			vertical.InfoRecordNumber,
			vertical.Currency,
			vertical.ItemPrice OrderItemPrice,
			vertical.ItemPriceForeignCurrency OrderItemPriceForeignCurrency,
			vertical.CreditorNumber [CreditorsNumber], 
			vertical.CreditorName [CreditorsName],
			vertical.[SupplierGroupNumber],
			vertical.[SupplierReference]
FROM cte_delivery_notes dn
LEFT JOIN cte_bom_item_kitting kit
	ON dn.DeliveryItemNo = kit.[BOMComponent]
LEFT JOIN cte_process_mapping processIDmapping 
	ON processIDmapping.[ItemNo] = kit.ItemNo AND processIDmapping.[DeliveryNo] = DN.[DeliveryNumber]
LEFT JOIN cte_vertical vertical
	ON vertical.ProcessId = processIDmapping.ProcessId AND vertical.itemno = kit.ItemNo

GROUP BY
            DeliveryNumber,
            PONo,
            ProductionOrderNo,
            DeliveryDistributionStatus,
            TransportType,
            ContainerId,
            StorageLocation1,
            DeliveryItemNo,
            DeliveryDate,
            DeliveryCreationDate,
            kit.ItemNo,
            CASE WHEN CASE WHEN DeliveryDate = DeliveryCreationDate THEN DATEADD(dd, 40, DeliveryCreationDate) ELSE DeliveryDate END < GETDATE() THEN GETDATE() + 10 ELSE CASE WHEN DeliveryDate = DeliveryCreationDate THEN DATEADD(dd, 40, DeliveryCreationDate) ELSE DeliveryDate END END,
            vertical.[ETAWareHouse],
            vertical.ProcessId,
			vertical.ETAport,
			vertical.ETD,
			vertical.Quantity,
			vertical.ContractReference,
			vertical.InfoRecordNumber,
			currency,
			vertical.ItemPrice,
			vertical.ItemPriceForeignCurrency,
			vertical.CreditorNumber,
			vertical.CreditorName,
			SupplierGroupNumber,
			SupplierReference

),
cte_final_dataset as 
(
    SELECT
        [source],
        po.ProcessId,
        ForwarderReference,
        Dispatcher,
        ETD,
        ETAPort,
        BookingConfirmed,
        po.[ItemNo],
        [BookingStatus],
        ETAWarehouse,
		[Currency],
		[CreditorsNumber],
        [CreditorsName],
		[SupplierGroupNumber],
        [SupplierReference],
		cr.ContractReference,
		cr.InfoRecordNumber,
        cr.[ItemPrice] AS OrderItemPrice,
		cr.[ItemPriceForeignCurrency] as [OrderItemPriceForeignCurrency],
        SUM(ISNULL(cr.Quantity, 0)) - SUM(ISNULL(StockReceiptQuantity, 0)) AS [Open QTY]
    FROM cte_purchase_transactions  po
	LEFT JOIN cte_contract_reference cr
		on po.ProcessId=cr.ProcessId and po.ItemNo=cr.itemno

    WHERE
        CompanyId = 1000
        AND ISNULL(po.ItemNo,'') <> ''
        AND OrderDocumentNo IS NOT NULL
        AND ISNULL(ItemProcessFulfilled, 0) = 0
        AND ISNULL(ProcessFulfilled, 0) = 0
        AND OrderDocumentType IN ('Z101', 'Z102', 'Z103', 'Z105', 'Z106')
    GROUP BY
		po.source,
        po.ProcessId,
        ForwarderReference,
        Dispatcher,
        ETD,
        ETAPort,
        BookingConfirmed ,
        po.ItemNo,
		po.BookingStatus,
        ETAWarehouse,
		[Currency],
		[CreditorsNumber],
        [CreditorsName],
		[SupplierGroupNumber],
        [SupplierReference],
		cr.ContractReference,
		cr.InfoRecordNumber,
		cr.[ItemPrice],
		cr.[ItemPriceForeignCurrency]


    HAVING
        SUM(ISNULL(OrderQuantity, 0)) > 0

	UNION ALL

	    SELECT
        'kitting delivery note' AS [source],
        ProcessId,
        NULL AS ForwarderReference,  
        NULL AS Dispatcher,           
        ETD,                 
        ETAPort,             
        '-1' AS BookingConfirmed,
        [main kitting item] AS [ItemNo],
        'Booking is confirmed' AS [BookingStatus],
        [ETAWareHouse],
		[Currency],
		[CreditorsNumber],
        [CreditorsName],
		[SupplierGroupNumber],
        [SupplierReference],
		ContractReference,
		InfoRecordNumber,
        OrderItemPrice,
		[OrderItemPriceForeignCurrency],
        MIN([main kitting item quantity]) AS [Open QTY]

    FROM cte_second_union
	    WHERE
        deliverynotestatus <> 'C'
        AND [main kitting item] IS NOT NULL
        AND ProcessID IS NOT NULL
    GROUP BY
        [main kitting item],
        processID,
        ProductionOrderNo,
        [ETAWareHouse],
		ETD,                 
        ETAPort,
		[Currency],
		CreditorsNumber,
		CreditorsName,
		SupplierGroupNumber,
		SupplierReference,
		ContractReference,
		InfoRecordNumber,
        OrderItemPrice,
		[OrderItemPriceForeignCurrency]
)

SELECT
    datefromparts(year(getdate()-1),month(getdate()-1),day(getdate()-1)) as [snapshot date],
    source,
    ProcessId,
    ForwarderReference,
    Dispatcher,
    ETD,
    ETAPort,
    BookingConfirmed,
    [ItemNo],
    [BookingStatus],
    ETAWarehouse,
	[Currency],
	[CreditorsNumber],
    [CreditorsName],
	case when CreditorsNumber IN (707063430,707063420,707063440,707063480,707063470,707063490,707063400,707063410,708000004,707407400,707410000) OR SupplierGroupNumber='IC00' then 'GTS' else 'Direct' end as [GTS or Direct],
	[SupplierGroupNumber],
    [SupplierReference],
    OrderItemPrice,
	[OrderItemPriceForeignCurrency],
	ContractReference,
	InfoRecordNumber,

    SUM([Open QTY]) AS [Open QTY],
    RANK() OVER (PARTITION BY [ItemNo] ORDER BY ETAWarehouse) AS rank
FROM cte_final_dataset

GROUP BY
    source,
    ProcessId,
    ForwarderReference,
    Dispatcher,
    ETD,
    ETAPort,
    BookingConfirmed,
    [ItemNo],
    [BookingStatus],
    ETAWarehouse,
	[Currency],
	[CreditorsNumber],
    [CreditorsName],
	[SupplierGroupNumber],
    [SupplierReference],
    OrderItemPrice,
	[OrderItemPriceForeignCurrency],
		ContractReference,
	InfoRecordNumber


	order by ProcessId,ItemNo