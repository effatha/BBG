SELECT min( [VALID_FROM])
 FROM [L0].[L0_MI_C_CS_COMMISSIONS_AMAZON_CATEGORY]



SELECT  
	TransactionYear, ChannelGroup3,
	SUM(NetOrderValueEst) NetOrderValueEst,
	SUM(RevenueEst) RevenueEst,
	SUM(FulfillmentOutboundEst) FulfillmentOutboundEst,
	[FulfillmentOutboundEst%] = sum(FulfillmentOutboundEst) / SUM(RevenueEst),
	[PC1%] = sum(PC1) / SUM(RevenueEst),
	[Marketing%] = Sum(ISNULL(MarketingShops,0)+ISNULL(MarketingAmazon,0)+ISNULL(MarketingMarketplacesEst,0)) / SUM(RevenueEst),
	[Commissions%] = Sum(ISNULL(CommissionsAmazonEst,0)-ISNULL(CommissionsAmazonRefundsEst,0)+ISNULL(CommissionsMarketplacesEst,0)-ISNULL(CommissionsMarketplacesRefundsEst,0)) / SUM(RevenueEst),
	[PC3%] = sum(PC3) / SUM(RevenueEst)
FROM PL.PL_V_SALES_TRANSACTIONS s
INNER JOIN PL.PL_V_SALES_CHANNEL ch on ch.Channelid = s.channelid
WHERE
	TransactionYear >= 2022
	and ChannelGroup3 in ('Amazon','Marketplaces WE','Shop We')
	and ISNULL(Incidentflag,'N') = 'N'
GROUP BY TransactionYear,ChannelGroup3 
order by 1 


with cte_sales AS
(
SELECT  
	TransactionYear, ChannelGroup1,
	SUM(NetOrderValueEst) NetOrderValueEst,
	SUM(RevenueEst) RevenueEst,
	[PC0] = sum(PC0),
	[PC1] = sum(PC1),
		[FulfillmentOutboundEst] = sum(FulfillmentOutboundEst),
	[Marketing] = Sum(ISNULL(MarketingShops,0)+ISNULL(MarketingAmazon,0)+ISNULL(MarketingMarketplacesEst,0)),
	[Commissions] = Sum(ISNULL(CommissionsAmazonEst,0)-ISNULL(CommissionsAmazonRefundsEst,0)+ISNULL(CommissionsMarketplacesEst,0)-ISNULL(CommissionsMarketplacesRefundsEst,0)) ,
	[PC3] = sum(PC3)
FROM PL.PL_V_SALES_TRANSACTIONS s
INNER JOIN PL.PL_V_SALES_CHANNEL ch on ch.Channelid = s.channelid
WHERE
	(TransactionYear >= 2023 OR SOURCE not in ('SAP','SGE'))
	and ChannelGroup1 in ('Amazon','Marketplaces WE','Shop We')
	and ISNULL(Incidentflag,'N') = 'N'
GROUP BY TransactionYear,ChannelGroup1

)
, cte_archive as
(
SELECT  
	TransactionYear, ChannelGroup1,
	SUM(NetOrderValueEst) NetOrderValueEst,
	SUM(RevenueEst) RevenueEst,
	[PC0] = sum(PC0),
	[PC1] = sum(PC1),
	[FulfillmentOutboundEst] = sum(FulfillmentOutboundEst),
--	[FulfillmentOutboundEst%] = sum(FulfillmentOutboundEst) / SUM(RevenueEst),
	[Marketing] = Sum(ISNULL(MarketingShops,0)+ISNULL(MarketingAmazon,0)+ISNULL(MarketingMarketplacesEst,0)),
	[Commissions] = Sum(ISNULL(CommissionsAmazonEst,0)-ISNULL(CommissionsAmazonRefundsEst,0)+ISNULL(CommissionsMarketplacesEst,0)-ISNULL(CommissionsMarketplacesRefundsEst,0)) ,
	[PC3] = sum(PC3)
FROM PL.PL_V_SALES_TRANSACTIONS_ARCHIVE s
INNER JOIN PL.PL_V_SALES_CHANNEL ch on ch.Channelid = s.channelid
WHERE 1=1
	and ChannelGroup1 in ('Amazon','Marketplaces WE','Shop WE')
	and ISNULL(Incidentflag,'N') = 'N'
GROUP BY TransactionYear,ChannelGroup1 

)
SELECT
	TransactionYear		= ISNULL(s.TransactionYear,a.TransactionYear),
	ChannelGroup1		= ISNULL(s.ChannelGroup1,a.ChannelGroup1),
	NetOrderValueEst	= ISNULL(s.NetOrderValueEst,0) + ISNULL(a.NetOrderValueEst,0),
	RevenueEst			= ISNULL(s.RevenueEst,0) + ISNULL(a.RevenueEst,0) ,
	[PC0%]				= (ISNULL(s.PC0,0) + ISNULL(a.PC0,0)) / (ISNULL(s.RevenueEst,0) + ISNULL(a.RevenueEst,0)),
	[PC1%]				= (ISNULL(s.PC1,0) + ISNULL(a.PC1,0)) / (ISNULL(s.RevenueEst,0) + ISNULL(a.RevenueEst,0)),
	[Marketing%]		= (ISNULL(s.Marketing,0)+ISNULL(a.Marketing,0)) / (ISNULL(s.RevenueEst,0) + ISNULL(a.RevenueEst,0)),
	[Commissions%]		= (ISNULL(s.Commissions,0)+ISNULL(a.Commissions,0)) / (ISNULL(s.RevenueEst,0) + ISNULL(a.RevenueEst,0)),
	[FulfillmentOutboundEst%] = (ISNULL(s.FulfillmentOutboundEst,0)+ISNULL(a.FulfillmentOutboundEst,0)) / (ISNULL(s.RevenueEst,0) + ISNULL(a.RevenueEst,0)),
	[PC3%]				= (ISNULL(s.PC3,0)+ISNULL(a.PC3,0)) / (ISNULL(s.RevenueEst,0) + ISNULL(a.RevenueEst,0))
