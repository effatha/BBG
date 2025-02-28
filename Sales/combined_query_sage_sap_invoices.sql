DECLARE @start_date as Date = '2020-01-01'
DECLARE @end_date as Date = '2023-12-31'

;with cte_main_data as (

	SELECT 
		PVST.Source,
		SalesTransactionCode,
		PVST.StorageLocation,
		PVST.TransactionDate,
		PVSTT.TransactionType,
		PVST.ProcessId,
		PVST.DocumentNo,
		PVST.DocumentItemPosition,
		PVST.ItemId,
		ItemType,
		Quantity
	FROM  PL.PL_V_SALES_TRANSACTIONS PVST
	INNER JOIN PL.PL_V_SALES_TRANSACTION_TYPE PVSTT ON PVSTT.TransactionTypeID = PVST.TransactionTypeID
	WHERE 1=1
		AND PVST.TransactionDate >= @start_date AND PVST.TransactionDate <= @end_date
		AND ISNULL(ReasonForRejections,'')=''
		AND (CompanyID in (43) OR Source = 'SAP')
	    AND PVSTT.TransactionType  IN ('Order', 'Replace','OrderInvoice')

	UNION

		SELECT 
		Source = CD_Source_system ,
		SalesTransactionCode = CD_SALES_TRANSACTION,
		StorageLocation = T_STORAGE_LOCATION,
		TransactionDate = D_CREATED,
		PVSTT.TransactionType,
		ProcessId = CD_SALES_PROCESS_ID,
		DocumentNo = CD_DOCUMENT_NO,
		DocumentItemPosition = CD_DOCUMENT_LINE,
		ItemId =PVST.ID_ITEM,
		ItemType = PVST.CD_ITEM_TYPE,
		Quantity = VL_ITEM_QUANTITY
	FROM  L1.L1_FACT_A_SALES_TRANSACTION PVST
	INNER JOIN PL.PL_V_SALES_TRANSACTION_TYPE PVSTT ON PVSTT.TransactionTypeID = PVST.ID_SALES_TRANSACTION_TYPE
	INNER JOIN PL.PL_V_ITEM PVI ON PVI.ItemId = PVST.ID_ITEM
	WHERE 1=1
		AND PVST.D_CREATED >= @start_date AND PVST.D_CREATED <= @end_date
		AND ISNULL(T_CANCELLATION_REASON,'')=''
		AND CD_Source_system = 'SAP'
	    AND PVSTT.TransactionType  IN ('Replace')
		and PVST.CD_DOCUMENT_LINE = '000100'
		and PVI.ItemNo like '7%'
)



	SELECT 
    PVST.Source,
    PVST.StorageLocation,
    PVST.TransactionDate,
    TransactionType,
    PVST.ProcessId,
	PVST.DocumentNo,
	PVST.DocumentItemPosition,
	DELIVERY.DeliveryNumber,
    InvoiceNumber = ISNULL(INVOICE.InvoiceNumber,INVOICE_SET_KITTING.InvoiceNumber),
	INVOICE.InvoiceID,
    PVI.ItemNo,
    PVST.ItemType as ItemQuality,
    PVST.Quantity
FROM cte_main_data PVST
INNER JOIN PL.PL_V_ITEM PVI ON PVI.ItemId = PVST.ItemID
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
        ProcessId = PVST.CD_SALES_PROCESS_ID,
        InvoiceNumber = PVST.CD_DOCUMENT_NO,
        ReferenceDocumentId = PVST.CD_DOCUMENT_ID_REFERENCE,
		ItemId = PVST.ID_ITEM,
		SGE_INV.CD_DOCUMENT_ID AS InvoiceId,
		ItemType = PVST.CD_ITEM_TYPE
    FROM L1.L1_FACT_A_SALES_TRANSACTION PVST
    INNER JOIN PL.PL_V_SALES_TRANSACTION_TYPE PVSTT ON PVSTT.TransactionTypeID = PVST.ID_SALES_TRANSACTION_TYPE
	INNER JOIN L1.L1_FACT_A_SALES_TRANSACTION SGE_INV on SGE_INV.CD_SALES_TRANSACTION = PVST.CD_SALES_TRANSACTION
	INNER JOIN PL.PL_V_ITEM PVI ON PVI.ItemId = PVST.ID_ITEM

    WHERE 0=0
        AND PVSTT.TransactionType = 'Invoice' 
		AND (PVST.CD_SOURCE_SYSTEM = 'SGE' OR PVST.VL_BILLING_QUANTITY <> 0)
		AND PVI.ItemNo like '7%'
    GROUP BY
        PVST.CD_SALES_PROCESS_ID,
        PVST.CD_DOCUMENT_NO,
		PVST.ID_ITEM,
        PVST.CD_DOCUMENT_ID_REFERENCE,
		SGE_INV.CD_DOCUMENT_ID,PVST.CD_ITEM_TYPE
) AS INVOICE_SET_KITTING 
		ON INVOICE_SET_KITTING.ProcessId = PVST.ProcessId AND INVOICE_SET_KITTING.ReferenceDocumentId = CASE WHEN PVST.Source= 'SAP' THEN PVST.DocumentNo ELSE SGE_ORDERS.CD_DOCUMENT_ID END
		AND INVOICE_SET_KITTING.ItemId = PVST.ItemId
		AND ( PVST.ItemType = INVOICE_SET_KITTING.ItemType )
LEFT JOIN (
    SELECT
        ProcessId = CD_SALES_PROCESS_ID,
        DeliveryNumber = CD_DOCUMENT_NO,
        ReferenceDocumentId = CD_DOCUMENT_ID_REFERENCE,
		ItemID = PVST.ID_ITEM,
		ItemType = PVST.CD_ITEM_TYPE
    FROM L1.L1_FACT_A_SALES_TRANSACTION PVST
    INNER JOIN PL.PL_V_ITEM PVI ON PVI.ItemId = PVST.ID_ITEM
    INNER JOIN PL.PL_V_SALES_TRANSACTION_TYPE PVSTT ON PVSTT.TransactionTypeID = PVST.ID_SALES_TRANSACTION_TYPE

    WHERE 0=0
        AND PVSTT.TransactionType = 'DeliveryNote' and ISNULL(FL_Deleted,'N') = 'N' AND VL_ITEM_Quantity <> 0
    GROUP BY
        PVST.CD_SALES_PROCESS_ID,
        PVST.CD_DOCUMENT_NO,
        PVST.CD_DOCUMENT_ID_REFERENCE,
		PVST.ID_ITEM,
		PVST.CD_ITEM_TYPE
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
   -- AND (
			--(CANCELLATION.CancelledDocumentNo IS NULL AND PVST.source = 'SAP')
			--	OR 
			--	( PVST.source = 'SGE' and CANCELLATION.CancelNumber IS NULL)
			--)
	AND 

	PVST.ProcessId= '0401100866'