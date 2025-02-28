
SELECT SchemaName = SCHEMA_NAME(t.schema_id)
 , [ReplicatedTable] = t.[name]
 , [RebuildStatement] = 'SELECT TOP 1 * FROM ' + '[' + SCHEMA_NAME(t.schema_id) + '].[' + t.[name] +']'
 ,c.*
FROM sys.tables t 
JOIN sys.pdw_replicated_table_cache_state c 
  ON c.object_id = t.object_id
JOIN sys.pdw_table_distribution_properties p
  ON p.object_id = t.object_id
WHERE c.[state] = 'NotReady'
AND p.[distribution_policy_desc] = 'REPLICATE'
and SCHEMA_NAME(t.schema_id) = 'TEST'



