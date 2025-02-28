/****** Object:  StoredProcedure [TEST].[WR_TX_L1__FACT_SALES_TRANSACTIONS_L1_FACT_A_RETURNS]    Script Date: 21/03/2024 17:26:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [TEST].[WR_TX_L1__FACT_SALES_TRANSACTIONS_L1_FACT_A_RETURNS] AS
BEGIN
 

 Declare @Processid nvarchar(50) = ''

;WITH CTE_COUNTRY AS (

	SELECT  ProcessId,InvoiceCountry,Max(isnull(DeliveryCountry,InvoiceCountry)) DeliveryCountry,RANK() OVER(partition by ProcessId ORDER BY min(TransactionDate) asc) rank_version
	FROM [PL].[PL_V_SALES_TRANSACTIONS]
	WHERE Source= 'SAP' and InvoiceCountry is not null 	and (PROCESSID = @Processid or @Processid = '')
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
	and (processid = @Processid or @Processid = '')
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
		 OrderReason = isnull(ordReason.Bezei,''),
		 CreationUserName = isnull(vaitm.ERNAM,''),
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
							WHEN CD_SALES_TRANSACTION_CATEGORY  in ('Return') AND pl.CD_SOURCE_SYSTEM = 'SGE' THEN (VL_ITEM_QUANTITY) 
							WHEN bf.KDAUF is not null THEN 1 
							ELSE 0 END) * -1


  FROM    [L1].L1_FACT_A_SALES_TRANSACTION_KPI pl
  INNER JOIN  L1.L1_DIM_A_SALES_TRANSACTION_TYPE typ 
			on typ.ID_SALES_TRANSACTION_TYPE= pl.ID_SALES_TRANSACTION_TYPE
  LEFT JOIN L0.L0_S4HANA_2LIS_13_VDHDR vdhdr 
				on vdhdr.vbeln = pl.CD_DOCUMENT_NO  AND vdhdr.VKORG = '1000' AND ZZ_RFBSK NOT IN ('E','B','K')
  LEFT JOIN L0.L0_S4HANA_2LIS_13_VDITM VITM 
				on VITM.vbeln = vdhdr.vbeln  AND VITM.POSNR = pl.CD_DOCUMENT_LINE
  LEFT JOIN CTE_COUNTRY ctr on ctr.ProcessId = pl.CD_SALES_PROCESS_ID and pl.CD_SOURCE_SYSTEM = 'SAP' and rank_version = 1
  LEFT JOIN  L0.L0_S4HANA_2LIS_11_VAITM VAITM 
				on vaitm.VBELN =  pl.CD_DOCUMENT_NO
				AND vaitm.POSNR = pl.[CD_DOCUMENT_LINE]
  LEFT JOIN L0.L0_S4HANA_2LIS_03_BF bf
		on bf.KDAUF = vaitm.VBELN
		AND bf.KDPOS = vaitm.POSNR
		AND bf.BWART = '657'
		AND bf.MJAHR > 2021
 LEFT JOIN L0.L0_S4HANA_0ORD_REASON_TEXT ordReason
	on 
		ordReason.AUGRU = vaitm.AUGRU
		AND ordReason.SPRAS ='E'

    where 1=1
		
		AND (CD_TYPE in ('G2','ZG2','ZG3','CBRE','S2') OR CD_SALES_TRANSACTION_CATEGORY in ('Refund','RefundCancellation','Replace','Return'))
		--AND CD_SALES_TRANSACTION_CATEGORY in ('Refund','RefundCancellation')
		--AND vdhdr.ZZ_BUCHK <> 'A'
       -- AND pl.CD_SOURCE_SYSTEM='SAP'
	   	and (pl.CD_SALES_PROCESS_ID = @Processid or @Processid = '')

    GROUP BY 
			 DATEADD(DAY,1,EOMONTH(CASE WHEN VITM.VBELN IS NULL THEN pl.D_CREATED ELSE VITM.FKDAT END,-1))
			  ,pl.CD_SOURCE_SYSTEM
			  ,CD_SALES_PROCESS_ID
			  ,ID_ITEM
			  , ISNULL(pl.[CD_COUNTRY_INVOICE],ctr.InvoiceCountry)
			  ,ISNULL(pl.[CD_COUNTRY_DELIVERY],ctr.DeliveryCountry)
			  ,ID_SALES_CHANNEL
			  ,isnull(ordReason.Bezei,'')
			  , isnull(vaitm.ERNAM,'')
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
		 OrderReason = isnull(ordReason.Bezei,''),
		 CreationUserName = isnull(vaitm.ERNAM,''),
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
							WHEN CD_SALES_TRANSACTION_CATEGORY  in ('Return') AND pl.CD_SOURCE_SYSTEM = 'SGE' THEN (VL_ITEM_QUANTITY) 
							WHEN bf.KDAUF is not null THEN 1 
							ELSE 0 END) * -1

  FROM    [L1].L1_FACT_A_SALES_TRANSACTION_KPI pl
  INNER JOIN  L1.L1_DIM_A_SALES_TRANSACTION_TYPE typ 
			on typ.ID_SALES_TRANSACTION_TYPE= pl.ID_SALES_TRANSACTION_TYPE
  LEFT JOIN L0.L0_S4HANA_2LIS_13_VDHDR vdhdr 
				on vdhdr.vbeln = pl.CD_DOCUMENT_NO AND vdhdr.VKORG = '1000' AND ZZ_RFBSK NOT IN ('E','B','K')
  LEFT JOIN L0.L0_S4HANA_2LIS_13_VDITM VITM 
				on VITM.vbeln = vdhdr.vbeln  AND VITM.POSNR = pl.CD_DOCUMENT_LINE
  LEFT JOIN l0.l0_s4hana_2lis_11_vahdr vahdr on vahdr.vbeln = pl.CD_SALES_PROCESS_ID and pl.CD_SOURCE_SYSTEM ='SAP'
  LEFT JOIN CTE_COUNTRY ctr on ctr.ProcessId = pl.CD_SALES_PROCESS_ID and pl.CD_SOURCE_SYSTEM = 'SAP' and rank_version = 1
  LEFT JOIN  L0.L0_S4HANA_2LIS_11_VAITM VAITM 
				on vaitm.VBELN =  pl.CD_DOCUMENT_NO
				AND vaitm.POSNR = pl.[CD_DOCUMENT_LINE]
 LEFT JOIN L0.L0_S4HANA_2LIS_03_BF bf
	on bf.KDAUF = vaitm.VBELN
	AND bf.KDPOS = vaitm.POSNR
	AND bf.BWART = '657'
	AND bf.MJAHR > 2021
	LEFT JOIN L0.L0_S4HANA_0ORD_REASON_TEXT ordReason
	on 
		ordReason.AUGRU = vaitm.AUGRU
		AND ordReason.SPRAS ='E'

    where 1=1
		AND (CD_TYPE in ('G2','ZG2','ZG3','CBRE','S2') OR CD_SALES_TRANSACTION_CATEGORY in ('Refund','RefundCancellation','Replace','Return'))
			   	and (pl.CD_SALES_PROCESS_ID = @Processid or @Processid = '')

    GROUP BY 
			  DATEADD(DAY,1,EOMONTH(ISNULL(pl.D_SALES_PROCESS,vahdr.ERDAT),-1))
			  ,pl.CD_SOURCE_SYSTEM
			  ,CD_SALES_PROCESS_ID
			  ,ID_ITEM
			  , ISNULL(pl.[CD_COUNTRY_INVOICE],ctr.InvoiceCountry)
			  ,ISNULL(pl.[CD_COUNTRY_DELIVERY],ctr.DeliveryCountry)
			  ,ID_SALES_CHANNEL
			  ,isnull(ordReason.Bezei,'')
			  , isnull(vaitm.ERNAM,'')
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
		 OrderReason = isnull(ordReason.Bezei,''),
		 CreationUserName = isnull(vaitm.ERNAM,''),
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
  LEFT JOIN CTE_COUNTRY ctr on ctr.ProcessId = pl.CD_SALES_PROCESS_ID and pl.CD_SOURCE_SYSTEM = 'SAP' and rank_version = 1
    LEFT JOIN  L0.L0_S4HANA_2LIS_11_VAITM VAITM 
				on vaitm.VBELN =  pl.CD_DOCUMENT_NO
				AND vaitm.POSNR = pl.[CD_DOCUMENT_LINE]
	LEFT JOIN L0.L0_S4HANA_0ORD_REASON_TEXT ordReason
	on 
		ordReason.AUGRU = vaitm.AUGRU
		AND ordReason.SPRAS ='E'

    where 1=1
		AND CD_SALES_TRANSACTION_CATEGORY in ('Order','OrderInvoice')
		AND ISNULL([T_CANCELLATION_REASON],'')=''
		and (pl.CD_SALES_PROCESS_ID = @Processid or @Processid = '')

    GROUP BY 
			 DATEADD(DAY,1,EOMONTH(ISNULL(pl.D_SALES_PROCESS,vahdr.ERDAT),-1))
			  ,pl.CD_SOURCE_SYSTEM
			  ,CD_SALES_PROCESS_ID
			  ,ID_ITEM
			  , ISNULL(pl.[CD_COUNTRY_INVOICE],ctr.InvoiceCountry)
			  ,ISNULL(pl.[CD_COUNTRY_DELIVERY],ctr.DeliveryCountry)
			  ,ID_SALES_CHANNEL
			  ,isnull(ordReason.Bezei,'')
			  , isnull(vaitm.ERNAM,'')
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
						OrderReason = ISNULL(unr.OrderReason,rel.OrderReason),
						CreationUserName = ISNULL(unr.CreationUserName,rel.CreationUserName),
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
				AND rel.OrderReason = unr.OrderReason
				AND rel.CreationUserName = unr.CreationUserName
)
INSERT INTO [TEST].[L1_FACT_A_RETURNS]
           ([D_TRANSACTION_MONTH]
           ,[CD_SOURCE_SYSTEM]
           ,[ID_ITEM]
           ,[CD_SALES_PROCESS_ID]
           ,[CD_COUNTRY_INVOICE]
           ,[CD_COUNTRY_DELIVERY]
           ,[ID_SALES_CHANNEL]
           ,[T_ORDER_REASON]
           ,[T_CREATION_USERNAME]
           ,[AMT_UNRELATED_REFUNDS_EUR]
           ,[AMT_UNRELATED_FULL_REFUND_EUR]
           ,[AMT_UNRELATED_FILTERED_REFUND_EUR]
           ,[AMT_RELATED_REFUNDS_EUR]
           ,[AMT_RELATED_FULL_REFUND_EUR]
           ,[AMT_RELATED_FILTERED_REFUND_EUR]
           ,[AMT_ORDER_VALUE_EUR]
           ,[VL_ORDER_QUANTITY]
           ,[VL_UNRELATED_REFUND_QUANTITY]
           ,[VL_RELATED_REFUND_QUANTITY]
           ,[VL_RELATED_FULL_REFUND_QUANTITY]
           ,[VL_RELATED_FILTERED_REFUND_QUANTITY]
           ,[VL_UNRELATED_REPLACE_QUANTITY]
           ,[VL_RELATED_REPLACE_QUANTITY]
           ,[VL_UNRELATED_RETURN_QUANTITY]
           ,[VL_RELATED_RETURN_QUANTITY])
   
SELECT 
				[TransactionMonth] = ISNULL(ref.[TransactionMonth],ord.[TransactionMonth]),
				Source = ISNULL(ref.Source,ord.Source),
				ItemID = ISNULL(ref.ItemID,ord.ItemID), 
				ProcessID = isnull(ref.ProcessID,ord.ProcessID),
				InvoiceCountry =ISNULL(ref.InvoiceCountry,ord.InvoiceCountry),
				DeliveryCountry = ISNULL(ref.DeliveryCountry,ord.DeliveryCountry),
				ChannelId = ISNULL(ref.ChannelId,ord.ChannelId),
				OrderReason = ISNULL(ref.OrderReason,ord.OrderReason),
				CreationUserName = ISNULL(ref.CreationUserName,ord.CreationUserName),
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
				RelatedFullRefundQuantity = CASE WHEN (isnull(ord.OrderQuantity,0) +  isnull(ref.RelatedRefundQuantity,0))<= 0 THEN  ref.RelatedRefundQuantity ELSE 0 END,
				RelatedFilteredRefundQuantity = CASE WHEN (isnull(ord.OrderQuantity,0) +  isnull(ref.RelatedRefundQuantity,0))> 0 THEN  ref.RelatedRefundQuantity ELSE 0 END,
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
		AND ord.OrderReason = ref.OrderReason
		AND ord.CreationUserName = ref.CreationUserName















END
