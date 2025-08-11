
ALTER PROC [TEST].[WR_TX_L1_FACT_A_AMAZON_ITEM_COST_L1_FACT_A_SALES_TRANSACTION_KPI]
AS
BEGIN
	---
    DECLARE @NUM_DAYS INT = 30

    --- delete from kpi table the ggl transactions before inserting it again
	DELETE FROM [TEST].[L1_FACT_A_SALES_TRANSACTION_KPI_SM] WHERE CD_SOURCE_SYSTEM = 'AMZ'
   -- AND D_CREATED >= cast(getdate() - @NUM_DAYS as date)

    ;WITH CTE_DELIVERY_COUNTRY_CHANNEL AS (
	
	SELECT 
		 DATEFROMPARTS(YEAR(D_CREATED), MONTH(D_CREATED), 1) D_CREATED,
		[CD_COUNTRY_DELIVERY],
		ID_SALES_CHANNEL,
		SUM([VL_ITEM_QUANTITY]) Quantity,
		sum(SUM([VL_ITEM_QUANTITY])) OVER (Partition by ID_SALES_CHANNEL,DATEFROMPARTS(YEAR(D_CREATED), MONTH(D_CREATED), 1) ) Total,
		DistributionRate = SUM([VL_ITEM_QUANTITY]) / sum(SUM([VL_ITEM_QUANTITY])) OVER (Partition by ID_SALES_CHANNEL,DATEFROMPARTS(YEAR(D_CREATED), MONTH(D_CREATED), 1) )
	FROM TEST.L1_FACT_A_SALES_TRANSACTION_KPI_SM f
	INNER JOIN [L1].[L1_DIM_A_SALES_TRANSACTION_TYPE] t
		ON t.[ID_SALES_TRANSACTION_TYPE] = f.[ID_SALES_TRANSACTION_TYPE]
	WHERE
		t.[CD_SALES_TRANSACTION_CATEGORY] in ('Order','OrderInvoice')
		AND [VL_ITEM_QUANTITY] > 0
        AND D_CREATED >= '2024-06-01'
	GROUP BY [CD_COUNTRY_DELIVERY],ID_SALES_CHANNEL,DATEFROMPARTS(YEAR(D_CREATED), MONTH(D_CREATED), 1)


),
CTE_DELIVERY_COUNTRY_ITEM AS (
	
	SELECT 
		DATEFROMPARTS(YEAR(D_CREATED), MONTH(D_CREATED), 1) D_CREATED,
		f.ID_ITEM,
		[CD_COUNTRY_DELIVERY],
		ID_SALES_CHANNEL,
		SUM([VL_ITEM_QUANTITY]) Quantity,
		sum(SUM([VL_ITEM_QUANTITY])) OVER (Partition by ID_SALES_CHANNEL,DATEFROMPARTS(YEAR(D_CREATED), MONTH(D_CREATED), 1),ID_ITEM ) Total,
		DistributionRate = SUM([VL_ITEM_QUANTITY]) / sum(SUM([VL_ITEM_QUANTITY])) OVER (Partition by ID_SALES_CHANNEL,DATEFROMPARTS(YEAR(D_CREATED), MONTH(D_CREATED), 1),ID_ITEM )
	FROM TEST.L1_FACT_A_SALES_TRANSACTION_KPI_SM f
	INNER JOIN [L1].[L1_DIM_A_SALES_TRANSACTION_TYPE] t
		ON t.[ID_SALES_TRANSACTION_TYPE] = f.[ID_SALES_TRANSACTION_TYPE]
	WHERE
		t.[CD_SALES_TRANSACTION_CATEGORY] in ('Order','OrderInvoice')
		AND [VL_ITEM_QUANTITY] > 0
        AND D_CREATED >= '2024-06-01'
	GROUP BY [CD_COUNTRY_DELIVERY],ID_SALES_CHANNEL,DATEFROMPARTS(YEAR(D_CREATED), MONTH(D_CREATED), 1),ID_ITEM


),
CTE_DELIVERY_COUNTRY_ITEM_PARENT AS (
	
	SELECT 
		DATEFROMPARTS(YEAR(D_CREATED), MONTH(D_CREATED), 1) D_CREATED,
		f.ID_ITEM_PARENT,
		[CD_COUNTRY_DELIVERY],
		ID_SALES_CHANNEL,
		SUM([VL_ITEM_PARENT_QUANTITY]) Quantity,
		sum(SUM([VL_ITEM_PARENT_QUANTITY])) OVER (Partition by ID_SALES_CHANNEL,DATEFROMPARTS(YEAR(D_CREATED), MONTH(D_CREATED), 1),ID_ITEM_PARENT ) Total,
		DistributionRate = SUM([VL_ITEM_PARENT_QUANTITY]) / sum(SUM([VL_ITEM_PARENT_QUANTITY])) OVER (Partition by ID_SALES_CHANNEL,DATEFROMPARTS(YEAR(D_CREATED), MONTH(D_CREATED), 1),ID_ITEM_PARENT )
	FROM TEST.L1_FACT_A_SALES_TRANSACTION_KPI_SM f
	INNER JOIN [L1].[L1_DIM_A_SALES_TRANSACTION_TYPE] t
		ON t.[ID_SALES_TRANSACTION_TYPE] = f.[ID_SALES_TRANSACTION_TYPE]
	WHERE
		t.[CD_SALES_TRANSACTION_CATEGORY] in ('Order','OrderInvoice')
		AND [VL_ITEM_PARENT_QUANTITY] > 0
		AND f.ID_ITEM_PARENT IS NOT NULL
        AND D_CREATED >= '2024-06-01'
	GROUP BY [CD_COUNTRY_DELIVERY],ID_SALES_CHANNEL,DATEFROMPARTS(YEAR(D_CREATED), MONTH(D_CREATED), 1),ID_ITEM_PARENT



),
CTE_MAIN AS (

SELECT 
	DATEFROMPARTS(YEAR(D_CAMPAIGN), MONTH(D_CAMPAIGN), 1) D_CAMPAIGN,
	amz.ID_ITEM,
	[CD_SOURCE_SYSTEM],
	CD_COUNTRY,
	[AMT_COST_EUR_ATT] = SUM([AMT_COST_EUR_ATT]),
	[GOOGLE_AMT_COST_EUR_ATT] = SUM([GOOGLE_AMT_COST_EUR_ATT]),
	[DSP_AMT_COST_EUR_ATT] =SUM([DSP_AMT_COST_EUR_ATT]),
	[ID_MARKETING_ACCOUNT]
FROM [L1].L1_FACT_A_AMAZON_ITEM_ATTRIBUTION amz
WHERE
     D_CAMPAIGN >= '2024-06-01'
GROUP BY DATEFROMPARTS(YEAR(D_CAMPAIGN), MONTH(D_CAMPAIGN), 1) ,amz.ID_ITEM,[CD_SOURCE_SYSTEM],
CD_COUNTRY,[ID_MARKETING_ACCOUNT]

)


