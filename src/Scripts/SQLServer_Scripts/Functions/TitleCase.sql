-- =============================================
-- Geçilen string içindeki kelimeleri büyük harfler ile başlayacak şekilde geri döner.
-- Örnek
-- SELECT dbo.TitleCase ('ALL UPPER CASE and   SOME lower')
-- =============================================

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TitleCase]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[TitleCase]
GO

CREATE FUNCTION dbo.TitleCase
(
    @Input as varchar(8000)
)
RETURNS varchar(8000)
AS
BEGIN  
    DECLARE @Reset bit,
            @Proper varchar(8000),
            @Counter int,
            @FirstChar char(1)
                
    SELECT @Reset = 1, @Counter = 1, @Proper = ''
     
    WHILE (@Counter <= LEN(@Input))
    BEGIN
        SELECT  @FirstChar = SUBSTRING(@Input, @Counter, 1),
                @Proper = @Proper + CASE WHEN @Reset = 1 THEN UPPER(@FirstChar) ELSE LOWER(@FirstChar) END,
                @Reset = CASE WHEN @FirstChar LIKE '[a-zA-Z]' THEN 0 ELSE 1 END,
                @Counter = @Counter + 1
    END
     
    SELECT @Proper = REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(@Proper)),'  ',' '+ CHAR(7)) , CHAR(7)+' ',''), CHAR(7),'')
    WHERE CHARINDEX('  ', @Proper) > 0 
     
    RETURN @Proper
END