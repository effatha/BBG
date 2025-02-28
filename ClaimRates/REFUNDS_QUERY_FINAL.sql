/*******************************************************************
** Billing Status: ZZ_RFBSK
	'E' - Billijng document cancelled
	'B' - Posting document not created (account determ.error)
	'K' - Journal entry not created (pricing error)
*******************************************************************/
/*******************************************************************
** TransctionTypes
	REFUNDS SAGE: VCA,VCC,VCD,VCF,VCG,VCJ,VCM,VCP,VCR,VCV,VFG,VFL
	REFUNDS SAP: G2,S2,ZG2,ZG3
*******************************************************************/


;WITH CTE_COUNTRY AS (

	SELECT  ProcessId,InvoiceCountry,Max(isnull(DeliveryCountry,InvoiceCountry)) DeliveryCountry
	FROM [PL].[PL_V_SALES_TRANSACTIONS]
	WHERE Source= 'SAP' and InvoiceCountry is not null
	GROUP BY ProcessId,InvoiceCountry
),
CTE_PROCESSID_VALUES AS (
	
	SELECT 
		ProcessID,ItemID,ChannelId,Source,
		---Value Tax in Sage is positive and in sap  is negative. for the math to work we need to invert the signal if the tax is from sage order
		GrossOrderValue = SUM(
								CASE WHEN TransactionType in ('Order','OrderInvoice') AND ISNULL(ReasonForRejections,'')='' 
								THEN (	isnull(GrossPrice,0) + (isnull(TaxPrice,0)*CASE WHEN pl.Source = 'SGE' THEN -1 ELSE 1 END) + isnull(Discount,0) + isnull(NetShippingRevenue,0)) ELSE 0 END)	
	FROM [PL].[PL_V_SALES_TRANSACTIONS] pl
		INNER JOIN  PL.PL_V_SALES_TRANSACTION_TYPE typ on typ.TransactionTypeID= pl.TransactionTypeID
		AND TransactionType in ('Order','OrderInvoice')
	where 1=1
	--AND	source = 'SAP'
	--and processid = '16181940'
	GROUP BY ProcessID,ItemID,ChannelId, source

),
CTE_UNRELATED_REFUNDS AS 
(
	    SELECT 
         [TransactionMonth] =  DATEADD(DAY,1,EOMONTH(CASE WHEN VITM.VBELN IS NULL THEN pl.D_CREATED ELSE VITM.FKDAT END,-1)),
		 ProcessID = pl.CD_SALES_PROCESS_ID,
		 ItemID = pl.ID_ITEM,
		 Source = pl.CD_SOURCE_SYSTEM,
		 InvoiceCountry = ISNULL(pl.[CD_COUNTRY_INVOICE],ctr.InvoiceCountry),
		 DeliveryCountry = ISNULL(pl.[CD_COUNTRY_DELIVERY],ctr.DeliveryCountry),
		 ChannelId = ID_SALES_CHANNEL,
		 RefundValue =  SUM(CASE 
							WHEN CD_SALES_TRANSACTION_CATEGORY  in ('Refund','RefundCancellation') 
									THEN (
									isnull(AMT_GROSS_PRICE_EUR,0) + 
									(isnull(AMT_TAX_PRICE_EUR,0) *CASE WHEN pl.CD_SOURCE_SYSTEM = 'SGE' THEN -1 ELSE 1 END) + 
									isnull(AMT_NET_DISCOUNT_EUR,0) + 
									isnull(AMT_NET_SHIPPING_REVENUE_EUR,0)
								)*CASE WHEN pl.CD_SOURCE_SYSTEM = 'SGE' THEN -1 ELSE 1 END
							ELSE 0 END) ,
		RefundQuantity = SUM(CASE 
							WHEN CD_SALES_TRANSACTION_CATEGORY  in ('Refund','RefundCancellation') 
									THEN (VL_ITEM_QUANTITY) * CASE WHEN pl.CD_SOURCE_SYSTEM = 'SGE' THEN -1 ELSE 1 END
							ELSE 0 END),
		ReplaceQuantity = SUM(CASE 
							WHEN CD_SALES_TRANSACTION_CATEGORY  in ('Replace') 
									THEN (VL_ITEM_QUANTITY) * CASE WHEN pl.CD_SOURCE_SYSTEM = 'SGE' THEN -1 ELSE 1 END
							ELSE 0 END),
		ReturnQuantity = SUM(CASE 
							WHEN CD_SALES_TRANSACTION_CATEGORY  in ('Return') 
									THEN (VL_ITEM_QUANTITY) * CASE WHEN pl.CD_SOURCE_SYSTEM = 'SGE' THEN -1 ELSE 1 END
							ELSE 0 END)
  FROM    [L1].L1_FACT_A_SALES_TRANSACTION_KPI pl
  INNER JOIN  L1.L1_DIM_A_SALES_TRANSACTION_TYPE typ 
			on typ.ID_SALES_TRANSACTION_TYPE= pl.ID_SALES_TRANSACTION_TYPE
  LEFT JOIN L0.L0_S4HANA_2LIS_13_VDHDR vdhdr 
				on vdhdr.vbeln = pl.CD_DOCUMENT_NO  AND vdhdr.VKORG = '1000' AND ZZ_RFBSK NOT IN ('E','B','K')
  LEFT JOIN L0.L0_S4HANA_2LIS_13_VDITM VITM 
				on VITM.vbeln = vdhdr.vbeln  AND VITM.POSNR = pl.CD_DOCUMENT_LINE
  LEFT JOIN CTE_COUNTRY ctr on ctr.ProcessId = pl.CD_SALES_PROCESS_ID and pl.CD_SOURCE_SYSTEM = 'SAP'

    where 1=1
        AND YEAR(DATEADD(DAY,1,EOMONTH(CASE WHEN VITM.VBELN IS NULL THEN pl.D_CREATED ELSE VITM.FKDAT END,-1))) = 2023
		AND MONTH(DATEADD(DAY,1,EOMONTH(CASE WHEN VITM.VBELN IS NULL THEN pl.D_CREATED ELSE VITM.FKDAT END,-1))) = 9
		
		AND (CD_TYPE in ('G2','ZG2','ZG3','CBRE','S2') OR CD_SALES_TRANSACTION_CATEGORY in ('Refund','RefundCancellation','Replace','Return'))
		--AND CD_SALES_TRANSACTION_CATEGORY in ('Refund','RefundCancellation')
		--AND vdhdr.ZZ_BUCHK <> 'A'
       -- AND pl.CD_SOURCE_SYSTEM='SAP'
    GROUP BY 
			 DATEADD(DAY,1,EOMONTH(CASE WHEN VITM.VBELN IS NULL THEN pl.D_CREATED ELSE VITM.FKDAT END,-1))
			  ,pl.CD_SOURCE_SYSTEM
			  ,CD_SALES_PROCESS_ID
			  ,ID_ITEM
			  , ISNULL(pl.[CD_COUNTRY_INVOICE],ctr.InvoiceCountry)
			  ,ISNULL(pl.[CD_COUNTRY_DELIVERY],ctr.DeliveryCountry)
			  ,ID_SALES_CHANNEL
	HAVING abs(SUM(
								isnull(AMT_GROSS_PRICE_EUR,0) + 
								(isnull(AMT_TAX_PRICE_EUR,0) *CASE WHEN pl.CD_SOURCE_SYSTEM = 'SGE' THEN -1 ELSE 1 END) + 
								isnull(AMT_NET_DISCOUNT_EUR,0) + 
								isnull(AMT_NET_SHIPPING_REVENUE_EUR,0)
					)
				) > 0


),
CTE_RELATED_REFUNDS AS 
(
	    SELECT 
         [TransactionMonth] =  DATEADD(DAY,1,EOMONTH(ISNULL(pl.D_SALES_PROCESS,vahdr.ERDAT),-1)),
		 ProcessID = pl.CD_SALES_PROCESS_ID,
		 ItemID = pl.ID_ITEM,
		 Source = pl.CD_SOURCE_SYSTEM,
		 InvoiceCountry = ISNULL(pl.[CD_COUNTRY_INVOICE],ctr.InvoiceCountry),
		 DeliveryCountry = ISNULL(pl.[CD_COUNTRY_DELIVERY],ctr.DeliveryCountry),
		 ChannelId = ID_SALES_CHANNEL,
		 RefundValue =  SUM(CASE 
							WHEN CD_SALES_TRANSACTION_CATEGORY  in ('Refund','RefundCancellation') 
									THEN (
									isnull(AMT_GROSS_PRICE_EUR,0) + 
									(isnull(AMT_TAX_PRICE_EUR,0) *CASE WHEN pl.CD_SOURCE_SYSTEM = 'SGE' THEN -1 ELSE 1 END) + 
									isnull(AMT_NET_DISCOUNT_EUR,0) + 
									isnull(AMT_NET_SHIPPING_REVENUE_EUR,0)
								)*CASE WHEN pl.CD_SOURCE_SYSTEM = 'SGE' THEN -1 ELSE 1 END
							ELSE 0 END) ,
		RefundQuantity = SUM(CASE 
							WHEN CD_SALES_TRANSACTION_CATEGORY  in ('Refund','RefundCancellation') 
									THEN (VL_ITEM_QUANTITY) * CASE WHEN pl.CD_SOURCE_SYSTEM = 'SGE' THEN -1 ELSE 1 END
							ELSE 0 END),
		ReplaceQuantity = SUM(CASE 
							WHEN CD_SALES_TRANSACTION_CATEGORY  in ('Replace') 
									THEN (VL_ITEM_QUANTITY) * CASE WHEN pl.CD_SOURCE_SYSTEM = 'SGE' THEN -1 ELSE 1 END
							ELSE 0 END),
		ReturnQuantity = SUM(CASE 
							WHEN CD_SALES_TRANSACTION_CATEGORY  in ('Return') 
									THEN (VL_ITEM_QUANTITY) * CASE WHEN pl.CD_SOURCE_SYSTEM = 'SGE' THEN -1 ELSE 1 END
							ELSE 0 END)
  FROM    [L1].L1_FACT_A_SALES_TRANSACTION_KPI pl
  INNER JOIN  L1.L1_DIM_A_SALES_TRANSACTION_TYPE typ 
			on typ.ID_SALES_TRANSACTION_TYPE= pl.ID_SALES_TRANSACTION_TYPE
  LEFT JOIN L0.L0_S4HANA_2LIS_13_VDHDR vdhdr 
				on vdhdr.vbeln = pl.CD_DOCUMENT_NO AND vdhdr.VKORG = '1000' AND ZZ_RFBSK NOT IN ('E','B','K')
  LEFT JOIN L0.L0_S4HANA_2LIS_13_VDITM VITM 
				on VITM.vbeln = vdhdr.vbeln  AND VITM.POSNR = pl.CD_DOCUMENT_LINE
  LEFT JOIN l0.l0_s4hana_2lis_11_vahdr vahdr on vahdr.vbeln = pl.CD_SALES_PROCESS_ID and pl.CD_SOURCE_SYSTEM ='SAP'
  LEFT JOIN CTE_COUNTRY ctr on ctr.ProcessId = pl.CD_SALES_PROCESS_ID and pl.CD_SOURCE_SYSTEM = 'SAP'

    where 1=1
        AND YEAR( DATEADD(DAY,1,EOMONTH(ISNULL(pl.D_SALES_PROCESS,vahdr.ERDAT),-1))) = 2023
		AND MONTH( DATEADD(DAY,1,EOMONTH(ISNULL(pl.D_SALES_PROCESS,vahdr.ERDAT),-1))) = 9
		AND (CD_TYPE in ('G2','ZG2','ZG3','CBRE','S2') OR CD_SALES_TRANSACTION_CATEGORY in ('Refund','RefundCancellation','Replace','Return'))
    GROUP BY 
			  DATEADD(DAY,1,EOMONTH(ISNULL(pl.D_SALES_PROCESS,vahdr.ERDAT),-1))
			  ,pl.CD_SOURCE_SYSTEM
			  ,CD_SALES_PROCESS_ID
			  ,ID_ITEM
			  , ISNULL(pl.[CD_COUNTRY_INVOICE],ctr.InvoiceCountry)
			  ,ISNULL(pl.[CD_COUNTRY_DELIVERY],ctr.DeliveryCountry)
			  ,ID_SALES_CHANNEL
	HAVING abs(SUM(
								isnull(AMT_GROSS_PRICE_EUR,0) + 
								(isnull(AMT_TAX_PRICE_EUR,0) *CASE WHEN pl.CD_SOURCE_SYSTEM = 'SGE' THEN -1 ELSE 1 END) + 
								isnull(AMT_NET_DISCOUNT_EUR,0) + 
								isnull(AMT_NET_SHIPPING_REVENUE_EUR,0)
					)
				) > 0


),
CTE_ORDER_VALUE AS
(
	SELECT 
         [TransactionMonth] =  DATEADD(DAY,1,EOMONTH(ISNULL(pl.D_SALES_PROCESS,vahdr.ERDAT),-1)),
		 ProcessID = pl.CD_SALES_PROCESS_ID,
		 ItemID = pl.ID_ITEM,
		 Source = pl.CD_SOURCE_SYSTEM,
		 InvoiceCountry = ISNULL(pl.[CD_COUNTRY_INVOICE],ctr.InvoiceCountry),
		 DeliveryCountry = ISNULL(pl.[CD_COUNTRY_DELIVERY],ctr.DeliveryCountry),
		 ChannelId = ID_SALES_CHANNEL,
		 OrderQuantity= SUM(VL_ITEM_QUANTITY),
		 OrderValue = sum(
								isnull(AMT_GROSS_PRICE_EUR,0) + 
								(isnull(AMT_TAX_PRICE_EUR,0) *CASE WHEN pl.CD_SOURCE_SYSTEM = 'SGE' THEN -1 ELSE 1 END) + 
								isnull(AMT_NET_DISCOUNT_EUR,0) + 
								isnull(AMT_NET_SHIPPING_REVENUE_EUR,0)
							)
  FROM    [L1].L1_FACT_A_SALES_TRANSACTION_KPI pl
  INNER JOIN  L1.L1_DIM_A_SALES_TRANSACTION_TYPE typ 
			on typ.ID_SALES_TRANSACTION_TYPE= pl.ID_SALES_TRANSACTION_TYPE
  LEFT JOIN l0.l0_s4hana_2lis_11_vahdr vahdr 
			on vahdr.vbeln = pl.CD_SALES_PROCESS_ID and pl.CD_SOURCE_SYSTEM ='SAP'
  LEFT JOIN CTE_COUNTRY ctr on ctr.ProcessId = pl.CD_SALES_PROCESS_ID and pl.CD_SOURCE_SYSTEM = 'SAP'

    where 1=1
        AND YEAR(DATEADD(DAY,1,EOMONTH(ISNULL(pl.D_SALES_PROCESS,vahdr.ERDAT),-1))) = 2023
		AND MONTH(DATEADD(DAY,1,EOMONTH(ISNULL(pl.D_SALES_PROCESS,vahdr.ERDAT),-1))) = 9
		AND CD_SALES_TRANSACTION_CATEGORY in ('Order','OrderInvoice')
		AND ISNULL([T_CANCELLATION_REASON],'')=''
    GROUP BY 
			 DATEADD(DAY,1,EOMONTH(ISNULL(pl.D_SALES_PROCESS,vahdr.ERDAT),-1))
			  ,pl.CD_SOURCE_SYSTEM
			  ,CD_SALES_PROCESS_ID
			  ,ID_ITEM
			  , ISNULL(pl.[CD_COUNTRY_INVOICE],ctr.InvoiceCountry)
			  ,ISNULL(pl.[CD_COUNTRY_DELIVERY],ctr.DeliveryCountry)
			  ,ID_SALES_CHANNEL
	HAVING abs(SUM(
								isnull(AMT_GROSS_PRICE_EUR,0) + 
								(isnull(AMT_TAX_PRICE_EUR,0) *CASE WHEN pl.CD_SOURCE_SYSTEM = 'SGE' THEN -1 ELSE 1 END) + 
								isnull(AMT_NET_DISCOUNT_EUR,0) + 
								isnull(AMT_NET_SHIPPING_REVENUE_EUR,0)
					)
				) > 0

),