FROM cte_sales s
FULL JOIN cte_archive a
	on 
		a.TransactionYear = s.TransactionYear
		AND
		a.ChannelGroup1 = s.ChannelGroup1
where 
ISNULL(s.ChannelGroup1,a.ChannelGroup1) = 'Amazon'



SELECT TOP 10 *
FROM L1.L1_FACT_A_SALES_TRANSACTION l1
WHERE
	YEAR(D_CREATED) = 2022
	AND
	MONTH(D_CREATED) = 1
	AND
	CD_TYPE in ('VVA','VSC','VSD')

select *
From L1.L1_FACT_A_SALES_TRANSACTION_KPI l1
where
	CD_SALES_PROCESS_ID  = '18562105'



	select channelgroup1,SUM(AMT_GROSS_ORDER_VALUE_EUR),SUM(AMT_NET_ORDER_VALUE_EST_EUR)
	FROM L1.L1_FACT_A_SALES_TRANSACTION_KPI_ARCHIVE s
	INNER JOIN PL.PL_V_SALES_CHANNEL ch on ch.Channelid = s.ID_SALES_CHANNEL

	where YEAR(D_CREATED) = 2022
		and cd_source_system in ('SAP','SGE')
	GROUP BY channelgroup1


	select channelgroup3,SUM(AMT_GROSS_ORDER_VALUE_EUR),SUM(AMT_NET_ORDER_VALUE_EST_EUR)
	FROM L1.L1_FACT_A_SALES_TRANSACTION_KPI s
	INNER JOIN PL.PL_V_SALES_CHANNEL ch on ch.Channelid = s.ID_SALES_CHANNEL
	where YEAR(D_CREATED) = 2022
	and cd_source_system in ('SAP','SGE')
	and channelgroup1 = 'Amazon'
		GROUP BY channelgroup3





	select top 10 s.*
	FROM L1.L1_FACT_A_SALES_TRANSACTION_KPI s
	where CD_SALES_TRANSACTION NOT IN (
	select distinct CD_SALES_TRANSACTION
	FROM WR.WR_L1_FACT_A_SALES_TRANSACTION_KPI s
		where YEAR(D_CREATED) = 2022

	)
	and YEAR(D_CREATED) = 2022

    UPDATE f
	SET f.VL_REFUND_RATE		= rrr.VL_REFUND_RATE
		,f.VL_RETURN_RATE		= rrr.VL_RETURN_RATE
		,f.VL_REPLACEMENT_RATE 	 =rrr.VL_REPLACEMENT_RATE
		,f.CD_REFUND_RATE_SOURCE =rrr.CD_REFUND_RATE_SOURCE
		,f.CD_RETURN_RATE_SOURCE =rrr.CD_RETURN_RATE_SOURCE
		,f.CD_REPLACEMENT_RATE_SOURCE =rrr.CD_REPLACEMENT_RATE_SOURCE
	from L1.L1_FACT_A_SALES_TRANSACTION f
	LEFT JOIN [L0].[L0_MI_COUNTRY_MAPPING] cmi
	ON f.[CD_COUNTRY_INVOICE] = cmi.COUNTRY
	LEFT JOIN [L1].[L1_FACT_A_NOV_CLAIM_RATES] rrr
	ON rrr.id_item = f.ID_ITEM
    AND f.D_CREATED BETWEEN rrr.d_valid_from and rrr.d_valid_to
	AND (rrr.CD_COUNTRY_INVOICE_GROUP is null OR rrr.CD_COUNTRY_INVOICE_GROUP = cmi.INVOICECOUNTRYGROUP)
	AND (rrr.CD_COUNTRY_DELIVERY IS null )
	AND (rrr.CD_CHANNEL_GROUP_3 is null )     
	where YEAR(D_CREATED) <= 2022
	and cd_type in ('ZAA','ZKE','ZAZ','VVA','VSD','VSC')



	---- MEK 
	
    UPDATE f
	SET f.[AMT_MEK_HEDGING_EUR] =  ISNULL(
                        mek.VERPR * 
                        (
                            CASE 
                            WHEN NUM_ITEM like '9%' 
                            THEN 0 
                            ELSE 1 
                            END
                        ), 0
                    ) * [VL_ITEM_QUANTITY]
	from L1.L1_FACT_A_SALES_TRANSACTION f
	INNER JOIN L1.L1_DIM_A_ITEM it on it.ID_ITEM = f.ID_ITEM
	LEFT JOIN L0.L0_S4HANA_MBEW AS mek
    ON CAST(mek.MATNR as INT) = '10' + RIGHT(NUM_ITEM,6)
		AND NUM_ITEM LIKE '[15]%'
		AND CAST(mek.LOAD_TIMESTAMP as DATE) =  CAST(DATEADD(YEAR,1,f.D_CREATED) AS DATE)
		AND mek.BWKEY = 1000
		AND mek.BWTAR = '100'
	where YEAR(f.D_CREATED) = 2020
	and cd_type in ('ZAA','ZKE','ZAZ','VVA','VSD','VSC')
	and ISNULL(amt_mek_hedging_eur,0) =0




	    UPDATE f
			SET f.AMT_GTS_MARKUP =  

      (ABS([AMT_MEK_HEDGING_EUR] )) / (1+ 0.15) 
      / (1+ CASE WHEN GTS.GTSMARKUPRATES < 0 THEN 0 ELSE ISNULL(GTS.GTSMARKUPRATES,0) END) * CASE WHEN GTS.GTSMARKUPRATES < 0 THEN 0 ELSE ISNULL(GTS.GTSMARKUPRATES,0) END 

	from L1.L1_FACT_A_SALES_TRANSACTION f
	INNER JOIN L1.L1_DIM_A_ITEM it on it.ID_ITEM = f.ID_ITEM
	 LEFT JOIN [L0].[L0_MI_GTS_MARKUP_RATES] GTS
	ON NUM_ITEM  = GTS.ITEMNO
        AND CAST(DATEADD(YEAR,3,f.D_CREATED) AS DATE) between GTS.VALID_FROM and GTS.VALID_TO

	where YEAR(f.D_CREATED) = 2020
	and cd_type in ('ZAA','ZKE','ZAZ','VVA','VSD','VSC')
	and ISNULL(AMT_GTS_MARKUP,0) =0
