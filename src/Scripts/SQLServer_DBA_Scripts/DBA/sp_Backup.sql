
GO

CREATE Proc  [dbo].[sp_Backup] (@BackupType VarChar(8), @Path VarChar(128))
WITH RECOMPILE 
As 
Declare @PrimaryReplicaServer SysName =(Select primary_replica  From sys.dm_hadr_availability_group_states )
Declare @ListenerHostname SysName =(Select dns_name  From sys.availability_group_listeners )

Declare @Tarih VarChar(15), 
	@Gun VarChar(3)= Convert(VarChar(3),Day(GetDate())),
	@Ay VarChar(3)=Convert(VarChar(3),Month(GetDate())),
	 @Yil VarChar(5)= Convert(VarChar(5),Year(GetDate()))

Declare @FileName VarChar(128), @FileType VarChar(8)='',  @dbname VarChar(256), @SubFix VarChar(128) 
Declare @Cmd VarChar(512)=''

Declare @hTime VarChar(20), @hDate VarChar(20),@hParam VarChar(40)

-- Select @PrimaryReplicaServer , @@SERVERNAME , @ListenerHostname 

Set @BackupType =Upper(@BackupType)
if @BackupType = 'DİFF' 
Begin
	Set @BackupType ='DIFF'
End 

Set @SubFix=''

if LEN(@Ay)=1 
	Set @Ay='0'+@AY

if LEN(@Gun)=1
	Set @Gun ='0'+@Gun

Set @Tarih=@Yil+'_'+@Ay+'_'+@Gun

if (@PrimaryReplicaServer= @@SERVERNAME)
Begin -- 'Primary Server'
	if (@BackupType ='DIFF')
	Begin
		DECLARE crs_Databases CURSOR FOR 
			Select name  From sys.databases Where [name] Not IN ('Tempdb', 'Master')  And  state_desc ='ONLINE' And is_read_only =0 And is_in_standby =0 And user_access =0
			Order By name 
		
		Set @FileType ='.firmdiff'
	End
    if (@BackupType ='TRANS')
	Begin
		DECLARE crs_Databases CURSOR FOR 
			Select name  From sys.databases Where [name] Not IN ('Tempdb')  And  state_desc ='ONLINE' And is_read_only =0 And is_in_standby =0 And user_access =0 And recovery_model_desc='FULL'
			Order By name 
		Set @FileType ='.firmtrn'
	End 
    if (@BackupType ='FULL')
	Begin
		DECLARE crs_Databases CURSOR FOR 
			Select name  From sys.databases Where [name]<>'Tempdb'  And state_desc ='ONLINE' And is_read_only =0 And is_in_standby =0 And user_access =0
			Order By name 
		Set @FileType ='.firmbk'
	End
End 
Else 
Begin -- 'Secondary Server'	
	Set @SubFix=@@SERVERNAME+'_' 	
	if (@BackupType ='DIFF')
	Begin
		DECLARE crs_Databases CURSOR FOR 
			Select name  From sys.databases Where [name] Not IN ('Tempdb', 'Master')  And  state_desc ='ONLINE' And is_read_only =0 And is_in_standby =0 And user_access =0
						 And [name] not in (Select [database_name] From sys.availability_databases_cluster)
			Order By name 
		Set @FileType ='.firmdiff'
	End
    if (@BackupType ='TRANS')
	Begin
		DECLARE crs_Databases CURSOR FOR 
			Select name  From sys.databases Where [name] Not IN ('Tempdb')  And  state_desc ='ONLINE' And is_read_only =0 And is_in_standby =0 And user_access =0 And recovery_model_desc='FULL'
						 And [name] not in (Select [database_name] From sys.availability_databases_cluster)
			Order By name 
		Set @FileType ='.firmtrn'
	End 
    if (@BackupType ='FULL')
	Begin
		DECLARE crs_Databases CURSOR FOR 
			Select name  From sys.databases Where [name]<>'Tempdb'  And state_desc ='ONLINE' And is_read_only =0 And is_in_standby =0 And user_access =0
						 And [name] not in (Select [database_name] From sys.availability_databases_cluster)
			Order By name 
		Set @FileType ='.firmbk'
	End
End

OPEN crs_Databases
FETCH NEXT FROM crs_Databases
INTO @dbname 

WHILE @@FETCH_STATUS = 0
BEGIN
	Set @hTime=CAST(GETDATE() AS time(7))
	Set @hTime=REPLACE ( @hTime , ':' , '' )
	Set @hTime='_'+REPLACE ( @hTime , '.' , '_' )
	Set @hTime = Left(@hTime, 10)

	Set @FileName=@Path+@BackupType +'\'+@SubFix+@dbname+'_'+@BackupType +'_'+@Tarih+@hTime+@FileType 
	Set @Cmd =
		(Select 
		Case 
			When @BackupType ='FULL' Then 
				'BACKUP DATABASE ' +@dbname +' TO DISK = '+Char(39)+ @FileName +Char(39)+ ' With COMPRESSION '

			When @BackupType ='TRANS' Then 
				'BACKUP LOG ' +@dbname +' TO DISK = ' + Char(39)+ @FileName +Char(39)+ ' With COMPRESSION '

			When @BackupType = 'DIFF' Then 
				'BACKUP DATABASE ' +@dbname +' TO DISK = '+ Char(39)+ @FileName +Char(39)+ ' With DIFFERENTIAL, COMPRESSION '
		End) 

	Exec (@Cmd)
	   
	FETCH NEXT FROM crs_Databases   
	INTO @dbname 
END

Close crs_Databases
DeAllocate crs_Databases

Set @hDate=CAST(DATEADD(DD,-21,GETDATE()) AS Date)
Set @hParam=@hDate

EXECUTE master.dbo.xp_delete_file 0,@Path,@FileType ,@hParam
