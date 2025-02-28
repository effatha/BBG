/****** Object:  View [PL].[PL_V_LAST_MEK_V3]    Script Date: 04/12/2024 17:05:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [PL].[PL_V_LAST_MEK_V3] AS with cte_last_mek as (
	SELECT  
		ItemNo,
		MekHedging,
		date,
		plant,
		lastversion = rank() over (partition by ItemNo order by date desc,MekHedging desc,plant asc) 
	FROM PL.PL_V_MEK_HISTORY 
	where 1=1
	AND itemtype = '100' 
	and plant in(1000,1100,1400)
	and MekHedging > 0
--	and itemno = '10045938' ---'10045938'
	--Group by itemno
	--order by date desc
)
,cte_kitting as
(
SELECT  
		ItemNo,
		MekHedging,
		date,
		plant,
		lastversion = rank() over (partition by ItemNo order by date desc,plant asc) 
	FROM PL.PL_V_MEK_HISTORY 
	where 1=1
	AND itemtype = '100' 
	and plant in (1000,1400)
	and MekHedging > 0 
)

SELECT 
	it.ItemNo, 
	MAX(GREATEST(mek.date,mek_purch.date)) LastValueDate,
	GREATEST(ISNULL(mek_purch.MekHedging,mek.MekHedging)) MekHedging

FROM PL.PL_V_ITEM it 
LEFT JOIN cte_last_mek mek on it.ItemNo = mek.ItemNo and mek.lastversion = 1 and itemclass <> 'Kitting-Item'
LEFT JOIN  cte_kitting mek_purch
	ON mek_purch.ItemNo  = CASE 
							 WHEN it.ItemNo LIKE '10%' THEN '11' + SUBSTRING(cast(it.ItemNo as varchar(10)), 3, LEN(it.ItemNo) - 2) ELSE 0 
						   END
	AND mek_purch.LastVersion = 1
where 1=1 --and it.itemNo in ('10033316')
GROUP BY  it.ItemNo,ISNULL(mek_purch.MekHedging,mek.MekHedging);
GO


