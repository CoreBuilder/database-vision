-- ==============================================================
-- Error Handling Template
-- ==============================================================

CREATE PROCEDURE dbo.ErrorHandlingTemplate
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON
        SET XACT_ABORT ON
 
        --  Code Which Doesn't Require Transaction
 
        BEGIN TRANSACTION
            -- Code which Requires Transaction 
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 AND XACT_STATE() <> 0 
            ROLLBACK TRAN
 
        -- Do the Necessary Error logging if required
        -- Take Corrective Action if Required
 
        THROW --RETHROW the ERROR -- SQL 2012 and above only
    END CATCH
END