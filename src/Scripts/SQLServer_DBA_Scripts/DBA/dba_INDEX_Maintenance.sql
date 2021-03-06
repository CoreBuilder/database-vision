

GO


CREATE PROC [dbo].[dba_INDEX_Maintenance] @DataBaseName nVarChar(256)='', @TableName nVarChar(256) ='', @Rebuild_With VarChar(16) ='ONLINE', 
@LikeType VarChar(5)='', @LikeForObject VarChar(16)='ALL', @FillFactor Smallint=0

AS BEGIN
        SET NOCOUNT ON;
        DECLARE
			@DBName nVarChar(256),
			@DBID VarChar(5),
			@Result VarChar(MAX),
			@tbName nVarChar(256),
			@tName nVarChar(256),
			@WhereTable nVarChar(256),
			@TableCount int,
			@RebuildWith VarChar(256),
			@xFillFactor VarChar(32) ='',
			@id_plan_handle varbinary(64) =0x0, 
            @OBJECT_ID INT,
            @INDEX_NAME nVarChar(256),
            @SCHEMA_NAME nVarChar(256),
            @OBJECT_NAME nVarChar(256),
            @AVG_FRAG float,
            @command VarChar(MAX),
            @RebuildCount int,
			@RebuildCountAll int,
            @ReOrganizeCount int,
            @ReOrganizeCountAll int,
			@StartTime DateTime,
			@StartTimeAll DateTime,
			@EndTime DateTime,
			@DurationSeconds int,
			@Duration VarChar(16),
			@emailSubject  VarChar(256),
			@emailBody VarChar(MAX)

		 Declare @tbl Table
		 (
			Dname nVarChar(256)
		 )

		Set @Result ='Job Parameters; @DatabaseName= ' +@DataBaseName + ','+ CHAR(13) +' @TableName= ' 
				+ @TableName + ','+ CHAR(13) +' @Rebuild_With= ' + @Rebuild_With + ','+ CHAR(13) +' @LikeType=  ' 
				+ @LikeType +Char(13)+Char(13)
		Set @StartTimeAll =GetDate()
		
		Create table  #tempim   (
			[ID] [INT] IDENTITY(1,1) NOT NULL PRIMARY KEY,
			[INDEX_NAME] nVarChar(256) NULL,
			[OBJECT_ID] INT NULL,
			[SCHEMA_NAME] nVarChar(256) NULL,
			[OBJECT_NAME] nVarChar(256) NULL,
			[AVG_FRAG] float
		) 

		Set @LikeForObject =UPPER(@LikeForObject) 
		Set @DBName = (Case When @DataBaseName ='' Then '%' Else @DataBaseName End)
		Set @tbName = (Case When @TableName='' Then '%' Else @TableName End)
		Set @WhereTable ='  Like ' +Char(39)+ @tbName + Char(39)

		 if (@LikeType='NOT')
		 Begin
			if(@LikeForObject='')
				Set @LikeForObject='ALL'
				 
			if (@DataBaseName ='')
			Begin
				INSERT INTO @tbl Select name From master.sys.databases Where name like @DBName And database_id>3 And state_desc ='ONLINE' And is_read_only =0 And is_in_standby =0 And user_access =0 And 
				[name] Not in
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
			End

			if (@DataBaseName <>'' And ( @LikeForObject='DATABASE' Or @LikeForObject='ALL')) 
			Begin	
				INSERT INTO @tbl 
				Select name From master.sys.databases Where name NOT like @DBName And database_id>3 And state_desc ='ONLINE' And is_read_only =0 And is_in_standby =0 And user_access =0 And 
				[name] Not in
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
			End
			if (@TableName <>'' And ( @LikeForObject='TABLE' Or @LikeForObject='ALL')) 
			Begin
				Set @WhereTable=' Not Like '+Char(39)+@tbName+Char(39)
				INSERT INTO @tbl Select name From master.sys.databases Where name like @DBName And database_id>3 And state_desc ='ONLINE' And is_read_only =0 And is_in_standby =0 And user_access =0 And 
				[name] Not in
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
			End

		 End  Else 
		 Begin

			INSERT INTO @tbl Select name From master.sys.databases Where name like @DBName And database_id>3 And state_desc ='ONLINE' And is_read_only =0 And is_in_standby =0 And user_access =0 And 
				[name] Not in
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
		 End


		Set @Rebuild_With = UPPER(@Rebuild_With)


		if (@FillFactor<>0)
		Begin
			Set @xFillFactor=',FILLFACTOR=' + Convert(VarChar(3),@FillFactor)
		End

		Set @RebuildWith =
			(Case 
				When @Rebuild_With ='' Then ' REBUILD WITH (ONLINE = ON ' + @xFillFactor + '  , MAXDOP=32) ' 
				When @Rebuild_With='ONLINE' Then ' REBUILD WITH (ONLINE = ON' + @xFillFactor + ', MAXDOP=32) '
				When @Rebuild_With='OFFLINE' Then ' REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON,MAXDOP=32) '
				ELSE ' REBUILD WITH (ONLINE = ON' + @xFillFactor + ', MAXDOP=32) ' 
			END)

		Set @RebuildCount=0
		Set @ReOrganizeCount=0
		Set @RebuildCountAll=0
		Set @ReOrganizeCountAll=0
		

 	    Declare dbs  CURSOR FAST_FORWARD FOR	
		Select Dname  From @tbl Order By Dname  -- Where database_id >4 And name like @DBName And state_desc ='ONLINE'

		OPEN dbs
        FETCH NEXT FROM dbs INTO @DBName
		WHILE @@FETCH_STATUS = 0
		Begin
			Set @DBID =Convert(VarChar(5),DB_ID(@DBName))
			Set @StartTime =GetDate()
			Set @command =''
			Set @command=
				'Use [' + @DBName + '] ;
				INSERT INTO #tempim (OBJECT_ID, INDEX_NAME, SCHEMA_NAME, OBJECT_NAME, AVG_FRAG)
				SELECT
					ps.object_id,
					i.name as IndexName,
					OBJECT_SCHEMA_NAME(ps.object_id) as ObjectSchemaName,
					OBJECT_NAME (ps.object_id) as ObjectName,
					ps.avg_fragmentation_in_percent
				FROM sys.dm_db_index_physical_stats ('+ @DBID +', NULL, NULL , NULL, ''LIMITED'') ps
				INNER JOIN sys.indexes i ON i.object_id=ps.object_id And i.index_id=ps.index_id
				WHERE avg_fragmentation_in_percent > 5 And ps.index_id > 0
					and ps.database_id='+ @DBID +' And OBJECT_NAME (ps.object_id) '+@WhereTable+'  
				ORDER BY OBJECT_NAME (ps.object_id) 
				Option (MAXDOP 32)'

			exec(@command)

			Set @tName=(SELECT Top 1 [OBJECT_NAME] FROM #tempim)
			Set @TableCount=(SELECT COUNT(*) FROM #tempim)
			 
			DECLARE c CURSOR FAST_FORWARD FOR
				SELECT OBJECT_ID,INDEX_NAME, SCHEMA_NAME, [OBJECT_NAME], AVG_FRAG
				FROM #tempim
				
			OPEN c
			FETCH NEXT FROM c INTO @OBJECT_ID, @INDEX_NAME, @SCHEMA_NAME, @OBJECT_NAME, @AVG_FRAG
			WHILE @@FETCH_STATUS = 0
			BEGIN
				--Reorganize or Rebuild index
				IF @AVG_FRAG>30 BEGIN
					SELECT @command = 'Use [' + @DBName + ']; ALTER INDEX [' + @INDEX_NAME +'] ON ['
									  + @SCHEMA_NAME + '].[' + @OBJECT_NAME + '] ' + @RebuildWith ;
					SET @RebuildCount = @RebuildCount+1
					SET @RebuildCountAll  = @RebuildCountAll +1

				END ELSE BEGIN
					SELECT @command = 'Use [' + @DBName + '] ; ALTER INDEX [' + @INDEX_NAME +'] ON ['
									  + @SCHEMA_NAME + '].[' + @OBJECT_NAME + '] REORGANIZE ';
					SET @ReOrganizeCount = @ReOrganizeCount+1
					SET @ReOrganizeCountAll  = @ReOrganizeCountAll +1

				END
                                   
				BEGIN TRY
					EXEC (@command);    
				END TRY
				BEGIN CATCH
				END CATCH

				-- UPDATE STATISTICS, Clear ExecPlans 
				if (@tName<>@OBJECT_NAME) Or (@TableCount=1)
				Begin
					Select @command= 'Use [' + @DBName + ']; UPDATE STATISTICS  [' + @SCHEMA_NAME +'].['+@OBJECT_NAME+'] WITH FULLSCAN , MAXDOP=32'
				
					BEGIN TRY
						EXEC (@command);   
					END TRY
					BEGIN CATCH
					END CATCH
					Set @tName =@OBJECT_NAME
				End

				FETCH NEXT FROM c INTO @OBJECT_ID, @INDEX_NAME, @SCHEMA_NAME, @OBJECT_NAME, @AVG_FRAG
			END
			CLOSE c
			DEALLOCATE c

			-- UPDATE STATISTICS 
			if  (@TableCount>1)
			Begin
				Select @command= 'Use [' + @DBName + ']; UPDATE STATISTICS  [' + @SCHEMA_NAME +'].['+@OBJECT_NAME+'] WITH FULLSCAN , MAXDOP=32'
			
				BEGIN TRY
					EXEC (@command);   
				END TRY
				BEGIN CATCH
				END CATCH	
				Set @tName =@OBJECT_NAME
			End
         
			Truncate Table #tempim
			
  			 Set @EndTime =GetDate()
			 Set @DurationSeconds =DATEDIFF(second,@StartTime, @EndTime)    
			 Set @Duration =
			 ( 
				 Select	right('0' + rtrim(convert(char(2), @DurationSeconds / (60 * 60))), 2) + ':' + 
					right('0' + rtrim(convert(char(2), (@DurationSeconds / 60) % 60)), 2) + ':' + 
					right('0' + rtrim(convert(char(2), @DurationSeconds % 60)),2) AS [HH:MM:SS]
			 )	

			Set @Result =@Result  + @DBName + '  ' +(cast(@RebuildCount  as VarChar(5))+' index Rebuild,'+cast(@ReOrganizeCount  as VarChar(5))
							+' index Reorganize edilmistir. '+Char(13)+ 'Süre :' + @Duration +'   ([HH:MM:SS])'+Char(13)+Char(13))

			Set @RebuildCount=0
			Set @ReOrganizeCount=0

			FETCH NEXT FROM dbs INTO @DBName
         END

		 
		 Close dbs 
		 DeAllocate dbs

		 Drop Table #tempim
	 
		 Set @EndTime =GetDate()
		 Set @DurationSeconds =DATEDIFF(second,@StartTimeAll , @EndTime)    
		 Set @Duration =
		 ( 
			 Select	right('0' + rtrim(convert(char(2), @DurationSeconds / (60 * 60))), 2) + ':' + 
				right('0' + rtrim(convert(char(2), (@DurationSeconds / 60) % 60)), 2) + ':' + 
				right('0' + rtrim(convert(char(2), @DurationSeconds % 60)),2) AS [HH:MM:SS]
		 )

		 Set @emailSubject ='INDEX_Maintenance job Messages ' + Convert(nVarChar(256),@@SERVERNAME) 
		 
		 Set @emailBody = @Result +Char(13)+'Total ' + (cast(@RebuildCountAll  as VarChar(5))+' index Rebuild,'+cast(@ReOrganizeCountAll  as VarChar(5))
	
							+' index Reorganize edilmistir. '+Char(13)+ 'Süre :' + @Duration +'   ([HH:MM:SS])'+Char(13)+Char(13))
	
 		 EXEC msdb.dbo.sp_send_dbmail
			@profile_name = 'DBA',
			@recipients='dba.alert@firm.com',
			@subject = @emailSubject ,
			@body = @emailBody ,
			@body_format = 'Text' ;

END 







