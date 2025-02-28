---PACKAGING
----------------------

DECLARE @StorageLocation varchar(50) = 'Kamp-Lintfort'
DECLARE @Fulfillment  varchar(50) = 'FBM'
DECLARE @date  varchar(50) = '2025-01-01'
DECLARE @sizebracket  varchar(50) = 'Standard-Size_large'
	
------GET TOTAL VALUES
--select 
--it.NUM_ITEM,
--kpi.T_REVISED_LOCATION,
--it.CD_SIZE_BRACKET, 
-- TOTAL_PACK = SUM(GREATEST(
--				LEAST(it.VL_VOLUME * isnull(packcost.AMT_PACKAGING_COST_M3_EUR, 0) / (CASE WHEN it.cd_unit_volume='CCM' THEN 1000000 WHEN it.cd_unit_volume='M3' THEN 1 END), (2 * packcost_max.AMT_PACKAGING_COST_M3_EUR))
--				,(0.02 * packcost_min.AMT_PACKAGING_COST_M3_EUR)
--				)),						
--VL_ITEM_QUANTITY=sum(VL_ITEM_QUANTITY),
--ITEM_VOLUME = SUM((it.VL_VOLUME * VL_ITEM_QUANTITY)/ (CASE WHEN it.cd_unit_volume='CCM' THEN 1000000 WHEN it.cd_unit_volume='M3' THEN 1 END) ) ,
--sum(AMT_PACKAGING_EUR)AMT_PACKAGING_EUR
--FROM [L1].[L1_FACT_F_BUSINESS_PLAN_KPI] kpi
--LEFT JOIN L1.L1_DIM_A_ITEM it on it.ID_ITEM = kpi.ID_ITEM
--		LEFT JOIN L1.L1_DIM_A_PACKAGING_COST packcost
--			ON it.CD_SIZE_BRACKET = packcost.CD_SIZE_BRACKET
--			AND kpi.CD_FULFILLMENT = packcost.CD_FULFILLMENT
--			AND kpi.T_REVISED_LOCATION = packcost.T_STORAGE_LOCATION
--			AND kpi.D_TARGET BETWEEN packcost.D_VALID_FROM AND packcost.D_VALID_TO
--		LEFT JOIN L1.L1_DIM_A_PACKAGING_COST packcost_min
--			ON 'Standard-Size_Small' = packcost_min.CD_SIZE_BRACKET
--			AND kpi.CD_FULFILLMENT = packcost_min.CD_FULFILLMENT
--			AND kpi.T_REVISED_LOCATION = packcost_min.T_STORAGE_LOCATION
--			AND kpi.D_TARGET BETWEEN packcost_min.D_VALID_FROM AND packcost_min.D_VALID_TO

--		LEFT JOIN L1.L1_DIM_A_PACKAGING_COST packcost_max
--			ON 'Over-Size_Large' = packcost_max.CD_SIZE_BRACKET
--			AND kpi.CD_FULFILLMENT = packcost_max.CD_FULFILLMENT
--			AND kpi.T_REVISED_LOCATION = packcost_max.T_STORAGE_LOCATION
--			AND kpi.D_TARGET BETWEEN packcost_max.D_VALID_FROM AND packcost_max.D_VALID_TO

--WHERE
--	kpi.CD_FULFILLMENT = @Fulfillment
--	AND
--	kpi.T_REVISED_LOCATION = @StorageLocation
--	AND 
--	kpi.D_TARGET = @date
--	AND
--	it.CD_SIZE_BRACKET = @sizebracket
--	and 
--	it.num_item = 10030983
--GROUP BY T_REVISED_LOCATION,it.CD_SIZE_BRACKET,it.NUM_ITEM
--order by 7 desc






-- GET STANDARD PACKING VALUES
 select 
 *
 FROM L1.L1_DIM_A_PACKAGING_COST packcost
 where 1=1  
	--packcost.CD_SIZE_BRACKET = @sizebracket
	AND  packcost.CD_FULFILLMENT = @Fulfillment
	AND  packcost.T_STORAGE_LOCATION = @StorageLocation
	AND @date BETWEEN packcost.D_VALID_FROM AND packcost.D_VALID_TO

--- GET MIN VALUE
 select 
 *,(0.02 * packcost_min.AMT_PACKAGING_COST_M3_EUR)
 FROM L1.L1_DIM_A_PACKAGING_COST packcost_min
 where 1=1  
	AND	 'Standard-Size_Small' = packcost_min.CD_SIZE_BRACKET
	AND  packcost_min.CD_FULFILLMENT = @Fulfillment
	AND  packcost_min.T_STORAGE_LOCATION = @StorageLocation
	AND @date BETWEEN packcost_min.D_VALID_FROM AND packcost_min.D_VALID_TO

