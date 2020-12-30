-- =============================================
-- PK Harici indexleri kolonlar ile birlikte dönen CTE
-- =============================================


WITH CTE as (
			SELECT		ic.[index_id] + ic.[object_id] AS [IndexId],t.[name] AS [TableName]
						,i.[name] AS [IndexName],c.[name] as [ColumnName],i.[type_desc]
						,i.[is_primary_key],i.[is_unique]
			FROM  [sys].[indexes] i 
			INNER JOIN [sys].[index_columns] ic 
					ON	i.[index_id]	=	ic.[index_id]
					AND	i.[object_id]	=	ic.[object_id]
			INNER JOIN [sys].[columns] c
					ON	ic.[column_id]	=	c.[column_id]
					AND	i.[object_id]	=	c.[object_id]
			INNER JOIN [sys].[tables] t
					ON	i.[object_id] = t.[object_id]
)
SELECT	c.[TableName],c.[IndexName],c.[type_desc],c.[is_primary_key],c.[is_unique]
		,STUFF( ( SELECT ','+ a.[ColumnName] FROM CTE a WHERE c.[IndexId] = a.[IndexId] FOR XML PATH('')),1 ,1, '') AS [Columns]
FROM	CTE c
WHERE c.is_primary_key = 0 -- Exclude PK
GROUP	BY c.[IndexId],c.[TableName],c.[IndexName],c.[type_desc],c.[is_primary_key],c.[is_unique]
ORDER	BY c.[TableName] ASC,c.[is_primary_key] DESC;


-- Index Fragmentation

SELECT	dbschemas.[name] as 'Schema', object_name(IPS.object_id) AS [TableName], SI.name AS [IndexName], IPS.Index_type_desc
,		IPS.avg_fragmentation_in_percent, IPS.page_count, IPS.avg_fragment_size_in_pages
,		IPS.avg_page_space_used_in_percent, IPS.record_count, IPS.ghost_record_count
,		IPS.fragment_count, IPS.avg_fragment_size_in_pages 
FROM sys.dm_db_index_physical_stats(db_id(DB_NAME()), NULL, NULL, NULL , 'DETAILED') IPS   
JOIN sys.tables ST WITH (nolock) ON IPS.object_id = ST.object_id
JOIN sys.schemas dbschemas WITH (nolock) on ST.[schema_id] = dbschemas.[schema_id]   
JOIN sys.indexes SI WITH (nolock) ON IPS.object_id = SI.object_id AND IPS.index_id = SI.index_id
WHERE ST.is_ms_shipped = 0 
order by IPS.avg_fragmentation_in_percent desc


-- Unused index AND DROP INDEX script generate

SELECT	o.name, indexname=i.name, i.index_id, reads=user_seeks + user_scans + user_lookups
,		writes =  user_updates   
,		rows = (SELECT SUM(p.rows) FROM sys.partitions p WHERE p.index_id = s.index_id AND s.object_id = p.object_id)
,		CASE WHEN s.user_updates < 1 THEN 100 ELSE 1.00 * (s.user_seeks + s.user_scans + s.user_lookups) / s.user_updates END AS reads_per_write
,		'DROP INDEX ' + QUOTENAME(i.name) + ' ON ' + QUOTENAME(c.name) + '.' + QUOTENAME(OBJECT_NAME(s.object_id)) as 'drop statement'
FROM sys.dm_db_index_usage_stats s  INNER JOIN sys.indexes i ON i.index_id = s.index_id AND s.object_id = i.object_id   
INNER JOIN sys.objects o on s.object_id = o.object_id
INNER JOIN sys.schemas c on o.schema_id = c.schema_id
WHERE OBJECTPROPERTY(s.object_id,'IsUserTable') = 1
AND s.database_id = DB_ID()   AND i.type_desc = 'nonclustered'
AND i.is_primary_key = 0AND i.is_unique_constraint = 0
AND (SELECT SUM(p.rows) FROM sys.partitions p WHERE p.index_id = s.index_id AND s.object_id = p.object_id) > 10000
ORDER BY reads

-- Potentially redundant indexes by checking the indexes that have the same leftmost columns.
select
    s.Name + N'.' + t.name as [Table]
    ,i1.index_id as [Index1 ID], i1.name as [Index1 Name]
    ,dupIdx.index_id as [Index2 ID], dupIdx.name as [Index2 Name] 
    ,c.name as [Column]
from 
    sys.tables t join sys.indexes i1 on
        t.object_id = i1.object_id
    join sys.index_columns ic1 on
        ic1.object_id = i1.object_id and
        ic1.index_id = i1.index_id and 
        ic1.index_column_id = 1  
    join sys.columns c on
        c.object_id = ic1.object_id and
        c.column_id = ic1.column_id      
    join sys.schemas s on 
        t.schema_id = s.schema_id
    cross apply
    (
        select i2.index_id, i2.name
        from
            sys.indexes i2 join sys.index_columns ic2 on       
                ic2.object_id = i2.object_id and
                ic2.index_id = i2.index_id and 
                ic2.index_column_id = 1  
        where	
            i2.object_id = i1.object_id and 
            i2.index_id > i1.index_id and 
            ic2.column_id = ic1.column_id
    ) dupIdx     
order by
    s.name, t.name, i1.index_id