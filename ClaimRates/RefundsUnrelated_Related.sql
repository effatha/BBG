/*******************************************************************
** TransctionTypes
	REFUNDS SAGE: VCA,VCC,VCD,VCF,VCG,VCJ,VCM,VCP,VCR,VCV,VFG,VFL
	REFUNDS SAP: G2,S2,ZG2,ZG3
*******************************************************************/


;WITH CTE_COUNTRY AS (

	SELECT DISTINCT ProcessId,InvoiceCountry from [PL].[PL_V_SALES_TRANSACTIONS] WHERE Source= 'SAP' and InvoiceCountry is not null
)
,CTE_PROCESSID_VALUES AS (
	
	SELECT 
		ProcessID,SUM(CASE WHEN TransactionType in ('Order','OrderInvoice') AND ISNULL(ReasonForRejections,'')='' THEN (isnull(GrossPrice,0)+ isnull(TaxPrice,0) - isnull(Discount,0) + isnull(NetShippingRevenue,0)) ELSE 0 END) GrossOrderValuePRD,
			SUM(CASE WHEN  TransactionType in ('Refund','RefundCancellation')
			THEN (isnull(GrossPrice,0)- isnull(TaxPrice,0) - isnull(Discount,0) + isnull(NetShippingRevenue,0)) * CASE WHEN pl.Source = 'SGE' THEN -1 ELSE 1 END ELSE 0 END) RefundValue,

			SUM(
				CASE WHEN TransactionType in ('OrderInvoice','Invoice') AND ISNULL(ReasonForRejections,'')='' THEN (isnull(GrossPrice,0)+ isnull(TaxPrice,0) - isnull(Discount,0) + isnull(NetShippingRevenue,0)) ELSE 0 END
			) InvoiceValuePRD
	FROM [PL].[PL_V_SALES_TRANSACTIONS] pl
		INNER JOIN  PL.PL_V_SALES_TRANSACTION_TYPE typ on typ.TransactionTypeID= pl.TransactionTypeID
		AND TransactionType in ('Order','OrderInvoice','Refund','RefundCancellation','Invoice')
	where 
		source = 'SAP'
	GROUP BY ProcessID

)
,CTE_UNRELATED_REFUNDS AS
(
	SELECT 
		[TransactionMonth]= DATEADD(DAY,1,EOMONTH(TransactionDate,-1)),
		EarliestTransactionMonth=MIN(DATEADD(DAY,1,EOMONTH(TransactionDate,-1))),
	--	Source,
		pl.ProcessID,
		ItemID,
		ISNULL(pl.InvoiceCountry,ctr.InvoiceCountry)InvoiceCountry,
		ChannelId,
		SUM(CASE WHEN TransactionType in ('Order','OrderInvoice') AND ISNULL(ReasonForRejections,'')='' THEN (isnull(GrossPrice,0)+ isnull(TaxPrice,0) - isnull(Discount,0) + isnull(NetShippingRevenue,0)) ELSE 0 END) GrossOrderValue,
		SUM(CASE WHEN TransactionType in ('Order','OrderInvoice') AND ISNULL(ReasonForRejections,'')='' THEN Quantity ELSE 0 END) OrderQuantity,

		SUM(
				CASE WHEN TransactionType in ('OrderInvoice','Invoice') AND ISNULL(ReasonForRejections,'')='' THEN (isnull(GrossPrice,0)+ isnull(TaxPrice,0) - isnull(Discount,0) + isnull(NetShippingRevenue,0)) ELSE 0 END
			) InvoiceValue,
		SUM(CASE WHEN  TransactionType in ('Refund','RefundCancellation')
			THEN (isnull(GrossPrice,0)- isnull(TaxPrice,0) - isnull(Discount,0) + isnull(NetShippingRevenue,0)) * CASE WHEN pl.Source = 'SGE' THEN -1 ELSE 1 END ELSE 0 END) RefundValue,
		SUM(
			CASE WHEN  abs(process.InvoiceValuePRD) = abs(process.RefundValue) THEN 
								CASE WHEN  TransactionType in ('Refund','RefundCancellation')
										THEN (isnull(GrossPrice,0)+ isnull(TaxPrice,0) - isnull(Discount,0) + isnull(NetShippingRevenue,0)) 
										* CASE WHEN pl.Source = 'SGE' THEN -1 ELSE 1 END  ELSE 0 END
				ELSE 0 END
			) FullRefundValue,
		SUM(
			CASE WHEN  abs(process.InvoiceValuePRD) <> abs(process.RefundValue) THEN 
								CASE WHEN  TransactionType in ('Refund','RefundCancellation')
										THEN (isnull(GrossPrice,0)+ isnull(TaxPrice,0) - isnull(Discount,0) + isnull(NetShippingRevenue,0)) 
										* CASE WHEN pl.Source = 'SGE' THEN -1 ELSE 1 END  ELSE 0 END
				ELSE 0 END
			) FilteredRefundValue,
			SUM(
			
								CASE WHEN  TransactionType in ('Replace')
										THEN (isnull(Quantity,0)) ELSE 0 END
				
			) ReplacementQty
	FROM	[PL].[PL_V_SALES_TRANSACTIONS] pl
	INNER JOIN  PL.PL_V_SALES_TRANSACTION_TYPE typ on typ.TransactionTypeID= pl.TransactionTypeID
	LEFT JOIN CTE_PROCESSID_VALUES process on process.ProcessID = pl.ProcessId
	LEFT JOIN CTE_COUNTRY ctr on ctr.ProcessId = pl.Processid and pl.Source = 'SAP'
	where 1=1
		AND YEAR(transactiondate) = 2023
	--	AND MONTH(transactiondate) = 5
		AND TransactionType in ('Order','OrderInvoice','Refund','RefundCancellation','Invoice','Replace')
		AND TransactionTypeCode not in ('IVS#FKART') --- intercompany
		AND Source = 'SAP'	
	GROUP BY DATEADD(DAY,1,EOMONTH(TransactionDate,-1)),ItemID,ISNULL(pl.InvoiceCountry,ctr.InvoiceCountry),ChannelId,pl.ProcessID--,source

),
 CTE_RELATED_REFUNDS AS 