--- get max value

 select *,(2 * packcost_max.AMT_PACKAGING_COST_M3_EUR)
 FROM L1.L1_DIM_A_PACKAGING_COST packcost_max
 where 1=1  
			AND 'Over-Size_Large' = packcost_max.CD_SIZE_BRACKET
	AND  packcost_max.CD_FULFILLMENT = @Fulfillment
	AND  packcost_max.T_STORAGE_LOCATION = @StorageLocation
	AND @date BETWEEN packcost_max.D_VALID_FROM AND packcost_max.D_VALID_TO








--SELECT 
--	*
--FROM [L1].[L1_FACT_F_BUSINESS_PLAN] where id_item = '5354' and cd_channel_group_3 = 'Amazon' and d_target = '2025-01-01'

--SELECT 
--	*
--FROM [L1].L1_DIM_A_ITEM
--where num_item = 10030983




--Currently: Amazon/Jan25 Item 10000148 has 11.78 as a quantity; the GB correspondent ansolute value is  0.71; the number i should be giving 


--	SELECT 
--		 MATNR
--		,VERPR
--		,LOAD_TIMESTAMP 
--		,rank() over (partition by CAST(MATNR as int) ORDER BY LOAD_TIMESTAMP DESC ) AS LastVersion
--	FROM [L0].[L0_S4HANA_MBEW] 
--	WHERE BWKEY = 1000
--    AND BWTAR = '100'
--	and CAST(MATNR as int) = 10033316




select 
it.NUM_ITEM,
kpi.T_REVISED_LOCATION,
it.CD_SIZE_BRACKET, 
 TOTAL_PACK = (GREATEST(
				LEAST(it.VL_VOLUME * isnull(packcost.AMT_PACKAGING_COST_M3_EUR, 0) / (CASE WHEN it.cd_unit_volume='CCM' THEN 1000000 WHEN it.cd_unit_volume='M3' THEN 1 END), (2 * packcost_max.AMT_PACKAGING_COST_M3_EUR))
				,(0.02 * packcost_min.AMT_PACKAGING_COST_M3_EUR)
				)),						
VL_ITEM_QUANTITY=VL_ITEM_QUANTITY,
ITEM_VOLUME = ((it.VL_VOLUME )/ (CASE WHEN it.cd_unit_volume='CCM' THEN 1000000 WHEN it.cd_unit_volume='M3' THEN 1 END) ) ,
(AMT_PACKAGING_EUR)AMT_PACKAGING_EUR
FROM [L1].[L1_FACT_F_BUSINESS_PLAN_KPI] kpi
LEFT JOIN L1.L1_DIM_A_ITEM it on it.ID_ITEM = kpi.ID_ITEM
		LEFT JOIN L1.L1_DIM_A_PACKAGING_COST packcost
			ON it.CD_SIZE_BRACKET = packcost.CD_SIZE_BRACKET
			AND kpi.CD_FULFILLMENT = packcost.CD_FULFILLMENT
			AND kpi.T_REVISED_LOCATION = packcost.T_STORAGE_LOCATION
			AND kpi.D_TARGET BETWEEN packcost.D_VALID_FROM AND packcost.D_VALID_TO
		LEFT JOIN L1.L1_DIM_A_PACKAGING_COST packcost_min
			ON 'Standard-Size_Small' = packcost_min.CD_SIZE_BRACKET
			AND kpi.CD_FULFILLMENT = packcost_min.CD_FULFILLMENT
			AND kpi.T_REVISED_LOCATION = packcost_min.T_STORAGE_LOCATION
			AND kpi.D_TARGET BETWEEN packcost_min.D_VALID_FROM AND packcost_min.D_VALID_TO

		LEFT JOIN L1.L1_DIM_A_PACKAGING_COST packcost_max
			ON 'Over-Size_Large' = packcost_max.CD_SIZE_BRACKET
			AND kpi.CD_FULFILLMENT = packcost_max.CD_FULFILLMENT
			AND kpi.T_REVISED_LOCATION = packcost_max.T_STORAGE_LOCATION
			AND kpi.D_TARGET BETWEEN packcost_max.D_VALID_FROM AND packcost_max.D_VALID_TO

WHERE
	kpi.CD_FULFILLMENT = @Fulfillment
	AND
	kpi.T_REVISED_LOCATION = @StorageLocation
	AND 
	kpi.D_TARGET = @date
	AND
	it.CD_SIZE_BRACKET = @sizebracket
	and 
	it.num_item = 10035220


