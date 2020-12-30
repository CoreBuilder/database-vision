-- ============================================
-- Table ile ilgili row ve column bilgisi döner
-- ============================================

-- Table Row Count
SELECT	o.name
,		ddps.partition_number
,		ddps.row_count 
FROM sys.indexes AS i
  INNER JOIN sys.objects AS o ON i.OBJECT_ID = o.OBJECT_ID
  INNER JOIN sys.dm_db_partition_stats AS ddps ON i.OBJECT_ID = ddps.OBJECT_ID
  AND i.index_id = ddps.index_id 
WHERE i.index_id < 2  AND o.is_ms_shipped = 0 ORDER BY 3 DESC

-- Table Column Count
SELECT TABLE_CATALOG, TABLE_SCHEMA, TABLE_NAME, COUNT(COLUMN_NAME ) ColCount
FROM INFORMATION_SCHEMA.COLUMNS
GROUP BY TABLE_CATALOG, TABLE_SCHEMA, TABLE_NAME
ORDER BY TABLE_CATALOG, TABLE_SCHEMA, TABLE_NAME;

-- List Table && Columns (identity,nullable)
SELECT b.name AS TableName,
       a.name AS ColumnName,
	   a.is_identity,
	   a.is_nullable
FROM   sys.columns a
       JOIN sys.tables b
         ON a.object_id = b.object_id
ORDER  BY tablename,
          column_id
