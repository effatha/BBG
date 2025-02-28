/**********************************************
*** CREATE TABLE
***********************************************/
--drop table #tmpProcessId

CREATE TABLE #tmpProcessId(
    Source NVARCHAR(255),
    Documentno NVARCHAR(255),
	LastDocument NVARCHAR(255),
    ProcessID NVARCHAR(255)
);

/**********************************************
*** INSERT ALL DOCUMENTS
***********************************************/
insert into #tmpProcessId(Source,Documentno,LastDocument)
--SELECT DISTINCT 'VAITM',VBELN,VBELN
--FROM  [L0].[L0_S4HANA_2LIS_11_VAITM]
--UNION
SELECT DISTINCT 'VCITM',VBELN,VBELN
FROM  [L0].[L0_S4HANA_2LIS_12_VCITM]
where vbeln = '3003027249'
--UNION
--SELECT DISTINCT 'VDITM',VBELN,VBELN
--FROM  [L0].[L0_S4HANA_2LIS_13_VDITM]

-- declare variable for while
DECLARE @nCount as int 
SELECT  @nCount = count(*) from #tmpProcessId where ISNULL(ProcessID,'')=''

/**********************************************
*** WHILE
***********************************************/

WHILE(@nCount > 0 )
BEGIN
------VAITM
	;with cte_vaitm as (
		SELECT DISTINCT VBELN, VGBEL FROM [L0].[L0_S4HANA_2LIS_11_VAITM]
	) 
	UPDATE vbfa
		SET		vbfa.ProcessId = CASE WHEN ISNULL(vaitm.VGBEL,'') = '' THEN vaitm.VBELN ELSE NULL END,
				vbfa.LastDocument = CASE WHEN ISNULL(vaitm.VGBEL,'') = '' THEN vaitm.VBELN ELSE vaitm.VGBEL END
	FROM #tmpProcessId vbfa
	INNER JOIN cte_vaitm vaitm
		on vbfa.LastDocument = vaitm.VBELN 
	WHERE 
		ISNULL(vbfa.ProcessID ,'')= ''
------VCITM
		
	;with cte_vcitm as (
		SELECT DISTINCT VBELN, VGBEL FROM [L0].[L0_S4HANA_2LIS_12_VCITM]
	) 
	UPDATE vbfa
		SET		vbfa.ProcessId = CASE WHEN ISNULL(vcitm.VGBEL,'') = '' THEN vcitm.VBELN ELSE NULL END,
				vbfa.LastDocument = CASE WHEN ISNULL(vcitm.VGBEL,'') = '' THEN vcitm.VBELN ELSE vcitm.VGBEL END
	FROM #tmpProcessId vbfa
	INNER JOIN cte_vcitm vcitm
		on vbfa.LastDocument = vcitm.VBELN 
		
	WHERE 
		ISNULL(vbfa.ProcessID ,'')= ''
------VDITM
	;with cte_vditm as (
		SELECT DISTINCT VBELN, VGBEL FROM [L0].[L0_S4HANA_2LIS_13_VDITM]
	) 
	UPDATE vbfa
		SET		vbfa.ProcessId = CASE WHEN ISNULL(vditm.VGBEL,'') = '' THEN vditm.VBELN ELSE NULL END,
				vbfa.LastDocument = CASE WHEN ISNULL(vditm.VGBEL,'') = '' THEN vditm.VBELN ELSE vditm.VGBEL END
	FROM #tmpProcessId vbfa
	INNER JOIN cte_vditm vditm
		on vbfa.LastDocument = vditm.VBELN 
		
	WHERE 
		ISNULL(vbfa.ProcessID ,'')= ''


		--check how many records we need to process excluding the ones that dont match any of the tables 
		select @nCount = SUM(CASE WHEN vaitm.VBELN IS NOT NULL OR vcitm.VBELN IS NOT NULL OR vditm.VBELN IS NOT NULL THEN 1 ELSE 0 END)
		from #tmpProcessId vbfa
		LEFT JOIN [L0].[L0_S4HANA_2LIS_11_VAITM] vaitm on vaitm.vbeln=vbfa.LastDocument
		LEFT JOIN [L0].[L0_S4HANA_2LIS_12_VCITM] vcitm on vcitm.vbeln=vbfa.LastDocument
		LEFT JOIN [L0].[L0_S4HANA_2LIS_13_VDITM] vditm on vditm.vbeln=vbfa.LastDocument
			WHERE 
		ISNULL(vbfa.ProcessID ,'')= ''

END







