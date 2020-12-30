-- =============================================
-- Geçilen decimal sonundaki sıfır ve decimal ayracını siler
-- Örnek
-- declare @num table (i decimal(18,4))
-- Test Data
-- insert @num 
-- select 134.000 union all
-- select 1.1200 union all
-- select 100.00 union all
-- select 69 union all
-- select 13. union all
-- select 123456789.9876543210000 union all
-- select 0.0200

-- select dbo.DecimalTrailingZeroRemove(i) from @num
-- =============================================

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DecimalTrailingZeroRemove]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[DecimalTrailingZeroRemove]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION dbo.DecimalTrailingZeroRemove
(
 @value decimal(18,4)
)
RETURNS nvarchar(50)
BEGIN
	
	DECLARE @return nvarchar(50)
	,		@strValue nvarchar(50)

	SET @strValue = CONVERT(nvarchar,@value)

	select @return = (CASE WHEN PATINDEX('%[1-9]%', REVERSE(@strValue)) < PATINDEX('%.%', REVERSE(@strValue)) 
					 THEN LEFT(@strValue, LEN(@strValue) - PATINDEX('%[1-9]%', REVERSE(@strValue)) + 1) ELSE LEFT(@strValue, LEN(@strValue) - PATINDEX('%.%', REVERSE(@strValue))) END)
	
	RETURN @return
END

