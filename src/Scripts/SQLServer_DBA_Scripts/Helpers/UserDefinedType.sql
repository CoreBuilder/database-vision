-- =============================================
-- UserDefinedType oluşturulması, kullanılması ve c# içinden çağrılması ile ilgili örnek 
-- =============================================

-- 1. SQL'de tanımlama
--CREATE TYPE PaymentDetail AS TABLE 
--(
--    voucher INT, serviceType INT, serviceID INT
--)

-- 2. Prosedür'de parametre olarak kullanılması
CREATE PROCEDURE [dbo].[PaymentsDetailGet]
(
 @tableVar dbo.PaymentDetail READONLY
)
AS
BEGIN
	
     select top 100 v.* 
     from vvInvoiceServices v with(nolock)
     inner join @TableVar T ON (T.voucher = v.voucher AND T.serviceID = v.srvID AND T.serviceType = v.serviceType)
	
END

-- 3. C# datatable'da SqlType set ediliyor
-- dtServices.Close();
-- dtServices.SelectCommand.Parameters["@TableVar"].SqlType = Devart.Data.SqlServer.SqlType.Structured;
-- dtServices.SelectCommand.Parameters["@TableVar"].Value = dtSelectedServices;
-- dtServices.Open();