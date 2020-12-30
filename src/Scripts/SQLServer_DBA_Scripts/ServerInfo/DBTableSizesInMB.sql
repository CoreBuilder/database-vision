-- =============================================
-- DB ve Table'lar için size'ları MB olarak gösterir
-- =============================================


select 
      convert(varchar,CAST((sum(reserved_page_count) * 8.0 / 1024) as decimal(18,2))) + ' MB' 
from 
      sys.dm_db_partition_stats 
GO 

select 
      sys.objects.name, sum(reserved_page_count) * 8.0 / 1024 
from 
      sys.dm_db_partition_stats, sys.objects 
where 
      sys.dm_db_partition_stats.object_id = sys.objects.object_id 
group by sys.objects.name
order by 2 DESC