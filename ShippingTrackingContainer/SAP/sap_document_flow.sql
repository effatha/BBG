CREATE TABLE #hierarchy (
    DocumentNo VARCHAR(50),
	PositionNo VARCHAR(50),
    TransactionTypeShort VARCHAR(5),
    referencedocumentid VARCHAR(50),
	referencePosition VARCHAR(50),
    root VARCHAR(50),
    Path VARCHAR(150)  -- Add a new column to store the path
)
--CREATE TABLE #possible_flows (
--	flow_id int identity(1,1)
--    TransactionTypeShort VARCHAR(5),
--	fullpath VARCHAR(150),
--    parent_flow_id int null
--)

-- Initialize a variable to control the loop
DECLARE @flag BIT;
SET @flag = 1;

-- Insert the base of the hierarchy
INSERT INTO #hierarchy
SELECT distinct
    DocumentNo, 
	DocumentItemPosition,
    [TransactionTypeShort], 
    '',
	'',
    DocumentNo AS root,
    [TransactionTypeShort] AS Path  -- Initialize the path with the TransactionTypeShort
FROM 
    [PL].[PL_V_SALES_TRANSACTIONS] 
WHERE 1=1
    AND isnull(referencedocumentid,'') =''
    AND SOURCE = 'SAP'
    AND MONTH(TransactionDate) = 10 
    AND YEAR(TransactionDate) = 2023 

-- Create a table to hold the new records
CREATE TABLE #new_records (
    DocumentNo VARCHAR(50),
	PositionNo VARCHAR(50),
    TransactionTypeShort VARCHAR(5),
    referencedocumentid VARCHAR(50),
	referencePosition VARCHAR(50),
    root VARCHAR(50),
    Path VARCHAR(150)  -- Add a new column to store the path
)

-- Loop until no more records can be added
WHILE @flag = 1
BEGIN
    -- Clear the new records table
    DELETE FROM #new_records;

    -- Insert the new records
    INSERT INTO #new_records
    SELECT distinct
        d.DocumentNo, 
		d.DocumentItemPosition,
        d.[TransactionTypeShort], 
        d.referencedocumentid,
		ISNULL(vaitm.VGPOS,ISNULL(vcitm.VGPOS,vditm.VGPOS)),
        h.root,
        h.Path + '_' + d.[TransactionTypeShort]  -- Concatenate the TransactionTypeShort to the path
    FROM 
        [PL].[PL_V_SALES_TRANSACTIONS] d

	LEFT JOIN #hierarchy h2 on h2.DocumentNo = d.DocumentNo and h2.PositionNo = d.DocumentItemPosition
			
	LEFT JOIN 
		L0.[L0_S4HANA_2LIS_11_VAITM] vaitm	on vaitm.VBELN = d.DocumentNo and vaitm.POSNR = d.DocumentItemPosition
	LEFT JOIN 
		L0.[L0_S4HANA_2LIS_12_VCITM] vcitm	on vcitm.VBELN = d.DocumentNo and vcitm.POSNR = d.DocumentItemPosition
	LEFT JOIN 
		L0.[L0_S4HANA_2LIS_13_VDITM] vditm	on vditm.VBELN = d.DocumentNo and vditm.POSNR = d.DocumentItemPosition
	 INNER JOIN 
        #hierarchy h ON d.referencedocumentid = h.DocumentNo and ISNULL(vaitm.VGPOS,ISNULL(vcitm.VGPOS,vditm.VGPOS)) = h.PositionNo
    WHERE 1=1
       -- d.DocumentNo NOT IN (SELECT DocumentNo FROM #hierarchy)
	   AND h2.DocumentNo is null
        AND d.SOURCE = 'SAP'

    -- If no new records were inserted, exit the loop
    IF (SELECT COUNT(*) FROM #new_records) = 0
        SET @flag = 0;
    ELSE
        INSERT INTO #hierarchy SELECT * FROM #new_records;
END

-- Select the final result
select 
	'' AS DocumentNo,
	'' AS PositionNo,
	'Root' AS TransactionTypeShort,
	'' AS ReferenceDocumentId,
	'' AS referenceposition,
	'' AS Root,
	'Root' AS  Path,
	'' AS CD_DOCUMENT,
	'' AS CD_REFERENCE
UNION
SELECT 
	DocumentNo,
	PositionNo,
	TransactionTypeShort,
	ReferenceDocumentId,
	referenceposition,
	Root,
	Path,
	CD_DOCUMENT = CONCAT(DocumentNo,'#',cast(PositionNo as int)),
	CD_REFERENCE = CASE WHEN isnull(ReferenceDocumentId,'') = '' THEN '' ELSE CONCAT(ReferenceDocumentId,'#',cast(referenceposition as int)) END

FROM #hierarchy ORDER BY root;












--drop table #hierarchy
--drop table #new_records
--drop table #new_records