(
		SELECT 
		[TransactionMonth]= DATEADD(DAY,1,EOMONTH(ISNULL(ProcessIdDate,vahdr.ERDAT),-1)),
		EarliestTransactionMonth=MIN(DATEADD(DAY,1,EOMONTH(TransactionDate,-1))),
	--	Source,
			pl.ProcessID,

		ItemID,
		ISNULL(pl.InvoiceCountry,ctr.InvoiceCountry)InvoiceCountry,
		ChannelId,
		SUM(
				CASE WHEN TransactionType in ('Refund','RefundCancellation') THEN (isnull(GrossPrice,0)+ isnull(TaxPrice,0) - isnull(Discount,0) + isnull(NetShippingRevenue,0)) *CASE WHEN pl.Source = 'SGE' THEN -1 ELSE 1 END
					ELSE 0 END
			) RefundValue,
		SUM(
			CASE WHEN  abs(process.InvoiceValuePRD) = abs(process.RefundValue) THEN 
								CASE WHEN  TransactionType in ('Refund','RefundCancellation')
										THEN (isnull(GrossPrice,0)+ isnull(TaxPrice,0) - isnull(Discount,0) + isnull(NetShippingRevenue,0)) 
										* CASE WHEN pl.Source = 'SGE' THEN -1 ELSE 1 END  ELSE 0 END
				ELSE 0 END
			) FullRefundValue,
		SUM(
			CASE WHEN  abs(process.InvoiceValuePRD) <> abs(process.RefundValue) THEN 
								CASE WHEN  TransactionType in ('Refund','RefundCancellation')
										THEN (isnull(GrossPrice,0)+ isnull(TaxPrice,0) - isnull(Discount,0) + isnull(NetShippingRevenue,0)) 
										* CASE WHEN pl.Source = 'SGE' THEN -1 ELSE 1 END  ELSE 0 END
				ELSE 0 END
			) FilteredRefundValue,
		SUM(
			
								CASE WHEN  TransactionType in ('Replace')
										THEN (isnull(Quantity,0)) ELSE 0 END
				
			) ReplacementQty
	FROM
	[PL].[PL_V_SALES_TRANSACTIONS] pl
	INNER JOIN  PL.PL_V_SALES_TRANSACTION_TYPE typ on typ.TransactionTypeID= pl.TransactionTypeID
	LEFT JOIN CTE_PROCESSID_VALUES process on process.ProcessID = pl.ProcessId
	LEFT JOIN l0.l0_s4hana_2lis_11_vahdr vahdr on vahdr.vbeln = pl.ProcessID and pl.source ='SAP'
	LEFT JOIN CTE_COUNTRY ctr on ctr.ProcessId = pl.Processid and pl.Source = 'SAP'
	where 1=1
		AND YEAR(transactiondate) = 2023
	--	AND MONTH(transactiondate) = 5
		AND TransactionType in ('Refund','RefundCancellation','OrderInvoice','Invoice','Replace')
		AND TransactionTypeCode not in ('IVS#FKART') --- intercompany
		AND Source = 'SAP'	
	GROUP BY DATEADD(DAY,1,EOMONTH(ISNULL(ProcessIdDate,vahdr.ERDAT),-1)),ItemID,ISNULL(pl.InvoiceCountry,ctr.InvoiceCountry),ChannelId,pl.ProcessID--,source

)


SELECT 
	
	[TransactionMonth],
	ch.ChannelId,
	ItemID,
	InvoiceCountry,
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
				ChannelId = ISNULL(nov.ChannelId,ref.ChannelId),
				nov.GrossOrderValue,
				nov.OrderQuantity,
				UnrelatedRefunds = nov.RefundValue,
				RelatedRefunds = ref.RefundValue,
				InvoiceValue = nov.InvoiceValue,
				UnrelatedFullRefundValue =  nov.FullRefundValue,
				UnrelatedFilteredRefundValue = nov.FilteredRefundValue,
				RelatedFullRefundValue =  ref.FullRefundValue,
				RelatedFilteredRefundValue = ref.FilteredRefundValue,
				UnrelatedReplacementQty = nov.ReplacementQty,
				RelatedReplacementQty = ref.ReplacementQty
		FROM CTE_UNRELATED_REFUNDS nov
		Full join CTE_RELATED_REFUNDS ref
			on  nov.[TransactionMonth] = ref.[TransactionMonth]
			 --AND   nov.Source = ref.Source
			 AND	nov.InvoiceCountry = ref.InvoiceCountry 
			 AND	nov.ChannelId = ref.ChannelId
			 AND	nov.ItemID = ref.ItemID
			 AND	nov.ProcessID = ref.ProcessID
		--order by 1

) refunds
LEFT JOIN PL.PL_V_SALES_CHANNEL ch 
		ON ch.ChannelId = refunds.ChannelId
where 
	YEAR([TransactionMonth])=2023
Group by 
[TransactionMonth]
--,ProcessID
	--,SalesOffice
	--,Channel
	,ItemID
	,InvoiceCountry
	,ch.ChannelId