CTE_FINAL_REFUNDS AS (
		SELECT
						[TransactionMonth] = ISNULL(unr.[TransactionMonth],rel.[TransactionMonth]),
						Source = ISNULL(unr.Source,rel.Source),
						ItemID = ISNULL(unr.ItemID,rel.ItemID), 
						ProcessID = isnull(unr.ProcessID,rel.ProcessID),
						InvoiceCountry =ISNULL(unr.InvoiceCountry,rel.InvoiceCountry),
						DeliveryCountry = ISNULL(unr.DeliveryCountry,rel.DeliveryCountry),
						ChannelId = ISNULL(unr.ChannelId,rel.ChannelId),
						UnrelatedRefunds = CASE WHEN rel.RefundValue<> 0 THEN  0 ELSE unr.RefundValue END,
						UnrelatedRefundsAll = unr.RefundValue,
						RelatedRefunds = rel.RefundValue,
						UnrelatedRefundQuantity = unr.RefundQuantity,
						RelatedRefundQuantity = rel.RefundQuantity,
						UnrelatedReplaceQuantity = unr.ReplaceQuantity,
						RelatedReplaceQuantity = rel.ReplaceQuantity,
						UnrelatedReturnQuantity = unr.ReturnQuantity,
						RelatedReturnQuantity = rel.ReturnQuantity
		FROM CTE_UNRELATED_REFUNDS unr
		FULL JOIN CTE_RELATED_REFUNDS rel
				on 
					rel.ProcessID = unr.ProcessID
				AND	rel.[TransactionMonth] = unr.[TransactionMonth]
				AND	rel.ItemID = unr.ItemID
				AND	rel.Source = unr.Source
				AND rel.InvoiceCountry = unr.InvoiceCountry
				AND rel.DeliveryCountry = unr.DeliveryCountry
				AND rel.ChannelId = unr.ChannelId
)

