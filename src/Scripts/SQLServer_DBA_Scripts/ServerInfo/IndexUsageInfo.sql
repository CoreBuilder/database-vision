-- =============================================
-- Index'lerin kullanılıp kullanılmadığını dönen sorgular
-- =============================================

-- Not Used Indexes
SELECT  o.name Object_Name,
        i.name Index_name, 
        i.Type_Desc 
FROM sys.objects AS o
     JOIN sys.indexes AS i
ON o.object_id = i.object_id 
   LEFT OUTER JOIN 
   sys.dm_db_index_usage_stats AS s    
ON i.object_id = s.object_id   
   AND i.index_id = s.index_id
WHERE  o.type = 'u'
AND i.type IN (1, 2) -- CLUSTERED, NONCLUSTERED
AND (s.user_seeks = 0 AND s.user_scans = 0 AND s.user_lookups = 0 )

-- Used Indexes
SELECT o.name Object_Name,
        SCHEMA_NAME(o.schema_id) Schema_name,
        i.name Index_name, 
        i.Type_Desc, 
        s.user_seeks,
        s.user_scans, 
        s.user_lookups, 
        s.user_updates  
  FROM sys.objects AS o
      JOIN sys.indexes AS i
  ON o.object_id = i.object_id 
      JOIN
   sys.dm_db_index_usage_stats AS s    
  ON i.object_id = s.object_id   
   AND i.index_id = s.index_id
  WHERE  o.type = 'u'
   AND i.type IN (1, 2) 
   AND(s.user_seeks > 0 or s.user_scans > 0 or s.user_lookups > 0 );


-- All index info
 select  s.Name + N'.' + t.name as [Table]
    ,i.name as [Index] 
    ,i.is_unique as [IsUnique]
    ,ius.user_seeks as [Seeks], ius.user_scans as [Scans]
    ,ius.user_lookups as [Lookups]
    ,ius.user_seeks + ius.user_scans + ius.user_lookups as [Reads]
    ,ius.user_updates as [Updates], ius.last_user_seek as [Last Seek]
    ,ius.last_user_scan as [Last Scan], ius.last_user_lookup as [Last Lookup]
    ,ius.last_user_update as [Last Update]
from 
    sys.tables t with (nolock) join sys.indexes i with (nolock) on
        t.object_id = i.object_id
    join sys.schemas s with (nolock) on 
        t.schema_id = s.schema_id
    left outer join sys.dm_db_index_usage_stats ius on
        ius.database_id = db_id() and
        ius.object_id = i.object_id and 
        ius.index_id = i.index_id
order by
    s.name, t.name, i.index_id

	
-- Index Row,UsedSpace,ReservedSpace 
;with SpaceInfo(ObjectId, IndexId, TableName, IndexName
    ,Rows, TotalSpaceMB, UsedSpaceMB)
as
( 
    select  
        t.object_id as [ObjectId]
        ,i.index_id as [IndexId]
        ,s.name + '.' + t.Name as [TableName]
        ,i.name as [Index Name]
        ,sum(p.[Rows]) as [Rows]
        ,sum(au.total_pages) * 8 / 1024 as [Total Space MB]
        ,sum(au.used_pages) * 8 / 1024 as [Used Space MB]
    from    
        sys.tables t with (nolock) join 
            sys.schemas s with (nolock) on 
                s.schema_id = t.schema_id
            join sys.indexes i with (nolock) on 
                t.object_id = i.object_id
            join sys.partitions p with (nolock) on 
                i.object_id = p.object_id and 
                i.index_id = p.index_id
            cross apply
            (
                select 
                    sum(a.total_pages) as total_pages
                    ,sum(a.used_pages) as used_pages
                from sys.allocation_units a with (nolock)
                where p.partition_id = a.container_id 
            ) au
    where   
        i.object_id > 255
    group by
        t.object_id, i.index_id, s.name, t.name, i.name
)
select 
    ObjectId, IndexId, TableName, IndexName
    ,Rows, TotalSpaceMB, UsedSpaceMB
    ,TotalSpaceMB - UsedSpaceMB as [ReservedSpaceMB]
from 
    SpaceInfo		
order by
    TotalSpaceMB desc
