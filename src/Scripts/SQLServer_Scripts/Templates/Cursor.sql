-- ==============================================================
-- Cursor template
-- ==============================================================

DECLARE @ID INT

DECLARE curs_1 CURSOR
    FORWARD_ONLY
    STATIC          
    READ_ONLY        
FOR
	select ...
OPEN curs_1
FETCH NEXT FROM curs_1 INTO @ID 
WHILE @@FETCH_STATUS = 0
BEGIN	
		
    
		
FETCH NEXT FROM curs_1 INTO @ID 
END
CLOSE curs_1
DEALLOCATE curs_1