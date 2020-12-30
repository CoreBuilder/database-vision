
-- =============================================
-- Parent Child ilişkisi içeren tabloda parent'ı olan kayıtları döner
-- =============================================

WITH PaymentTree (parentPaymentID, paymentID, localID, paymentSource, paymentLevel) AS
(
	select P.parentID, P.ID, P.localID, P.paymentSource, 0 as paymentlLevel 
	from Payment P with(nolock)
	where P.parentID IS NULL
	UNION ALL
	select P.parentID, P.ID, P.localID, P.paymentSource, 1 as paymentlLevel 
	from Payment P with(nolock)
	inner join PaymentTree PT ON PT.PaymentID = P.parentID
)
select * from PaymentTree
where paymentLevel > 0
OPTION (MAXRECURSION 2)