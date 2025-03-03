USE [CT dwh 03 Intelligence]
GO
/****** Object:  View [dbo].[PL_V_AUTOMATIC_REFUNDS]    Script Date: 13/06/2024 13:50:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[PL_V_AUTOMATIC_REFUNDS]
AS


WITH CTE_ORDERS AS (
    SELECT 
        ProcessId,
        DocumentNo,
        DocumentItemPosition,
        CustomerID,
        ChannelID AS ID_SALES_CHANNEL,
        SUM(CASE WHEN ISNULL(GrossPriceForeignCurrency,0) + ISNULL(GrossDocumentFooterForeignCurrency,0) = 0 THEN IsNull(GrossPrice,0)+ISNULL(GrossDocumentFooter,0) ELSE ISNULL(GrossPriceForeignCurrency,0) + ISNULL(GrossDocumentFooterForeignCurrency,0) END) AS AMT_GROSS_PRICE_EUR,
        MAX(MarketplaceOrderID) AS CD_MARKET_ORDER_ID
    FROM [CT dwh 03 Intelligence].[sales].[vFactSalesTransactionsVertical]
    WHERE TransactionTypeShort IN ('F2','S1','L2','ZF2')
    GROUP BY ProcessId, DocumentNo, DocumentItemPosition, CustomerID, ChannelID
)
 
SELECT  
    ret.ProcessId ,
    ret.DocumentNo ,
    ret.DocumentItemPosition ,
    ret.ReferenceDocumentId as CreditMemoRequest ,
    ret.TransactionDate ,
    ret.Channel as SalesOffice,
    ISNULL(ret.CreationUserName,cm.ERNAM) as CreatedBy,
    ISNULL(ret.OrderReason,cm.AUGRU) OrderReason,
    ord.AMT_GROSS_PRICE_EUR AS GrossPriceINV,
    SUM(CASE WHEN ISNULL(ret.GrossPriceForeignCurrency,0) + ISNULL(ret.GrossDocumentFooterForeignCurrency,0) = 0 THEN ISNULL(ret.GrossPrice,0)+ISNULL(GrossDocumentFooter,0) ELSE ISNULL(ret.GrossPriceForeignCurrency,0) + ISNULL(ret.GrossDocumentFooterForeignCurrency,0) END) AS GrossPriceCM,
    ord.CD_MARKET_ORDER_ID as CustomerReference,
    ISNULL(ret.CustomerID,cm.KUNNR)CustomerID,
    CASE WHEN ABS(SUM(CASE WHEN ISNULL(ret.GrossPriceForeignCurrency,0) + ISNULL(ret.GrossDocumentFooterForeignCurrency,0) = 0 THEN ISNULL(ret.GrossPrice,0)+ISNULL(GrossDocumentFooter,0) ELSE ISNULL(ret.GrossPriceForeignCurrency,0) + ISNULL(ret.GrossDocumentFooterForeignCurrency,0) END)) < ABS(isnull(ord.AMT_GROSS_PRICE_EUR,0)) THEN 'Partial Refund' ELSE 'Full Refund' END AS RefundType
	FROM [CT dwh 03 Intelligence].[sales].[vFactSalesTransactionsVertical] ret
Left JOIN [CT dwh 02 Data].dbo.tSAP2LIS_13_VDITM vditm on ret.DocumentNo = vditm.vbeln and ret.DocumentItemPosition = vditm.posnr and vditm.is_current = 1
Left Join [CT dwh 02 Data].dbo.tSAP2LIS_11_VAITM cm on cm.vbeln = vditm.AUBEL and vditm.AUPOS = cm.POSNR and cm.is_current =1
INNER JOIN CTE_ORDERS ord ON ord.ProcessId = ret.ProcessId AND ord.DocumentItemPosition = cm.VGPOS
LEFT JOIN [CT dwh 03 Intelligence].[sales].[vDimItem] itm ON itm.Itemno = ret.ItemNo
WHERE ret.TransactionTypeShort IN ('G2','ZG2') and ret.TransactionDate >= getdate()-30 --and ret.DocumentNo = '6300181568'
GROUP BY ret.ProcessId, ret.DocumentItemPosition, ret.DocumentNo, ret.DocumentPositionID, ret.ReferenceDocumentId, ret.TransactionDate,
         ret.Channel
		 ,ISNULL(ret.CreationUserName,cm.ERNAM)
		 ,ISNULL(ret.OrderReason,cm.AUGRU)
		 , ord.AMT_GROSS_PRICE_EUR
		 , ord.CD_MARKET_ORDER_ID
		 , ISNULL(ret.CustomerID,cm.KUNNR)
--ORDER BY TransactionDate desc











GO
