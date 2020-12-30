-- =============================================
-- Geçilen string'i sql objeleri içinde arayarak 
-- geçtiği yerleri döner.
-- Örnek
-- SELECT dbo.FindSQL (bir fonksiyon veya prosedür ismi)
-- =============================================

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FindSQL]') AND type in (N'P'))
DROP PROCEDURE [dbo].[FindSQL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FindSQL]
@Search varchar(255) 
AS
BEGIN

SELECT DISTINCT o.name AS Object_Name
,				o.type_desc
FROM sys.sql_modules m with(nolock) 
INNER JOIN sys.objects o with(nolock) ON m.object_id=o.object_id 
WHERE m.definition Like '%'+@Search+'%' 
ORDER BY 2,1

END

GO