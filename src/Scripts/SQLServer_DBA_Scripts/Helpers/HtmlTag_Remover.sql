--=========================================================
-- Author		: Steven McDonald
-- Date			: 17 February 2011
-- Description	: Removes all HTML tags from provided Text
-- Link			: Original version - 
-- http://blog.sqlauthority.com/2007/06/16/sql-server-udf-user-defined-function-to-strip-html-parse-html-no-regular-expression/
--=========================================================

CREATE FUNCTION StripHTMLTags(
	@HTMLText VARCHAR(MAX)
) RETURNS VARCHAR(MAX)
AS

BEGIN
	DECLARE @Start INT
	DECLARE @End INT
	DECLARE @Length INT
	
	--Gets the start and end indexes of the HTML tag
	SET @Start = CHARINDEX('<', @HTMLText)
	SET @End = CHARINDEX('>', @HTMLText, CHARINDEX('<', @HTMLText))
	SET @Length = (@End - @Start) + 1
	
	WHILE @Start > 0 AND @End > 0 AND @Length > 0
	BEGIN
		--Strip HTML tag out of Text
		SET @HTMLText = STUFF(@HTMLText, @Start, @Length, '')
		SET @Start = CHARINDEX('<', @HTMLText)
		SET @End = CHARINDEX('>', @HTMLText, CHARINDEX('<', @HTMLText))
		
		--If an open tag is found and no close tag is found; 
		--assume the rest of the string is HTML and remove it
		IF(@Start > 0 AND @End = 0)
		BEGIN
			SET @End = LEN(@HTMLText)
		END
		
		SET @Length = (@End - @Start) + 1
	END
	
	RETURN LTRIM(RTRIM(@HTMLText))
END
GO