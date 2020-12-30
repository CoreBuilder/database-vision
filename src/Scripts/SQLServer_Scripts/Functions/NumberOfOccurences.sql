-- =============================================
-- Aranan string'in, Geçilen string içinde kaç kere tekrarladığını bulur.
-- Örnek - Virgül tekrar sayısı
-- select dbo.FindNumberOfOccurences('ddd,dss,,ggh,,e',',')
-- =============================================

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FindNumberOfOccurences]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FindNumberOfOccurences]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION dbo.FindNumberOfOccurences
(
 @pStr NVARCHAR(MAX)
,@pSearchTerm NVARCHAR(MAX)
)
RETURNS INT
BEGIN
	DECLARE	@counter INT = 0;

	WHILE CHARINDEX(@pSearchTerm,@pStr,0) > 0
	BEGIN
		SET	@pStr = SUBSTRING(@pStr,CHARINDEX(@pSearchTerm,@pStr,0) + 1, LEN(@pStr));
		SET	@counter+=1;
	END	
	RETURN @counter
END