-- =============================================
-- Sıralı ID'den aradan silme yapıldıktan sonra 
-- tekrar ID sıralama yapma işlemi
-- =============================================

CREATE TABLE #testt (ID INT UNIQUE, nor INT)

INSERT INTO #testt
select 1, 50
UNION
select 2, 50
UNION
select 3, 50
UNION
select 4, 50

select * from #testt

delete from #testt where ID IN (1,4)

select * from #testt

WITH myCTE (ID1, nor, ID) AS 
(
	Select Row_Number() Over ( Order By ID )
    , nor
	, ID
	From #testt
)
UPDATE t
SET t.ID = myCTE.ID1
FROM #testt t
inner join myCTE ON t.ID = myCTE.ID

select * from #testt