/****** Object:  View [PL].[PL_V_RETURNS]    Script Date: 29/09/2023 11:23:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [PL].[PL_V_RETURNS] AS WITH CTE_COUNTRY AS (

	SELECT  ProcessId,InvoiceCountry,Max(isnull(DeliveryCountry,InvoiceCountry)) DeliveryCountry
	FROM [PL].[PL_V_SALES_TRANSACTIONS]
	WHERE Source= 'SAP' and InvoiceCountry is not null
	GROUP BY ProcessId,InvoiceCountry
)
,CTE_PROCESSID_VALUES AS (
	
	SELECT 
		ProcessID,
		---Value Tax in Sage is positive and in sap  is negative. for the math to work we need to invert the signal if the tax is from sage order
		GrossOrderValuePRD = SUM(
								CASE WHEN TransactionType in ('Order','OrderInvoice') AND ISNULL(ReasonForRejections,'')='' 
								THEN (	isnull(GrossPrice,0) + (isnull(TaxPrice,0)*CASE WHEN pl.Source = 'SGE' THEN -1 ELSE 1 END) + isnull(Discount,0) + isnull(NetShippingRevenue,0)) ELSE 0 END) ,
		
		RefundValue	 =		SUM(
								CASE WHEN  TransactionType in ('Refund','RefundCancellation')
								THEN (	isnull(GrossPrice,0) + (isnull(TaxPrice,0)*CASE WHEN pl.Source = 'SGE' THEN -1 ELSE 1 END) + isnull(Discount,0) + isnull(NetShippingRevenue,0)) ELSE 0 END
								*CASE WHEN pl.Source = 'SGE' THEN -1 ELSE 1 END
								) ,

			SUM(
				CASE WHEN TransactionType in ('OrderInvoice','Invoice') AND ISNULL(ReasonForRejections,'')='' THEN (isnull(GrossPrice,0)+ isnull(TaxPrice,0) + isnull(Discount,0) + isnull(NetShippingRevenue,0)) ELSE 0 END
			) InvoiceValuePRD
			,		SUM(CASE WHEN TransactionType in ('Order','OrderInvoice') AND ISNULL(ReasonForRejections,'')='' THEN (isnull(GrossPrice,0)+ isnull(TaxPrice,0) + isnull(Discount,0) + isnull(NetShippingRevenue,0)) ELSE 0 END) GrossOrderValue

	FROM [PL].[PL_V_SALES_TRANSACTIONS] pl
		INNER JOIN  PL.PL_V_SALES_TRANSACTION_TYPE typ on typ.TransactionTypeID= pl.TransactionTypeID
		AND TransactionType in ('Order','OrderInvoice','Refund','RefundCancellation','Invoice')
	where 1=1
	--AND	source = 'SAP'
	--and processid = '16181940'
	GROUP BY ProcessID

)
,CTE_UNRELATED_REFUNDS AS
(
	SELECT 
		[TransactionMonth]= DATEADD(DAY,1,EOMONTH(TransactionDate,-1)),
		EarliestTransactionMonth=MIN(DATEADD(DAY,1,EOMONTH(TransactionDate,-1))),
		RefundDate = MIN(CASE WHEN TransactionType in ('Refund','RefundCancellation') THEN  DATEADD(DAY,1,EOMONTH(TransactionDate,-1)) ELSE '2999-01-01' END),
	--	Source,
		pl.ProcessID,
		ItemID,
		InvoiceCountry = ISNULL(pl.InvoiceCountry,ctr.InvoiceCountry),
		DeliveryCountry = ISNULL(pl.DeliveryCountry,ctr.DeliveryCountry),
		ChannelId,
		GrossOrderValue = SUM(
								CASE WHEN TransactionType in ('Order','OrderInvoice') AND ISNULL(ReasonForRejections,'')='' 
										THEN (	isnull(GrossPrice,0) + (isnull(TaxPrice,0)*CASE WHEN pl.Source = 'SGE' THEN -1 ELSE 1 END) + isnull(Discount,0) + isnull(NetShippingRevenue,0)) ELSE 0 END),


		OrderQuantity = SUM(CASE WHEN TransactionType in ('Order','OrderInvoice') AND ISNULL(ReasonForRejections,'')='' THEN Quantity ELSE 0 END) ,

		InvoiceValue = SUM(
				CASE WHEN TransactionType in ('OrderInvoice','Invoice') AND ISNULL(ReasonForRejections,'')='' THEN (isnull(GrossPrice,0)+ isnull(TaxPrice,0) + isnull(Discount,0) + isnull(NetShippingRevenue,0)) ELSE 0 END) ,
		RefundValue	 =		SUM(
								CASE WHEN  TransactionType in ('Refund','RefundCancellation')
								THEN (	isnull(GrossPrice,0) + (isnull(TaxPrice,0)*CASE WHEN pl.Source = 'SGE' THEN -1 ELSE 1 END) + isnull(Discount,0) + isnull(NetShippingRevenue,0)) ELSE 0 END
								*CASE WHEN pl.Source = 'SGE' THEN -1 ELSE 1 END
								) ,

		FullRefundValue =SUM(
								CASE WHEN   (abs(process.GrossOrderValuePRD) - abs(process.RefundValue))< 1 THEN 
									CASE WHEN  TransactionType in ('Refund','RefundCancellation')
										THEN (	isnull(GrossPrice,0) + (isnull(TaxPrice,0)*CASE WHEN pl.Source = 'SGE' THEN -1 ELSE 1 END) + isnull(Discount,0) + isnull(NetShippingRevenue,0)) ELSE 0 END
								ELSE 0 END	*CASE WHEN pl.Source = 'SGE' THEN -1 ELSE 1 END
) ,
		FilteredRefundValue = SUM(
								CASE WHEN   (abs(process.GrossOrderValuePRD) - abs(process.RefundValue))> 1 THEN 
									CASE WHEN  TransactionType in ('Refund','RefundCancellation')
										THEN (	isnull(GrossPrice,0) + (isnull(TaxPrice,0)*CASE WHEN pl.Source = 'SGE' THEN -1 ELSE 1 END) + isnull(Discount,0) + isnull(NetShippingRevenue,0)) ELSE 0 END
								ELSE 0 END	*CASE WHEN pl.Source = 'SGE' THEN -1 ELSE 1 END
) 
	FROM	[PL].[PL_V_SALES_TRANSACTIONS] pl
	INNER JOIN  PL.PL_V_SALES_TRANSACTION_TYPE typ on typ.TransactionTypeID= pl.TransactionTypeID
	LEFT JOIN CTE_PROCESSID_VALUES process on process.ProcessID = pl.ProcessId
	LEFT JOIN CTE_COUNTRY ctr on ctr.ProcessId = pl.Processid and pl.Source = 'SAP'
	where 1=1
		--AND YEAR(transactiondate) = 2023
		--AND MONTH(transactiondate) = 1
		AND TransactionType in ('Order','OrderInvoice','Refund','RefundCancellation')
		AND TransactionTypeCode not in ('IVS#FKART') --- intercompany
		--AND Source = 'SAP'	
		--	and pl.processid = '16181940'

	GROUP BY 
			DATEADD(DAY,1,EOMONTH(TransactionDate,-1)),
			ItemID,
			ISNULL(pl.InvoiceCountry,ctr.InvoiceCountry),
			ChannelId,
			pl.ProcessID,
			--,source
			ISNULL(pl.DeliveryCountry,ctr.DeliveryCountry)

),


 CTE_RELATED_REFUNDS AS 
(
		SELECT 
		[TransactionMonth]= DATEADD(DAY,1,EOMONTH(ISNULL(ProcessIdDate,vahdr.ERDAT),-1)),
		EarliestTransactionMonth=MIN(DATEADD(DAY,1,EOMONTH(TransactionDate,-1))),
		RefundDate = MIN(CASE WHEN TransactionType in ('Refund','RefundCancellation') THEN  DATEADD(DAY,1,EOMONTH(TransactionDate,-1)) ELSE '2999-01-01' END),
		pl.ProcessID,
		ItemID,
		InvoiceCountry = ISNULL(pl.InvoiceCountry,ctr.InvoiceCountry),
		DeliveryCountry = ISNULL(pl.DeliveryCountry,ctr.DeliveryCountry),
		ChannelId,
		RefundValue	 =		SUM(
								CASE WHEN  TransactionType in ('Refund','RefundCancellation')
								THEN (	isnull(GrossPrice,0) + (isnull(TaxPrice,0)*CASE WHEN pl.Source = 'SGE' THEN -1 ELSE 1 END) + isnull(Discount,0) + isnull(NetShippingRevenue,0)) ELSE 0 END
								*CASE WHEN pl.Source = 'SGE' THEN -1 ELSE 1 END
								) ,
		FullRefundValue =SUM(
								CASE WHEN   (abs(process.GrossOrderValuePRD) - abs(process.RefundValue))< 1 THEN 
									CASE WHEN  TransactionType in ('Refund','RefundCancellation')
										THEN (	isnull(GrossPrice,0) + (isnull(TaxPrice,0)*CASE WHEN pl.Source = 'SGE' THEN -1 ELSE 1 END) + isnull(Discount,0) + isnull(NetShippingRevenue,0)) ELSE 0 END
								ELSE 0 END*CASE WHEN pl.Source = 'SGE' THEN -1 ELSE 1 END) ,
		FilteredRefundValue = SUM(
								CASE WHEN   (abs(process.GrossOrderValuePRD) - abs(process.RefundValue))> 1 THEN 
									CASE WHEN  TransactionType in ('Refund','RefundCancellation')
										THEN (	isnull(GrossPrice,0) + (isnull(TaxPrice,0)*CASE WHEN pl.Source = 'SGE' THEN -1 ELSE 1 END) + isnull(Discount,0) + isnull(NetShippingRevenue,0)) ELSE 0 END
								ELSE 0 END*CASE WHEN pl.Source = 'SGE' THEN -1 ELSE 1 END) 
	FROM
	[PL].[PL_V_SALES_TRANSACTIONS] pl
	INNER JOIN  PL.PL_V_SALES_TRANSACTION_TYPE typ on typ.TransactionTypeID= pl.TransactionTypeID
	LEFT JOIN CTE_PROCESSID_VALUES process on process.ProcessID = pl.ProcessId
	LEFT JOIN l0.l0_s4hana_2lis_11_vahdr vahdr on vahdr.vbeln = pl.ProcessID and pl.source ='SAP'
	LEFT JOIN CTE_COUNTRY ctr on ctr.ProcessId = pl.Processid and pl.Source = 'SAP'
	where 1=1
		--AND YEAR(transactiondate) = 2023
		--AND MONTH(transactiondate) = 1
		AND TransactionType in ('Refund','RefundCancellation','OrderInvoice')
		AND TransactionTypeCode not in ('IVS#FKART') --- intercompany
	--	AND Source = 'SAP'	
	GROUP BY 
		DATEADD(DAY,1,EOMONTH(ISNULL(ProcessIdDate,vahdr.ERDAT),-1)),
		ItemID,
		ISNULL(pl.InvoiceCountry,ctr.InvoiceCountry),
		ChannelId,
		pl.ProcessID,
		--,source
		ISNULL(pl.DeliveryCountry,ctr.DeliveryCountry)


)


SELECT 
	
	[TransactionMonth],
	ch.ChannelId,
	ItemID,
	InvoiceCountry,
	DeliveryCountry,
	----RelatedRefundDate,
	----UnrelatedRefundDate,
	--ProcessID,
	--ProcessID,
	sum(GrossOrderValue) OrderValue,
	sum(OrderQuantity) OrderQuantity,
	sum(RelatedRefunds)RelatedRefunds,
	sum(UnrelatedRefunds)UnrelatedRefunds,
	--sum(InvoiceValue)InvoiceValue,
	sum(UnrelatedFullRefundValue)UnrelatedFullRefundValue,
	sum(UnrelatedFilteredRefundValue)UnrelatedFilteredRefundValue,
	SUM(RelatedFullRefundValue)RelatedFullRefundValue,
	SUM(RelatedFilteredRefundValue)RelatedFilteredRefundValue
--	sum(UnrelatedReplacementQty)UnrelatedReplacementQty,
--	sum(RelatedReplacementQty)RelatedReplacementQty
	FROM  (

		SELECT
				[TransactionMonth] = ISNULL(nov.[TransactionMonth],ref.[TransactionMonth]),
				--Source = ISNULL(nov.Source,ref.Source),
				ItemID = ISNULL(nov.ItemID,ref.ItemID), 
				ProcessID = isnull(nov.ProcessID,ref.ProcessID),
				InvoiceCountry =ISNULL(nov.InvoiceCountry,ref.InvoiceCountry),
				DeliveryCountry = ISNULL(nov.DeliveryCountry,ref.DeliveryCountry),
				ChannelId = ISNULL(nov.ChannelId,ref.ChannelId),
				nov.GrossOrderValue,
				nov.OrderQuantity,
				UnrelatedRefunds = CASE WHEN ref.REfundValue<> 0 THEN  0 ELSE nov.RefundValue END,
				RelatedRefunds = ref.RefundValue,
--				InvoiceValue = nov.InvoiceValue,
				UnrelatedFullRefundValue =  CASE WHEN ref.REfundValue<> 0 THEN  0 ELSE nov.FullRefundValue END,
				UnrelatedFilteredRefundValue = CASE WHEN ref.REfundValue<> 0 THEN  0 ELSE nov.FilteredRefundValue END,
				RelatedFullRefundValue =  ref.FullRefundValue,
				RelatedFilteredRefundValue = ref.FilteredRefundValue,
			--	UnrelatedReplacementQty = nov.ReplacementQty,
			--	RelatedReplacementQty = ref.ReplacementQty,
				UnrelatedRefundDate =  nov.RefundDate,
				RelatedRefundDate =  ref.RefundDate
		FROM CTE_UNRELATED_REFUNDS nov
		Full join CTE_RELATED_REFUNDS ref
			on  nov.[TransactionMonth] = ref.[TransactionMonth]
			 --AND   nov.Source = ref.Source
			 AND	nov.InvoiceCountry = ref.InvoiceCountry 
			 AND	nov.DeliveryCountry = ref.DeliveryCountry 
			 AND	nov.ChannelId = ref.ChannelId
			 AND	nov.ItemID = ref.ItemID
			 AND	nov.ProcessID = ref.ProcessID
			 AND	nov.RefundDate = ref.RefundDate
		--order by 1

) refunds
LEFT JOIN PL.PL_V_SALES_CHANNEL ch 
		ON ch.ChannelId = refunds.ChannelId
where 1=1
--AND ProcessID in('0400331293','0402928052','0400331293','0402928052')  --- '0400331293','0402928052'
	--	and (RelatedRefunds<> 0 OR UnrelatedRefunds <> 0)
	--AND YEAR([TransactionMonth]) = 2023

Group by 
[TransactionMonth]
,ItemID
,InvoiceCountry
,ch.ChannelId
,DeliveryCountry;
GO


