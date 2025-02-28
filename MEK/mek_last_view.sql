/****** Object:  View [PL].[PL_V_LAST_MEK]    Script Date: 25/11/2024 11:01:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [PL].[PL_V_LAST_MEK] AS with cte_last_mek as (
	SELECT  ItemNo,MekHedging,date, lastversion = rank() over (partition by ItemNo order by date desc),itemtype,plant
	FROM PL.PL_V_MEK_HISTORY 
	where 1=1
	and itemtype = '100' 
	--and plant = '1000'
	--and MekHedging > 0
	and itemno = '10045855'
	--Group by itemno
	--order by date desc

)
SELECT mek.ItemNo, mek.date LastValueDate,SUM(ISNULL(elementmek.MekHedging * element.VL_ELEMENT_QUANTITY,mek.MekHedging)) MekHedging
FROM cte_last_mek mek
LEFT JOIN [L1].[L1_DIM_A_ITEM_BOM] element
	ON mek.ItemNo  =  cast(element.CD_ITEM as int)
	AND cd_plant = 1000
	AND CD_BOM_USAGE = '5'

LEFT JOIN  cte_last_mek elementmek
	ON elementmek.ItemNo  = cast(element.CD_ITEM_ELEMENT as int)
	AND cd_plant = 1000 and elementmek.LastVersion = 1
where 1=1--mek.itemNo ='10035039'
and mek.LastVersion = 1 
GROUP BY  mek.ItemNo,mek.date
GO


 SELECT cast(CD_ITEM as int) ,CD_ITEM_ELEMENT
 FROM [L1].[L1_DIM_A_ITEM_BOM]
 WHERE 1=1
	---and CD_BOM_USAGE = '5'
	AND cd_plant = 1000
	--and VL_ELEMENT_QUANTITY< 0
 GROUP BY cast(CD_ITEM as int),CD_ITEM_ELEMENT
 having count (*) > 1 


select count(*)
from [PL].[PL_V_LAST_MEK] --where itemNo = '10046001'


select top 10 *
from [PL].[PL_V_LAST_MEK_v2] mek2
INNER JOIN [PL].[PL_V_LAST_MEK] mek on mek.itemno = mek2.Itemno
where
	mek.Mekhedging <> mek2.Mekhedging




select TOP 10 * FROM [L1].[L1_DIM_A_ITEM_BOM] element where cast(element.CD_ITEM as int) ='10046001' and CD_PLANT = '1000'
select * from l1.l1_dim_a_item where num_item = '10046044'


SELECT max(D_created) 
FROM L1.L1_fact_a_sales_transaction where id_item =32578