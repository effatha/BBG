SELECT 
  CompanyId,
  [Year] = 2022,
  ISNULL(IncidentFlag,1)IncidentFlag,
  ISNULL(ChannelGroupI,'N/A'),
  ISNULL(InvoiceCountry,'N/A')InvoiceCountry,
  sum(Revenue)Revenue
  FROM [CT dwh 03 Intelligence].[sales].[vFactSalesTransactionsVertical]
  WHERE
    TransactionYear = 2022
  --  and TransactionType in ('OrderInvoice','Invoice','Refund')
  GROUP BY
  CompanyId,
  ISNULL(IncidentFlag,1),
  ISNULL(ChannelGroupI,'N/A'),
  ISNULL(InvoiceCountry,'N/A')
Order By ISNULL(ChannelGroupI,'N/A'),InvoiceCountry


    --Select top 10 *
    --FROM [CT dwh 03 Intelligence].[sales].[vFactSalesTransactionsVertical]
