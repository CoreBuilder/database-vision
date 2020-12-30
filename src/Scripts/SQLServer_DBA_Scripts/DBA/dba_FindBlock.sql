


CREATE PROCEDURE [dbo].[DBA_FindBlock]
AS
BEGIN
SELECT s.spid,
       BlockingSPID = s.blocked,
       DatabaseName = DB_NAME(s.dbid),
       s.program_name,
       s.loginame,
       ObjectName = OBJECT_NAME(objectid, s.dbid),
       Definition = CAST(text AS VARCHAR(MAX))
INTO #Processes
FROM sys.sysprocesses s WITH (NOLOCK)
    CROSS APPLY sys.dm_exec_sql_text(sql_handle);
WITH Blocking (spid, BlockingSPID, BlockingStatement, RowNo, LevelRow)
AS (SELECT s.spid,
           s.BlockingSPID,
           s.Definition,
           ROW_NUMBER() OVER (ORDER BY s.spid),
           0 AS LevelRow
    FROM #Processes s
        JOIN #Processes s1
            ON s.spid = s1.BlockingSPID
    WHERE s.BlockingSPID = 0
    UNION ALL
    SELECT r.spid,
           r.BlockingSPID,
           r.Definition,
           d.RowNo,
           d.LevelRow + 1
    FROM #Processes r
        JOIN Blocking d
            ON r.BlockingSPID = d.spid
    WHERE r.BlockingSPID > 0)
SELECT *
FROM Blocking
ORDER BY RowNo,
         LevelRow;

DROP TABLE #Processes;
END
GO


