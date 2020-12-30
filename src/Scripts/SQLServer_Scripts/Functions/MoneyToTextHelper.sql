
-- =============================================
-- Geçilen money int'i rusca text olarak döner
-- Örnek
-- select dbo.MoneyToText(4456.32,1) as y
-- =============================================

-- Function için gerekli table örneği

GO

CREATE TABLE [dbo].[TextForNumbers](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[numberIdentity] [int] NULL,
	[digitName] [nvarchar](10) NULL,
	[numberText] [nvarchar](50) NULL,
	[langPrefix] [nvarchar](10) NULL,
 CONSTRAINT [PK_TextForNumbers] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

-- Table için örnek veriler

/*
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(3,1,'i2','одна','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(4,2,'i2','две','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(5,1,'i19','один','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(6,2,'i19','два','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(7,3,'i19','три','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(8,4,'i19','четыре','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(9,5,'i19','пять','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(10,6,'i19','шесть','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(11,7,'i19','семь','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(12,8,'i19','восемь','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(13,9,'i19','девять','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(14,10,'i19','десять','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(15,11,'i19','одиннадцать','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(16,12,'i19','двенадцать','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(17,13,'i19','тринадцать','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(18,14,'i19','четырнадцать','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(19,15,'i19','пятнадцать','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(20,16,'i19','шестнадцать','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(21,17,'i19','семнадцать','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(22,18,'i19','восемнадцать','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(23,19,'i19','девятнадцать','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(24,2,'des','двадцать','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(25,3,'des','тридцать','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(26,4,'des','сорок','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(27,5,'des','пятьдесят','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(28,6,'des','шестьдесят','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(29,7,'des','семьдесят','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(30,8,'des','восемьдесят','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(31,9,'des','девяносто','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(41,1,'hang','сто','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(42,2,'hang','двести','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(43,3,'hang','триста','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(44,4,'hang','четыреста','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(45,5,'hang','пятьсот','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(46,6,'hang','шестьсот','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(47,7,'hang','семьсот','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(48,8,'hang','восемьсот','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(49,9,'hang','девятьсот','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(50,1,'rub','рубль','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(51,2,'rub','рубля','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(52,3,'rub','рублей','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(53,1,'kopeek','копейка','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(54,2,'kopeek','копейки','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(55,3,'kopeek','копеек','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(56,1,'tho','тысяча','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(57,2,'tho','тысячи','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(58,3,'tho','тысяч','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(59,1,'mil','миллион','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(60,2,'mil','миллиона','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(61,3,'mil','миллионов','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(62,1,'mrd','миллиард','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(63,2,'mrd','миллиарда','ru')
INSERT INTO [TextForNumbers] ([ID],[numberIdentity],[digitName],[numberText],[langPrefix])VALUES(64,3,'mrd','миллиардов','ru')
*/


GO


CREATE FUNCTION [dbo].[MoneyToTextHelper](@value int, @digits int) 
RETURNS @ReturnList TABLE
(
  FieldValue NVARCHAR(MAX),
  Digits int
)
AS BEGIN

-- select dbo.MoneyToText(4456.32,1) as y

DECLARE @result nvarchar(max) = ''

DECLARE @d2 int = 0
	
IF @value >= 100 
BEGIN 
	SET @d2 = CEILING(@value / 100)
	SELECT @result += t.numberText FROM TextForNumbers t WHERE t.digitName='hang' AND t.langPrefix='ru' AND t.numberIdentity = @d2
	SET @value %= 100
END

IF @value >= 20
BEGIN
	SET @d2 = CEILING(@value / 10)
	SELECT @result += t.numberText FROM TextForNumbers t WHERE t.digitName='des' AND t.langPrefix='ru' AND t.numberIdentity = @d2
	SET @value %= 10
END

IF @value > 0
BEGIN
	IF @value < 3 AND @digits > 0
	BEGIN
		IF @digits >= 2
			SELECT @result += t.numberText FROM TextForNumbers t WHERE t.digitName='i19' AND t.langPrefix='ru' AND t.numberIdentity = @value	
		ELSE
			SELECT @result += t.numberText FROM TextForNumbers t WHERE t.digitName='i2' AND t.langPrefix='ru' AND t.numberIdentity = @value	
	END
	ELSE
	BEGIN
		SELECT @result += t.numberText FROM TextForNumbers t WHERE t.digitName='i19' AND t.langPrefix='ru' AND t.numberIdentity = @value	
	END
END

DECLARE @many int = 3

IF @value = 1 
	SET @many = 1
ELSE IF @value >= 2 AND @value <=4 
	SET @many = 2
ELSE
	SET @many = 3

INSERT INTO @ReturnList VALUES (@result, @many)

RETURN 

END

GO