--DECLARE @start_date as Date = '2020-01-01'
--DECLARE @end_date as Date = '2023-12-31'

--SELECT
--    PVST.Source,
--    PVST.StorageLocation,
--    PVST.TransactionDate,
--    PVSTT.TransactionType,
--    PVST.ProcessId,
--	PVST.DocumentNo,
--    INVOICE.InvoiceNumber,
--	INVOICE.InvoiceID,
--    DELIVERY.DeliveryNumber,
--    PVI.ItemNo,
--    PVST.ItemType as ItemQuality,
--    PVST.Quantity
--FROM PL.PL_V_SALES_TRANSACTIONS PVST
--INNER JOIN PL.PL_V_ITEM PVI ON PVI.ItemId = PVST.ItemID
--INNER JOIN PL.PL_V_SALES_TRANSACTION_TYPE PVSTT ON PVSTT.TransactionTypeID = PVST.TransactionTypeID
--INNER JOIN L1.L1_FACT_A_SALES_TRANSACTION SGE_ORDERS on SGE_ORDERS.CD_SALES_TRANSACTION = PVST.SalesTransactionCode
--LEFT JOIN (
--    SELECT
--        PVST.ProcessId,
--        PVST.DocumentNo InvoiceNumber,
--        PVST.ReferenceDocumentId,
--		SGE_INV.CD_DOCUMENT_ID AS InvoiceId
--    FROM syndpbbgdwh01.PL.PL_V_SALES_TRANSACTIONS PVST
--    INNER JOIN PL.PL_V_SALES_TRANSACTION_TYPE PVSTT ON PVSTT.TransactionTypeID = PVST.TransactionTypeID
--	INNER JOIN L1.L1_FACT_A_SALES_TRANSACTION SGE_INV on SGE_INV.CD_SALES_TRANSACTION = PVST.SalesTransactionCode

--    WHERE 0=0
--        AND PVSTT.TransactionType = 'Invoice'
--    GROUP BY
--        PVST.ProcessId,
--        PVST.DocumentNo,
--        PVST.ReferenceDocumentId,
--		SGE_INV.CD_DOCUMENT_ID
--) AS INVOICE 
--		ON INVOICE.ProcessId = PVST.ProcessId AND INVOICE.ReferenceDocumentId = CASE WHEN PVST.Source= 'SAP' THEN PVST.DocumentNo ELSE SGE_ORDERS.CD_DOCUMENT_ID END
--LEFT JOIN (
--    SELECT
--        PVST.ProcessId,
--        PVST.DocumentNo DeliveryNumber,
--        PVST.ReferenceDocumentId
--    FROM syndpbbgdwh01.PL.PL_V_SALES_TRANSACTIONS PVST
--    INNER JOIN PL.PL_V_ITEM PVI ON PVI.ItemId = PVST.ItemID
--    INNER JOIN PL.PL_V_SALES_TRANSACTION_TYPE PVSTT ON PVSTT.TransactionTypeID = PVST.TransactionTypeID

--    WHERE 0=0
--        AND PVSTT.TransactionType = 'DeliveryNote'
--    GROUP BY
--        PVST.ProcessId,
--        PVST.DocumentNo,
--        PVST.ReferenceDocumentId
--) DELIVERY ON DELIVERY.ProcessId = PVST.ProcessId AND DELIVERY.ReferenceDocumentId = PVST.DocumentNo
--LEFT JOIN (
--    SELECT
--        PVST.ProcessId,
--        PVST.DocumentNo CancelNumber,
--		PVST.ReferenceDocumentId,
--		SGE_CAN.CD_DOCUMENT_ID AS CancellationID,
--        PVST.CancelledDocumentNo
--    FROM syndpbbgdwh01.PL.PL_V_SALES_TRANSACTIONS PVST
--    INNER JOIN PL.PL_V_ITEM PVI ON PVI.ItemId = PVST.ItemID
--    INNER JOIN PL.PL_V_SALES_TRANSACTION_TYPE PVSTT ON PVSTT.TransactionTypeID = PVST.TransactionTypeID
--	INNER JOIN L1.L1_FACT_A_SALES_TRANSACTION SGE_CAN on SGE_CAN.CD_SALES_TRANSACTION = PVST.SalesTransactionCode

--    WHERE 0=0
--        AND PVSTT.TransactionType = 'InvoiceCancellation'
--        --AND NOT PVST.CancelledDocumentNo IS NULL
--	--	and processid = '18447582'
--    GROUP BY
--        PVST.ProcessId,
--        PVST.DocumentNo,
--        PVST.CancelledDocumentNo,SGE_CAN.CD_DOCUMENT_ID,ReferenceDocumentId
--) CANCELLATION 
--			ON CANCELLATION.ProcessId = PVST.ProcessId 
--			AND CASE WHEN PVST.Source= 'SAP' THEN CANCELLATION.CancelledDocumentNo ELSE CANCELLATION.ReferenceDocumentId END  = CASE WHEN PVST.Source= 'SAP' THEN INVOICE.InvoiceNumber ELSE INVOICE.InvoiceID END
--WHERE 0=0
----	and PVST.source='SGE'
--    AND PVSTT.TransactionType  IN ('Order', 'Replace','OrderInvoice')
--    AND (
--			(CANCELLATION.CancelledDocumentNo IS NULL AND PVST.source = 'SAP')
--				OR 
--				( PVST.source = 'SGE')
--			)
-- --   AND PVST.TransactionDate >= @start_date AND PVST.TransactionDate <= @end_date
----	and InvoiceNumber = '6300000380'
--	and PVST.DocumentNo =  '1704751'
--	and PVST.ProcessId =  '12706122'
--	and PVI.ItemNo = '10029669'
--	--Order by InvoiceNumber


	--select * from PL.PL_V_ITEM where itemno = '10029669'

