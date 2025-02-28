drop table #lucanet_acounts
drop table #lucanet_groups

create table #lucanet_groups
(
	ParentID int,
	parent_path nvarchar(250),
	parent_path_name nvarchar(250),
	parent_level int,
	KPI nVarchar(10),
	nRetries int,
	direct_reference int

)

create table #lucanet_acounts
(
	Category nvarchar(150),
	AccountID int,
	ParentGroupID int,
	AccountType nvarchar(50),
	KPI nVarchar(10),
	account_path nvarchar(250),
	account_path_name nvarchar(250),
	account_level int,
	direct_reference int

)

INSERT INTO #lucanet_groups(ParentID,KPI,nRetries,parent_path,parent_path_name,parent_level,direct_reference)
--SELECT 2417205,'Revenue',0
--UNION
--SELECT 2417206,'COGS',0,'G-2417206','G-Cost of goods sold',1,1
SELECT id,'NA',0,'G-'+id,''+ name,1,1 from TEST.L0_LUCANET_READ_ELEMENTS L1 where parentid =2417202  --and id --not in (2417206)

WHILE EXISTS (
	SELECT 1 from #lucanet_groups
)
BEGIN
	
	---get accounts directly under the ids in #lucanet_groups
	INSERT INTO #lucanet_acounts (Category,AccountID,AccountType,ParentGroupID,KPI,account_path,account_path_name,account_level,direct_reference)
	select l1.category,id,type,l1.ParentID,lc.KPI,lc.parent_path + '=> A-'+ l1.id,lc.parent_path_name + '=> A-'+ l1.name   ,parent_level+10, lc.direct_reference
	from  TEST.L0_LUCANET_READ_ELEMENTS L1
	INNER JOIN #lucanet_groups lc
		on (lc.ParentID = l1.ParentID OR l1.id = lc.ParentID)
	where [type] in ('Account') and l1.id not in (select distinct AccountID from #lucanet_acounts where direct_reference = 1)


	INSERT INTO #lucanet_groups (ParentID,KPI,nRetries,parent_path,parent_path_name,parent_level,direct_reference)
	select 
			CASE WHEN l1.[type] = 'Group' THEN id ELSE ReferenceSourceID END,
			lc.KPI,
			0,
			lc.parent_path + '=>'+CASE WHEN l1.[type] = 'Group' THEN 'G-'+id ELSE 'R-'+ReferenceSourceID END,
			lc.parent_path_name + '=>'+CASE WHEN l1.[type] = 'Group' THEN 'G-'+[name] ELSE 'R-'+ReferenceSourceID END,
			parent_level+10,
			CASE WHEN isnull(l1.directreference,'') = 'FALSE' or lc.direct_reference = 0 THEN 0 ELSE 1 END
	from  TEST.L0_LUCANET_READ_ELEMENTS L1
	INNER JOIN #lucanet_groups lc
		on lc.ParentID = l1.ParentID
	where  [type] in ('Group','Reference')
	
	--	select * from  #lucanet_groups

	
	--(
	--			(
	--				category = 'PL' AND [type] in ('Group','Reference')) 
	--			OR (category = 'COPL' AND [type] in ('Group'))
	--			OR
	--				(category = 'COPL' AND [type] in ('Reference') and  isnull(directreference,'') = 'TRUE'
	--			)
	--		)

			--and isnull(directreference,'') = 'TRUE'

	DELETE FROM #lucanet_groups where nRetries = 1 

	UPDATE #lucanet_groups SET nRetries = 1




END

select * from  #lucanet_acounts where  accountid in (2421560,2408169,2495892)-- account_path like  '%2497282%'


select * from  #lucanet_groups


; with all_direct_nodes_accounts as (

	select Distinct accountid from  #lucanet_acounts where direct_reference = 1
)
SELECT 
	DISTINCT lcn.*
FROM #lucanet_acounts lcn
where (direct_reference = 1 or accountid not in (select accountid from all_direct_nodes_accounts))
--and accountid in (2495710,2408169,2495892)



select * from  #lucanet_groups
select *	from  TEST.L0_LUCANET_READ_ELEMENTS L1 
where 
id =2417206 
parentid = 2417206

name like '608AE Übrige ergebniswirksame Konsolidierungsdifferenzen - CTS'

--drop table #lucanet_acounts
--drop table #lucanet_groups


;WITH CTE_LAST_LOAD AS (

	SELECT AdjustmentLevelID,PeriodID,category,MAX(LOAD_TIMESTAMP)LOAD_TIMESTAMP
	FROM [L0_FIN].[L0_LUCANET_READ_FACTS] LCN 
	GROUP BY AdjustmentLevelID,PeriodID,category

)  
,
all_direct_nodes_accounts as (

	select Distinct accountid from  #lucanet_acounts where direct_reference = 1
),
kpi_accounts as (SELECT 
	DISTINCT lcn.*
FROM #lucanet_acounts lcn
where (direct_reference = 1 or accountid not in (select accountid from all_direct_nodes_accounts))
)

select account.account_path,account_path_name,lcn.*,([Value]/100.00) ValueDecimals
FROM [L0_FIN].[L0_LUCANET_READ_FACTS] LCN 
INNER JOIN kpi_accounts account on account.AccountID = lcn.accountid and account_path like 'G-2417205%'
INNER JOIN L0_FIN.L0_MI_LUCANET_MATRIX matrix
	on matrix.[AUDITID] = lcn.AdjustmentLevelID
	and (cast(periodid+'-01' as date)) between validfrom and validto 
INNER JOIN CTE_LAST_LOAD l on l.AdjustmentLevelID = lcn.AdjustmentLevelID and l.PeriodID = lcn.PeriodID and lcn.LOAD_TIMESTAMP >=l.LOAD_TIMESTAMP
	and l.category = lcn.category
where 1=1-- AND AccountName like '%601000%'
--and [ConsolidationElementName] like '%%'
and lcn.periodid = '2023-11'
--and accountname like '72511000%'


select * from #lucanet_acounts where accountid like '%2421560%'

select * from #lucanet_acounts where accountid like '%2421560%'




SELECT *
FROM [L0_FIN].[L0_LUCANET_READ_FACTS] LCN 
WHERE periodid ='2023-11'
and accountname like '63106746 Warehousing/fulfilment'









with cte_references as 
(
select distinct referencesourceid
FROM [TEST].L0_LUCANET_READ_ELEMENTS where category = 'COPL' and type = 'Reference' and directreference = 'True'
) 
	SELECT distinct id
	FROM [TEST].L0_LUCANET_READ_ELEMENTS el
	INNER JOIN cte_references ref on ref.referencesourceid = el.parentid
	where  type in ('Group','Account')
	and id in (2495891,2420636)

	select * from #lucanet_groups

	select * 
	FROM [TEST].L0_LUCANET_READ_ELEMENTS where id = 2417202 --name like '63106746 Warehousing/fulfilment'


		select * 
	FROM [TEST].L0_LUCANET_READ_ELEMENTS where parentid = 2417244

