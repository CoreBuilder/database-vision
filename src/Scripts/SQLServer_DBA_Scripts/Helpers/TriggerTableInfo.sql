-- =============================================
-- Trigger'ların table'ları ve tiplerini listeleyen sorgu
-- =============================================

SELECT 
     sysobjects.name AS trigger_name 
    ,USER_NAME(sysobjects.uid) AS trigger_owner 
    ,s.name AS table_schema 
    ,OBJECT_NAME(parent_obj) AS table_name 
    ,OBJECTPROPERTY( id, 'ExecIsUpdateTrigger') AS isupdate 
    ,OBJECTPROPERTY( id, 'ExecIsDeleteTrigger') AS isdelete 
    ,OBJECTPROPERTY( id, 'ExecIsInsertTrigger') AS isinsert 
    ,OBJECTPROPERTY( id, 'ExecIsAfterTrigger') AS isafter 
    ,OBJECTPROPERTY( id, 'ExecIsInsteadOfTrigger') AS isinsteadof 
    ,OBJECTPROPERTY(id, 'ExecIsTriggerDisabled') AS [disabled] 
FROM sysobjects with(nolock)
INNER JOIN sysusers with(nolock) 
    ON sysobjects.uid = sysusers.uid 
INNER JOIN sys.tables t with(nolock)
    ON sysobjects.parent_obj = t.object_id 
INNER JOIN sys.schemas s with(nolock)
    ON t.schema_id = s.schema_id 
WHERE sysobjects.type = 'TR'