--	select [FL_DELETED],*   FROM L1.L1_FACT_A_SALES_TRANSACTION_KPI WHERE CD_SALES_PROCESS_ID='0400870319'  and CD_DOCUMENT_NO = '3000846769'and ID_ITEM=8661


DROP TABLE TEST.PL_AUDIT_QUERY
	DECLARE @start_date as Date = '2020-01-01'
DECLARE @end_date as Date = '2023-12-31'

	SELECT
    PVST.Source,
    PVST.StorageLocation,
    PVST.TransactionDate,
    PVSTT.TransactionType,
    PVST.ProcessId,
	PVST.DocumentNo,
	PVST.DocumentItemPosition,
    INVOICE.InvoiceNumber,
	INVOICE.InvoiceID,
    PVI.ItemNo,
    PVST.ItemType as ItemQuality,
    PVST.Quantity
INTO  TEST.PL_AUDIT_QUERY
FROM PL.PL_V_SALES_TRANSACTIONS PVST
INNER JOIN PL.PL_V_ITEM PVI ON PVI.ItemId = PVST.ItemID
INNER JOIN PL.PL_V_SALES_CHANNEL PVSC ON PVSC.ChannelId = PVST.ChannelId
INNER JOIN PL.PL_V_SALES_TRANSACTION_TYPE PVSTT ON PVSTT.TransactionTypeID = PVST.TransactionTypeID
INNER JOIN L1.L1_FACT_A_SALES_TRANSACTION SGE_ORDERS on SGE_ORDERS.CD_SALES_TRANSACTION = PVST.SalesTransactionCode
LEFT JOIN (
    SELECT
        PVST.ProcessId,
        PVST.DocumentNo InvoiceNumber,
        PVST.ReferenceDocumentId,
		PVST.ItemId,
		SGE_INV.CD_DOCUMENT_ID AS InvoiceId,
		PVST.ItemType
    FROM syndpbbgdwh01.PL.PL_V_SALES_TRANSACTIONS PVST
    INNER JOIN PL.PL_V_SALES_TRANSACTION_TYPE PVSTT ON PVSTT.TransactionTypeID = PVST.TransactionTypeID
	INNER JOIN L1.L1_FACT_A_SALES_TRANSACTION SGE_INV on SGE_INV.CD_SALES_TRANSACTION = PVST.SalesTransactionCode

    WHERE 0=0
        AND PVSTT.TransactionType = 'Invoice' 
		AND (CD_SOURCE_SYSTEM = 'SGE' OR VL_BILLING_QUANTITY <> 0)
    GROUP BY
        PVST.ProcessId,
        PVST.DocumentNo,
		PVST.ItemId,
        PVST.ReferenceDocumentId,
		SGE_INV.CD_DOCUMENT_ID,PVST.ItemType
) AS INVOICE 
		ON INVOICE.ProcessId = PVST.ProcessId AND INVOICE.ReferenceDocumentId = CASE WHEN PVST.Source= 'SAP' THEN PVST.DocumentNo ELSE SGE_ORDERS.CD_DOCUMENT_ID END
		AND INVOICE.ItemId = PVST.ItemId
		AND ( PVST.ItemType = INVOICE.ItemType )