SELECT 
				[TransactionMonth] = ISNULL(ref.[TransactionMonth],ord.[TransactionMonth]),
				Source = ISNULL(ref.Source,ord.Source),
				ItemID = ISNULL(ref.ItemID,ord.ItemID), 
				ProcessID = isnull(ref.ProcessID,ord.ProcessID),
				InvoiceCountry =ISNULL(ref.InvoiceCountry,ord.InvoiceCountry),
				DeliveryCountry = ISNULL(ref.DeliveryCountry,ord.DeliveryCountry),
				ChannelId = ISNULL(ref.ChannelId,ord.ChannelId),
				UnrelatedRefunds =ref.UnrelatedRefunds,
				UnrelatedFullRefundValue =	CASE WHEN prod.GrossOrderValue IS NULL OR ABS(isnull(ref.UnrelatedRefunds,0) + isnull(prod.GrossOrderValue,0)) <1 THEN ref.UnrelatedRefunds ELSE 0 END,
				UnrelatedFilteredRefundValue = CASE WHEN prod.GrossOrderValue IS NOT NULL AND ABS(isnull(ref.UnrelatedRefunds,0) + isnull(prod.GrossOrderValue,0)) >1 THEN  ref.UnrelatedRefunds ELSE 0 END,
				--UnrelatedRefundsAll = ref.UnrelatedRefundsAll,
				RelatedRefunds = ref.RelatedRefunds,
				RelatedFullRefundValue =	CASE WHEN prod.GrossOrderValue IS NULL OR ABS(isnull(ref.RelatedRefunds,0) + isnull(prod.GrossOrderValue,0)) <1 THEN  ref.RelatedRefunds ELSE 0 END,
				RelatedFilteredRefundValue = CASE WHEN prod.GrossOrderValue IS NOT NULL AND  ABS(isnull(ref.RelatedRefunds,0) + isnull(prod.GrossOrderValue,0)) >1 THEN  ref.RelatedRefunds ELSE 0 END,
				OrderValue = ord.OrderValue,
				OrderQuantity = ord.OrderQuantity,
				--GrossOrderValue = prod.GrossOrderValue,
				UnrelatedRefundQuantity = ref.UnrelatedRefundQuantity,
				RelatedRefundQuantity = ref.RelatedRefundQuantity,
				UnrelatedReplaceQuantity = ref.UnrelatedReplaceQuantity,
				RelatedReplaceQuantity = ref.RelatedReplaceQuantity,
				UnrelatedReturnQuantity = ref.UnrelatedReturnQuantity,
				RelatedReturnQuantity = ref.RelatedReturnQuantity
FROM CTE_FINAL_REFUNDS ref
LEFT JOIN CTE_PROCESSID_VALUES prod
	on 
		prod.ProcessID = ref.ProcessID
		AND prod.ItemID = ref.ItemID
		AND prod.ChannelId = ref.ChannelId
		AND	prod.Source = ref.Source

FULL JOIN CTE_ORDER_VALUE ord
		on 
			ord.ProcessID = ref.ProcessID
		AND	ord.[TransactionMonth] = ref.[TransactionMonth]
		AND	ord.ItemID = ref.ItemID
		AND	ord.Source = ref.Source
		AND ord.InvoiceCountry = ref.InvoiceCountry
		AND ord.DeliveryCountry = ref.DeliveryCountry
		AND ord.ChannelId = ref.ChannelId




-- select VL_ITEM_QUANTITY,* from L1.L1_FACT_A_SALES_TRANSACTION_KPI where CD_DOCUMENT_NO = '6301834889'

-- select [VKBUR],* from  l0.l0_s4hana_2lis_11_vaitm where vbeln = '0403856713'
-- select [VKBUR],* from  l0.l0_s4hana_2lis_13_vditm where vbeln = '6301834889'


