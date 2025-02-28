select	 
	top 10 sales.*	
from pl.pl_v_sales_transactions sales
INNER JOIN pl.PL_v_ITEM it on it.ItemID = sales.ItemId
WHERE
	it.ItemNO = '10041291'
	and NetOrderValueEst > 0 
order by TransactionDate desc

SELECT TOP 100  * 
FROM PL.PL_V_MEK_HISTORY 
where itemno = '11041291' and itemtype = '100' and plant = '1000' order by date desc

select * from  pl.PL_v_ITEM it where itemid =21052
select * from l1.L1_fact_F_business_plan where ID_ITEM = 13270
select * from L0.L0_MI_BUSINESS_PLAN_MEK_OVERRIDE where itemno ='10041291'


with cte_last_mek as (
	SELECT  ItemNo,MekHedging, lastversion = rank() over (partition by ItemNo order by date desc) 
	FROM PL.PL_V_MEK_HISTORY 
	where 
	itemtype = '100' 
	and plant = '1000' 
	--and itemno = '10035255'
	--Group by itemno
	--order by date desc

)
SELECT mek.ItemNo, SUM(ISNULL(elementmek.MekHedging * element.VL_ELEMENT_QUANTITY,mek.MekHedging)) MekHedging
FROM cte_last_mek mek
LEFT JOIN [L1].[L1_DIM_A_ITEM_BOM] element
	ON mek.ItemNo  =  cast(element.CD_ITEM as int)
	AND cd_plant = 1000
LEFT JOIN  cte_last_mek elementmek
	ON elementmek.ItemNo  = cast(element.CD_ITEM_ELEMENT as int)
	AND cd_plant = 1000 and elementmek.LastVersion = 1
where mek.itemNo ='10035255'
and mek.LastVersion = 1 
GROUP BY  mek.ItemNo

select * from pl.pl_v_bom