LEFT JOIN (
    SELECT
        PVST.ProcessId,
        PVST.DocumentNo DeliveryNumber,
        PVST.ReferenceDocumentId,
		PVST.ItemID,
		PVST.ItemType
    FROM syndpbbgdwh01.PL.PL_V_SALES_TRANSACTIONS PVST
    INNER JOIN PL.PL_V_ITEM PVI ON PVI.ItemId = PVST.ItemID
    INNER JOIN PL.PL_V_SALES_TRANSACTION_TYPE PVSTT ON PVSTT.TransactionTypeID = PVST.TransactionTypeID

    WHERE 0=0
        AND PVSTT.TransactionType = 'DeliveryNote' and ISNULL(Deleted,'N') = 'N' AND Quantity <> 0
    GROUP BY
        PVST.ProcessId,
        PVST.DocumentNo,
        PVST.ReferenceDocumentId,
		PVST.ItemID,
		PVST.ItemType
) DELIVERY ON DELIVERY.ProcessId = PVST.ProcessId AND DELIVERY.ReferenceDocumentId = PVST.DocumentNo 		
		AND DELIVERY.ItemId = PVST.ItemId
		AND ( PVST.ItemType = DELIVERY.ItemType )

LEFT JOIN (
    SELECT
        PVST.ProcessId,
        PVST.DocumentNo CancelNumber,
		PVST.ReferenceDocumentId,
		SGE_CAN.CD_DOCUMENT_ID AS CancellationID,
        PVST.CancelledDocumentNo,
		PVST.ItemID,
		PVST.ItemType
    FROM syndpbbgdwh01.PL.PL_V_SALES_TRANSACTIONS PVST
    INNER JOIN PL.PL_V_ITEM PVI ON PVI.ItemId = PVST.ItemID
    INNER JOIN PL.PL_V_SALES_TRANSACTION_TYPE PVSTT ON PVSTT.TransactionTypeID = PVST.TransactionTypeID
	INNER JOIN L1.L1_FACT_A_SALES_TRANSACTION SGE_CAN on SGE_CAN.CD_SALES_TRANSACTION = PVST.SalesTransactionCode

    WHERE 0=0
        AND PVSTT.TransactionType = 'InvoiceCancellation'
        --AND NOT PVST.CancelledDocumentNo IS NULL
	--	and processid = '12706122' and ReferenceDocumentId='52332068'
    GROUP BY
        PVST.ProcessId,
        PVST.DocumentNo,
        PVST.CancelledDocumentNo,SGE_CAN.CD_DOCUMENT_ID,ReferenceDocumentId,PVST.ItemID,
		PVST.ItemType
) CANCELLATION 
			ON CANCELLATION.ProcessId = PVST.ProcessId 
			AND CASE WHEN PVST.Source= 'SAP' THEN CANCELLATION.CancelledDocumentNo ELSE CANCELLATION.ReferenceDocumentId END  = CASE WHEN PVST.Source= 'SAP' THEN INVOICE.InvoiceNumber ELSE INVOICE.InvoiceID END
			AND PVST.ItemID=CANCELLATION.ItemID
					AND ( PVST.ItemType = CANCELLATION.ItemType )


WHERE 0=0
    AND PVSTT.TransactionType  IN ('Order', 'Replace','OrderInvoice')
    AND (
			(CANCELLATION.CancelledDocumentNo IS NULL AND PVST.source = 'SAP')
				OR 
				( PVST.source = 'SGE' and CANCELLATION.CancelNumber IS NULL)
			)
    AND PVST.TransactionDate >= @start_date AND PVST.TransactionDate <= @end_date
	AND ISNULL(ReasonForRejections,'')=''
	AND (CompanyID in (43) OR CD_SOURCE_SYSTEM = 'SAP')
	AND
		CASE 
			WHEN PVSC.Channel='Intercompany' OR PVSC.Channel='Mandanten' THEN 1
		ELSE 0 END	 = 0

