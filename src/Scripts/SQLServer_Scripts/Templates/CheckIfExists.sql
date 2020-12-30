-- ==============================================================
-- Alter ve drop öncesi exists kontrolleri
-- ==============================================================

--	1
	IF NOT EXISTS(SELECT * FROM sys.columns 
           	 WHERE Name = N'priceType' AND Object_ID = Object_ID(N'ManualPriceSendItems'))
	BEGIN
    		ALTER TABLE ManualPriceSendItems ADD priceType INT NULL
	END

--  2
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rp_ServiceList]') AND type in (N'P', N'PC'))
	BEGIN
		DROP PROCEDURE [dbo].[rp_ServiceList]
	END