INSERT INTO [TEST].[L1_FACT_A_SALES_TRANSACTION_KPI_SM]
    (
        ID_SALES_TRANSACTION,
        CD_SALES_TRANSACTION,
        CD_SOURCE_SYSTEM,
        D_CREATED,
        D_SALES_PROCESS,
        CD_TYPE,
        ID_ITEM,
		ID_ITEM_PARENT,
        ID_SALES_CHANNEL,
        ID_COMPANY,
        CD_COUNTRY_INVOICE,
        CD_COUNTRY_DELIVERY,
        CD_COUNTRY_ORDER,
        AMT_AMAZON_MARKETING_EUR,
        CD_COUNTRY_GROUP_INVOICE,
        CD_COUNTRY_GROUP_DELIVERY,
        T_STORAGE_LOCATION,
        D_EFF_FROM,
        D_EFF_TO,
        D_EFF_DELETED
        --DT_DWH_CREATED,
        --DT_DWH_UPDATED
    )
    SELECT 
        0                                                                                                               as ID_SALES_TRANSACTION
        ,CONCAT('MKT#',cast(isnull(amz.ID_ITEM,0) as nvarchar(50)),'#',cast(isnull(channel.ID_SALES_CHANNEL,0) as nvarchar(50))
				,'#',cast(ISNULL(dri.[CD_COUNTRY_DELIVERY],ISNULL(dri_parent.[CD_COUNTRY_DELIVERY],ISNULL(drc.[CD_COUNTRY_DELIVERY],amz.[CD_COUNTRY]))) as nvarchar(50))
				,'#',cast(ISNULL(amz.CD_COUNTRY,0) as nvarchar(10)),
                '#',cast(amz.D_CAMPAIGN as nvarchar(50)) )																as CD_SALES_TRANSACTION
        ,amz.[CD_SOURCE_SYSTEM]				                                                                            as CD_SOURCE_SYSTEM
        ,amz.[D_CAMPAIGN]   				                                                                            as D_CREATED
        ,amz.[D_CAMPAIGN]				                                                                                as D_SALES_PROCESS
        ,'Marketing'					                                                                                as CD_TYPE
        ,amz.[ID_ITEM]						                                                                            as ID_ITEM
		,dri_parent.ID_ITEM_PARENT                                                                                      as ID_ITEM_PARENT
        ,channel.[ID_SALES_CHANNEL]			                                                                            as ID_SALES_CHANNEL
        ,ID_COMPANY                                                                                                     AS ID_COMPANY
        ,ISNULL(dri.[CD_COUNTRY_DELIVERY],ISNULL(dri_parent.[CD_COUNTRY_DELIVERY],ISNULL(drc.[CD_COUNTRY_DELIVERY],amz.[CD_COUNTRY])))                           as CD_COUNTRY_INVOICE
        ,ISNULL(dri.[CD_COUNTRY_DELIVERY],ISNULL(dri_parent.[CD_COUNTRY_DELIVERY],ISNULL(drc.[CD_COUNTRY_DELIVERY],amz.[CD_COUNTRY]))) 							 as CD_COUNTRY_DELIVERY
        ,amz.[CD_COUNTRY]					                                                                            as CD_COUNTRY_ORDER
        ,ROUND(SUM((ISNULL(amz.[AMT_COST_EUR_ATT],0)+ISNULL(amz.[GOOGLE_AMT_COST_EUR_ATT],0)+ISNULL(amz.[DSP_AMT_COST_EUR_ATT],0))) * (ISNULL(dri.DistributionRate,ISNULL(dri_parent.DistributionRate,ISNULL(drc.DistributionRate,1)))),2)		         as AMT_AMAZON_MARKETING_EUR
         ,cmid.INVOICECOUNTRYGROUP								                                                        AS CD_COUNTRY_GROUP_INVOICE
		,cmid.DELIVERYCOUNTRYGROUP								                                                        AS CD_COUNTRY_GROUP_DELIVERY
		,channel.T_DEFAULT_STORAGE_LOCATION                                                                             AS T_STORAGE_LOCATION
        ,GETDATE()                                                                                                      as D_EFF_FROM
        ,convert(date, '12/31/9999')                                                                                    as D_EFF_TO
        ,convert(date, '12/31/9999')                                                                                    as D_EFF_DELETED
        --,sysdatetime()                                                                                                  as DT_DWH_CREATED
        --,sysdatetime()                                                                                                  as DT_DWH_UPDATED
    FROM CTE_MAIN amz
    LEFT JOIN L1.L1_DIM_A_MARKETING_ACCOUNT mkt
        on mkt.[ID_MARKETING_ACCOUNT] = amz.[ID_MARKETING_ACCOUNT]
    LEFT JOIN L1.L1_DIM_A_SALES_CHANNEL channel
        on channel.[CD_SALES_CHANNEL] = mkt.[CD_SALES_CHANNEL]
	LEFT JOIN CTE_DELIVERY_COUNTRY_ITEM dri
		on dri.ID_SALES_CHANNEL = channel.ID_SALES_CHANNEL
			AND dri.D_CREATED =amz.D_CAMPAIGN
			AND dri.ID_ITEM = amz.ID_ITEM
	LEFT JOIN CTE_DELIVERY_COUNTRY_ITEM_PARENT dri_parent
		on dri_parent.ID_SALES_CHANNEL = channel.ID_SALES_CHANNEL
			AND dri_parent.D_CREATED =amz.D_CAMPAIGN
			AND dri_parent.ID_ITEM_PARENT = amz.ID_ITEM
	LEFT JOIN CTE_DELIVERY_COUNTRY_CHANNEL drc
		on drc.ID_SALES_CHANNEL = channel.ID_SALES_CHANNEL
			AND drc.D_CREATED =amz.D_CAMPAIGN
			AND dri.ID_ITEM IS NULL AND  dri_parent.ID_ITEM_PARENT IS NULL
    LEFT JOIN [L0].[L0_MI_COUNTRY_MAPPING] cmid
			ON ISNULL(dri.[CD_COUNTRY_DELIVERY],ISNULL(dri_parent.[CD_COUNTRY_DELIVERY],ISNULL(drc.[CD_COUNTRY_DELIVERY],amz.[CD_COUNTRY])))  = cmid.COUNTRY
	LEFT JOIN [L1].[L1_DIM_A_COMPANY] company
		    ON  [CD_COMPANY]= '1000' and company.[CD_SOURCE_SYSTEM] = 'SAP'
    WHERE 1=1
			and ABS(ISNULL(amz.[AMT_COST_EUR_ATT],0)+ISNULL(amz.[GOOGLE_AMT_COST_EUR_ATT],0)+ISNULL(amz.[DSP_AMT_COST_EUR_ATT],0))>0
           -- AND amz.D_CAMPAIGN >= cast(getdate() - @NUM_DAYS as date)
		Group by amz.CD_SOURCE_SYSTEM,D_CAMPAIGN,amz.ID_ITEM,channel.ID_SALES_CHANNEL,amz.CD_COUNTRY,drc.[CD_COUNTRY_DELIVERY],dri_parent.[CD_COUNTRY_DELIVERY],drc.DistributionRate,dri.DistributionRate,dri_parent.DistributionRate,dri.[CD_COUNTRY_DELIVERY],cmid.INVOICECOUNTRYGROUP,cmid.DELIVERYCOUNTRYGROUP,channel.T_DEFAULT_STORAGE_LOCATION,ID_COMPANY,dri_parent.ID_ITEM_PARENT 

	


END

