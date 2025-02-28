DECLARE @start_date as Date = '2023-12-01'
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
FROM PL.PL_V_SALES_TRANSACTIONS PVST
INNER JOIN PL.PL_V_ITEM PVI ON PVI.ItemId = PVST.ItemID
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
Order by InvoiceNumber
