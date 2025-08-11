
ALTER PROC [TEST].WR_TX_L1_FACT_A_D2C_PERFORMANCE_ITEM_L1_FACT_A_SALES_TRANSACTION_KPI_SM
AS
BEGIN

DECLARE @LOAD_START_DATE AS date 

SET @LOAD_START_DATE = CAST(GETDATE () - 30 as date)
	--- delete from kpi table the ggl transactions before inserting it again
	DELETE FROM [TEST].[L1_FACT_A_SALES_TRANSACTION_KPI_SM] WHERE CD_SOURCE_SYSTEM IN ('FBK','CRT','BNG','PSM','RTB')

	--calculate the cost of the item attribution table and group by channel and day
  
      
    INSERT INTO [TEST].[L1_FACT_A_SALES_TRANSACTION_KPI_SM] (
			
			ID_SALES_TRANSACTION,
			CD_SALES_TRANSACTION,
			CD_SOURCE_SYSTEM,
			D_CREATED,
			D_SALES_PROCESS,
			CD_TYPE,
			ID_ITEM,
			ID_SALES_CHANNEL,
			ID_COMPANY,
--			AMT_PC2_EUR,
			AMT_SHOP_MARKETING_EUR,
--			AMT_PC3_EUR,
			CD_COUNTRY_INVOICE,
			CD_COUNTRY_DELIVERY,
			CD_COUNTRY_ORDER,
			CD_COUNTRY_GROUP_INVOICE,
			CD_COUNTRY_GROUP_DELIVERY,
			T_STORAGE_LOCATION,
			D_EFF_FROM,
			D_EFF_TO,
			D_EFF_DELETED
			--DT_DWH_CREATED,
			--DT_DWH_UPDATED
	)


--- first select returns all the item attribution lines cost
SELECT
			0																												AS ID_SALES_TRANSACTION
			,CONCAT('MKT#',cast(PS.CD_SOURCE_SYSTEM as nvarchar(50)),'#',cast( PS.[D_CAMPAIGN] as nvarchar(50)),'#',cast( isnull(sc.ID_SALES_CHANNEL,0) as nvarchar(50))
										,'#',cast( isnull(ps.ID_ITEM,0) as nvarchar(50)),'#',cast(MA.CD_COUNTRY as nvarchar(50)))		,PS.CD_SOURCE_SYSTEM																											AS CD_SOURCE_SYSTEM
			,DATEFROMPARTS(YEAR([D_CAMPAIGN]), MONTH([D_CAMPAIGN]), 1)																										AS D_CREATED
			,DATEFROMPARTS(YEAR([D_CAMPAIGN]), MONTH([D_CAMPAIGN]), 1)																										AS D_SALES_PROCESS
			,'Marketing'																									AS CD_TYPE
			,ps.ID_ITEM																										AS ID_ITEM
			,SC.ID_SALES_CHANNEL																							AS ID_SALES_CHANNEL
			,ID_COMPANY                                                                                                          AS ID_COMPANY
			,ROUND(SUM(isnull(PS.[AMT_COST_EUR_ATT],0)),2)																				AS AMT_SHOP_MARKETING_EUR 
			,MA.CD_COUNTRY																									AS CD_COUNTRY_INVOICE
			,MA.CD_COUNTRY																									AS CD_COUNTRY_DELIVERY
			,MA.CD_COUNTRY																									AS CD_COUNTRY_ORDER
			,cmid.INVOICECOUNTRYGROUP								                                                        AS CD_COUNTRY_GROUP_INVOICE
			,cmid.DELIVERYCOUNTRYGROUP								                                                        AS CD_COUNTRY_GROUP_DELIVERY
			,SC.T_DEFAULT_STORAGE_LOCATION                                                                                  AS T_STORAGE_LOCATION
			,GETDATE()																										AS D_EFF_FROM
			,convert(date, '12/31/9999')																					AS D_EFF_TO
			,convert(date, '12/31/9999')																					AS D_EFF_DELETED
			--,sysdatetime()																									AS DT_DWH_CREATED
			--,sysdatetime()	
			--AS DT_DWH_UPDATED
		FROM L1.L1_FACT_A_D2C_PERFORMANCE_ITEM AS PS
		LEFT JOIN [L1].[L1_DIM_A_MARKETING_ACCOUNT] AS MA
			 ON PS.ID_MARKETING_ACCOUNT = MA.ID_MARKETING_ACCOUNT
		LEFT JOIN l1.[L1_DIM_A_SALES_CHANNEL] AS SC
			 ON MA.CD_SALES_CHANNEL = SC.CD_SALES_CHANNEL
		LEFT JOIN [L0].[L0_MI_COUNTRY_MAPPING] cmid
			ON MA.CD_COUNTRY = cmid.COUNTRY
		LEFT JOIN [L1].[L1_DIM_A_COMPANY] company
		    ON  [CD_COMPANY]= '1000' and company.[CD_SOURCE_SYSTEM] = 'SAP'
		WHERE 1=1
			and [D_CAMPAIGN]>='2024-06-01'
		GROUP BY 
			PS.[D_CAMPAIGN],
			PS.CD_SOURCE_SYSTEM,
			ID_ITEM,
			SC.ID_SALES_CHANNEL,
			MA.CD_COUNTRY,
			cmid.INVOICECOUNTRYGROUP,
			cmid.DELIVERYCOUNTRYGROUP,
			SC.T_DEFAULT_STORAGE_LOCATION,
			ID_COMPANY,DATEFROMPARTS(YEAR([D_CAMPAIGN]), MONTH([D_CAMPAIGN]), 1)

			having  SUM(isnull(PS.[AMT_COST_EUR_ATT],0)) <> 0

  

END