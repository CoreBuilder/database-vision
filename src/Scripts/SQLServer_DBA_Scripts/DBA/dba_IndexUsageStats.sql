
GO

-- EXEC Firm_DBA_IndexUsageStats 'ProcName'

CREATE PROCEDURE [dbo].[Firm_DBA_IndexUsageStats]
(
	@tablename VARCHAR(1000)
)
AS
BEGIN
    

set nocount on

if object_id('tempdb..#helpindex') > 0 drop table #helpindex

create table #helpindex (
   index_name varchar (1000) not null primary key
 , index_description varchar (1000) null
 , index_keys varchar (1000) null
)

insert #helpindex
exec sp_helpindex @tablename

alter table #helpindex add inccols varchar(1000) null

declare cr cursor for
select si.name, sc.name
from sysobjects so
join sysindexes si on so.id = si.id
join sys.index_columns ic on si.id = ic.object_id and si.indid = ic.index_id
join sys.columns sc on ic.object_id = sc.object_id and ic.column_id = sc.column_id
where so.xtype = 'U'
  and so.name = @tablename
  and ic.is_included_column = 1
order by si.name, ic.index_column_id

declare @siname varchar(1000), @scname varchar(1000)

OPEN cr

FETCH NEXT FROM cr INTO @siname, @scname

WHILE @@fetch_status = 0
 BEGIN

  UPDATE #helpindex SET inccols = ISNULL(inccols , '') + @scname + ', ' WHERE index_name = @siname

  FETCH NEXT FROM cr INTO @siname, @scname
 END

UPDATE #helpindex SET inccols = LEFT(inccols, DATALENGTH(inccols) - 2)
WHERE RIGHT(inccols, 2) = ', '

CLOSE cr
DEALLOCATE cr

SELECT hi.index_name, hi.index_description, hi.index_keys, hi.inccols AS included_columns, ius.index_id, user_seeks, user_scans, user_lookups, user_updates
, last_user_seek, last_user_scan, last_user_lookup
FROM sys.dm_db_index_usage_stats ius
JOIN sysindexes si ON ius.object_id = si.id AND ius.index_id = si.indid
JOIN sysobjects so ON si.id = so.id
JOIN #helpindex hi ON si.name = hi.index_name COLLATE DATABASE_DEFAULT
WHERE ius.database_id = DB_ID()
  AND so.name = @tablename

DROP TABLE #helpindex

/*
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
*/


END;
GO


