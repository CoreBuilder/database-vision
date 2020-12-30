-- =============================================
-- Yüklü miktarda data bulunan bir tablodan 4000'er 4000'er kayıtları siler. 
-- Transaction log'un büyümesini engeller.
-- =============================================

BEGIN TRANSACTION
	
	CREATE TABLE #IDS (ID INT)

	INSERT INTO #IDS
	select ID FROM ErrorLog with(nolock)
	WHERE errorMessage = 'Ambiguous column name ''cancelStatus''.' 
	and errorProcedure = 'MessageReceive'
    
	WHILE @@ROWCOUNT > 0
	BEGIN
		DELETE TOP (4000) L
		FROM ErrorLog L
		INNER JOIN #IDS D ON D.ID = L.ID
	END

COMMIT TRANSACTION


-- UPDATE

DECLARE @Rows INT,
        @BatchSize INT; -- keep below 5000 to be safe

SET @BatchSize = 2000;

SET @Rows = @BatchSize; -- initialize just to enter the loop

BEGIN TRY    
  WHILE (@Rows = @BatchSize)
  BEGIN
		UPDATE TOP (@BatchSize) rci
		SET rci.AddrHomeEmail = 'blank@detur.com'
		FROM ResCustInfo rci 
		WHERE 
		CHARINDEX('@',rci.AddrHomeEmail) = 0
		 AND rci.AddrHomeEmail IN ('adfhadfh', 'hgkyubhjkluiloij;')

      SET @Rows = @@ROWCOUNT;
  END;
END TRY
BEGIN CATCH
  RETURN;
END CATCH;