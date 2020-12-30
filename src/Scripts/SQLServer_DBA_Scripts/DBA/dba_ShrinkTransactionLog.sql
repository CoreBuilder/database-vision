
GO


CREATE PROCEDURE [dbo].[Firm_DBA_ShrinkTransactionLog]
AS
BEGIN
 
 /*
	-- List Log Files
	SELECT name FROM sys.master_files WHERE type_desc = 'LOG'

	SELECT 
    db.name AS                                   [Database Name], 
    mf.name AS                                   [Logical Name], 
    mf.type_desc AS                              [File Type], 
    mf.physical_name AS                          [Path], 
    CAST(
        (mf.Size * 8
        ) / 1024.0 AS DECIMAL(18, 1)) AS         [Initial Size (MB)], 
    'By '+IIF(
            mf.is_percent_growth = 1, CAST(mf.growth AS VARCHAR(10))+'%', CONVERT(VARCHAR(30), CAST(
        (mf.growth * 8
        ) / 1024.0 AS DECIMAL(18, 1)))+' MB') AS [Autogrowth], 
    IIF(mf.max_size = 0, 'No growth is allowed', IIF(mf.max_size = -1, 'Unlimited', CAST(
        (
                CAST(mf.max_size AS BIGINT) * 8
        ) / 1024 AS VARCHAR(30))+' MB')) AS      [MaximumSize]
FROM 
     sys.master_files AS mf
     INNER JOIN sys.databases AS db ON
            db.database_id = mf.database_id

 */

DECLARE @logFileName NVARCHAR(2000)
,		@dbNAME NVARCHAR(2000)
,		@sql NVARCHAR(2000)

CREATE TABLE #LogFileCheck (dbNAME NVARCHAR(1000), logName NVARCHAR(2000), fileSizeInMB DECIMAL(18,1))

INSERT INTO #LogFileCheck
SELECT db.name, mf.name, CAST( (mf.Size * 8) / 1024.0 AS DECIMAL(18, 1) )
FROM 
     sys.master_files AS mf
     INNER JOIN sys.databases AS db ON
            db.database_id = mf.database_id
WHERE mf.type_desc = 'LOG' AND (db.name = 'Firm2011' OR db.name = 'TestDB')

DECLARE checkFileC CURSOR FOR 
SELECT dbNAME, c.logName FROM #LogFileCheck c WHERE c.fileSizeInMB > 500 -- 500 MB
OPEN checkFileC 
FETCH NEXT FROM checkFileC INTO @dbNAME, @logFileName
WHILE @@FETCH_STATUS = 0
BEGIN
	
	SET @sql = ''
	SELECT @sql = 'USE '+@dbNAME+'; DBCC SHRINKFILE ('+@logFileName+', 2);'
	EXEC sp_sqlexec @Sql

FETCH NEXT FROM checkFileC INTO @dbNAME, @logFileName
END
CLOSE checkFileC
DEALLOCATE checkFileC

DROP TABLE #LogFileCheck

END

GO


