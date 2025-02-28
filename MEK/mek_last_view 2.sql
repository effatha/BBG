 
 
ALTER VIEW [PL].[PL_V_LAST_MEK] AS 
with cte_last_mek as (
	SELECT  ItemNo,MekHedging,date, lastversion = rank() over (partition by ItemNo order by date desc) 
	FROM PL.PL_V_MEK_HISTORY 
	where 1=1
	AND itemtype = '100' 
	and plant = '1000'
	--and MekHedging > 0
--	and itemno = '10046001'
	--Group by itemno
	--order by date desc

)
SELECT it.ItemNo, MAX(GREATEST(mek.date,elementmek.date)) LastValueDate,SUM(ISNULL(elementmek.MekHedging * element.VL_ELEMENT_QUANTITY,mek.MekHedging)) MekHedging

FROM PL.PL_V_ITEM it 
LEFT JOIN cte_last_mek mek on it.ItemNo = mek.ItemNo and mek.lastversion = 1
LEFT JOIN [L1].[L1_DIM_A_ITEM_BOM] element
	ON it.ItemNo  =  cast(element.CD_ITEM as int)
	AND cd_plant = 1000
	AND CD_BOM_USAGE = '5'
LEFT JOIN  cte_last_mek elementmek
	ON elementmek.ItemNo  = cast(element.CD_ITEM_ELEMENT as int)
	AND cd_plant = 1000 and elementmek.LastVersion = 1
where 1=1 --and it.itemNo ='10046001'
GROUP BY  it.ItemNo--,mek.date
