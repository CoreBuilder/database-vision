-- =============================================
-- Fix Heap Fragmentation
-- 1.ALTER TABLE...REBUILD (SQL 2008+).
-- 2.CREATE CLUSTERED INDEX, then DROP INDEX.
-- =============================================

-- Kesin çözüm doğru index'i bulundurmak tabloda

-- Find Heap Fragmentation
select  o.name ,
        ips.index_type_desc ,
        ips.avg_fragmentation_in_percent ,
        ips.record_count ,
        ips.page_count ,
        ips.compressed_page_count
from    sys.dm_db_index_physical_stats(db_id(), null, null, null, 'DETAILED') ips
        join sys.objects o on o.object_id = ips.object_id
where   ips.index_id = 0
        and ips.avg_fragmentation_in_percent > 0
order by ips.avg_fragmentation_in_percent desc;


-- Fix Heap Fragmentation
-- 1.ALTER TABLE...REBUILD (SQL 2008+).
-- 2.CREATE CLUSTERED INDEX, then DROP INDEX.

-- 1. 
ALTER TABLE dbo.ReportX REBUILD;
GO
-- 2.
CREATE CLUSTERED INDEX indxRep ON dbo.ReportX(ID);
GO
DROP INDEX indxRep ON dbo.ReportX;
GO