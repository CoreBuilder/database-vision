
GO

CREATE Proc [dbo].[sp_Shrink_Log] (@db_Name VarChar(128)='ALL', @logFileSize VarChar(5)='2048')
As
Declare @cmd VarChar(512),@db VarChar(128)='%'

if (@db_name<>'ALL') 
Begin
	Set @db=@db_name+'%'
End

DBCC FREESESSIONCACHE

Declare crDatabases Cursor For 

SELECT 
      'USE [' + d.name + N']' + CHAR(13) + CHAR(10) 
    + 'DBCC SHRINKFILE (N''' + mf.name + N''' , ' + @logFileSize + ') WITH NO_INFOMSGS' 
    + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) 
FROM 
         sys.master_files mf 
    JOIN sys.databases d 
        ON mf.database_id = d.database_id 
WHERE mf.type_desc ='LOG' AND d.state_desc='ONLINE' AND d.name like @db And d.database_id >1  And d.is_read_only =0 And d.is_in_standby =0 And d.user_access =0 And 
d.name Not in
(
	SELECT
	dbcs.database_name AS [DatabaseName]
	FROM master.sys.availability_groups AS AG
	LEFT OUTER JOIN master.sys.dm_hadr_availability_group_states as agstates ON AG.group_id = agstates.group_id
	INNER JOIN master.sys.availability_replicas AS AR ON AG.group_id = AR.group_id
	INNER JOIN master.sys.dm_hadr_availability_replica_states AS arstates  ON AR.replica_id = arstates.replica_id AND arstates.is_local = 1
	INNER JOIN master.sys.dm_hadr_database_replica_cluster_states AS dbcs ON arstates.replica_id = dbcs.replica_id
	LEFT OUTER JOIN master.sys.dm_hadr_database_replica_states AS dbrs
	   ON dbcs.replica_id = dbrs.replica_id AND dbcs.group_database_id = dbrs.group_database_id

)


Open crDatabases
Fetch Next From crDatabases
Into @cmd 

While @@FETCH_STATUS =0 
Begin 

	Execute (@cmd)

	Fetch Next From crDatabases 
	Into @cmd 
End 

Close crDatabases
DeAllocate crDatabases
