-- ==============================================================
-- OPENQUERY'yi dinamik olarak oluşturmak
-- ==============================================================

set @sql='
select * from OPENQUERY(['+@serverName+'],''exec  ['+@dbName+'].[dbo].rp_CatalogPrice
@fromArea='+CAST(@fromArea as varchar)+',
@country='+CAST(@country as varchar)+',
@night='+CAST(@night as varchar)+',
@month='+CAST(@month as varchar)+',
@year='+CAST(@year as varchar)+',
@currency='+CAST(@currency as varchar)+'
 '') as t '

EXECUTE sp_executesql @sql
