-- ==============================================================
-- Trigger Template
-- ==============================================================

CREATE TRIGGER [dbo].[PaymentPlan] ON [dbo].[Voucher] AFTER INSERT,UPDATE,DELETE
AS
BEGIN	

IF @@ROWCOUNT = 0 return
SET NOCOUNT ON

DECLARE @action nvarchar(10),
		@ID INT = 0,
        @insCount int = (SELECT COUNT(*) FROM inserted),
        @delCount int = (SELECT COUNT(*) FROM deleted)
        
SELECT @action = CASE WHEN @insCount > @delCount THEN 'inserted'
                      WHEN @insCount < @delCount THEN 'deleted' ELSE 'updated' END
	
	-- Table toplu update alıyor ise cursor ile dön
	IF @action = 'inserted'
	BEGIN 
		select 1	
	END

	IF @action = 'updated'
	BEGIN 
		select 2	
	END

	IF @action = 'deleted'
	BEGIN 
		select 3
	END
	
END
