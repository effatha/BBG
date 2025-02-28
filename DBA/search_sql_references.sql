Declare @keyword as nvarchar(max)  = 'vChalTec_Inbound_Deliveries'

SELECT
    m.object_id AS [ID], 
	ob.name AS [Procedure Name], 
    definition as [Definition]
FROM
    [CT dwh 00 Meta].sys.sql_modules m
	join [CT dwh 00 Meta].sys.objects ob on ob.object_id = m.object_id
WHERE
    definition LIKE '%'+@keyword+'%'

UNION ALL

SELECT
    m.object_id AS [ID], 
	ob.name AS [Procedure Name], 
    definition as [Definition]
FROM
    [CT dwh 01 Stage].sys.sql_modules m
	join [CT dwh 01 Stage].sys.objects ob on ob.object_id = m.object_id
WHERE
    definition LIKE '%'+@keyword+'%'

	UNION ALL
SELECT
    m.object_id AS [ID], 
	ob.name AS [Procedure Name], 
    definition as [Definition]
FROM
    [CT dwh 02 Data].sys.sql_modules m
	join [CT dwh 02 Data].sys.objects ob on ob.object_id = m.object_id
WHERE
    definition LIKE '%'+@keyword+'%'
	UNION ALL
SELECT
    m.object_id AS [ID], 
	ob.name AS [Procedure Name], 
    definition as [Definition]
FROM
    [CT dwh 03 Intelligence].sys.sql_modules m
	join [CT dwh 03 Intelligence].sys.objects ob on ob.object_id = m.object_id
WHERE
    definition LIKE '%'+@keyword+'%'
UNION ALL
SELECT
    m.object_id AS [ID], 
	ob.name AS [Procedure Name], 
    definition as [Definition]
FROM
    [CT dwh 04 Analysis].sys.sql_modules m
	join [CT dwh 04 Analysis].sys.objects ob on ob.object_id = m.object_id
WHERE
    definition LIKE '%'+@keyword+'%'


SELECT s.step_id as 'Step ID',
j.[name] as 'SQL Agent Job Name',
s.database_name as 'DB Name',
s.command as 'Command'

FROM   msdb.dbo.sysjobsteps AS s
INNER JOIN msdb.dbo.sysjobs AS j ON  s.job_id = j.job_id
WHERE  s.command LIKE '%'+@keyword+'%'




select
 VIEW_CATALOG,
 VIEW_SCHEMA,
 VIEW_NAME
from [CT dwh 02 Data].INFORMATION_SCHEMA.VIEW_TABLE_USAGE
where
 --TABLE_SCHEMA = 'Person' and
 TABLE_NAME like '%'+@keyword+'%'

UNION ALL
select
 VIEW_CATALOG,
 VIEW_SCHEMA,
 VIEW_NAME
from [CT dwh 03 Intelligence].INFORMATION_SCHEMA.VIEW_TABLE_USAGE
where
 --TABLE_SCHEMA = 'Person' and
 TABLE_NAME like '%'+@keyword+'%'

 UNION ALL
select
 VIEW_CATALOG,
 VIEW_SCHEMA,
 VIEW_NAME
from [CT dwh 04 Analysis].INFORMATION_SCHEMA.VIEW_TABLE_USAGE
where
 --TABLE_SCHEMA = 'Person' and
 TABLE_NAME like '%'+@keyword+'%'



