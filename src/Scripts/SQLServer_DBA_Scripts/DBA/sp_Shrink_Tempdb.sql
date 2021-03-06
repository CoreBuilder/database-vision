
GO

CREATE Proc [dbo].[sp_Shrink_Tempdb] (@fileSizeLimit int=512)
As

Declare @tmpFile sysname, @cmd VarChar(1024) 

Set @cmd ='Use Tempdb;'+Char(13)+' DBCC FREESESSIONCACHE WITH NO_INFOMSGS;'
Exec (@cmd)

Declare tmpFiles CURSOR
For 
Select [name] From tempdb.sys.database_files Where type_desc ='ROWS'

Open tmpFiles 
FETCH NEXT FROM tmpFiles 
INTO @tmpFile

While @@FETCH_STATUS =0
Begin
	
	Set @cmd ='Use tempdb; DBCC SHRINKFILE ('+@tmpFile+' , '+Convert(VarChar(8),@fileSizeLimit)+')'
	Execute (@cmd)

	FETCH NEXT FROM tmpFiles
	INTO @tmpFile
End 

Close tmpFiles
DeAllocate tmpFiles

